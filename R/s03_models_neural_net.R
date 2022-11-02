# s03_models_neural_net.R


# Step 03 : Fit neural networks to water temperature.


# Project : water_temperature_neural_networkds
# Author  : Jeremie Boudreault
# Email   : Jeremie.Boudreault [at] inrs [dot] ca
# Depends : R (v4.2.1)
# License : CC BY-NC-ND 4.0


# Library ----------------------------------------------------------------------


library(data.table)
library(ggplot2)
library(neuralnet)


# Imports ----------------------------------------------------------------------


data <- data.table::fread(
    file.path("data", "cleaned", "hydro_weather_data_v2.csv")
)


# Train-test split -------------------------------------------------------------


# Split data for train.
data_train <- data[DATASET == "TRAIN", ]
data_test <- data[DATASET == "TEST", ]

# Check split.
nrow(data_train)
nrow(data_test)
nrow(data_train)/nrow(data)
nrow(data_test)/nrow(data)


# Scale all predictors ---------------------------------------------------------


for (pred in c("AIRTEMP", "FLOW", "PRECIP", "CLOUD", "SUNSHINE", "WIND")) {

    # Compute mean and standard deviation on train only.
    m <- mean(data_train[[pred]])
    sd <- sd(data_train[[pred]])

    # Update values on train and test.
    data.table::set(data_train, j = pred, value = (data_train[[pred]] - m)/sd)
    data.table::set(data_test, j = pred, value = (data_test[[pred]] - m)/sd)

}


# Exports datasets for traceability --------------------------------------------


# Columns of interest.
cols <- c(
    "WATERTEMP", "AIRTEMP", "FLOW", "PRECIP",
    "CLOUD", "SUNSHINE", "WIND"
)

# Export train data.
data.table::fwrite(
    x    = data_train[, ..cols],
    file = file.path("data", "cleaned", "water_temp_data_scaled_train.csv")
)

# Export test data.
data.table::fwrite(
    x    = data_test[, ..cols],
    file = file.path("data", "cleaned", "water_temp_data_scaled_test.csv")
)


# Formula ----------------------------------------------------------------------


formula_small <- paste0(
    "WATERTEMP ~ AIRTEMP"
)

formula_full <- paste0(
    "WATERTEMP ~ ",
    "AIRTEMP + FLOW + PRECIP + ",
    "CLOUD + SUNSHINE + WIND"
)


# Fit models --------------------------------------------------------------------


# Perceptron linéaire (une variable explicative)
nn_00 <- neuralnet::neuralnet(
    data          = data_train,
    formula       = formula_small,
    hidden        = c(0L),
    linear.output = TRUE,
    lifesign      = "full",
    learningrate  = 0.01,
    threshold     = 0.1
)

# Perceptron linéaire.
nn_0 <- neuralnet::neuralnet(
    data          = data_train,
    formula       = formula_full,
    hidden        = c(0L),
    linear.output = TRUE,
    lifesign      = "full",
    learningrate  = 0.01,
    threshold     = 0.1
)

# Perceptron multicouche avec 5 neuronnes dans la première couche.
nn_5 <- neuralnet::neuralnet(
    data          = data_train,
    formula       = formula_full,
    hidden        = c(5L),
    linear.output = TRUE,
    lifesign      = "full",
    learningrate  = 0.01,
    threshold     = 0.1
)

# Perceptron multicouche avec 5 neuronnes dans la première couche et fonction tanh.
nn_5_tanh <- neuralnet::neuralnet(
    data          = data_train,
    formula       = formula_full,
    hidden        = c(5L),
    act.fct       = "tanh",
    linear.output = TRUE,
    lifesign      = "full",
    learningrate  = 0.01,
    threshold     = 0.1
)

# Perceptron multicouche avec 7 et 5 neurones et fonction tanh.
nn_75_tanh <- neuralnet::neuralnet(
    data          = data_train,
    formula       = formula_full,
    hidden        = c(7L, 5L),
    act.fct       = "tanh",
    linear.output = TRUE,
    lifesign      = "full",
    learningrate  = 0.05,
    threshold     = 0.1
)

# On affiche les réseaux.
plot(nn_00)
plot(nn_0)
plot(nn_5)
plot(nn_5_tanh)
plot(nn_75_tanh)

# On imprique nos modèles dans une liste.
nn_list <- list(
    perceptron_lin_sim = nn_00,
    perceptron_lin     = nn_0,
    perceptron_5       = nn_5,
    perceptron_5_tanh  = nn_5_tanh,
    perceptron_75_tanh = nn_75_tanh
)

# Évaluation des modèles (entraînement).
pred_train <- lapply(
    X       = nn_list,
    FUN     = predict,
    newdata = data_train
)

# Évaluation des modèles (test).
pred_test <- lapply(
    X       = nn_list,
    FUN     = predict,
    newdata = data_test
)

# On extrait les observations.
obs_train <- train[, "WATERTEMP"]
obs_test  <- test[, "WATERTEMP"]

# Fonction pour calculer l'erreur quandratique moyenne (RMSE).
calculate_rmse <- function(obs, pred) {
    round(sqrt(mean((obs - pred)^2)), 2L)
}

# On applique la fonction sur chaque prédiction (Entraînement)
lapply(
    X   = pred_train,
    FUN = calculate_rmse,
    obs = obs_train
)

# On applique la fonction sur chaque prédiction (Test)
lapply(
    X   = pred_test,
    FUN = calculate_rmse,
    obs = obs_test
)

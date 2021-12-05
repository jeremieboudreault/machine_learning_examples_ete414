# s03_models_neural_net.R


# Step 03 : Fit neural networks to water temperature.


# Project : water_temperature_neural_networkds
# Author  : Jeremie Boudreault
# Email   : Jeremie.Boudreault [at] inrs [dot] ca
# Depends : R (v3.6.3)
# License : CC BY-NC-ND 4.0



# Library ----------------------------------------------------------------------


library(data.table)
library(ggplot2)
library(neuralnet)


# Imports ----------------------------------------------------------------------


data <- data.table::fread(
    file.path("data", "cleaned", "hydro_weather_data_v1.csv")
)


# Scaling ----------------------------------------------------------------------


data_scaled <- scale(data[, -c("DATE", "YEAR", "MONTH", "DAYOFYEAR")])


# Training-Test split ----------------------------------------------------------


# Set seed prior to split.
set.seed(2912L)

# Compute train indice.
train <- sample(
    x       = seq.int(1L, nrow(data_scaled)),
    size    = floor(nrow(data_scaled) * 0.70),
    replace = FALSE
)

# Split data.
data_scaled_train <- data_scaled[train, ]
data_scaled_test  <- data_scaled[-train, ]

# Check split.
nrow(data_scaled_train)
nrow(data_scaled_test)
nrow(data_scaled_train)/nrow(data_scaled)
nrow(data_scaled_test)/nrow(data_scaled)


# Formula ----------------------------------------------------------------------


formula_small <- paste0(
    "WATERTEMP_MEAN ~ AIRTEMP_MEAN"
)

formula_full <- paste0(
    "WATERTEMP_MEAN ~ ",
    "AIRTEMP_MEAN + FLOW_MEAN + PRECIP_MEAN + ",
    "CLOUD + SUNSHINE_TOTAL + WIND_MEAN"
)


# Fit models --------------------------------------------------------------------


# Perceptron linéaire (une variable explicative)
nn_00 <- neuralnet::neuralnet(
    data          = data_scaled_train,
    formula       = formula_small,
    hidden        = c(0L),
    linear.output = TRUE,
    lifesign      = "full",
    learningrate  = 0.01,
    threshold     = 0.1
)

# Perceptron linéaire.
nn_0 <- neuralnet::neuralnet(
    data          = data_scaled_train,
    formula       = formula_full,
    hidden        = c(0L),
    linear.output = TRUE,
    lifesign      = "full",
    learningrate  = 0.01,
    threshold     = 0.1
)

# Perceptron multicouche avec 5 neuronnes dans la première couche.
nn_5 <- neuralnet::neuralnet(
    data          = data_scaled_train,
    formula       = formula_full,
    hidden        = c(5L),
    linear.output = TRUE,
    lifesign      = "full",
    learningrate  = 0.01,
    threshold     = 0.1
)

# Perceptron multicouche avec 5 neuronnes dans la première couche et fonction tanh.
nn_5_tanh <- neuralnet::neuralnet(
    data          = data_scaled_train,
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
    data          = data_scaled_train,
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
    newdata = data_scaled_train
)

# Évaluation des modèles (test).
pred_test <- lapply(
    X       = nn_list,
    FUN     = predict,
    newdata = data_scaled_test
)

# On veut transformer nos prédictions en valeurs de températures.
mean_temp <- 14.56391
std_temp <- 5.108149

# On convertit nos prédictions en températures.
for (i in 1:5) {
    pred_train[[i]] <- pred_train[[i]] * std_temp + mean_temp
    pred_test[[i]]  <- pred_test[[i]]  * std_temp + mean_temp
}

# On extrait les observations.
obs_train <- train[, "WATERTEMP_MEAN"] * std_temp + mean_temp
obs_test  <- test[, "WATERTEMP_MEAN"]  * std_temp + mean_temp

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

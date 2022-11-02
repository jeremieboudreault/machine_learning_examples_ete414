# s02_models_linear_reg.R


# Step 02 : Fit on a linear regression model as a benchmark.


# Project : water_temperature_neural_networkds
# Author  : Jeremie Boudreault
# Email   : Jeremie.Boudreault [at] inrs [dot] ca
# Depends : R (v4.2.1)
# Imports : jtheme v0.0.3 [https://github.com/jeremieboudreault/jtheme]
# License : CC BY-NC-ND 4.0


# Library ----------------------------------------------------------------------


library(data.table)
library(jtheme)


# Imports ----------------------------------------------------------------------


data <- data.table::fread(
    file.path("data", "cleaned", "hydro_weather_data_v2.csv")
)


# Fit linear regression --------------------------------------------------------


fit_1 <- lm(
    formula = WATERTEMP ~ AIRTEMP,
    data    = data[DATASET == "TRAIN", ]
)

fit_2 <- lm(
    formula = WATERTEMP ~ poly(AIRTEMP, 2L),
    data    = data[DATASET == "TRAIN", ]
)

fit_3 <- lm(
    formula = WATERTEMP ~ poly(AIRTEMP, 3L),
    data    = data[DATASET == "TRAIN", ]
)


# Summary of the model ---------------------------------------------------------


(fit_1_summ <- summary(fit_1))
(fit_2_summ <- summary(fit_2))
(fit_3_summ <- summary(fit_3))


# AIC values -------------------------------------------------------------------


AIC(fit_1)
AIC(fit_2)
AIC(fit_3)


# Compute RMSE -----------------------------------------------------------------


# Train.
RMSE_1 <- sqrt(mean(residuals(fit_1)^2))
RMSE_2 <- sqrt(mean(residuals(fit_2)^2))
RMSE_3 <- sqrt(mean(residuals(fit_3)^2))

# Test
RMSE_1_test <- sqrt(mean((predict(fit_1, data[DATASET == "TEST"]) - data[DATASET == "TEST", WATERTEMP])^2))
RMSE_2_test <- sqrt(mean((predict(fit_2, data[DATASET == "TEST"]) - data[DATASET == "TEST", WATERTEMP])^2))
RMSE_3_test <- sqrt(mean((predict(fit_3, data[DATASET == "TEST"]) - data[DATASET == "TEST", WATERTEMP])^2))


# Extract regression lines -----------------------------------------------------


# Create x grid.
reg_lines <- data.table::data.table(
    AIRTEMP = seq(min(data$AIRTEMP), max(data$AIRTEMP), length.out = 100)
)

# Predict on the grid.
reg_lines[, Linear  := predict(fit_1, newdata = reg_lines)]
reg_lines[, Degree2 := predict(fit_2, newdata = reg_lines)]
reg_lines[, Degree3 := predict(fit_3, newdata = reg_lines)]

# Melt table.
reg_lines <- data.table::melt.data.table(reg_lines, id.vars = "AIRTEMP")

# Rename columns.
reg_lines[variable == "Linear",
          variable := paste0("Linear (RMSE = ", round_trim(RMSE_1, 2L), "/", round_trim(RMSE_1_test, 2L), "ºC)")]
reg_lines[variable == "Degree2",
          variable := paste0("Degree 2 (RMSE = ", round_trim(RMSE_2,2L), "/", round_trim(RMSE_2_test, 2L), "ºC)")]
reg_lines[variable == "Degree3",
          variable := paste0("Degree 3 (RMSE = ", round_trim(RMSE_3, 2L), "/", round_trim(RMSE_3_test, 2L), "ºC)")]


# Plot final results -----------------------------------------------------------


ggplot(
    data   = data,
    mapping = aes(
        x    = AIRTEMP,
        y    = WATERTEMP
    )
) +
geom_point(
    mapping = aes(fill = DATASET),
    alpha  = 0.1,
    stroke = 0,
    size   = 2L,
    shape  = 21L,
    show.legend = FALSE
) +
geom_line(
    data = reg_lines,
    mapping = aes(
        x   = AIRTEMP,
        y   = value,
        col = variable
    ),
    lwd = 0.7
) +
labs(
    title = "Linear models for water temperature",
    x     = "Air temperature (ºC)",
    y     = "Water temperature (ºC)",
    color = NULL,
    fill  = NULL
) +
scale_fill_manual(values = c("darkred", "black")) +
jtheme(border = "all") +
theme(legend.position = c(0.835, 0.125))


# Exports -----------------------------------------------------------------


jtheme::save_ggplot(
    file = file.path("plots", "fig_01_linear_models_results.jpg"),
    size = "rect"
)


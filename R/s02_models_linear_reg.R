# s02_models_linear_reg.R


# Step 02 : Fit on a linear regression model as a benchmark.


# Project : water_temperature_neural_networkds
# Author  : Jeremie Boudreault
# Email   : Jeremie.Boudreault [at] inrs [dot] ca
# Depends : R (v3.6.3)
# License : CC BY-NC-ND 4.0



# Library ----------------------------------------------------------------------


library(ggplot2)


# Imports ----------------------------------------------------------------------


data <- data.table::fread(
    file.path("data", "cleaned", "hydro_weather_data_v1.csv")
)


# Fit linear regression --------------------------------------------------------


fit_1 <- lm(
    formula = WATERTEMP_MEAN ~ AIRTEMP_MEAN,
    data    = data
)

fit_2 <- lm(
    formula = WATERTEMP_MEAN ~ poly(AIRTEMP_MEAN, 2L),
    data    = data
)

fit_3 <- lm(
    formula = WATERTEMP_MEAN ~ poly(AIRTEMP_MEAN, 3L),
    data    = data
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


RMSE_1 <- sqrt(mean(residuals(fit_1)^2))
RMSE_2 <- sqrt(mean(residuals(fit_2)^2))
RMSE_3 <- sqrt(mean(residuals(fit_3)^2))


# Extract regression lines -----------------------------------------------------


# Create x grid.
reg_lines <- data.table::data.table(
    AIRTEMP_MEAN = seq(min(data$AIRTEMP_MEAN), max(data$AIRTEMP_MEAN), length.out = 100)
)

# Predict on the grid.
reg_lines[, Linear  := predict(fit_1, newdata = reg_lines)]
reg_lines[, Degree2 := predict(fit_2, newdata = reg_lines)]
reg_lines[, Degree3 := predict(fit_3, newdata = reg_lines)]

# Melt table.
reg_lines <- data.table::melt.data.table(reg_lines, id.vars = "AIRTEMP_MEAN")

# Rename columns.
reg_lines[variable == "Linear",
          variable := paste0("Linear (RMSE = ", round(RMSE_1, 2L), "ºC)")]
reg_lines[variable == "Degree2",
          variable := paste0("Degree 2 (RMSE = ", round(RMSE_2,2L), "ºC)")]
reg_lines[variable == "Degree3",
          variable := paste0("Degree 3 (RMSE = ", round(RMSE_3, 2L), "ºC)")]


# Plot final results -----------------------------------------------------------


ggplot(
    data   = data,
    mapping = aes(
        x = AIRTEMP_MEAN,
        y = WATERTEMP_MEAN
    )
) +
geom_point(
    alpha  = 0.1,
    stroke = 0,
    size   = 2L,
    shape  = 19L
) +
geom_line(
    data = reg_lines,
    mapping = aes(
        x = AIRTEMP_MEAN,
        y = value,
        col = variable
    ),
    lwd = 0.7
) +
labs(
    title = "Regression models for mean water temperature",
    x     = "Air temperature (ºC)",
    y     = "Water temperature (ºC)",
    color = "Models"
) +
theme(legend.position = c(0.825, 0.175))


# Exports -----------------------------------------------------------------


ggplot2::ggsave(
    filename = file.path("plots", "fig_01_linear_models_results.jpg"),
    width    = 7L,
    height   = 5L,
)


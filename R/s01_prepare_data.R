# s01_prepare_data.R


# Step 01 : Prepare data of water temperature and weather data prior to fit.


# Project : water_temperature_neural_networkds
# Author  : Jeremie Boudreault
# Email   : Jeremie.Boudreault [at] inrs [dot] ca
# Depends : R (v3.6.3)
# License : CC BY-NC-ND 4.0



# Library ----------------------------------------------------------------------


library(data.table)


# Versioning -------------------------------------------------------------------


dataset_ver <- "v1"


# Hydrological data ------------------------------------------------------------


# Import.
hydro_data <- data.table::fread(
    file.path("data", "hydro", "06054500.txt")
)

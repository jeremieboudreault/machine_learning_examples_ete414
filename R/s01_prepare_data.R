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


# Update columns names.
colnames(hydro_data) <- c(
    "AGENCY",
    "STNID",
    "DATE",
    "WATERTEMP_MAX",
    "WATERTEMP_MAX_FLAG",
    "WATERTEMP_MIN",
    "WATERTEMP_MIN_FLAG",
    "WATERTEMP_MEAN",
    "WATERTEMP_MEAN_FLAG",
    "FLOW_MEAN",
    "FLOW_MEAN_FLAG"
)

# Remove the first two rows.
hydro_data <- hydro_data[3:nrow(hydro_data), ]

# Convert to numeric values.
hydro_data[, `:=`(
    DATE            = as.Date(DATE),
    WATERTEMP_MAX   = as.numeric(WATERTEMP_MAX),
    WATERTEMP_MIN   = as.numeric(WATERTEMP_MIN),
    WATERTEMP_MEAN  = as.numeric(WATERTEMP_MEAN),
    FLOW_MEAN       = as.numeric(FLOW_MEAN)
)]

# Create YEAR, MONTH and DAYOFYEAR values.
hydro_data[, `:=`(
    YEAR       = as.integer(format(DATE, "%Y")),
    MONTH      = as.integer(format(DATE, "%m")),
    DAYOFYEAR  = as.integer(format(DATE, "%j"))
)]

# Check values (factors)
table(hydro_data$AGENCY, useNA = "ifany")
table(hydro_data$STNID, useNA = "ifany")
table(hydro_data$WATERTEMP_MAX_FLAG, useNA = "ifany")
table(hydro_data$WATERTEMP_MIN_FLAG, useNA = "ifany")
table(hydro_data$WATERTEMP_MEAN_FLAG, useNA = "ifany")
table(hydro_data$FLOW_MEAN_FLAG, useNA = "ifany")

# Check values (date).
range(hydro_data$DATE)
range(hydro_data$YEAR)
range(hydro_data$MONTH)
range(hydro_data$DAYOFYEAR)

# Check values (numeric).
summary(hydro_data$WATERTEMP_MAX)
summary(hydro_data$WATERTEMP_MIN)
summary(hydro_data$WATERTEMP_MEAN)
summary(hydro_data$FLOW_MEAN)

# Keep only columns of interest.
hydro_data <- hydro_data[, .(
    DATE,
    YEAR,
    MONTH,
    DAYOFYEAR,
    WATERTEMP_MIN,
    WATERTEMP_MEAN,
    WATERTEMP_MAX,
    FLOW_MEAN
)]

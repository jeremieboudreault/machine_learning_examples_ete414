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


# Weather data -----------------------------------------------------------------


# Imports.
weather_data <- data.table::fread(
    file.path("data", "weather", "USW00024144.csv")
)

# Update column names.
colnames(weather_data) <- c(
    "STNID",
    "STNNAME",
    "LATITUDE",
    "LONGITUDE",
    "ELEVATION",
    "DATE",
    "CLOUDMANUAL",
    "CLOUDMANUAL_FLAG",
    "CLOUDAUTO",
    "CLOUDAUTO_FLAG",
    "WIND_MEAN",
    "WIND_MEAN_FLAG",
    "PRECIP_MEAN",
    "PRECIP_MEAN_FLAG",
    "SUNSHINE_PERCENT",
    "SUNSHINE_PERCENT_FLAG",
    "SNOWFALL",
    "SNOWFALL_FLAG",
    "SNOWDEPTH",
    "SNOWDEPTH_FLAG",
    "AIRTEMP_MEAN",
    "AIRTEMP_MEAN_FLAG",
    "AIRTEMP_MAX",
    "AIRTEMP_MAX_FLAG",
    "AIRTEMP_MIN",
    "AIRTEMP_MIN_FLAG",
    "SUNSHINE_TOTAL",
    "SUNSHINE_TOTAL_FLAG",
    "WIND_GUST",
    "WIND_GUST_FLAG"
)

# Convect values to numeric.
weather_data[, SUNSHINE_PERCENT := as.numeric(SUNSHINE_PERCENT)]
weather_data[, SUNSHINE_TOTAL := as.numeric(SUNSHINE_TOTAL)]
weather_data[, CLOUDMANUAL := as.numeric(CLOUDMANUAL)]
weather_data[, CLOUDAUTO   := as.numeric(CLOUDAUTO)]
weather_data[, CLOUD       := rowMeans(
    x     = weather_data[, .(CLOUDMANUAL, CLOUDAUTO)],
    na.rm = TRUE
)]

# Convert to date values and create YEAR, MONTH and DAYOFYEAR values.
weather_data[, DATE := as.Date(DATE)]
weather_data[, `:=`(
    YEAR       = as.integer(format(DATE, "%Y")),
    MONTH      = as.integer(format(DATE, "%m")),
    DAYOFYEAR  = as.integer(format(DATE, "%j"))
)]

# Check values (factors)
table(weather_data$STNID,       useNA = "ifany")
table(weather_data$STNNAME,     useNA = "ifany")
table(weather_data$LATITUDE,    useNA = "ifany")
table(weather_data$LONGITUDE,   useNA = "ifany")
table(weather_data$ELEVATION,   useNA = "ifany")
table(weather_data$CLOUDMANUAL, useNA = "ifany")
table(weather_data$CLOUDAUTO,   useNA = "ifany")

# Check values (date).
range(weather_data$DATE)
range(weather_data$YEAR)
range(weather_data$MONTH)
range(weather_data$DAYOFYEAR)

# Check values (numeric).
summary(weather_data$CLOUD)
summary(weather_data$WIND_MEAN)
summary(weather_data$WIND_GUST)
summary(weather_data$PRECIP_MEAN)
summary(weather_data$SUNSHINE_PERCENT)
summary(weather_data$SUNSHINE_TOTAL)
summary(weather_data$SNOWFALL)
summary(weather_data$SNOWDEPTH)
summary(weather_data$AIRTEMP_MEAN)
summary(weather_data$AIRTEMP_MIN)
summary(weather_data$AIRTEMP_MAX)

# Keep only columns of interest.
weather_data <- weather_data[, .(
    DATE,
    AIRTEMP_MEAN,
    AIRTEMP_MIN,
    AIRTEMP_MAX,
    PRECIP_MEAN,
    CLOUD,
    SUNSHINE_PERCENT,
    SUNSHINE_TOTAL,
    WIND_MEAN,
    WIND_GUST
)]


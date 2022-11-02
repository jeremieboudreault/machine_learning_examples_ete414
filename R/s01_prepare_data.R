# s01_prepare_data.R


# Step 01 : Prepare data of water temperature and weather data prior to fit.


# Project : water_temperature_machine_learning_ete414
# Author  : Jeremie Boudreault
# Email   : Jeremie.Boudreault [at] inrs [dot] ca
# Depends : R (v4.2.1)
# License : CC BY-NC-ND 4.0


# Library ----------------------------------------------------------------------


library(data.table)


# Versioning -------------------------------------------------------------------


dataset_ver <- "v2"


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
    FLOW_MEAN       = as.numeric(FLOW_MEAN)  / 35.3147  # Convert to m3/s
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


# Combine both data ------------------------------------------------------------


data <- data.table::merge.data.table(
    x     = hydro_data,
    y     = weather_data,
    by    = "DATE",
    all.x = TRUE
)

# Clean data prior to exporting ------------------------------------------------


# Check missing <WATERTEMP>.
sum(is.na(data$WATERTEMP_MAX))
sum(is.na(data$WATERTEMP_MIN))
sum(is.na(data$WATERTEMP_MEAN))

# Try to fix some <WATERTEMP_MEAN>.
data[is.na(WATERTEMP_MEAN), WATERTEMP_MEAN := (WATERTEMP_MAX + WATERTEMP_MIN) / 2]
sum(is.na(data$WATERTEMP_MEAN))

# Remove data that have no <WATERTEMP_MEAN>.
data <- data[!is.na(WATERTEMP_MEAN) & !is.na(WATERTEMP_MAX) & !is.na(WATERTEMP_MIN), ]

# Try to fix some <AIRTEMP_MEAN>.
sum(is.na(data$AIRTEMP_MEAN))
data[is.na(AIRTEMP_MEAN), AIRTEMP_MEAN := (AIRTEMP_MAX + AIRTEMP_MIN) / 2]
sum(is.na(data$AIRTEMP_MEAN))

# Remove remaining missing air temp.
data <- data[!is.na(AIRTEMP_MEAN) & !is.na(AIRTEMP_MAX) & !is.na(AIRTEMP_MIN)]

# Final check on temperature.
sum(is.na(data$AIRTEMP_MEAN))
sum(is.na(data$AIRTEMP_MIN))
sum(is.na(data$AIRTEMP_MAX))

# Some correction to the values.
data[is.na(FLOW_MEAN),      FLOW_MEAN      := median(data$FLOW_MEAN, na.rm = TRUE)]
data[is.na(PRECIP_MEAN),    PRECIP_MEAN    := median(data$PRECIP_MEAN, na.rm = TRUE)]
data[is.na(CLOUD),          CLOUD          := median(data$CLOUD, na.rm = TRUE)]
data[is.na(SUNSHINE_TOTAL), SUNSHINE_TOTAL := median(data$SUNSHINE_TOTAL, na.rm = TRUE)]
data[is.na(WIND_MEAN),      WIND_MEAN      := median(data$WIND_MEAN, na.rm = TRUE)]

# Filter on non-freezing months.
data <- data[MONTH %in% seq.int(4L, 10L)]


# Create <TRAIN> and <TEST> prior to export ------------------------------------


# Set seed prior to split.
set.seed(2912L)

# Compute train indice.
train <- sample(
    x       = seq.int(1L, nrow(data)),
    size    = floor(nrow(data) * 0.70),
    replace = FALSE
)

# Set <DATASET> indicateur.
data[train, DATASET := "TRAIN"]
data[-train, DATASET := "TEST"]

# Check result.
table(data$DATASET, useNA = "always")


# Dataset for water temperature modelling --------------------------------------


# Final data for temperature modelling
data_final <- data[, .(DATE,
         DATASET,
         WATERTEMP = WATERTEMP_MEAN,
         AIRTEMP   = AIRTEMP_MEAN,
         FLOW      = FLOW_MEAN,
         PRECIP    = PRECIP_MEAN,
         CLOUD     = CLOUD,
         SUNSHINE  = SUNSHINE_TOTAL,
         WIND      = WIND_MEAN
)]

# Export.
data.table::fwrite(
    x    = data_final,
    file = file.path(
        "data", "cleaned", sprintf("hydro_weather_data_%s.csv", dataset_ver)
    )
)

# Export.
data.table::fwrite(
    x    = data_final,
    file = file.path(
        "rmd", "data", sprintf("donnees_temp_eau_reg.csv")
    )
)



# Dataset for fishing season ---------------------------------------------------


# Create an indicator of open-closed fishing.
data[WATERTEMP_MAX > 20, IND := "Fermée"]
data[WATERTEMP_MAX <= 20, IND := "Ouverte"]

# Create a subset of the data.
data_fishing <- data[, .(
    Date        = DATE,
    Peche       = IND,
    Temperature = AIRTEMP_MEAN,
    Debit       = FLOW_MEAN
)]

# Export to rmd/data.
data.table::fwrite(data_fishing, "rmd/data/donnees_peche_classif.csv")


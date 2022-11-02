# 01_mlp_sklearn.py


# 1 : Fit MLP to river tempeature data using Scikit-learn.


# Project : water_temperature_machine_learning_ete414
# Author  : Jeremie Boudreault
# Email   : Prenom.Nom@inrs.ca
# Depends : Python 3.10.7. 
# Imports : See below.
# License : CC BY-NC-ND 4.0


# Libraries --------------------------------------------------------------------


import pandas as pd                                # Pandas DataFrame
from sklearn.neural_network import MLPRegressor    # MLP regressor
from sklearn.model_selection import GridSearchCV   # CV Grid Search
import sklearn.metrics                             # Metrics


# Imports ----------------------------------------------------------------------


# Load scaled train data.
train = pd.read_csv(
    filepath_or_buffer = "data/cleaned/water_temp_data_scaled_train.csv", 
    delimiter          = ",", 
    decimal            = "."
)

# Load scaled test data.
test = pd.read_csv(
    filepath_or_buffer = "data/cleaned/water_temp_data_scaled_test.csv", 
    delimiter          = ",", 
    decimal            = "."
)


# Explore data -----------------------------------------------------------------


# Check train dataset.
train.head()
train.info()
train.shape

# Check test dataset.
test.head()
test.info()
test.shape


# Split train and test ---------------------------------------------------------


# Set y columns.
y_col = "WATERTEMP"

# Train.
x_train = train.loc[:, train.columns != y_col]
y_train = train[y_col]

# Test.
x_test = test.loc[:, test.columns != y_col]
y_test = test[y_col]

# Set folds for train (not used for now).
k = 5
folds = random.choices([1, 2, 3, 4, 5], k = len(y_train))
pd.value_counts(folds)/len(y_train)


# Set-up for cross validation --------------------------------------------------


# Hyperparameters.
hyper = {
    'activation':(
        'relu', 
        'tanh',
        'logistic'
    ), 
    'hidden_layer_sizes': (
        (5), 
        (7, 5),
        (9, 7, 5),
        (9, 9, 7, 7),
        (15, 9, 9, 7)
    ),
    'learning_rate_init':(
        0.0005,
        0.001,
        0.01
    )
}

# Set estimator.
mlp = MLPRegressor(
    random_state        = 2912, 
    solver              = "adam",
    max_iter            = 10000,
    tol                 = 0.00001,
    verbose             = False,
    early_stopping      = False
)

# Set grid search for 5-fold cross-validation.
cv = GridSearchCV(
    estimator  = mlp,                               # The estimator
    param_grid = hyper,                             # The dictionnary of hyper parameters.
    scoring    = "neg_root_mean_squared_error",     # The error to minimize
    n_jobs     = -1,                                # Run in parallel on all processors
    refit      = True,                              # Refit with the best model
    cv         = 5,                                 # Number of folds in CV.
    verbose    = 3                                  # Show results while fitting.
)


# Cross validaiton -------------------------------------------------------------


# Process cross-validation.
cv.fit(x_train, y_train)

# Extract results of the fitting.
cv_results = pd.DataFrame(cv.cv_results_)
View(cv_results)

# Export results.
cv_results.to_csv(
    path_or_buf = "tmp/mlp_sklearn_results.csv", 
    sep         = ";", 
    decimal     = ".",
    index       = False
)


# Performance of the best model ------------------------------------------------


# Extract best model.
model = cv.best_estimator_

# Compute RMS on train and test.
rmse_train = sklearn.metrics.root_mean_squared_error(regr.predict(x_train), y_train)
rmse_test = sklearn.metrics.root_mean_squared_error(model.predict(x_test), y_test)

# Print results.
print("RMSE (train) = ", rmse_train)
print("RMSE (test) = ", rmse_test)


# Interpretation ---------------------------------------------------------------


# To be completed...

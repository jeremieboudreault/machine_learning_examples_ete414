# 01_mlp_sklearn.py


# 1 : Fit MLP to river tempeature data using Scikit-learn.


# Project : water_temperature_neural_networks
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
y_col = "WATERTEMP_MEAN"

# Train.
x_train = train.loc[:, train.columns != y_col]
y_train = train[y_col]

# Test.
x_test = test.loc[:, test.columns != y_col]
y_test = test[y_col]

# Set folds for train.
k = 5
folds = random.choices([1, 2, 3, 4, 5], k = len(y_train))
pd.value_counts(folds)/len(y_train)


# Fit MLP using scikit-learn ---------------------------------------------------


# Hyperparameters.
hyper = {
    'activation':(
        'relu', 
        'tanh'
    ), 
    'hidden_layer_sizes': (
        (5), 
        (5, 7)
    ),
    'learning_rate_init':(
        0.001,
        0.01
    )
}

# Set estimator.
mlp = MLPRegressor(
    random_state        = 2912, 
    #hidden_layer_sizes  = (9, 9, 7, 5),
    #activation          = "tanh",
    solver              = "adam",
    #learning_rate_init  = 0.001,
    max_iter            = 10000,
    tol                 = 0.00001,
    verbose             = False,
    #early_stopping      = True,   # Because we perform cross validaiton, we will not do early stopping
    #validation_fraction = 0.3
)

# Set grid search for 5-fold cross-validation.
cv = GridSearchCV(
    estimator  = mlp,         # The estimator
    param_grid = hyper,       # The dictionnary of hyper parameters.
    scoring    = "neg_root_mean_squared_error",
    n_jobs     = -1,         # Run in parallel on all processors
    refit      = True,        # Refit the model with the best model
    cv         = 5,          # Number of folds in CV.
    verbose    = 3          # Show results while fitting.
)

# Process cross validation.
cv.fit(x_train, y_train)

# Results of the fitting.
View(pd.DataFrame(cv.cv_results_))

# Extract best model.
model = cv.best_estimator_

#regr.score(x_train, y_train)
#regr.score(x_test, y_test)

#math.sqrt(sklearn.metrics.mean_squared_error(regr.predict(x_train), y_train))
math.sqrt(sklearn.metrics.mean_squared_error(model.predict(x_test), y_test))

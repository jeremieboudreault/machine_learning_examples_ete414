# LIME example

# imports
import numpy as np
from sklearn.datasets import load_iris
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split
from lime.lime_tabular import LimeTabularExplainer

# Set seed for lime.
np.random.seed(1)

# Function to train model.
def train_model(X_train: np.ndarray,
                X_test: np.ndarray,
                y_train: np.ndarray,
                y_test: np.ndarray) -> RandomForestClassifier:
    model = RandomForestClassifier()
    model.fit(X_train, y_train)
    
    predictions = model.predict(X_test)
    
    print(f'Accuracy: {np.round((accuracy_score(y_test, predictions) * 100), 3)}%')
    return model

# Data and models.
iris = load_iris()
X_train, X_test, y_train, y_test = train_test_split(iris.data, iris.target, train_size=0.8)
rf = train_model(X_train, X_test, y_train, y_test)

# Lime.
explainer = LimeTabularExplainer(X_train, 
                                 feature_names=iris.feature_names, 
                                 class_names=iris.target_names, 
                                 discretize_continuous=True)
# Get LIME.
i = np.random.randint(0, X_test.shape[0])
exp = explainer.explain_instance(X_test[i], rf.predict_proba, num_features=2, top_labels=1)
exp.show()                                 

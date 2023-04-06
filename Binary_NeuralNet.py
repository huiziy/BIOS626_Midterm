# -*- coding: utf-8 -*-
"""ExploratoryAnalysis.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/1lvB3pxzNnxy5nKJYcqIdK4qThmaIxvpa
"""

import pandas as pd
import numpy as np
import keras
import tensorflow as tf
from sklearn.model_selection import train_test_split
from random import sample
import collections

from google.colab import drive
drive.mount('/content/drive')

dataset = pd.read_csv('/content/drive/MyDrive/BIOS620/Midterm 1/data/training_data.csv')
X = dataset.iloc[:, 0:].values
y = dataset.iloc[:, 1].values

result = np.where(y>=4,0,1)
y = result

## Random Splitting
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, random_state = 0)

## Split based on Individual

unique_indx = list(dataset.iloc[:,0].unique())

train_indx = sample(list(dataset.iloc[:,0].unique()), k = int(dataset.iloc[:,0].unique().shape[0] * 0.8))
test_indx = [a for a in unique_indx if a not in train_indx]

np.in1d(X[:,0], train_indx)

X_train = X[np.in1d(X[:,0], train_indx),:]
X_test = X[np.in1d(X[:,0], test_indx),:]
y_train = y[np.in1d(X[:,0], train_indx)]
y_test = y[np.in1d(X[:,0], test_indx)]

X_train = X_train[:,2:]
X_test = X_test[:,2:]

"""Feature Scaling"""

from sklearn.preprocessing import StandardScaler
sc = StandardScaler()
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)

ann = tf.keras.models.Sequential()

ann.add(tf.keras.layers.Dense(units=6, activation='relu'))
ann.add(tf.keras.layers.Dense(units=6, activation='relu'))
ann.add(tf.keras.layers.Dense(units=1, activation='sigmoid'))

ann.compile(optimizer = 'adam', loss = 'binary_crossentropy', metrics = ['accuracy'])

ann.fit(X_train, y_train, batch_size = 32, epochs = 100)

y_pred = ann.predict(X_test)
y_pred = (y_pred > 0.5)
print(np.concatenate((y_pred.reshape(len(y_pred),1), y_test.reshape(len(y_test),1)),1))

from sklearn.metrics import confusion_matrix, accuracy_score
cm = confusion_matrix(y_test, y_pred)
print(cm)
accuracy_score(y_test, y_pred)

### Training on the Entire Training Dataset

test = pd.read_csv('/content/drive/MyDrive/BIOS620/Midterm 1/data/test_data.csv')

test.shape

X = test.iloc[:, 0:].values
X = X[:,1:]

sc = StandardScaler()
X_holdout = sc.fit_transform(X)

y_preds = ann.predict(X_holdout) # see how the model did!

y_preds = (y_preds > 0.5)
y_pred = 1 * y_preds

with open("/content/drive/MyDrive/BIOS620/Midterm 1/data/results/binary_mm0507.txt", "wb") as f:
    np.savetxt(f, y_pred.astype(int), fmt='%i', delimiter="\t")


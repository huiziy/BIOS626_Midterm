library("xgboost")  # the main algorithm
library("archdata") # for the sample dataset
library("caret")    # for the confusionmatrix() function (also needs e1071 package)
library("dplyr")    # for some data preperation
library("Ckmeans.1d.dp") # for xgb.ggplot.importance

######################################
# Prediction using XGBoost (test on testing data)

### Read-in data and split to produce training and testing
setwd("/Users/huiziyu/Dropbox/Winter_2023/BIOS626/Midterm 1/data")
data <- read.delim("training_data.txt")
data$activity <- ifelse(data$activity >= 7, 7, data$activity) - 1
train_index <- which(data$subject <= 23)

# Full data set
data_variables <- as.matrix(data[,c(-1,-2)])
data_label <- data[,"activity"]
data_matrix <- xgb.DMatrix(data = as.matrix(data), label = data_label)
# split train data and make xgb.DMatrix
train_data   <- data_variables[train_index,]
train_label  <- data_label[train_index]
train_matrix <- xgb.DMatrix(data = train_data, label = train_label)
# split test data and make xgb.DMatrix
test_data  <- data_variables[-train_index,]
test_label <- data_label[-train_index]
test_matrix <- xgb.DMatrix(data = test_data, label = test_label)
watchlist <- list(train=train_matrix, test=test_matrix)
numberOfClasses <- length(unique(data$activity))

########### Hyperparameter Tuning ###########
best_param = list()
best_seednumber = 1234
best_logloss = Inf
best_logloss_index = 0
param_full <- c()
for (iter in 1:50) {
  print(iter)
  param <- list(objective = "multi:softprob",
                eval_metric = "mlogloss",
                num_class = numberOfClasses,
                max_depth = sample(6:10, 1),
                eta = runif(1, .01, .3),
                gamma = runif(1, 0.0, 0.2), 
                subsample = runif(1, .6, .9),
                colsample_bytree = runif(1, .5, .8), 
                min_child_weight = sample(1:40, 1),
                max_delta_step = sample(1:10, 1)
  )
  cv.nround = 100
  cv.nfold = 3
  seed.number = sample.int(10000, 1)[[1]]
  set.seed(seed.number)
  mdcv <- xgb.cv(data = train_matrix, params = param, nthread=6, 
                 nfold=cv.nfold, nrounds=cv.nround,
                 early_stopping_rounds=20, maximize=FALSE,
                 verbose = FALSE,
                 prediction = TRUE)
  
  min_logloss = min(mdcv$evaluation_log[, test_mlogloss_mean])
  min_logloss_index = which.min(mdcv$evaluation_log[, test_mlogloss_mean])
  ## Record out of bag results
  param_result <- unlist(param)
  OOF_prediction <- data.frame(mdcv$pred) %>%
    mutate(max_prob = max.col(., ties.method = "last"),
           label = train_label + 1)
  OOB_Results <- confusionMatrix(factor(OOF_prediction$max_prob),
                  factor(OOF_prediction$label),
                  mode = "everything")
  param_result <- c(param_result,OOB_Results$overall[1])
  ## Record testing results 
  # Predict hold-out test set
  bst_model <- xgb.train(params = param,
                         data = train_matrix,
                         nrounds = nround)
  test_pred <- predict(bst_model, newdata = test_matrix)
  test_prediction <- matrix(test_pred, nrow = numberOfClasses,
                            ncol=length(test_pred)/numberOfClasses) %>%
    t() %>%
    data.frame() %>%
    mutate(label = test_label + 1,
           max_prob = max.col(., "last"))
  # confusion matrix of test set
  Testing_Results <- confusionMatrix(factor(test_prediction$max_prob),
                  factor(test_prediction$label),
                  mode = "everything")
  param_result <- c(param_result,Testing_Results$overall[1])
  
  if (min_logloss < best_logloss) {
    best_logloss = min_logloss
    best_logloss_index = min_logloss_index
    best_seednumber = seed.number
    best_param = param
  }
  param_full <- rbind(param_full, param_result)
}

results_df <- param_full[,2:dim(param_full)[2]]
write.csv(results_df,file = "/Users/huiziyu/Dropbox/Winter_2023/BIOS626/Midterm 1/data/results_grid.csv", row.names = FALSE)
results <- read.csv("/Users/huiziyu/Dropbox/Winter_2023/BIOS626/Midterm 1/data/results_grid.csv")
best_param_test <- results[which.max(results$Accuracy.1),]
best_param_test <- as.list(best_param_test[2:9])
best_param_test[["objetive"]] <- "multi:softprob"
best_param_test[["eval_metric"]] <- "mlogloss"
nround = best_logloss_index
set.seed(best_seednumber)

## Plot
results$eval_metric <- NULL
results$num_class <- NULL
colnames(results)[dim(results)[2]-1] = "Accuracy_OOB"
colnames(results)[dim(results)[2]] = "Accuracy_Test"
col_names <- col_names(results)
results <- round(results,2)
write.csv(results,file = "/Users/huiziyu/Dropbox/Winter_2023/BIOS626/Midterm 1/data/results_grid_round.csv", row.names = FALSE)


# Train on the full dataset
data <- read.delim("training_data.txt")
data$activity <- ifelse(data$activity >= 7, 7, data$activity) - 1
data_variables <- as.matrix(data[,c(-1,-2)])
data_label <- data[,"activity"]
data_matrix <- xgb.DMatrix(data = as.matrix(data_variables), label = data_label)

md_full <- xgb.train(data=data_matrix, params=best_param_test, nrounds=nround, nthread=6)

######################################
# Prediction for Results Submission
test_pred <- predict(md_full, newdata = test_matrix)
test_pred <- test_pred + 1
data <- read.delim("training_data.txt")
data$activity <- ifelse(data$activity >= 7, 7, data$activity)
test_actual <-data$activity[-train_index]
confusionMatrix(factor(test_pred),
                factor(test_actual),
                mode = "everything")

test <- read.delim("test_data.txt")
test_variables <- as.matrix(test[,-1])
test_matrix <- xgb.DMatrix(data = as.matrix(test_variables))
test_pred <- predict(md_full, newdata = test_matrix)
test_pred <- test_pred + 1
write.table(test_pred, "/Users/huiziyu/Dropbox/Winter_2023/BIOS626/Midterm 1/results/multiclass_mm0507.txt", row.names = FALSE, col.names = FALSE)



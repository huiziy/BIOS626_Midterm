######################################
# Prediction using SVM (test on testing data)
setwd("/Users/huiziyu/Dropbox/Winter_2023/BIOS626/Midterm 1/data")
data <- read.delim("training_data.txt")
train_set <- data[data$subject <= 23,]
test_set <- data[data$subject > 23,]
full_df <- train_set[,2:dim(train_set)[2]]
full_df$activity <- ifelse(full_df$activity < 7, full_df$activity, 7)
full_df$activity <- paste0("class",full_df$activity)
full_df$activity <- as.factor(full_df$activity)

ctrl <- trainControl(method = "cv", savePred=T, classProb=T,
                     summaryFunction=twoClassSummary)
mod1 <- train(activity~., data=full_df, method = "svmLinear",
              preProcess = c("center","scale"))
mod1

test_set <- test_set[,2:dim(test_set)[2]]
test_set$activity <- ifelse(test_set$activity < 7, test_set$activity, 7)
test_set$activity <- paste0("class",test_set$activity)
test_set$activity <- as.factor(test_set$activity)
pred1 <- predict(mod1, newdata = test_set)
sum(pred1 == test_set$activity) / length(pred1)


######################################
# Prediction for Results Submission
data <- read.delim("training_data.txt")
full_df <- data[,2:dim(data)[2]]
full_df$activity <- ifelse(full_df$activity < 7, full_df$activity, 7)
full_df$activity <- paste0("class",full_df$activity)
full_df$activity <- as.factor(full_df$activity)

ctrl <- trainControl(method = "cv", savePred=T, classProb=T,
                     summaryFunction=twoClassSummary)
mod1 <- train(activity~., data=full_df, method = "svmLinear",
              preProcess = c("center","scale"))
mod1
# Prediction on holdoff set
test <- read.delim("test_data.txt")
test_set <- as.matrix(test[,-1])
test_pred <- predict(mod1, newdata = test_set)
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
test_pred <- str_replace(test_pred, "class", "")
test_pred <- as.numeric(test_pred)
write.table(test_pred, "/Users/huiziyu/Dropbox/Winter_2023/BIOS626/Midterm 1/results/multiclass_mm0507.txt", row.names = FALSE, col.names = FALSE)

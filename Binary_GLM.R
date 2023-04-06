######################################
## Binary Classification using GLM
library(caret)
setwd("/Users/huiziyu/Dropbox/Winter_2023/BIOS626/Midterm 1/data")
data <- read.delim("training_data.txt")
train_set <- data[data$subject <= 23,]
test_set <- data[data$subject > 23,]
full_df <- train_set[,2:dim(train_set)[2]]
full_df$activity <- ifelse(full_df$activity >= 4, 0, 1)
full_df$activity <- as.factor(full_df$activity)
test_df <- test_set[,2:dim(test_set)[2]]
test_df$activity <- ifelse(test_df$activity >= 4, 0, 1)
test_df$activity <- as.factor(test_df$activity)

### Building the GLM model
mod1 <- glm(activity ~ . , data = full_df, family = "binomial")
summary(mod1)

pred <- predict(mod1, newdata = test_df, type = "response")
pred_outcome <- ifelse(pred < 0.5, 0, 1)
pred_outcome <- as.factor(pred_outcome)
confusionMatrix(pred_outcome,test_df$activity)
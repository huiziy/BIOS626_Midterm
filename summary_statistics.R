######################################
### Generate Summary Statistics
setwd("/Users/huiziyu/Dropbox/Winter_2023/BIOS626/Midterm 1/data")
data <- read.delim("training_data.txt")
dim(hold)
length(unique(hold$subject))
data %>% group_by(activity) %>% group_by(activity) %>% 
  summarise(value = n(),
            .groups = 'drop') %>% mutate(percent = value/sum(value) * 100)

hold <- read.delim("test_data.txt")
dim(hold)
length(unique(hold$subject))



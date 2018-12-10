library(reshape2)

#Downloading the zip file
if (!file.exists(filename)){
  
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  
  download.file(fileURL, filename, method="curl")
  
}  

#Unzip the zip file
if (!file.exists("UCI HAR Dataset")) { 
  
  unzip(filename) 
  
}

#Activity labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

#Filter features by matching "mean" and "std" word
features_mean_std <- grep(".*mean.*|.*std.*", features[,2])

features_mean_std.names <- features[features_mean_std,2]

features_mean_std.names = gsub('-mean', 'Mean', features_mean_std.names)

features_mean_std.names = gsub('-std', 'Std', features_mean_std.names)

features_mean_std.names <- gsub('[-()]', '', features_mean_std.names)

#train data

train <- read.table("UCI HAR Dataset/train/X_train.txt")[features_mean_std]

trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")

trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")

train <- cbind(trainSubjects, trainActivities, train)


#test data
test <- read.table("UCI HAR Dataset/test/X_test.txt")[features_mean_std]

testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")

testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")

test <- cbind(testSubjects, testActivities, test)

#merging train and test data
mergedData <- rbind(train, test)
colnames(mergedData) <- c("subject", "activity", features_mean_std.names)

# turn activities & subjects into factors
mergedData$activity <- factor(mergedData$activity, levels = activityLabels[,1], labels = activityLabels[,2])

mergedData$subject <- as.factor(mergedData$subject)

mergedData.melted <- melt(mergedData, id = c("subject", "activity"))

mergedData.mean <- dcast(mergedData.melted, subject + activity ~ variable, mean)



write.table(mergedData.mean, "week4data.txt", row.names = FALSE, quote = FALSE)

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
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])

featuresWanted.names <- features[featuresWanted,2]

featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)

featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)

featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)

#train data

train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]

trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")

trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")

train <- cbind(trainSubjects, trainActivities, train)


#test data
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]

testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")

testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")

test <- cbind(testSubjects, testActivities, test)

#merging train and test data
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresWanted.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])

allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))

allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)



write.table(allData.mean, "week4data.txt", row.names = FALSE, quote = FALSE)

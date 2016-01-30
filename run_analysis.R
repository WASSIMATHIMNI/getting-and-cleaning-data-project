## Following script does the following:
## - Merging the training and test data sets
## - Extracts measurements (mean,sd) from the observations
## - Use descriptive names and appropriate labels for activity names
## - Creates a second tidy data set.

library(reshape2)

filename <- "getdata_dataset.zip"

## Download file and unzip
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}
if (!file.exists("UCI HAR Dataset")) {
  unzip(filename)
}

# Load labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extracting the mean and std
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]


# Formating names
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)


# Load the traininga dn test datasets and bind them together
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

trainTestMerged <- rbind(train, test)
colnames(trainTestMerged) <- c("subject", "activity", featuresWanted.names)

# turn activities & subjects into factors
trainTestMerged$activity <- factor(trainTestMerged$activity, levels = activityLabels[,1], labels = activityLabels[,2])
trainTestMerged$subject <- as.factor(trainTestMerged$subject)

trainTestMerged.melted <- melt(trainTestMerged, id = c("subject", "activity"))
trainTestMerged.mean <- dcast(trainTestMerged.melted, subject + activity ~ variable, mean)

write.table(trainTestMerged.mean, "tidy.txt", row.names = FALSE, quote = FALSE)

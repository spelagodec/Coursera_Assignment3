# Review criteria  
## The submitted data set is tidy.
## The Github repo contains the required scripts.
## GitHub contains a code book that modifies and updates the available codebooks with the data to indicate all the variables and summaries calculated, along with units, and any other relevant information.
## The README that explains the analysis files is clear and understandable.
## The work submitted for this project is the work of the student who submitted it.

#####################################

# You should create one R script called run_analysis.R that does the following.
## Merges the training and the test sets to create one data set.
## Extracts only the measurements on the mean and standard deviation for each measurement.
## Uses descriptive activity names to name the activities in the data set
## Appropriately labels the data set with descriptive variable names.
## From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.



## STEP 1: Data download 

fileName <- "UCI HAR data.zip"
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dir <- "UCI HAR Dataset"

# File download verification. If file does not exist, download to working directory.
if(!file.exists(fileName)){
  download.file(url,fileName, mode = "wb") 
}

## STEP 2: Data unzip 

if(!file.exists(dir)){
  unzip("UCI HAR data.zip", files = NULL, exdir=".")
}


## STEP 3: Read Data
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
X_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
X_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
features <- read.table("UCI HAR Dataset/features.txt")  

## STEP 4: Analysis

# 4.1. Merges the training and the test sets to create one data set. 
dataSetx <- rbind(X_train,X_test)

# 4.2 Extracts only the measurements on the mean and standard deviation for each measurement. 
# Create a vector of only mean and std, use the vector to subset.
MeanStdOnly <- grep("mean()|std()", features[, 2]) 
dataSetx <- dataSetx[,MeanStdOnly]


# 4.3 Appropriately labels the data set with descriptive activity names.

# Create vector of "clean" feature names, removing "()" and applying to the dataSetx to rename labels.
CleanNames <- sapply(features[, 2], function(x) {gsub("[()]", "",x)})
names(dataSetx) <- CleanNames[MeanStdOnly]

# combine test and train of subject data and activity data, give descriptive lables
subject <- rbind(subject_train, subject_test)
names(subject) <- 'subject'
activity <- rbind(y_train,y_test)
names(activity) <- 'activity'

# combine subject, activity, and mean and std only data set to create final data set.
dataSet <- cbind(subject,activity, dataSetx)


# Uses descriptive activity names to name the activities in the data set
# group the activity column of dataSet, re-name labels of levels with activity_levels, and apply it to dataSet.
act_group <- factor(dataSet$activity)
levels(act_group) <- activity_labels[,2]
dataSet$activity <- act_group


#  STEP 5: Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

install.packages("reshape")
library(reshape2)

install.packages("data.table")
library(data.table)

baseData <- melt(dataSet,(id.vars=c("subject","activity")))
secondDataSet <- dcast(baseData, subject + activity ~ variable, mean)
names(secondDataSet)[-c(1:2)] <- paste("[mean of]" , names(secondDataSet)[-c(1:2)] )
write.table(secondDataSet, "tidy_data.txt", sep = ",")


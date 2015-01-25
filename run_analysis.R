#Project for Getting and Cleaning Data

#data used is located at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

#This R script called run_analysis.R and does the following. 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set obtained in above 4, creates a second, independent tidy data set with the average of each variable for each 
#    activity and each subject.

# Assumption : data has been loaded in the working directory

#Libraries loaded for this script
library(dplyr)
library(reshape2)
library(data.table)

#Load x data labels - copy text descripion from features.txt

est_data = read.table( "./UCI HAR Dataset/features.txt")

#convert to vector
est_data = as.vector(t(est_data[2]))

# read the activity label data
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt", col.name=c("id", "activity"))



for (type in c("train", "test")){
  
  # read the y data and match the act_id to the activity label
  # add the description column by matching the act_id to the activity label
  y <- read.table(paste0("./UCI HAR Dataset/",type,"/y_",type,".txt"), col.name="act_id")
  y = mutate(y, activity = activity_labels[y$act_id,"activity"])
  
  # read the subject data 
  subject <- read.table(paste0("./UCI HAR Dataset/",type,"/subject_",type,".txt"), col.name="subject")
  
  # read the x data 
  x <- read.table(paste0("./UCI HAR Dataset/",type,"/X_",type,".txt"), col.names=est_data)
  
  #we only want the mean and std
  if (type == "test"){
    data_test <- cbind(y[2], subject[1],
                       x[,c(grep(".mean",names(x)),grep(".std",names(x)))])
  } else if (type == "train"){
    data_train <- cbind(y[2], subject[1],
                        x[,c(grep(".mean",names(x)),grep(".std",names(x)))])
  }
}

rm("x","y","subject","activity_labels")

# Merges the training and the test sets to create one data set.
Mergeddata <- rbind(data_train,data_test)

#Data Label set to descriptive test
Mergeddata <- rename( Mergeddata, Subject=subject, Activity = activity )


rm("data_train", "data_test")

#Item 5
DT <- data.table(group_by(Mergeddata, Subject, Activity))
tinyData <- DT[, lapply(.SD, mean), by = c("Activity","Subject")]

write.table(tinyData, row.names=FALSE,file = "tiny.txt")

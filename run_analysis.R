
library(reshape2)

# obtain dataset

rawDataPath <- "./rawData"
rawDataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
rawDataFile <- "rawData.zip"
rawDataFilename <- paste(rawDataPath, "/", "rawData.zip", sep = "")
dataDirectory <- "./data"

if (!file.exists(rawDataPath)) {
    dir.create(rawDataPath)
    download.file(url = rawDataUrl, destfile = rawDataFilename)
}
if (!file.exists(dataDirectory)) {
    dir.create(dataDirectory)
    unzip(zipfile = rawDataFilename, exdir = dataDirectory)
}


# train 

x_train <- read.table(paste(sep = "", dataDirectory, "/UCI HAR Dataset/train/X_train.txt"))
y_train <- read.table(paste(sep = "", dataDirectory, "/UCI HAR Dataset/train/Y_train.txt"))
s_train <- read.table(paste(sep = "", dataDirectory, "/UCI HAR Dataset/train/subject_train.txt"))

# test 

x_test <- read.table(paste(sep = "", dataDirectory, "/UCI HAR Dataset/test/X_test.txt"))
y_test <- read.table(paste(sep = "", dataDirectory, "/UCI HAR Dataset/test/Y_test.txt"))
s_test <- read.table(paste(sep = "", dataDirectory, "/UCI HAR Dataset/test/subject_test.txt"))

# merge training and testing data

x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
s_data <- rbind(s_train, s_test)

# activity labels

a_label <- read.table(paste(sep = "", dataDirectory, "/UCI HAR Dataset/activity_labels.txt"))
a_label[,2] <- as.character(a_label[,2])

# feature info

feature <- read.table(paste(sep = "", dataDirectory, "/UCI HAR Dataset/features.txt"))


# extract columns and mean / std

selectCols <- grep("-(mean|std).*", as.character(feature[,2]))
selectColName <- feature[selectCols, 2]
selectColName <- gsub("-mean", "Mean", selectColName)
selectColName <- gsub("-std", "Std", selectColName)
selectColName <- gsub("[-()]", "", selectColName)


# extract data 

x_data <- x_data[selectCols]
fullData <- cbind(s_data, y_data, x_data)
colnames(fullData) <- c("subject", "activity", selectColName)

fullData$Activity <- factor(fullData$Activity, levels = a_label[,1], labels = a_label[,2])
fullData$Subject <- as.factor(fullData$Subject)


# get final dataset
meltData <- melt(fullData, id = c("subject", "activity"))
finalData <- dcast(meltData, Subject + Activity ~ variable, mean)

write.table(finalData, "./tidy_dataset.txt", row.names = FALSE, quote = FALSE)
# Script to make Plot 2 of the Assignment
rm(list=ls())
gc()
setwd("/Users/Devender/research-project-2")
library(data.table)
library(dplyr)
library(lubridate)
library(R.utils)

if(!file.exists("data")) { 
    dir.create("data")
}

if(!file.exists("data/StormData.csv")){
    
    if(!file.exists("data/StormData.csv.bz2")){ 
        flog.info("downloading dataset")
        url<-"https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
        download.file(url,"data/StormData.csv.bz2",method="curl") 
    }
    
    bunzip2("data/StormData.csv.bz2", destname="data/StormData.csv")
}

storm_data <- fread("data/StormData.csv",sep=",",header=TRUE,select=c("EVTYPE",
                                                                    "FATALITIES",
                                                                    "INJURIES",
                                                                    "PROPDMG",
                                                                    "PROPDMGEXP",
                                                                    "CROPDMG",
                                                                    "CROPDMGEXP"))
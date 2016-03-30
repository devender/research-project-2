# Script to make Plot 2 of the Assignment
rm(list=ls())
gc()
setwd("/Users/Devender/research-project-2")
library(data.table)
library(dplyr)
library(lubridate)
library(R.utils)
library(lattice)

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
"FATALITIES","INJURIES","PROPDMG","PROPDMGEXP","CROPDMG","CROPDMGEXP"))

storm_data <- transform(storm_data,EVTYPE = factor(EVTYPE))

str(storm_data)

expand_expo<-function(char){
    if(char == "M" | char == "m"){
        return(1e+06)
    }else if(char == "K" | char == "k"){
        return(1e+03)
    }else if(char=="B" | char == "b"){
        return(1e+09)
    }else if(char=="H" | char == "h"){
        return(1e+02)
    }else if(char=="" | char=="+" | char=="?" | char == "-"){
        return(1)
    }else{
        return(as.numeric(char))
    }
}
v_expand_expo<-Vectorize(expand_expo, SIMPLIFY = TRUE)

storm_data<-storm_data %>%
    mutate(cropDamage = CROPDMG * v_expand_expo(CROPDMGEXP)) %>%
    mutate(propDamage = PROPDMG * v_expand_expo(PROPDMGEXP))

pop_health<- storm_data %>%
    group_by(EVTYPE) %>%
    summarize(Injuries = log(sum(INJURIES)), 
              Fatalities = log(sum(FATALITIES)), 
              total = log(sum(INJURIES)) + log(sum(FATALITIES))) %>%
    arrange(desc(total)) %>%
    top_n(10)
    
economy<-storm_data %>%
    group_by(EVTYPE) %>%
    summarise(PropertyDamage = sum(propDamage),
              CropDamage = sum(cropDamage),
              total = sum(propDamage)+sum(cropDamage)) %>%
    arrange(desc(total)) %>%
    top_n(10)

#barchart(EVTYPE ~ Injuries + Fatalities, data = pop_health, stack = TRUE, xlab = c("LOG of total injuries and fatalities"))
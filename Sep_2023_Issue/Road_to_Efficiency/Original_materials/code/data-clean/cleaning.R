#################################################################
####                                                         ####
#        R code for manuscript Avoyan and Ramos:                #
# "A road to efficiency through communication and commitment"   #
####                                                         ####
#################################################################
## Summary of the document
# Part 0: Preliminaries (used libraries, data, parameters)
# Part 1: Take files from z-Tree output and reshape them into a workable data format. 
# Part 2: Take survey files from z-Tree survey output and reshape them into workable format.
############
## PART 0 ## 
############
# Clear the system
rm(list = ls())
# Install Required Libraries
pkgTest <- function(x,y="")
{
  if (!require(x,character.only = TRUE))
  {
    if ( y == "" ) 
    {
      install.packages(x,dep=TRUE)
    } else {
      remotes::install_version(x, y)
    }
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
  return("OK")
}
#
global.libraries <- c("ggplot2","reshape2","plyr","tidyr","plm","grid")
results <- sapply(as.list(global.libraries), pkgTest)
# IMPORTANT: replace "/Users/alaavoyan/Desktop/ReplicationPackage/" with the directory in which the ReadMe-file is located
basepath <- "/Users/alaavoyan/Desktop/ReplicationPackage/"
setwd(basepath) # set the directory 
# 
# Set output digits
#
options("scipen"=10, "digits"=3)
#
#######################################################
# Load the raw CSV files for all sessions (Main Data) # 
#######################################################
# Baseline Treatments: sessions 1,2 and 3 
data11 <- read.csv("data/raw/151214_1046.csv", stringsAsFactors=FALSE) 
data12 <- read.csv("data/raw/160222_1450.csv", stringsAsFactors=FALSE) 
data13 <- read.csv("data/raw/180402_1606.csv", stringsAsFactors=FALSE) 
# Revision Mechanism Treatments: sessions 1,2, 3 and 4 
data21 <- read.csv("data/raw/151209_1044.csv", stringsAsFactors=FALSE) 
data22 <- read.csv("data/raw/151210_1332.csv", stringsAsFactors=FALSE) 
data23 <- read.csv("data/raw/160217_1543.csv", stringsAsFactors=FALSE) 
data24 <- read.csv("data/raw/180402_1410.csv", stringsAsFactors=FALSE) 
# Revision Cheap Talk Treatments: sessions 1,2, 3 and 4 
data31 <- read.csv("data/raw/160224_1313.csv", stringsAsFactors=FALSE) 
data32 <- read.csv("data/raw/160224_1426.csv", stringsAsFactors=FALSE) 
data33 <- read.csv("data/raw/160224_1617.csv", stringsAsFactors=FALSE) 
data34 <- read.csv("data/raw/180402_1242.csv", stringsAsFactors=FALSE) 
# Random Revision Mechanism Treatments: sessions 1,2, 3 and 4 
data41 <- read.csv("data/raw/180410_1715.csv", stringsAsFactors=FALSE) 
data42 <- read.csv("data/raw/180411_1812.csv", stringsAsFactors=FALSE) 
data43 <- read.csv("data/raw/180413_1257.csv", stringsAsFactors=FALSE) 
data44 <- read.csv("data/raw/180413_1711.csv", stringsAsFactors=FALSE) 
# Standard Cheap Talk Treatment: sessions 1,2, 3, 4 
data51 <- read.csv("data/raw/180425_1116.csv", stringsAsFactors=FALSE) 
data52 <- read.csv("data/raw/180425_1309.csv", stringsAsFactors=FALSE) 
data53 <- read.csv("data/raw/180425_1709.csv", stringsAsFactors=FALSE) 
data54 <- read.csv("data/raw/180426_1510.csv", stringsAsFactors=FALSE)
# Infrequent Revision Meachanism: session 1, 2, 3, 4
data61 <- read.csv("data/raw/180430_1715.csv", stringsAsFactors=FALSE)
data62 <- read.csv("data/raw/180502_1258.csv", stringsAsFactors=FALSE) 
data63 <- read.csv("data/raw/180502_1708.csv", stringsAsFactors=FALSE)
data64 <- read.csv("data/raw/180507_1654.csv", stringsAsFactors=FALSE)
# Revision Cheap Talk Memory: session 1,2,3,4
data71 <- read.csv("data/raw/180605_1112.csv", stringsAsFactors=FALSE) 
data72 <- read.csv("data/raw/180718_1714.csv", stringsAsFactors=FALSE)
data73 <- read.csv("data/raw/180719_1411.csv", stringsAsFactors=FALSE)
data74 <- read.csv("data/raw/180720_1409.csv", stringsAsFactors=FALSE)
# Synch-RM: session 1,2,3,4,5,6,7,8
data81 <- read.csv("data/raw/201021_1149.csv", stringsAsFactors=FALSE) 
data82 <- read.csv("data/raw/201021_1344.csv", stringsAsFactors=FALSE)
data83 <- read.csv("data/raw/201022_1147.csv", stringsAsFactors=FALSE)
data84 <- read.csv("data/raw/201104_1053.csv", stringsAsFactors=FALSE)
data85 <- read.csv("data/raw/201104_1346.csv", stringsAsFactors=FALSE)
data86 <- read.csv("data/raw/201116_1339.csv", stringsAsFactors=FALSE)
data87 <- read.csv("data/raw/201117_1439.csv", stringsAsFactors=FALSE)
data88 <- read.csv("data/raw/210325_1641.csv", stringsAsFactors=FALSE)
# RM at Indiana University: session 1,2,3,4,5,6,7,8
data91 <- read.csv("data/raw/201022_1548.csv", stringsAsFactors=FALSE) 
data92 <- read.csv("data/raw/201027_1347.csv", stringsAsFactors=FALSE)
data93 <- read.csv("data/raw/201027_1445.csv", stringsAsFactors=FALSE)
data94 <- read.csv("data/raw/201027_1542.csv", stringsAsFactors=FALSE)
data95 <- read.csv("data/raw/201105_1434.csv", stringsAsFactors=FALSE)
data96 <- read.csv("data/raw/201118_1104.csv", stringsAsFactors=FALSE) 
data97 <- read.csv("data/raw/201118_1340.csv", stringsAsFactors=FALSE) 
data98 <- read.csv("data/raw/201119_1443.csv", stringsAsFactors=FALSE) 
# RM with VHBB: session 1,2,3,4,5,6,7,8
data101 <- read.csv("data/raw/210322_1440.csv", stringsAsFactors=FALSE) 
data102 <- read.csv("data/raw/210322_1544.csv", stringsAsFactors=FALSE) 
data103 <- read.csv("data/raw/210322_1637.csv", stringsAsFactors=FALSE) 
data104 <- read.csv("data/raw/210323_1240.csv", stringsAsFactors=FALSE) 
data105 <- read.csv("data/raw/210323_1339.csv", stringsAsFactors=FALSE) 
data106 <- read.csv("data/raw/210324_1613.csv", stringsAsFactors=FALSE) 
data107 <- read.csv("data/raw/210324_1706.csv", stringsAsFactors=FALSE) 
data108 <- read.csv("data/raw/210325_1547.csv", stringsAsFactors=FALSE) 
# Richer RCT: session 1,2,3,4,5,6,7,8
data111 <- read.csv("data/raw/210405_1640.csv", stringsAsFactors=FALSE) 
data112 <- read.csv("data/raw/210406_1635.csv", stringsAsFactors=FALSE) 
data113 <- read.csv("data/raw/210414_1534.csv", stringsAsFactors=FALSE) 
data114 <- read.csv("data/raw/210414_1638.csv", stringsAsFactors=FALSE) 
data115 <- read.csv("data/raw/210419_1534.csv", stringsAsFactors=FALSE) 
data116 <- read.csv("data/raw/210421_1656.csv", stringsAsFactors=FALSE)
data117 <- read.csv("data/raw/210427_1036.csv", stringsAsFactors=FALSE) 
data118 <- read.csv("data/raw/210427_1641.csv", stringsAsFactors=FALSE)
#########################################################
# Load the raw CSV files for all sessions (Survey Data) #
#########################################################
# Baseline Treatments: sessions 1,2 and 3 
SurveyData11 <- read.csv("data/raw/151214_1046_survey.csv", stringsAsFactors=FALSE) 
SurveyData12 <- read.csv("data/raw/160222_1450_survey.csv", stringsAsFactors=FALSE) 
SurveyData13 <- read.csv("data/raw/180402_1606_survey.csv", stringsAsFactors=FALSE) 
# Revision Mechanism Treatments: sessions 1,2, 3 and 4 
SurveyData21 <- read.csv("data/raw/151209_1044_survey.csv", stringsAsFactors=FALSE) 
SurveyData22 <- read.csv("data/raw/151210_1332_survey.csv", stringsAsFactors=FALSE) 
SurveyData23 <- read.csv("data/raw/160217_1543_survey.csv", stringsAsFactors=FALSE) 
SurveyData24 <- read.csv("data/raw/180402_1410_survey.csv", stringsAsFactors=FALSE) 
# Revision Cheap Talk Treatments: sessions 1,2, 3 and 4 
SurveyData31 <- read.csv("data/raw/160224_1313_survey.csv", stringsAsFactors=FALSE) 
SurveyData32 <- read.csv("data/raw/160224_1426_survey.csv", stringsAsFactors=FALSE) 
SurveyData33 <- read.csv("data/raw/160224_1617_survey.csv", stringsAsFactors=FALSE) 
SurveyData34 <- read.csv("data/raw/180402_1242_survey.csv", stringsAsFactors=FALSE) 
# Random Revision Mechanism Treatments: sessions 1,2, 3 and 4 
SurveyData41 <- read.csv("data/raw/180410_1715_survey.csv", stringsAsFactors=FALSE) 
SurveyData42 <- read.csv("data/raw/180411_1812_survey.csv", stringsAsFactors=FALSE) 
SurveyData43 <- read.csv("data/raw/180413_1257_survey.csv", stringsAsFactors=FALSE) 
SurveyData44 <- read.csv("data/raw/180413_1711_survey.csv", stringsAsFactors=FALSE) 
# Standard Cheap Talk Treatment: sessions 1,2, 3, 4 
SurveyData51 <- read.csv("data/raw/180425_1116_survey.csv", stringsAsFactors=FALSE) 
SurveyData52 <- read.csv("data/raw/180425_1309_survey.csv", stringsAsFactors=FALSE) 
SurveyData53 <- read.csv("data/raw/180425_1709_survey.csv", stringsAsFactors=FALSE) 
SurveyData54 <- read.csv("data/raw/180426_1510_survey.csv", stringsAsFactors=FALSE)
# Infrequent Revision Meachanism: session 1, 2, 3, 4
SurveyData61 <- read.csv("data/raw/180430_1715_survey.csv", stringsAsFactors=FALSE)
SurveyData62 <- read.csv("data/raw/180502_1258_survey.csv", stringsAsFactors=FALSE) 
SurveyData63 <- read.csv("data/raw/180502_1708_survey.csv", stringsAsFactors=FALSE)
SurveyData64 <- read.csv("data/raw/180507_1654_survey.csv", stringsAsFactors=FALSE)
# Revision Cheap Talk Memory: session 1,2,3,4
SurveyData71 <- read.csv("data/raw/180605_1112_survey.csv", stringsAsFactors=FALSE) 
SurveyData72 <- read.csv("data/raw/180718_1714_survey.csv", stringsAsFactors=FALSE)
SurveyData73 <- read.csv("data/raw/180719_1411_survey.csv", stringsAsFactors=FALSE)
SurveyData74 <- read.csv("data/raw/180720_1409_survey.csv", stringsAsFactors=FALSE)
# Synch-RM: session 1,2,3,4,5,6,7,8
SurveyData81 <- read.csv("data/raw/201021_1149_survey.csv", stringsAsFactors=FALSE) 
SurveyData82 <- read.csv("data/raw/201021_1344_survey.csv", stringsAsFactors=FALSE)
SurveyData83 <- read.csv("data/raw/201022_1147_survey.csv", stringsAsFactors=FALSE)
SurveyData84 <- read.csv("data/raw/201104_1053_survey.csv", stringsAsFactors=FALSE)
SurveyData85 <- read.csv("data/raw/201104_1346_survey.csv", stringsAsFactors=FALSE)
SurveyData86 <- read.csv("data/raw/201116_1339_survey.csv", stringsAsFactors=FALSE)
SurveyData87 <- read.csv("data/raw/201117_1439_survey.csv", stringsAsFactors=FALSE)
SurveyData88 <- read.csv("data/raw/210325_1641_survey.csv", stringsAsFactors=FALSE)
# RM at Indiana University: session 1,2,3,4,5,6,7,8
SurveyData91 <- read.csv("data/raw/201022_1548_survey.csv", stringsAsFactors=FALSE) 
SurveyData92 <- read.csv("data/raw/201027_1347_survey.csv", stringsAsFactors=FALSE)
SurveyData93 <- read.csv("data/raw/201027_1445_survey.csv", stringsAsFactors=FALSE)
SurveyData94 <- read.csv("data/raw/201027_1542_survey.csv", stringsAsFactors=FALSE)
SurveyData95 <- read.csv("data/raw/201105_1434_survey.csv", stringsAsFactors=FALSE)
SurveyData96 <- read.csv("data/raw/201118_1104_survey.csv", stringsAsFactors=FALSE) 
SurveyData97 <- read.csv("data/raw/201118_1340_survey.csv", stringsAsFactors=FALSE) 
SurveyData98 <- read.csv("data/raw/201119_1443_survey.csv", stringsAsFactors=FALSE) 
# RM with VHBB: session 1,2,3,4,5,6,7,8
SurveyData101 <- read.csv("data/raw/210322_1440_survey.csv", stringsAsFactors=FALSE) 
SurveyData102 <- read.csv("data/raw/210322_1544_survey.csv", stringsAsFactors=FALSE) 
SurveyData103 <- read.csv("data/raw/210322_1637_survey.csv", stringsAsFactors=FALSE) 
SurveyData104 <- read.csv("data/raw/210323_1240_survey.csv", stringsAsFactors=FALSE) 
SurveyData105 <- read.csv("data/raw/210323_1339_survey.csv", stringsAsFactors=FALSE) 
SurveyData106 <- read.csv("data/raw/210324_1613_survey.csv", stringsAsFactors=FALSE) 
SurveyData107 <- read.csv("data/raw/210324_1706_survey.csv", stringsAsFactors=FALSE) 
SurveyData108 <- read.csv("data/raw/210325_1547_survey.csv", stringsAsFactors=FALSE) 
# Richer RCT: session 1,2,3,4,5,6,7,8
SurveyData111 <- read.csv("data/raw/210405_1640_survey.csv", stringsAsFactors=FALSE) 
SurveyData112 <- read.csv("data/raw/210406_1635_survey.csv", stringsAsFactors=FALSE) 
SurveyData113 <- read.csv("data/raw/210414_1534_survey.csv", stringsAsFactors=FALSE) 
SurveyData114 <- read.csv("data/raw/210414_1638_survey.csv", stringsAsFactors=FALSE) 
SurveyData115 <- read.csv("data/raw/210419_1534_survey.csv", stringsAsFactors=FALSE) 
SurveyData116 <- read.csv("data/raw/210421_1656_survey.csv", stringsAsFactors=FALSE) 
SurveyData117 <- read.csv("data/raw/210427_1036_survey.csv", stringsAsFactors=FALSE) 
SurveyData118 <- read.csv("data/raw/210427_1641_survey.csv", stringsAsFactors=FALSE) 
#########################################################
###                                                   ###
# Part 1: Reshape z-Tree output into a workable data    #
#           formats for each treatment separately       #
###                                                   ###
#########################################################
########################
# Baseline Treatment  #
#######################
#
# Group IDs and Role IDs
GroupID11 <- as.numeric(data11[3:20,20])
GroupID12 <- as.numeric(data12[3:20,20]) + 3 # To have unique IDs for each treatment (not session)
GroupID13 <- as.numeric(data13[3:14,20]) + 6 # To have unique IDs for each treatment (not session)
#
RoleID11 <- as.numeric(data11[3:20,22])
RoleID12 <- as.numeric(data12[3:20,22])
RoleID13 <- as.numeric(data13[3:14,22])
# Gather decisions in each round
Decision11 <- matrix(-1,18,10)
Decision12 <- matrix(-1,18,10)
Decision13 <- matrix(-1,12,10)
# Extract from every round
for(i in 1:10){
  auxi11 <- data11[((18*(i-1) + 3*i):(18*i + 3*i - 1)),40]
  auxi12 <- data12[((18*(i-1) + 3*i):(18*i + 3*i - 1)),40]
  auxi13 <- data13[((12*(i-1) + 3*i):(12*i + 3*i - 1)),40]
  Decision11[,i] <- as.numeric((auxi11))
  Decision12[,i] <- as.numeric((auxi12))
  Decision13[,i] <- as.numeric((auxi13))
}
#
# Order Decisions in Baseline Treatment by GroupID and then Combine all sessions
#
Decision_11 <- cbind(GroupID11,RoleID11,Decision11,data11[3:20,24:28])
Decision_11 <- Decision_11[order(GroupID11),] 
Decision_12 <- cbind(GroupID12,RoleID12,Decision12,data12[3:20,24:28])
Decision_12 <- Decision_12[order(GroupID12),] 
Decision_13 <- cbind(GroupID13,RoleID13,Decision13,data13[3:14,24:28])
Decision_13 <- Decision_13[order(GroupID13),]  
#
b1 <- data.frame(cbind(c("Baseline"),rep(1,18),Decision_11))
b2 <- data.frame(cbind(c("Baseline"),rep(2,18),Decision_12))
b3 <- data.frame(cbind(c("Baseline"),rep(3,12),Decision_13))

names(b1) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10), "Q1", "Q2", "Q3", "Q4", "Q5")
names(b2) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10), "Q1", "Q2", "Q3", "Q4", "Q5")
names(b3) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10), "Q1", "Q2", "Q3", "Q4", "Q5")
#
DecisionsBT <- rbind(b1,b2,b3) # Payoff Relevant Decisions for the Baseline treatment
#
DecisionsBT$Quiz <- rowSums(data.frame(DecisionsBT$Q1 == .42,DecisionsBT$Q2 == .5,
                                       DecisionsBT$Q3 == .62,DecisionsBT$Q4 == .82,
                                       DecisionsBT$Q5 == .74) )
DecisionsBT <- DecisionsBT[,-c(15:19)]
#########################################################
###                                                   ###
# Part 2: Reshape survey output into a workable data    #
#           formats for each treatment separately       #
###                                                   ###
#########################################################
# Combine Group IDs, add survey variables and sort by Group IDs
# Baseline
survey11 <- cbind(GroupID11,t(SurveyData11[c(3:7),-c(1)]))
survey12 <- cbind(GroupID12,t(SurveyData12[c(3:7),-c(1)]))
survey13 <- cbind(GroupID13,t(SurveyData13[c(3:7),-c(1)]))
survey11 <- survey11[order(GroupID11),] 
survey12 <- survey12[order(GroupID12),] 
survey13 <- survey13[order(GroupID13),] 
survey1 <- data.frame(rbind(survey11,survey12,survey13))[,-c(1)]
names(survey1) <- c("Gender", "Major1", "Major2", "GPA", "GameTheory")
#
DecisionsBT <- data.frame(DecisionsBT,survey1)
#
# Response Time Data
#
# Gather RTs in each round
RT11 <- matrix(-1,18,10)
RT12 <- matrix(-1,18,10)
RT13 <- matrix(-1,12,10)
# Extract from every round
for(i in 1:10){
  auxi11 <- data11[((18*(i-1) + 3*i):(18*i + 3*i - 1)),41]
  auxi12 <- data12[((18*(i-1) + 3*i):(18*i + 3*i - 1)),41]
  auxi13 <- data13[((12*(i-1) + 3*i):(12*i + 3*i - 1)),41]
  RT11[,i] <- as.numeric((auxi11))
  RT12[,i] <- as.numeric((auxi12))
  RT13[,i] <- as.numeric((auxi13))
}
#
# Order RTs in Baseline Treatment by GroupID and then Combine all sessions
#
RT_11 <- cbind(GroupID11,RoleID11,abs(RT11-1000)+1)
RT_11 <- RT_11[order(GroupID11),] 
RT_12 <- cbind(GroupID12,RoleID12,abs(RT12-1000)+1)
RT_12 <- RT_12[order(GroupID12),] 
RT_13 <- cbind(GroupID13,RoleID13,abs(RT13-1000)+1)
RT_13 <- RT_13[order(GroupID13),]  
#
ba1 <- data.frame(cbind(c("Baseline"),rep(1,18),RT_11))
ba2 <- data.frame(cbind(c("Baseline"),rep(2,18),RT_12))
ba3 <- data.frame(cbind(c("Baseline"),rep(3,12),RT_13))

names(ba1) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(ba2) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10))
names(ba3) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10))
#
RTsBT <- rbind(ba1,ba2,ba3) 
#
# ADD Quiz (only add payoff quiz since not all treatments have probability quiz)
######################
# REVISION MECHANISM #
######################
# Choice is the instant changes on the left
# Decisions are the choices posted on the graph
#
# Create a data frame for each subject and every second as columns 
# 
Choices21 <- matrix(-1,12,600)
Choices22 <- matrix(-1,12,600)
Choices23 <- matrix(-1,12,600)
Choices24 <- matrix(-1,12,600)
#
GroupID21 <- numeric(12)
GroupID22 <- numeric(12)
GroupID23 <- numeric(12)
GroupID24 <- numeric(12)
#
columnChoice <- 1165 # First column that choice appears
#
for(r in 1:10){
  for(i in 1:12){
    # Session 1 
    auxi21 <- data21[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean21 <- numeric(ncol(auxi21))
    for (k in 1:ncol(auxi21)){
      kt21 <- auxi21[1,k]
      aux_clean21[k] <- as.numeric((kt21))
    }
    Choices21[i,((r-1)*60 +1):(r*60) ] <- aux_clean21
    # Session 2 
    auxi22 <- data22[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean22 <- numeric(ncol(auxi22))
    for (k in 1:ncol(auxi22)){
      kt22 <- auxi22[1,k]
      aux_clean22[k] <- as.numeric((kt22))
    }
    Choices22[i,((r-1)*60 +1):(r*60) ] <- aux_clean22
    # Session 3 
    auxi23 <- data23[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean23 <- numeric(ncol(auxi23))
    for (k in 1:ncol(auxi23)){
      kt23 <- auxi23[1,k]
      aux_clean23[k] <- as.numeric((kt23))
    }
    Choices23[i,((r-1)*60 +1):(r*60) ] <- aux_clean23
    # Session 4 
    auxi24 <- data24[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean24 <- numeric(ncol(auxi24))
    for (k in 1:ncol(auxi24)){
      kt24 <- auxi24[1,k]
      aux_clean24[k] <- as.numeric((kt24))
    }
    Choices24[i,((r-1)*60 +1):(r*60) ] <- aux_clean24
  }
}
#
# Group ID and Role ID
#
GroupID21 <- as.numeric((data21[3:14,10]))
GroupID22 <- as.numeric((data22[3:14,10])) + 2
GroupID23 <- as.numeric((data23[3:14,10])) + 4
GroupID24 <- as.numeric((data24[3:14,10])) + 6
#
RoleID21 <- as.numeric((data21[3:14,12]))
RoleID22 <- as.numeric((data22[3:14,12]))
RoleID23 <- as.numeric((data23[3:14,12]))
RoleID24 <- as.numeric((data24[3:14,12]))
#
Decisions21 <- matrix(-1,12,600)
Decisions22 <- matrix(-1,12,600)
Decisions23 <- matrix(-1,12,600)
Decisions24 <- matrix(-1,12,600)
#
columnDecision <- 1885 # First column that decision appears
#
for(r in 1:10){
  for(i in 1:12){
    # Session 1 
    auxi21 <- data21[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean21 <- numeric(ncol(auxi21))
    for (k in 1:ncol(auxi21)){
      kt21 <- auxi21[1,k]
      aux_clean21[k] <- as.numeric((kt21))
    }
    Decisions21[i,((r-1)*60 +1):(r*60) ] <- aux_clean21
    # Session 2 
    auxi22 <- data22[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean22 <- numeric(ncol(auxi22))
    for (k in 1:ncol(auxi22)){
      kt22 <- auxi22[1,k]
      aux_clean22[k] <- as.numeric((kt22))
    }
    Decisions22[i,((r-1)*60 +1):(r*60) ] <- aux_clean22
    # Session 3 
    auxi23 <- data23[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean23 <- numeric(ncol(auxi23))
    for (k in 1:ncol(auxi23)){
      kt23 <- auxi23[1,k]
      aux_clean23[k] <- as.numeric((kt23))
    }
    Decisions23[i,((r-1)*60 +1):(r*60) ] <- aux_clean23
    # Session 4 
    auxi24 <- data24[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean24 <- numeric(ncol(auxi24))
    for (k in 1:ncol(auxi24)){
      kt24 <- auxi24[1,k]
      aux_clean24[k] <- as.numeric((kt24))
    }
    Decisions24[i,((r-1)*60 +1):(r*60) ] <- aux_clean24
  }
}
#
# Order Choices and Decisions by GroupID and then Combine all sessions
#
Choices_21 <- cbind(GroupID21,RoleID21,Choices21)
Choices_21 <- Choices_21[order(GroupID21),] 
Choices_22 <- cbind(GroupID22,RoleID22,Choices22)
Choices_22 <- Choices_22[order(GroupID22),] 
Choices_23 <- cbind(GroupID23,RoleID23,Choices23)
Choices_23 <- Choices_23[order(GroupID23),] 
Choices_24 <- cbind(GroupID24,RoleID24,Choices24)
Choices_24 <- Choices_24[order(GroupID24),] 
#
Decisions_21 <- cbind(GroupID21,RoleID21,Decisions21)
Decisions_21 <- Decisions_21[order(GroupID21),] 
Decisions_22 <- cbind(GroupID22,RoleID22,Decisions22)
Decisions_22 <- Decisions_22[order(GroupID22),] 
Decisions_23 <- cbind(GroupID23,RoleID23,Decisions23)
Decisions_23 <- Decisions_23[order(GroupID23),] 
Decisions_24 <- cbind(GroupID24,RoleID24,Decisions24)
Decisions_24 <- Decisions_24[order(GroupID24),] 
#
#
# Combine Choices and Decisions
#
RevisionMechanismChoices <- data.frame(rbind(Choices_21,Choices_22,
                                             Choices_23,Choices_24))
RevisionMechanismDecisions <- data.frame(rbind(Decisions_21,Decisions_22,
                                               Decisions_23,Decisions_24))
sessionRM <- c(rep(1,12),rep(2,12),rep(3,12),rep(4,12))
RevisionMechanismChoices <- data.frame(cbind(c("Revision Mechanism"),sessionRM,RevisionMechanismChoices))
RevisionMechanismDecisions <- data.frame(cbind(c("Revision Mechanism"),sessionRM,RevisionMechanismDecisions))
#
#
names(RevisionMechanismChoices) <- c("Treatment","Session","GroupID", "RoleID", c(1:600)) # Instant choices
names(RevisionMechanismDecisions) <- c("Treatment","Session","GroupID", "RoleID", c(1:600)) # Decisions on the graph
# Quiz
Quiz_2 <- cbind(c(GroupID21,GroupID22,GroupID23,GroupID24),
                       c(RoleID21,RoleID22,RoleID23,RoleID24),
                 rbind(data21[3:14,14:18],data22[3:14,14:18],data23[3:14,14:18],data24[3:14,14:18])
                 )
Quiz_2 <- Quiz_2[order(c(GroupID21,GroupID22,GroupID23,GroupID24)),] 
names(Quiz_2) <- c("Group","Role","Q1", "Q2", "Q3", "Q4", "Q5")
#
# Only payoff relevant decisions - Revision Mechanism
#
AnswerRM <- matrix(-1,48,10)
#
for(i in 1:10){
  AnswerRM[,i] <- RevisionMechanismDecisions[,64 + 60*(i-1)]
}
RevisionMechanismAnswers <- data.frame(cbind(RevisionMechanismDecisions[,1:4], AnswerRM)) # Payoff Relevant Decisions for RM
# Add Quiz
RevisionMechanismAnswers$Quiz <- rowSums(data.frame(Quiz_2$Q1 == .42,Quiz_2$Q2 == .5,
                                       Quiz_2$Q3 == .62,Quiz_2$Q4 == .82,
                                       Quiz_2$Q5 == .74) )
names(RevisionMechanismAnswers) <- c("Treatment","Session","GroupID", "RoleID", c(1:10),"Quiz")
#
# SURVEY
# 
# Revision Mechanism
survey21 <- cbind(GroupID21,t(SurveyData21[c(3:7),-c(1)]))
survey22 <- cbind(GroupID22,t(SurveyData22[c(3:7),-c(1)]))
survey23 <- cbind(GroupID23,t(SurveyData23[c(3:7),-c(1)]))
survey24 <- cbind(GroupID24,t(SurveyData24[c(3:7),-c(1)]))
survey21 <- survey21[order(GroupID21),] 
survey22 <- survey22[order(GroupID22),] 
survey23 <- survey23[order(GroupID23),] 
survey24 <- survey24[order(GroupID24),] 
survey2 <- data.frame(rbind(survey21,survey22,survey23,survey24))
names(survey2) <- c("Group", "Gender", "Major1", "Major2", "GPA", "GameTheory")
#
RevisionMechanismAnswers <- data.frame(RevisionMechanismAnswers,survey2[,-c(1)])
#
# Response Time RM
#
# Gather RTs in each round
RT21 <- matrix(-1,12,10)
RT22 <- matrix(-1,12,10)
RT23 <- matrix(-1,12,10)
RT24 <- matrix(-1,12,10)
# Extract from every round
columnRT <- 49
rowRT <- 77
for(i in 1:10){
  auxi21 <- data21[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  auxi22 <- data22[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  auxi23 <- data23[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  auxi24 <- data24[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  RT21[,i] <- as.numeric((auxi21))
  RT22[,i] <- as.numeric((auxi22))
  RT23[,i] <- as.numeric((auxi23))
  RT24[,i] <- as.numeric((auxi24))
}
#
# Order RTs in Baseline Treatment by GroupID and then Combine all sessions
#
RT_21 <- cbind(GroupID21,RoleID21,abs(RT21-1000)+1)
RT_21 <- RT_21[order(GroupID21),] 
RT_22 <- cbind(GroupID22,RoleID22,abs(RT22-1000)+1)
RT_22 <- RT_22[order(GroupID22),] 
RT_23 <- cbind(GroupID23,RoleID23,abs(RT23-1000)+1)
RT_23 <- RT_23[order(GroupID23),]  
RT_24 <- cbind(GroupID24,RoleID24,abs(RT24-1000)+1)
RT_24 <- RT_24[order(GroupID24),]  
#
ba1 <- data.frame(cbind(c("Revision Mechanism"),rep(1,12),RT_21))
ba2 <- data.frame(cbind(c("Revision Mechanism"),rep(2,12),RT_22))
ba3 <- data.frame(cbind(c("Revision Mechanism"),rep(3,12),RT_23))
ba4 <- data.frame(cbind(c("Revision Mechanism"),rep(4,12),RT_24))


names(ba1) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(ba2) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10))
names(ba3) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10))
names(ba4) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10))
#
RTsRM <- rbind(ba1,ba2,ba3,ba4)
#
#######################
# REVISION CHEAP TALK #
#######################
# 
Choices31 <- matrix(-1,12,600)
Choices32 <- matrix(-1,12,600)
Choices33 <- matrix(-1,12,600)
Choices34 <- matrix(-1,12,600)
#
GroupID31 <- numeric(12)
GroupID32 <- numeric(12)
GroupID33 <- numeric(12)
GroupID34 <- numeric(12)
#
columnChoice <- 1176
#
for(r in 1:10){
  for(i in 1:12){
    # Session 1 
    auxi31 <- data31[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean31 <- numeric(ncol(auxi31))
    for (k in 1:ncol(auxi31)){
      kt31 <- auxi31[1,k]
      aux_clean31[k] <- as.numeric((kt31))
    }
    Choices31[i,((r-1)*60 +1):(r*60) ] <- aux_clean31
    # Session 2 
    auxi32 <- data32[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean32 <- numeric(ncol(auxi32))
    for (k in 1:ncol(auxi32)){
      kt32 <- auxi32[1,k]
      aux_clean32[k] <- as.numeric((kt32))
    }
    Choices32[i,((r-1)*60 +1):(r*60) ] <- aux_clean32
    # Session 3 
    auxi33 <- data33[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean33 <- numeric(ncol(auxi33))
    for (k in 1:ncol(auxi33)){
      kt33 <- auxi33[1,k]
      aux_clean33[k] <- as.numeric((kt33))
    }
    Choices33[i,((r-1)*60 +1):(r*60) ] <- aux_clean33
    # Session 4 
    auxi34 <- data34[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean34 <- numeric(ncol(auxi34))
    for (k in 1:ncol(auxi34)){
      kt34 <- auxi34[1,k]
      aux_clean34[k] <- as.numeric((kt34))
    }
    Choices34[i,((r-1)*60 +1):(r*60) ] <- aux_clean34
  }
}
#
# Group ID and Role ID
#
GroupID31 <- as.numeric((data31[3:14,10]))
GroupID32 <- as.numeric((data32[3:14,10])) + 2
GroupID33 <- as.numeric((data33[3:14,10])) + 4
GroupID34 <- as.numeric((data34[3:14,10])) + 6
#
RoleID31 <- as.numeric((data31[3:14,12]))
RoleID32 <- as.numeric((data32[3:14,12]))
RoleID33 <- as.numeric((data33[3:14,12]))
RoleID34 <- as.numeric((data34[3:14,12]))
# 
Decisions31 <- matrix(-1,12,600)
Decisions32 <- matrix(-1,12,600)
Decisions33 <- matrix(-1,12,600)
Decisions34 <- matrix(-1,12,600)
#
columnDecision <- 1896
#
for(r in 1:10){
  for(i in 1:12){
    # Session 1 
    auxi31 <- data31[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean31 <- numeric(ncol(auxi31))
    for (k in 1:ncol(auxi31)){
      kt31 <- auxi31[1,k]
      aux_clean31[k] <- as.numeric((kt31))
    }
    Decisions31[i,((r-1)*60 +1):(r*60) ] <- aux_clean31
    # Session 2 
    auxi32 <- data32[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean32 <- numeric(ncol(auxi32))
    for (k in 1:ncol(auxi32)){
      kt32 <- auxi32[1,k]
      aux_clean32[k] <- as.numeric((kt32))
    }
    Decisions32[i,((r-1)*60 +1):(r*60) ] <- aux_clean32
    # Session 3 
    auxi33 <- data33[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean33 <- numeric(ncol(auxi33))
    for (k in 1:ncol(auxi33)){
      kt33 <- auxi33[1,k]
      aux_clean33[k] <- as.numeric((kt33))
    }
    Decisions33[i,((r-1)*60 +1):(r*60) ] <- aux_clean33
    # Session 4 
    auxi34 <- data34[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean34 <- numeric(ncol(auxi34))
    for (k in 1:ncol(auxi34)){
      kt34 <- auxi34[1,k]
      aux_clean34[k] <- as.numeric((kt34))
    }
    Decisions34[i,((r-1)*60 +1):(r*60) ] <- aux_clean34
  }
}
#
# Order Choices and Decisions by GroupID and then Combine all sessions
#
Choices_31 <- cbind(GroupID31,RoleID31,Choices31)
Choices_31 <- Choices_31[order(GroupID31),] 
Choices_32 <- cbind(GroupID32,RoleID32,Choices32)
Choices_32 <- Choices_32[order(GroupID32),] 
Choices_33 <- cbind(GroupID33,RoleID33,Choices33)
Choices_33 <- Choices_33[order(GroupID33),] 
Choices_34 <- cbind(GroupID34,RoleID34,Choices34)
Choices_34 <- Choices_34[order(GroupID34),] 
#
Decisions_31 <- cbind(GroupID31,RoleID31,Decisions31)
Decisions_31 <- Decisions_31[order(GroupID31),] 
Decisions_32 <- cbind(GroupID32,RoleID32,Decisions32)
Decisions_32 <- Decisions_32[order(GroupID32),] 
Decisions_33 <- cbind(GroupID33,RoleID33,Decisions33)
Decisions_33 <- Decisions_33[order(GroupID33),] 
Decisions_34 <- cbind(GroupID34,RoleID34,Decisions34)
Decisions_34 <- Decisions_34[order(GroupID34),] 
#
# Combine Choices and Decisions
#
RevisionCheapTalkChoices <- data.frame(rbind(Choices_31,Choices_32,
                                     Choices_33,Choices_34))
RevisionCheapTalkDecisions <- data.frame(rbind(Decisions_31,Decisions_32,
                                       Decisions_33,Decisions_34))
session <- c(rep(1,12),rep(2,12),rep(3,12),rep(4,12))
RevisionCheapTalkChoices <- data.frame(cbind("Revision Cheap Talk",session,RevisionCheapTalkChoices))
RevisionCheapTalkDecisions <- data.frame(cbind("Revision Cheap Talk",session,RevisionCheapTalkDecisions))
names(RevisionCheapTalkChoices) <- c("Treatment","Session","GroupID", "RoleID", c(1:600))
names(RevisionCheapTalkDecisions) <- c("Treatment","Session","GroupID", "RoleID", c(1:600))
#
# Quiz
Quiz_3 <- cbind(c(GroupID31,GroupID32,GroupID33,GroupID34),
                c(RoleID31,RoleID32,RoleID33,RoleID34),
                rbind(data31[3:14,14:18],data32[3:14,14:18],data33[3:14,14:18],data34[3:14,14:18])
)
Quiz_3 <- Quiz_3[order(c(GroupID31,GroupID32,GroupID33,GroupID34)),] 
names(Quiz_3) <- c("Group","Role","Q1", "Q2", "Q3", "Q4", "Q5")
##################################################
# Only 60th second decisions, payoff irrelevant  #
##################################################
RCT60th <- matrix(-1,48,10)
#
for(i in 1:10){
  RCT60th[,i] <- RevisionCheapTalkDecisions[,64 + 60*(i-1)]
}
RevisionCheapTalk60th <- data.frame(cbind(RevisionCheapTalkDecisions[,2:3], RCT60th))
RevisionCheapTalk60th <- data.frame(cbind(c("Revision Cheap Talk 60th"),session,RevisionCheapTalk60th))
names(RevisionCheapTalk60th) <- c("Treatment","Session","GroupID", "RoleID", c(1:10))
###################################################
# Revision Cheap Talk - Payoff Relevant Decision  #
##################################################
Answer31 <- matrix(-1,12,10)
Answer32 <- matrix(-1,12,10)
Answer33 <- matrix(-1,12,10)
Answer34 <- matrix(-1,12,10)
#
for(i in 1:10){
  auxi31 <- data31[((12*(i-1) + 3*i + 62*(i-1)):(12*i + 3*i + 62*(i-1) - 1)),39]
  auxi32 <- data32[((12*(i-1) + 3*i + 62*(i-1)):(12*i + 3*i + 62*(i-1) - 1)),39]
  auxi33 <- data33[((12*(i-1) + 3*i + 62*(i-1)):(12*i + 3*i + 62*(i-1) - 1)),39]
  auxi34 <- data34[((12*(i-1) + 3*i + 62*(i-1)):(12*i + 3*i + 62*(i-1) - 1)),39]
  Answer31[,i] <- as.numeric((auxi31))
  Answer32[,i] <- as.numeric((auxi32))
  Answer33[,i] <- as.numeric((auxi33))
  Answer34[,i] <- as.numeric((auxi34))
}
#
#
# Order Decisions by GroupID and then Combine all sessions
#
Answer_31 <- cbind(GroupID31,RoleID31,Answer31)
Answer_31 <- Answer_31[order(GroupID31),] 
Answer_32 <- cbind(GroupID32,RoleID32,Answer32)
Answer_32 <- Answer_32[order(GroupID32),] 
Answer_33 <- cbind(GroupID33,RoleID33,Answer33)
Answer_33 <- Answer_33[order(GroupID33),]  
Answer_34 <- cbind(GroupID34,RoleID34,Answer34)
Answer_34 <- Answer_34[order(GroupID34),]  
#
a1 <- data.frame(cbind(c("Revision Cheap Talk"),rep(1,12),Answer_31))
a2 <- data.frame(cbind(c("Revision Cheap Talk"),rep(2,12),Answer_32))
a3 <- data.frame(cbind(c("Revision Cheap Talk"),rep(3,12),Answer_33))
a4 <- data.frame(cbind(c("Revision Cheap Talk"),rep(4,12),Answer_34))
names(a1) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(a2) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(a3) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(a4) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
#
RevisionCheapTalkAnswers <- rbind(a1,a2,a3,a4) # Payoff relevant decisions in RCT
#
# Add Quiz
RevisionCheapTalkAnswers$Quiz <- rowSums(data.frame(Quiz_3$Q1 == .42,Quiz_3$Q2 == .5,
                                                    Quiz_3$Q3 == .62,Quiz_3$Q4 == .82,
                                                    Quiz_3$Q5 == .74) )
#

# Revision Cheap Talk 
survey31 <- cbind(GroupID31,t(SurveyData31[c(3:7),-c(1)]))
survey32 <- cbind(GroupID32,t(SurveyData32[c(3:7),-c(1)]))
survey33 <- cbind(GroupID33,t(SurveyData33[c(3:7),-c(1)]))
survey34 <- cbind(GroupID34,t(SurveyData34[c(3:7),-c(1)]))
survey31 <- survey31[order(GroupID31),] 
survey32 <- survey32[order(GroupID32),] 
survey33 <- survey33[order(GroupID33),] 
survey34 <- survey34[order(GroupID34),] 
survey3 <- data.frame(rbind(survey31,survey32,survey33,survey34))
names(survey3) <- c("Group", "Gender", "Major1", "Major2", "GPA", "GameTheory")
#
RevisionCheapTalkAnswers <- data.frame(RevisionCheapTalkAnswers,survey3[,-c(1)])
#
#
#
#
# Response Time RCT
#
# Gather RTs in each round
RT31 <- matrix(-1,12,10)
RT32 <- matrix(-1,12,10)
RT33 <- matrix(-1,12,10)
RT34 <- matrix(-1,12,10)
# Extract from every round
columnRT <- 47
rowRT <- 77
for(i in 1:10){
  auxi31 <- data31[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  auxi32 <- data32[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  auxi33 <- data33[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  auxi34 <- data34[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  RT31[,i] <- as.numeric((auxi31))
  RT32[,i] <- as.numeric((auxi32))
  RT33[,i] <- as.numeric((auxi33))
  RT34[,i] <- as.numeric((auxi34))
}
#
# Order RTs in Baseline Treatment by GroupID and then Combine all sessions
#
RT_31 <- cbind(GroupID31,RoleID31,abs(RT31-1000)+1)
RT_31 <- RT_31[order(GroupID31),] 
RT_32 <- cbind(GroupID32,RoleID32,abs(RT32-1000)+1)
RT_32 <- RT_32[order(GroupID32),] 
RT_33 <- cbind(GroupID33,RoleID33,abs(RT33-1000)+1)
RT_33 <- RT_33[order(GroupID33),]  
RT_34 <- cbind(GroupID34,RoleID34,abs(RT34-1000)+1)
RT_34 <- RT_34[order(GroupID34),]  
#
ba1 <- data.frame(cbind(c("Revision Cheap Talk"),rep(1,12),RT_31))
ba2 <- data.frame(cbind(c("Revision Cheap Talk"),rep(2,12),RT_31))
ba3 <- data.frame(cbind(c("Revision Cheap Talk"),rep(3,12),RT_31))
ba4 <- data.frame(cbind(c("Revision Cheap Talk"),rep(4,12),RT_31))


names(ba1) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(ba2) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10))
names(ba3) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10))
names(ba4) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10))
#
RTsRCT <- rbind(ba1,ba2,ba3,ba4)
#
#############################
# RANDOM REVISION MECHANISM # 
#############################
#
Choices41 <- matrix(-1,12,600)
Choices42 <- matrix(-1,12,600)
Choices43 <- matrix(-1,12,600)
Choices44 <- matrix(-1,12,600)
#
GroupID41 <- numeric(12)
GroupID42 <- numeric(12)
GroupID43 <- numeric(12)
GroupID44 <- numeric(12)
#
columnChoice <- 1166
#
for(r in 1:10){
  for(i in 1:12){
    # Session 1 
    auxi41 <- data41[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean41 <- numeric(ncol(auxi41))
    for (k in 1:ncol(auxi41)){
      kt41 <- auxi41[1,k]
      aux_clean41[k] <- as.numeric((kt41))
    }
    Choices41[i,((r-1)*60 +1):(r*60) ] <- aux_clean41
    # Session 2 
    auxi42 <- data42[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean42 <- numeric(ncol(auxi42))
    for (k in 1:ncol(auxi42)){
      kt42 <- auxi42[1,k]
      aux_clean42[k] <- as.numeric((kt42))
    }
    Choices42[i,((r-1)*60 +1):(r*60) ] <- aux_clean42
    # Session 3 
    auxi43 <- data43[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean43 <- numeric(ncol(auxi43))
    for (k in 1:ncol(auxi43)){
      kt43 <- auxi43[1,k]
      aux_clean43[k] <- as.numeric((kt43))
    }
    Choices43[i,((r-1)*60 +1):(r*60) ] <- aux_clean43
    # Session 2 
    auxi44 <- data44[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean44 <- numeric(ncol(auxi44))
    for (k in 1:ncol(auxi44)){
      kt44 <- auxi44[1,k]
      aux_clean44[k] <- as.numeric((kt44))
    }
    Choices44[i,((r-1)*60 +1):(r*60) ] <- aux_clean44
  }
}
#
# Group ID and Role ID
#
GroupID41 <- as.numeric((data41[3:14,10]))
GroupID42 <- as.numeric((data42[3:14,10])) + 2
GroupID43 <- as.numeric((data43[3:14,10])) + 4
GroupID44 <- as.numeric((data44[3:14,10])) + 6
#
RoleID41 <- as.numeric((data41[3:14,12]))
RoleID42 <- as.numeric((data42[3:14,12]))
RoleID43 <- as.numeric((data43[3:14,12]))
RoleID44 <- as.numeric((data44[3:14,12]))
# 
Decisions41 <- matrix(-1,12,600)
Decisions42 <- matrix(-1,12,600)
Decisions43 <- matrix(-1,12,600)
Decisions44 <- matrix(-1,12,600)
#
columnDecision <- 1886
#
for(r in 1:10){
  for(i in 1:12){
    # Session 1 
    auxi41 <- data41[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean41 <- numeric(ncol(auxi41))
    for (k in 1:ncol(auxi41)){
      kt41 <- auxi41[1,k]
      aux_clean41[k] <- as.numeric((kt41))
    }
    Decisions41[i,((r-1)*60 +1):(r*60) ] <- aux_clean41
    # Session 2 
    auxi42 <- data42[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean42 <- numeric(ncol(auxi42))
    for (k in 1:ncol(auxi42)){
      kt42 <- auxi42[1,k]
      aux_clean42[k] <- as.numeric((kt42))
    }
    Decisions42[i,((r-1)*60 +1):(r*60) ] <- aux_clean42
    # Session 3 
    auxi43 <- data43[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean43 <- numeric(ncol(auxi43))
    for (k in 1:ncol(auxi43)){
      kt43 <- auxi43[1,k]
      aux_clean43[k] <- as.numeric((kt43))
    }
    Decisions43[i,((r-1)*60 +1):(r*60) ] <- aux_clean43
    # Session 4 
    auxi44 <- data44[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean44 <- numeric(ncol(auxi44))
    for (k in 1:ncol(auxi44)){
      kt44 <- auxi44[1,k]
      aux_clean44[k] <- as.numeric((kt44))
    }
    Decisions44[i,((r-1)*60 +1):(r*60) ] <- aux_clean44
  }
}
#
# Order Choices and Decisions by GroupID and then Combine all sessions
#
Choices_41 <- cbind(GroupID41,RoleID41,Choices41)
Choices_41 <- Choices_41[order(GroupID41),] 
Choices_42 <- cbind(GroupID42,RoleID42,Choices42)
Choices_42 <- Choices_42[order(GroupID42),] 
Choices_43 <- cbind(GroupID43,RoleID43,Choices43)
Choices_43 <- Choices_43[order(GroupID43),] 
Choices_44 <- cbind(GroupID44,RoleID44,Choices44)
Choices_44 <- Choices_44[order(GroupID44),] 
#
Decisions_41 <- cbind(GroupID41,RoleID41,Decisions41)
Decisions_41 <- Decisions_41[order(GroupID41),] 
Decisions_42 <- cbind(GroupID42,RoleID42,Decisions42)
Decisions_42 <- Decisions_42[order(GroupID42),] 
Decisions_43 <- cbind(GroupID43,RoleID43,Decisions43)
Decisions_43 <- Decisions_43[order(GroupID43),] 
Decisions_44 <- cbind(GroupID44,RoleID44,Decisions44)
Decisions_44 <- Decisions_44[order(GroupID44),] 
#
# Combine Choices and Decisions
#
RandomRMChoices <- data.frame(rbind(Choices_41,Choices_42,
                                    Choices_43,Choices_44))
RandomRMDecisions <- data.frame(rbind(Decisions_41,Decisions_42,
                                      Decisions_43,Decisions_44))
RandomRMChoices <- data.frame(cbind("Random Revision Mechanism",session,RandomRMChoices))
RandomRMDecisions <- data.frame(cbind("Random Revision Mechanism",session,RandomRMDecisions))
names(RandomRMChoices) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:600))
names(RandomRMDecisions) <- c("Treatment","Session", "GroupID", "RoleID", c(1:600))
#
#
# Quiz
Quiz_4 <- cbind(c(GroupID41,GroupID42,GroupID43,GroupID44),
                c(RoleID41,RoleID42,RoleID43,RoleID44),
                rbind(data41[3:14,75:79],data42[3:14,75:79],data43[3:14,75:79],
                      data44[3:14,75:79])
)
Quiz_4 <- Quiz_4[order(c(GroupID41,GroupID42,GroupID43,GroupID44)),] 
names(Quiz_4) <- c("Group","Role","Q1", "Q2", "Q3", "Q4", "Q5")
#
# Only payoff relevant decisions RRM
#
AnswerRRM <- matrix(-1,48,10)
#
for(i in 1:10){
  AnswerRRM[,i] <- RandomRMDecisions[,64 + 60*(i-1)]
}
RandomRMAnswers <- data.frame(cbind(RandomRMDecisions[,1:4], AnswerRRM))
names(RandomRMAnswers) <- c("Treatment","Session","GroupID", "RoleID", c(1:10)) # Payoff relevant decisions RRM
#
RandomRMAnswers$Quiz <- rowSums(data.frame(Quiz_4$Q1 == .42,Quiz_4$Q2 == .5,
                                           Quiz_4$Q3 == .62,Quiz_4$Q4 == .82,
                                           Quiz_4$Q5 == .74) )
# Survey
# Random Revision Mechanism
survey41 <- cbind(GroupID41,t(SurveyData41[c(3:7),-c(1)]))
survey42 <- cbind(GroupID42,t(SurveyData42[c(3:7),-c(1)]))
survey43 <- cbind(GroupID43,t(SurveyData43[c(3:7),-c(1)]))
survey44 <- cbind(GroupID44,t(SurveyData44[c(3:7),-c(1)]))
survey41 <- survey41[order(GroupID41),] 
survey42 <- survey42[order(GroupID42),] 
survey43 <- survey43[order(GroupID43),] 
survey44 <- survey44[order(GroupID44),] 
survey4 <- data.frame(rbind(survey41,survey42,survey43,survey44))
names(survey4) <- c("Group", "Gender", "Major1", "Major2", "GPA", "GameTheory")
#
RandomRMAnswers <- data.frame(RandomRMAnswers,survey4[,-c(1)])

###############################
#     Standard Cheap Talk     #
###############################
#
# Group ID and Role ID
#
GroupID51 <- as.numeric((data51[3:14,10]))
GroupID52 <- as.numeric((data52[3:14,10])) + 2
GroupID53 <- as.numeric((data53[3:14,10])) + 4
GroupID54 <- as.numeric((data54[3:14,10])) + 6
#
RoleID51 <- as.numeric((data51[3:14,12]))
RoleID52 <- as.numeric((data52[3:14,12]))
RoleID53 <- as.numeric((data53[3:14,12]))
RoleID54 <- as.numeric((data54[3:14,12]))
#
Decision51 <- matrix(-1,12,10)
Decision52 <- matrix(-1,12,10)
Decision53 <- matrix(-1,12,10)
Decision54 <- matrix(-1,12,10)
#
for(i in 1:10){
  auxi11 <- data51[((77*(i-1) + 3):(11 + 77*(i-1) + 3)),42]
  auxi12 <- data52[((77*(i-1) + 3):(11 + 77*(i-1) + 3)),42]
  auxi13 <- data53[((77*(i-1) + 3):(11 + 77*(i-1) + 3)),42]
  auxi14 <- data54[((77*(i-1) + 3):(11 + 77*(i-1) + 3)),42]
  Decision51[,i] <- as.numeric((auxi11))
  Decision52[,i] <- as.numeric((auxi12))
  Decision53[,i] <- as.numeric((auxi13))
  Decision54[,i] <- as.numeric((auxi14))
}
#
#
# Order Decisions in standard Cheap Talk Treatment by GroupID and then Combine all sessions
#
Decision_51 <- cbind(GroupID51,RoleID51,Decision51)
Decision_51 <- Decision_51[order(GroupID51),] 
Decision_52 <- cbind(GroupID52,RoleID52,Decision52)
Decision_52 <- Decision_52[order(GroupID52),] 
Decision_53 <- cbind(GroupID53,RoleID53,Decision53)
Decision_53 <- Decision_53[order(GroupID53),]  
Decision_54 <- cbind(GroupID54,RoleID54,Decision54)
Decision_54 <- Decision_54[order(GroupID54),]  
#
SCT1 <- data.frame(cbind(c("Standard Cheap Talk"),rep(1,12),Decision_51))
SCT2 <- data.frame(cbind(c("Standard Cheap Talk"),rep(2,12),Decision_52))
SCT3 <- data.frame(cbind(c("Standard Cheap Talk"),rep(3,12),Decision_53))
SCT4 <- data.frame(cbind(c("Standard Cheap Talk"),rep(4,12),Decision_54))
names(SCT1) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(SCT2) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(SCT3) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(SCT4) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
#
DecisionsSCT <- rbind(SCT1,SCT2,SCT3,SCT4) # Payoff Relevant Decisions SCT
#
Quiz_5 <- cbind(c(GroupID51,GroupID52,GroupID53,GroupID54),
                c(RoleID51,RoleID52,RoleID53,RoleID54),
                rbind(data51[3:14,26:30],data52[3:14,26:30],data53[3:14,26:30],data54[3:14,26:30])
)
Quiz_5 <- Quiz_5[order(c(GroupID51,GroupID52,GroupID53,GroupID54)),] 
names(Quiz_5) <- c("Group","Role","Q1", "Q2", "Q3", "Q4", "Q5")
DecisionsSCT$Quiz <- rowSums(data.frame(Quiz_5$Q1 == .42,Quiz_5$Q2 == .5,
                                                    Quiz_5$Q3 == .62,Quiz_5$Q4 == .82,
                                                    Quiz_5$Q5 == .74) )
# Data not recorder for first session
DecisionsSCT$Quiz[1:12] <- NA
# Add Survey
# Standard Cheap Talk
survey51 <- cbind(GroupID51,t(SurveyData51[c(3:7),-c(1)]))
survey52 <- cbind(GroupID52,t(SurveyData52[c(3:7),-c(1)]))
survey53 <- cbind(GroupID53,t(SurveyData53[c(3:7),-c(1)]))
survey54 <- cbind(GroupID54,t(SurveyData54[c(3:7),-c(1)]))
survey51 <- survey51[order(GroupID51),] 
survey52 <- survey52[order(GroupID52),] 
survey53 <- survey53[order(GroupID53),] 
survey54 <- survey54[order(GroupID54),] 
survey5 <- data.frame(rbind(survey51,survey52,survey53,survey54))
names(survey5) <- c("Group", "Gender", "Major1", "Major2", "GPA", "GameTheory")
#
DecisionsSCT <- data.frame(DecisionsSCT,survey5[,-c(1)])
#
# Messages in Standard Cheap talk
#
Message51 <- matrix(-1,12,10)
Message52 <- matrix(-1,12,10)
Message53 <- matrix(-1,12,10)
Message54 <- matrix(-1,12,10)
#
for(i in 1:10){
  auxi11 <- data51[((77*(i-1) + 3):(11 + 77*(i-1) + 3)),41]
  auxi12 <- data52[((77*(i-1) + 3):(11 + 77*(i-1) + 3)),41]
  auxi13 <- data53[((77*(i-1) + 3):(11 + 77*(i-1) + 3)),41]
  auxi14 <- data54[((77*(i-1) + 3):(11 + 77*(i-1) + 3)),41]
  Message51[,i] <- as.numeric((auxi11))
  Message52[,i] <- as.numeric((auxi12))
  Message53[,i] <- as.numeric((auxi13))
  Message54[,i] <- as.numeric((auxi14))
}
#
# Order Messages in standard Cheap Talk Treatment by GroupID and then Combine all sessions
#
Message_51 <- cbind(GroupID51,RoleID51,Message51)
Message_51 <- Message_51[order(GroupID51),] 
Message_52 <- cbind(GroupID52,RoleID52,Message52)
Message_52 <- Message_52[order(GroupID52),] 
Message_53 <- cbind(GroupID53,RoleID53,Message53)
Message_53 <- Message_53[order(GroupID53),] 
Message_54 <- cbind(GroupID54,RoleID54,Message54)
Message_54 <- Message_54[order(GroupID54),] 
#
m1 <- data.frame(cbind(c("Standard Cheap Talk"),rep(1,12),Message_51))
m2 <- data.frame(cbind(c("Standard Cheap Talk"),rep(2,12),Message_52))
m3 <- data.frame(cbind(c("Standard Cheap Talk"),rep(3,12),Message_53))
m4 <- data.frame(cbind(c("Standard Cheap Talk"),rep(4,12),Message_54))
names(m1) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(m2) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(m3) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(m4) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
#
MessagesSCT <- rbind(m1,m2,m3,m4) # Messages in SCT
#
#
#
# Response Time Standard Cheap Talk
#
# Gather RTs in each round
RT51 <- matrix(-1,12,10)
RT52 <- matrix(-1,12,10)
RT53 <- matrix(-1,12,10)
RT54 <- matrix(-1,12,10)
# Extract from every round
columnRT <- 61
rowRT <- 77
for(i in 1:10){
  auxi51 <- data51[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  auxi52 <- data52[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  auxi53 <- data53[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  auxi54 <- data54[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  RT51[,i] <- as.numeric((auxi51))
  RT52[,i] <- as.numeric((auxi52))
  RT53[,i] <- as.numeric((auxi53))
  RT54[,i] <- as.numeric((auxi54))
}
#
# Order RTs in Baseline Treatment by GroupID and then Combine all sessions
#
RT_51 <- cbind(GroupID51,RoleID51,abs(RT51-240+65)+1)
RT_51 <- RT_51[order(GroupID51),] 
RT_52 <- cbind(GroupID52,RoleID52,abs(RT52-240+65)+1)
RT_52 <- RT_52[order(GroupID52),] 
RT_53 <- cbind(GroupID53,RoleID53,abs(RT53-240+65)+1)
RT_53 <- RT_53[order(GroupID53),]  
RT_54 <- cbind(GroupID54,RoleID54,abs(RT54-240+65)+1)
RT_54 <- RT_54[order(GroupID54),]  
#
ba1 <- data.frame(cbind(c("Standard Cheap Talk"),rep(1,12),RT_51))
ba2 <- data.frame(cbind(c("Standard Cheap Talk"),rep(2,12),RT_52))
ba3 <- data.frame(cbind(c("Standard Cheap Talk"),rep(3,12),RT_53))
ba4 <- data.frame(cbind(c("Standard Cheap Talk"),rep(4,12),RT_54))


names(ba1) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(ba2) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10))
names(ba3) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10))
names(ba4) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10))
#
RTsSCT <- rbind(ba1,ba2,ba3,ba4)
#
###################################
#                                #
# Infrequent Revision Mechanism  #
#                                #
##################################
#
# Create a data frame for each subject and every second as columns 
# 
Choices61 <- matrix(-1,12,600)
Choices62 <- matrix(-1,12,600)
Choices63 <- matrix(-1,12,600)
Choices64 <- matrix(-1,12,600)
#
GroupID61 <- numeric(12)
GroupID62 <- numeric(12)
GroupID63 <- numeric(12)
GroupID64 <- numeric(12)
#
columnChoice <- 1165 # First column that choice appears
#
for(r in 1:10){
  for(i in 1:12){
    # Session 1 
    auxi61 <- data61[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean61 <- numeric(ncol(auxi61))
    for (k in 1:ncol(auxi61)){
      kt61 <- auxi61[1,k]
      aux_clean61[k] <- as.numeric((kt61))
    }
    Choices61[i,((r-1)*60 +1):(r*60) ] <- aux_clean61
    # Session 2 
    auxi62 <- data62[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean62 <- numeric(ncol(auxi62))
    for (k in 1:ncol(auxi62)){
      kt62 <- auxi62[1,k]
      aux_clean62[k] <- as.numeric((kt62))
    }
    Choices62[i,((r-1)*60 +1):(r*60) ] <- aux_clean62
    # Session 3 
    auxi63 <- data63[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean63 <- numeric(ncol(auxi63))
    for (k in 1:ncol(auxi63)){
      kt63 <- auxi63[1,k]
      aux_clean63[k] <- as.numeric((kt63))
    }
    Choices63[i,((r-1)*60 +1):(r*60) ] <- aux_clean63
    # Session 4
    auxi64 <- data64[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean64 <- numeric(ncol(auxi64))
    for (k in 1:ncol(auxi64)){
      kt64 <- auxi64[1,k]
      aux_clean64[k] <- as.numeric((kt64))
    }
    Choices64[i,((r-1)*60 +1):(r*60) ] <- aux_clean64
  }
}
#
# Group ID and Role ID
#
GroupID61 <- as.numeric((data61[3:14,10]))
GroupID62 <- as.numeric((data62[3:14,10])) + 2
GroupID63 <- as.numeric((data63[3:14,10])) + 4
GroupID64 <- as.numeric((data64[3:14,10])) + 6
#
RoleID61 <- as.numeric((data61[3:14,12]))
RoleID62 <- as.numeric((data62[3:14,12]))
RoleID63 <- as.numeric((data63[3:14,12]))
RoleID64 <- as.numeric((data64[3:14,12]))
#
Decisions61 <- matrix(-1,12,600)
Decisions62 <- matrix(-1,12,600)
Decisions63 <- matrix(-1,12,600)
Decisions64 <- matrix(-1,12,600)
#
columnDecision <- 1885 # First column that decision appears
#
for(r in 1:10){
  for(i in 1:12){
    # Session 1 
    auxi61 <- data61[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean61 <- numeric(ncol(auxi61))
    for (k in 1:ncol(auxi61)){
      kt61 <- auxi61[1,k]
      aux_clean61[k] <- as.numeric((kt61))
    }
    Decisions61[i,((r-1)*60 +1):(r*60) ] <- aux_clean61
    # Session 2 
    auxi62 <- data62[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean62 <- numeric(ncol(auxi62))
    for (k in 1:ncol(auxi62)){
      kt62 <- auxi62[1,k]
      aux_clean62[k] <- as.numeric((kt62))
    }
    Decisions62[i,((r-1)*60 +1):(r*60) ] <- aux_clean62
    # Session 3 
    auxi63 <- data63[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean63 <- numeric(ncol(auxi63))
    for (k in 1:ncol(auxi63)){
      kt63 <- auxi63[1,k]
      aux_clean63[k] <- as.numeric((kt63))
    }
    Decisions63[i,((r-1)*60 +1):(r*60) ] <- aux_clean63
    # Session 2 
    auxi64 <- data64[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean64 <- numeric(ncol(auxi64))
    for (k in 1:ncol(auxi64)){
      kt64 <- auxi64[1,k]
      aux_clean64[k] <- as.numeric((kt64))
    }
    Decisions64[i,((r-1)*60 +1):(r*60) ] <- aux_clean64
  }
}
#
# Order Choices and Decisions by GroupID and then Combine all sessions
#
Choices_61 <- cbind(GroupID61,RoleID61,Choices61)
Choices_61 <- Choices_61[order(GroupID61),] 
Choices_62 <- cbind(GroupID62,RoleID62,Choices62)
Choices_62 <- Choices_62[order(GroupID62),] 
Choices_63 <- cbind(GroupID63,RoleID63,Choices63)
Choices_63 <- Choices_63[order(GroupID63),] 
Choices_64 <- cbind(GroupID64,RoleID64,Choices64)
Choices_64 <- Choices_64[order(GroupID64),] 
#
Decisions_61 <- cbind(GroupID61,RoleID61,Decisions61)
Decisions_61 <- Decisions_61[order(GroupID61),] 
Decisions_62 <- cbind(GroupID62,RoleID62,Decisions62)
Decisions_62 <- Decisions_62[order(GroupID62),] 
Decisions_63 <- cbind(GroupID63,RoleID63,Decisions63)
Decisions_63 <- Decisions_63[order(GroupID63),] 
Decisions_64 <- cbind(GroupID64,RoleID64,Decisions64)
Decisions_64 <- Decisions_64[order(GroupID64),] 
#
# Combine Choices and Decisions
#
InfrequentRevisionMechanismChoices <- data.frame(rbind(Choices_61,Choices_62,
                                                       Choices_63,Choices_64))
InfrequentRevisionMechanismDecisions <- data.frame(rbind(Decisions_61,Decisions_62,
                                                         Decisions_63,Decisions_64))
InfrequentRevisionMechanismChoices <- data.frame(cbind(c("Infrequent Revision Mechanism"),session,InfrequentRevisionMechanismChoices))
InfrequentRevisionMechanismDecisions <- data.frame(cbind(c("Infrequent Revision Mechanism"),session,InfrequentRevisionMechanismDecisions))

names(InfrequentRevisionMechanismChoices) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:600))
names(InfrequentRevisionMechanismDecisions) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:600))
#
#
# Quiz
Quiz_6 <- cbind(c(GroupID61,GroupID62,GroupID63,GroupID64),
                c(RoleID61,RoleID62,RoleID63,RoleID64),
                rbind(data61[3:14,26:30],data62[3:14,26:30],data63[3:14,26:30],data64[3:14,26:30])
)
Quiz_6 <- Quiz_6[order(c(GroupID61,GroupID62,GroupID63,GroupID64)),] 
names(Quiz_6) <- c("Group","Role","Q1", "Q2", "Q3", "Q4", "Q5")
#
# Only payoff relevant  decisions Infrequent RM
#
AnswerIRM <- matrix(-1,48,10)
#
for(i in 1:10){
  AnswerIRM[,i] <- InfrequentRevisionMechanismDecisions[,64 + 60*(i-1)]
}
InfrequentRevisionMechanismAnswers <- data.frame(cbind(InfrequentRevisionMechanismDecisions[,1:4], AnswerIRM))
names(InfrequentRevisionMechanismAnswers) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10)) # Payoff Relevant Decisions IRM
#
# Add Quiz
InfrequentRevisionMechanismAnswers$Quiz <- rowSums(data.frame(Quiz_6$Q1 == .42,Quiz_6$Q2 == .5,
                                                    Quiz_6$Q3 == .62,Quiz_6$Q4 == .82,
                                                    Quiz_6$Q5 == .74) )
# Add survey
#
# Infrequent Revision Mechanism 
survey61 <- cbind(GroupID61,t(SurveyData61[c(3:7),-c(1)]))
survey62 <- cbind(GroupID62,t(SurveyData62[c(3:7),-c(1)]))
survey63 <- cbind(GroupID63,t(SurveyData63[c(3:7),-c(1)]))
survey64 <- cbind(GroupID64,t(SurveyData64[c(3:7),-c(1)]))
survey61 <- survey61[order(GroupID61),] 
survey62 <- survey62[order(GroupID62),] 
survey63 <- survey63[order(GroupID63),] 
survey64 <- survey64[order(GroupID64),] 
survey6 <- data.frame(rbind(survey61,survey62,survey63,survey64))
names(survey6) <- c("Group", "Gender", "Major1", "Major2", "GPA", "GameTheory")
#
InfrequentRevisionMechanismAnswers <- data.frame(InfrequentRevisionMechanismAnswers,survey6[,-c(1)])
#
#
# Response Time IRM
#
# Gather RTs in each round
RT61 <- matrix(-1,12,10)
RT62 <- matrix(-1,12,10)
RT63 <- matrix(-1,12,10)
RT64 <- matrix(-1,12,10)
# Extract from every round
columnRT <- 61
rowRT <- 77
for(i in 1:10){
  auxi61 <- data61[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  auxi62 <- data62[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  auxi63 <- data63[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  auxi64 <- data64[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  RT61[,i] <- as.numeric((auxi61))
  RT62[,i] <- as.numeric((auxi62))
  RT63[,i] <- as.numeric((auxi63))
  RT64[,i] <- as.numeric((auxi64))
}
#
# Order RTs in Baseline Treatment by GroupID and then Combine all sessions
#
RT_61 <- cbind(GroupID61,RoleID61,abs(RT61-1000)+1)
RT_61 <- RT_61[order(GroupID61),] 
RT_62 <- cbind(GroupID62,RoleID62,abs(RT62-1000)+1)
RT_62 <- RT_62[order(GroupID62),] 
RT_63 <- cbind(GroupID63,RoleID63,abs(RT63-1000)+1)
RT_63 <- RT_63[order(GroupID63),]  
RT_64 <- cbind(GroupID64,RoleID64,abs(RT64-1000)+1)
RT_64 <- RT_64[order(GroupID64),]  
#
ba1 <- data.frame(cbind(c("Infrequent Revision Mechanism"),rep(1,12),RT_61))
ba2 <- data.frame(cbind(c("Infrequent Revision Mechanism"),rep(2,12),RT_62))
ba3 <- data.frame(cbind(c("Infrequent Revision Mechanism"),rep(3,12),RT_63))
ba4 <- data.frame(cbind(c("Infrequent Revision Mechanism"),rep(4,12),RT_64))


names(ba1) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(ba2) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10))
names(ba3) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10))
names(ba4) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10))
#
RTsIRM <- rbind(ba1,ba2,ba3,ba4)
#
#####################################################
#           Revision Cheap Talk Memory              #
#####################################################
#
# Create a data frame for each subject and every second as columns (for relevant treatments)
# 
Choices71 <- matrix(-1,12,600)
Choices72 <- matrix(-1,12,600)
Choices73 <- matrix(-1,12,600)
Choices74 <- matrix(-1,12,600)
#
columnChoice <- 1175 # First column that choice appears
#
for(r in 1:10){
  for(i in 1:12){
    # Session 1 
    auxi71 <- data71[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean71 <- numeric(ncol(auxi71))
    for (k in 1:ncol(auxi71)){
      kt71 <- auxi71[1,k]
      aux_clean71[k] <- as.numeric(kt71)
    }
    Choices71[i,((r-1)*60 +1):(r*60) ] <- aux_clean71
    # Session 2 
    auxi72 <- data72[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean72 <- numeric(ncol(auxi72))
    for (k in 1:ncol(auxi72)){
      kt72 <- auxi72[1,k]
      aux_clean72[k] <- as.numeric(kt72)
    }
    Choices72[i,((r-1)*60 +1):(r*60) ] <- aux_clean72
    # Session 3 
    auxi73 <- data73[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean73 <- numeric(ncol(auxi73))
    for (k in 1:ncol(auxi73)){
      kt73 <- auxi73[1,k]
      aux_clean73[k] <- as.numeric(kt73)
    }
    Choices73[i,((r-1)*60 +1):(r*60) ] <- aux_clean73
    # Session 4
    auxi74 <- data74[1 + (r-1)*77,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean74 <- numeric(ncol(auxi74))
    for (k in 1:ncol(auxi74)){
      kt74 <- auxi74[1,k]
      aux_clean74[k] <- as.numeric(kt74)
    }
    Choices74[i,((r-1)*60 +1):(r*60) ] <- aux_clean74
  }
}
#
# Group ID and Role ID
#
GroupID71 <- as.numeric((data71[3:14,10])) + 8
GroupID72 <- as.numeric((data72[3:14,10])) + 10
GroupID73 <- as.numeric((data73[3:14,10])) + 12
GroupID74 <- as.numeric((data74[3:14,10])) + 14
#
RoleID71 <- as.numeric((data71[3:14,12]))
RoleID72 <- as.numeric((data72[3:14,12]))
RoleID73 <- as.numeric((data73[3:14,12]))
RoleID74 <- as.numeric((data74[3:14,12]))
#
Decisions71 <- matrix(-1,12,600)
Decisions72 <- matrix(-1,12,600)
Decisions73 <- matrix(-1,12,600)
Decisions74 <- matrix(-1,12,600)
#
columnDecision <- 1895 # First column that decision appears
#
for(r in 1:10){
  for(i in 1:12){
    # Session 1 
    auxi71 <- data71[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean71 <- numeric(ncol(auxi71))
    for (k in 1:ncol(auxi71)){
      kt71 <- auxi71[1,k]
      aux_clean71[k] <- as.numeric(kt71)
    }
    Decisions71[i,((r-1)*60 +1):(r*60) ] <- aux_clean71
    # Session 2 
    auxi72 <- data72[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean72 <- numeric(ncol(auxi72))
    for (k in 1:ncol(auxi72)){
      kt72 <- auxi72[1,k]
      aux_clean72[k] <- as.numeric(kt72)
    }
    Decisions72[i,((r-1)*60 +1):(r*60) ] <- aux_clean72
    # Session 3 
    auxi73 <- data73[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean73 <- numeric(ncol(auxi73))
    for (k in 1:ncol(auxi73)){
      kt73 <- auxi73[1,k]
      aux_clean73[k] <- as.numeric(kt73)
    }
    Decisions73[i,((r-1)*60 +1):(r*60) ] <- aux_clean73
    # Session 4
    auxi74 <- data74[1 + (r-1)*77,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean74 <- numeric(ncol(auxi74))
    for (k in 1:ncol(auxi74)){
      kt74 <- auxi74[1,k]
      aux_clean74[k] <- as.numeric(kt74)
    }
    Decisions74[i,((r-1)*60 +1):(r*60) ] <- aux_clean74
  }
}
#
# Order Choices and Decisions by GroupID and then Combine all sessions
#
Choices_71 <- cbind(GroupID71,RoleID71,Choices71)
Choices_71 <- Choices_71[order(GroupID71),] 
Choices_72 <- cbind(GroupID72,RoleID72,Choices72)
Choices_72 <- Choices_72[order(GroupID72),] 
Choices_73 <- cbind(GroupID73,RoleID73,Choices73)
Choices_73 <- Choices_73[order(GroupID73),] 
Choices_74 <- cbind(GroupID74,RoleID74,Choices74)
Choices_74 <- Choices_74[order(GroupID74),] 
#
Decisions_71 <- cbind(GroupID71,RoleID71,Decisions71)
Decisions_71 <- Decisions_71[order(GroupID71),] 
Decisions_72 <- cbind(GroupID72,RoleID72,Decisions72)
Decisions_72 <- Decisions_72[order(GroupID72),] 
Decisions_73 <- cbind(GroupID73,RoleID73,Decisions73)
Decisions_73 <- Decisions_73[order(GroupID73),] 
Decisions_74 <- cbind(GroupID74,RoleID74,Decisions74)
Decisions_74 <- Decisions_74[order(GroupID74),]
#
# Combine Choices and Decisions
#
RevisionCheapTalkMemoryChoices <- data.frame(rbind(Choices_71,Choices_72,
                                                   Choices_73,Choices_74))
RevisionCheapTalkMemoryDecisions <- data.frame(rbind(Decisions_71,Decisions_72,
                                                     Decisions_73,Decisions_74))
RevisionCheapTalkMemoryChoices <- data.frame(cbind(c("Revision Cheap Talk"),session,RevisionCheapTalkMemoryChoices))
RevisionCheapTalkMemoryDecisions <- data.frame(cbind(c("Revision Cheap Talk"),session,RevisionCheapTalkMemoryDecisions))

names(RevisionCheapTalkMemoryChoices) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:600))
names(RevisionCheapTalkMemoryDecisions) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:600))
#
#
#
# Quiz
Quiz_7 <- cbind(c(GroupID71,GroupID72,GroupID73,GroupID74),
                c(RoleID71,RoleID72,RoleID73,RoleID74),
                rbind(data71[3:14,14:18],data72[3:14,14:18],data73[3:14,14:18],data74[3:14,14:18])
)
Quiz_7 <- Quiz_7[order(c(GroupID71,GroupID72,GroupID73,GroupID74)),] 
names(Quiz_7) <- c("Group","Role","Q1", "Q2", "Q3", "Q4", "Q5")
#
#######################################################
# Revision Cheap Talk ONLY Payoff Relevant Decisions  #
#######################################################
Answer71 <- matrix(-1,12,10)
Answer72 <- matrix(-1,12,10)
Answer73 <- matrix(-1,12,10)
Answer74 <- matrix(-1,12,10)
#
for(i in 1:10){
  auxi71 <- data71[((12*(i-1) + 3*i + 62*(i-1)):(12*i + 3*i + 62*(i-1) - 1)),35]
  auxi72 <- data72[((12*(i-1) + 3*i + 62*(i-1)):(12*i + 3*i + 62*(i-1) - 1)),35]
  auxi73 <- data73[((12*(i-1) + 3*i + 62*(i-1)):(12*i + 3*i + 62*(i-1) - 1)),35]
  auxi74 <- data74[((12*(i-1) + 3*i + 62*(i-1)):(12*i + 3*i + 62*(i-1) - 1)),35]
  
  Answer71[,i] <- as.numeric(auxi71)
  Answer72[,i] <- as.numeric(auxi72)
  Answer73[,i] <- as.numeric(auxi73)
  Answer74[,i] <- as.numeric(auxi74)
}
#
# Order Decisions by GroupID and then Combine all sessions
#
Answer_71 <- cbind(GroupID71,RoleID71,Answer71)
Answer_71 <- Answer_71[order(GroupID71),] 
Answer_72 <- cbind(GroupID72,RoleID72,Answer72)
Answer_72 <- Answer_72[order(GroupID72),] 
Answer_73 <- cbind(GroupID73,RoleID73,Answer73)
Answer_73 <- Answer_73[order(GroupID73),]  
Answer_74 <- cbind(GroupID74,RoleID74,Answer74)
Answer_74 <- Answer_74[order(GroupID74),] 
#
a1 <- data.frame(cbind(c("Revision Cheap Talk"),rep(1,12),Answer_71))
a2 <- data.frame(cbind(c("Revision Cheap Talk"),rep(2,12),Answer_72))
a3 <- data.frame(cbind(c("Revision Cheap Talk"),rep(3,12),Answer_73))
a4 <- data.frame(cbind(c("Revision Cheap Talk"),rep(4,12),Answer_74))
names(a1) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(a2) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(a3) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(a4) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
#
RevisionCheapTalkMemoryAnswers <- rbind(a1,a2,a3,a4) # Payoff Relevant Decisions R-CT-M
#
RevisionCheapTalkMemoryAnswers$Quiz <- rowSums(data.frame(Quiz_7$Q1 == .42,Quiz_7$Q2 == .5,
                                                    Quiz_7$Q3 == .62,Quiz_7$Q4 == .82,
                                                    Quiz_7$Q5 == .74) )
# Add survey
# Revision Cheap Talk Memory
survey71 <- cbind(GroupID71,t(SurveyData71[c(3:7),-c(1)]))
survey72 <- cbind(GroupID72,t(SurveyData72[c(3:7),-c(1)]))
survey73 <- cbind(GroupID73,t(SurveyData73[c(3:7),-c(1)]))
survey74 <- cbind(GroupID74,t(SurveyData74[c(3:7),-c(1)]))
survey71 <- survey71[order(GroupID71),] 
survey72 <- survey72[order(GroupID72),] 
survey73 <- survey73[order(GroupID73),] 
survey74 <- survey74[order(GroupID74),] 
survey7 <- data.frame(rbind(survey71,survey72,survey73,survey74))
names(survey7) <- c("Group", "Gender", "Major1", "Major2", "GPA", "GameTheory")
#
RevisionCheapTalkMemoryAnswers <- data.frame(RevisionCheapTalkMemoryAnswers,survey7[,-c(1)])
#
##################################################
# Only 60th second decisions, payoff irrelevant  #
##################################################
RCTM60th <- matrix(-1,48,10)
#
for(i in 1:10){
  RCTM60th[,i] <- RevisionCheapTalkMemoryDecisions[,64 + 60*(i-1)]
}
RevisionCheapTalkMemory60th <- data.frame(cbind(RevisionCheapTalkMemoryDecisions[,2:3], RCTM60th))
RevisionCheapTalkMemory60th <- data.frame(cbind(c("Revision Cheap Talk 60th"),session,
                                                RevisionCheapTalkMemory60th))
names(RevisionCheapTalkMemory60th) <- c("Treatment","Session","GroupID", "RoleID", c(1:10))
#
#
# Response Time RCT Memory
#
# Gather RTs in each round
RT71 <- matrix(-1,12,10)
RT72 <- matrix(-1,12,10)
RT73 <- matrix(-1,12,10)
RT74 <- matrix(-1,12,10)
# Extract from every round
columnRT <- 56
rowRT <- 77
for(i in 1:10){
  auxi71 <- data71[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  auxi72 <- data72[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  auxi73 <- data73[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  auxi74 <- data74[((rowRT*(i-1) + 3):(rowRT*(i-1) + 14)),columnRT]
  RT71[,i] <- as.numeric((auxi71))
  RT72[,i] <- as.numeric((auxi72))
  RT73[,i] <- as.numeric((auxi73))
  RT74[,i] <- as.numeric((auxi74))
}
#
# Order RTs in Baseline Treatment by GroupID and then Combine all sessions
#
RT_71 <- cbind(GroupID71,RoleID71,abs(RT71-240+65)+1)
RT_71 <- RT_71[order(GroupID71),] 
RT_72 <- cbind(GroupID72,RoleID72,abs(RT72-240+65)+1)
RT_72 <- RT_72[order(GroupID72),] 
RT_73 <- cbind(GroupID73,RoleID73,abs(RT73-240+65)+1)
RT_73 <- RT_73[order(GroupID73),]  
RT_74 <- cbind(GroupID74,RoleID74,abs(RT74-240+65)+1)
RT_74 <- RT_74[order(GroupID74),]  
#
ba1 <- data.frame(cbind(c("Revision Cheap Talk Memory"),rep(1,12),RT_71))
ba2 <- data.frame(cbind(c("Revision Cheap Talk Memory"),rep(2,12),RT_72))
ba3 <- data.frame(cbind(c("Revision Cheap Talk Memory"),rep(3,12),RT_73))
ba4 <- data.frame(cbind(c("Revision Cheap Talk Memory"),rep(4,12),RT_74))


names(ba1) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(ba2) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10))
names(ba3) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10))
names(ba4) <- c("Treatment", "Session","GroupID", "RoleID", c(1:10))
#
RTsRCTM <- rbind(ba1,ba2,ba3,ba4)
#
#################################
#         Synchronous RM        #
#################################
#
# Create a data frame for each subject and every second as columns 
# 
Choices81 <- matrix(-1,6,600)
Choices82 <- matrix(-1,6,600)
Choices83 <- matrix(-1,6,600)
Choices84 <- matrix(-1,6,600)
Choices85 <- matrix(-1,6,600)
Choices86 <- matrix(-1,6,600)
Choices87 <- matrix(-1,6,600)
Choices88 <- matrix(-1,6,600)
#
columnChoice <- 787 # First column that choice appears
rowChoice <- 73 # Row when second choice appears 
#
for(r in 1:10){
  for(i in 1:6){
    # Session 1 
    auxi81 <- data81[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean81 <- numeric(ncol(auxi81))
    for (k in 1:ncol(auxi81)){
      kt81 <- auxi81[1,k]
      aux_clean81[k] <- as.numeric(kt81)
    }
    Choices81[i,((r-1)*60 +1):(r*60) ] <- aux_clean81
    # Session 2 
    auxi82 <- data82[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean82 <- numeric(ncol(auxi82))
    for (k in 1:ncol(auxi82)){
      kt82 <- auxi82[1,k]
      aux_clean82[k] <- as.numeric(kt82)
    }
    Choices82[i,((r-1)*60 +1):(r*60) ] <- aux_clean82
    # Session 3 
    auxi83 <- data83[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean83 <- numeric(ncol(auxi83))
    for (k in 1:ncol(auxi83)){
      kt83 <- auxi83[1,k]
      aux_clean83[k] <- as.numeric(kt83)
    }
    Choices83[i,((r-1)*60 +1):(r*60) ] <- aux_clean83
    # Session 4 
    auxi84 <- data84[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean84 <- numeric(ncol(auxi84))
    for (k in 1:ncol(auxi84)){
      kt84 <- auxi84[1,k]
      aux_clean84[k] <- as.numeric(kt84)
    }
    Choices84[i,((r-1)*60 +1):(r*60) ] <- aux_clean84
    # Session 5 
    auxi85 <- data85[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean85 <- numeric(ncol(auxi85))
    for (k in 1:ncol(auxi85)){
      kt85 <- auxi85[1,k]
      aux_clean85[k] <- as.numeric(kt85)
    }
    Choices85[i,((r-1)*60 +1):(r*60) ] <- aux_clean85
    # Session 6
    auxi86 <- data86[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean86 <- numeric(ncol(auxi86))
    for (k in 1:ncol(auxi86)){
      kt86 <- auxi86[1,k]
      aux_clean86[k] <- as.numeric(kt86)
    }
    Choices86[i,((r-1)*60 +1):(r*60) ] <- aux_clean86
    # Session 7
    auxi87 <- data87[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean87 <- numeric(ncol(auxi87))
    for (k in 1:ncol(auxi87)){
      kt87 <- auxi87[1,k]
      aux_clean87[k] <- as.numeric(kt87)
    }
    Choices87[i,((r-1)*60 +1):(r*60) ] <- aux_clean87
    # Session 8
    auxi88 <- data88[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean88 <- numeric(ncol(auxi88))
    for (k in 1:ncol(auxi88)){
      kt88 <- auxi88[1,k]
      aux_clean88[k] <- as.numeric(kt88)
    }
    Choices88[i,((r-1)*60 +1):(r*60) ] <- aux_clean88
  }
}
#
# Group ID and Role ID
#
GroupID81 <- as.numeric(data81[3:8,10])
GroupID82 <- as.numeric(data82[3:8,10]) + 1
GroupID83 <- as.numeric(data83[3:8,10]) + 2
GroupID84 <- as.numeric(data84[3:8,10]) + 3
GroupID85 <- as.numeric(data85[3:8,10]) + 4
GroupID86 <- as.numeric(data86[3:8,10]) + 5
GroupID87 <- as.numeric(data87[3:8,10]) + 6
GroupID88 <- as.numeric(data88[3:8,10]) + 7
#
RoleID81 <- as.numeric(data81[3:8,12])
RoleID82 <- as.numeric(data82[3:8,12])
RoleID83 <- as.numeric(data83[3:8,12])
RoleID84 <- as.numeric(data84[3:8,12])
RoleID85 <- as.numeric(data85[3:8,12])
RoleID86 <- as.numeric(data86[3:8,12])
RoleID87 <- as.numeric(data87[3:8,12])
RoleID88 <- as.numeric(data88[3:8,12])
#
Decisions81 <- matrix(-1,6,600)
Decisions82 <- matrix(-1,6,600)
Decisions83 <- matrix(-1,6,600)
Decisions84 <- matrix(-1,6,600)
Decisions85 <- matrix(-1,6,600)
Decisions86 <- matrix(-1,6,600)
Decisions87 <- matrix(-1,6,600)
Decisions88 <- matrix(-1,6,600)
#
columnDecision <- 1147 # First column that decision appears
rowDecision <- 73  # Row when second decision appears 
#
for(r in 1:10){
  for(i in 1:6){
    # Session 1 
    auxi81 <- data81[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean81 <- numeric(ncol(auxi81))
    for (k in 1:ncol(auxi81)){
      kt81 <- auxi81[1,k]
      aux_clean81[k] <- as.numeric(kt81)
    }
    Decisions81[i,((r-1)*60 +1):(r*60) ] <- aux_clean81
    # Session 2 
    auxi82 <- data82[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean82 <- numeric(ncol(auxi82))
    for (k in 1:ncol(auxi82)){
      kt82 <- auxi82[1,k]
      aux_clean82[k] <- as.numeric(kt82)
    }
    Decisions82[i,((r-1)*60 +1):(r*60) ] <- aux_clean82
    # Session 3 
    auxi83 <- data83[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean83 <- numeric(ncol(auxi83))
    for (k in 1:ncol(auxi83)){
      kt83 <- auxi83[1,k]
      aux_clean83[k] <- as.numeric(kt83)
    }
    Decisions83[i,((r-1)*60 +1):(r*60) ] <- aux_clean83
    # Session 4 
    auxi84 <- data84[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean84 <- numeric(ncol(auxi84))
    for (k in 1:ncol(auxi84)){
      kt84 <- auxi84[1,k]
      aux_clean84[k] <- as.numeric(kt84)
    }
    Decisions84[i,((r-1)*60 +1):(r*60) ] <- aux_clean84
    # Session 5 
    auxi85 <- data85[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean85 <- numeric(ncol(auxi85))
    for (k in 1:ncol(auxi85)){
      kt85 <- auxi85[1,k]
      aux_clean85[k] <- as.numeric(kt85)
    }
    Decisions85[i,((r-1)*60 +1):(r*60) ] <- aux_clean85
    # Session 6 
    auxi86 <- data86[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean86 <- numeric(ncol(auxi86))
    for (k in 1:ncol(auxi86)){
      kt86 <- auxi86[1,k]
      aux_clean86[k] <- as.numeric(kt86)
    }
    Decisions86[i,((r-1)*60 +1):(r*60) ] <- aux_clean86
    # Session 7
    auxi87 <- data87[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean87 <- numeric(ncol(auxi87))
    for (k in 1:ncol(auxi87)){
      kt87 <- auxi87[1,k]
      aux_clean87[k] <- as.numeric(kt87)
    }
    Decisions87[i,((r-1)*60 +1):(r*60) ] <- aux_clean87
    # Session 8
    auxi88 <- data88[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean88 <- numeric(ncol(auxi88))
    for (k in 1:ncol(auxi88)){
      kt88 <- auxi88[1,k]
      aux_clean88[k] <- as.numeric(kt88)
    }
    Decisions88[i,((r-1)*60 +1):(r*60) ] <- aux_clean88
  }
}
#
# Order Choices and Decisions by GroupID and then Combine all sessions
#
Choices_81 <- cbind(GroupID81,RoleID81,Choices81)
Choices_81 <- Choices_81[order(GroupID81),] 
Choices_82 <- cbind(GroupID82,RoleID82,Choices82)
Choices_82 <- Choices_82[order(GroupID82),] 
Choices_83 <- cbind(GroupID83,RoleID83,Choices83)
Choices_83 <- Choices_83[order(GroupID83),] 
Choices_84 <- cbind(GroupID84,RoleID84,Choices84)
Choices_84 <- Choices_84[order(GroupID84),] 
Choices_85 <- cbind(GroupID85,RoleID85,Choices85)
Choices_85 <- Choices_85[order(GroupID85),] 
Choices_86 <- cbind(GroupID86,RoleID86,Choices86)
Choices_86 <- Choices_86[order(GroupID86),] 
Choices_87 <- cbind(GroupID87,RoleID87,Choices87)
Choices_87 <- Choices_87[order(GroupID87),] 
Choices_88 <- cbind(GroupID88,RoleID88,Choices88)
Choices_88 <- Choices_88[order(GroupID88),] 
#
Decisions_81 <- cbind(GroupID81,RoleID81,Decisions81)
Decisions_81 <- Decisions_81[order(GroupID81),] 
Decisions_82 <- cbind(GroupID82,RoleID82,Decisions82)
Decisions_82 <- Decisions_82[order(GroupID82),] 
Decisions_83 <- cbind(GroupID83,RoleID83,Decisions83)
Decisions_83 <- Decisions_83[order(GroupID83),] 
Decisions_84 <- cbind(GroupID84,RoleID84,Decisions84)
Decisions_84 <- Decisions_84[order(GroupID84),] 
Decisions_85 <- cbind(GroupID85,RoleID85,Decisions85)
Decisions_85 <- Decisions_85[order(GroupID85),] 
Decisions_86 <- cbind(GroupID86,RoleID86,Decisions86)
Decisions_86 <- Decisions_86[order(GroupID86),] 
Decisions_87 <- cbind(GroupID87,RoleID87,Decisions87)
Decisions_87 <- Decisions_87[order(GroupID87),] 
Decisions_88 <- cbind(GroupID88,RoleID88,Decisions88)
Decisions_88 <- Decisions_88[order(GroupID88),] 
#
# Combine Choices and Decisions
#
SynchRevisionMechanismChoices <- data.frame(rbind(Choices_81,Choices_82,
                                                  Choices_83,Choices_84,
                                                  Choices_85,Choices_86,
                                                  Choices_87,Choices_88))
SynchRevisionMechanismDecisions <- data.frame(rbind(Decisions_81,Decisions_82,
                                                    Decisions_83,Decisions_84,
                                                    Decisions_85,Decisions_86,
                                                    Decisions_87,Decisions_88))
SynchRevisionMechanismChoices <- data.frame(cbind(c("Synchronous Revision Mechanism"),SynchRevisionMechanismChoices$GroupID,SynchRevisionMechanismChoices))
SynchRevisionMechanismDecisions <- data.frame(cbind(c("Synchronous Revision Mechanism"),SynchRevisionMechanismDecisions$GroupID,SynchRevisionMechanismDecisions))
#
names(SynchRevisionMechanismChoices) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:600))
names(SynchRevisionMechanismDecisions) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:600))
#
#
# Quiz
Quiz_8 <- cbind(c(GroupID81,GroupID82,GroupID83,GroupID84,
                  GroupID85,GroupID86,GroupID87,GroupID88),
                c(RoleID81,RoleID82,RoleID83,RoleID84,
                  RoleID85,RoleID86,RoleID87,RoleID88),
                rbind(data81[3:8,14:18],data82[3:8,14:18],data83[3:8,14:18],data84[3:8,14:18],
                      data86[3:8,14:18],data87[3:8,14:18],data87[3:8,14:18],data88[3:8,14:18])
)
Quiz_8 <- Quiz_8[order(c(GroupID81,GroupID82,GroupID83,GroupID84,
                         GroupID85,GroupID86,GroupID87,GroupID88)),] 
names(Quiz_8) <- c("Group","Role","Q1", "Q2", "Q3", "Q4", "Q5")
#
# Only payoff relevant decisions Synchronous Revision Mechanism
#
AnswerS_RM <- matrix(-1,48,10)
#
for(i in 1:10){
  AnswerS_RM[,i] <- SynchRevisionMechanismDecisions[,64 + 60*(i-1)]
}
SynchRevisionMechanismAnswers <- data.frame(cbind(SynchRevisionMechanismDecisions[,1:4], AnswerS_RM))
names(SynchRevisionMechanismAnswers) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10)) # Payoff Relevant Decisions S-RM
#
# Add Quiz
SynchRevisionMechanismAnswers$Quiz <- rowSums(data.frame(Quiz_8$Q1 == .42,Quiz_8$Q2 == .5,
                                                    Quiz_8$Q3 == .62,Quiz_8$Q4 == .82,
                                                    Quiz_8$Q5 == .74) )
#
#
# S-RM
survey81 <- cbind(GroupID81,t(SurveyData81[c(3:7),-c(1)]))
survey82 <- cbind(GroupID82,t(SurveyData82[c(3:7),-c(1)]))
survey83 <- cbind(GroupID83,t(SurveyData83[c(3:7),-c(1)]))
survey84 <- cbind(GroupID84,t(SurveyData84[c(3:7),-c(1)]))
survey85 <- cbind(GroupID85,t(SurveyData85[c(3:7),-c(1)]))
survey86 <- cbind(GroupID86,t(SurveyData86[c(3:7),-c(1)]))
survey87 <- cbind(GroupID87,t(SurveyData87[c(3:7),-c(1)]))
survey88 <- cbind(GroupID88,t(SurveyData88[c(3:7),-c(1)]))

survey81 <- survey81[order(GroupID81),] 
survey82 <- survey82[order(GroupID82),] 
survey83 <- survey83[order(GroupID83),] 
survey84 <- survey84[order(GroupID84),] 
survey85 <- survey85[order(GroupID85),] 
survey86 <- survey86[order(GroupID86),] 
survey87 <- survey87[order(GroupID87),] 
survey88 <- survey88[order(GroupID88),] 
survey8 <- data.frame(rbind(survey81,survey82,survey83,survey84,
                            survey85,survey86,survey87,survey88))
names(survey8) <- c("Group", "Gender", "Major1", "Major2", "GPA", "GameTheory")
#
SynchRevisionMechanismAnswers <- data.frame(SynchRevisionMechanismAnswers,survey8[,-c(1)])
#




#
#########################
# REVISION MECHANISM IU #
#########################
#
# Create a data frame for each subject and every second as columns (for relevant treatments)
# 
Choices91 <- matrix(-1,6,600)
Choices92 <- matrix(-1,6,600)
Choices93 <- matrix(-1,6,600)
Choices94 <- matrix(-1,6,600)
Choices95 <- matrix(-1,6,600)
Choices96 <- matrix(-1,6,600)
Choices97 <- matrix(-1,6,600)
Choices98 <- matrix(-1,6,600)
#
columnChoice <- 787 # First column that choice appears
rowChoice <- 75-2 # Row when second choice appears 
#
for(r in 1:10){
  for(i in 1:6){
    # Session 1 
    auxi91 <- data91[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean91 <- numeric(ncol(auxi91))
    for (k in 1:ncol(auxi91)){
      kt91 <- auxi91[1,k]
      aux_clean91[k] <- as.numeric(kt91)
    }
    Choices91[i,((r-1)*60 +1):(r*60) ] <- aux_clean91
    # Session 2 
    auxi92 <- data92[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean92 <- numeric(ncol(auxi92))
    for (k in 1:ncol(auxi92)){
      kt92 <- auxi92[1,k]
      aux_clean92[k] <- as.numeric(kt92)
    }
    Choices92[i,((r-1)*60 +1):(r*60) ] <- aux_clean92
    # Session 3 
    auxi93 <- data93[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean93 <- numeric(ncol(auxi93))
    for (k in 1:ncol(auxi93)){
      kt93 <- auxi93[1,k]
      aux_clean93[k] <- as.numeric(kt93)
    }
    Choices93[i,((r-1)*60 +1):(r*60) ] <- aux_clean93
    # Session 4
    auxi94 <- data94[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean94 <- numeric(ncol(auxi94))
    for (k in 1:ncol(auxi94)){
      kt94 <- auxi94[1,k]
      aux_clean94[k] <- as.numeric(kt94)
    }
    Choices94[i,((r-1)*60 +1):(r*60) ] <- aux_clean94
    # Session 5
    auxi95 <- data95[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean95 <- numeric(ncol(auxi95))
    for (k in 1:ncol(auxi95)){
      kt95 <- auxi95[1,k]
      aux_clean95[k] <- as.numeric(kt95)
    }
    Choices95[i,((r-1)*60 +1):(r*60) ] <- aux_clean95
    # Session 6
    auxi96 <- data96[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean96 <- numeric(ncol(auxi96))
    for (k in 1:ncol(auxi96)){
      kt96 <- auxi96[1,k]
      aux_clean96[k] <- as.numeric(kt96)
    }
    Choices96[i,((r-1)*60 +1):(r*60) ] <- aux_clean96
    # Session 7
    auxi97 <- data97[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean97 <- numeric(ncol(auxi97))
    for (k in 1:ncol(auxi97)){
      kt97 <- auxi97[1,k]
      aux_clean97[k] <- as.numeric(kt97)
    }
    Choices97[i,((r-1)*60 +1):(r*60) ] <- aux_clean97
    # Session 8
    auxi98 <- data98[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean98 <- numeric(ncol(auxi98))
    for (k in 1:ncol(auxi98)){
      kt98 <- auxi98[1,k]
      aux_clean98[k] <- as.numeric(kt98)
    }
    Choices98[i,((r-1)*60 +1):(r*60) ] <- aux_clean98
  }
}
#
# Group ID and Role ID
#
#
# Group ID and Role ID
#
GroupID91 <- as.numeric(data91[3:8,10]) + 8
GroupID92 <- as.numeric(data92[3:8,10]) + 9
GroupID93 <- as.numeric(data93[3:8,10]) + 10
GroupID94 <- as.numeric(data94[3:8,10]) + 11
GroupID95 <- as.numeric(data95[3:8,10]) + 12
GroupID96 <- as.numeric(data96[3:8,10]) + 13
GroupID97 <- as.numeric(data97[3:8,10]) + 14
GroupID98 <- as.numeric(data98[3:8,10]) + 15
#
RoleID91 <- as.numeric(data91[3:8,12])
RoleID92 <- as.numeric(data92[3:8,12])
RoleID93 <- as.numeric(data93[3:8,12])
RoleID94 <- as.numeric(data94[3:8,12])
RoleID95 <- as.numeric(data95[3:8,12])
RoleID96 <- as.numeric(data96[3:8,12])
RoleID97 <- as.numeric(data97[3:8,12])
RoleID98 <- as.numeric(data98[3:8,12])
#
Decisions91 <- matrix(-1,6,600)
Decisions92 <- matrix(-1,6,600)
Decisions93 <- matrix(-1,6,600)
Decisions94 <- matrix(-1,6,600)
Decisions95 <- matrix(-1,6,600)
Decisions96 <- matrix(-1,6,600)
Decisions97 <- matrix(-1,6,600)
Decisions98 <- matrix(-1,6,600)
#
#
columnDecision <- 1147 # First column that decision appears
rowDecision <- 75-2  # Row when second decision appears 
#
for(r in 1:10){
  for(i in 1:6){
    # Session 1 
    auxi91 <- data91[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean91 <- numeric(ncol(auxi91))
    for (k in 1:ncol(auxi91)){
      kt91 <- auxi91[1,k]
      aux_clean91[k] <- as.numeric(kt91)
    }
    Decisions91[i,((r-1)*60 +1):(r*60) ] <- aux_clean91
    # Session 2 
    auxi92 <- data92[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean92 <- numeric(ncol(auxi92))
    for (k in 1:ncol(auxi92)){
      kt92 <- auxi92[1,k]
      aux_clean92[k] <- as.numeric(kt92)
    }
    Decisions92[i,((r-1)*60 +1):(r*60) ] <- aux_clean92
    # Session 3 
    auxi93 <- data93[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean93 <- numeric(ncol(auxi93))
    for (k in 1:ncol(auxi93)){
      kt93 <- auxi93[1,k]
      aux_clean93[k] <- as.numeric(kt93)
    }
    Decisions93[i,((r-1)*60 +1):(r*60) ] <- aux_clean93
    # Session 4 
    auxi94 <- data94[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean94 <- numeric(ncol(auxi94))
    for (k in 1:ncol(auxi94)){
      kt94 <- auxi94[1,k]
      aux_clean94[k] <- as.numeric(kt94)
    }
    Decisions94[i,((r-1)*60 +1):(r*60) ] <- aux_clean94
    # Session 5
    auxi95 <- data95[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean95 <- numeric(ncol(auxi95))
    for (k in 1:ncol(auxi95)){
      kt95 <- auxi95[1,k]
      aux_clean95[k] <- as.numeric(kt95)
    }
    Decisions95[i,((r-1)*60 +1):(r*60) ] <- aux_clean95
    # Session 6
    auxi96 <- data96[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean96 <- numeric(ncol(auxi96))
    for (k in 1:ncol(auxi96)){
      kt96 <- auxi96[1,k]
      aux_clean96[k] <- as.numeric(kt96)
    }
    Decisions96[i,((r-1)*60 +1):(r*60) ] <- aux_clean96
    # Session 7
    auxi97 <- data97[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean97 <- numeric(ncol(auxi97))
    for (k in 1:ncol(auxi97)){
      kt97 <- auxi97[1,k]
      aux_clean97[k] <- as.numeric(kt97)
    }
    Decisions97[i,((r-1)*60 +1):(r*60) ] <- aux_clean97
    # Session 8
    auxi98 <- data98[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean98 <- numeric(ncol(auxi98))
    for (k in 1:ncol(auxi98)){
      kt98 <- auxi98[1,k]
      aux_clean98[k] <- as.numeric(kt98)
    }
    Decisions98[i,((r-1)*60 +1):(r*60) ] <- aux_clean98
  }
}
#
# Order Choices and Decisions by GroupID and then Combine all sessions
#
Choices_91 <- cbind(GroupID91,RoleID91,Choices91)
Choices_91 <- Choices_91[order(GroupID91),] 
Choices_92 <- cbind(GroupID92,RoleID92,Choices92)
Choices_92 <- Choices_92[order(GroupID92),] 
Choices_93 <- cbind(GroupID93,RoleID93,Choices93)
Choices_93 <- Choices_93[order(GroupID93),] 
Choices_94 <- cbind(GroupID94,RoleID94,Choices94)
Choices_94 <- Choices_94[order(GroupID94),] 
Choices_95 <- cbind(GroupID95,RoleID95,Choices95)
Choices_95 <- Choices_95[order(GroupID95),] 
Choices_96 <- cbind(GroupID96,RoleID96,Choices96)
Choices_96 <- Choices_96[order(GroupID96),] 
Choices_97 <- cbind(GroupID97,RoleID97,Choices97)
Choices_97 <- Choices_97[order(GroupID97),] 
Choices_98 <- cbind(GroupID98,RoleID98,Choices98)
Choices_98 <- Choices_98[order(GroupID98),] 
#
Decisions_91 <- cbind(GroupID91,RoleID91,Decisions91)
Decisions_91 <- Decisions_91[order(GroupID91),] 
Decisions_92 <- cbind(GroupID92,RoleID92,Decisions92)
Decisions_92 <- Decisions_92[order(GroupID92),] 
Decisions_93 <- cbind(GroupID93,RoleID93,Decisions93)
Decisions_93 <- Decisions_93[order(GroupID93),] 
Decisions_94 <- cbind(GroupID94,RoleID94,Decisions94)
Decisions_94 <- Decisions_94[order(GroupID94),] 
Decisions_95 <- cbind(GroupID95,RoleID95,Decisions95)
Decisions_95 <- Decisions_95[order(GroupID95),] 
Decisions_96 <- cbind(GroupID96,RoleID96,Decisions96)
Decisions_96 <- Decisions_96[order(GroupID96),] 
Decisions_97 <- cbind(GroupID97,RoleID97,Decisions97)
Decisions_97 <- Decisions_97[order(GroupID97),] 
Decisions_98 <- cbind(GroupID98,RoleID98,Decisions98)
Decisions_98 <- Decisions_98[order(GroupID98),] 
#
# Combine Choices and Decisions
#
RevisionMechanismIUChoices <- data.frame(rbind(Choices_91,Choices_92,
                                               Choices_93,Choices_94,
                                               Choices_95,Choices_96,
                                               Choices_97,Choices_98))
RevisionMechanismIUDecisions <- data.frame(rbind(Decisions_91,Decisions_92,
                                                 Decisions_93,Decisions_94,
                                                 Decisions_95,Decisions_96,
                                                 Decisions_97,Decisions_98))
session2020 <- c(rep(1,6),rep(2,6),rep(3,6),rep(4,6),rep(5,6),rep(6,6),rep(7,6),rep(8,6))
RevisionMechanismIUChoices <- data.frame(cbind(c("Revision Mechanism"),session2020,RevisionMechanismIUChoices), stringsAsFactors = F)
RevisionMechanismIUDecisions <- data.frame(cbind(c("Revision Mechanism"),session2020,RevisionMechanismIUDecisions), stringsAsFactors = F)
#
names(RevisionMechanismIUChoices) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:600))
names(RevisionMechanismIUDecisions) <- c("Treatment","Session", "GroupID", "RoleID", c(1:600))
#
#
# Quiz
Quiz_9 <- cbind(c(GroupID91,GroupID92,GroupID93,GroupID94,
                  GroupID95,GroupID96,GroupID97,GroupID98),
                c(RoleID91,RoleID92,RoleID93,RoleID94,
                  RoleID95,RoleID96,RoleID97,RoleID98),
                rbind(data91[3:8,14:18],data92[3:8,14:18],data93[3:8,14:18],data94[3:8,14:18],
                      data96[3:8,14:18],data97[3:8,14:18],data97[3:8,14:18],data98[3:8,14:18])
)
Quiz_9 <- Quiz_9[order(c(GroupID91,GroupID92,GroupID93,GroupID94,
                         GroupID95,GroupID96,GroupID97,GroupID98)),] 
names(Quiz_9) <- c("Group","Role","Q1", "Q2", "Q3", "Q4", "Q5")
#
# Only payoff relevant decisions Revision Mechanism IU
#
AnswerRM_IU <- matrix(-1,48,10)
#
for(i in 1:10){
  AnswerRM_IU[,i] <- RevisionMechanismIUDecisions[,64 + 60*(i-1)]
}
RevisionMechanismIUAnswers <- data.frame(cbind(RevisionMechanismIUDecisions[,1:4], AnswerRM_IU))
names(RevisionMechanismIUAnswers) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10)) # Payoff Relevant Decisions RM-IU
#
# Add Quiz
RevisionMechanismIUAnswers$Quiz <- rowSums(data.frame(Quiz_9$Q1 == .42,Quiz_9$Q2 == .5,
                                                    Quiz_9$Q3 == .62,Quiz_9$Q4 == .82,
                                                    Quiz_9$Q5 == .74) )
#
# RM IU
survey91 <- cbind(GroupID91,t(SurveyData91[c(3:7),-c(1)]))
survey92 <- cbind(GroupID92,t(SurveyData92[c(3:7),-c(1)]))
survey93 <- cbind(GroupID93,t(SurveyData93[c(3:7),-c(1)]))
survey94 <- cbind(GroupID94,t(SurveyData94[c(3:7),-c(1)]))
survey95 <- cbind(GroupID95,t(SurveyData95[c(3:7),-c(1)]))
survey96 <- cbind(GroupID96,t(SurveyData96[c(3:7),-c(1)]))
survey97 <- cbind(GroupID97,t(SurveyData97[c(3:7),-c(1)]))
survey98 <- cbind(GroupID98,t(SurveyData98[c(3:7),-c(1)]))

survey91 <- survey91[order(GroupID91),] 
survey92 <- survey92[order(GroupID92),] 
survey93 <- survey93[order(GroupID93),] 
survey94 <- survey94[order(GroupID94),] 
survey95 <- survey95[order(GroupID95),] 
survey96 <- survey96[order(GroupID96),] 
survey97 <- survey97[order(GroupID97),] 
survey98 <- survey98[order(GroupID98),] 
survey9 <- data.frame(rbind(survey91,survey92,survey93,survey94,
                            survey95,survey96,survey97,survey98))
names(survey9) <- c("Group", "Gender", "Major1", "Major2", "GPA", "GameTheory")
#
RevisionMechanismIUAnswers <- data.frame(RevisionMechanismIUAnswers,survey9[,-c(1)])
#
###########################
# REVISION MECHANISM VHBB #
###########################
#
# Create a data frame for each subject and every second as columns (for relevant treatments)
# 
Choices101 <- matrix(-1,6,600)
Choices102 <- matrix(-1,6,600)
Choices103 <- matrix(-1,6,600)
Choices104 <- matrix(-1,6,600)
Choices105 <- matrix(-1,6,600)
Choices106 <- matrix(-1,6,600)
Choices107 <- matrix(-1,6,600)
Choices108 <- matrix(-1,6,600)
#
columnChoice <- 787 # First column that choice appears
rowChoice <- 75-2 # Row when second choice appears 
#
for(r in 1:10){
  for(i in 1:6){
    # Session 1 
    auxi101 <- data101[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean101 <- numeric(ncol(auxi101))
    for (k in 1:ncol(auxi101)){
      kt101 <- auxi101[1,k]
      aux_clean101[k] <- as.numeric(kt101)
    }
    Choices101[i,((r-1)*60 +1):(r*60) ] <- aux_clean101
    # Session 2 
    auxi102 <- data102[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean102 <- numeric(ncol(auxi102))
    for (k in 1:ncol(auxi102)){
      kt102 <- auxi102[1,k]
      aux_clean102[k] <- as.numeric(kt102)
    }
    Choices102[i,((r-1)*60 +1):(r*60) ] <- aux_clean102
    # Session 3 
    auxi103 <- data103[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean103 <- numeric(ncol(auxi103))
    for (k in 1:ncol(auxi103)){
      kt103 <- auxi103[1,k]
      aux_clean103[k] <- as.numeric(kt103)
    }
    Choices103[i,((r-1)*60 +1):(r*60) ] <- aux_clean103
    # Session 4
    auxi104 <- data104[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean104 <- numeric(ncol(auxi104))
    for (k in 1:ncol(auxi104)){
      kt104 <- auxi104[1,k]
      aux_clean104[k] <- as.numeric(kt104)
    }
    Choices104[i,((r-1)*60 +1):(r*60) ] <- aux_clean104
    # Session 5
    auxi105 <- data105[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean105 <- numeric(ncol(auxi105))
    for (k in 1:ncol(auxi105)){
      kt105 <- auxi105[1,k]
      aux_clean105[k] <- as.numeric(kt105)
    }
    Choices105[i,((r-1)*60 +1):(r*60) ] <- aux_clean105
    # Session 6
    auxi106 <- data106[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean106 <- numeric(ncol(auxi106))
    for (k in 1:ncol(auxi106)){
      kt106 <- auxi106[1,k]
      aux_clean106[k] <- as.numeric(kt106)
    }
    Choices106[i,((r-1)*60 +1):(r*60) ] <- aux_clean106
    # Session 7
    auxi107 <- data107[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean107 <- numeric(ncol(auxi107))
    for (k in 1:ncol(auxi107)){
      kt107 <- auxi107[1,k]
      aux_clean107[k] <- as.numeric(kt107)
    }
    Choices107[i,((r-1)*60 +1):(r*60) ] <- aux_clean107
    # Session 8
    auxi108 <- data108[1 + (r-1)*rowChoice,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean108 <- numeric(ncol(auxi108))
    for (k in 1:ncol(auxi108)){
      kt108 <- auxi108[1,k]
      aux_clean108[k] <- as.numeric(kt108)
    }
    Choices108[i,((r-1)*60 +1):(r*60) ] <- aux_clean108
  }
}
#
# Group ID and Role ID
#
#
# Group ID and Role ID
#
GroupID101 <- as.numeric(data101[3:8,10]) + 8
GroupID102 <- as.numeric(data102[3:8,10]) + 9
GroupID103 <- as.numeric(data103[3:8,10]) + 10
GroupID104 <- as.numeric(data104[3:8,10]) + 11
GroupID105 <- as.numeric(data105[3:8,10]) + 12
GroupID106 <- as.numeric(data106[3:8,10]) + 13
GroupID107 <- as.numeric(data107[3:8,10]) + 14
GroupID108 <- as.numeric(data108[3:8,10]) + 15
#
RoleID101 <- as.numeric(data101[3:8,12])
RoleID102 <- as.numeric(data102[3:8,12])
RoleID103 <- as.numeric(data103[3:8,12])
RoleID104 <- as.numeric(data104[3:8,12])
RoleID105 <- as.numeric(data105[3:8,12])
RoleID106 <- as.numeric(data106[3:8,12])
RoleID107 <- as.numeric(data107[3:8,12])
RoleID108 <- as.numeric(data108[3:8,12])
#
Decisions101 <- matrix(-1,6,600)
Decisions102 <- matrix(-1,6,600)
Decisions103 <- matrix(-1,6,600)
Decisions104 <- matrix(-1,6,600)
Decisions105 <- matrix(-1,6,600)
Decisions106 <- matrix(-1,6,600)
Decisions107 <- matrix(-1,6,600)
Decisions108 <- matrix(-1,6,600)
#
#
columnDecision <- 1147 # First column that decision appears
rowDecision <- 75-2  # Row when second decision appears 
#
for(r in 1:10){
  for(i in 1:6){
    # Session 1 
    auxi101 <- data101[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean101 <- numeric(ncol(auxi101))
    for (k in 1:ncol(auxi101)){
      kt101 <- auxi101[1,k]
      aux_clean101[k] <- as.numeric(kt101)
    }
    Decisions101[i,((r-1)*60 +1):(r*60) ] <- aux_clean101
    # Session 2 
    auxi102 <- data102[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean102 <- numeric(ncol(auxi102))
    for (k in 1:ncol(auxi102)){
      kt102 <- auxi102[1,k]
      aux_clean102[k] <- as.numeric(kt102)
    }
    Decisions102[i,((r-1)*60 +1):(r*60) ] <- aux_clean102
    # Session 3 
    auxi103 <- data103[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean103 <- numeric(ncol(auxi103))
    for (k in 1:ncol(auxi103)){
      kt103 <- auxi103[1,k]
      aux_clean103[k] <- as.numeric(kt103)
    }
    Decisions103[i,((r-1)*60 +1):(r*60) ] <- aux_clean103
    # Session 4 
    auxi104 <- data104[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean104 <- numeric(ncol(auxi104))
    for (k in 1:ncol(auxi104)){
      kt104 <- auxi104[1,k]
      aux_clean104[k] <- as.numeric(kt104)
    }
    Decisions104[i,((r-1)*60 +1):(r*60) ] <- aux_clean104
    # Session 5
    auxi105 <- data105[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean105 <- numeric(ncol(auxi105))
    for (k in 1:ncol(auxi105)){
      kt105 <- auxi105[1,k]
      aux_clean105[k] <- as.numeric(kt105)
    }
    Decisions105[i,((r-1)*60 +1):(r*60) ] <- aux_clean105
    # Session 6
    auxi106 <- data106[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean106 <- numeric(ncol(auxi106))
    for (k in 1:ncol(auxi106)){
      kt106 <- auxi106[1,k]
      aux_clean106[k] <- as.numeric(kt106)
    }
    Decisions106[i,((r-1)*60 +1):(r*60) ] <- aux_clean106
    # Session 7
    auxi107 <- data107[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean107 <- numeric(ncol(auxi107))
    for (k in 1:ncol(auxi107)){
      kt107 <- auxi107[1,k]
      aux_clean107[k] <- as.numeric(kt107)
    }
    Decisions107[i,((r-1)*60 +1):(r*60) ] <- aux_clean107
    # Session 8
    auxi108 <- data108[1 + (r-1)*rowDecision,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean108 <- numeric(ncol(auxi108))
    for (k in 1:ncol(auxi108)){
      kt108 <- auxi108[1,k]
      aux_clean108[k] <- as.numeric(kt108)
    }
    Decisions108[i,((r-1)*60 +1):(r*60) ] <- aux_clean108
  }
}
#
# Order Choices and Decisions by GroupID and then Combine all sessions
#
Choices_101 <- cbind(GroupID101,RoleID101,Choices101)
Choices_101 <- Choices_101[order(GroupID101),] 
Choices_102 <- cbind(GroupID102,RoleID102,Choices102)
Choices_102 <- Choices_102[order(GroupID102),] 
Choices_103 <- cbind(GroupID103,RoleID103,Choices103)
Choices_103 <- Choices_103[order(GroupID103),] 
Choices_104 <- cbind(GroupID104,RoleID104,Choices104)
Choices_104 <- Choices_104[order(GroupID104),] 
Choices_105 <- cbind(GroupID105,RoleID105,Choices105)
Choices_105 <- Choices_105[order(GroupID105),] 
Choices_106 <- cbind(GroupID106,RoleID106,Choices106)
Choices_106 <- Choices_106[order(GroupID106),] 
Choices_107 <- cbind(GroupID107,RoleID107,Choices107)
Choices_107 <- Choices_107[order(GroupID107),] 
Choices_108 <- cbind(GroupID108,RoleID108,Choices108)
Choices_108 <- Choices_108[order(GroupID108),] 
#
Decisions_101 <- cbind(GroupID101,RoleID101,Decisions101)
Decisions_101 <- Decisions_101[order(GroupID101),] 
Decisions_102 <- cbind(GroupID102,RoleID102,Decisions102)
Decisions_102 <- Decisions_102[order(GroupID102),] 
Decisions_103 <- cbind(GroupID103,RoleID103,Decisions103)
Decisions_103 <- Decisions_103[order(GroupID103),] 
Decisions_104 <- cbind(GroupID104,RoleID104,Decisions104)
Decisions_104 <- Decisions_104[order(GroupID104),] 
Decisions_105 <- cbind(GroupID105,RoleID105,Decisions105)
Decisions_105 <- Decisions_105[order(GroupID105),] 
Decisions_106 <- cbind(GroupID106,RoleID106,Decisions106)
Decisions_106 <- Decisions_106[order(GroupID106),] 
Decisions_107 <- cbind(GroupID107,RoleID107,Decisions107)
Decisions_107 <- Decisions_107[order(GroupID107),] 
Decisions_108 <- cbind(GroupID108,RoleID108,Decisions108)
Decisions_108 <- Decisions_108[order(GroupID108),] 
#
# Combine Choices and Decisions
#
RevisionMechanismVHBBChoices <- data.frame(rbind(Choices_101,Choices_102,
                                                 Choices_103,Choices_104,
                                                 Choices_105,Choices_106,
                                                 Choices_107,Choices_108))
RevisionMechanismVHBBDecisions <- data.frame(rbind(Decisions_101,Decisions_102,
                                                   Decisions_103,Decisions_104,
                                                   Decisions_105,Decisions_106,
                                                   Decisions_107,Decisions_108))
session2020 <- c(rep(1,6),rep(2,6),rep(3,6),rep(4,6),rep(5,6),rep(6,6),rep(7,6),rep(8,6))
RevisionMechanismVHBBChoices <- data.frame(cbind(c("Revision Mechanism VHBB"),session2020,RevisionMechanismVHBBChoices), stringsAsFactors = F)
RevisionMechanismVHBBDecisions <- data.frame(cbind(c("Revision Mechanism VHBB"),session2020,RevisionMechanismVHBBDecisions), stringsAsFactors = F)
#
names(RevisionMechanismVHBBChoices) <- c("Treatment","Session", "GroupID", "RoleID", c(1:600))
names(RevisionMechanismVHBBDecisions) <- c("Treatment","Session", "GroupID", "RoleID", c(1:600))
#
#
# Quiz
Quiz_10 <- cbind(c(GroupID101,GroupID102,GroupID103,GroupID104,
                   GroupID105,GroupID106,GroupID107,GroupID108),
                 c(RoleID101,RoleID102,RoleID103,RoleID104,
                   RoleID105,RoleID106,RoleID107,RoleID108),
                 rbind(data101[3:8,14:18],data102[3:8,14:18],data103[3:8,14:18],data104[3:8,14:18],
                       data106[3:8,14:18],data107[3:8,14:18],data107[3:8,14:18],data108[3:8,14:18])
)
Quiz_10 <- Quiz_10[order(c(GroupID101,GroupID102,GroupID103,GroupID104,
                           GroupID105,GroupID106,GroupID107,GroupID108)),] 
names(Quiz_10) <- c("Group","Role","Q1", "Q2", "Q3", "Q4", "Q5")

#
# Only payoff relevant decisions Revision Mechanism VHBB
#
AnswerRM_VHBB <- matrix(-1,48,10)
#
for(i in 1:10){
  AnswerRM_VHBB[,i] <- RevisionMechanismVHBBDecisions[,64 + 60*(i-1)]
}
RevisionMechanismVHBBAnswers <- data.frame(cbind(RevisionMechanismVHBBDecisions[,1:4], AnswerRM_VHBB))
names(RevisionMechanismVHBBAnswers) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10)) # Payoff Relevant Decisions RM-VHBB
#
# Add Quiz
RevisionMechanismVHBBAnswers$Quiz <- rowSums(data.frame(Quiz_10$Q1 == .6,Quiz_10$Q2 == .8,
                                                    Quiz_10$Q3 == .8,Quiz_10$Q4 == 1,
                                                    Quiz_10$Q5 == .8) )
# Add survey 
# RM VHBB
survey101 <- cbind(GroupID101,t(SurveyData101[c(3:7),-c(1)]))
survey102 <- cbind(GroupID102,t(SurveyData102[c(3:7),-c(1)]))
survey103 <- cbind(GroupID103,t(SurveyData103[c(3:7),-c(1)]))
survey104 <- cbind(GroupID104,t(SurveyData104[c(3:7),-c(1)]))
survey105 <- cbind(GroupID105,t(SurveyData105[c(3:7),-c(1)]))
survey106 <- cbind(GroupID106,t(SurveyData106[c(3:7),-c(1)]))
survey107 <- cbind(GroupID107,t(SurveyData107[c(3:7),-c(1)]))
survey108 <- cbind(GroupID108,t(SurveyData108[c(3:7),-c(1)]))

survey101 <- survey101[order(GroupID101),] 
survey102 <- survey102[order(GroupID102),] 
survey103 <- survey103[order(GroupID103),] 
survey104 <- survey104[order(GroupID104),] 
survey105 <- survey105[order(GroupID105),] 
survey106 <- survey106[order(GroupID106),] 
survey107 <- survey107[order(GroupID107),] 
survey108 <- survey108[order(GroupID108),] 
survey10 <- data.frame(rbind(survey101,survey102,survey103,survey104,
                             survey105,survey106,survey107,survey108))
names(survey10) <- c("Group", "Gender", "Major1", "Major2", "GPA", "GameTheory")
#
RevisionMechanismVHBBAnswers <- data.frame(RevisionMechanismVHBBAnswers,survey10[,-c(1)])
#
#####################################################
#          Richer Revision Cheap Talk               #
#####################################################
#
# Create a data frame for each subject and every second as columns (for relevant treatments)
# 
Choices111 <- matrix(-1,6,600)
Choices112 <- matrix(-1,6,600)
Choices113 <- matrix(-1,6,600)
Choices114 <- matrix(-1,6,600)
Choices115 <- matrix(-1,6,600)
Choices116 <- matrix(-1,6,600)
Choices117 <- matrix(-1,6,600)
Choices118 <- matrix(-1,6,600)
#
ChoicesG111 <- matrix(-1,6,600)
ChoicesG112 <- matrix(-1,6,600)
ChoicesG113 <- matrix(-1,6,600)
ChoicesG114 <- matrix(-1,6,600)
ChoicesG115 <- matrix(-1,6,600)
ChoicesG116 <- matrix(-1,6,600)
ChoicesG117 <- matrix(-1,6,600)
ChoicesG118 <- matrix(-1,6,600)
#
columnChoice <- 1163 # First column that choice appears
columnChoiceG <- 1523 # First column that choice appears
#
for(r in 1:10){
  for(i in 1:6){
    # Session 1 
    auxi111 <- data111[1 + (r-1)*73,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean111 <- numeric(ncol(auxi111))
    for (k in 1:ncol(auxi111)){
      kt111 <- auxi111[1,k]
      aux_clean111[k] <- as.numeric(kt111)
    }
    Choices111[i,((r-1)*60 +1):(r*60) ] <- aux_clean111
    # Session 2 
    auxi112 <- data112[1 + (r-1)*73,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean112 <- numeric(ncol(auxi112))
    for (k in 1:ncol(auxi112)){
      kt112 <- auxi112[1,k]
      aux_clean112[k] <- as.numeric(kt112)
    }
    Choices112[i,((r-1)*60 +1):(r*60) ] <- aux_clean112
    # Session 3 
    auxi113 <- data113[1 + (r-1)*73,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean113 <- numeric(ncol(auxi113))
    for (k in 1:ncol(auxi113)){
      kt113 <- auxi113[1,k]
      aux_clean113[k] <- as.numeric(kt113)
    }
    Choices113[i,((r-1)*60 +1):(r*60) ] <- aux_clean113
    # Session 4
    auxi114 <- data114[1 + (r-1)*73,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean114 <- numeric(ncol(auxi114))
    for (k in 1:ncol(auxi114)){
      kt114 <- auxi114[1,k]
      aux_clean114[k] <- as.numeric(kt114)
    }
    Choices114[i,((r-1)*60 +1):(r*60) ] <- aux_clean114
    # Session 5
    auxi115 <- data115[1 + (r-1)*73,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean115 <- numeric(ncol(auxi115))
    for (k in 1:ncol(auxi115)){
      kt115 <- auxi115[1,k]
      aux_clean115[k] <- as.numeric(kt115)
    }
    Choices115[i,((r-1)*60 +1):(r*60) ] <- aux_clean115
    # Session 6
    auxi116 <- data116[1 + (r-1)*73,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean116 <- numeric(ncol(auxi116))
    for (k in 1:ncol(auxi116)){
      kt116 <- auxi116[1,k]
      aux_clean116[k] <- as.numeric(kt116)
    }
    Choices116[i,((r-1)*60 +1):(r*60) ] <- aux_clean116
    # Session 7
    auxi117 <- data117[1 + (r-1)*73,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean117 <- numeric(ncol(auxi117))
    for (k in 1:ncol(auxi117)){
      kt117 <- auxi117[1,k]
      aux_clean117[k] <- as.numeric(kt117)
    }
    Choices117[i,((r-1)*60 +1):(r*60) ] <- aux_clean117
    # Session 8
    auxi118 <- data118[1 + (r-1)*73,(columnChoice+60*(i-1)):(columnChoice+60*(i)-1)]
    aux_clean118 <- numeric(ncol(auxi118))
    for (k in 1:ncol(auxi118)){
      kt118 <- auxi118[1,k]
      aux_clean118[k] <- as.numeric(kt118)
    }
    Choices118[i,((r-1)*60 +1):(r*60) ] <- aux_clean118
  }
}
#
for(r in 1:10){
  for(i in 1:6){
    # Session 1 
    auxiG111 <- data111[1 + (r-1)*73,(columnChoiceG+60*(i-1)):(columnChoiceG+60*(i)-1)]
    aux_cleanG111 <- numeric(ncol(auxiG111))
    for (k in 1:ncol(auxiG111)){
      ktG111 <- auxiG111[1,k]
      aux_cleanG111[k] <- as.numeric(ktG111)
    }
    ChoicesG111[i,((r-1)*60 +1):(r*60) ] <- aux_cleanG111
    # Session 2 
    auxiG112 <- data112[1 + (r-1)*73,(columnChoiceG+60*(i-1)):(columnChoiceG+60*(i)-1)]
    aux_cleanG112 <- numeric(ncol(auxiG112))
    for (k in 1:ncol(auxiG112)){
      ktG112 <- auxiG112[1,k]
      aux_cleanG112[k] <- as.numeric(ktG112)
    }
    ChoicesG112[i,((r-1)*60 +1):(r*60) ] <- aux_cleanG112
    # Session 3 
    auxiG113 <- data113[1 + (r-1)*73,(columnChoiceG+60*(i-1)):(columnChoiceG+60*(i)-1)]
    aux_cleanG113 <- numeric(ncol(auxiG113))
    for (k in 1:ncol(auxiG113)){
      ktG113 <- auxiG113[1,k]
      aux_cleanG113[k] <- as.numeric(ktG113)
    }
    ChoicesG113[i,((r-1)*60 +1):(r*60) ] <- aux_cleanG113
    # Session 4
    auxiG114 <- data114[1 + (r-1)*73,(columnChoiceG+60*(i-1)):(columnChoiceG+60*(i)-1)]
    aux_cleanG114 <- numeric(ncol(auxiG114))
    for (k in 1:ncol(auxiG114)){
      ktG114 <- auxiG114[1,k]
      aux_cleanG114[k] <- as.numeric(ktG114)
    }
    ChoicesG114[i,((r-1)*60 +1):(r*60) ] <- aux_cleanG114
    # Session 5 
    auxiG115 <- data115[1 + (r-1)*73,(columnChoiceG+60*(i-1)):(columnChoiceG+60*(i)-1)]
    aux_cleanG115 <- numeric(ncol(auxiG115))
    for (k in 1:ncol(auxiG115)){
      ktG115 <- auxiG115[1,k]
      aux_cleanG115[k] <- as.numeric(ktG115)
    }
    ChoicesG115[i,((r-1)*60 +1):(r*60) ] <- aux_cleanG115
    # Session 6
    auxiG116 <- data116[1 + (r-1)*73,(columnChoiceG+60*(i-1)):(columnChoiceG+60*(i)-1)]
    aux_cleanG116 <- numeric(ncol(auxiG116))
    for (k in 1:ncol(auxiG116)){
      ktG116 <- auxiG116[1,k]
      aux_cleanG116[k] <- as.numeric(ktG116)
    }
    ChoicesG116[i,((r-1)*60 +1):(r*60) ] <- aux_cleanG116
    # Session 7
    auxiG117 <- data117[1 + (r-1)*73,(columnChoiceG+60*(i-1)):(columnChoiceG+60*(i)-1)]
    aux_cleanG117 <- numeric(ncol(auxiG117))
    for (k in 1:ncol(auxiG117)){
      ktG117 <- auxiG117[1,k]
      aux_cleanG117[k] <- as.numeric(ktG117)
    }
    ChoicesG117[i,((r-1)*60 +1):(r*60) ] <- aux_cleanG117
    # Session 8
    auxiG118 <- data118[1 + (r-1)*73,(columnChoiceG+60*(i-1)):(columnChoiceG+60*(i)-1)]
    aux_cleanG118 <- numeric(ncol(auxiG118))
    for (k in 1:ncol(auxiG118)){
      ktG118 <- auxiG118[1,k]
      aux_cleanG118[k] <- as.numeric(ktG118)
    }
    ChoicesG118[i,((r-1)*60 +1):(r*60) ] <- aux_cleanG118
  }
}
#
# Group ID and Role ID
#
GroupID111 <- as.numeric(data111[3:8,10])
GroupID112 <- as.numeric(data112[3:8,10]) + 1
GroupID113 <- as.numeric(data113[3:8,10]) + 2
GroupID114 <- as.numeric(data114[3:8,10]) + 3
GroupID115 <- as.numeric(data115[3:8,10]) + 4
GroupID116 <- as.numeric(data116[3:8,10]) + 5
GroupID117 <- as.numeric(data117[3:8,10]) + 6
GroupID118 <- as.numeric(data118[3:8,10]) + 7
#
RoleID111 <- as.numeric(data111[3:8,12])
RoleID112 <- as.numeric(data112[3:8,12])
RoleID113 <- as.numeric(data113[3:8,12])
RoleID114 <- as.numeric(data114[3:8,12])
RoleID115 <- as.numeric(data115[3:8,12])
RoleID116 <- as.numeric(data116[3:8,12])
RoleID117 <- as.numeric(data117[3:8,12])
RoleID118 <- as.numeric(data118[3:8,12])
#
Decisions111 <- matrix(-1,6,600)
Decisions112 <- matrix(-1,6,600)
Decisions113 <- matrix(-1,6,600)
Decisions114 <- matrix(-1,6,600)
Decisions115 <- matrix(-1,6,600)
Decisions116 <- matrix(-1,6,600)
Decisions117 <- matrix(-1,6,600)
Decisions118 <- matrix(-1,6,600)
#
columnDecision <- 1883 # First column that decision appears
columnDecisionG <- 2243 # First column that decision appears

#
for(r in 1:10){
  for(i in 1:6){
    # Session 1 
    auxi111 <- data111[1 + (r-1)*73,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean111 <- numeric(ncol(auxi111))
    for (k in 1:ncol(auxi111)){
      kt111 <- auxi111[1,k]
      aux_clean111[k] <- as.numeric(kt111)
    }
    Decisions111[i,((r-1)*60 +1):(r*60) ] <- aux_clean111
    # Session 2 
    auxi112 <- data112[1 + (r-1)*73,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean112 <- numeric(ncol(auxi112))
    for (k in 1:ncol(auxi112)){
      kt112 <- auxi112[1,k]
      aux_clean112[k] <- as.numeric(kt112)
    }
    Decisions112[i,((r-1)*60 +1):(r*60) ] <- aux_clean112
    # Session 3 
    auxi113 <- data113[1 + (r-1)*73,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean113 <- numeric(ncol(auxi113))
    for (k in 1:ncol(auxi113)){
      kt113 <- auxi113[1,k]
      aux_clean113[k] <- as.numeric(kt113)
    }
    Decisions113[i,((r-1)*60 +1):(r*60) ] <- aux_clean113
    # Session 4
    auxi114 <- data114[1 + (r-1)*73,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean114 <- numeric(ncol(auxi114))
    for (k in 1:ncol(auxi114)){
      kt114 <- auxi114[1,k]
      aux_clean114[k] <- as.numeric(kt114)
    }
    Decisions114[i,((r-1)*60 +1):(r*60) ] <- aux_clean114
    # Session 5
    auxi115 <- data115[1 + (r-1)*73,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean115 <- numeric(ncol(auxi115))
    for (k in 1:ncol(auxi115)){
      kt115 <- auxi115[1,k]
      aux_clean115[k] <- as.numeric(kt115)
    }
    Decisions115[i,((r-1)*60 +1):(r*60) ] <- aux_clean115
    # Session 6
    auxi116 <- data116[1 + (r-1)*73,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean116 <- numeric(ncol(auxi116))
    for (k in 1:ncol(auxi116)){
      kt116 <- auxi116[1,k]
      aux_clean116[k] <- as.numeric(kt116)
    }
    Decisions116[i,((r-1)*60 +1):(r*60) ] <- aux_clean116
    # Session 7
    auxi117 <- data117[1 + (r-1)*73,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean117 <- numeric(ncol(auxi117))
    for (k in 1:ncol(auxi117)){
      kt117 <- auxi117[1,k]
      aux_clean117[k] <- as.numeric(kt117)
    }
    Decisions117[i,((r-1)*60 +1):(r*60) ] <- aux_clean117
    # Session 8
    auxi118 <- data118[1 + (r-1)*73,(columnDecision+60*(i-1)):(columnDecision+60*(i)-1)]
    aux_clean118 <- numeric(ncol(auxi118))
    for (k in 1:ncol(auxi118)){
      kt118 <- auxi118[1,k]
      aux_clean118[k] <- as.numeric(kt118)
    }
    Decisions118[i,((r-1)*60 +1):(r*60) ] <- aux_clean118
  }
}
#
# Order Choices and Decisions by GroupID and then Combine all sessions
#
Choices_111 <- cbind(GroupID111,RoleID111,Choices111)
Choices_111 <- Choices_111[order(GroupID111),] 
Choices_112 <- cbind(GroupID112,RoleID112,Choices112)
Choices_112 <- Choices_112[order(GroupID112),] 
Choices_113 <- cbind(GroupID113,RoleID113,Choices113)
Choices_113 <- Choices_113[order(GroupID113),] 
Choices_114 <- cbind(GroupID114,RoleID114,Choices114)
Choices_114 <- Choices_114[order(GroupID114),] 
Choices_115 <- cbind(GroupID115,RoleID115,Choices115)
Choices_115 <- Choices_115[order(GroupID115),] 
Choices_116 <- cbind(GroupID116,RoleID116,Choices116)
Choices_116 <- Choices_116[order(GroupID116),] 
Choices_117 <- cbind(GroupID117,RoleID117,Choices117)
Choices_117 <- Choices_117[order(GroupID117),] 
Choices_118 <- cbind(GroupID118,RoleID118,Choices118)
Choices_118 <- Choices_118[order(GroupID118),] 
#
Decisions_111 <- cbind(GroupID111,RoleID111,Decisions111)
Decisions_111 <- Decisions_111[order(GroupID111),] 
Decisions_112 <- cbind(GroupID112,RoleID112,Decisions112)
Decisions_112 <- Decisions_112[order(GroupID112),] 
Decisions_113 <- cbind(GroupID113,RoleID113,Decisions113)
Decisions_113 <- Decisions_113[order(GroupID113),] 
Decisions_114 <- cbind(GroupID114,RoleID114,Decisions114)
Decisions_114 <- Decisions_114[order(GroupID114),]
Decisions_115 <- cbind(GroupID115,RoleID115,Decisions115)
Decisions_115 <- Decisions_115[order(GroupID115),] 
Decisions_116 <- cbind(GroupID116,RoleID116,Decisions116)
Decisions_116 <- Decisions_116[order(GroupID116),] 
Decisions_117 <- cbind(GroupID117,RoleID117,Decisions117)
Decisions_117 <- Decisions_117[order(GroupID117),] 
Decisions_118 <- cbind(GroupID118,RoleID118,Decisions118)
Decisions_118 <- Decisions_118[order(GroupID118),] 
#
DecisionsG111 <- matrix(-1,6,600)
DecisionsG112 <- matrix(-1,6,600)
DecisionsG113 <- matrix(-1,6,600)
DecisionsG114 <- matrix(-1,6,600)
DecisionsG115 <- matrix(-1,6,600)
DecisionsG116 <- matrix(-1,6,600)
DecisionsG117 <- matrix(-1,6,600)
DecisionsG118 <- matrix(-1,6,600)
#
#
for(r in 1:10){
  for(i in 1:6){
    # Session 1 
    auxiG111 <- data111[1 + (r-1)*73,(columnDecisionG+60*(i-1)):(columnDecisionG+60*(i)-1)]
    aux_cleanG111 <- numeric(ncol(auxiG111))
    for (k in 1:ncol(auxiG111)){
      ktG111 <- auxiG111[1,k]
      aux_cleanG111[k] <- as.numeric(ktG111)
    }
    DecisionsG111[i,((r-1)*60 +1):(r*60) ] <- aux_cleanG111
    # Session 2 
    auxiG112 <- data112[1 + (r-1)*73,(columnDecisionG+60*(i-1)):(columnDecisionG+60*(i)-1)]
    aux_cleanG112 <- numeric(ncol(auxiG112))
    for (k in 1:ncol(auxiG112)){
      ktG112 <- auxiG112[1,k]
      aux_cleanG112[k] <- as.numeric(ktG112)
    }
    DecisionsG112[i,((r-1)*60 +1):(r*60) ] <- aux_cleanG112
    # Session 3 
    auxiG113 <- data113[1 + (r-1)*73,(columnDecisionG+60*(i-1)):(columnDecisionG+60*(i)-1)]
    aux_cleanG113 <- numeric(ncol(auxiG113))
    for (k in 1:ncol(auxiG113)){
      ktG113 <- auxiG113[1,k]
      aux_cleanG113[k] <- as.numeric(ktG113)
    }
    DecisionsG113[i,((r-1)*60 +1):(r*60) ] <- aux_cleanG113
    # Session 4
    auxiG114 <- data114[1 + (r-1)*73,(columnDecisionG+60*(i-1)):(columnDecisionG+60*(i)-1)]
    aux_cleanG114 <- numeric(ncol(auxiG114))
    for (k in 1:ncol(auxiG114)){
      ktG114 <- auxiG114[1,k]
      aux_cleanG114[k] <- as.numeric(ktG114)
    }
    DecisionsG114[i,((r-1)*60 +1):(r*60) ] <- aux_cleanG114
    # Session 5
    auxiG115 <- data115[1 + (r-1)*73,(columnDecisionG+60*(i-1)):(columnDecisionG+60*(i)-1)]
    aux_cleanG115 <- numeric(ncol(auxiG115))
    for (k in 1:ncol(auxiG115)){
      ktG115 <- auxiG115[1,k]
      aux_cleanG115[k] <- as.numeric(ktG115)
    }
    DecisionsG115[i,((r-1)*60 +1):(r*60) ] <- aux_cleanG115
    # Session 6
    auxiG116 <- data116[1 + (r-1)*73,(columnDecisionG+60*(i-1)):(columnDecisionG+60*(i)-1)]
    aux_cleanG116 <- numeric(ncol(auxiG116))
    for (k in 1:ncol(auxiG116)){
      ktG116 <- auxiG116[1,k]
      aux_cleanG116[k] <- as.numeric(ktG116)
    }
    DecisionsG116[i,((r-1)*60 +1):(r*60) ] <- aux_cleanG116
    # Session 7
    auxiG117 <- data117[1 + (r-1)*73,(columnDecisionG+60*(i-1)):(columnDecisionG+60*(i)-1)]
    aux_cleanG117 <- numeric(ncol(auxiG117))
    for (k in 1:ncol(auxiG117)){
      ktG117 <- auxiG117[1,k]
      aux_cleanG117[k] <- as.numeric(ktG117)
    }
    DecisionsG117[i,((r-1)*60 +1):(r*60) ] <- aux_cleanG117
    # Session 8
    auxiG118 <- data118[1 + (r-1)*73,(columnDecisionG+60*(i-1)):(columnDecisionG+60*(i)-1)]
    aux_cleanG118 <- numeric(ncol(auxiG118))
    for (k in 1:ncol(auxiG118)){
      ktG118 <- auxiG118[1,k]
      aux_cleanG118[k] <- as.numeric(ktG118)
    }
    DecisionsG118[i,((r-1)*60 +1):(r*60) ] <- aux_cleanG118
  }
}
#
# Order Choices and Decisions by GroupID and then Combine all sessions
#
ChoicesG_111 <- cbind(GroupID111,RoleID111,Choices111)
ChoicesG_111 <- ChoicesG_111[order(GroupID111),] 
ChoicesG_112 <- cbind(GroupID112,RoleID112,Choices112)
ChoicesG_112 <- ChoicesG_112[order(GroupID112),] 
ChoicesG_113 <- cbind(GroupID113,RoleID113,Choices113)
ChoicesG_113 <- ChoicesG_113[order(GroupID113),] 
ChoicesG_114 <- cbind(GroupID114,RoleID114,Choices114)
ChoicesG_114 <- ChoicesG_114[order(GroupID114),] 
ChoicesG_115 <- cbind(GroupID115,RoleID115,Choices115)
ChoicesG_115 <- ChoicesG_115[order(GroupID115),] 
ChoicesG_116 <- cbind(GroupID116,RoleID116,Choices116)
ChoicesG_116 <- ChoicesG_116[order(GroupID116),] 
ChoicesG_117 <- cbind(GroupID117,RoleID117,Choices117)
ChoicesG_117 <- ChoicesG_117[order(GroupID117),] 
ChoicesG_118 <- cbind(GroupID118,RoleID118,Choices118)
ChoicesG_118 <- ChoicesG_118[order(GroupID118),] 
#
DecisionsG_111 <- cbind(GroupID111,RoleID111,DecisionsG111)
DecisionsG_111 <- DecisionsG_111[order(GroupID111),] 
DecisionsG_112 <- cbind(GroupID112,RoleID112,DecisionsG112)
DecisionsG_112 <- DecisionsG_112[order(GroupID112),] 
DecisionsG_113 <- cbind(GroupID113,RoleID113,DecisionsG113)
DecisionsG_113 <- DecisionsG_113[order(GroupID113),] 
DecisionsG_114 <- cbind(GroupID114,RoleID114,DecisionsG114)
DecisionsG_114 <- DecisionsG_114[order(GroupID114),]
DecisionsG_115 <- cbind(GroupID115,RoleID115,DecisionsG115)
DecisionsG_115 <- DecisionsG_115[order(GroupID115),] 
DecisionsG_116 <- cbind(GroupID116,RoleID116,DecisionsG116)
DecisionsG_116 <- DecisionsG_116[order(GroupID116),]
DecisionsG_117 <- cbind(GroupID117,RoleID117,DecisionsG117)
DecisionsG_117 <- DecisionsG_117[order(GroupID117),] 
DecisionsG_118 <- cbind(GroupID118,RoleID118,DecisionsG118)
DecisionsG_118 <- DecisionsG_118[order(GroupID118),]
#
# Combine Choices and Decisions
#
RicherRevisionCheapTalkChoices <- data.frame(rbind(Choices_111,Choices_112,
                                                   Choices_113,Choices_114,
                                                   Choices_115,Choices_116,
                                                   Choices_117,Choices_118))
RicherRevisionCheapTalkDecisions <- data.frame(rbind(Decisions_111,Decisions_112,
                                                     Decisions_113,Decisions_114,
                                                     Decisions_115,Decisions_116,
                                                     Decisions_117,Decisions_118))
session <- c(rep(1,6),rep(2,6),rep(3,6),rep(4,6),rep(5,6),rep(6,6),rep(7,6),rep(8,6))
RicherRevisionCheapTalkChoices <- data.frame(cbind(c("Richer Revision Cheap Talk"),session,RicherRevisionCheapTalkChoices))
RicherRevisionCheapTalkDecisions <- data.frame(cbind(c("Richer Revision Cheap Talk"),session,RicherRevisionCheapTalkDecisions))

names(RicherRevisionCheapTalkChoices) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:600))
names(RicherRevisionCheapTalkDecisions) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:600))
#
# Group
#
RicherRevisionCheapTalkChoicesG <- data.frame(rbind(ChoicesG_111,ChoicesG_112,
                                                    ChoicesG_113,ChoicesG_114,
                                                    ChoicesG_115,ChoicesG_116,
                                                    ChoicesG_117,ChoicesG_118))
RicherRevisionCheapTalkDecisionsG <- data.frame(rbind(DecisionsG_111,DecisionsG_112,
                                                      DecisionsG_113,DecisionsG_114,
                                                      DecisionsG_115,DecisionsG_116,
                                                      DecisionsG_117,DecisionsG_118))
session <- c(rep(1,6),rep(2,6),rep(3,6),rep(4,6),rep(5,6),rep(6,6),rep(7,6),rep(8,6))

RicherRevisionCheapTalkChoicesG <- data.frame(cbind(c("Richer Revision Cheap Talk G"),session,RicherRevisionCheapTalkChoicesG))
RicherRevisionCheapTalkDecisionsG <- data.frame(cbind(c("Richer Revision Cheap Talk G"),session,RicherRevisionCheapTalkDecisionsG))

names(RicherRevisionCheapTalkChoicesG) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:600))
names(RicherRevisionCheapTalkDecisionsG) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:600))
#
#
# Quiz
Quiz_11 <- cbind(c(GroupID111,GroupID112,GroupID113,GroupID114,
                   GroupID115,GroupID116,GroupID117,GroupID118),
                 c(RoleID111,RoleID112,RoleID113,RoleID114,
                   RoleID115,RoleID116,RoleID117,RoleID118),
                 rbind(data111[3:8,14:18],data112[3:8,14:18],data113[3:8,14:18],data114[3:8,14:18],
                       data116[3:8,14:18],data117[3:8,14:18],data117[3:8,14:18],data118[3:8,14:18])
)
Quiz_11 <- Quiz_11[order(c(GroupID111,GroupID112,GroupID113,GroupID114,
                           GroupID115,GroupID116,GroupID117,GroupID118)),] 
names(Quiz_11) <- c("Group","Role","Q1", "Q2", "Q3", "Q4", "Q5")
#
#######################################################
# Revision Cheap Talk ONLY Payoff Relevant Decisions  #
#######################################################
Answer111 <- matrix(-1,6,10)
Answer112 <- matrix(-1,6,10)
Answer113 <- matrix(-1,6,10)
Answer114 <- matrix(-1,6,10)
Answer115 <- matrix(-1,6,10)
Answer116 <- matrix(-1,6,10)
Answer117 <- matrix(-1,6,10)
Answer118 <- matrix(-1,6,10)
#
for(i in 1:10){
  auxi111 <- data111[((6*(i-1) + 3*i + 64*(i-1)):(6*i + 3*i + 64*(i-1) - 1)),35]
  auxi112 <- data112[((6*(i-1) + 3*i + 64*(i-1)):(6*i + 3*i + 64*(i-1) - 1)),35]
  auxi113 <- data113[((6*(i-1) + 3*i + 64*(i-1)):(6*i + 3*i + 64*(i-1) - 1)),35]
  auxi114 <- data114[((6*(i-1) + 3*i + 64*(i-1)):(6*i + 3*i + 64*(i-1) - 1)),35]
  auxi115 <- data115[((6*(i-1) + 3*i + 64*(i-1)):(6*i + 3*i + 64*(i-1) - 1)),35]
  auxi116 <- data116[((6*(i-1) + 3*i + 64*(i-1)):(6*i + 3*i + 64*(i-1) - 1)),35]
  auxi117 <- data117[((6*(i-1) + 3*i + 64*(i-1)):(6*i + 3*i + 64*(i-1) - 1)),35]
  auxi118 <- data118[((6*(i-1) + 3*i + 64*(i-1)):(6*i + 3*i + 64*(i-1) - 1)),35]
  
  Answer111[,i] <- as.numeric(auxi111)
  Answer112[,i] <- as.numeric(auxi112)
  Answer113[,i] <- as.numeric(auxi113)
  Answer114[,i] <- as.numeric(auxi114)
  Answer115[,i] <- as.numeric(auxi115)
  Answer116[,i] <- as.numeric(auxi116)
  Answer117[,i] <- as.numeric(auxi117)
  Answer118[,i] <- as.numeric(auxi118)
}
#
# Order Decisions by GroupID and then Combine all sessions
#
Answer_111 <- cbind(GroupID111,RoleID111,Answer111)
Answer_111 <- Answer_111[order(GroupID111),] 
Answer_112 <- cbind(GroupID112,RoleID112,Answer112)
Answer_112 <- Answer_112[order(GroupID112),] 
Answer_113 <- cbind(GroupID113,RoleID113,Answer113)
Answer_113 <- Answer_113[order(GroupID113),]  
Answer_114 <- cbind(GroupID114,RoleID114,Answer114)
Answer_114 <- Answer_114[order(GroupID114),] 
Answer_115 <- cbind(GroupID115,RoleID115,Answer115)
Answer_115 <- Answer_115[order(GroupID115),]  
Answer_116 <- cbind(GroupID116,RoleID116,Answer116)
Answer_116 <- Answer_116[order(GroupID116),] 
Answer_117 <- cbind(GroupID117,RoleID117,Answer117)
Answer_117 <- Answer_117[order(GroupID117),]  
Answer_118 <- cbind(GroupID118,RoleID118,Answer118)
Answer_118 <- Answer_118[order(GroupID118),] 
#
a1 <- data.frame(cbind(c("Richer Revision Cheap Talk"),rep(1,6),Answer_111))
a2 <- data.frame(cbind(c("Richer Revision Cheap Talk"),rep(2,6),Answer_112))
a3 <- data.frame(cbind(c("Richer Revision Cheap Talk"),rep(3,6),Answer_113))
a4 <- data.frame(cbind(c("Richer Revision Cheap Talk"),rep(4,6),Answer_114))
a5 <- data.frame(cbind(c("Richer Revision Cheap Talk"),rep(5,6),Answer_115))
a6 <- data.frame(cbind(c("Richer Revision Cheap Talk"),rep(6,6),Answer_116))
a7 <- data.frame(cbind(c("Richer Revision Cheap Talk"),rep(7,6),Answer_117))
a8 <- data.frame(cbind(c("Richer Revision Cheap Talk"),rep(8,6),Answer_118))
names(a1) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(a2) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(a3) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(a4) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(a5) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(a6) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(a7) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
names(a8) <- c("Treatment", "Session", "GroupID", "RoleID", c(1:10))
#
RicherRevisionCheapTalkAnswers <- rbind(a1,a2,a3,a4,a5,a6,a7,a8) # Payoff Relevant Decisions Richer R-CT
#
# Add Quiz
RicherRevisionCheapTalkAnswers$Quiz <- rowSums(data.frame(Quiz_11$Q1 == .42,Quiz_11$Q2 == .5,
                                                    Quiz_11$Q3 == .62,Quiz_11$Q4 == .82,
                                                    Quiz_11$Q5 == .74) )
# Add survey
# R R-CT
survey111 <- cbind(GroupID111,t(SurveyData111[c(3:7),-c(1)]))
survey112 <- cbind(GroupID112,t(SurveyData112[c(3:7),-c(1)]))
survey113 <- cbind(GroupID113,t(SurveyData113[c(3:7),-c(1)]))
survey114 <- cbind(GroupID114,t(SurveyData114[c(3:7),-c(1)]))
survey115 <- cbind(GroupID115,t(SurveyData115[c(3:7),-c(1)]))
survey116 <- cbind(GroupID116,t(SurveyData116[c(3:7),-c(1)]))
survey117 <- cbind(GroupID117,t(SurveyData117[c(3:7),-c(1)]))
survey118 <- cbind(GroupID118,t(SurveyData118[c(3:7),-c(1)]))

survey111 <- survey111[order(GroupID111),] 
survey112 <- survey112[order(GroupID112),] 
survey113 <- survey113[order(GroupID113),] 
survey114 <- survey114[order(GroupID114),] 
survey115 <- survey115[order(GroupID115),] 
survey116 <- survey116[order(GroupID116),] 
survey117 <- survey117[order(GroupID117),] 
survey118 <- survey118[order(GroupID118),] 
survey11 <- data.frame(rbind(survey111,survey112,survey113,survey114,
                             survey115,survey116,survey117,survey118))
names(survey11) <- c("Group", "Gender", "Major1", "Major2", "GPA", "GameTheory")
#
RicherRevisionCheapTalkAnswers <- data.frame(RicherRevisionCheapTalkAnswers,survey11[,-c(1)])
#
##################################################
# Only 60th second decisions, payoff irrelevant  #
##################################################
RRCT60th <- matrix(-1,48,10)
#
for(i in 1:10){
  RRCT60th[,i] <- RicherRevisionCheapTalkDecisions[,64 + 60*(i-1)]
}
RicherRevisionCheapTalk60th <- data.frame(cbind(RicherRevisionCheapTalkDecisions[,2:3], RRCT60th))
RicherRevisionCheapTalk60th <- data.frame(cbind(c("Richer Revision Cheap Talk 60th"),session,
                                                RicherRevisionCheapTalk60th))
names(RicherRevisionCheapTalk60th) <- c("Treatment","Session","GroupID", "RoleID", c(1:10))
#
# GROUPS
#
RRCT60th_G <- matrix(-1,48,10)
#
for(i in 1:10){
  RRCT60th_G[,i] <- RicherRevisionCheapTalkDecisionsG[,64 + 60*(i-1)]
}
RicherRevisionCheapTalkG60th <- data.frame(cbind(RicherRevisionCheapTalkDecisionsG[,2:3], RRCT60th_G))
RicherRevisionCheapTalkG60th <- data.frame(cbind(c("Richer Revision Cheap Talk G 60th"),session,
                                                 RicherRevisionCheapTalkG60th))
names(RicherRevisionCheapTalkG60th) <- c("Treatment","Session","GroupID", "RoleID", c(1:10))
#####################

#############################################################
#     Combine Payoff Relevant Data for all treatments       #
#############################################################
#
# Write a data file with only payoff relevant choices 
#
test <- c(1:48)
B <- data.frame(test,DecisionsBT, stringsAsFactors=FALSE)
RM <- data.frame(test,RevisionMechanismAnswers, stringsAsFactors=FALSE)
RCT <- data.frame(test,RevisionCheapTalkAnswers, stringsAsFactors=FALSE)
IRM <- data.frame(test,InfrequentRevisionMechanismAnswers, stringsAsFactors=FALSE)
SCT <- data.frame(test,DecisionsSCT, stringsAsFactors=FALSE)
RRM <- data.frame(test,RandomRMAnswers, stringsAsFactors=FALSE)
RCTM <- data.frame(test,RevisionCheapTalkMemoryAnswers, stringsAsFactors=FALSE) 
SRM <- data.frame(test,SynchRevisionMechanismAnswers, stringsAsFactors=FALSE) 
RMIU <- data.frame(test,RevisionMechanismIUAnswers, stringsAsFactors=FALSE) 
RMVHBB <- data.frame(test,RevisionMechanismVHBBAnswers, stringsAsFactors=FALSE) 
RRCT <- data.frame(test,RicherRevisionCheapTalkAnswers, stringsAsFactors=FALSE)
names(B)[1] <- "ID"
names(RM)[1] <- "ID"
names(RCT)[1] <- "ID"
names(IRM)[1] <- "ID"
names(SCT)[1] <- "ID"
names(RRM)[1] <- "ID"
names(RCTM)[1] <- "ID"
names(SRM)[1] <- "ID"
names(RMIU)[1] <- "ID"
names(RMVHBB)[1] <- "ID"
names(RRCT)[1] <- "ID"
#
PayoffRelevant <- data.frame(rbind(B,RM,RCT,IRM,SCT,
                                   RRM,RCTM,SRM,RMIU,RMVHBB,RRCT, stringsAsFactors=FALSE), stringsAsFactors=FALSE)
names(PayoffRelevant)[1:15] <- c("ID", "Treatment","Session","Group", "Role", paste0("Round",(1:10)))
dataPR <- PayoffRelevant[,-c(1)]
# CLEAN SURVEY info
mj1 <- (dataPR$Major1 == "other")
#
dataPR$Major1[mj1] <- dataPR$Major2[mj1]
# For unwilling to disclose GPA subjects
dataPR$GPA[dataPR$GPA == -1 ] <- NA
#############################################################
write.csv(dataPR, file = "data/working-data-reproduced/PayoffRelevantData.csv")
#############################################################
#
Choices <- data.frame(rbind(RevisionMechanismChoices,RevisionCheapTalkChoices,
      InfrequentRevisionMechanismChoices,RandomRMChoices,
      RevisionCheapTalkMemoryChoices,SynchRevisionMechanismChoices,
      RevisionMechanismIUChoices,RevisionMechanismVHBBChoices,
      RicherRevisionCheapTalkChoices,RicherRevisionCheapTalkChoicesG))
#
Decisions <- data.frame(rbind(RevisionMechanismDecisions,RevisionCheapTalkDecisions,
                              InfrequentRevisionMechanismDecisions,RandomRMDecisions,
                              RevisionCheapTalkMemoryDecisions,SynchRevisionMechanismDecisions,
                              RevisionMechanismIUDecisions,RevisionMechanismVHBBDecisions,
                              RicherRevisionCheapTalkDecisions,RicherRevisionCheapTalkDecisionsG))
#############################################################
write.csv(Choices, file = "data/working-data-reproduced/Choices_instant.csv")
write.csv(Decisions, file = "data/working-data-reproduced/Decisions_revised.csv")
#############################################################
#
# Cheap talk messages 
LastMessages <- data.frame(rbind(MessagesSCT,RevisionCheapTalk60th,RevisionCheapTalkMemory60th,
                                 RicherRevisionCheapTalk60th,RicherRevisionCheapTalkG60th))
#
#############################################################
write.csv(LastMessages, file = "data/working-data-reproduced/CheapTalkMessages.csv")
#############################################################
#
MessageAction <- rbind(cbind(MessagesSCT,SCT),cbind(RevisionCheapTalk60th,RCT),
                       cbind(RevisionCheapTalkMemory60th,RCTM),
                       cbind(RicherRevisionCheapTalk60th,RRCT),
                       cbind(RicherRevisionCheapTalkG60th,RRCT))
#############################################################
write.csv(MessageAction, file = "data/working-data-reproduced/MessageAction.csv")
#############################################################
#
# Response Time Data
#
RTdata <- data.frame(rbind(RTsBT,RTsRM,RTsSCT,RTsRCT,RTsRCTM,RTsIRM))
#############################################################
write.csv(RTdata, file = "data/working-data-reproduced/ResponseTimeData.csv")
#############################################################
#
# END
#
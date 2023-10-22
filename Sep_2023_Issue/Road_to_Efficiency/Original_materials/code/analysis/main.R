#################################################################
#################################################################
####                                                         ####
#        R code for manuscript Avoyan and Ramos:                #
# "A road to efficiency through communication and commitment"   #
####                                                         ####
#################################################################
#################################################################
#
## Summary of the document
#
# Part 0: Preliminaries (used libraries, data, parameters)
# Part 1: The numerical calculations and measures used in the main body of the paper 
# Part 2: The figures included in the main body of the paper
# Part 3: Additional tables, tests of the exact predictions, and calculations for the Results 
#
# Part 4: Re-print of all the results from the paper <- #!# SEE FOR RESULTS ONLY #!#
#
# Part 5: additional analyses for the online Appendix
#
############
## PART 0 ## 
############
#
# Clear the system
#
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
global.libraries <- c("ggplot2","reshape2","plyr","dplyr","tidyr","plm","grid","stargazer","Hmisc","rms","lmtest","multiwayvcov","sandwich","effects","gtools","Rmisc")
results <- sapply(as.list(global.libraries), pkgTest)
#
# IMPORTANT: replace "/Users/alaavoyan/Desktop/ReplicationPackage/" with the directory in which the ReadMe-file is located
basepath <- "/Users/alaavoyan/Desktop/ReplicationPackage/"
setwd(basepath) # set the directory 
#
# 
# Set output digits
#
options("scipen"=10, "digits"=3)
#
# Load the  Data 
#
PayoffRelevant <- read.csv("data/working-data-reproduced/PayoffRelevantData.csv", stringsAsFactors=FALSE) 
dataLONG <- read.csv("data/working-data-reproduced/Decisions_revised.csv", stringsAsFactors=FALSE) 
dataLONG_choices <- read.csv("data/working-data-reproduced/Choices_instant.csv", stringsAsFactors=FALSE) 
# 
# Organize/clean
#
dataPR <- PayoffRelevant[,-c(1)]
# Unique group identifiers
Gauxi1 <- nrow(dataPR)/6 # Number of total groups
GroupNumbers <- sort(rep(c(1:Gauxi1),6))
dataPR$Group <- GroupNumbers
PayoffRelevant$Group <- GroupNumbers
# 
Gauxi2 <- nrow(dataLONG)/6 # Number of mechanism groups
Groups <- sort(rep(c(1:Gauxi2),6))
dataLONG$GroupID <- Groups
#
Gauxi3 <- nrow(dataLONG_choices)/6 # Number of mechanism groups
Groups <- sort(rep(c(1:Gauxi3),6))
dataLONG_choices$GroupID <- Groups
############
#  PART 1  # 
#####################
# Calculate Payoffs # 
#####################
#
# Payoff parameters of the Minimum Effort Game 
# main
aAVYN = .18
bAVYN = .04
cAVYN = .2
# VHBB 1990
aVHBB = .6
bVHBB = .1
cVHBB = .2
# 
R <- 10 # Number of rounds
L <- length(dataPR$Treatment) - 2*48 
LVHBB <- length(dataPR$Treatment) - 48
Tot <-  length(dataPR$Treatment) 
#
# Payoff in each round
# 
PayoffRoundsSubjectAuxi <- matrix(0, Tot, R)
# Original Payoff parameters 
for(j in 1:R){
  for(i in c(1:L,(LVHBB+1):Tot)){
    k <- floor((i-1)/6)
    auxi11 <- as.numeric(as.character(dataPR[(1+6*k):(6*(k+1)),j+4]))
    auxi12 <- as.numeric(as.character(dataPR[i,j+4]))
    PayoffRoundsSubjectAuxi[i,j] = aAVYN - bAVYN*auxi12 + cAVYN*min(auxi11)
  }
}
# VHBB payoff parameters
for(j in 1:R){
  for(i in (L+1):LVHBB){
    k <- floor((i-1)/6)
    auxi11 <- as.numeric(as.character(dataPR[(1+6*k):(6*(k+1)),j+4]))
    auxi12 <- as.numeric(as.character(dataPR[i,j+4]))
    PayoffRoundsSubjectAuxi[i,j] = aVHBB - bVHBB*auxi12 + cVHBB*min(auxi11)
  }
}
# Join the payoff and treatment data
PayoffRoundsSubject <- data.frame(dataPR$Treatment, dataPR$Group, dataPR$Role, PayoffRoundsSubjectAuxi)
names(PayoffRoundsSubject)[1:3] <- c("Treatment","Group","Role")
PayoffSubject <- data.frame(c(1:(nrow(PayoffRelevant))),PayoffRelevant$Treatment,PayoffRelevant$Group,rowSums(PayoffRoundsSubject[4:13]))
names(PayoffSubject) <- c("ID","Treatment","Group","Payoff")
#
dfff <- ddply(PayoffSubject, .(Group, Treatment), summarise, GroupMeanmean = mean(Payoff))
#
# Payoffs with CHOICE data
#
ChoiceIRM <- dataLONG_choices[dataLONG_choices$Treatment == "Infrequent Revision Mechanism",c(1:5,65,125,185,245,305,365,425,485,545,605)]
PayoffRoundsSubjectAuxiIRMchoice <- matrix(0, 48, 10)
# Original Payoff parameters 
for(j in 1:R){
  for(i in c(1:48)){
    k <- floor((i-1)/6)
    auxi11 <- as.numeric(as.character(ChoiceIRM[(1+6*k):(6*(k+1)),j+4]))
    auxi12 <- as.numeric(as.character(ChoiceIRM[i,j+5]))
    PayoffRoundsSubjectAuxiIRMchoice[i,j] = aAVYN - bAVYN*auxi12 + cAVYN*min(auxi11)
  }
}
#
# Payoffs with CHOICE data RM
#
ChoiceRM <- dataLONG_choices[dataLONG_choices$Treatment == "Revision Mechanism",c(1:5,65,125,185,245,305,365,425,485,545,605)]
PayoffRoundsSubjectAuxiRMchoice <- matrix(0, 48, 10)
# Original Payoff parameters 
for(j in 1:R){
  for(i in c(1:48)){
    k <- floor((i-1)/6)
    auxi11 <- as.numeric(as.character(ChoiceRM[(1+6*k):(6*(k+1)),j+4]))
    auxi12 <- as.numeric(as.character(ChoiceRM[i,j+5]))
    PayoffRoundsSubjectAuxiRMchoice[i,j] = aAVYN - bAVYN*auxi12 + cAVYN*min(auxi11)
  }
}
#
#########################
# Normalized Efficiency # All 10 rounds combined
#########################
MaxEarning <- 1.3 # Maximum earning per round
MinimumEarning <- (.1*5 +.34)/6 # Minimum group payoff per round (1 subject choosing 1, 5 subjects choosing 7)
MinimumEarningVHBB <- (.1*5 +.70)/6 # Minimum group payoff per round (1 subject choosing 1, 5 subjects choosing 7)
#
EfficiencyB <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Baseline",4:13])$value)) 
                - MinimumEarning)/(MaxEarning-MinimumEarning)
EfficiencyRM <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Revision Mechanism",4:13])$value)) 
                 - MinimumEarning)/(MaxEarning-MinimumEarning)
EfficiencySCT <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Standard Cheap Talk",4:13])$value)) 
                  - MinimumEarning)/(MaxEarning-MinimumEarning)
EfficiencyIRM <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Infrequent Revision Mechanism",4:13])$value)) 
                  - MinimumEarning)/(MaxEarning-MinimumEarning)
EfficiencyRRM <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Random Revision Mechanism",4:13])$value)) 
                  - MinimumEarning)/(MaxEarning-MinimumEarning)
EfficiencySRM <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Synchronous Revision Mechanism",4:13])$value)) 
                  - MinimumEarning)/(MaxEarning-MinimumEarning)
EfficiencyRCT <- (mean(as.numeric(melt(PayoffRoundsSubject[(PayoffRoundsSubject$Treatment == "Revision Cheap Talk"|PayoffRoundsSubject$Treatment == "Revision Cheap Talk Memory"),4:13])$value)) 
                   - MinimumEarning)/(MaxEarning-MinimumEarning)
EfficiencyRMVHBB <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Revision Mechanism VHBB",4:13])$value)) 
                   - MinimumEarningVHBB)/(MaxEarning-MinimumEarningVHBB)
EfficiencyRRCT <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Richer Revision Cheap Talk",4:13])$value)) 
                    - MinimumEarning)/(MaxEarning-MinimumEarning)
EfficiencyIRMchoice <- (mean(as.numeric(melt(PayoffRoundsSubjectAuxiIRMchoice)$value)) 
                  - MinimumEarning)/(MaxEarning-MinimumEarning)
EfficiencyRMchoice <- (mean(as.numeric(melt(PayoffRoundsSubjectAuxiRMchoice)$value)) 
                        - MinimumEarning)/(MaxEarning-MinimumEarning)
###############################
# Normalized Efficiency Table # 
###############################
#
options(digits = 3)
#
cat("B", EfficiencyB*100, "\n",
    "S-CT", EfficiencySCT*100, "\n",
    "R-CT", EfficiencyRCT*100, "\n",
    "R-R-CT", EfficiencyRRCT*100, "\n",
    "S-RM", EfficiencySRM*100, "\n",
    "I-RM", EfficiencyIRM*100, "\n",
    "R-RM", EfficiencyRRM*100, "\n",
    "RM",EfficiencyRM*100, "\n", 
    "RM-VHBB", EfficiencyRMVHBB*100, "\n"
    )#In The Paper
#
gainRMoverB <- (1 - (1-EfficiencyRM)/(1-EfficiencyB))*100 
gainRMoverB # In the paper
gainBoverSCT <- (1 - (1-EfficiencySCT)/(1-EfficiencyB))*100
gainRMoverSCT <- (1 - (1-EfficiencyRM)/(1-EfficiencySCT))*100
# # In the paper # Test efficiency of Baseline vs RM and SCT vs RM
wilcox.test(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Baseline",4:13])$value) , as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Revision Mechanism",4:13])$value))
wilcox.test(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Standard Cheap Talk",4:13])$value) , as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Revision Mechanism",4:13])$value))
##########################################
# Normalized Efficiency From Other Papers #
##########################################
#
# Deck, Cary and Nikos Nikiforakis, “Perfect and imperfect real-time monitoring in a minimum-effort game,” Experimental Economics, 2012
#
Max <- 1.65
Min <- 0.15
MinGroup <- .25  # Minimum group payoff per round (1 subject choosing 1, 5 subjects choosing 7)
comunityAverage <- 1.237
neighborAverage <- 1.0
baselineAverage <- .859
#
(comunityAverage - MinGroup)/(Max - MinGroup) # In the paper
(neighborAverage - MinGroup)/(Max - MinGroup) # In the paper
(baselineAverage - MinGroup)/(Max - MinGroup) # Baseline
#
# Blume and Ortmann 2007
#
(.95 - (.7+8*.1)/9)/(1.3- (.7+8*.1)/9) # In the paper
(.55 - (.7+8*.1)/9)/(1.3- (.7+8*.1)/9) # Baseline
#
######################################
# Decomposition of Efficiency Gains  #
######################################
#
(EfficiencyRM-EfficiencyB)
(EfficiencyRM-EfficiencySCT)
(EfficiencyRM-EfficiencySCT)/(EfficiencyRM-EfficiencyB)
#
#########################
# Normalized Efficiency # for a specific round (Round 1)
#########################
round1 = 1+3 # add 3 for column correction; first number is the round of interest 
#
Efficiency_round1_B <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Baseline",round1])$value)) 
                - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round1_RM <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Revision Mechanism",round1])$value)) 
                 - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round1_SCT <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Standard Cheap Talk",round1])$value)) 
                  - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round1_IRM <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Infrequent Revision Mechanism",round1])$value)) 
                  - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round1_RRM <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Random Revision Mechanism",round1])$value)) 
                  - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round1_SRM <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Synchronous Revision Mechanism",round1])$value)) 
                  - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round1_RCT <- (mean(as.numeric(melt(PayoffRoundsSubject[(PayoffRoundsSubject$Treatment == "Revision Cheap Talk"|PayoffRoundsSubject$Treatment == "Revision Cheap Talk Memory"),round1])$value)) 
                  - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round1_RMVHBB <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Revision Mechanism VHBB",round1])$value)) 
                     - MinimumEarningVHBB)/(MaxEarning-MinimumEarningVHBB)
Efficiency_round1_RRCT <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Richer Revision Cheap Talk",round1])$value)) 
                   - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round1_IRMchoice <- (mean(as.numeric(melt(PayoffRoundsSubjectAuxiIRMchoice)$value)) 
                        - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round1_RMchoice <- (mean(as.numeric(melt(PayoffRoundsSubjectAuxiRMchoice)$value)) 
                       - MinimumEarning)/(MaxEarning-MinimumEarning)
###############################
# Normalized Efficiency Table # Specific round only (Round 1)
###############################
#
options(digits = 4)
#
cat("B", Efficiency_round1_B*100, "\n",
    "RM",Efficiency_round1_RM*100, "\n", 
    "S-CT", Efficiency_round1_SCT*100, "\n",
    "R-CT", Efficiency_round1_RCT*100, "\n",
    "R-RM", Efficiency_round1_RRM*100, "\n",
    "I-RM", Efficiency_round1_IRM*100, "\n",
    "S-RM", Efficiency_round1_SRM*100, "\n",
    "RM-VHBB", Efficiency_round1_RMVHBB*100, "\n",
    "R-R-CT", Efficiency_round1_RRCT*100, "\n",
    "I-RM-choice", Efficiency_round1_IRMchoice*100, "\n",
    "RM-choice", Efficiency_round1_RMchoice*100, "\n"
)#In The Paper
round10 = 10+3 # add 3 for column correction; first number is the round of interest (run with 1 and 10 # In the paper)
#
Efficiency_round10_B <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Baseline",round10])$value)) 
                         - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round10_RM <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Revision Mechanism",round10])$value)) 
                          - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round10_SCT <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Standard Cheap Talk",round10])$value)) 
                           - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round10_IRM <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Infrequent Revision Mechanism",round10])$value)) 
                           - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round10_RRM <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Random Revision Mechanism",round10])$value)) 
                           - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round10_SRM <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Synchronous Revision Mechanism",round10])$value)) 
                           - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round10_RCT <- (mean(as.numeric(melt(PayoffRoundsSubject[(PayoffRoundsSubject$Treatment == "Revision Cheap Talk"|PayoffRoundsSubject$Treatment == "Revision Cheap Talk Memory"),round10])$value)) 
                           - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round10_RMVHBB <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Revision Mechanism VHBB",round10])$value)) 
                              - MinimumEarningVHBB)/(MaxEarning-MinimumEarningVHBB)
Efficiency_round10_RRCT <- (mean(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Richer Revision Cheap Talk",round10])$value)) 
                            - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round10_IRMchoice <- (mean(as.numeric(melt(PayoffRoundsSubjectAuxiIRMchoice)$value)) 
                                 - MinimumEarning)/(MaxEarning-MinimumEarning)
Efficiency_round10_RMchoice <- (mean(as.numeric(melt(PayoffRoundsSubjectAuxiRMchoice)$value)) 
                                - MinimumEarning)/(MaxEarning-MinimumEarning)
###############################
# Normalized Efficiency Table # Specific round only (Round 10)
###############################
#
options(digits = 4)
#
cat("B", Efficiency_round10_B*100, "\n",
    "RM",Efficiency_round10_RM*100, "\n", 
    "S-CT", Efficiency_round10_SCT*100, "\n",
    "R-CT", Efficiency_round10_RCT*100, "\n",
    "R-RM", Efficiency_round10_RRM*100, "\n",
    "I-RM", Efficiency_round10_IRM*100, "\n",
    "S-RM", Efficiency_round10_SRM*100, "\n",
    "RM-VHBB", Efficiency_round10_RMVHBB*100, "\n",
    "R-R-CT", Efficiency_round10_RRCT*100, "\n",
    "I-RM-choice", Efficiency_round10_IRMchoice*100, "\n",
    "RM-choice", Efficiency_round10_RMchoice*100, "\n"
)#In The Paper
############
## PART 2 ## Figures
################################
#          FIGURE 2
################################
DF_figure2 <- data.frame(c("a","b", "c", "d",  "e", "f","g", "h","i"),
                         c(EfficiencyB*100,EfficiencySCT*100,EfficiencySRM*100,EfficiencyRCT*100,EfficiencyRRCT*100,EfficiencyIRM*100,EfficiencyRRM*100,EfficiencyRM*100,EfficiencyRMVHBB*100))
names(DF_figure2) <- c("Treatment","Efficiency")

gg_Figure2 <- ggplot(data = DF_figure2, aes(x = Treatment, y = Efficiency, fill = Treatment)) +
  geom_bar(stat ="identity") +
  scale_fill_grey(start = 0.8, end = 0.25)  + 
  xlab("Treatments") +
  ylab("Normalized Efficiency") + 
  scale_y_continuous(expand = c(0, 0), limits = c(0, 100)) +
  theme_linedraw(base_size = 25) + 
  scale_x_discrete(
    labels=c("Baseline","S-CT", "S-RM", "R-CT", "R-R-CT", "I-RM", "R-RM","RM", "RM-VHBB")) + 
  theme(text = element_text(family = "Times"), legend.position = "none")
gg_Figure2
# save
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="Figure2.eps",height=8,width=12)
print(gg_Figure2)
dev.off()
##############################################################################
#       MOVE Classification (Section 5.3.4 including Figure 3)               #
##############################################################################
dataD <- dataLONG[,6:605]
#
matrixD <- data.matrix(dataD)
#
N <- nrow(dataD) 
G <- N/6
#
moved <- matrix(0, N, 599)
#
for(i in 1:N){
  for(j in 2:600){
    # Did decision change?
    if(dataD[i, j] == dataD[i, (j-1)]){
      moved[i,(j-1)] = 1; # no move
    }else{
      moved[i,(j-1)] = 2; # move
    }
  }
}
# Correct for 60th and 1st second difference
for(k in 1:(10-1)){
  moved[,60*k] = 1;
}
#
# Calculate Mins by second for each Group
#
GroupsMinimum <- matrix(0, G, 600)
GroupMinimumWout <- matrix(0, G*6,600) # MIN without you 
#
for(i in 1:G){
  for(j in 1:600){
    GroupsMinimum[i,j] <- min(dataD[((1+(i-1)*6):(6*i)), j])
  }
}
#
for(i in 1:(G*6)){
  for(j in 1:600){
    m <- (1 + 6*(floor((i-1)/6) ) ):(6*(1 + floor((i-1)/6)))
    s <- i - 6*floor((i-1)/6)
    l <- m[-s]
    GroupMinimumWout[i, j] <- min(dataD[l, j])
  }
}
# Move types (long classification)
MyopicUp <- matrix(0, N, 599) # Min and moves up to the next Min /UP
MyopicDown <- matrix(0, N, 599) # Not Min and moves down to the Min; Not Min and moves down but above Min
ForwardThinking <- matrix(0, N, 599) # Min and moves up above the next Min /UP; Not Min but still moves UP
Punishment <- matrix(0, N, 599) # Not Min and moves down bellow Min
Other <- matrix(0, N, 599) # Min and moves down
#
PossibleMyopicUp <- matrix(0, N, 599) # 
PossibleMyopicDown <- matrix(0, N, 599) # 
PossibleForwardThinking <- matrix(0, N, 599) # 
PossiblePunishment <- matrix(0, N, 599) # 
PossibleOther <- matrix(0, N, 599) # 
#
#
for(i in 1:N){
  for(j in 2:600){
    # For Decisions (on graph)
    if(moved[i, (j-1)] == 2){
      # Changed Action
      if(dataD[i, (j-1)] == GroupsMinimum[(floor((i-1)/6) + 1), (j-1)]){
        # you are the MIN of Group
        if(dataD[i,j] >= dataD[i,(j-1)]){# check the == part, should be redundunt
          # Moved UP
          if(dataD[i, j] == GroupsMinimum[floor(((i-1)/6) + 1), j]){
            # NEW Min
            MyopicUp[i,(j-1)] = 2;
          }else{
            # was Min moved above the next Min (not Min anymore)
            ForwardThinking[i, (j-1)] = 2;
          }
        }else{
          # Moved Down
          Other[i, (j-1)] = 2;
        }
      }else{# Not a Min of the group
        if(dataD[i, j] >= dataD[i, (j-1)]){# check the == part, should be redundunt
          # Moved up
          ForwardThinking[i, (j-1)] = 2;
        }else{
          # Moved down
          if(dataD[i, j] >= GroupsMinimum[(floor((i-1)/6) + 1), (j-1)]){
            MyopicDown[i,(j-1)] = 2;
          }else{
            Punishment[i,(j-1)] = 2;
          }
        }  
      }
    }
  }
}
# Ranges for appropriate graphs
range1 <- numeric(10)
range2 <- numeric(10)
range3 <- numeric(10)
range4 <- numeric(10)
range5 <- numeric(10)
range52 <- numeric(10)
range6 <- numeric(10)
range62 <- numeric(10)
range7 <- numeric(10)
range8 <- numeric(10)
range82 <- numeric(10)
range9 <- numeric(10)
range92 <- numeric(10)
range1to30 <- numeric(300)
range31to60 <- numeric(300)
#
range1to10 <- numeric(100)
range11to20 <- numeric(100)
range21to30 <- numeric(100)
range31to40 <- numeric(100)
range41to50 <- numeric(100)
range51to60 <- numeric(100)
#
for(i in 1:10){
  range1[i] = 1+60*(i-1)
  range2[i] = 30 + 60*(i-1)
  range3[i] = 31+60*(i-1)
  range4[i] = 60*i
  range5[i] = 10 + 60*(i-1)
  range52[i] = 11 + 60*(i-1)
  range6[i] = 20 + 60*(i-1)
  range62[i] = 21 + 60*(i-1)
  range7[i] = 30 + 60*(i-1)
  range8[i] = 40 + 60*(i-1)
  range82[i] = 41 + 60*(i-1)
  range9[i] = 50 + 60*(i-1)
  range92[i] = 51 + 60*(i-1)
  #
  range1to30[(1 + 30*(i-1)):(30*i)] <- c(range1[i]:range2[i])
  range31to60[(1 + 30*(i-1)):(30*i)] <- c(range3[i]:range4[i])
  range1to10[(1 + 10*(i-1)):(10*i)] <- c(range1[i]:range5[i])
  range11to20[(1 + 10*(i-1)):(10*i)] <- c(range52[i]:range6[i])
  range21to30[(1 + 10*(i-1)):(10*i)] <- c(range62[i]:range7[i])
  range31to40[(1 + 10*(i-1)):(10*i)] <- c(range3[i]:range8[i])
  range41to50[(1 + 10*(i-1)):(10*i)] <- c(range82[i]:range9[i])
  range51to60[(1 + 10*(i-1)):(10*i)] <- c(range92[i]:range4[i])
}
#
RRMrows <- which(dataLONG$Treatment == "Random Revision Mechanism")
RCTrows <- which(dataLONG$Treatment == "Revision Cheap Talk")
#
moves <- data.frame(moved)
#
Allmoves1to10 <- sum(moves[RRMrows,range1to10] == 2)
Allmoves11to20 <-sum(moves[RRMrows,range11to20] == 2)
Allmoves21to30 <-sum(moves[RRMrows,range21to30] == 2)
Allmoves31to40 <-sum(moves[RRMrows,range31to40] == 2)
Allmoves41to50 <-sum(moves[RRMrows,range41to50] == 2)
Allmoves51to60 <-sum(moves[RRMrows,range51to60[-c(100)]] == 2)
#
AllForwardThinking1to10 <- sum(ForwardThinking[RRMrows,range1to10] == 2)
AllForwardThinking11to20 <-sum(ForwardThinking[RRMrows,range11to20] == 2)
AllForwardThinking21to30 <-sum(ForwardThinking[RRMrows,range21to30] == 2)
AllForwardThinking31to40 <-sum(ForwardThinking[RRMrows,range31to40] == 2)
AllForwardThinking41to50 <-sum(ForwardThinking[RRMrows,range41to50] == 2)
AllForwardThinking51to60 <-sum(ForwardThinking[RRMrows,range51to60[-c(100)]] == 2)
#
AllMyopicDown1to10 <- sum(MyopicDown[RRMrows,range1to10] == 2)
AllMyopicDown11to20 <-sum(MyopicDown[RRMrows,range11to20] == 2)
AllMyopicDown21to30 <-sum(MyopicDown[RRMrows,range21to30] == 2)
AllMyopicDown31to40 <-sum(MyopicDown[RRMrows,range31to40] == 2)
AllMyopicDown41to50 <-sum(MyopicDown[RRMrows,range41to50] == 2)
AllMyopicDown51to60 <-sum(MyopicDown[RRMrows,range51to60[-c(100)]] == 2)
#
AllMyopicUp1to10 <- sum(MyopicUp[RRMrows,range1to10] == 2)
AllMyopicUp11to20 <-sum(MyopicUp[RRMrows,range11to20] == 2)
AllMyopicUp21to30 <-sum(MyopicUp[RRMrows,range21to30] == 2)
AllMyopicUp31to40 <-sum(MyopicUp[RRMrows,range31to40] == 2)
AllMyopicUp41to50 <-sum(MyopicUp[RRMrows,range41to50] == 2)
AllMyopicUp51to60 <-sum(MyopicUp[RRMrows,range51to60[-c(100)]] == 2)
#
AllPunishment1to10 <- sum(Punishment[RRMrows,range1to10] == 2)
AllPunishment11to20 <-sum(Punishment[RRMrows,range11to20] == 2)
AllPunishment21to30 <-sum(Punishment[RRMrows,range21to30] == 2)
AllPunishment31to40 <-sum(Punishment[RRMrows,range31to40] == 2)
AllPunishment41to50 <-sum(Punishment[RRMrows,range41to50] == 2)
AllPunishment51to60 <-sum(Punishment[RRMrows,range51to60[-c(100)]] == 2)
#
AllOther1to10 <- sum(Other[RRMrows,range1to10] == 2)
AllOther11to20 <-sum(Other[RRMrows,range11to20] == 2)
AllOther21to30 <-sum(Other[RRMrows,range21to30] == 2)
AllOther31to40 <-sum(Other[RRMrows,range31to40] == 2)
AllOther41to50 <-sum(Other[RRMrows,range41to50] == 2)
AllOther51to60 <-sum(Other[RRMrows,range51to60[-c(100)]] == 2)
#
#
# # In The Paper # Result 6
#
AllForwardThinking1to10/(AllForwardThinking1to10+AllMyopicDown1to10+AllMyopicUp1to10+AllPunishment1to10+AllOther1to10)
AllMyopicDown51to60/(AllForwardThinking51to60+AllMyopicDown51to60+AllMyopicUp51to60+AllPunishment51to60+AllOther51to60)
AllMyopicDown1to10/(AllForwardThinking1to10+AllMyopicDown1to10+AllMyopicUp1to10+AllPunishment1to10+AllOther1to10)
AllForwardThinking51to60/(AllForwardThinking51to60+AllMyopicDown51to60+AllMyopicUp51to60+AllPunishment51to60+AllOther51to60)
#
# SHORTER CLASSIFICATION for the Figure 3
#
dataForBarShort <- data.frame(c(AllForwardThinking1to10,
                                AllForwardThinking11to20,
                                AllForwardThinking21to30,
                                AllForwardThinking31to40,
                                AllForwardThinking41to50,
                                AllForwardThinking51to60,
                                AllMyopicDown1to10,
                                AllMyopicDown11to20,
                                AllMyopicDown21to30,
                                AllMyopicDown31to40,
                                AllMyopicDown41to50,
                                AllMyopicDown51to60,
                                AllMyopicUp1to10+AllPunishment1to10+AllOther1to10,
                                AllMyopicUp11to20+AllPunishment11to20+AllOther11to20,
                                AllMyopicUp21to30+AllPunishment21to30+AllOther21to30,
                                AllMyopicUp31to40+AllPunishment31to40+AllOther31to40,
                                AllMyopicUp41to50+AllPunishment41to50+AllOther41to50,
                                AllMyopicUp51to60+AllPunishment51to60+AllOther51to60),
                              c(rep(c("1 to 10","11 to 20","21 to 30","31 to 40","41 to 50","51 to 60"),3)),
                              c(rep("Forward Thinking",6),rep("Myopic Down",6),
                                rep("Other",6)))
names(dataForBarShort) <- c("Moves","Seconds","Type")
#
#
gg_Figure3 <- ggplot(dataForBarShort, aes(x=Seconds, y=Moves ,fill=Type)) + 
  geom_bar(stat ="identity") + 
  xlab("Seconds") + 
  ylab("Number of Moves") + 
  scale_y_continuous(expand = c(0, 0), limits = c(0, 360)) +
  guides(fill = guide_legend(title = "Types of Moves:")) + 
  theme_linedraw(base_size = 20) +
  theme(legend.background =  element_rect(fill="White",
                                          size=0.5, linetype="solid", colour ="grey"),
        text=element_text(family="Times New Roman")
  ) +
  theme(legend.position="top") + 
  scale_fill_grey(start = 0.4, end = 0.9)
gg_Figure3
#
# Save the graph (Figure 3)
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="Figure3.eps",height=8,width=12)
print(gg_Figure3)
dev.off()
###############################
#  RRM WHERE do subjects move #
###############################
dataD <- dataLONG[,6:605]
#
matrixD <- data.matrix(dataD)
#
N <- nrow(dataD) 
G <- N/6
#
movedVar <- matrix(-5, N, 599)
#
for(i in 1:N){
  for(j in 2:600){
    # Did decision change?
    if(dataD[i, j] == dataD[i, (j-1)]){
      movedVar[i,(j-1)] = 0; # no move
    }else{
      movedVar[i,(j-1)] = 1; # move
    }
  }
}
# Correct for 60th and 1st second difference
for(k in 1:(10-1)){
  movedVar[,60*k] = 0;
}
#
movedWhere <- as.matrix(dataD[,-c(1)])
#
CombinedMoves <- movedWhere*movedVar
CombinedMoves[CombinedMoves == 0] <- NA
#
RRMrows <- which(dataLONG$Treatment == "Random Revision Mechanism")
#
CombinedMovesRRM <- CombinedMoves[RRMrows,]
#
MovedTo7 <- matrix(-9,48,10)
#
for(i in 1:48){
  for(r in 1:10){
    if(r == 1){
      range <- 1:59
      auxiVector <- c(CombinedMovesRRM[i,range])
      auxiVector2 <- auxiVector[!is.na(auxiVector)]
      MovedTo7[i,r] <- (auxiVector2[1] == 7)*1
    }else{
      range <- (60*(r-1)):(60*r-1)
      auxiVector <- c(CombinedMovesRRM[i,range])
      auxiVector2 <- auxiVector[!is.na(auxiVector)]
      MovedTo7[i,r] <- (auxiVector2[1] == 7)*1
    }
  }
}
#
mean(MovedTo7,na.rm = T)*100 # In the Paper, Moved directly to 7 
sum(MovedTo7, na.rm = T)
#########################################
#        FIGURE 4a and Figure D6a       #
#########################################
#    Equilibrium Deviation over 60 seconds
dataAuxi1 <- dataLONG
dataD <- gather(dataLONG, Round, Effort, X1:X600)
#
options(digits=2)
#
# Individual Deviations (non scaled)
#
EqbmDevD <- numeric(nrow(dataD))
#
for(r in 1:nrow(dataD)){
  k <- floor((r-1)/6)
  auxi11 <- (dataD[(1+6*k):(6*(k+1)),7])
  EqbmDevD[r] <- dataD[r,7] - min(auxi11)
}
#
# Mean Group Deviations 
#
gEqbmDevD <- numeric(nrow(dataD))
AverageOver60 <- numeric(nrow(dataD))
MinOver60 <- numeric(nrow(dataD))
#
#
for(r in 1:nrow(dataD)){
  k <- floor((r-1)/6)
  auxi11 <- (dataD[(1+6*k):(6*(k+1)),7])
  gEqbmDevD[r] <- (mean((auxi11 - min(auxi11))))
  AverageOver60[r] <- mean(auxi11)
  MinOver60[r] <- min(auxi11)
}
#
###
#
DFD <- data.frame(cbind(dataD, EqbmDevD, gEqbmDevD))
#
clean <- function(x) as.numeric(gsub("X", "", x))
DFD$Round <- (as.numeric(lapply(DFD$Round, clean)))
#
# Equilibrium Deviation for ALL 10 Rounds combined
#
RoundAll10 <- DFD[DFD$Treatment != "Random RM",]
RMa <- numeric(60)
CTa <- numeric(60)
RRCTa <- numeric(60)
range <- numeric(10)
#
for(r in 1:60){
  auxi11 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 300 + r) & RoundAll10$Treatment == "Revision Mechanism"])
  auxi12 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 360 + r) & RoundAll10$Treatment == "Revision Mechanism"])
  auxi13 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 420 + r) & RoundAll10$Treatment == "Revision Mechanism"])
  auxi14 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 480 + r) & RoundAll10$Treatment == "Revision Mechanism"])
  auxi15 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 540 + r) & RoundAll10$Treatment == "Revision Mechanism"])
  auxi16 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 0 + r) & RoundAll10$Treatment == "Revision Mechanism"])
  auxi17 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 60 + r) & RoundAll10$Treatment == "Revision Mechanism"])
  auxi18 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 120 + r) & RoundAll10$Treatment == "Revision Mechanism"])
  auxi19 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 180 + r) & RoundAll10$Treatment == "Revision Mechanism"])
  auxi10 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 240 + r) & RoundAll10$Treatment == "Revision Mechanism"])
  
  RMa[r] <- mean(c(auxi11,auxi12,auxi13,auxi14,auxi15,auxi16,auxi17,auxi18,auxi19,auxi10))
  
  auxi11 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 300 + r) & RoundAll10$Treatment == "Revision Cheap Talk"])
  auxi12 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 360 + r) & RoundAll10$Treatment == "Revision Cheap Talk"])
  auxi13 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 420 + r) & RoundAll10$Treatment == "Revision Cheap Talk"])
  auxi14 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 480 + r) & RoundAll10$Treatment == "Revision Cheap Talk"])
  auxi15 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 540 + r) & RoundAll10$Treatment == "Revision Cheap Talk"])
  auxi16 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 0 + r) & RoundAll10$Treatment == "Revision Cheap Talk"])
  auxi17 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 60 + r) & RoundAll10$Treatment == "Revision Cheap Talk"])
  auxi18 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 120 + r) & RoundAll10$Treatment == "Revision Cheap Talk"])
  auxi19 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 180 + r) & RoundAll10$Treatment == "Revision Cheap Talk"])
  auxi10 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 240 + r) & RoundAll10$Treatment == "Revision Cheap Talk"])
  
  CTa[r]  <- mean(c(auxi11,auxi12,auxi13,auxi14,auxi15,auxi16,auxi17,auxi18,auxi19,auxi10))
  
  auxi11 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 300 + r) & RoundAll10$Treatment == "Richer Revision Cheap Talk"])
  auxi12 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 360 + r) & RoundAll10$Treatment == "Richer Revision Cheap Talk"])
  auxi13 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 420 + r) & RoundAll10$Treatment == "Richer Revision Cheap Talk"])
  auxi14 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 480 + r) & RoundAll10$Treatment == "Richer Revision Cheap Talk"])
  auxi15 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 540 + r) & RoundAll10$Treatment == "Richer Revision Cheap Talk"])
  auxi16 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 0 + r) & RoundAll10$Treatment == "Richer Revision Cheap Talk"])
  auxi17 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 60 + r) & RoundAll10$Treatment == "Richer Revision Cheap Talk"])
  auxi18 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 120 + r) & RoundAll10$Treatment == "Richer Revision Cheap Talk"])
  auxi19 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 180 + r) & RoundAll10$Treatment == "Richer Revision Cheap Talk"])
  auxi10 <- mean(RoundAll10$gEqbmDevD[(RoundAll10$Round == 240 + r) & RoundAll10$Treatment == "Richer Revision Cheap Talk"])
  
  RRCTa[r]  <- mean(c(auxi11,auxi12,auxi13,auxi14,auxi15,auxi16,auxi17,auxi18,auxi19,auxi10))
}
DFAaa <- data.frame(c(rep(1:60,3)),c(rep("Revision Mechanism",60),rep("Revision Cheap Talk",60),
                                     rep("Richer Revision Cheap Talk",60)),c(RMa, CTa,RRCTa))
names(DFAaa) <- c("Seconds","Treatment","EquilibriumDeviation") 
#
#
#
DFAaa$Treatment <- factor(DFAaa$Treatment, levels = c("Baseline",
                                                      "Revision Mechanism",
                                                      "Standard Cheap Talk",
                                                      "Revision Cheap Talk",
                                                      "Richer Revision Cheap Talk",
                                                      "Infrequent Revision Mechanism",
                                                      "Random Revision Mechanism"))
#
gg_gg_FigureD6a <- ggplot(DFAaa) +
  geom_line(aes((Seconds), (EquilibriumDeviation), group = Treatment, colour = Treatment
                , linetype = Treatment), 
            size = 2) +
  geom_vline(xintercept = 60, size=1) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 1.55)) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 61)) +
  scale_colour_manual(name = "Treatment", values = c("dodgerblue","#7FC97F","lightskyblue")) +
  scale_linetype_manual(name = "Treatment",values = c("solid","dashed","dotdash")) +
  xlab("\n Seconds") + #ylim(0,1.3) +
  ylab("Equilibrium Deviation \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(legend.position=c(.54,.25),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("top")) + 
  theme(legend.key.width=unit(5,"line"))
gg_gg_FigureD6a
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD6a.eps",height=9,width=12)
print(gg_gg_FigureD6a)
dev.off()
#
# Equilibrium Deviation for LAST 5 Rounds
#
RoundL5 <- DFD[DFD$Round > 300,]
RML5 <- numeric(60)
CTL5 <- numeric(60)
RRCT5 <- numeric(60)
RMLL5 <- numeric(60)
range <- numeric(5)
#
for(r in 1:60){
  auxi11 <- mean(RoundL5$gEqbmDevD[(RoundL5$Round == 300 + r) & RoundL5$Treatment == "Revision Mechanism"])
  auxi12 <- mean(RoundL5$gEqbmDevD[(RoundL5$Round == 360 + r) & RoundL5$Treatment == "Revision Mechanism"])
  auxi13 <- mean(RoundL5$gEqbmDevD[(RoundL5$Round == 420 + r) & RoundL5$Treatment == "Revision Mechanism"])
  auxi14 <- mean(RoundL5$gEqbmDevD[(RoundL5$Round == 480 + r) & RoundL5$Treatment == "Revision Mechanism"])
  auxi15 <- mean(RoundL5$gEqbmDevD[(RoundL5$Round == 540 + r) & RoundL5$Treatment == "Revision Mechanism"])
  
  RML5[r] <- mean(c(auxi11,auxi12,auxi13,auxi14,auxi15))
  
  auxi11 <- mean(RoundL5$gEqbmDevD[(RoundL5$Round == 300 + r) & RoundL5$Treatment == "Revision Cheap Talk"])
  auxi12 <- mean(RoundL5$gEqbmDevD[(RoundL5$Round == 360 + r) & RoundL5$Treatment == "Revision Cheap Talk"])
  auxi13 <- mean(RoundL5$gEqbmDevD[(RoundL5$Round == 420 + r) & RoundL5$Treatment == "Revision Cheap Talk"])
  auxi14 <- mean(RoundL5$gEqbmDevD[(RoundL5$Round == 480 + r) & RoundL5$Treatment == "Revision Cheap Talk"])
  auxi15 <- mean(RoundL5$gEqbmDevD[(RoundL5$Round == 540 + r) & RoundL5$Treatment == "Revision Cheap Talk"])
  
  CTL5[r] <- mean(c(auxi11,auxi12,auxi13,auxi14,auxi15))
  
  auxi11 <- mean(RoundL5$gEqbmDevD[(RoundL5$Round == 300 + r) & RoundL5$Treatment == "Richer Revision Cheap Talk"])
  auxi12 <- mean(RoundL5$gEqbmDevD[(RoundL5$Round == 360 + r) & RoundL5$Treatment == "Richer Revision Cheap Talk"])
  auxi13 <- mean(RoundL5$gEqbmDevD[(RoundL5$Round == 420 + r) & RoundL5$Treatment == "Richer Revision Cheap Talk"])
  auxi14 <- mean(RoundL5$gEqbmDevD[(RoundL5$Round == 480 + r) & RoundL5$Treatment == "Richer Revision Cheap Talk"])
  auxi15 <- mean(RoundL5$gEqbmDevD[(RoundL5$Round == 540 + r) & RoundL5$Treatment == "Richer Revision Cheap Talk"])
  
  RRCT5[r] <- mean(c(auxi11,auxi12,auxi13,auxi14,auxi15))
  
}
DFAL5 <- data.frame(c(rep(1:60,2)),c(rep("Revision Mechanism",60),rep("Revision Cheap Talk",60)), c(RML5, CTL5))
names(DFAL5) <- c("Seconds","Treatment","EquilibriumDeviation") 
#
DFAL5$Treatment <- factor(DFAL5$Treatment, levels = c("Revision Mechanism",
                                                      "Revision Cheap Talk") )
#
#
#
gg_Figure4a <- ggplot(DFAL5) +
  geom_line(aes((Seconds), (EquilibriumDeviation), group = Treatment, colour = Treatment
                , linetype = Treatment), 
            size = 2) +
  geom_vline(xintercept = 60, size=1) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 1)) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 61)) +
  scale_colour_manual(name = "Treatment", values = c("dodgerblue","#7FC97F","lightskyblue")) +
  scale_linetype_manual(name = "Treatment",values = c("solid","dashed","dotdash")) +
  xlab("\n Seconds") + #ylim(0,1.3) +
  ylab("Equilibrium Deviation \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(legend.position=c(.4,.2),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("top")) + 
  theme(legend.key.width=unit(5,"line"))
gg_Figure4a
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="Figure4a.eps",height=9,width=12)
print(gg_Figure4a)
dev.off()
#
############################################
#          FIGURE 4b and FIGURE D6b        #
############################################
# Load the data
dataMessageAction <- read.csv("data/working-data-reproduced/MessageAction.csv", stringsAsFactors=FALSE) 
#
ColumnsToKeep <- c("Treatment", "Session", "GroupID","RoleID",
                   "X1","X61","X121","X181","X241","X301","X361","X421","X481","X541")
InitialData_DF <- dataLONG[ColumnsToKeep]
names(InitialData_DF)[5:14] <- c(1:10)
# Unique group identifiers
G <- nrow(dataMessageAction)/6 # Number of total groups
GroupNumbers <- sort(rep(c(1:G),6))
dataMessageAction$GroupID <- GroupNumbers
#
DF_AE_L <- gather(dataMessageAction, "Round", "LastChoice", X1.1:X10.1)
DF_AE <- ddply(DF_AE_L, .(Treatment), summarise, AE_L = mean(LastChoice))
DF_AE$Treatment <- c("Revision Cheap Talk", "Richer Revision Cheap Talk",
                     "Richer Revision Cheap Talk G", "Standard Cheap Talk")
DF_InitialChoice <- gather(InitialData_DF, "Round", "InitialChoice", 5:14)
DF_IC <- ddply(DF_InitialChoice, .(Treatment), summarise, AE_I = mean(InitialChoice))
#
DF_FC_L_auxi1 <- ddply(DF_AE_L, .(Treatment, GroupID, Round), summarise, FC_L_a = (length(unique(LastChoice)) == 1))
DF_FC_L_auxi2 <- ddply(DF_FC_L_auxi1, .(Treatment), summarise, FC_L = mean(FC_L_a) )
DF_FC_L_auxi2$Treatment <- c("Revision Cheap Talk", "Richer Revision Cheap Talk",
                             "Richer Revision Cheap Talk G", "Standard Cheap Talk")
#
# # Part of Table C.1 (FC(I) and ED(I))
#
IndDevAuxi <- ddply(DF_InitialChoice, .(Treatment, GroupID, Round), plyr::summarize, IndDev = InitialChoice-min(InitialChoice))
IndDevAuxi2 <- ddply(IndDevAuxi, .(Treatment, Round), plyr::summarize,  GroupDev = mean(IndDev))
IndDevAuxi3 <- ddply(IndDevAuxi2, .(Treatment), plyr::summarize,  TreatmentEqbmDev = mean(GroupDev))
IndDevAuxi3 # In The Paper
#
DF_FC_I_auxi1 <- ddply(DF_InitialChoice, .(Treatment, GroupID, Round), summarise, FC_I_a =  (length(unique(InitialChoice)) == 1))
DF_FC_I_auxi2 <- ddply(DF_FC_I_auxi1, .(Treatment), summarise, FC_I = mean(FC_I_a) )
DF_FC_I_auxi2 # In The Paper 
################################
# Minimum Effort Calculations  #
################################
#
MinimumEffortAuxi1 <- dataPR[,-c(2,4)]
names(MinimumEffortAuxi1)[1:12] <- c("Treatment", "Group", c(1:10) )
MinimumEffortAuxi2 <- gather(MinimumEffortAuxi1, Round, Effort,3:12)
MinimumEffortAuxi2$Round  <- factor(MinimumEffortAuxi2$Round, 
                                    levels =sort(unique(as.numeric(MinimumEffortAuxi2$Round))))
#
MinimumEffortGroup <- ddply(MinimumEffortAuxi2, .(Treatment, Round, Group), plyr::summarize, 
                            MinGroup=min((Effort)))
MinimumEffortRound <- ddply(MinimumEffortGroup, .(Treatment,Round), plyr::summarize, 
                            MinRound=mean((MinGroup)))
MinimumEffort <- ddply(MinimumEffortRound, .(Treatment), plyr::summarize, 
                       MinTreatment=mean((MinRound)))
AverageEffort <- ddply(MinimumEffortAuxi2, .(Treatment), plyr::summarize, 
                       AverageEffort=mean(as.numeric(Effort)))
#
print(MinimumEffort) # In the paper
################################
#        Frequency of 7s       #
################################
#
Frequency7sAuxi1 <- dataPR[,-c(2,4)]
names(Frequency7sAuxi1)[1:12] <- c("Treatment", "Group", c(1:10) )
Frequency7sAuxi2 <- gather(Frequency7sAuxi1, Round, Effort,3:12)
#
Frequency7sGroup <- ddply(Frequency7sAuxi2, .(Treatment, Round, Group), plyr::summarize, 
                          Freq7sGroup = length(which(Effort == 7) )/6 )
Frequency7sRound <- ddply(Frequency7sGroup, .(Treatment,Round), plyr::summarize, 
                          Freq7sRound=mean(Freq7sGroup) )
Frequency7sTreatment <- ddply(Frequency7sRound, .(Treatment), plyr::summarize, 
                              Freq7sTreatment=mean(Freq7sRound) )
#
print(Frequency7sTreatment) # In the paper
##################################################
# Equilibrium Deviation Calculations GROUP LEVEL #
##################################################
#
EqbmDevAuxi1 <- dataPR[,-c(2)]
names(EqbmDevAuxi1) <- c("Treatment", "Group", "Role",1:10, names(EqbmDevAuxi1)[14:19])
PRlongFormat <- gather(EqbmDevAuxi1, Round, Effort,4:13)
#
EqbmDevGroup <- ddply(PRlongFormat, .(Treatment, Round, Group), plyr::summarize, 
                      EqDevGroup = mean(as.numeric(Effort) - min(as.numeric(Effort)) ))
EqbmDevRound <- ddply(EqbmDevGroup, .(Treatment,Round), plyr::summarize, 
                      EqbmDevRound=mean(EqDevGroup))
EqbmDevTreatment <- ddply(EqbmDevRound, .(Treatment), plyr::summarize, 
                          EqbmDevTreatment=mean(EqbmDevRound))
#
print(EqbmDevTreatment) # In the paper
# Fully coordinated groups out of all cases
100*mean(EqbmDevGroup[EqbmDevGroup$Treatment == "Baseline",]$EqDevGroup == 0) # In the paper
EqbmDevTreatment # In The Paper
####################################################
# Equilibrium Deviation Calculations SUBJECT LEVEL #
####################################################
#
# Group Minimums
#
G <- nrow(dataPR)/6 # Number of total groups
#
GroupNumbers <- sort(rep(c(1:G),10))
RoundNumbers <- (rep(c(1:10),G))
#
MinAuxi <- data.frame(matrix(-7,length(RoundNumbers),1))
MinAuxi$Group <- GroupNumbers
MinAuxi$Round <- RoundNumbers
names(MinAuxi)[1] <- "MinimumEffort"
#
# Individual Deviations 
#
for(r in 1:nrow(PRlongFormat)){
  k <- floor((r-1)/6)
  auxiIND <- PRlongFormat$Effort[(1+6*k):(6*(k+1))]
  PRlongFormat$IndEqDev[r] <- PRlongFormat$Effort[r] - min(auxiIND)
}
########################################
# Actions coordinated on median choice #
########################################
#
MedianActionDF <- dataPR[,-c(2,4)]
names(MedianActionDF) <- c("Treatment", "Group", 1:10)
MedianActionDF2 <- gather(MedianActionDF, Round, Effort,3:12)
MedianActionDF3 <- ddply(MedianActionDF2, .(Treatment, Round, Group), plyr::summarize, 
                         MedianAction= mean(as.numeric(Effort) == median(as.numeric(Effort) )) )
MedianActionRound <- ddply(MedianActionDF3, .(Treatment,Round), plyr::summarize, 
                           MedianActionR=mean(MedianAction))
MedianActionTreatment <- ddply(MedianActionRound, .(Treatment), plyr::summarize, 
                               MedianAction=mean(MedianActionR))
########################################
# Actions coordinated on median choice #
########################################
#
MedianActionDF <- dataPR[,-c(2,4)]
names(MedianActionDF) <- c("Treatment", "Group", 1:10)
MedianActionDF2 <- gather(MedianActionDF, Round, Effort,3:12)
MedianActionDF3 <- ddply(MedianActionDF2, .(Treatment, Round, Group), plyr::summarize, 
                         MedianAction= mean(as.numeric(Effort) == median(as.numeric(Effort) )) )
MedianActionRound <- ddply(MedianActionDF3, .(Treatment,Round), plyr::summarize, 
                           MedianActionR=mean(MedianAction))
MedianActionTreatment <- ddply(MedianActionRound, .(Treatment), plyr::summarize, 
                               MedianAction=mean(MedianActionR))
############################
# Fully Coordinated Groups #
############################
FullCoordGroup <- ddply(EqbmDevGroup, .(Treatment,Round, Group), plyr::summarize, 
                        EqZeroGroup=(EqDevGroup == 0))
FullCoordRound <- ddply(FullCoordGroup, .(Treatment,Round), plyr::summarize, 
                        EqZeroRound=mean(EqZeroGroup))
FullCoordTreatment <- ddply(FullCoordRound, .(Treatment), plyr::summarize, 
                            EqZeroTreatment=mean(EqZeroRound))
#
FullCoordTreatment$Treatment # In The Paper 
FullCoordTreatment$EqZeroTreatment*100 # In The Paper 
###########################################
# DATA FRAMES FOR Testing and Regressions #
###########################################
DF_PayoffRegression <- data.frame(PayoffRoundsSubject,dataPR[15:20])
DF_PayoffRegression <- DF_PayoffRegression[,-c(17)]
DF_SubjectLEVEL <- data.frame(PayoffSubject,dataPR[15:20])
DF_SubjectLEVEL <- DF_SubjectLEVEL[,-c(8)]
#
variablesTs <- c("Baseline","Revision Mechanism","Standard Cheap Talk")
variablesR3 <- c("Revision Mechanism","Infrequent Revision Mechanism")
#
DF_Payoff <- gather(DF_PayoffRegression, "Round", "Payoff", X1:X10)
#
# Clean X in front of Rounds
#
clean <- function(x) as.numeric(gsub("X", "", x))
DF_Payoff$Round <- (as.numeric(lapply(DF_Payoff$Round, clean)))
#
# FOUR MEASURE REGRESSIONS
#
DF_regression <- merge(MinimumEffortGroup, EqbmDevGroup,  by=c("Group","Treatment","Round") )
DF_regression <- merge(Frequency7sGroup,DF_regression,  by=c("Group","Treatment","Round") )
DF_regression <- merge(FullCoordGroup,DF_regression,  by=c("Group","Treatment","Round") )
# Change FACTOR to Standard Cheap Talk
DF_regression <- within(DF_regression, Treatment <- as.factor(Treatment))
DF_regression$Treatment <- relevel(DF_regression$Treatment, ref = 8)
#
DF_regression_REG2 <- DF_regression[DF_regression$Treatment %in% variablesTs,]
DF_regression_AuxiAdd <- DF_regression[DF_regression$Treatment %in% variablesR3,]
#
#####
#
#
PRlongFormat <- within(PRlongFormat, Treatment <- as.factor(Treatment))
PRlongFormat$Treatment <- relevel(PRlongFormat$Treatment, ref = 8)
#
PRlongFormat_Panel1 <- PRlongFormat[PRlongFormat$Treatment %in% variablesTs,]
PRlongFormat_Panel1 <- within(PRlongFormat_Panel1, Treatment <- as.factor(Treatment))
PRlongFormat_Panel1$Treatment <- relevel(PRlongFormat_Panel1$Treatment, ref = 3)
# For cluster to work, fill in NAs
PRlongFormat_Panel1$GPA[c(which(is.na(PRlongFormat_Panel1$GPA)))] <- mean(PRlongFormat_Panel1$GPA,na.rm = T)
PRlongFormat_Panel1$Quiz[c(which(is.na(PRlongFormat_Panel1$Quiz)))] <- 5
# For cluster to work, fill in NAs
PRlongFormat$GPA[c(which(is.na(PRlongFormat$GPA)))] <- mean(PRlongFormat$GPA,na.rm = T)
PRlongFormat$Quiz[c(which(is.na(PRlongFormat$Quiz)))] <- 5
#
DF_Payoff <- within(DF_Payoff, Treatment <- as.factor(Treatment))
DF_Payoff$Treatment <- relevel(DF_Payoff$Treatment, ref = 8)
# For cluster to work, fill in NAs
DF_Payoff$GPA[c(which(is.na(DF_Payoff$GPA)))] <- mean(DF_Payoff$GPA,na.rm = T)
DF_Payoff$Quiz[c(which(is.na(DF_Payoff$Quiz)))] <- 5
#
DF_Payoff_REG1 <- DF_Payoff[DF_Payoff$Treatment %in% variablesTs,]
DF_Payoff_AuxiAdd <- DF_Payoff[DF_Payoff$Treatment %in% variablesR3,]
#
LandI <- merge(DF_FC_I_auxi2,DF_FC_L_auxi2, by.x ="Treatment",by.y ="Treatment", all = T, incomparables = T)
LandIandPR <- merge(LandI,FullCoordTreatment, by.x ="Treatment",by.y ="Treatment", all = T, incomparables = T)
LandIandPRandAI <- merge(LandIandPR,DF_IC, by.x ="Treatment",by.y ="Treatment", all = T, incomparables = T)
LandIandPRandAIandAL <- merge(LandIandPRandAI,DF_AE, by.x ="Treatment",by.y ="Treatment", all = T, incomparables = T)
LandIandPRandAIandALandPR <- merge(LandIandPRandAIandAL,AverageEffort, by.x ="Treatment",by.y ="Treatment", all = T, incomparables = T)
LandIandPRandAIandALandPR
names(LandIandPRandAIandALandPR) <- c("Treatment",
                                      "Initial_FC","Last_FC","PR_FC",
                                      "Initial_AE","Last_AE","PR_AE")
#
#
options(digits = 3)
100*LandIandPRandAIandALandPR$Initial_FC # In The Paper
#
# Parts of Table C.1 (FC(PR) is from column PR_FC multiplied by 100)
LandIandPRandAIandALandPR
#
df_auxiliary_1 <- gather(LandIandPRandAIandALandPR, TypeFC, FC, 2:4)
df_auxiliary_2 <- gather(LandIandPRandAIandALandPR, TypeAE, AE, 5:7)
#
DF_Fancy <- data.frame(df_auxiliary_1,df_auxiliary_2)
DF_Fancy_auxi_1 <- LandIandPRandAIandALandPR[c(3,5,6),]
#
columnValues <- c("Treatment","AE","FC","TypeFC")
rowValues <- c("Revision Mechanism", "Revision Cheap Talk")
DF_Fancy_CT_E <- DF_Fancy[DF_Fancy$Treatment %in% rowValues, columnValues]
DF_Fancy_CT_E$Type[DF_Fancy_CT_E$TypeFC=="Last_FC"] <- c("60th Message")
DF_Fancy_CT_E$Type[DF_Fancy_CT_E$TypeFC=="PR_FC"] <- c("Payoff Relevant")
DF_Fancy_CT_E <- DF_Fancy_CT_E[DF_Fancy_CT_E$TypeFC!="Initial_FC",]
#
gg_Figure4b <- ggplot() + 
  geom_point(data=DF_Fancy_CT_E, aes(x=AE,y=FC, shape = Type, fill = Type),size = 8) +
  geom_segment(aes(x=unique(DF_Fancy$Last_AE[DF_Fancy$Treatment == "Revision Cheap Talk"]),
                   xend = unique(DF_Fancy$PR_AE[DF_Fancy$Treatment == "Revision Cheap Talk"]),
                   y=unique(DF_Fancy$Last_FC[DF_Fancy$Treatment == "Revision Cheap Talk"]),
                   yend = unique(DF_Fancy$PR_FC[DF_Fancy$Treatment == "Revision Cheap Talk"])),
               size=.5, linetype = "dashed", color = "black",
               arrow = arrow()) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 1)) +
  scale_x_continuous(expand = c(0, 0), limits = c(4, 7)) +
  scale_shape_manual(name = "Decision Type", values = c(21,22)) +
  scale_fill_manual(name = "Decision Type", values = c("lightskyblue","dodgerblue","#7FC97F")) +
  #scale_linetype_manual(name = "Decision Type",values = c("solid","dashed","dotdash")) +
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times")) +
  xlab("\n Average Effort") + #ylim(0,1.3) +
  ylab("Fraction of Fully Coordinated Groups \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(plot.title = element_text(hjust = 0.5)) + 
  theme(legend.position=c(.35,.99),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("top")) + 
  theme(legend.key.width=unit(5,"line")) +
  annotate("text", x = 6.57, 
           y = 0.51,  label = "bold(R-CT)",
           parse = TRUE, family="Times",size=7) +
  annotate("text", x = 6.31, 
           y = 0.7,  label = "bold(RM)",
           parse = TRUE, family="Times",size=7)
gg_Figure4b
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="Figure4b.eps",height=9,width=12)
print(gg_Figure4b)
dev.off()
################################
#          FIGURE D6b          #
################################
#
RMs <- c("Random Revision Mechanism","Revision Mechanism","Synchronous Revision Mechanism",
         "Infrequent Revision Mechanism","Revision Mechanism VHBB")
CTs <- c("Revision Cheap Talk","Richer Revision Cheap Talk","Revision Mechanism")
columnValues <- c("Treatment","AE","FC","TypeFC")
DF_Fancy_CT=DF_Fancy[DF_Fancy$Treatment %in% CTs & DF_Fancy$TypeFC != "Initial_FC",columnValues]
DF_Fancy_CT$Type[DF_Fancy_CT$TypeFC=="Last_FC"] <- c("60th Message")
DF_Fancy_CT$Type[DF_Fancy_CT$TypeFC=="PR_FC"] <- c("Payoff Relevant")
#
gg_FigureD6b <- ggplot() + 
  geom_point(data=DF_Fancy_CT, aes(x=AE,y=FC, color = Type, shape = Type),size = 6) +
  geom_segment(aes(x=unique(DF_Fancy$Last_AE[DF_Fancy$Treatment == "Revision Cheap Talk"]),
                   xend = unique(DF_Fancy$PR_AE[DF_Fancy$Treatment == "Revision Cheap Talk"]),
                   y=unique(DF_Fancy$Last_FC[DF_Fancy$Treatment == "Revision Cheap Talk"]),
                   yend = unique(DF_Fancy$PR_FC[DF_Fancy$Treatment == "Revision Cheap Talk"])),
               size=.5, linetype = "dashed", color = "black",
               arrow = arrow()) +
  geom_segment(aes(x=unique(DF_Fancy$Last_AE[DF_Fancy$Treatment == "Richer Revision Cheap Talk"]),
                   xend = unique(DF_Fancy$PR_AE[DF_Fancy$Treatment == "Richer Revision Cheap Talk"]),
                   y=unique(DF_Fancy$Last_FC[DF_Fancy$Treatment == "Richer Revision Cheap Talk"]),
                   yend = unique(DF_Fancy$PR_FC[DF_Fancy$Treatment == "Richer Revision Cheap Talk"])),
               size=.5, linetype = "dashed", color ="black",
               arrow = arrow()) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 1)) +
  scale_x_continuous(expand = c(0, 0), limits = c(5, 7)) +
  scale_shape_manual(name = "Decision Type", values = c(16,17)) +
  scale_colour_manual(name = "Decision Type", values = c("lightskyblue","dodgerblue")) +
  #scale_linetype_manual(name = "Decision Type",values = c("solid","dashed","dotdash")) +
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times")) +
  xlab("\n Average Effort") + #ylim(0,1.3) +
  ylab("Fraction of Fully Coordinated Groups \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(plot.title = element_text(hjust = 0.5)) + 
  theme(legend.position=c(.35,.99),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("top")) + 
  theme(legend.key.width=unit(5,"line")) +
  annotate("text", x = 6.31, 
           y = 0.685,  label = "bold(RM)",
           parse = TRUE, family="Times",size=7) +
  annotate("text", x = 6.39, 
           y = 0.45,  label = "bold(RCT)",
           parse = TRUE, family="Times",size=7) +
  annotate("text", x = 6.50, 
           y = 0.55,  label = "bold(RRCT)",
           parse = TRUE, family="Times",size=7)
gg_FigureD6b
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD6b.eps",height=9,width=12)
print(gg_FigureD6b)
dev.off()
############
## PART 3 ## 
################################################################
# CALCULATIONS for Tables D1 and D2 used throughout the paper  # 
################################################################
#
# TEST EXACT PREDICTION OF THE THEORY I (the exact prediction of II is later, searchable by EXACT PREDICTION OF THE THEORY II)
#
wilcox.test(DF_Payoff$Payoff[DF_Payoff$Treatment=="Revision Mechanism"], 
            mu = 1.3, alternative="less")$p.value
#
mean(DF_Payoff$Payoff[DF_Payoff$Treatment=="Revision Mechanism"])
################################
#   TEST THEORETICAL INSIGHTS  #
################################
# TEST GROUP PAYOFFS (rounds included)
#
DF_GroupPayoff <- ddply(DF_Payoff, .(Treatment,Group,Round), plyr::summarize, 
                        GroupPayoff=mean(as.numeric(Payoff)))
a <- DF_GroupPayoff$GroupPayoff[DF_GroupPayoff$Treatment=="Revision Mechanism"]
b <- DF_GroupPayoff$GroupPayoff[DF_GroupPayoff$Treatment=="Standard Cheap Talk"]
c <- DF_GroupPayoff$GroupPayoff[DF_GroupPayoff$Treatment=="Revision Mechanism VHBB"]
d <- DF_GroupPayoff$GroupPayoff[DF_GroupPayoff$Treatment=="Random Revision Mechanism"]
e <- DF_GroupPayoff$GroupPayoff[DF_GroupPayoff$Treatment=="Synchronous Revision Mechanism"]
f <- DF_GroupPayoff$GroupPayoff[DF_GroupPayoff$Treatment=="Infrequent Revision Mechanism"]
g <- DF_GroupPayoff$GroupPayoff[DF_GroupPayoff$Treatment=="Revision Cheap Talk"]
h <- DF_GroupPayoff$GroupPayoff[DF_GroupPayoff$Treatment=="Richer Revision Cheap Talk"]
j <- DF_GroupPayoff$GroupPayoff[DF_GroupPayoff$Treatment=="Baseline"]
options("scipen"=10, "digits"=3)
bp <- wilcox.test(a,b)$p.value
cp <- wilcox.test(a,c)$p.value
dp <- wilcox.test(a,d)$p.value
ep <- wilcox.test(a,e)$p.value
fp <- wilcox.test(a,f)$p.value
gp <- wilcox.test(a,g)$p.value
hp <- wilcox.test(a,h)$p.value
aPm <- mean(a)*10
bPm <- mean(b)*10
cPm <- mean(c)*10
dPm <- mean(d)*10
ePm <- mean(e)*10
fPm <- mean(f)*10
gPm <- mean(g)*10
hPm <- mean(h)*10
#
# TEST GROUP Mins (rounds included)
#
aM <- DF_regression$MinGroup[DF_regression$Treatment=="Revision Mechanism"]
bM <- DF_regression$MinGroup[DF_regression$Treatment=="Standard Cheap Talk"]
cM <- DF_regression$MinGroup[DF_regression$Treatment=="Revision Mechanism VHBB"]
dM <- DF_regression$MinGroup[DF_regression$Treatment=="Random Revision Mechanism"]
eM <- DF_regression$MinGroup[DF_regression$Treatment=="Synchronous Revision Mechanism"]
fM <- DF_regression$MinGroup[DF_regression$Treatment=="Infrequent Revision Mechanism"]
gM <- DF_regression$MinGroup[DF_regression$Treatment=="Revision Cheap Talk"]
hM <- DF_regression$MinGroup[DF_regression$Treatment=="Richer Revision Cheap Talk"]
jM <- DF_regression$MinGroup[DF_regression$Treatment=="Baseline"]
options("scipen"=10, "digits"=3)
bMp <-wilcox.test(aM,bM)$p.value
cMp <-wilcox.test(aM,cM)$p.value
dMp <-wilcox.test(aM,dM)$p.value
eMp <-wilcox.test(aM,eM)$p.value
fMp <-wilcox.test(aM,fM)$p.value
gMp <-wilcox.test(aM,gM)$p.value
hMp <-wilcox.test(aM,hM)$p.value
#
# TEST GROUP Frequency of 7s (rounds included)
#
aF <- DF_regression$Freq7sGroup[DF_regression$Treatment=="Revision Mechanism"]
bF <- DF_regression$Freq7sGroup[DF_regression$Treatment=="Standard Cheap Talk"]
cF <- DF_regression$Freq7sGroup[DF_regression$Treatment=="Revision Mechanism VHBB"]
dF <- DF_regression$Freq7sGroup[DF_regression$Treatment=="Random Revision Mechanism"]
eF <- DF_regression$Freq7sGroup[DF_regression$Treatment=="Synchronous Revision Mechanism"]
fF <- DF_regression$Freq7sGroup[DF_regression$Treatment=="Infrequent Revision Mechanism"]
gF <- DF_regression$Freq7sGroup[DF_regression$Treatment=="Revision Cheap Talk"]
hF <- DF_regression$Freq7sGroup[DF_regression$Treatment=="Richer Revision Cheap Talk"]
jF <- DF_regression$Freq7sGroup[DF_regression$Treatment=="Baseline"]
options("scipen"=10, "digits"=3)
bFp <- wilcox.test(aF,bF)$p.value
cFp <- wilcox.test(aF,cF)$p.value
dFp <- wilcox.test(aF,dF)$p.value
eFp <- wilcox.test(aF,eF)$p.value
fFp <- wilcox.test(aF,fF)$p.value
gFp <- wilcox.test(aF,gF)$p.value
hFp <- wilcox.test(aF,hF)$p.value
#
# TEST GROUP Fully Coordinated(rounds included)
#
DF_regression$EqZeroGroup <- DF_regression$EqZeroGroup*1
#
aC <- DF_regression$EqZero[DF_regression$Treatment=="Revision Mechanism"]
bC <- DF_regression$EqZero[DF_regression$Treatment=="Standard Cheap Talk"]
cC <- DF_regression$EqZero[DF_regression$Treatment=="Revision Mechanism VHBB"]
dC <- DF_regression$EqZero[DF_regression$Treatment=="Random Revision Mechanism"]
eC <- DF_regression$EqZero[DF_regression$Treatment=="Synchronous Revision Mechanism"]
fC <- DF_regression$EqZero[DF_regression$Treatment=="Infrequent Revision Mechanism"]
gC <- DF_regression$EqZero[DF_regression$Treatment=="Revision Cheap Talk"]
hC <- DF_regression$EqZero[DF_regression$Treatment=="Richer Revision Cheap Talk"]
jC <- DF_regression$EqZero[DF_regression$Treatment=="Baseline"]
options("scipen"=10, "digits"=3)
bCp <- wilcox.test(aC,bC)$p.value
cCp <- wilcox.test(aC,cC)$p.value
dCp <- wilcox.test(aC,dC)$p.value
eCp <- wilcox.test(aC,eC)$p.value
fCp <- wilcox.test(aC,fC)$p.value
gCp <- wilcox.test(aC,gC)$p.value
hCp <- wilcox.test(aC,hC)$p.value
#
# TEST GROUP Eqbm Dev (rounds included)
#
aE <- DF_regression$EqDevGroup[DF_regression$Treatment=="Revision Mechanism"]
bE <- DF_regression$EqDevGroup[DF_regression$Treatment=="Standard Cheap Talk"]
cE <- DF_regression$EqDevGroup[DF_regression$Treatment=="Revision Mechanism VHBB"]
dE <- DF_regression$EqDevGroup[DF_regression$Treatment=="Random Revision Mechanism"]
eE <- DF_regression$EqDevGroup[DF_regression$Treatment=="Synchronous Revision Mechanism"]
fE <- DF_regression$EqDevGroup[DF_regression$Treatment=="Infrequent Revision Mechanism"]
gE <- DF_regression$EqDevGroup[DF_regression$Treatment=="Revision Cheap Talk"]
hE <- DF_regression$EqDevGroup[DF_regression$Treatment=="Richer Revision Cheap Talk"]
jE <- DF_regression$EqDevGroup[DF_regression$Treatment=="Baseline"]
options("scipen"=10, "digits"=3)
bEp <- wilcox.test(aE,bE)$p.value
cEp <- wilcox.test(aE,cE)$p.value
dEp <- wilcox.test(aE,dE)$p.value
eEp <- wilcox.test(aE,eE)$p.value
fEp <- wilcox.test(aE,fE)$p.value
gEp <- wilcox.test(aE,gE)$p.value
hEp <- wilcox.test(aE,hE)$p.value
#
# R-R-CT vs R-CT
#
options("scipen"=100, "digits"=6)
#
cat(
  10*mean(g),
  10*mean(h),
  mean(gM),
  mean(hM),
  mean(gF),
  mean(hF),
  mean(gC),
  mean(hC),
  mean(gE),
  mean(hE), "\n",
  wilcox.test(g,h)$p.value,
  wilcox.test(gM,hM)$p.value,
  wilcox.test(gF,hF)$p.value,
  wilcox.test(gC,hC)$p.value,
  wilcox.test(gE,hE)$p.value
)
#
options("scipen"=100, "digits"=6)
# Table D.1 and Table D.2 (referenced throughout the paper) # In The Paper 
for(i in 1:1){
  cat("RM"," & ", sprintf('%.3f',10*mean(a)), " & ", sprintf('%.3f',mean(aM)), " & ", sprintf('%.3f',mean(aF)), " & ", sprintf('%.3f',mean(aC)), " & ", sprintf('%.3f',mean(aE)), "\\","\\"," \n", sep="") 
  cat("Baseline"," & ", sprintf('%.3f',10*mean(j)), " & ", sprintf('%.3f',mean(jM)), " & ", sprintf('%.3f',mean(jF)), " & ", sprintf('%.3f',mean(jC)), " & ", sprintf('%.3f',mean(jE)), "\\","\\"," \n", sep="") 
  cat("S-CT"," & ", sprintf('%.3f',10*mean(b)), " & ", sprintf('%.3f',mean(bM)), " & ", sprintf('%.3f',mean(bF)), " & ", sprintf('%.3f',mean(bC)), " & ", sprintf('%.3f',mean(bE)), "\\","\\"," \n", sep="") 
  cat("R-RM"," & ", sprintf('%.3f',10*mean(d)), " & ", sprintf('%.3f',mean(dM)), " & ", sprintf('%.3f',mean(dF)), " & ", sprintf('%.3f',mean(dC)), " & ", sprintf('%.3f',mean(dE)), "\\","\\"," \n", sep="") 
  cat("RM-VHBB"," & ", sprintf('%.3f',10*mean(c)), " & ", sprintf('%.3f',mean(cM)), " & ", sprintf('%.3f',mean(cF)), " & ", sprintf('%.3f',mean(cC)), " & ", sprintf('%.3f',mean(cE)), "\\","\\"," \n", sep="") 
  cat("I-RM"," & ", sprintf('%.3f',10*mean(f)), " & ", sprintf('%.3f',mean(fM)), " & ", sprintf('%.3f',mean(fF)), " & ", sprintf('%.3f',mean(fC)), " & ", sprintf('%.3f',mean(fE)), "\\","\\"," \n", sep="") 
  cat("S-RM"," & ", sprintf('%.3f',10*mean(e)), " & ", sprintf('%.3f',mean(eM)), " & ", sprintf('%.3f',mean(eF)), " & ", sprintf('%.3f',mean(eC)), " & ", sprintf('%.3f',mean(eE)), "\\","\\"," \n", sep="") 
  cat("R-CT"," & ", sprintf('%.3f',10*mean(g)), " & ", sprintf('%.3f',mean(gM)), " & ", sprintf('%.3f',mean(gF)), " & ", sprintf('%.3f',mean(gC)), " & ", sprintf('%.3f',mean(gE)), "\\","\\"," \n", sep="") 
  cat("R-R-CT"," & ", sprintf('%.3f',10*mean(h)), " & ", sprintf('%.3f',mean(hM)), " & ", sprintf('%.3f',mean(hF)), " & ", sprintf('%.3f',mean(hC)), " & ", sprintf('%.3f',mean(hE)), "\\","\\"," \n", sep="") 
  cat( "\n", sep="") 
  cat("S-CT"," & ", sprintf('%.3f',bp), " & ", sprintf('%.3f',bMp), " & ", sprintf('%.3f',bFp), " & ", sprintf('%.3f',bCp), " & ", sprintf('%.3f',bEp), " & ", length(a), ",", length(b), "\\","\\"," \n", sep="") 
  cat("R-RM"," & ", sprintf('%.3f',dp), " & ", sprintf('%.3f',dMp), " & ", sprintf('%.3f',dFp), " & ", sprintf('%.3f',dCp), " & ", sprintf('%.3f',dEp), " & ", length(a), ",", length(d),"\\","\\"," \n", sep="") 
  cat("RM-VHBB"," & ", sprintf('%.3f',cp), " & ", sprintf('%.3f',cMp), " & ", sprintf('%.3f',cFp), " & ", sprintf('%.3f',cCp), " & ", sprintf('%.3f',cEp), " & ", length(a), ",", length(c), "\\","\\"," \n", sep="") 
  cat("I-RM"," & ", sprintf('%.3f',fp), " & ", sprintf('%.3f',fMp), " & ", sprintf('%.3f',fFp), " & ", sprintf('%.3f',fCp), " & ", sprintf('%.3f',fEp)," & ", length(a), ",", length(f),"\\","\\"," \n", sep="") 
  cat("S-RM"," & ", sprintf('%.3f',ep), " & ", sprintf('%.3f',eMp), " & ", sprintf('%.3f',eFp), " & ", sprintf('%.3f',eCp), " & ", sprintf('%.3f',eEp), " & ", length(a), ",", length(e),"\\","\\"," \n", sep="") 
  cat("R-CT"," & ", sprintf('%.3f',gp), " & ", sprintf('%.3f',gMp), " & ", sprintf('%.3f',gFp), " & ", sprintf('%.3f',gCp), " & ", sprintf('%.3f',gEp), " & ", length(a), ",", length(g),"\\","\\"," \n", sep="") 
  cat("R-R-CT"," & ", sprintf('%.3f',hp), " & ", sprintf('%.3f',hMp), " & ", sprintf('%.3f',hFp), " & ", sprintf('%.3f',hCp), " & ", sprintf('%.3f',hEp), " & ", length(a), ",", length(h),"\\","\\"," \n", sep="") 
}
#
(10*mean(a)-10*mean(j))/10*mean(a) # In the paper
(10*mean(a)-10*mean(b))/10*mean(a) # In the paper
#
#################################################################################
#         Regression Analysis    (Table 2 and more)                             #
#################################################################################
#
# CLUSTER FUNCTION
#
# write your own function to return variance covariance matrix under clustered SEs
get_CL_vcov<-function(model, cluster){
  require(sandwich, quietly = TRUE)
  require(lmtest, quietly = TRUE)
  
  #calculate degree of freedom adjustment
  M <- length(unique(cluster))
  N <- length(cluster)
  K <- model$rank
  dfc <- (M/(M-1))*((N-1)/(N-K))
  
  #calculate the uj's
  uj  <- apply(estfun(model),2, function(x) tapply(x, cluster, sum))
  
  #use sandwich to get the var-covar matrix
  vcovCL <- dfc*sandwich(model, meat=crossprod(uj)/N)
  return(vcovCL)
}
# errors are not clustered at this stage
model1 <- lm(data = DF_Payoff_REG1, Payoff ~ Treatment + Quiz + Gender + GPA + GameTheory)
summary(model1) 
#
reg1AuxiAdd <- lm(data = DF_Payoff_AuxiAdd, Payoff ~ Treatment + Quiz + Gender + GPA + GameTheory)
summary(reg1AuxiAdd) 
#
reg1all <- lm(data = DF_Payoff, Payoff ~ Treatment + Quiz + Gender + GPA + GameTheory)
summary(reg1all)
#
reg1allR <- lm(data = DF_Payoff, Payoff ~ Treatment +  as.numeric(Round) + Quiz + Gender + GPA + GameTheory)
summary(reg1allR)
#
###
#
# Cluster errors by GROUP
#
model1.vcovCL <- get_CL_vcov(model1, DF_Payoff_REG1$Group)
m1R3.vcovCL <- get_CL_vcov(reg1AuxiAdd, DF_Payoff_AuxiAdd$Group)
m1all.vcovCL <- get_CL_vcov(reg1all, DF_Payoff$Group)
m1allR.vcovCL <- get_CL_vcov(reg1allR, DF_Payoff$Group)
#
############# COEFs ##################### # errors are clustered 
coeftest(model1, model1.vcovCL)                 #
coeftest(reg1AuxiAdd, m1R3.vcovCL)        #
mD5_1 <- coeftest(reg1all, m1all.vcovCL)  #
mD6_1 <- coeftest(reg1allR, m1allR.vcovCL)#
#########################################    
#
#
model2 <- lm(data = DF_regression_REG2, MinGroup ~ Treatment)
summary(model2)
model5 <- lm(data = PRlongFormat_Panel1, 
             IndEqDev ~ Treatment + GPA+Gender+GameTheory+Quiz)
summary(model5)
model3 <- lm(data = DF_regression_REG2, Freq7sGroup ~ Treatment)
summary(model3)
model4 <- lm(data = DF_regression_REG2, EqZeroGroup ~ Treatment)
summary(model4)
#
model2.vcovCL <- get_CL_vcov(model2, DF_regression_REG2$Group)
model5.vcovCL <- get_CL_vcov(model5, PRlongFormat_Panel1$Group)
model3.vcovCL <- get_CL_vcov(model3, DF_regression_REG2$Group)
model4.vcovCL <- get_CL_vcov(model4, DF_regression_REG2$Group)
#
############# COEFs ################### Clustered by group
coeftest(model2, model2.vcovCL)              #
coeftest(model5, model5.vcovCL)              #
coeftest(model3, model3.vcovCL)              #
coeftest(model4, model4.vcovCL)              #
####################################### 
#
# Table 2 # In The Paper
#
options(digits = 3)
#
for(i in 1:1){
  cat("Baseline","&",coeftest(model1, model1.vcovCL)[2,1],"$^{",stars.pval(coeftest(model1, model1.vcovCL)[2,4]), "}$", "&",coeftest(model2, model2.vcovCL)[2,1],"$^{",stars.pval(coeftest(model2, model2.vcovCL)[2,4]), "}$","&", coeftest(model3, model3.vcovCL)[2,1],"$^{",stars.pval(coeftest(model3, model3.vcovCL)[2,4]), "}$","&",coeftest(model4, model4.vcovCL)[2,1],"$^{",stars.pval(coeftest(model4, model4.vcovCL)[2,4]), "}$","&",coeftest(model5, model5.vcovCL)[2,1],"$^{",stars.pval(coeftest(model5, model5.vcovCL)[2,4]), "}$","\\","\\", "\n",sep = "")
  cat("&","(",coeftest(model1, model1.vcovCL)[2,2],")","&","(",coeftest(model2, model2.vcovCL)[2,2],")","&","(",coeftest(model3, model3.vcovCL)[2,2],")","&","(",coeftest(model4, model4.vcovCL)[2,2],")","&","(",coeftest(model5, model5.vcovCL)[2,2],")","\\","\\", "\n",sep = "")
  cat("Revision Mechanism","&",coeftest(model1, model1.vcovCL)[3,1],"$^{",stars.pval(coeftest(model1, model1.vcovCL)[3,4]), "}$","&",coeftest(model2, model2.vcovCL)[3,1],"$^{",stars.pval(coeftest(model2, model2.vcovCL)[3,4]), "}$","&",coeftest(model3, model3.vcovCL)[3,1],"$^{",stars.pval(coeftest(model3, model3.vcovCL)[3,4]), "}$","&",coeftest(model4, model4.vcovCL)[3,1],"$^{",stars.pval(coeftest(model4, model4.vcovCL)[3,4]), "}$","&",coeftest(model5, model5.vcovCL)[3,1],"$^{",stars.pval(coeftest(model5, model5.vcovCL)[3,4]), "}$","\\","\\", "\n",sep = "")
  cat("&","(",coeftest(model1, model1.vcovCL)[3,2],")","&","(",coeftest(model2, model2.vcovCL)[3,2],")","&","(",coeftest(model3, model3.vcovCL)[3,2],")","&","(",coeftest(model4, model4.vcovCL)[3,2],")","&","(",coeftest(model5, model5.vcovCL)[3,2],")","\\","\\", "\n",sep = "")
  cat("Quiz","&",coeftest(model1, model1.vcovCL)[4,1],"$^{",stars.pval(coeftest(model1, model1.vcovCL)[4,4]), "}$","&","&","&","&",coeftest(model5, model5.vcovCL)[4,1],"$^{",stars.pval(coeftest(model5, model5.vcovCL)[4,4]), "}$","\\","\\", "\n",sep = "")
  cat("&","(",coeftest(model1, model1.vcovCL)[4,2],")","&","&","&","&","(",coeftest(model5, model5.vcovCL)[4,2],")","\\","\\", "\n",sep = "")
  cat("Constant","&",coeftest(model1, model1.vcovCL)[1,1],"$^{",stars.pval(coeftest(model1, model1.vcovCL)[1,4]), "}$","&",coeftest(model2, model2.vcovCL)[1,1],"$^{",stars.pval(coeftest(model2, model2.vcovCL)[1,4]), "}$","&",coeftest(model3, model3.vcovCL)[1,1],"$^{",stars.pval(coeftest(model3, model3.vcovCL)[1,4]), "}$","&",coeftest(model4, model4.vcovCL)[1,1],"$^{",stars.pval(coeftest(model4, model4.vcovCL)[1,4]), "}$","&",coeftest(model5, model5.vcovCL)[1,1],"$^{",stars.pval(coeftest(model5, model5.vcovCL)[1,4]), "}$","\\","\\", "\n",sep = "")
  cat("&","(",coeftest(model1, model1.vcovCL)[1,2],")","&","(",coeftest(model2, model2.vcovCL)[1,2],")","&","(",coeftest(model3, model3.vcovCL)[1,2],")","&","(",coeftest(model4, model4.vcovCL)[1,2],")","&","(",coeftest(model5, model5.vcovCL)[1,2],")","\\","\\", "\n",sep = "")
}
#
for(i in 1:1){
  cat(nobs(model1),"&",nobs(model2),"&",nobs(model3),"&",nobs(model4),"&",nobs(model5),"\n")
  cat(summary(model1)$r.squared,"&",summary(model2)$r.squared,"&",summary(model3)$r.squared,"&",
      summary(model4)$r.squared,"&",summary(model5)$r.squared,"\n")
}
##################################################
# Additional regressions for the Online Appendix #
##################################################
# ALL TREATMENTS - # Table D.5
#
reg6all <- lm(data = DF_regression, MinGroup ~ Treatment)
summary(reg6all)
reg7all <- lm(data = PRlongFormat, 
              IndEqDev ~ Treatment + GPA+Gender+GameTheory+Quiz)
summary(reg7all)
reg8all <- lm(data = DF_regression, Freq7sGroup ~ Treatment)
summary(reg8all)
reg9all <- lm(data = DF_regression, EqZeroGroup ~ Treatment)
summary(reg9all)
#
m6all.vcovCL <- get_CL_vcov(reg6all, DF_regression$Group)
m7all.vcovCL <- get_CL_vcov(reg7all, PRlongFormat$Group)
m8all.vcovCL <- get_CL_vcov(reg8all, DF_regression$Group)
m9all.vcovCL <- get_CL_vcov(reg9all, DF_regression$Group)
#
############# COEFs ###################
mD5_2 <- coeftest(reg6all, m6all.vcovCL)              # 
mD5_5 <- coeftest(reg7all, m7all.vcovCL)              #
mD5_3 <- coeftest(reg8all, m8all.vcovCL)              #
mD5_4 <- coeftest(reg9all, m9all.vcovCL)              #
####################################### 
# Print Table D.5
stargazer(mD5_1,mD5_2,mD5_3,mD5_4,mD5_5, title="Results", align=T)
#
options(digits = 3)
#
for(i in 1:1){
  cat(nobs(reg1all),"&",nobs(reg6all),"&",nobs(reg8all),"&",nobs(reg9all),"&",nobs(reg7all),"\n")
  cat(summary(reg1all)$r.squared,"&",summary(reg6all)$r.squared,"&",summary(reg8all)$r.squared,"&",
      summary(reg9all)$r.squared,"&",summary(reg7all)$r.squared,"\n")
}
#
# ALL TREATMENTS and with round variable # Table D.6
#
reg6allR <- lm(data = DF_regression, MinGroup ~ Treatment + as.numeric(Round))
summary(reg6allR)
reg7allR <- lm(data = PRlongFormat, 
               IndEqDev ~ Treatment + GPA+Gender+GameTheory+Quiz+  as.numeric(Round))
summary(reg7allR)
reg8allR <- lm(data = DF_regression, Freq7sGroup ~ Treatment+  as.numeric(Round))
summary(reg8allR)
reg9allR <- lm(data = DF_regression, EqZeroGroup ~ Treatment+  as.numeric(Round))
summary(reg9allR)
#
m6allR.vcovCL <- get_CL_vcov(reg6allR, DF_regression$Group)
m7allR.vcovCL <- get_CL_vcov(reg7allR, PRlongFormat$Group)
m8allR.vcovCL <- get_CL_vcov(reg8allR, DF_regression$Group)
m9allR.vcovCL <- get_CL_vcov(reg9allR, DF_regression$Group)
#
############# COEFs ###################
mD6_2 <- coeftest(reg6allR, m6allR.vcovCL)              #
mD5_5 <- coeftest(reg7allR, m7allR.vcovCL)              #
mD6_3 <- coeftest(reg8allR, m8allR.vcovCL)              #
mD6_4 <- coeftest(reg9allR, m9allR.vcovCL)              #
####################################### 
# Print Table D.6 
stargazer(mD6_1,mD6_2,mD6_3,mD6_4,mD5_5, title="Results", align=T)
#
options(digits = 3)
#
for(i in 1:1){
  cat(nobs(reg1allR),"&",nobs(reg6allR),"&",nobs(reg8allR),"&",nobs(reg9allR),"&",nobs(reg7allR),"\n")
  cat(summary(reg1allR)$r.squared,"&",summary(reg6allR)$r.squared,"&",summary(reg8allR)$r.squared,"&",
      summary(reg9allR)$r.squared,"&",summary(reg7allR)$r.squared,"\n")
}
###############################################################
#         REGRESSIONS with GROUPING
###############################################################
#
# RM vs S-CT and R-CT # Table D.3
#
variablesMix_2 <- c("Revision Mechanism", "Standard Cheap Talk", "Baseline",
                    "Revision Cheap Talk")
#
DF_Payoff$Factor[DF_Payoff$Treatment == "Standard Cheap Talk" |
                   DF_Payoff$Treatment == "Revision Cheap Talk"] <- c("a")
DF_Payoff$Factor[DF_Payoff$Treatment == "Baseline"] <- c("b")
DF_Payoff$Factor[DF_Payoff$Treatment == "Revision Mechanism"] <- c("c")
#
#
DF_regression$Factor[DF_regression$Treatment == "Standard Cheap Talk" |
                       DF_regression$Treatment == "Revision Cheap Talk"] <- c("a")
DF_regression$Factor[DF_regression$Treatment == "Baseline"] <- c("b")
DF_regression$Factor[DF_regression$Treatment == "Revision Mechanism"] <- c("c")
#
#
PRlongFormat$Factor[PRlongFormat$Treatment == "Standard Cheap Talk" |
                      PRlongFormat$Treatment == "Revision Cheap Talk"] <- c("a")
PRlongFormat$Factor[PRlongFormat$Treatment == "Baseline"] <- c("b")
PRlongFormat$Factor[PRlongFormat$Treatment == "Revision Mechanism"] <- c("c")
#
DF_Payoff_REG_FACT_1 <- DF_Payoff[DF_Payoff$Treatment %in% variablesMix_2,]
DF_regression_REG_FACT_1 <- DF_regression[DF_regression$Treatment %in% variablesMix_2,]
PRlongFormat_Panel1_FACT_1 <- PRlongFormat[PRlongFormat$Treatment %in% variablesMix_2,]
#
# For cluster to work, fill in NAs
PRlongFormat_Panel1_FACT_1$GPA[c(which(is.na(PRlongFormat_Panel1_FACT_1$GPA)))] <- mean(PRlongFormat_Panel1_FACT_1$GPA,na.rm = T)
PRlongFormat_Panel1_FACT_1$Quiz[c(which(is.na(PRlongFormat_Panel1_FACT_1$Quiz)))] <- 5
#
regFactor1_pay <- lm(data = DF_Payoff_REG_FACT_1, Payoff ~ Factor + Quiz + Gender + GPA + GameTheory)
summary(regFactor1_pay)
nobs(regFactor1_pay)
#
regFactor1_pay.vcovCL <- get_CL_vcov(regFactor1_pay, DF_Payoff_REG_FACT_1$Group)
#
############# COEFs #####################
mD.3_1 <- coeftest(regFactor1_pay, regFactor1_pay.vcovCL)               #
#########################################   
#
# 4 MEASURES
#
reg6 <- lm(data = DF_regression_REG_FACT_1, MinGroup ~ Factor)
summary(reg6)
reg7 <- lm(data = PRlongFormat_Panel1_FACT_1, 
           IndEqDev ~ Factor + GPA+Gender+GameTheory+Quiz)
summary(reg7)
reg8 <- lm(data = DF_regression_REG_FACT_1, Freq7sGroup ~ Factor)
summary(reg8)
reg9 <- lm(data = DF_regression_REG_FACT_1, EqZeroGroup ~ Factor)
summary(reg9)
#
m6.vcovCL <- get_CL_vcov(reg6, DF_regression_REG_FACT_1$Group)
#
m7.vcovCL <- get_CL_vcov(reg7, PRlongFormat_Panel1_FACT_1$Group)
#
m8.vcovCL <- get_CL_vcov(reg8, DF_regression_REG_FACT_1$Group)
#
m9.vcovCL <- get_CL_vcov(reg9, DF_regression_REG_FACT_1$Group)
#
############# COEFs ###################
mD.3_2 <- coeftest(reg6, m6.vcovCL)              # 
mD.3_5 <- coeftest(reg7, m7.vcovCL)              #
mD.3_3 <- coeftest(reg8, m8.vcovCL)              #
mD.3_4 <- coeftest(reg9, m9.vcovCL)              #
####################################### 
# Print # Table D.3
stargazer(mD.3_1,mD.3_2,mD.3_3,mD.3_4,mD.3_5, align = T)
#
options(digits = 3)
#
for(i in 1:1){
  cat(nobs(regFactor1_pay),"&",nobs(reg6),"&",nobs(reg8),"&",nobs(reg9),"&",nobs(reg7),"\n")
  cat(summary(regFactor1_pay)$r.squared,"&",summary(reg6)$r.squared,"&",summary(reg8)$r.squared,"&",
      summary(reg9)$r.squared,"&",summary(reg7)$r.squared,"\n")
}
###############################
#   RMs and CTs # Table D.4   #
###############################
variablesMix_3 <- c("Baseline","Revision Mechanism","Random Revision Mechanism",
                    "Revision Mechanism VHBB",
                    "Standard Cheap Talk","Revision Cheap Talk",
                    "Richer Revision Cheap Talk")
#
# Make Factors For Groups
#
DF_Payoff$Factor[DF_Payoff$Treatment == "Standard Cheap Talk"|
                   DF_Payoff$Treatment == "Revision Cheap Talk"|
                   DF_Payoff$Treatment == "Richer Revision Cheap Talk"] <- c("a")
DF_Payoff$Factor[DF_Payoff$Treatment == "Baseline"] <- c("b")
DF_Payoff$Factor[DF_Payoff$Treatment == "Revision Mechanism"|
                   DF_Payoff$Treatment == "Random Revision Mechanism" |
                   DF_Payoff$Treatment == "Revision Mechanism VHBB"] <- c("c")
#
DF_regression$Factor[DF_regression$Treatment == "Standard Cheap Talk"|
                       DF_regression$Treatment == "Revision Cheap Talk"|
                       DF_regression$Treatment == "Richer Revision Cheap Talk"] <- c("a")
DF_regression$Factor[DF_regression$Treatment == "Baseline"] <- c("b")
DF_regression$Factor[DF_regression$Treatment == "Revision Mechanism"|
                       DF_regression$Treatment == "Random Revision Mechanism" |
                       DF_regression$Treatment == "Revision Mechanism VHBB"] <- c("c")
#
PRlongFormat$Factor[PRlongFormat$Treatment == "Standard Cheap Talk"|
                      PRlongFormat$Treatment == "Revision Cheap Talk"|
                      PRlongFormat$Treatment == "Richer Revision Cheap Talk"] <- c("a")
PRlongFormat$Factor[PRlongFormat$Treatment == "Baseline"] <- c("b")
PRlongFormat$Factor[PRlongFormat$Treatment == "Revision Mechanism"|
                      PRlongFormat$Treatment == "Random Revision Mechanism" |
                      PRlongFormat$Treatment == "Revision Mechanism VHBB"] <- c("c")
#
DF_Payoff_REG_FACT_2 <- DF_Payoff[DF_Payoff$Treatment %in% variablesMix_3,]
DF_regression_REG_FACT_2 <- DF_regression[DF_regression$Treatment %in% variablesMix_3,]
PRlongFormat_Panel1_FACT_2 <- PRlongFormat[PRlongFormat$Treatment %in% variablesMix_3,]
#
# For cluster to work, fill in NAs
PRlongFormat_Panel1_FACT_2$GPA[c(which(is.na(PRlongFormat_Panel1_FACT_2$GPA)))] <- mean(PRlongFormat_Panel1_FACT_2$GPA,na.rm = T)
PRlongFormat_Panel1_FACT_2$Quiz[c(which(is.na(PRlongFormat_Panel1_FACT_2$Quiz)))] <- 5
#
regFy <- lm(data = DF_Payoff_REG_FACT_2, Payoff ~ Factor + Quiz + Gender + GPA + GameTheory)
summary(regFy)
nobs(regFy)
#
regFy.vcovCL <- get_CL_vcov(regFy, DF_Payoff_REG_FACT_2$Group)
#
############# COEFs #####################
mD.4_1 <- coeftest(regFy, regFy.vcovCL)               #
#########################################  
#
# 4 MEASURES
#
regF26 <- lm(data = DF_regression_REG_FACT_2, MinGroup ~ Factor)
summary(regF26)
regF27 <- lm(data = PRlongFormat_Panel1_FACT_2, 
             IndEqDev ~ Factor + GPA+Gender+GameTheory+Quiz)
summary(regF27)
regF28 <- lm(data = DF_regression_REG_FACT_2, Freq7sGroup ~ Factor)
summary(regF28)
regF29 <- lm(data = DF_regression_REG_FACT_2, EqZeroGroup ~ Factor)
summary(regF29)
#
m6.vcovCL <- get_CL_vcov(regF26, DF_regression_REG_FACT_2$Group)
#
m7.vcovCL <- get_CL_vcov(regF27, PRlongFormat_Panel1_FACT_2$Group)
#
m8.vcovCL <- get_CL_vcov(regF28, DF_regression_REG_FACT_2$Group)
#
m9.vcovCL <- get_CL_vcov(regF29, DF_regression_REG_FACT_2$Group)
#
############# COEFs ###################
mD.4_2 <- coeftest(regF26, m6.vcovCL)              # 
mD.4_5 <- coeftest(regF27, m7.vcovCL)              #
mD.4_3 <- coeftest(regF28, m8.vcovCL)              #
mD.4_4 <- coeftest(regF29, m9.vcovCL)              #
####################################### 
#
# Print Table D.4
stargazer(mD.4_1,mD.4_2,mD.4_3,mD.4_4,mD.4_5,title="Results", align=T)
#
options(digits = 3)
#
for(i in 1:1){
  cat(nobs(regFy),"&",nobs(regF26),"&",nobs(regF28),"&",nobs(regF29),"&",nobs(regF27),"\n")
  cat(summary(regFy)$r.squared,"&",summary(regF26)$r.squared,"&",summary(regF28)$r.squared,"&",
      summary(regF29)$r.squared,"&",summary(regF27)$r.squared,"\n")
}
#
########################################### 
# INITIAL CHOICE ANALYSIS and Table D.7   #
########################################### 
ColumnsToKeep <- c("Treatment", "Session", "GroupID","RoleID",
                   "X1","X61","X121","X181","X241","X301","X361","X421","X481","X541")
InitialData_DF <- dataLONG[ColumnsToKeep]
names(InitialData_DF)[5:14] <- c(1:10)
#
RMinitial <- subset(InitialData_DF, Treatment == "Revision Mechanism", select = c(5:14))
IRMinitial <- subset(InitialData_DF, Treatment == "Infrequent Revision Mechanism", select = c(5:14))
SRMinitial <- subset(InitialData_DF, Treatment == "Synchronous Revision Mechanism", select = c(5:14))
RMVHBBinitial <- subset(InitialData_DF, Treatment == "Revision Mechanism VHBB", select = c(5:14))
RCTinitial <- subset(InitialData_DF, Treatment == "Revision Cheap Talk", select = c(5:14))
RRCTinitial <- subset(InitialData_DF, Treatment == "Richer Revision Cheap Talk", select = c(5:14))
####
#
# EXACT PREDICTION OF THE THEORY II
#
test <- (RMinitial$`10` == 7)*1
#
Success <- sum(test == 1, na.rm = T)
SampSize <- sum(test == 1 | test == 0, na.rm = T)
#
binom.test(Success, SampSize, p = 1, alternative = "less") # H_0: != 100
# INITIAL CHOICE DISTRIBUTION RM all and Round 10 
table(melt(RMinitial)$value)/sum(table(melt(RMinitial)$value)) # In the paper
table(melt(RMinitial$`10`)$value)/sum(table(melt(RMinitial$`10`)$value)) # In the paper
##################
#    Table D.7   #
##################
options(digits = 2)
100*table(melt(RMinitial)$value)/sum(table(melt(RMinitial)$value)) 
100*table(melt(IRMinitial)$value)/sum(table(melt(IRMinitial)$value)) 
##################
#   CREDIBILITY  #
##################
#  Reached 7 DID 7 ( Needs to be done for each group )
#
Grms <- nrow(dataLONG_choices)/6 # Number of mechanism groups
ReachedCommon <- matrix(-7, Grms, 600) 
ProfilesStayed <- matrix(-5, Grms, 10) 
#
# Reached profile of Common Effort over 60 seconds
#
for(countG in 1:nrow(dataLONG)){
  for(countr in 1:600){
    countK <- floor((countG-1)/6) + 1
    auxi <- (dataLONG[(1+6*(countK-1)):(6*(countK)),countr+5]) 
    if(length(unique(auxi)) == 1){
      ReachedCommon[countK,countr] <-  1
    }else{
      ReachedCommon[countK,countr] <-  0
    }
  }
}
#
# Matched the 60th second
#
range <- numeric(10)
for(i in 1:10){
  range[i] = 60+60*(i-1)
}
#
for(i in 1:Grms){
  for(r in 1:10){
    auxi <- (ReachedCommon[i,(range[r]-59):range[r]]) 
    if(sum(auxi) == 0){
      ProfilesStayed[i,r] = NA
    }else{
      if(ReachedCommon[i,range[r]] == 0){
        ProfilesStayed[i,r] = 0
      }else{
        ProfilesStayed[i,r] = 1
      }
    }
  }
}
#
# PAYOFF RELEVEANT CHOICE FOR CHEAP TALK TREATMENTS
#
dataPR_sub <- dataPR[dataPR$Treatment != "Baseline" & dataPR$Treatment != "Standard Cheap Talk",]
ReachedCommonPR <- matrix(-2, nrow(dataPR_sub)/6, 10) 
#
for(z in 1:nrow(dataPR_sub)){
  for(r in 1:10){
    K <- floor((z-1)/6) + 1
    auxi <- (dataPR_sub[(1+6*(K-1)):(6*(K)),r+4]) 
    if(length(unique(auxi)) == 1){
      ReachedCommonPR[K,r] <-  1
    }else{
      ReachedCommonPR[K,r] <-  0
    }
  }
}
#
ProfilesStayedPR <- matrix(-3,nrow(dataPR_sub)/6,10)
#
for(i in 1:(nrow(dataPR_sub)/6)){
  for(r in 1:10){
    auxi <- (ReachedCommon[i,(range[r]-59):range[r]]) 
    if(sum(auxi) == 0){
      ProfilesStayedPR[i,r] = NA
    }else{
      if(ReachedCommonPR[i,r] == 0){
        ProfilesStayedPR[i,r] = 0
      }else{
        ProfilesStayedPR[i,r] = 1
      }
    }
  }
}
#
dataPR_sub$Number <- sort(rep(c(1:(nrow(dataPR_sub)/6)),6))
#
RCTidex <-unique(dataPR_sub$Number[which(dataPR_sub$Treatment == "Revision Cheap Talk")])
testStayedRCT <- melt(ProfilesStayedPR[RCTidex,])$value
mean(testStayedRCT, na.rm = T)*100 # In The Paper (credibility) R-CT
#
RRCTidex <-unique(dataPR_sub$Number[which(dataPR_sub$Treatment == "Richer Revision Cheap Talk")])
testStayedRRCT <- melt(ProfilesStayedPR[RRCTidex,])$value
mean(testStayedRRCT, na.rm = T)*100
#
RMidex <-unique(dataPR_sub$Number[which(dataPR_sub$Treatment == "Revision Mechanism")])
testStayedRM <- melt(ProfilesStayedPR[RMidex,])$value
mean(testStayedRM, na.rm = T)*100 # In The Paper (credibility) RM
#
100-sum(is.na(testStayedRCT))/length(testStayedRCT)*100
100-sum(is.na(testStayedRM))/length(testStayedRM)*100
100-sum(is.na(testStayedRRCT))/length(testStayedRRCT)*100
#
# How soon do groups converge
#
CovergenceSpeed <-matrix(-1, Grms, 10) 
#
for (i in 1:10) {
  for (k in 1:Grms) {
    auxi <- ReachedCommon[k,((1+(i-1)*60):(60 + (i-1)*60))] #pick a 60 second vector per group per round
    CovergenceSpeed[k,i] <- min( which (auxi == 1), 60 )
  }
}
#
# Correct 60s to NAs to indicat the end of a period
#
CovergenceSpeed[CovergenceSpeed == 60] <- NA
#
# When did they converge? How Quickly?
#
RMidex <- unique(dataLONG$GroupID[which(dataLONG$Treatment == "Revision Mechanism")])
RCTindex <- unique(dataLONG$GroupID[which(dataLONG$Treatment == "Revision Cheap Talk")])
RRCTindex <- unique(dataLONG$GroupID[which(dataLONG$Treatment == "Richer Revision Cheap Talk")])
#
mean(CovergenceSpeed[RMidex,], na.rm = T) 
mean(CovergenceSpeed[RCTindex,], na.rm = T) 
mean(CovergenceSpeed[RRCTindex,], na.rm = T)
#
# How often did they converge?
#
(1-length(which( is.na(CovergenceSpeed[RMidex,]) ))/160)*100 # In The Paper (convergence frequency) RM
(1-length(which( is.na(CovergenceSpeed[RCTindex,]) ))/160)*100 # In The Paper (convergence frequency) R-CT
#
#
###################################################
#   Differences between communication and action  #  Result 8 and above
###################################################
#
# MESSAGES
#
dataMessages <- read.csv("data/working-data-reproduced/CheapTalkMessages.csv", stringsAsFactors=FALSE) 
#
# Unique group identifiers
Gauxi <- nrow(dataMessages)/6 # Number of total groups
GroupNumbers <- sort(rep(c(1:Gauxi),6))
dataMessages$GroupID <- GroupNumbers
#
Xs <- c("X1","X2","X3","X4","X5","X6","X7","X8","X9","X10")
Rs <- c("Round1","Round2","Round3","Round4","Round5","Round6","Round7","Round8","Round9","Round10")
#
MessageRCT <- dataMessages[dataMessages$Treatment == "Revision Cheap Talk 60th",c("Treatment",Xs)]
MessageRRCT <- dataMessages[dataMessages$Treatment == "Richer Revision Cheap Talk 60th",c("Treatment",Xs)]
MessageRRCT_G <- dataMessages[dataMessages$Treatment == "Richer Revision Cheap Talk G 60th",c("Treatment",Xs)]
RCT_PR <- dataPR[dataPR$Treatment %in% c("Revision Cheap Talk"),c("Treatment",Rs)]
RRCT_PR <- dataPR[dataPR$Treatment %in% c("Richer Revision Cheap Talk"),c("Treatment",Rs)]
#
message60th <- rbind(MessageRCT,MessageRRCT,MessageRRCT_G)
actionsCTs <- rbind(RCT_PR,RRCT_PR)
names(message60th) <- names(actionsCTs)
#
dataFrameNA <- rbind(message60th,actionsCTs)
Gauxi <- nrow(dataFrameNA)/6 # Number of total groups
GroupNumbers <- sort(rep(c(1:Gauxi),6))
dataFrameNA$Group <- GroupNumbers
#
dataFrameLONG <- gather(dataFrameNA, Round, Choice, Round1:Round10)
#
MinimumAuxiliary1 <- ddply(dataFrameLONG, .(Treatment, Round, Group), plyr::summarize, 
                           MinGroup=min((Choice)))
MinimumAuxiliary2 <- ddply(MinimumAuxiliary1, .(Treatment, Round), plyr::summarize, 
                           MinGroup=mean((MinGroup)))
MinimumAuxiliary3 <- ddply(MinimumAuxiliary2, .(Treatment), plyr::summarize, 
                           MinGroup=mean((MinGroup)))
#
EqbmDevAuxiliary1 <- ddply(dataFrameLONG, .(Treatment, Round, Group), plyr::summarize, 
                           EqDevGroup = mean(as.numeric(Choice) - min(as.numeric(Choice)) ))
EqbmDevAuxiliary2 <- ddply(EqbmDevAuxiliary1, .(Treatment,Round), plyr::summarize, 
                           EqbmDevRound=mean(EqDevGroup))
EqbmDevAuxiliary3 <- ddply(EqbmDevAuxiliary2, .(Treatment), plyr::summarize, 
                           EqbmDevTreatment=mean(EqbmDevRound))
#
#
#
FullCoordGroup <- ddply(EqbmDevAuxiliary1, .(Treatment,Round, Group), plyr::summarize, 
                        EqZeroGroup=(EqDevGroup == 0))
FullCoordRound <- ddply(FullCoordGroup, .(Treatment,Round), plyr::summarize, 
                        EqZeroRound=mean(EqZeroGroup))
FullCoordTreatment <- ddply(FullCoordRound, .(Treatment), plyr::summarize, 
                            EqZeroTreatment=mean(EqZeroRound))
#
#
#
Frequency7sGroup <- ddply(dataFrameLONG, .(Treatment, Round, Group), plyr::summarize, 
                          Freq7sGroup = length(which(Choice == 7) )/6 )
Frequency7sRound <- ddply(Frequency7sGroup, .(Treatment,Round), plyr::summarize, 
                          Freq7sRound=mean(Freq7sGroup) )
Frequency7sTreatment <- ddply(Frequency7sRound, .(Treatment), plyr::summarize, 
                              Freq7sTreatment=mean(Freq7sRound) )
#
#
#
minPR <- MinimumAuxiliary1$MinGroup[MinimumAuxiliary1$Treatment == "Revision Cheap Talk"]
min60th <- MinimumAuxiliary1$MinGroup[MinimumAuxiliary1$Treatment == "Revision Cheap Talk 60th"]
freqPR <- Frequency7sGroup$Freq7sGroup[Frequency7sGroup$Treatment == "Revision Cheap Talk"]
freq60th <- Frequency7sGroup$Freq7sGroup[Frequency7sGroup$Treatment == "Revision Cheap Talk 60th"]
fcPR <- FullCoordGroup$EqZeroGroup[FullCoordGroup$Treatment == "Revision Cheap Talk"]*1
fc60th <- FullCoordGroup$EqZeroGroup[FullCoordGroup$Treatment == "Revision Cheap Talk 60th"]*1
eqbmPR <- EqbmDevAuxiliary1$EqDevGroup[EqbmDevAuxiliary1$Treatment == "Revision Cheap Talk"]
eqbm60th <- EqbmDevAuxiliary1$EqDevGroup[EqbmDevAuxiliary1$Treatment == "Revision Cheap Talk 60th"]
#
cat(
  mean(minPR), # In The Paper
  mean(min60th),
  mean(freqPR),
  mean(freq60th),
  mean(fcPR),
  mean(fc60th),
  mean(eqbmPR),
  mean(eqbm60th), "\n",
  wilcox.test(minPR,min60th, alternative = "less")$p.value, # In The Paper
  wilcox.test(freqPR,freq60th, alternative = "less")$p.value,
  wilcox.test(fcPR,fc60th, alternative = "less")$p.value,
  wilcox.test(eqbmPR,eqbm60th, alternative = "greater")$p.value
)
#
#
#
##############################################################
#       Calculate payoffs loss from lack of credibility      # 
##############################################################
#
# Parameters of the Minimum Effort Game 
#
L <- length(dataFrameNA$Treatment) 
#
# Payoff in each round
# 
PayoffRoundsSubjectAuxiliary <- matrix(0, L, 10)
# Original Payoff parameters 
for(j in 1:10){
  for(i in c(1:L)){
    k <- floor((i-1)/6)
    auxi11 <- as.numeric(as.character(dataFrameNA[(1+6*k):(6*(k+1)),j+1]))
    auxi12 <- as.numeric(as.character(dataFrameNA[i,j+1]))
    PayoffRoundsSubjectAuxiliary[i,j] = .18 - .04*auxi12 + .2*min(auxi11)
  }
}
# Join the payoff and treatment data
PayoffsMixedMessages <- data.frame(dataFrameNA$Treatment, dataFrameNA$Group, PayoffRoundsSubjectAuxiliary)
names(PayoffsMixedMessages)[1:2] <- c("Treatment","Group")
#
#
#
PayoffsMixedLONG <- gather(PayoffsMixedMessages,Round,Payoff,X1:X10)
#
#
options(digits = 4)
payoffPR <- PayoffsMixedLONG$Payoff[PayoffsMixedLONG$Treatment == "Revision Cheap Talk"]
payoff60th <- PayoffsMixedLONG$Payoff[PayoffsMixedLONG$Treatment == "Revision Cheap Talk 60th"]
cat(
  mean(payoffPR)*10,
  mean(payoff60th)*10,
  wilcox.test(payoffPR,payoff60th, alternative = "less")$p.value
) # In The Paper 
#
# Percentage loss from lack of credibility
#
100*(mean(payoff60th)*10-mean(payoffPR)*10)/(mean(payoffPR)*10) # In The Paper
#
#############################################################################
#
# Part 4: Re-print some of the results for easier access #SummaryResults 
#
###############################
#     Normalized Efficiency   # 
###############################
#
options(digits = 3)
#
cat("B", EfficiencyB*100, "\n",
    "S-CT", EfficiencySCT*100, "\n",
    "RM",EfficiencyRM*100, "\n", 
    "R-RM", EfficiencyRRM*100, "\n",
    "RM-VHBB", EfficiencyRMVHBB*100, "\n",
    "S-RM", EfficiencySRM*100, "\n",
    "I-RM", EfficiencyIRM*100, "\n",
    "R-CT", EfficiencyRCT*100, "\n",
    "R-R-CT", EfficiencyRRCT*100, "\n"
)
gainRMoverB <- (1 - (1-EfficiencyRM)/(1-EfficiencyB))*100 
gainBoverSCT <- (1 - (1-EfficiencySCT)/(1-EfficiencyB))*100 
gainRMoverSCT <- (1 - (1-EfficiencyRM)/(1-EfficiencySCT))*100 
gainRMoverB # gain over Baseline by RM  
gainBoverSCT # gain over Baseline by SCT  
gainRMoverSCT # gain over SCT by RM 
#
# Baseline vs RM and SCT vs RM test
wilcox.test(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Baseline",4:13])$value) , as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Revision Mechanism",4:13])$value))
wilcox.test(as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Standard Cheap Talk",4:13])$value) , as.numeric(melt(PayoffRoundsSubject[PayoffRoundsSubject$Treatment == "Revision Mechanism",4:13])$value))
#
###############################
#     Normalized Efficiency   # Only round 1 and Only Round 10 
###############################

options(digits = 3)
#
cat("B", Efficiency_round1_B*100, "\n",
    "RM",Efficiency_round1_RM*100, "\n", 
    "S-CT", Efficiency_round1_SCT*100, "\n"
)
#
cat("B", Efficiency_round10_B*100, "\n",
    "RM",Efficiency_round10_RM*100, "\n", 
    "S-CT", Efficiency_round10_SCT*100, "\n"
)
#
###############################
#     Normalized Efficiency   # in other papers
###############################
(comunityAverage - MinGroup)/(Max - MinGroup) # 60 second Cheap Talk
(baselineAverage - MinGroup)/(Max - MinGroup) # Baseline
#
# Blume and Ortmann 2007
#
(.95 - (.7+8*.1)/9)/(1.3- (.7+8*.1)/9) # Cheap talk 
(.55 - (.7+8*.1)/9)/(1.3- (.7+8*.1)/9) # Baseline
#
options("scipen"=100, "digits"=6)
############
# Figure 2 #
############
gg_Figure2
#############################################################
# Table D.1 and Table D.2 (referenced throughout the paper) #
#############################################################
for(i in 1:1){
  cat("RM"," & ", sprintf('%.3f',10*mean(a)), " & ", sprintf('%.3f',mean(aM)), " & ", sprintf('%.3f',mean(aF)), " & ", sprintf('%.3f',mean(aC)), " & ", sprintf('%.3f',mean(aE)), "\\","\\"," \n", sep="") 
  cat("Baseline"," & ", sprintf('%.3f',10*mean(j)), " & ", sprintf('%.3f',mean(jM)), " & ", sprintf('%.3f',mean(jF)), " & ", sprintf('%.3f',mean(jC)), " & ", sprintf('%.3f',mean(jE)), "\\","\\"," \n", sep="") 
  cat("S-CT"," & ", sprintf('%.3f',10*mean(b)), " & ", sprintf('%.3f',mean(bM)), " & ", sprintf('%.3f',mean(bF)), " & ", sprintf('%.3f',mean(bC)), " & ", sprintf('%.3f',mean(bE)), "\\","\\"," \n", sep="") 
  cat("R-RM"," & ", sprintf('%.3f',10*mean(d)), " & ", sprintf('%.3f',mean(dM)), " & ", sprintf('%.3f',mean(dF)), " & ", sprintf('%.3f',mean(dC)), " & ", sprintf('%.3f',mean(dE)), "\\","\\"," \n", sep="") 
  cat("RM-VHBB"," & ", sprintf('%.3f',10*mean(c)), " & ", sprintf('%.3f',mean(cM)), " & ", sprintf('%.3f',mean(cF)), " & ", sprintf('%.3f',mean(cC)), " & ", sprintf('%.3f',mean(cE)), "\\","\\"," \n", sep="") 
  cat("I-RM"," & ", sprintf('%.3f',10*mean(f)), " & ", sprintf('%.3f',mean(fM)), " & ", sprintf('%.3f',mean(fF)), " & ", sprintf('%.3f',mean(fC)), " & ", sprintf('%.3f',mean(fE)), "\\","\\"," \n", sep="") 
  cat("S-RM"," & ", sprintf('%.3f',10*mean(e)), " & ", sprintf('%.3f',mean(eM)), " & ", sprintf('%.3f',mean(eF)), " & ", sprintf('%.3f',mean(eC)), " & ", sprintf('%.3f',mean(eE)), "\\","\\"," \n", sep="") 
  cat("R-CT"," & ", sprintf('%.3f',10*mean(g)), " & ", sprintf('%.3f',mean(gM)), " & ", sprintf('%.3f',mean(gF)), " & ", sprintf('%.3f',mean(gC)), " & ", sprintf('%.3f',mean(gE)), "\\","\\"," \n", sep="") 
  cat("R-R-CT"," & ", sprintf('%.3f',10*mean(h)), " & ", sprintf('%.3f',mean(hM)), " & ", sprintf('%.3f',mean(hF)), " & ", sprintf('%.3f',mean(hC)), " & ", sprintf('%.3f',mean(hE)), "\\","\\"," \n", sep="") 
  cat( "\n", sep="") 
  cat("S-CT"," & ", sprintf('%.3f',bp), " & ", sprintf('%.3f',bMp), " & ", sprintf('%.3f',bFp), " & ", sprintf('%.3f',bCp), " & ", sprintf('%.3f',bEp), " & ", length(a), ",", length(b), "\\","\\"," \n", sep="") 
  cat("R-RM"," & ", sprintf('%.3f',dp), " & ", sprintf('%.3f',dMp), " & ", sprintf('%.3f',dFp), " & ", sprintf('%.3f',dCp), " & ", sprintf('%.3f',dEp), " & ", length(a), ",", length(d),"\\","\\"," \n", sep="") 
  cat("RM-VHBB"," & ", sprintf('%.3f',cp), " & ", sprintf('%.3f',cMp), " & ", sprintf('%.3f',cFp), " & ", sprintf('%.3f',cCp), " & ", sprintf('%.3f',cEp), " & ", length(a), ",", length(c), "\\","\\"," \n", sep="") 
  cat("I-RM"," & ", sprintf('%.3f',fp), " & ", sprintf('%.3f',fMp), " & ", sprintf('%.3f',fFp), " & ", sprintf('%.3f',fCp), " & ", sprintf('%.3f',fEp)," & ", length(a), ",", length(f),"\\","\\"," \n", sep="") 
  cat("S-RM"," & ", sprintf('%.3f',ep), " & ", sprintf('%.3f',eMp), " & ", sprintf('%.3f',eFp), " & ", sprintf('%.3f',eCp), " & ", sprintf('%.3f',eEp), " & ", length(a), ",", length(e),"\\","\\"," \n", sep="") 
  cat("R-CT"," & ", sprintf('%.3f',gp), " & ", sprintf('%.3f',gMp), " & ", sprintf('%.3f',gFp), " & ", sprintf('%.3f',gCp), " & ", sprintf('%.3f',gEp), " & ", length(a), ",", length(g),"\\","\\"," \n", sep="") 
  cat("R-R-CT"," & ", sprintf('%.3f',hp), " & ", sprintf('%.3f',hMp), " & ", sprintf('%.3f',hFp), " & ", sprintf('%.3f',hCp), " & ", sprintf('%.3f',hEp), " & ", length(a), ",", length(h),"\\","\\"," \n", sep="") 
}
#########################################
#  Table 2 (Regression Summary Table)   #
######################################### 
options(digits = 3)
#
for(i in 1:1){
  cat("Baseline","&",coeftest(model1, model1.vcovCL)[2,1],"$^{",stars.pval(coeftest(model1, model1.vcovCL)[2,4]), "}$", "&",coeftest(model2, model2.vcovCL)[2,1],"$^{",stars.pval(coeftest(model2, model2.vcovCL)[2,4]), "}$","&", coeftest(model3, model3.vcovCL)[2,1],"$^{",stars.pval(coeftest(model3, model3.vcovCL)[2,4]), "}$","&",coeftest(model4, model4.vcovCL)[2,1],"$^{",stars.pval(coeftest(model4, model4.vcovCL)[2,4]), "}$","&",coeftest(model5, model5.vcovCL)[2,1],"$^{",stars.pval(coeftest(model5, model5.vcovCL)[2,4]), "}$","\\","\\", "\n",sep = "")
  cat("&","(",coeftest(model1, model1.vcovCL)[2,2],")","&","(",coeftest(model2, model2.vcovCL)[2,2],")","&","(",coeftest(model3, model3.vcovCL)[2,2],")","&","(",coeftest(model4, model4.vcovCL)[2,2],")","&","(",coeftest(model5, model5.vcovCL)[2,2],")","\\","\\", "\n",sep = "")
  cat("Revision Mechanism","&",coeftest(model1, model1.vcovCL)[3,1],"$^{",stars.pval(coeftest(model1, model1.vcovCL)[3,4]), "}$","&",coeftest(model2, model2.vcovCL)[3,1],"$^{",stars.pval(coeftest(model2, model2.vcovCL)[3,4]), "}$","&",coeftest(model3, model3.vcovCL)[3,1],"$^{",stars.pval(coeftest(model3, model3.vcovCL)[3,4]), "}$","&",coeftest(model4, model4.vcovCL)[3,1],"$^{",stars.pval(coeftest(model4, model4.vcovCL)[3,4]), "}$","&",coeftest(model5, model5.vcovCL)[3,1],"$^{",stars.pval(coeftest(model5, model5.vcovCL)[3,4]), "}$","\\","\\", "\n",sep = "")
  cat("&","(",coeftest(model1, model1.vcovCL)[3,2],")","&","(",coeftest(model2, model2.vcovCL)[3,2],")","&","(",coeftest(model3, model3.vcovCL)[3,2],")","&","(",coeftest(model4, model4.vcovCL)[3,2],")","&","(",coeftest(model5, model5.vcovCL)[3,2],")","\\","\\", "\n",sep = "")
  cat("Quiz","&",coeftest(model1, model1.vcovCL)[4,1],"$^{",stars.pval(coeftest(model1, model1.vcovCL)[4,4]), "}$","&","&","&","&",coeftest(model5, model5.vcovCL)[4,1],"$^{",stars.pval(coeftest(model5, model5.vcovCL)[4,4]), "}$","\\","\\", "\n",sep = "")
  cat("&","(",coeftest(model1, model1.vcovCL)[4,2],")","&","&","&","&","(",coeftest(model5, model5.vcovCL)[4,2],")","\\","\\", "\n",sep = "")
  cat("Constant","&",coeftest(model1, model1.vcovCL)[1,1],"$^{",stars.pval(coeftest(model1, model1.vcovCL)[1,4]), "}$","&",coeftest(model2, model2.vcovCL)[1,1],"$^{",stars.pval(coeftest(model2, model2.vcovCL)[1,4]), "}$","&",coeftest(model3, model3.vcovCL)[1,1],"$^{",stars.pval(coeftest(model3, model3.vcovCL)[1,4]), "}$","&",coeftest(model4, model4.vcovCL)[1,1],"$^{",stars.pval(coeftest(model4, model4.vcovCL)[1,4]), "}$","&",coeftest(model5, model5.vcovCL)[1,1],"$^{",stars.pval(coeftest(model5, model5.vcovCL)[1,4]), "}$","\\","\\", "\n",sep = "")
  cat("&","(",coeftest(model1, model1.vcovCL)[1,2],")","&","(",coeftest(model2, model2.vcovCL)[1,2],")","&","(",coeftest(model3, model3.vcovCL)[1,2],")","&","(",coeftest(model4, model4.vcovCL)[1,2],")","&","(",coeftest(model5, model5.vcovCL)[1,2],")","\\","\\", "\n",sep = "")
}
#
for(i in 1:1){
  cat(nobs(model1),"&",nobs(model2),"&",nobs(model3),"&",nobs(model4),"&",nobs(model5),"\n")
  cat(summary(model1)$r.squared,"&",summary(model2)$r.squared,"&",summary(model3)$r.squared,"&",
      summary(model4)$r.squared,"&",summary(model5)$r.squared,"\n")
}
##########################################
# TEST EXACT PREDICTION OF THE THEORY I  #
##########################################
wilcox.test(DF_Payoff$Payoff[DF_Payoff$Treatment=="Revision Mechanism"], 
            mu = 1.3, alternative="less")$p.value  # H_0: payoff = 1.3 (maximum payoff)
###########################################
# TEST EXACT PREDICTION OF THE THEORY II  #
###########################################
binom.test(Success, SampSize, p = 1, alternative = "less") # H_0: initial choice percentage = 100
#
##########################################
#       Initial Choice Distribution      #
##########################################
table(melt(RMinitial)$value)/sum(table(melt(RMinitial)$value)) # value under 7 
table(melt(RMinitial$`10`)$value)/sum(table(melt(RMinitial$`10`)$value)) # value under 7 
############
# Figure 3 #
############
gg_Figure3
#################################
#    Revision Classification    # (Result 6 and above)
#################################
100*dataForBarShort[1,1]/(dataForBarShort[1,1]+dataForBarShort[7,1]+dataForBarShort[13,1]) # Forward thinking in the first 10 seconds out of all
100*dataForBarShort[12,1]/(dataForBarShort[6,1]+dataForBarShort[12,1]+dataForBarShort[18,1]) # Myopic down in the last 10 seconds out of all
#
100*dataForBarShort[7,1]/(dataForBarShort[1,1]+dataForBarShort[7,1]+dataForBarShort[13,1]) # Myopic down in the first 10 seconds out of all
100*dataForBarShort[6,1]/(dataForBarShort[6,1]+dataForBarShort[12,1]+dataForBarShort[18,1]) # Forward thinking in the last 10 seconds out of all
#
100*mean(MovedTo7,na.rm = T) # Moved directly to 7 
#
##########################################################
#   Section Communication and Commitment (Credibility)   # (Result 7 and above)
##########################################################
(1-length(which( is.na(CovergenceSpeed[RMidex,]) ))/160)*100 # Convergence frequency in RM
(1-length(which( is.na(CovergenceSpeed[RCTindex,]) ))/160)*100 # Convergence frequency in R-CT
mean(testStayedRM, na.rm = T)*100 # Stayed at the converged profile RM
mean(testStayedRCT, na.rm = T)*100 # Stayed at the converged profile R-CT
###################################################
#   Differences between communication and action  #  Result 8 and above
###################################################
cat(
  mean(payoffPR)*10,
  mean(payoff60th)*10,
  wilcox.test(payoffPR,payoff60th, alternative = "less")$p.value
) 
cat(
  mean(minPR), 
  mean(min60th),
  mean(freqPR),
  mean(freq60th),
  mean(fcPR),
  mean(fc60th),
  mean(eqbmPR),
  mean(eqbm60th), "\n",
  wilcox.test(minPR,min60th, alternative = "less")$p.value, 
  wilcox.test(freqPR,freq60th, alternative = "less")$p.value,
  wilcox.test(fcPR,fc60th, alternative = "less")$p.value,
  wilcox.test(eqbmPR,eqbm60th, alternative = "greater")$p.value
)
# Percentage loss from lack of credibility
100*(mean(payoff60th)*10-mean(payoffPR)*10)/(mean(payoffPR)*10)
###########################
# Figure 4a and Figure 4b #
###########################
gg_Figure4a
gg_Figure4b
#############################
# Richness of Communication #
#############################
options("scipen"=2, "digits"=3)
#
cat(
  10*mean(g),
  10*mean(h),
  mean(gM),
  mean(hM),
  mean(gF),
  mean(hF),
  mean(gC),
  mean(hC),
  mean(gE),
  mean(hE), "\n",
  wilcox.test(g,h)$p.value,
  wilcox.test(gM,hM)$p.value,
  wilcox.test(gF,hF)$p.value,
  wilcox.test(gC,hC)$p.value,
  wilcox.test(gE,hE)$p.value
)
#
# END of the main results
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
######################################################
## PART 5 ## additional analyses for online Appendix #
######################################################
#   Figure D1a and Figure D1b   #
#################################
#
df_NG1 <- merge(MinimumEffort, EqbmDevTreatment, by = "Treatment")
df_NG1$Treatment <- c("Baseline","I-RM","R-RM","R-CT","RM","RM-VHBB","R-R-CT","S-CT","S-RM")
df_NG1$auxiOrder <- c(1,6,7,3,9,8,4,2,5)
df_NG1$Treatment <- reorder(df_NG1$Treatment, df_NG1$auxiOrder)
#
gg_FigureD1a <- ggplot(df_NG1) + 
  geom_point(aes(x = MinTreatment, y = EqbmDevTreatment, fill = Treatment,
                 group = Treatment, shape = Treatment), size = 8) +
  scale_x_continuous(expand = c(0, 0), limits = c(1, 7)) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 1.75)) +
  scale_shape_manual(values=c(20,7,10,12,24,25,22,23,21)) +
  scale_fill_manual(name = "Treatment", values = c("#d4b481","#99de99","#63ab63","#3b943b","#BEAED4",
                                                   "#837399","lightskyblue","dodgerblue","dodgerblue3")) +
  xlab("\n Average Minimum Effort") + ylab("Average Equilibrium Deviation \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times")) +
  theme(plot.title = element_text(hjust = 0.5)) + 
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(legend.position=c(.3,.77),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("bottom")) + 
  theme(legend.key.width=unit(5,"line"))
gg_FigureD1a
#
#######################
#
df_NG2 <- merge(AverageEffort, MedianActionTreatment, by = "Treatment")
df_NG2$Treatment <- c("Baseline","I-RM","R-RM","R-CT","RM","RM-VHBB","R-R-CT","S-CT","S-RM")
df_NG2$auxiOrder <- c(1,6,7,3,9,8,4,2,5)
df_NG2$Treatment <- reorder(df_NG2$Treatment, df_NG2$auxiOrder)
#
gg_FigureD1b <- ggplot(df_NG2) + 
  geom_point(aes(x = AverageEffort, y = MedianAction, group = Treatment, shape = Treatment, fill = Treatment), size = 8) +
  scale_x_continuous(expand = c(0, 0), limits = c(1, 7)) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 1)) +
  scale_shape_manual(values=c(20,7,10,12,24,25,22,23,21)) +
  scale_fill_manual(name = "Treatment", values = c("#d4b481","#99de99","#63ab63","#3b943b","#BEAED4",
                                                   "#837399","lightskyblue","dodgerblue","dodgerblue3")) +
  xlab("\n Average Effort") + ylab("Coordination on Median Action \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times")) +
  #ggtitle("Fully Coordinated Groups") +
  theme(plot.title = element_text(hjust = 0.5)) + 
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(legend.position=c(.3,.77),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("bottom")) + 
  theme(legend.key.width=unit(5,"line"))
gg_FigureD1b
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD1a.eps",height=8,width=12)
print(gg_FigureD1a)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD1b.eps",height=8,width=12)
print(gg_FigureD1b)
dev.off()
#######################################################
#
#           Moving graphs          #
#
#######################################################
# Message data frame: DF_AE_L
# Initial choice data frame: DF_InitialChoice
InitialChoiceMinimumEffort_auxi1  <- ddply(DF_InitialChoice, .(Treatment, GroupID, Round), summarise, InitialMinEffort =  min(InitialChoice))
InitialChoiceMinimumEffort_auxi2  <- ddply(InitialChoiceMinimumEffort_auxi1, .(Treatment, Round), summarise, InitialMinEffortR =  mean(InitialMinEffort))
InitialChoiceMinimumEffort  <- ddply(InitialChoiceMinimumEffort_auxi2, .(Treatment), summarise, InitialMinEffortTreatment =  mean(InitialMinEffortR))
#
InitialChoiceEqbmDeviation_auxi1 <- ddply(DF_InitialChoice, .(Treatment, Round, GroupID), plyr::summarize, EqDevGroup = mean(as.numeric(InitialChoice) - min(as.numeric(InitialChoice)) ))
InitialChoiceEqbmDeviation_auxi2 <- ddply(InitialChoiceEqbmDeviation_auxi1, .(Treatment,Round), plyr::summarize, EqbmDevRound=mean(EqDevGroup))
InitialChoiceEqbmDeviation <- ddply(InitialChoiceEqbmDeviation_auxi2, .(Treatment), plyr::summarize, InitialEqbmDevTreatment=mean(EqbmDevRound))
#
InitialChoiceAverageEffort_auxi1  <- ddply(DF_InitialChoice, .(Treatment, GroupID, Round), summarise, InitialAverageEffort =  mean(InitialChoice))
InitialChoiceAverageEffort_auxi2  <- ddply(InitialChoiceAverageEffort_auxi1, .(Treatment, Round), summarise, InitialAverageR =  mean(InitialAverageEffort))
InitialChoiceAverageEffort  <- ddply(InitialChoiceAverageEffort_auxi2, .(Treatment), summarise, InitialAverageEffortTreatment =  mean(InitialAverageR))
#
InitialChoiceMedianActionCoordination_auxi1 <- ddply(DF_InitialChoice, .(Treatment, GroupID, Round), summarise, CoordMedian =  mean(InitialChoice == median(InitialChoice)))
InitialChoiceMedianActionCoordination_auxi2 <- ddply(InitialChoiceMedianActionCoordination_auxi1, .(Treatment, Round), summarise, CoordMedianR =  mean(CoordMedian))
InitialChoiceMedianActionCoordination <- ddply(InitialChoiceMedianActionCoordination_auxi2, .(Treatment), summarise, InitialCoordMedianTreatment =  mean(CoordMedianR))
#
# Message choice data frame: DF_AE_L
LastChoiceMinimumEffort_auxi1  <- ddply(DF_AE_L, .(Treatment, GroupID, Round), summarise, LastMinEffort =  min(LastChoice))
LastChoiceMinimumEffort_auxi2  <- ddply(LastChoiceMinimumEffort_auxi1, .(Treatment, Round), summarise, LastMinEffortR =  mean(LastMinEffort))
MessageMinimumEffort  <- ddply(LastChoiceMinimumEffort_auxi2, .(Treatment), summarise, LastMinEffortTreatment =  mean(LastMinEffortR))
#
LastChoiceEqbmDeviation_auxi1 <- ddply(DF_AE_L, .(Treatment, Round, GroupID), plyr::summarize, EqDevGroup = mean(as.numeric(LastChoice) - min(as.numeric(LastChoice)) ))
LastChoiceEqbmDeviation_auxi2 <- ddply(LastChoiceEqbmDeviation_auxi1, .(Treatment,Round), plyr::summarize, EqbmDevRound=mean(EqDevGroup))
MessageEqbmDeviation <- ddply(LastChoiceEqbmDeviation_auxi2, .(Treatment), plyr::summarize, LastEqbmDevTreatment=mean(EqbmDevRound))
#
LastChoiceAverageEffort_auxi1  <- ddply(DF_AE_L, .(Treatment, GroupID, Round), summarise, LastAverageEffort =  mean(LastChoice))
LastChoiceAverageEffort_auxi2  <- ddply(LastChoiceAverageEffort_auxi1, .(Treatment, Round), summarise, LastAverageR =  mean(LastAverageEffort))
MessageAverageEffort  <- ddply(LastChoiceAverageEffort_auxi2, .(Treatment), summarise, LastAverageEffortTreatment =  mean(LastAverageR))
#
LastChoiceMedianActionCoordination_auxi1 <- ddply(DF_AE_L, .(Treatment, GroupID, Round), summarise, CoordMedian =  mean(LastChoice == median(LastChoice)))
LastChoiceMedianActionCoordination_auxi2 <- ddply(LastChoiceMedianActionCoordination_auxi1, .(Treatment, Round), summarise, CoordMedianR =  mean(CoordMedian))
MessageMedianActionCoordination <- ddply(LastChoiceMedianActionCoordination_auxi2, .(Treatment), summarise, LastCoordMedianTreatment =  mean(CoordMedianR))
#
InitialChoiceMinimumEffort
InitialChoiceEqbmDeviation
InitialChoiceAverageEffort
InitialChoiceMedianActionCoordination
#
MessageMinimumEffort
MessageEqbmDeviation
MessageAverageEffort
MessageMedianActionCoordination
MessageMinimumEffort$Treatment <- c("Revision Cheap Talk","Richer Revision Cheap Talk","Richer Revision Cheap Talk G","Standard Cheap Talk")
MessageEqbmDeviation$Treatment <- c("Revision Cheap Talk","Richer Revision Cheap Talk","Richer Revision Cheap Talk G","Standard Cheap Talk")
MessageAverageEffort$Treatment <- c("Revision Cheap Talk","Richer Revision Cheap Talk","Richer Revision Cheap Talk G","Standard Cheap Talk")
MessageMedianActionCoordination$Treatment <- c("Revision Cheap Talk","Richer Revision Cheap Talk","Richer Revision Cheap Talk G","Standard Cheap Talk")
#
# Payoff Relevant
#
MinimumEffort
EqbmDevTreatment
AverageEffort
MedianActionTreatment
#
# Graph with Minimum EFFORT and Equilibrium Deviation (Initial to PR)
#
#
auxi123 <- merge(InitialChoiceMinimumEffort,InitialChoiceEqbmDeviation, by.x ="Treatment",by.y ="Treatment", all = T, incomparables = T)
auxi1234 <- merge(auxi123,MessageMinimumEffort, by.x ="Treatment",by.y ="Treatment", all = T, incomparables = T)
auxi12345 <- merge(auxi1234,MessageEqbmDeviation, by.x ="Treatment",by.y ="Treatment", all = T, incomparables = T)
auxi123456 <- merge(auxi12345,MinimumEffort, by.x ="Treatment",by.y ="Treatment", all = T, incomparables = T)
auxi1234567 <- merge(auxi123456,EqbmDevTreatment, by.x ="Treatment",by.y ="Treatment", all = T, incomparables = T)
names(auxi1234567) <- c("Treatment",
                            "Initial_ME","Initial_ED",
                            "Message_ME","Message_ED",
                            "PR_ME","PR_ED")
#
# Part of Table C.1 --- column PR_ED is ED(PR) in the table
auxi1234567
#
# Calculate number of rounds in which no subject used a revision (no revision frequency)
#
NoRevisionFrequencyAuxiIND<- matrix(-2,nrow(moved),10)
#
for(i in 1:nrow(moved)){
  for(k in 1:10){
    rangeRound <- (60*(k-1)+1):(k*60-1)
    if(length(unique(moved[i,rangeRound]))== 1){ # True: no move
      NoRevisionFrequencyAuxiIND[i,k] <- 1 
    }
    if(length(unique(moved[i,rangeRound])) == 2){ # True: move
      NoRevisionFrequencyAuxiIND[i,k] <- 0
    }
  }
}
RMrows <- which(dataLONG$Treatment == "Revision Mechanism")
RMVHBBrows <- which(dataLONG$Treatment == "Revision Mechanism VHBB")
IRMrows <- which(dataLONG$Treatment == "Infrequent Revision Mechanism")
SRMrows <- which(dataLONG$Treatment == "Synchronous Revision Mechanism")
#
NoRevisionFrequencyAuxi2 <- data.frame(dataLONG$Treatment[c(RMrows,RMVHBBrows,IRMrows,SRMrows)],dataLONG$GroupID[c(RMrows,RMVHBBrows,IRMrows,SRMrows)],
                                       NoRevisionFrequencyAuxiIND[c(RMrows,RMVHBBrows,IRMrows,SRMrows),])
names(NoRevisionFrequencyAuxi2)[c(1,2)] <- c("Treatment","Group")
#
NoRevisionFrequencyAuxi3 <- gather(NoRevisionFrequencyAuxi2, Round, Revision, X1:X10)
names(NoRevisionFrequencyAuxi3)[c(1,2)] <- c("Treatment","Group")
#
NoRevisionFrequencyAuxi4 <- ddply(NoRevisionFrequencyAuxi3, .(Treatment, Group, Round), plyr::summarize, 
                                  GroupMoved = (sum(Revision) == 6) )

#
NoRevisionFrequencyAuxi5 <- ddply(NoRevisionFrequencyAuxi4, .(Treatment,Group), plyr::summarize, 
                                  TreatmentMovedRound = mean(GroupMoved) )
NoRevisionFrequencyAuxi6 <- ddply(NoRevisionFrequencyAuxi5, .(Treatment), plyr::summarize, 
                                  TreatmentMoved = mean(TreatmentMovedRound) )
# Part of Table C.1 (NRF)
NoRevisionFrequencyAuxi6
#
#
#
df_auxiliary_1 <- gather(auxi1234567, TypeME, ME, c(Initial_ME,Message_ME,PR_ME))
df_auxiliary_2 <- gather(auxi1234567, TypeED, ED, c(Initial_ED,Message_ED,PR_ED))
#
DF_Fancy_GRAPH_1 <- data.frame(df_auxiliary_1,df_auxiliary_2)
#
DF_Fancy_GRAPH_1_df <-  DF_Fancy_GRAPH_1
DF_Fancy_GRAPH_1_df$ME[DF_Fancy_GRAPH_1_df$Treatment == "Standard Cheap Talk" & DF_Fancy_GRAPH_1_df$TypeME == "Initial_ME"] <- 
  unique(DF_Fancy_GRAPH_1_df$Message_ME[DF_Fancy_GRAPH_1_df$Treatment == "Standard Cheap Talk"]) 
DF_Fancy_GRAPH_1_df$ED[DF_Fancy_GRAPH_1_df$Treatment == "Standard Cheap Talk" & DF_Fancy_GRAPH_1_df$TypeED == "Initial_ED"] <- 
  unique(DF_Fancy_GRAPH_1_df$Message_ED[DF_Fancy_GRAPH_1_df$Treatment == "Standard Cheap Talk"]) #
DF_Fancy_GRAPH_1_df <- DF_Fancy_GRAPH_1_df[DF_Fancy_GRAPH_1_df$TypeED != "Message_ED"& DF_Fancy_GRAPH_1_df$Treatment != "Richer Revision Cheap Talk G",]
#
DF_Fancy_GRAPH_1_df$TypeED[DF_Fancy_GRAPH_1_df$TypeED=="Initial_ED"] <- c("Initial Message")
DF_Fancy_GRAPH_1_df$TypeED[DF_Fancy_GRAPH_1_df$TypeED=="PR_ED"] <- c("Payoff Relevant")
####
#
DF_Fancy_GRAPH_2 <- data.frame(df_auxiliary_1,df_auxiliary_2)
DF_Fancy_GRAPH_2_df <-  DF_Fancy_GRAPH_2
DF_Fancy_GRAPH_2_df <- DF_Fancy_GRAPH_2_df[DF_Fancy_GRAPH_2_df$TypeED != "Initial_ED"& 
                                             DF_Fancy_GRAPH_2_df$Treatment != "Richer Revision Cheap Talk G" &
                                             DF_Fancy_GRAPH_2_df$Treatment != "Standard Cheap Talk",]
#
DF_Fancy_GRAPH_2_df$TypeED[DF_Fancy_GRAPH_2_df$TypeED=="Message_ED"] <- c("60th Message")
DF_Fancy_GRAPH_2_df$TypeED[DF_Fancy_GRAPH_2_df$TypeED=="PR_ED"] <- c("Payoff Relevant")
#
# 
# Graph with Average EFFORT and Coordination on Median Choice (Initial to PR) alaba
#
#
auxiTT123 <- merge(InitialChoiceAverageEffort,InitialChoiceMedianActionCoordination, by.x ="Treatment",by.y ="Treatment", all = T, incomparables = T)
auxiTT1234 <- merge(auxiTT123,MessageAverageEffort, by.x ="Treatment",by.y ="Treatment", all = T, incomparables = T)
auxiTT12345 <- merge(auxiTT1234,MessageMedianActionCoordination, by.x ="Treatment",by.y ="Treatment", all = T, incomparables = T)
auxiTT123456 <- merge(auxiTT12345,AverageEffort, by.x ="Treatment",by.y ="Treatment", all = T, incomparables = T)
auxiTT1234567 <- merge(auxiTT123456,MedianActionTreatment, by.x ="Treatment",by.y ="Treatment", all = T, incomparables = T)
names(auxiTT1234567) <- c("Treatment",
                          "Initial_AE","Initial_MedE",
                          "Message_AE","Message_MedE",
                          "PR_AE","PR_MedE")
auxiTT1234567
#
#
df_auxiTTliary_1 <- gather(auxiTT1234567, TypeAE, AE, c(Initial_AE,Message_AE,PR_AE))
df_auxiTTliary_2 <- gather(auxiTT1234567, TypeEDMedE, MedE, c(Initial_MedE,Message_MedE,PR_MedE))
#
DF_Fancy_GRAPH_1TT <- data.frame(df_auxiTTliary_1,df_auxiTTliary_2)
#
#RMinitial <- subset(InitialData_DF, Treatment == "Revision Mechanism", select = c(5:14))
#
DF_Fancy_GRAPH_1TT_df <-  DF_Fancy_GRAPH_1TT
DF_Fancy_GRAPH_1TT_df$AE[DF_Fancy_GRAPH_1TT_df$Treatment == "Standard Cheap Talk" & DF_Fancy_GRAPH_1TT_df$TypeAE == "Initial_AE"] <- 
  unique(DF_Fancy_GRAPH_1TT_df$Message_AE[DF_Fancy_GRAPH_1TT_df$Treatment == "Standard Cheap Talk"]) 
DF_Fancy_GRAPH_1TT_df$MedE[DF_Fancy_GRAPH_1TT_df$Treatment == "Standard Cheap Talk" & DF_Fancy_GRAPH_1TT_df$TypeEDMedE == "Initial_MedE"] <- 
  unique(DF_Fancy_GRAPH_1TT_df$Message_MedE[DF_Fancy_GRAPH_1TT_df$Treatment == "Standard Cheap Talk"]) #
DF_Fancy_GRAPH_1TT_df <- DF_Fancy_GRAPH_1TT_df[DF_Fancy_GRAPH_1TT_df$TypeEDMedE != "Message_MedE"& DF_Fancy_GRAPH_1TT_df$Treatment != "Richer Revision Cheap Talk G",]
#
DF_Fancy_GRAPH_1TT_df$TypeEDMedE[DF_Fancy_GRAPH_1TT_df$TypeEDMedE=="Initial_MedE"] <- c("Initial Message")
DF_Fancy_GRAPH_1TT_df$TypeEDMedE[DF_Fancy_GRAPH_1TT_df$TypeEDMedE=="PR_MedE"] <- c("Payoff Relevant")
#
################################################
#    Average and Minimum over 60 seconds       #
################################################
##               Figure D7                    ##
################################################ 
#
dataAuxi1 <- dataLONG
dataD <- gather(dataLONG, Round, Effort, X1:X600)
#
options(digits=2)
#
DFDave <- dataD
#
clean <- function(x) as.numeric(gsub("X", "", x))
DFDave$Round <- (as.numeric(lapply(DFDave$Round, clean)))
#
Mean60group <- ddply(DFDave, .(GroupID, Treatment, Round), summarise, GroupMean60 = mean(Effort))
Mean60 <- ddply(Mean60group, .(Treatment, Round), summarise, MeanOver60 = mean(GroupMean60))
Mean60use <- ddply(Mean60group, .(Treatment, Round), summarise, MeanOver60 = mean(GroupMean60))
#
Min60group <- ddply(DFDave, .(GroupID, Treatment, Round), summarise, GroupMin60 = min(Effort))
Min60 <- ddply(Min60group, .(Treatment, Round), summarise, MinOver60 = mean(GroupMin60))
Min60use <- ddply(Min60group, .(Treatment, Round), summarise, MinOver60 = mean(GroupMin60))
#
#
Mean60$Round <- Mean60$Round %% 60 # Modulo operator to combine all the 1st, 2nd, etc seconds
Mean60$Round[Mean60$Round == 0] <- 60
unique(Mean60$Round)
Min60$Round <- Min60$Round %% 60 # Modulo operator to combine all the 1st, 2nd, etc seconds
Min60$Round[Min60$Round == 0] <- 60
unique(Min60$Round)
#
Mean60n <- ddply(Mean60, .(Treatment, Round), summarise, MeanOver60n = mean(MeanOver60))
Min60n <- ddply(Min60, .(Treatment, Round), summarise, MinOver60n = mean(MinOver60))
#
#
#
gg_FigureD7a.1 <- ggplot(Mean60n[Mean60n$Treatment == "Revision Cheap Talk"|
                                      Mean60n$Treatment == "Revision Mechanism",]) +
  geom_line(aes((Round), (MeanOver60n), group = Treatment, colour = Treatment
                , linetype = Treatment), 
            size = 2) +
  geom_vline(xintercept = 60, size=1) +
  scale_y_continuous(expand = c(0, 0), limits = c(1, 7)) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 61)) +
  scale_colour_manual(name = "Treatment", values = c("#7FC97F","dodgerblue")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  xlab("\n Seconds") + #ylim(0,1.3) +
  ylab("Average Effort \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(legend.position=c(.38,.32),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("top")) + 
  theme(legend.key.width=unit(5,"line"))
gg_FigureD7a.1
#
gg_FigureD7b.1 <- ggplot(Min60n[Min60n$Treatment == "Revision Cheap Talk"|
                                     Min60n$Treatment == "Revision Mechanism",]) +
  geom_line(aes((Round), (MinOver60n), group = Treatment, colour = Treatment
                , linetype = Treatment), 
            size = 2) +
  geom_vline(xintercept = 60, size=1) +
  scale_y_continuous(expand = c(0, 0), limits = c(1, 7)) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 61)) +
  scale_colour_manual(name = "Treatment", values = c("#7FC97F","dodgerblue")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  xlab("\n Seconds") + #ylim(0,1.3) +
  ylab("Minimum Effort \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(legend.position=c(.38,.32),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("top")) + 
  theme(legend.key.width=unit(5,"line"))
gg_FigureD7b.1
#
gg_FigureD7a.2 <- ggplot(Mean60n[Mean60n$Treatment == "Random Revision Mechanism"|
                                       Mean60n$Treatment == "Revision Mechanism VHBB",]) +
  geom_line(aes((Round), (MeanOver60n), group = Treatment, colour = Treatment
                , linetype = Treatment), 
            size = 2) +
  geom_vline(xintercept = 60, size=1) +
  scale_y_continuous(expand = c(0, 0), limits = c(1, 7)) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 61)) +
  scale_colour_manual(name = "Treatment", values = c("lightskyblue","dodgerblue3")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  xlab("\n Seconds") + #ylim(0,1.3) +
  ylab("Average Effort \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(legend.position=c(.47,.32),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("top")) + 
  theme(legend.key.width=unit(5,"line"))
gg_FigureD7a.2
#
gg_FigureD7b.2 <- ggplot(Min60n[Min60n$Treatment == "Random Revision Mechanism"|
                                  Min60n$Treatment == "Revision Mechanism VHBB",]) +
  geom_line(aes((Round), (MinOver60n), group = Treatment, colour = Treatment
                , linetype = Treatment), 
            size = 2) +
  geom_vline(xintercept = 60, size=1) +
  scale_y_continuous(expand = c(0, 0), limits = c(1, 7)) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 61)) +
  scale_colour_manual(name = "Treatment", values = c("lightskyblue","dodgerblue3")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  xlab("\n Seconds") + #ylim(0,1.3) +
  ylab("Minimum Effort \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(legend.position=c(.8,.32),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("top")) + 
  theme(legend.key.width=unit(5,"line"))
gg_FigureD7b.2
#
gg_FigureD7a.3 <- ggplot(Mean60n[Mean60n$Treatment == "Infrequent Revision Mechanism"|
                                                Mean60n$Treatment == "Synchronous Revision Mechanism",]) +
  geom_line(aes((Round), (MeanOver60n), group = Treatment, colour = Treatment
                , linetype = Treatment), 
            size = 2) +
  geom_vline(xintercept = 60, size=1) +
  scale_y_continuous(expand = c(0, 0), limits = c(1, 7)) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 61)) +
  scale_colour_manual(name = "Treatment", values = c("#BEAED4","#837399")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  xlab("\n Seconds") + #ylim(0,1.3) +
  ylab("Average Effort \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(legend.position=c(.52,.32),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("top")) + 
  theme(legend.key.width=unit(5,"line"))
gg_FigureD7a.3
#
gg_FigureD7b.3 <- ggplot(Min60n[Min60n$Treatment == "Infrequent Revision Mechanism"|
                                           Min60n$Treatment == "Synchronous Revision Mechanism",]) +
  geom_line(aes((Round), (MinOver60n), group = Treatment, colour = Treatment
                , linetype = Treatment), 
            size = 2) +
  geom_vline(xintercept = 60, size=1) +
  scale_y_continuous(expand = c(0, 0), limits = c(1, 7)) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 61)) +
  scale_colour_manual(name = "Treatment", values = c("#BEAED4","#837399")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  xlab("\n Seconds") + #ylim(0,1.3) +
  ylab("Minimum Effort \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(legend.position=c(.52,.32),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("top")) + 
  theme(legend.key.width=unit(5,"line"))
gg_FigureD7b.3
#
gg_FigureD7a.4 <- ggplot(Mean60n[Mean60n$Treatment == "Revision Cheap Talk"|
                                             Mean60n$Treatment == "Richer Revision Cheap Talk",]) +
  geom_line(aes((Round), (MeanOver60n), group = Treatment, colour = Treatment
                , linetype = Treatment), 
            size = 2) +
  geom_vline(xintercept = 60, size=1) +
  scale_y_continuous(expand = c(0, 0), limits = c(1, 7)) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 61)) +
  scale_colour_manual(name = "Treatment", values = c("#63ab63","#3b943b")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  xlab("\n Seconds") + #ylim(0,1.3) +
  ylab("Average Effort \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(legend.position=c(.45,.32),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("top")) + 
  theme(legend.key.width=unit(5,"line"))
gg_FigureD7a.4
#
gg_FigureD7b.4 <- ggplot(Min60n[Min60n$Treatment == "Revision Cheap Talk"|
                                        Min60n$Treatment == "Richer Revision Cheap Talk",]) +
  geom_line(aes((Round), (MinOver60n), group = Treatment, colour = Treatment
                , linetype = Treatment), 
            size = 2) +
  geom_vline(xintercept = 60, size=1) +
  scale_y_continuous(expand = c(0, 0), limits = c(1, 7)) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 61)) +
  scale_colour_manual(name = "Treatment", values = c("#63ab63","#3b943b")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  xlab("\n Seconds") + #ylim(0,1.3) +
  ylab("Minimum Effort \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(legend.position=c(.45,.32),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("top")) + 
  theme(legend.key.width=unit(5,"line"))
gg_FigureD7b.4
#
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD7a.1.eps",height=6,width=12)
print(gg_FigureD7a.1)
dev.off()
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD7a.2.eps",height=6,width=12)
print(gg_FigureD7a.2)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD7a.3.eps",height=6,width=12)
print(gg_FigureD7a.3)
dev.off()
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD7a.4.eps",height=6,width=12)
print(gg_FigureD7a.4)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD7b.1.eps",height=6,width=12)
print(gg_FigureD7b.1)
dev.off()
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD7b.2.eps",height=6,width=12)
print(gg_FigureD7b.2)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD7b.3.eps",height=6,width=12)
print(gg_FigureD7b.3)
dev.off()
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD7b.4.eps",height=6,width=12)
print(gg_FigureD7b.4)
dev.off()
#
#
#################################
# Figure D10a and Figure D10b   #
#################################
gg_FigureD10a <- ggplot(Mean60n[Mean60n$Treatment == "Infrequent Revision Mechanism"|
                                       Mean60n$Treatment == "Revision Mechanism",]) +
  geom_line(aes((Round), (MeanOver60n), group = Treatment, colour = Treatment
                , linetype = Treatment), 
            size = 2) +
  geom_vline(xintercept = 60, size=1) +
  scale_y_continuous(expand = c(0, 0), limits = c(1, 7)) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 61)) +
  scale_colour_manual(name = "Treatment", values = c("#7FC97F","dodgerblue")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  xlab("\n Seconds") + #ylim(0,1.3) +
  ylab("Average Effort \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(legend.position=c(.54,.25),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("top")) + 
  theme(legend.key.width=unit(5,"line"))
gg_FigureD10a
#
gg_FigureD10b <- ggplot(Min60n[Min60n$Treatment == "Infrequent Revision Mechanism"|
                                  Min60n$Treatment == "Revision Mechanism",]) +
  geom_line(aes((Round), (MinOver60n), group = Treatment, colour = Treatment
                , linetype = Treatment), 
            size = 2) +
  geom_vline(xintercept = 60, size=1) +
  scale_y_continuous(expand = c(0, 0), limits = c(1, 7)) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 61)) +
  scale_colour_manual(name = "Treatment", values = c("#7FC97F","dodgerblue")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  xlab("\n Seconds") + #ylim(0,1.3) +
  ylab("Minimum Effort \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(legend.position=c(.54,.25),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("top")) + 
  theme(legend.key.width=unit(5,"line"))
gg_FigureD10b
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD10a.eps",height=8,width=12)
print(gg_FigureD10a)
dev.off()
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD10b.eps",height=8,width=12)
print(gg_FigureD10b)
dev.off()
################################################
#       Figure D11a and Figure D11b            #
################################################ 
#
dataAuxi1 <- dataLONG_choices
dataC <- gather(dataLONG_choices, Round, Effort, X1:X600)
#
options(digits=2)
#
DFDaveCHOICE <- dataC
#
clean <- function(x) as.numeric(gsub("X", "", x))
DFDaveCHOICE$Round <- (as.numeric(lapply(DFDaveCHOICE$Round, clean)))
#
Mean60groupCHOICE <- ddply(DFDaveCHOICE, .(GroupID, Treatment, Round), summarise, GroupMean60 = mean(Effort))
Mean60CHOICE <- ddply(Mean60groupCHOICE, .(Treatment, Round), summarise, MeanOver60 = mean(GroupMean60))
Mean60use <- ddply(Mean60groupCHOICE, .(Treatment, Round), summarise, MeanOver60 = mean(GroupMean60))
#
Min60groupCHOICE <- ddply(DFDaveCHOICE, .(GroupID, Treatment, Round), summarise, GroupMin60 = min(Effort))
Min60CHOICE <- ddply(Min60groupCHOICE, .(Treatment, Round), summarise, MinOver60 = mean(GroupMin60))
Min60use <- ddply(Min60groupCHOICE, .(Treatment, Round), summarise, MinOver60 = mean(GroupMin60))
#
#
Mean60CHOICE$Round <- Mean60CHOICE$Round %% 60 # Modulo operator to combine all the 1st, 2nd, etc seconds
Mean60CHOICE$Round[Mean60CHOICE$Round == 0] <- 60
unique(Mean60CHOICE$Round)
Min60CHOICE$Round <- Min60CHOICE$Round %% 60 # Modulo operator to combine all the 1st, 2nd, etc seconds
Min60CHOICE$Round[Min60CHOICE$Round == 0] <- 60
unique(Min60CHOICE$Round)
#
Mean60n <- ddply(Mean60CHOICE, .(Treatment, Round), summarise, MeanOver60n = mean(MeanOver60))
Min60n <- ddply(Min60CHOICE, .(Treatment, Round), summarise, MinOver60n = mean(MinOver60))
#

#
gg_FigureD11a <- ggplot(Mean60n[Mean60n$Treatment == "Infrequent Revision Mechanism"|
                                             Mean60n$Treatment == "Revision Mechanism",]) +
  geom_line(aes((Round), (MeanOver60n), group = Treatment, colour = Treatment
                , linetype = Treatment), 
            size = 2) +
  geom_vline(xintercept = 60, size=1) +
  scale_y_continuous(expand = c(0, 0), limits = c(1, 7)) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 61)) +
  scale_colour_manual(name = "Treatment", values = c("#7FC97F","dodgerblue")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  xlab("\n Seconds") + #ylim(0,1.3) +
  ylab("Average Effort \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(legend.position=c(.54,.25),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("top")) + 
  theme(legend.key.width=unit(5,"line"))
gg_FigureD11a
#
gg_FigureD11b <- ggplot(Min60n[Min60n$Treatment == "Infrequent Revision Mechanism"|
                                        Min60n$Treatment == "Revision Mechanism",]) +
  geom_line(aes((Round), (MinOver60n), group = Treatment, colour = Treatment
                , linetype = Treatment), 
            size = 2) +
  geom_vline(xintercept = 60, size=1) +
  scale_y_continuous(expand = c(0, 0), limits = c(1, 7)) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 61)) +
  scale_colour_manual(name = "Treatment", values = c("#7FC97F","dodgerblue")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  xlab("\n Seconds") + #ylim(0,1.3) +
  ylab("Minimum Effort \n") +  
  theme_bw(base_size = 25) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", colour ="grey")) + 
  theme(legend.position=c(.54,.25),legend.justification=c(1,1),
        legend.direction="vertical",
        legend.box="horizontal",
        legend.box.just = c("top")) + 
  theme(legend.key.width=unit(5,"line"))
gg_FigureD11b
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD11a.eps",height=8,width=12)
print(gg_FigureD11a)
dev.off()
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD11b.eps",height=8,width=12)
print(gg_FigureD11b)
dev.off()
##############################
#   Figure D8 and Figure D9  #
##############################
#
FigAuxi <- MinimumEffortRound[MinimumEffortRound$Treatment == "Revision Mechanism"|
  MinimumEffortRound$Treatment=="Revision Cheap Talk",]
FigAuxi2 <- ddply(MinimumEffortAuxi2, .(Treatment, Group, Round), plyr::summarize, 
                       AverageEffort=mean(as.numeric(Effort)))
FigAuxi3 <- ddply(FigAuxi2, .(Treatment, Round), plyr::summarize, 
                  AverageEffortRound=mean(as.numeric(AverageEffort)))
FigAuxi4 <- FigAuxi3[FigAuxi3$Treatment == "Revision Mechanism"| 
                       FigAuxi3$Treatment == "Revision Cheap Talk"|
                       FigAuxi3$Treatment == "Baseline",]
#
FigAuxi4$Round <- as.numeric(FigAuxi4$Round)*60
FigAuxi$Round <- as.numeric(FigAuxi$Round)*60
#
ForContGraphsMin <- MinimumEffortRound
ForContGraphsMin$Round <-  as.numeric(ForContGraphsMin$Round)*60
#
ForContGraphsAve <- FigAuxi3
ForContGraphsAve$Round <-  as.numeric(ForContGraphsAve$Round)*60 
#
#
FigureD9.1 <- ggplot(Mean60use[Mean60use$Treatment=="Revision Mechanism"|
                                 Mean60use$Treatment=="Revision Cheap Talk",]) +
  geom_line(aes(x=Round, y=MeanOver60, group = Treatment, color = Treatment, linetype = Treatment),size = .71)+
  geom_vline(xintercept = 60) + geom_vline(xintercept = 2*60) + geom_vline(xintercept = 3*60) + 
  geom_vline(xintercept = 4*60) + geom_vline(xintercept = 5*60) + geom_vline(xintercept = 6*60) + 
  geom_vline(xintercept = 7*60) + geom_vline(xintercept = 8*60) + geom_vline(xintercept = 9*60) + 
  geom_vline(xintercept = 10*60) +geom_vline(xintercept = 0) + 
  #("#d4b481","#99de99","#63ab63","#3b943b","#BEAED4","#837399","lightskyblue","dodgerblue","dodgerblue3")) +
  scale_colour_manual(name = "Treatment", values = c("#d4b481","#63ab63","dodgerblue", "#99de99")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid", "dotted")) +
  geom_point(data=ForContGraphsAve[ForContGraphsAve$Treatment=="Baseline"|
                                     ForContGraphsAve$Treatment=="Revision Mechanism"|
                                     ForContGraphsAve$Treatment=="Revision Cheap Talk"|
                                     ForContGraphsAve$Treatment=="Standard Cheap Talk",],
             aes(x=Round, y=AverageEffortRound, shape = Treatment) ,size = 5) + 
  geom_point(data=ForContGraphsAve[ForContGraphsAve$Treatment=="Baseline"|
                                     ForContGraphsAve$Treatment=="Revision Mechanism"|
                                     ForContGraphsAve$Treatment=="Revision Cheap Talk"|
                                     ForContGraphsAve$Treatment=="Standard Cheap Talk",],
             aes(x=Round, y=AverageEffortRound, shape = Treatment, color = Treatment) ,size = 4) + 
  scale_shape_manual(values = c(15, 16,17,18)) + 
  xlab("Seconds") + ylim(1,7) + 
  scale_x_continuous(breaks = c(30,90,150,210,270,330,390,450,510,570), 
                     labels = c("Round 1", "Round 2", "Round 3", "Round 4", "Round 5", "Round 6", "Round 7", "Round 8", "Round 9", "Round 10")) +
  ylab("Average Effort") + 
  theme_bw(base_size = 18) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", 
                                         colour ="grey"), legend.key.size=unit(1.5,"cm")) +
  theme(legend.position="top") +
  guides(linetype = FALSE)

FigureD9.1
#
FigureD9.2 <- ggplot(Mean60use[Mean60use$Treatment=="Random Revision Mechanism"|
                                 Mean60use$Treatment=="Revision Mechanism VHBB",]) +
  geom_line(aes(x=Round, y=MeanOver60, group = Treatment, color = Treatment, linetype = Treatment),size = .71)+
  geom_vline(xintercept = 60) + geom_vline(xintercept = 2*60) + geom_vline(xintercept = 3*60) + 
  geom_vline(xintercept = 4*60) + geom_vline(xintercept = 5*60) + geom_vline(xintercept = 6*60) + 
  geom_vline(xintercept = 7*60) + geom_vline(xintercept = 8*60) + geom_vline(xintercept = 9*60) + 
  geom_vline(xintercept = 10*60) +geom_vline(xintercept = 0) + 
  scale_colour_manual(name = "Treatment", values = c("lightskyblue","dodgerblue3")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  geom_point(data=ForContGraphsAve[ForContGraphsAve$Treatment=="Random Revision Mechanism"|
                                     ForContGraphsAve$Treatment=="Revision Mechanism VHBB",],  aes(x=Round,y=AverageEffortRound,shape = Treatment) ,size = 5) + 
  geom_point(data=ForContGraphsAve[ForContGraphsAve$Treatment=="Random Revision Mechanism"|
                                     ForContGraphsAve$Treatment=="Revision Mechanism VHBB",],  aes(x=Round,y=AverageEffortRound,shape = Treatment, color = Treatment) ,size = 4) + 
  xlab("Seconds") + ylim(1,7) + 
  scale_x_continuous(breaks = c(30,90,150,210,270,330,390,450,510,570), 
                     labels = c("Round 1", "Round 2", "Round 3", "Round 4", "Round 5", "Round 6", "Round 7", "Round 8", "Round 9", "Round 10")) +
  ylab("Average Effort") + 
  theme_bw(base_size = 18) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", 
                                         colour ="grey"),
        legend.key.size=unit(1,"cm")) +
  theme(legend.position="top")

FigureD9.2
#
# Long graphs for other treatments
#
FigureD9.3 <- ggplot(Mean60use[Mean60use$Treatment=="Infrequent Revision Mechanism"|
                                 Mean60use$Treatment=="Synchronous Revision Mechanism",]) +
  geom_line(aes(x=Round, y=MeanOver60, group = Treatment, color = Treatment, linetype = Treatment),size = .71)+
  geom_vline(xintercept = 60) + geom_vline(xintercept = 2*60) + geom_vline(xintercept = 3*60) + 
  geom_vline(xintercept = 4*60) + geom_vline(xintercept = 5*60) + geom_vline(xintercept = 6*60) + 
  geom_vline(xintercept = 7*60) + geom_vline(xintercept = 8*60) + geom_vline(xintercept = 9*60) + 
  geom_vline(xintercept = 10*60) +geom_vline(xintercept = 0) + 
  scale_colour_manual(name = "Treatment", values = c("#BEAED4","#837399")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  geom_point(data=ForContGraphsAve[ForContGraphsAve$Treatment=="Infrequent Revision Mechanism"|
                                     ForContGraphsAve$Treatment=="Synchronous Revision Mechanism",],  aes(x=Round,y=AverageEffortRound,shape = Treatment) ,size = 5) + 
  geom_point(data=ForContGraphsAve[ForContGraphsAve$Treatment=="Infrequent Revision Mechanism"|
                                     ForContGraphsAve$Treatment=="Synchronous Revision Mechanism",],  aes(x=Round,y=AverageEffortRound,shape = Treatment, color = Treatment) ,size = 4) + 
  
  xlab("Seconds") + ylim(1,7) + 
  scale_x_continuous(breaks = c(30,90,150,210,270,330,390,450,510,570), 
                     labels = c("Round 1", "Round 2", "Round 3", "Round 4", "Round 5", "Round 6", "Round 7", "Round 8", "Round 9", "Round 10")) +
  ylab("Average Effort") + 
  theme_bw(base_size = 18) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", 
                                         colour ="grey"),
        legend.key.size=unit(1,"cm")) +
  theme(legend.position="top")

FigureD9.3
#
#
#
# Long graphs for other treatments
#
FigureD9.4 <- ggplot(Mean60use[Mean60use$Treatment=="Revision Cheap Talk"|
                                 Mean60use$Treatment=="Richer Revision Cheap Talk",]) +
  geom_line(aes(x=Round, y=MeanOver60, group = Treatment, color = Treatment, linetype = Treatment),size = .71)+
  geom_vline(xintercept = 60) + geom_vline(xintercept = 2*60) + geom_vline(xintercept = 3*60) + 
  geom_vline(xintercept = 4*60) + geom_vline(xintercept = 5*60) + geom_vline(xintercept = 6*60) + 
  geom_vline(xintercept = 7*60) + geom_vline(xintercept = 8*60) + geom_vline(xintercept = 9*60) + 
  geom_vline(xintercept = 10*60) +geom_vline(xintercept = 0) + 
  scale_colour_manual(name = "Treatment", values = c("#63ab63","#1f631f")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  geom_point(data=ForContGraphsAve[ForContGraphsAve$Treatment=="Revision Cheap Talk"|
                                     ForContGraphsAve$Treatment=="Richer Revision Cheap Talk",],  aes(x=Round,y=AverageEffortRound,shape = Treatment) ,size = 5) + 
  geom_point(data=ForContGraphsAve[ForContGraphsAve$Treatment=="Revision Cheap Talk"|
                                     ForContGraphsAve$Treatment=="Richer Revision Cheap Talk",],  aes(x=Round,y=AverageEffortRound,shape = Treatment, color = Treatment) ,size = 4) + 
  
  xlab("Seconds") + ylim(1,7) + 
  scale_x_continuous(breaks = c(30,90,150,210,270,330,390,450,510,570), 
                     labels = c("Round 1", "Round 2", "Round 3", "Round 4", "Round 5", "Round 6", "Round 7", "Round 8", "Round 9", "Round 10")) +
  ylab("Average Effort") + 
  theme_bw(base_size = 18) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", 
                                         colour ="grey"),
        legend.key.size=unit(1,"cm")) +
  theme(legend.position="top")

FigureD9.4
#
#
#
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD9.1.eps",height=4,width=12)
print(FigureD9.1)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD9.2.eps",height=4,width=12)
print(FigureD9.2)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD9.3.eps",height=4,width=12)
print(FigureD9.3)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD9.4.eps",height=4,width=12)
print(FigureD9.4)
dev.off()
#
#
#
FigureD8.1 <- ggplot(Min60use[Min60use$Treatment=="Revision Mechanism"|
                                            Min60use$Treatment=="Revision Cheap Talk",]) +
  geom_line(aes(x=Round, y=MinOver60, group = Treatment, color = Treatment, linetype = Treatment),size = .71)+
  geom_vline(xintercept = 60) + geom_vline(xintercept = 2*60) + geom_vline(xintercept = 3*60) + 
  geom_vline(xintercept = 4*60) + geom_vline(xintercept = 5*60) + geom_vline(xintercept = 6*60) + 
  geom_vline(xintercept = 7*60) + geom_vline(xintercept = 8*60) + geom_vline(xintercept = 9*60) + 
  geom_vline(xintercept = 10*60) +geom_vline(xintercept = 0) + 
  #("#d4b481","#99de99","#63ab63","#3b943b","#BEAED4","#837399","lightskyblue","dodgerblue","dodgerblue3")) +
  scale_colour_manual(name = "Treatment", values = c("#d4b481","#63ab63","dodgerblue", "#99de99")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid", "dotted")) +
  geom_point(data=ForContGraphsMin[ForContGraphsMin$Treatment=="Baseline"|
                                     ForContGraphsMin$Treatment=="Revision Mechanism"|
                                     ForContGraphsMin$Treatment=="Revision Cheap Talk"|
                                     ForContGraphsMin$Treatment=="Standard Cheap Talk",],
             aes(x=Round, y=MinRound, shape = Treatment) ,size = 5) + 
  geom_point(data=ForContGraphsMin[ForContGraphsMin$Treatment=="Baseline"|
                                     ForContGraphsMin$Treatment=="Revision Mechanism"|
                                     ForContGraphsMin$Treatment=="Revision Cheap Talk"|
                                     ForContGraphsMin$Treatment=="Standard Cheap Talk",],
             aes(x=Round, y=MinRound, shape = Treatment, color = Treatment) ,size = 4) + 
  scale_shape_manual(values = c(15, 16,17,18)) + 
  xlab("Seconds") + ylim(1,7) + 
  scale_x_continuous(breaks = c(30,90,150,210,270,330,390,450,510,570), 
                     labels = c("Round 1", "Round 2", "Round 3", "Round 4", "Round 5", "Round 6", "Round 7", "Round 8", "Round 9", "Round 10")) +
  ylab("Average Minimum Effort") + 
  theme_bw(base_size = 18) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", 
                                         colour ="grey"), legend.key.size=unit(1.5,"cm")) +
  theme(legend.position="top") +
  guides(linetype = FALSE)

FigureD8.1
#
LongGraphMinBRCTRM <- ggplot(Min60use[Min60use$Treatment=="Revision Mechanism"|
                                        Min60use$Treatment=="Revision Cheap Talk",]) +
  geom_line(aes(x=Round, y=MinOver60, group = Treatment, color = Treatment, linetype = Treatment),size = .71)+
  geom_vline(xintercept = 60) + geom_vline(xintercept = 2*60) + geom_vline(xintercept = 3*60) + 
  geom_vline(xintercept = 4*60) + geom_vline(xintercept = 5*60) + geom_vline(xintercept = 6*60) + 
  geom_vline(xintercept = 7*60) + geom_vline(xintercept = 8*60) + geom_vline(xintercept = 9*60) + 
  geom_vline(xintercept = 10*60) +geom_vline(xintercept = 0) + 
  #("#d4b481","#99de99","#63ab63","#3b943b","#BEAED4","#837399","lightskyblue","dodgerblue","dodgerblue3")) +
  scale_colour_manual(name = "Treatment", values = c("#d4b481", "#63ab63","dodgerblue")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  geom_vline(xintercept = 60) + geom_vline(xintercept = 2*60) + geom_vline(xintercept = 3*60) + 
  geom_vline(xintercept = 4*60) + geom_vline(xintercept = 5*60) + geom_vline(xintercept = 6*60) + 
  geom_vline(xintercept = 7*60) + geom_vline(xintercept = 8*60) + geom_vline(xintercept = 9*60) + 
  geom_vline(xintercept = 10*60) +geom_vline(xintercept = 0) + 
  geom_point(data=ForContGraphsMin[ForContGraphsMin$Treatment=="Revision Mechanism"|
                                     ForContGraphsMin$Treatment=="Revision Cheap Talk"|
                                     ForContGraphsMin$Treatment=="Baseline",],aes(x=Round, y=MinRound, shape = Treatment) ,size = 5) + 
  geom_point(data=ForContGraphsMin[ForContGraphsMin$Treatment=="Revision Mechanism"|
                                     ForContGraphsMin$Treatment=="Revision Cheap Talk"|
                                     ForContGraphsMin$Treatment=="Baseline",],aes(x=Round, y=MinRound, shape = Treatment, color = Treatment) ,size = 4) + 
  #geom_point(aes(x=Seconds, y=AverageM, shape=Treatment2) ,size = 4, colour="darkgreen") + 
  #geom_point(aes(x=Seconds, y=AverageP, shape=Treatment1) ,size = 4, colour="blue") + 
  #geom_line(aes(x=Seconds, y=PilotM) ,size = 3, colour="blue") + 
  xlab("Seconds") + ylim(1,7) + 
  scale_x_continuous(breaks = c(30,90,150,210,270,330,390,450,510,570), 
                     labels = c("Round 1", "Round 2", "Round 3", "Round 4", "Round 5", "Round 6", "Round 7", "Round 8", "Round 9", "Round 10")) +
  ylab("Average Minimum Effort") + 
  theme_bw(base_size = 18) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", 
                                         colour ="grey"), legend.key.size=unit(1,"cm")) +
  theme(legend.position="top") + guides(linetype = FALSE)

LongGraphMinBRCTRM
#
FigureD8.2 <- ggplot(Min60use[Min60use$Treatment=="Random Revision Mechanism"|
                                        Min60use$Treatment=="Revision Mechanism VHBB",]) +
  geom_line(aes(x=Round, y=MinOver60, group = Treatment, color = Treatment, linetype = Treatment),size = .71)+
  geom_vline(xintercept = 60) + geom_vline(xintercept = 2*60) + geom_vline(xintercept = 3*60) + 
  geom_vline(xintercept = 4*60) + geom_vline(xintercept = 5*60) + geom_vline(xintercept = 6*60) + 
  geom_vline(xintercept = 7*60) + geom_vline(xintercept = 8*60) + geom_vline(xintercept = 9*60) + 
  geom_vline(xintercept = 10*60) +geom_vline(xintercept = 0) + 
  #("#d4b481","#99de99","#63ab63","#3b943b","#BEAED4","#837399","lightskyblue","dodgerblue","dodgerblue3")) +
  scale_colour_manual(name = "Treatment", values = c( "lightskyblue","dodgerblue3")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  geom_vline(xintercept = 60) + geom_vline(xintercept = 2*60) + geom_vline(xintercept = 3*60) + 
  geom_vline(xintercept = 4*60) + geom_vline(xintercept = 5*60) + geom_vline(xintercept = 6*60) + 
  geom_vline(xintercept = 7*60) + geom_vline(xintercept = 8*60) + geom_vline(xintercept = 9*60) + 
  geom_vline(xintercept = 10*60) +geom_vline(xintercept = 0) + 
  geom_point(data=ForContGraphsMin[ForContGraphsMin$Treatment=="Random Revision Mechanism"|
                                     ForContGraphsMin$Treatment=="Revision Mechanism VHBB",],aes(x=Round, y=MinRound, shape = Treatment) ,size = 5) + 
  geom_point(data=ForContGraphsMin[ForContGraphsMin$Treatment=="Random Revision Mechanism"|
                                     ForContGraphsMin$Treatment=="Revision Mechanism VHBB",],aes(x=Round, y=MinRound, shape = Treatment, color = Treatment) ,size = 4) + 
  xlab("Seconds") + ylim(1,7) + 
  scale_x_continuous(breaks = c(30,90,150,210,270,330,390,450,510,570), 
                     labels = c("Round 1", "Round 2", "Round 3", "Round 4", "Round 5", "Round 6", "Round 7", "Round 8", "Round 9", "Round 10")) +
  ylab("Average Minimum Effort") + 
  theme_bw(base_size = 18) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", 
                                         colour ="grey"), legend.key.size=unit(1,"cm")) +
  theme(legend.position="top")

FigureD8.2
#
FigureD8.3 <- ggplot(Min60use[Min60use$Treatment=="Infrequent Revision Mechanism"|
                                           Min60use$Treatment=="Synchronous Revision Mechanism",]) +
  geom_line(aes(x=Round, y=MinOver60, group = Treatment, color = Treatment, linetype = Treatment),size = .71)+
  geom_vline(xintercept = 60) + geom_vline(xintercept = 2*60) + geom_vline(xintercept = 3*60) + 
  geom_vline(xintercept = 4*60) + geom_vline(xintercept = 5*60) + geom_vline(xintercept = 6*60) + 
  geom_vline(xintercept = 7*60) + geom_vline(xintercept = 8*60) + geom_vline(xintercept = 9*60) + 
  geom_vline(xintercept = 10*60) +geom_vline(xintercept = 0) + 
  #("#d4b481","#99de99","#63ab63","#3b943b","#BEAED4","#837399","lightskyblue","dodgerblue","dodgerblue3")) +
  scale_colour_manual(name = "Treatment", values = c( "#BEAED4","#837399")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  geom_vline(xintercept = 60) + geom_vline(xintercept = 2*60) + geom_vline(xintercept = 3*60) + 
  geom_vline(xintercept = 4*60) + geom_vline(xintercept = 5*60) + geom_vline(xintercept = 6*60) + 
  geom_vline(xintercept = 7*60) + geom_vline(xintercept = 8*60) + geom_vline(xintercept = 9*60) + 
  geom_vline(xintercept = 10*60) +geom_vline(xintercept = 0) + 
  geom_point(data=ForContGraphsMin[ForContGraphsMin$Treatment=="Infrequent Revision Mechanism"|
                                     ForContGraphsMin$Treatment=="Synchronous Revision Mechanism",],aes(x=Round, y=MinRound, shape = Treatment) ,size = 5) + 
  geom_point(data=ForContGraphsMin[ForContGraphsMin$Treatment=="Infrequent Revision Mechanism"|
                                     ForContGraphsMin$Treatment=="Synchronous Revision Mechanism",],aes(x=Round, y=MinRound, shape = Treatment, color = Treatment) ,size = 4) + 
  xlab("Seconds") + ylim(1,7) + 
  scale_x_continuous(breaks = c(30,90,150,210,270,330,390,450,510,570), 
                     labels = c("Round 1", "Round 2", "Round 3", "Round 4", "Round 5", "Round 6", "Round 7", "Round 8", "Round 9", "Round 10")) +
  ylab("Average Minimum Effort") + 
  theme_bw(base_size = 18) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", 
                                         colour ="grey"), legend.key.size=unit(1,"cm")) +
  theme(legend.position="top")

FigureD8.3
#
FigureD8.4 <- ggplot(Min60use[Min60use$Treatment=="Revision Cheap Talk"|
                                        Min60use$Treatment=="Richer Revision Cheap Talk",]) +
  geom_line(aes(x=Round, y=MinOver60, group = Treatment, color = Treatment, linetype = Treatment),size = .71)+
  geom_vline(xintercept = 60) + geom_vline(xintercept = 2*60) + geom_vline(xintercept = 3*60) + 
  geom_vline(xintercept = 4*60) + geom_vline(xintercept = 5*60) + geom_vline(xintercept = 6*60) + 
  geom_vline(xintercept = 7*60) + geom_vline(xintercept = 8*60) + geom_vline(xintercept = 9*60) + 
  geom_vline(xintercept = 10*60) +geom_vline(xintercept = 0) + 
  #("#d4b481","#99de99","#63ab63","#3b943b","#BEAED4","#837399","lightskyblue","dodgerblue","dodgerblue3")) +
  scale_colour_manual(name = "Treatment", values = c("#63ab63","#1f631f")) +
  scale_linetype_manual(name = "Treatment",values = c("dashed","solid")) +
  geom_vline(xintercept = 60) + geom_vline(xintercept = 2*60) + geom_vline(xintercept = 3*60) + 
  geom_vline(xintercept = 4*60) + geom_vline(xintercept = 5*60) + geom_vline(xintercept = 6*60) + 
  geom_vline(xintercept = 7*60) + geom_vline(xintercept = 8*60) + geom_vline(xintercept = 9*60) + 
  geom_vline(xintercept = 10*60) +geom_vline(xintercept = 0) + 
  geom_point(data=ForContGraphsMin[ForContGraphsMin$Treatment=="Revision Cheap Talk"|
                                     ForContGraphsMin$Treatment=="Richer Revision Cheap Talk",],aes(x=Round, y=MinRound, shape = Treatment) ,size = 5) + 
  geom_point(data=ForContGraphsMin[ForContGraphsMin$Treatment=="Revision Cheap Talk"|
                                     ForContGraphsMin$Treatment=="Richer Revision Cheap Talk",],aes(x=Round, y=MinRound, shape = Treatment, color = Treatment) ,size = 4) + 
  xlab("Seconds") + ylim(1,7) + 
  scale_x_continuous(breaks = c(30,90,150,210,270,330,390,450,510,570), 
                     labels = c("Round 1", "Round 2", "Round 3", "Round 4", "Round 5", "Round 6", "Round 7", "Round 8", "Round 9", "Round 10")) +
  ylab("Average Minimum Effort") + 
  theme_bw(base_size = 18) +
  theme(text = element_text(family = "Times"))+
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="solid", 
                                         colour ="grey"), legend.key.size=unit(1,"cm")) +
  theme(legend.position="top")

FigureD8.4
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD8.1.eps",height=4,width=12)
print(FigureD8.1)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD8.2.eps",height=4,width=12)
print(FigureD8.2)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD8.3.eps",height=4,width=12)
print(FigureD8.3)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="FigureD8.4.eps",height=4,width=12)
print(FigureD8.4)
dev.off()
#
#############################################################################
# Figure D2, Figure D3, Figure D4, Figure D5 (First Order Dominance graphs) #
#############################################################################
df_FOSD_Baseline_1 <- data.frame( x=c(a,j), Treatment <- c(rep("RM", length(a)),rep("B", length(j) ) ) )
names(df_FOSD_Baseline_1) <- c("Payoff","Treatment")
#
ggBaseline1 <- ggplot(df_FOSD_Baseline_1, aes(Payoff, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = .45, y = .98, label = paste("KS test p-value < ", format(round(ks.test(a,j)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#d4b481", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.4,.9),legend.justification=c(1,1),
        legend.title = element_blank(),
        legend.key.width = unit(3, "line"),
        strip.text.x = element_text(size = 12, face = "bold"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggBaseline1
#
#
df_FOSD_Baseline_2 <- data.frame( x=c(aM,jM), Treatment <- c(rep("RM", length(aM)),rep("B", length(jM) ) ) )
names(df_FOSD_Baseline_2) <- c("Minimum","Treatment")
#
ggBaseline2 <- ggplot(df_FOSD_Baseline_2, aes(Minimum, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = 2.7, y = .98, label = paste("KS test p-value < ", format(round(ks.test(aM,jM)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#d4b481", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Minimum Effort") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.4,.9),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggBaseline2
#
df_FOSD_Baseline_3 <- data.frame( x=c(aF,jF), Treatment <- c(rep("RM", length(aF)),rep("B", length(jF) ) ) )
names(df_FOSD_Baseline_3) <- c("Frequency","Treatment")
#
ggBaseline3 <- ggplot(df_FOSD_Baseline_3, aes(Frequency, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  scale_color_manual(values=c("#d4b481", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Frequency Of Efficient Effort") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.89,.8),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) +
  annotate("text", x = .3, y = .98, label = paste("KS test p-value < ", format(round(ks.test(aF,jF)$p.value, digits = 2), nsmall = 2)), size = 8) 
ggBaseline3
#
df_FOSD_Baseline_4 <- data.frame( x=c(aC,jC), Treatment <- c(rep("RM", length(aC)),rep("B", length(jC) ) ) )
names(df_FOSD_Baseline_4) <- c("Coordination","Treatment")
#
ggBaseline4 <- ggplot(df_FOSD_Baseline_4, aes(Coordination, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = .5, y = .85, label = paste("KS test p-value < ", format(round(ks.test(aC,jC)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#d4b481", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Full Coordination") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.7,.345),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggBaseline4
#
df_FOSD_Baseline_5 <- data.frame( x=c(aE,jE), Treatment <- c(rep("RM", length(aE)),rep("B", length(jE) ) ) )
names(df_FOSD_Baseline_5) <- c("Eqbm","Treatment")
#
ggBaseline5 <- ggplot(df_FOSD_Baseline_5, aes(Eqbm, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = 3.7, y = .05, label = paste("KS test p-value < ", format(round(ks.test(aE,jE)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#d4b481", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Equilibrium Deviation") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.99,.55),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggBaseline5
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF1.eps",height=5,width=8)
print(ggBaseline1)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF2.eps",height=5,width=8)
print(ggBaseline2)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF3.eps",height=5,width=8)
print(ggBaseline3)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF4.eps",height=5,width=8)
print(ggBaseline4)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF5.eps",height=5,width=8)
print(ggBaseline5)
dev.off()
#
#
#
df_FOSD_SCT_1 <- data.frame( x=c(a,b), Treatment <- c(rep("RM", length(a)),rep("S-CT", length(b) ) ) )
names(df_FOSD_SCT_1) <- c("Payoff","Treatment")
#
ggSCT1 <- ggplot(df_FOSD_SCT_1, aes(Payoff, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = .45, y = .98, label = paste("KS test p-value < ", format(round(ks.test(a,b)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("dodgerblue", "#99de99"))+
  ylab("ECDF") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dotted", colour ="grey")) + 
  theme(legend.position=c(.4,.9),legend.justification=c(1,1),
        legend.title = element_blank(),
        legend.key.width = unit(3, "line"),
        strip.text.x = element_text(size = 12, face = "bold"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggSCT1
#
#
df_FOSD_SCT_2 <- data.frame( x=c(aM,bM), Treatment <- c(rep("RM", length(aM)),rep("S-CT", length(bM) ) ) )
names(df_FOSD_SCT_2) <- c("Minimum","Treatment")
#
ggSCT2 <- ggplot(df_FOSD_SCT_2, aes(Minimum, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = 2.7, y = .98, label = paste("KS test p-value < ", format(round(ks.test(aM,bM)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("dodgerblue", "#99de99"))+
  ylab("ECDF") + xlab("Minimum Effort") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dotted", colour ="grey")) + 
  theme(legend.position=c(.4,.9),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 10, face = "bold"),
        legend.key.width = unit(3, "line"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggSCT2
#
df_FOSD_SCT_3 <- data.frame( x=c(aF,bF), Treatment <- c(rep("RM", length(aF)),rep("S-CT", length(bF) ) ) )
names(df_FOSD_SCT_3) <- c("Frequency","Treatment")
#
ggSCT3 <- ggplot(df_FOSD_SCT_3, aes(Frequency, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  scale_color_manual(values=c("dodgerblue", "#99de99"))+
  ylab("ECDF") + xlab("Frequency Of Efficient Effort") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dotted", colour ="grey")) + 
  theme(legend.position=c(.4,.9),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) +
  annotate("text", x = .3, y = .98, label = paste("KS test p-value < ", format(round(ks.test(aF,bF)$p.value, digits = 2), nsmall = 2)), size = 8) 
ggSCT3
#
df_FOSD_SCT_4 <- data.frame( x=c(aC,bC), Treatment <- c(rep("RM", length(aC)),rep("S-CT", length(bC) ) ) )
names(df_FOSD_SCT_4) <- c("Coordination","Treatment")
#
ggSCT4 <- ggplot(df_FOSD_SCT_4, aes(Coordination, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = .5, y = .9, label = paste("KS test p-value < ", format(round(ks.test(aC,bC)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("dodgerblue", "#99de99"))+
  ylab("ECDF") + xlab("Full Coordination") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dotted", colour ="grey")) + 
  theme(legend.position=c(.6,.345),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggSCT4
#
df_FOSD_SCT_5 <- data.frame( x=c(aE,bE), Treatment <- c(rep("RM", length(aE)),rep("S-CT", length(bE) ) ) )
names(df_FOSD_SCT_5) <- c("Eqbm","Treatment")
#
ggSCT5 <- ggplot(df_FOSD_SCT_5, aes(Eqbm, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = 3.7, y = .05, label = paste("KS test p-value < ", format(round(ks.test(aE,bE)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("dodgerblue", "#99de99"))+
  ylab("ECDF") + xlab("Equilibrium Deviation") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dotted", colour ="grey")) + 
  theme(legend.position=c(.99,.55),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggSCT5
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF1_2.eps",height=5,width=8)
print(ggSCT1)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF2_2.eps",height=5,width=8)
print(ggSCT2)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF3_2.eps",height=5,width=8)
print(ggSCT3)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF4_2.eps",height=5,width=8)
print(ggSCT4)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF5_2.eps",height=5,width=8)
print(ggSCT5)
dev.off()
#
#
#
df_FOSD_IRM_1 <- data.frame( x=c(a,f), Treatment <- c(rep("RM", length(a)),rep("I-RM", length(f) ) ) )
names(df_FOSD_IRM_1) <- c("Payoff","Treatment")
#
ggIRM1 <- ggplot(df_FOSD_IRM_1, aes(Payoff, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = .45, y = .98, label = paste("KS test p-value < ", format(round(ks.test(a,f)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#BEAED4", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.4,.9),legend.justification=c(1,1),
        legend.title = element_blank(),
        legend.key.width = unit(3, "line"),
        strip.text.x = element_text(size = 12, face = "bold"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggIRM1
#
#
df_FOSD_IRM_2 <- data.frame( x=c(aM,fM), Treatment <- c(rep("RM", length(aM)),rep("I-RM", length(fM) ) ) )
names(df_FOSD_IRM_2) <- c("Minimum","Treatment")
#
ggIRM2 <- ggplot(df_FOSD_IRM_2, aes(Minimum, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = 2.7, y = .98, label = paste("KS test p-value < ", format(round(ks.test(aM,fM)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#BEAED4", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Minimum Effort") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.4,.9),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggIRM2
#
df_FOSD_IRM_3 <- data.frame( x=c(aF,fF), Treatment <- c(rep("RM", length(aF)),rep("I-RM", length(fF) ) ) )
names(df_FOSD_IRM_3) <- c("Frequency","Treatment")
#
ggIRM3 <- ggplot(df_FOSD_IRM_3, aes(Frequency, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  scale_color_manual(values=c("#BEAED4", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Frequency Of Efficient Effort") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.4,.8),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) +
  annotate("text", x = .3, y = .98, label = paste("KS test p-value < ", format(round(ks.test(aF,fF)$p.value, digits = 2), nsmall = 2)), size = 8) 
ggIRM3
#
df_FOSD_IRM_4 <- data.frame( x=c(aC,fC), Treatment <- c(rep("RM", length(aC)),rep("I-RM", length(fC) ) ) )
names(df_FOSD_IRM_4) <- c("Coordination","Treatment")
#
ggIRM4 <- ggplot(df_FOSD_IRM_4, aes(Coordination, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = .5, y = .9, label = paste("KS test p-value < ", format(round(ks.test(aC,fC)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#BEAED4", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Full Coordination") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.65,.34),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggIRM4
#
df_FOSD_IRM_5 <- data.frame( x=c(aE,fE), Treatment <- c(rep("RM", length(aE)),rep("I-RM", length(fE) ) ) )
names(df_FOSD_IRM_5) <- c("Eqbm","Treatment")
#
ggIRM5 <- ggplot(df_FOSD_IRM_5, aes(Eqbm, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = 3.7, y = .05, label = paste("KS test p-value < ", format(round(ks.test(aE,fE)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#BEAED4", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Equilibrium Deviation") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.99,.55),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggIRM5
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF1_3.eps",height=5,width=8)
print(ggIRM1)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF2_3.eps",height=5,width=8)
print(ggIRM2)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF3_3.eps",height=5,width=8)
print(ggIRM3)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF4_3.eps",height=5,width=8)
print(ggIRM4)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF5_3.eps",height=5,width=8)
print(ggIRM5)
dev.off()
#
#
#
df_FOSD_SRM_1 <- data.frame( x=c(a,e), Treatment <- c(rep("RM", length(a)),rep("S-RM", length(e) ) ) )
names(df_FOSD_SRM_1) <- c("Payoff","Treatment")
#
ggSRM1 <- ggplot(df_FOSD_SRM_1, aes(Payoff, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = .45, y = .98, label = paste("KS test p-value < ", format(round(ks.test(a,e)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#837399", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.4,.9),legend.justification=c(1,1),
        legend.title = element_blank(),
        legend.key.width = unit(3, "line"),
        strip.text.x = element_text(size = 12, face = "bold"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggSRM1
#
#
df_FOSD_SRM_2 <- data.frame( x=c(aM,eM), Treatment <- c(rep("RM", length(aM)),rep("S-RM", length(eM) ) ) )
names(df_FOSD_SRM_2) <- c("Minimum","Treatment")
#
ggSRM2 <- ggplot(df_FOSD_SRM_2, aes(Minimum, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = 2.7, y = .98, label = paste("KS test p-value < ", format(round(ks.test(aM,eM)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#837399", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Minimum Effort") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.4,.9),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggSRM2
#
df_FOSD_SRM_3 <- data.frame( x=c(aF,eF), Treatment <- c(rep("RM", length(aF)),rep("S-RM", length(eF) ) ) )
names(df_FOSD_SRM_3) <- c("Frequency","Treatment")
#
ggSRM3 <- ggplot(df_FOSD_SRM_3, aes(Frequency, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  scale_color_manual(values=c("#837399", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Frequency Of Efficient Effort") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.4,.8),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) +
  annotate("text", x = .3, y = .98, label = paste("KS test p-value < ", format(round(ks.test(aF,eF)$p.value, digits = 2), nsmall = 2)), size = 8) 
ggSRM3
#
df_FOSD_SRM_4 <- data.frame( x=c(aC,eC), Treatment <- c(rep("RM", length(aC)),rep("S-RM", length(eC) ) ) )
names(df_FOSD_SRM_4) <- c("Coordination","Treatment")
#
ggSRM4 <- ggplot(df_FOSD_SRM_4, aes(Coordination, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = .5, y = .9, label = paste("KS test p-value < ", format(round(ks.test(aC,eC)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#837399", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Full Coordination") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.65,.34),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggSRM4
#
df_FOSD_SRM_5 <- data.frame( x=c(aE,eE), Treatment <- c(rep("RM", length(aE)),rep("S-RM", length(eE) ) ) )
names(df_FOSD_SRM_5) <- c("Eqbm","Treatment")
#
ggSRM5 <- ggplot(df_FOSD_SRM_5, aes(Eqbm, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = 3.7, y = .05, label = paste("KS test p-value < ", format(round(ks.test(aE,eE)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#837399", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Equilibrium Deviation") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.99,.55),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggSRM5
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF1_4.eps",height=5,width=8)
print(ggSRM1)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF2_4.eps",height=5,width=8)
print(ggSRM2)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF3_4.eps",height=5,width=8)
print(ggSRM3)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF4_4.eps",height=5,width=8)
print(ggSRM4)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF5_4.eps",height=5,width=8)
print(ggSRM5)
dev.off()
#
#
#
#
#
df_FOSD_RRM_1 <- data.frame( x=c(a,d), Treatment <- c(rep("RM", length(a)),rep("R-RM", length(d) ) ) )
names(df_FOSD_RRM_1) <- c("Payoff","Treatment")
#
ggRRM1 <- ggplot(df_FOSD_RRM_1, aes(Payoff, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = .45, y = .98, label = paste("KS test p-value = ", format(round(ks.test(a,d)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("lightskyblue", "#56B4E9"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.4,.9),legend.justification=c(1,1),
        legend.title = element_blank(),
        legend.key.width = unit(3, "line"),
        strip.text.x = element_text(size = 12, face = "bold"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggRRM1
#
#
df_FOSD_RRM_2 <- data.frame( x=c(aM,dM), Treatment <- c(rep("RM", length(aM)),rep("R-RM", length(dM) ) ) )
names(df_FOSD_RRM_2) <- c("Minimum","Treatment")
#
ggRRM2 <- ggplot(df_FOSD_RRM_2, aes(Minimum, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = 2.7, y = .98, label = paste("KS test p-value = ", format(round(ks.test(aM,dM)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("lightskyblue", "#56B4E9"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Minimum Effort") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.4,.9),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggRRM2
#
df_FOSD_RRM_3 <- data.frame( x=c(aF,dF), Treatment <- c(rep("RM", length(aF)),rep("R-RM", length(dF) ) ) )
names(df_FOSD_RRM_3) <- c("Frequency","Treatment")
#
ggRRM3 <- ggplot(df_FOSD_RRM_3, aes(Frequency, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  scale_color_manual(values=c("lightskyblue", "#56B4E9"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Frequency Of Efficient Effort") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.45,.8),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) +
  annotate("text", x = .3, y = .98, label = paste("KS test p-value = ", format(round(ks.test(aF,dF)$p.value, digits = 2), nsmall = 2)), size = 8) 
ggRRM3
#
df_FOSD_RRM_4 <- data.frame( x=c(aC,dC), Treatment <- c(rep("RM", length(aC)),rep("R-RM", length(dC) ) ) )
names(df_FOSD_RRM_4) <- c("Coordination","Treatment")
#
ggRRM4 <- ggplot(df_FOSD_RRM_4, aes(Coordination, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = .5, y = .9, label = paste("KS test p-value = ", format(round(ks.test(aC,dC)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("lightskyblue", "#56B4E9"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Full Coordination") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.7,.8),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggRRM4
#
df_FOSD_RRM_5 <- data.frame( x=c(aE,dE), Treatment <- c(rep("RM", length(aE)),rep("R-RM", length(dE) ) ) )
names(df_FOSD_RRM_5) <- c("Eqbm","Treatment")
#
ggRRM5 <- ggplot(df_FOSD_RRM_5, aes(Eqbm, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = 3.7, y = .05, label = paste("KS test p-value = ", format(round(ks.test(aE,dE)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("lightskyblue", "#56B4E9"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Equilibrium Deviation") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.99,.55),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggRRM5
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF1_5.eps",height=5,width=8)
print(ggRRM1)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF2_5.eps",height=5,width=8)
print(ggRRM2)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF3_5.eps",height=5,width=8)
print(ggRRM3)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF4_5.eps",height=5,width=8)
print(ggRRM4)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF5_5.eps",height=5,width=8)
print(ggRRM5)
dev.off()
#
#
#
#
#
df_FOSD_RMVHBB_1 <- data.frame( x=c(a,c), Treatment <- c(rep("RM", length(a)),rep("RM-VHBB", length(c) ) ) )
names(df_FOSD_RMVHBB_1) <- c("Payoff","Treatment")
#
ggRMVHBB1 <- ggplot(df_FOSD_RMVHBB_1, aes(Payoff, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = .47, y = .98, label = paste("KS test p-value = ", format(round(ks.test(a,c)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("dodgerblue","dodgerblue3"))+
  scale_linetype_manual(values = c("solid","dashed")) +
  ylab("ECDF") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.45,.9),legend.justification=c(1,1),
        legend.title = element_blank(),
        legend.key.width = unit(3, "line"),
        strip.text.x = element_text(size = 12, face = "bold"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggRMVHBB1
#
#
df_FOSD_RMVHBB_2 <- data.frame( x=c(aM,cM), Treatment <- c(rep("RM", length(aM)),rep("RM-VHBB", length(cM) ) ) )
names(df_FOSD_RMVHBB_2) <- c("Minimum","Treatment")
#
ggRMVHBB2 <- ggplot(df_FOSD_RMVHBB_2, aes(Minimum, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = 2.7, y = .98, label = paste("KS test p-value = ", format(round(ks.test(aM,cM)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("dodgerblue","dodgerblue3"))+
  scale_linetype_manual(values = c("solid","dashed")) +
  ylab("ECDF") + xlab("Minimum Effort") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.45,.9),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggRMVHBB2
#
df_FOSD_RMVHBB_3 <- data.frame( x=c(aF,cF), Treatment <- c(rep("RM", length(aF)),rep("RM-VHBB", length(cF) ) ) )
names(df_FOSD_RMVHBB_3) <- c("Frequency","Treatment")
#
ggRMVHBB3 <- ggplot(df_FOSD_RMVHBB_3, aes(Frequency, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  scale_color_manual(values=c("dodgerblue","dodgerblue3"))+
  scale_linetype_manual(values = c("solid","dashed")) +
  ylab("ECDF") + xlab("Frequency Of Efficient Effort") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.45,.8),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) +
  annotate("text", x = .3, y = .98, label = paste("KS test p-value = ", format(round(ks.test(aF,cF)$p.value, digits = 2), nsmall = 2)), size = 8) 
ggRMVHBB3
#
df_FOSD_RMVHBB_4 <- data.frame( x=c(aC,cC), Treatment <- c(rep("RM", length(aC)),rep("RM-VHBB", length(cC) ) ) )
names(df_FOSD_RMVHBB_4) <- c("Coordination","Treatment")
#
ggRMVHBB4 <- ggplot(df_FOSD_RMVHBB_4, aes(Coordination, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = .5, y = .9, label = paste("KS test p-value = ", format(round(ks.test(aC,cC)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("dodgerblue","dodgerblue3"))+
  scale_linetype_manual(values = c("solid","dashed")) +
  ylab("ECDF") + xlab("Full Coordination") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.7,.8),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggRMVHBB4
#
df_FOSD_RMVHBB_5 <- data.frame( x=c(aE,cE), Treatment <- c(rep("RM", length(aE)),rep("RM-VHBB", length(cE) ) ) )
names(df_FOSD_RMVHBB_5) <- c("Eqbm","Treatment")
#
ggRMVHBB5 <- ggplot(df_FOSD_RMVHBB_5, aes(Eqbm, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = 3.7, y = .05, label = paste("KS test p-value = ", format(round(ks.test(aE,cE)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("dodgerblue","dodgerblue3"))+
  scale_linetype_manual(values = c("solid","dashed")) +
  ylab("ECDF") + xlab("Equilibrium Deviation") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.99,.55),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggRMVHBB5
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF1_6.eps",height=5,width=8)
print(ggRMVHBB1)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF2_6.eps",height=5,width=8)
print(ggRMVHBB2)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF3_6.eps",height=5,width=8)
print(ggRMVHBB3)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF4_6.eps",height=5,width=8)
print(ggRMVHBB4)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF5_6.eps",height=5,width=8)
print(ggRMVHBB5)
dev.off()
#
#
#
df_FOSD_RCT_1 <- data.frame( x=c(a,g), Treatment <- c(rep("RM", length(a)),rep("R-CT", length(g) ) ) )
names(df_FOSD_RCT_1) <- c("Payoff","Treatment")
#
ggRCT1 <- ggplot(df_FOSD_RCT_1, aes(Payoff, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = .45, y = .98, label = paste("KS test p-value < ", format(round(ks.test(a,g)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#63ab63", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.4,.9),legend.justification=c(1,1),
        legend.title = element_blank(),
        legend.key.width = unit(3, "line"),
        strip.text.x = element_text(size = 12, face = "bold"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggRCT1
# 
#
df_FOSD_RCT_2 <- data.frame( x=c(aM,gM), Treatment <- c(rep("RM", length(aM)),rep("R-CT", length(gM) ) ) )
names(df_FOSD_RCT_2) <- c("Minimum","Treatment")
#
ggRCT2 <- ggplot(df_FOSD_RCT_2, aes(Minimum, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = 2.7, y = .98, label = paste("KS test p-value < ", format(round(ks.test(aM,gM)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#63ab63", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Minimum Effort") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.4,.9),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggRCT2
#
df_FOSD_RCT_3 <- data.frame( x=c(aF,gF), Treatment <- c(rep("RM", length(aF)),rep("R-CT", length(gF) ) ) )
names(df_FOSD_RCT_3) <- c("Frequency","Treatment")
#
ggRCT3 <- ggplot(df_FOSD_RCT_3, aes(Frequency, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  scale_color_manual(values=c("#63ab63", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Frequency Of Efficient Effort") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.45,.8),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) +
  annotate("text", x = .3, y = .98, label = paste("KS test p-value < ", format(round(ks.test(aF,gF)$p.value, digits = 2), nsmall = 2)), size = 8) 
ggRCT3
#
df_FOSD_RCT_4 <- data.frame( x=c(aC,gC), Treatment <- c(rep("RM", length(aC)),rep("R-CT", length(gC) ) ) )
names(df_FOSD_RCT_4) <- c("Coordination","Treatment")
#
ggRCT4 <- ggplot(df_FOSD_RCT_4, aes(Coordination, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = .5, y = .9, label = paste("KS test p-value < ", format(round(ks.test(aC,gC)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#63ab63", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Full Coordination") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.7,.34),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggRCT4
#
df_FOSD_RCT_5 <- data.frame( x=c(aE,gE), Treatment <- c(rep("RM", length(aE)),rep("R-CT", length(gE) ) ) )
names(df_FOSD_RCT_5) <- c("Eqbm","Treatment")
#
ggRCT5 <- ggplot(df_FOSD_RCT_5, aes(Eqbm, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = 3.7, y = .05, label = paste("KS test p-value < ", format(round(ks.test(aE,gE)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#63ab63", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Equilibrium Deviation") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.99,.55),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggRCT5
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF1_7.eps",height=5,width=8)
print(ggRCT1)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF2_7.eps",height=5,width=8)
print(ggRCT2)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF3_7.eps",height=5,width=8)
print(ggRCT3)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF4_7.eps",height=5,width=8)
print(ggRCT4)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF5_7.eps",height=5,width=8)
print(ggRCT5)
dev.off()
#
#
#
df_FOSD_RRCT_1 <- data.frame( x=c(a,h), Treatment <- c(rep("RM", length(a)),rep("R-R-CT", length(h) ) ) )
names(df_FOSD_RRCT_1) <- c("Payoff","Treatment")
#
ggRRCT1 <- ggplot(df_FOSD_RRCT_1, aes(Payoff, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = .45, y = .98, label = paste("KS test p-value < ", format(round(ks.test(a,h)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#3b943b", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.4,.9),legend.justification=c(1,1),
        legend.title = element_blank(),
        legend.key.width = unit(3, "line"),
        strip.text.x = element_text(size = 12, face = "bold"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggRRCT1
#
#
df_FOSD_RRCT_2 <- data.frame( x=c(aM,hM), Treatment <- c(rep("RM", length(aM)),rep("R-R-CT", length(hM) ) ) )
names(df_FOSD_RRCT_2) <- c("Minimum","Treatment")
#
ggRRCT2 <- ggplot(df_FOSD_RRCT_2, aes(Minimum, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = 2.7, y = .98, label = paste("KS test p-value < ", format(round(ks.test(aM,hM)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#3b943b", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Minimum Effort") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.4,.9),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggRRCT2
#
df_FOSD_RRCT_3 <- data.frame( x=c(aF,hF), Treatment <- c(rep("RM", length(aF)),rep("R-R-CT", length(hF) ) ) )
names(df_FOSD_RRCT_3) <- c("Frequency","Treatment")
#
ggRRCT3 <- ggplot(df_FOSD_RRCT_3, aes(Frequency, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  scale_color_manual(values=c("#3b943b", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Frequency Of Efficient Effort") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.45,.8),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) +
  annotate("text", x = .3, y = .98, label = paste("KS test p-value < ", format(round(ks.test(aF,hF)$p.value, digits = 2), nsmall = 2)), size = 8) 
ggRRCT3
#
df_FOSD_RRCT_4 <- data.frame( x=c(aC,hC), Treatment <- c(rep("RM", length(aC)),rep("R-R-CT", length(hC) ) ) )
names(df_FOSD_RRCT_4) <- c("Coordination","Treatment")
#
ggRRCT4 <- ggplot(df_FOSD_RRCT_4, aes(Coordination, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = .5, y = .9, label = paste("KS test p-value < ", format(round(ks.test(aC,hC)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#3b943b", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Full Coordination") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.65,.34),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggRRCT4
#
df_FOSD_RRCT_5 <- data.frame( x=c(aE,hE), Treatment <- c(rep("RM", length(aE)),rep("R-R-CT", length(hE) ) ) )
names(df_FOSD_RRCT_5) <- c("Eqbm","Treatment")
#
ggRRCT5 <- ggplot(df_FOSD_RRCT_5, aes(Eqbm, colour = Treatment, linetype = Treatment)) +
  stat_ecdf(size = 2) +
  annotate("text", x = 3.7, y = .05, label = paste("KS test p-value < ", format(round(ks.test(aE,hE)$p.value, digits = 2), nsmall = 2)), size = 8) + 
  scale_color_manual(values=c("#3b943b", "dodgerblue"))+
  scale_linetype_manual(values = c("dashed", "solid")) +
  ylab("ECDF") + xlab("Equilibrium Deviation") +
  theme_bw(base_size = 30) +
  theme(legend.background = element_rect(fill="White",
                                         size=0.5, linetype="dashed", colour ="grey")) + 
  theme(legend.position=c(.99,.55),legend.justification=c(1,1),
        legend.title = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        legend.key.width = unit(3, "line"),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        strip.background = element_rect(fill="gray100", colour="gray100",size=.1),
        legend.background = element_rect(size=0.5, linetype="solid",  colour ="white"),
        text=element_text(family="Times New Roman"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  guides(shape = guide_legend(override.aes = list(size=1))) 
ggRRCT5
#
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF1_8.eps",height=5,width=8)
print(ggRRCT1)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF2_8.eps",height=5,width=8)
print(ggRRCT2)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF3_8.eps",height=5,width=8)
print(ggRRCT3)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF4_8.eps",height=5,width=8)
print(ggRRCT4)
dev.off()
#
saveG <- TRUE
#
if(class(dev.list()) != "NULL"){dev.off()}
cairo_ps(file="ECDF5_8.eps",height=5,width=8)
print(ggRRCT5)
dev.off()
#
# END
# 
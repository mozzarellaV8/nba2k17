# NBA Moneyball 2016-2017
# off-the-shelf linear regression - data cleanse
# training on 2010s decade data
# basketball-reference.com/leagues for season summaries

# load data -------------------------------------------------------------------

# test
nba2k11 <- read.csv("data/2k11.csv")
nba2k11$Year <- 2011
nba2k11$Playoffs <- ifelse(grepl("\\*", nba2k11$Team), 1, 0)

# bind all the 2000s data into one frame
dir <- "~/Documents/Foundations-Linear/NBA/data"
dir2 <- "~/Documents/Foundations-Linear/NBA/data-opp"
dir3 <- "~/Documents/Foundations-Linear/NBA/data-s"
nbaStats <- list.files(path = dir, pattern = "csv", all.files = T, 
                       full.names = T, recursive = T)
nbaOpp <- list.files(path = dir2, pattern = "csv", all.files = T, 
                       full.names = T, recursive = T)
standings <- list.files(path = dir3, pattern = "csv", all.files = T, 
                        full.names = T, recursive = T)

# set up the years variable
years <- 2010:2016

# open up individual csvs, add years & playoff binary columns, bind all
# careful with column headers from basketball-reference; they vary
nba <- data.frame()
for (i in 1:length(nbaStats)) {
  temp <- read.csv(nbaStats[i])
  temp$Year <- years[i]
  temp$Playoffs <- ifelse(grepl("\\*", temp$Team), 1, 0)
  # take points allowed from opponent data for temp
  opp <- read.csv(nbaOpp[i])
  temp$oppPTS <- opp$PTS
  # take wins from standings data temp
  stand <- read.csv(standings[i])
  temp$Record <- stand$Overall
  # load all temp results into nba dataframe
  nba <- rbind(nba, temp)
}


# reorder columns
nba <- nba[c(1, 2, 27, 30, 25, 26, 29, 28, 3:24)]
nba$Rk <- NULL

# separate Record into W/L columns
library(tidyr)
nba <- separate(nba, Record, into = c("W", "L"), sep = "-")
nba$W <- as.numeric(nba$W)
nba$L <- as.numeric(nba$L)

# remove duplicates from playoff asterisks
# charlotte, new orleans, and brooklyn account for 3 more teams
nba$Team <- gsub("\\*", "", nba$Team)
nba$Team <- as.factor(nba$Team)

# check it out
str(nba)
summary(nba)

write.table(nba, file = "nba2k17.csv", sep = ",", row.names = F)


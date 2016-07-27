# NBA Moneyball 2016-2017
# off-the-shelf linear regression - data cleanse
# training on 2010s decade data
# basketball-reference.com/leagues for season summaries

# load + bind data ------------------------------------------------------------
# bind all the 2000s statistics into one data frame

# directory variables
dir <- "~/GitHub/nba2k17/data"
dir2 <- "~/GitHub/nba2k17/data-opp"
dir3 <- "~/GitHub/nba2k17/data-s"

# create file lists to call from
nbaStats <- list.files(path = dir, pattern = "csv", all.files = T,
                       full.names = T, recursive = T)
nbaOpp <- list.files(path = dir2, pattern = "csv", all.files = T, 
                       full.names = T, recursive = T)
standings <- list.files(path = dir3, pattern = "csv", all.files = T, 
                        full.names = T, recursive = T)

# set up the years variable
years <- 2000:2016

# open up individual csvs; add years & playoff binary columns; bind
# careful with raw column headers from basketball-reference; 
# they vary from season to season.

nba <- data.frame()
for (i in 1:length(nbaStats)) {
  temp <- read.csv(nbaStats[i])
  # add column for year and playoff binary
  temp$Year <- years[i]
  temp$Playoffs <- ifelse(grepl("\\*", temp$Team), 1, 0)
  # take points allowed from opponent data for temp
  opp <- read.csv(nbaOpp[i])
  temp$oppPTS <- opp$PTS
  temp$oppPTS.G <- opp$PTS.G
  # take wins from standings data temp
  stand <- read.csv(standings[i])
  temp$Record <- stand$Overall
  # load all temp results into nba dataframe
  nba <- rbind(nba, temp)
}

# test
nba2k11 <- subset(nba, nba$Year == 2011)

# reorder columns
nba <- nba[c(1, 2, 31, 25, 26, 29, 30, 28, 3:24)]
nba$Rk <- NULL

# separate Record into W/L columns
library(tidyr)

nba <- separate(nba, Record, into = c("W", "L"), sep = "-")
nba$W <- as.numeric(nba$W)
nba$L <- as.numeric(nba$L)

# remove duplicates from playoff asterisk notations
nba$Team <- gsub("\\*", "", nba$Team)
nba$Team <- as.factor(nba$Team)
levels(nba$Team)
# As of 2016 there are 30 teams in the league.
# Charlotte Bobcats/Hornets, New Orleans Hornets/Pelicans, 
# New Orleans/Oklahoma City Hornets, Vancouver Grizzlies, Seattle Supersonics, 
# and Brooklyn Nets account for the extra levels in the variables. 
# Essentially, changes in team ownership/location/existence.

# rename some columns for cleanliness (lowercase x, slightly easier to read)
library(plyr)
nba <- plyr::rename(nba, replace = c("X3P" = "x3P", "X3PA" = "x3PA", "X3P_P" = "x3P_P",
                                     "X2P" = "x2P", "X2PA" = "x2PA", "X2P_P" = "x2P_P"))

# check it out
str(nba)
summary(nba)

# write it out
write.table(nba, file = "nba2k17.csv", sep = ",", row.names = F)
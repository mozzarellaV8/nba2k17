# NBA Moneyball 2016-2017
# off-the-shelf linear regression
# training on 2010s decade data
# basketball-reference.com/leagues for season summaries

# load data -------------------------------------------------------------------

rm(list = ls())
nba <- read.csv("nba2k17.csv", header = T)
str(nba)
summary(nba)

# linear model 01 - wins ~ playoff --------------------------------------------

table(nba$W, nba$Playoffs)

# look into why duplicate values show up here
winsPO <- as.matrix(table(nba$W, nba$Playoffs))
colnames(winsPO) <- c("NumWins", "PO", "Frequency")
winsPO <- winsPO[order(winsPO$Frequency, decreasing = T), ]
rownames(winsPO) <- NULL

winsPO <- winsPO[!(winsPO$PO == 0 & winsPO$Frequency == 0), ]

# linear regression model: wins ~ playoff berth
winsPO.model <- lm(W ~ Playoffs, data = nba)
summary(winsPO.model)
# Coefficients:
#               Estimate Std. Error   t value   Pr(>|t|)    
#   (Intercept)  30.3348     0.5391     56.27   <2e-16  ***
#   Playoffs     18.9152     0.7346     25.75   <2e-16  ***

# Multiple R-squared:  0.5686,	Adjusted R-squared:  0.5677

# 57% accuracy according to multiple R^2: OK. 

# Correlation Matrix ----------------------------------------------------------

# plot correlation of all variables, see where things lie.
library(corrplot)
nba.cor <- nba
nba.cor$Team <- NULL
nba.cor <- cor(nba.cor, use = "everything")

par(family = "Arial Rounded MT Bold")
corrplot(nba.cor, method = "ellipse", tl.srt = 45, tl.cex = 0.85, mar = c(2, 2, 2, 2),
         title = "Correlation Matrix of Traditional NBA Statistics: 2000-2016")

corrplot(nba.cor, method = "shade", tl.srt = 45, tl.cex = 1, mar = c(2, 2, 2, 2),
         title = "Correlation Matrix of Traditional NBA Statistics: 2000-2016", 
         addCoef.col = "black", number.cex = 0.65)

      



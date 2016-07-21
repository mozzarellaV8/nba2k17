# NBA Moneyball 2016-2017
# off-the-shelf linear regression
# training on 2010s decade data
# basketball-reference.com/leagues for season summaries

# load data -------------------------------------------------------------------

nba <- read.csv("nba2k17.csv")
str(nba)
summary(nba)

# linear model 01 - wins ~ playoff --------------------------------------------

table(nba$W, nba$Playoffs)
winsPO <- as.data.frame(table(nba$W, nba$Playoffs))
colnames(winsPO) <- c("NumWins", "PO", "Frequency")
winsPO <- winsPO[order(winsPO$Frequency, decreasing = T), ]
rownames(winsPO) <- NULL

winsPO <- winsPO[!(winsPO$PO == 0 & winsPO$Frequency == 0), ]

winsPO.model <- lm(W ~ Playoffs, data = nba)
summary(winsPO.model)
# Coefficients:
#               Estimate Std. Error t value Pr(>|t|)    
#   (Intercept)  30.2143     0.9454   31.96   <2e-16 ***
#   Playoffs     18.0714     1.2946   13.96   <2e-16 ***

# Multiple R-squared:  0.4837

# not that great.

library(corrplot)
nba.cor <- nba
nba.cor$Team <- NULL
nba.cor <- cor(nba.cor, use = "everything")
# nba.cor[,colnames(nba.cor)] = apply(nba.cor[,colnames(nba.cor)], 2, 
#                                    function(x) as.numeric(as.character(x)))

par(family = "Arial Rounded MT Bold")
corrplot(nba.cor, method = "ellipse", tl.srt = 45, tl.cex = 1, mar = c(2, 2, 2, 2),
         title = "Correlation Matrix of Traditional NBA Statistics")

corrplot(nba.cor, method = "shade", tl.srt = 45, tl.cex = 1, mar = c(2, 2, 2, 2),
         title = "Correlation Matrix of Traditional NBA Statistics", 
         addCoef.col = "black", number.cex = 0.65)

      



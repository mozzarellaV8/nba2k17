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
winsPO <- as.data.frame(table(nba$W, nba$Playoffs))
colnames(winsPO) <- c("NumWins", "PO", "Frequency")
winsPO <- winsPO[order(winsPO$Frequency, decreasing = T), ]
rownames(winsPO) <- NULL

winsPO <- winsPO[!(winsPO$PO == 0 & winsPO$Frequency == 0), ]

# linear regression model: wins ~ playoff berth
winsPO.model <- lm(W ~ Playoffs, data = nba)
summary(winsPO.model)
#   Coefficients:
#               Estimate Std. Error   t value   Pr(>|t|)    
#   (Intercept)  329.7983     0.4993   59.68    <2e-16 ***
#   Playoffs     19.9113      0.6803   29.27    <2e-16 ***

# Multiple R-squared:  0.6301,	Adjusted R-squared:  0.6293 

# 63% accuracy according to multiple R^2: OK. 

# Point Differentials ---------------------------------------------------------

# compute point diffrential
nba$ptsDIFF <- nba$PTS - nba$oppPTS
summary(nba$ptsDIFF)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#  -945    -248      15       0     271     882 

# plot point differential against wins
par(mar = c(6, 6, 6, 6), las = 1, family = "Arial Rounded MT Bold")
plot(nba$ptsDIFF, nba$W, 
     xlab = "point differerntial", 
     ylab = "number of wins", 
     main = "Point Differential vs. Wins: NBA 2000-2016")
abline(lm(W ~ ptsDIFF, data = nba), col = "firebrick2", lty = 2)
# higher positive point differential; higher number of wins

library(ggplot2)
library(RColorBrewer)

ptDiffPlot <- ggplot(nba, aes(x = ptsDIFF, y = W, color = ptsDIFF)) +
  geom_point(size = 4, shape = 17, alpha = 0.99) +
  scale_color_continuous(low = "red1", high = "steelblue2") +
  theme_minimal(base_size = 12, base_family = "Arial Rounded MT Bold") +
  theme(plot.margin = unit(c(3, 3, 3, 3), "cm")) +
  labs(title = "Point Differential vs. Wins: NBA 2000-2016",
       x = "point differential", y = "number of wins", colour = "pt/diff")

ptDiffPlot

ptDiffPlot + geom_smooth(method = lm, linetype = 2, se = F, color = "black")

ptDiffPlot + stat_smooth()

# closer look at positive values for ptsDIFF
nbaPos <- subset(nba, nba$ptsDIFF > 0)

ptDiffPos <- ggplot(nbaPos, aes(x = ptsDIFF, y = W, color = ptsDIFF)) +
  geom_point(size = 4, shape = 17) +
  scale_color_continuous(low = "red1", high = "steelblue2") +
  theme_minimal(base_size = 12, base_family = "Arial Rounded MT Bold") +
  theme(plot.margin = unit(c(2, 2, 2, 2), "cm")) +
  labs(title = "Point Differential vs. Wins: NBA 2000-2016",
       x = "point differential", y = "number of wins", color = "pt/diff")

ptDiffPos

# Model 02: Points ------------------------------------------------------------

# split the data into test and traning - train 2000-2015, test 2016

nbaTrain <- subset(nba, nba$Year != 2016)
nbaTest <- subset(nba, nba$Year == 2016)

# reorder columns for ptsDIFF
nbaTrain <- nbaTrain[c(1:7, 31, 8:30)]
nbaTest <- nbaTest[c(1:7, 31, 8:30)]

# compute training point differential
nbaTrain$ptsDIFF <- nbaTrain$PTS - nbaTrain$oppPTS

# plot
trainDiffPlot <- ggplot(nbaTrain, aes(x = ptsDIFF, y = W, color = ptsDIFF)) +
  geom_point(size = 4, shape = 17, alpha = 0.99) +
  scale_color_continuous(low = "red1", high = "steelblue2") +
  theme_minimal(base_size = 12, base_family = "Arial Rounded MT Bold") +
  theme(plot.margin = unit(c(3, 3, 3, 3), "cm")) +
  labs(title = "Point Differential vs. Wins: NBA 2000-2015",
       x = "point differential", y = "number of wins", colour = "pt/diff")

# plot w/ loess
trainDiffPlot + stat_smooth()

# plot with ols
trainDiffPlot + geom_smooth(method = lm, linetype = 2, se = F, color = "black") 

# plot w/ annotations
trainDiffPlot + 
  annotate("text", x = 856, y = 64.8, label = "Celtics, 2008", 
           family = "Times", size = 4) + 
  annotate("text", x = 862, y = 68.6, label = "Warriors, 2015",
           family = "Times", size = 4) +
  annotate("text", x = 820, y = 59, label = "Thunder, 2013",
           family = "Times", size = 4)

# Correlation Matrix: ptsDIFF--------------------------------------------------

# plot correlation of all variables, see where things lie.
library(corrplot)
nbaTrain.cor <- nbaTrain
nbaTrain.cor$Team <- NULL
nbaTrain.cor <- cor(nbaTrain.cor, use = "everything")

par(family = "Arial Rounded MT Bold")
corrplot(nbaTrain.cor, method = "ellipse", tl.srt = 45, tl.cex = 0.85, 
         mar = c(2, 2, 2, 2),
         title = "Correlation Matrix of Traditional NBA Statistics: 2000-2015")

corrplot(nbaTrain.cor, method = "shade", tl.srt = 45, tl.cex = 0.85, 
         mar = c(2, 2, 2, 2),
         title = "Correlation Matrix of Traditional NBA Statistics: 2000-2015", 
         addCoef.col = "black", number.cex = 0.65)
# exhibiting 0.96 correlation coefficient - almost certain.

# Model 02: Wins by Point Differential ----------------------------------------
RegSeasonW <- lm(W ~ ptsDIFF, data = nbaTrain)
summary(RegSeasonW)
#     Coefficients:
#                   Estimate Std.Error  t-value   Pr(>|t|)    
#     (Intercept) 4.049e+01  1.595e-01  253.93    <2e-16 ***
#     ptsDIFF     3.301e-02  4.411e-04   74.84    <2e-16 ***

# Multiple R-squared:  0.9221,	Adjusted R-squared:  0.922 

# Wow OK - just as thought, 92% accuracy in point differential as 
# predictor of number of wins.

# Model 03: Points by . -------------------------------------------------------

# So point differential almost guarantees wins - or vice versa.
# So how do points get generated?

# gonna try the kitchen sink first cuz im tired
RegSeasonPTS <- lm(PTS ~ x2PA + x3PA + FTA + AST + ORB + DRB +
                     TOV + STL + BLK, data = nbaTrain)
summary(RegSeasonPTS)
# Coefficients:
#                 Estimate Std.Error  t-value   Pr(>|t|)    
#   (Intercept) -115.57845  149.24481  -0.774     0.4391    
#   x2PA           0.93292    0.04358  21.408    < 2e-16 ***
#   x3PA           1.27051    0.04303  29.529    < 2e-16 ***
#   FTA            1.04762    0.04139  25.313    < 2e-16 ***
#   AST            0.60766    0.06696   9.075    < 2e-16 ***
#   ORB           -1.18058    0.11358 -10.395    < 2e-16 ***
#   DRB           -0.01055    0.08277  -0.128     0.8986    
#   TOV           -0.45360    0.09145  -4.960   9.89e-07 ***
#   STL           -0.24038    0.13016  -1.847     0.0654 .  
#   BLK            0.26559    0.13388   1.984     0.0479 *  

# Multiple R-squared:  0.9018,	Adjusted R-squared:  0.8999 

# Pretty Good: But let's remove the less significant variables
# one at a time:
# BLK, STL, DRB
# But also think about how these defensive stats contribute to the 
# offense in indirect ways.

# find the sum of squared error
SSE <- sum(RegSeasonPTS$residuals^2)
SSE # 14491859
# pretty damn high.

RegSeasonPTS$residuals
plot(RegSeasonPTS$residuals)
par(mfrow = c(2, 2), mar = c(6, 6, 6, 6))
plot(RegSeasonPTS)

# root mean squared error
RMSE <- sqrt(SSE/nrow(nbaTrain))
RMSE # 174.6688
# pretty damn low.
mean(nbaTrain$PTS)
# 7922.436




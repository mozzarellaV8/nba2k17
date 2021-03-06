# NBA Moneyball 2016-2017
# off-the-shelf linear regression
# training on 2010s decade data
# basketball-reference.com/leagues for season summaries

# load data -------------------------------------------------------------------

rm(list = ls())
nba <- read.csv("nba2k17.csv", header = T)
str(nba)
summary(nba)

# Wins Estimator --------------------------------------------------------------
# looking at the entire population here

# estimate win-cutoff for playoff eligibility
table(nba$W, nba$Playoffs)

# Point Differential - Population ---------------------------------------------

# compute point diffrential
nba$ptsDIFF <- nba$PTS - nba$oppPTS
summary(nba$ptsDIFF)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#  -945    -248      15       0     271     882 

# compute point differential/game check this
nba$ptsDIFF.G <- nba$PTS.G - nba$oppPTS.G
summary(nba$ptsDIFF.G)
#       Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
#  -13.90000  -3.10000   0.20000   0.00198   3.30000  10.80000

# reorder columns with new variables
nba <- nba[c(1:7, 32, 33, 8:30)]

# write table of this (possibly) final data
write.table(nba, file = "nba2k17-Final.csv")

# Plots: Point Differential ---------------------------------------------------

library(ggplot2)
library(RColorBrewer)

# plot point differential against wins
par(mar = c(6, 6, 6, 6), las = 1, family = "Arial Rounded MT Bold")
plot(nba$ptsDIFF, nba$W, 
     xlab = "point differerntial", 
     ylab = "number of wins", 
     main = "Point Differential vs. Wins: NBA 2000-2016")
abline(lm(W ~ ptsDIFF, data = nba), col = "firebrick2", lty = 2)
# higher positive point differential; higher number of wins

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

# Training/Test sets ----------------------------------------------------------

# split the data into test and traning 
# training: 2000-2015
# test: 2016

nbaTrain <- subset(nba, nba$Year != 2016)
nbaTest <- subset(nba, nba$Year == 2016)
str(nbaTrain)
str(nbaTest)

# wins~playoffs table
# get a sense of how many wins are needed 
# for a good chance of making the playoffs
table(nbaTrain$W, nbaTrain$Playoffs)
# it would seem that 41 wins is the minimum, and 42 wins more comfortable.

# Plot: Wins - Point Differential ---------------------------------------------

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

# Correlation Matrix: Point Differential --------------------------------------

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

# Wins and Point Differential exhibiting 0.96 correlation - almost certain.
# Other highly correlated variables are obvious - e.g. 0.98 for 3 pointers and
# 3 pointers attempted.

# Model 01: Wins by Point Differential ----------------------------------------

RegSeasonW <- lm(W ~ ptsDIFF, data = nbaTrain)
summary(RegSeasonW)
#     Coefficients:
#                   Estimate Std.Error  t-value   Pr(>|t|)    
#     (Intercept) 4.049e+01  1.595e-01  253.93    <2e-16 ***
#     ptsDIFF     3.301e-02  4.411e-04   74.84    <2e-16 ***

# Multiple R-squared:  0.9221,	Adjusted R-squared:  0.922 

# Wow OK - just as thought, 92% accuracy in point differential as 
# predictor of number of wins. Err, pretty linear relationship.

# So given a team needs 42 wins to make the playoffs - what's the minumum
# total point differential over a season that'll net 42 wins? 

# Plug coefficients into regression formula
# Set as inequality greater than 42. 

ptDiffNeeded <- (42 - 41) / 0.033
# 30.30

# Model 01B: Wins by Point Differential (per game) ----------------------------

RegSeasonW.G <- lm(W ~ ptsDIFF.G, data = nbaTrain)
summary(RegSeasonW.G)
# Coefficients:
#             Estimate Std. Error   t value   Pr(>|t|)    
# (Intercept) 40.48589    0.16341    247.75    <2e-16 ***
# ptsDIFF.G    2.66910    0.03662     72.88    <2e-16 ***

# Residual standard error: 3.561 on 473 degrees of freedom
# Multiple R-squared:  0.9182,	Adjusted R-squared:  0.9181 
# F-statistic:  5312 on 1 and 473 DF,  p-value: < 2.2e-16

# Wins = Intercept Coefficient + (ptsDiff.G coefficient * ptsDIFF.G)
# 42 <= 40.5 + 2.67 * (ptsdf)
# 42 - 40.5 / 2.67 <= ptsdf  
(42 - 40.5) / 2.67
# 0.5617978

# This actually is not any more interpretable than the complete season
# point diff total. 

# Model 02: Points ------------------------------------------------------------

# So point differential almost guarantees wins - or vice versa.
# Wins are guaranteed by a favorable point differential. 
# So how do points get generated? 
# This model takes a look at variables influencing points scored.

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

# Residual standard error: 176.5 on 465 degrees of freedom
# Multiple R-squared:  0.9018,	Adjusted R-squared:  0.8999 

# Pretty Good: But let's remove the less significant variables
# one at a time:
# BLK, STL, DRB
# But also think about how these defensive stats contribute to the 
# offense in indirect ways.

# look at the residuals
RegSeasonPTS$residuals

# find the sum of squared error
SSE <- sum(RegSeasonPTS$residuals^2)
SSE # 14491859
# pretty high number - not very interpretable for this situation.

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

# RMSE feels more interpretable; more of an 'average' of the errors.
# the NBA mean for points over a season is 7922, so our RMSE is somewhat close;
# being 175 points off of values in the 7-8 thousands. 

# RMSE/mean points per team per season
175/7922
# 0.02209038

# lm points V2 ----------------------------------------------------------------

# Remove indedpendent variables one by one

# remove defensive rebounds (DRB) - highest p-value.
RegSeasonV2 <- lm(PTS ~ x2PA + x3PA + FTA + AST + ORB + TOV + STL + BLK,
                  data = nbaTrain)
summary(RegSeasonV2)
# Coefficients:
# Estimate Std. Error t value Pr(>|t|)    
#   (Intercept) -118.71595  147.04708  -0.807   0.4199    
#   x2PA           0.93008    0.03740  24.869  < 2e-16 ***
#   x3PA           1.26693    0.03253  38.950  < 2e-16 ***
#   FTA            1.04628    0.04000  26.159  < 2e-16 ***
#   AST            0.60602    0.06565   9.231  < 2e-16 ***
#   ORB           -1.17608    0.10786 -10.904  < 2e-16 ***
#   TOV           -0.45590    0.08957  -5.090 5.21e-07 ***
#   STL           -0.23544    0.12412  -1.897   0.0585 .  
#   BLK            0.25990    0.12608   2.061   0.0398 * 

# Multiple R-squared:  0.9018,	Adjusted R-squared:  0.9001 
# No change on Multple r^2 and a slight improvement in Adjusted r^2

SSE2 <- sum(RegSeasonV2$residuals^2)
SSE2
# 14492365

RMSE2 <- sqrt(SSE2/nrow(nbaTrain))
RMSE2
# 174.6718
# ever so slightly higher; but really more or less the same.


# lm points V3 ----------------------------------------------------------------

# remove STL
RegSeasonV3 <- lm(PTS ~ x2PA + x3PA + FTA + AST + ORB + TOV + BLK, 
                  data = nbaTrain)
summary(RegSeasonV3)
# Coefficients:
#                   Estimate Std. Error   t value Pr(>|t|)    
#     (Intercept) -118.08524 147.45515   -0.801   0.4236    
#     x2PA           0.92512   0.03741   24.728  < 2e-16 ***
#     x3PA           1.26041   0.03243   38.860  < 2e-16 ***
#      FTA           1.04083   0.04000   26.018  < 2e-16 ***
#      AST           0.57722   0.06405    9.013  < 2e-16 ***
#      ORB          -1.19650   0.10762  -11.118  < 2e-16 ***
#      TOV          -0.48669   0.08833   -5.510 5.94e-08 ***
#      BLK           0.27512   0.12617    2.181   0.0297 *  

# Multiple R-squared:  0.9011,	Adjusted R-squared:  0.8996
# slight unimprovement; remove BLK from one more model and compare


SSE3 <- sum(RegSeasonV3$residuals^2)
SSE3
# 14604259

RMSE3 <- sqrt(SSE3/nrow(nbaTrain))
RMSE3
# 175.3448
# it got higher, but is still the same. 


# lm points V4 ----------------------------------------------------------------

# remove BLK
RegSeasonV4 <- lm(PTS ~ x2PA + x3PA + FTA + AST + ORB + TOV,
                  data = nbaTrain)
summary(RegSeasonV4)
# Coefficients:
# Estimate Std. Error t value Pr(>|t|)    
#   (Intercept) -78.28950  146.90722  -0.533    0.594    
#   x2PA          0.92022    0.03749  24.543  < 2e-16 ***
#   x3PA          1.25065    0.03225  38.776  < 2e-16 ***
#   FTA           1.04922    0.03998  26.245  < 2e-16 ***
#   AST           0.60795    0.06273   9.692  < 2e-16 ***
#   ORB          -1.16450    0.10704 -10.879  < 2e-16 ***
#   TOV          -0.47907    0.08861  -5.406 1.03e-07 ***

# Multiple R-squared:  0.9001,	Adjusted R-squared:  0.8988
# slight unimprovement; but all coefficients carry significant weight now.
# out of curiousity/domain knowledge; would like to remove TOV from the model.

SSE4 <- sum(RegSeasonV4$residuals^2)
SSE4
# 14752957

RMSE4 <- sqrt(SSE4/nrow(nbaTrain))
RMSE4
# 176.2352
# the more variables we take away, the higher the RMSE inches.

# lm points V5 ----------------------------------------------------------------

# remove TOV
RegSeasonV5 <- lm(PTS ~ x2PA + x3PA + FTA + AST + ORB, data = nbaTrain)
summary(RegSeasonV5)
# Multiple R-squared:  0.8938,	Adjusted R-squared:  0.8927 
# again, slight unimprovement; but slightly more than removing the previous 
# two variables. Now model consists of all offensive metrics. 
# Stricly by numbers on r^2 and error, RegSeasonV2 is the best model. 
# So let's take a look at the sum of squared errors and root mean sq error
# for RegSeasonV2

SSE5 <- sum(RegSeasonV5$residuals^2)
SSE5
# [1] 15674293

RMSE5 <- sqrt(SSE5/nrow(nbaTrain))
RMSE5
# [1] 181.6549

# Removing the turnovers was one variable too many I think.

# So removing variables one by one steadily increased the SSE and RMSE.
# What does this mean? 
# It's good practice to trim the model to be as simple as possible (but no simpler)

# vectors to dataframe of errors
SumSqError <- c(SSE, SSE2, SSE3, SSE4, SSE5)
RootMeanSqError <- c(RMSE, RMSE2, RMSE3, RMSE4, RMSE5)
rSquared <- c(0.9018, 0.9018, 0.9011, 0.9001, 0.8938)
errors <- data.frame(SumSqError = SumSqError, RootMeanSqError = RootMeanSqError,
                     rSquared = rSquared)

# Judging strictly by the numbers, points model V2 might be the best fit. 

# Prediction on Test set ------------------------------------------------------

PointsPrediction <- predict(RegSeasonV2, newdata = nbaTest)
summary(PointsPrediction)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   7956    8346    8506    8520    8688    9164 

table(PointsPrediction)

# out of sample RSquared:

# sum of squared error
# sum of (difference between prediction and test points squared)
ssePredict <- sum((PointsPrediction - nbaTest$PTS)^2)

# total sum of squares
# mean of actual point total minus test point total
sstPredict <- sum((mean(nbaTrain$PTS) - nbaTest$PTS)^2)

r2 <- 1 - (ssePredict / sstPredict)
r2
# 0.8393029 for rSqaured value on this prediction. 
# still a strong positive linear relationship

rmsePredict <- sqrt(ssePredict/nrow(nbaTest))
rmsePredict
# 233.7225

mean(errors$RootMeanSqError)
# 176.5151

# difference in rsme between prediction and mean of training models
rmsePredict - mean(errors$RootMeanSqError)
# 57.20739

mean(errors$rSquared)
# 0.89972

# difference between predicted r^2 and mean of training model r^2
r2 - mean(errors$rSquared)
# -0.06041706

# So the prediction model on the test set differs by 57 points from 
# the models run on training data, and the rSquared value drops by 0.06 
# from the mean of the rSqaured values in the 5 models. Perhaps using the
# V2 model resulted in ovefitting from trying to reduce the error.

# difference in prediction rSquared and training model rSqaured
r2 - errors$rSquared[2]
# -0.06249706

# Prediction V2 ---------------------------------------------------------------

# try using RegSeasonV4, which let go of all less significant variables 
# and didn't suffer a large change in error values.

PointsPredictionV2 <- predict(RegSeasonV4, newdata = nbaTest)
summary(PointsPredictionV2)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   7947    8361    8492    8517    8689    9140 

table(PointsPredictionV2)

# sum of squared errors
ssePredictV2 <- sum((PointsPredictionV2 - nbaTest$PTS)^2)
ssePredictV2
# 1704450

# total sum of squares
sstPredictV2 <- sum((mean(nbaTrain$PTS) - nbaTest$PTS)^2)

# rSquared
r2v2 <-  1 - (ssePredictV2 / sstPredictV2)
r2v2
# 0.832864
# Not bad - similar to RegSeasonV2's prediction.

par(mfrow = c(2, 2), mar = c(6, 6, 6, 6))
plot(RegSeasonV4)

# NBA Moneyball
# fuckin finally

# load data -----------------------------------------------

NBA <- read.csv("data_lecture/NBA_train.csv")
NBA_test <- read.csv("data_lecture/NBA_test.csv")

# tear it up ----------------------------------------------

str(NBA)
summary(NBA)

# linear regression model ---------------------------------
# find the coefficients, get the predictor equation

# wins ~ playoffs - playoffs is a binary
table(NBA$W, NBA$Playoffs)
wplay <- lm(W ~ Playoffs, data = NBA)
summary(wplay)

# compute and plot point differential
NBA$PTSdiff <- NBA$PTS - NBA$oppPTS
par(mar = c(8, 8, 8, 8))
plot(NBA$PTSdiff, NBA$W, 
     xlab = "NBA pt. differential",
     ylab = "number of wins", 
     main = "NBA: Point Differential ~ Wins, 1980-2011")

# predict regular season wins with Wins ~ Pt Differential
WinsReg <- lm(W ~ PTSdiff, NBA)
summary(WinsReg)

# Points regression model ---------------------------------

PointsReg <- lm(PTS ~ X2PA + X3PA + FTA + AST + ORB + DRB +
                  TOV + STL + BLK, data = NBA)
summary(PointsReg)
PointsReg$residuals

# sum of squared errors
SSE <- sum(PointsReg$residuals^2)
SSE # 28394314
# --- very high

# look at RMSE 
RMSE <- sqrt(SSE/nrow(NBA))
RMSE # 184.4049
mean(NBA$PTS) # 8370.24

# so 184 isn't so high.
# remove insignificant variables one at a time:
# TOV -> highest p-value - first out
PointsRegV2 <- lm(PTS ~ X2PA + X3PA + FTA + AST + ORB + 
                  DRB +STL + BLK, data = NBA)
summary(PointsRegV2)

# DRB - next highest p-value now out:
PointsRegV3 <- lm(PTS ~ X2PA + X3PA + FTA + AST + ORB + 
                    STL + BLK, data = NBA)
summary(PointsRegV3)

# BLK - no significance to model
PointsRegV4 <- lm(PTS ~ X2PA + X3PA + FTA + AST + ORB + STL, data = NBA)
summary(PointsRegV4)

SSE4 <- sum(PointsRegV4$residuals^2)
RSME4 <- sqrt(SSE4/nrow(NBA))
SSE4 # 28421465
RSME4 # 184.493


# Making Predictions --------------------------------------

PointsPrediction <- predict(PointsRegV4, newdata = NBA_test)
summary(PointsPrediction)

SSE_pp <- sum((PointsPrediction - NBA_test$PTS)^2)
SST <- sum((mean(NBA$PTS) - NBA_test$PTS)^2)
r2 <- 1 - SSE_pp/SST
r2 # 0.8127142

RMSE <- sqrt(SSE_pp/nrow(NBA_test))
RMSE # 196.3723

mean(NBA_test$PTS)

NBA 2k17
========

_student work in R_

What follows is a basic, off-the-shelf linear regression to predict the number of cumulative points a team will need to score to make the NBA playoffs for the 2016-17 season. 

This is a **very** simple linear regression on some **very** simple data (read: no advanced metrics, no polynomial regressions). It's not trying to make the firmest real-world predictions, and also doesn't take into account the Draft or recent free agency moves that could easily throw the balance of the league off (\*cough*, _Durant_).

Going to be following the steps outlined in this [MIT/EdX](https://www.youtube.com/watch?v=WfaKNYR2vAA) lecture with some possibility for freestyling on the framework if I'm feeling like opening up the statistics book. I know MIT profs have more important things to do than know the difference between _baseball_ and _basketball_, but I still find it funny that this recitation used the two terms interchangeably. 

- [the code](nba2k17.R), in progress. 
- [notes](notes.md) in detail for reference. 


# the Data

[Basketball-Reference](http://basketball-reference.com) is an amazing resource, but their statistics don't always come ready to plug right into R. For instance, Wins/Losses are in a different table from traditional statistics. On top of that, team records are divided by conference while the trad stats are one table of all 30 teams. So! Because of all this, I ended up downloading 3 different CSV for each season from the site - one for team stats, one for opponent stats, and one for the standings. 

This is not to say anything against Basketball-Reference - but more to point out for a specific analysis within a specific programming language, it won't always be a plug-and-play situation.

The cleaning, binding, and cleaning script is [here](nba2k17-bind.R).

## Exploratory

correlations between variables? added ptsDIFF variable, for point differential...

![corrplot01](plots/nba-corrplot-ptsDIFF-01.png)

...which as Moneyball has proven, is a pretty strong indicator/estimator/predictor of Wins:

![ptDiff02-lm](plots/PtDiff-02-lm.png)

## since 2000

the [NBA Rulebook](NBA-rulebook-00.md) - amendments by year.

It's been said often that the league has gotten 'soft' since the 1990s- meaning, among many things, that defensive rules have changed in favor of higher scoring games. An immediate example that comes to mind is the reinstatement of zone defense (3 second defensive caveat). Others include hand-checking. 

So the [rulebook amendments](http://www.nba.com/analysis/rules_history.html) since 2000 are here for further research into which intervals in the NBA might've had effects on scoring.



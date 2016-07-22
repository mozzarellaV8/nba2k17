NBA 2K17
========

_student work in R_

What follows is a basic, off-the-shelf linear regression to predict the number of cumulative points a team will need to score to make the NBA playoffs for the 2016-17 season. 

This is a **very** simple linear regression on some _very_ simple data (read: no advanced metrics). It's not trying to make the firmest predictions, and also doesn't take into account recent free agency moves that could easily throw the balance of the league off (\*cough*, _Durant_).

Going to be following the steps outlined in this [MIT/EdX](https://www.youtube.com/watch?v=WfaKNYR2vAA) lecture with some possibility for freestyling on the framework if I'm feeling like opening up the statistics book. I know MIT profs have more important things to do than know the difference between _baseball_ and _basketball_, but I still find it funny that this recitation used the two terms interchangeably. 


# the Data

[Basketball-Reference](http://basketball-reference.com) is an amazing resource, but their statistics don't always come ready to plug right into R. For instance, Wins/Losses are in a different table from traditional statistics. On top of that, team records are divided by conference while the trad stats are one table of all 30 teams. So! Because of all this, I ended up downloading 3 different CSV for each season from the site - one for team stats, one for opponent stats, and one for the standings. 

This is not to say anything against Basketball-Reference - but more to point out for a specific analysis within a specific programming language, it won't always be a plug-and-play situation.

The cleaning, binding, and cleaning script is [here](nba2k17-bind.R)





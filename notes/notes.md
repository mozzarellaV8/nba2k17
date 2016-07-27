# Notes

- [Step by Step](#step-by-step)


# Step by Step

**How many regular season wins does an NBA team need to have a strong chance at making the playoffs?**

After splitting the data into training (2000-2015) and test (2016) sets, making a table of Wins vs. Playoff Appearances gives a sense of how many wins a team needs for a strong shot at making the playoffs. 

``` r
table(nbaTrain$W, nbaTrain$Playoffs)
```

![WinsPlayoffTable](plots/WinsPlayoffTable.png)

**How many points does a team need to win by - on average - to have a strong chance at a W?** 

This is the Point Differential (`ptsDIFF`), and it's calculated seasonally from each team's point totals. Simple formula: 

	Points Scored minus Points Allowed = Points Differential





# Sum of Squared Error Calculation

``` r
SSE <- sum()
```
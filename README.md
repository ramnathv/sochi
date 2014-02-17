## Sochi Olympics Medal Tally

This is an [OpenCPU](http://opencpu.org) application that uses the [NVD3](http://nvd3.org) binding in [rCharts](http://rcharts.io) to visualize the medal counts by event in the Sochi Winter Olympics. Data is scraped from the [Sochi Olympics website](http://www.sochi2014.com/en)

![Imgur](http://i.imgur.com/SJJuwuG.png)

The basic workhorse of this application is the [getMedalCounts](https://github.com/ramnathv/sochi/blob/master/R/sochi.R#L1) function, which accepts the `event` name and the `year` and returns a data frame with the medal tallies, in the long format.


```r
library(sochi)
medals <- getMedalCounts(event = "alpine-skiing", year = "2010")
head(medals)
```

```
##         Country Rank Medal Count
## 1       Germany    1  Gold     3
## 2 United States    2  Gold     2
## 3   Switzerland    3  Gold     2
## 4        Norway    4  Gold     1
## 5       Austria    5  Gold     1
## 6         Italy    6  Gold     1
```



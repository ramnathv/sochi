## Sochi Olympics Medal Tally

This is an [OpenCPU](http://opencpu.org) application that uses the [NVD3](http://nvd3.org) binding in [rCharts](http://rcharts.io) to visualize the medal counts by event in the Sochi Winter Olympics. Data is scraped from the [Sochi Olympics website](http://www.sochi2014.com/en)

![Imgur](http://i.imgur.com/SJJuwuG.png)

### Create R Package

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


The chart is then generated using the [sochiChart](https://github.com/ramnathv/sochi/blob/master/R/sochi.R#L38) function, which uses `nPlot` fromm [rCharts](http://rcharts.io). The code is fairly self-explanatory.

```S
sochiChart <- function(event, year){
  data = getMedalCounts(event, year)
  n1 <- nPlot(Count ~ Country, 
    data = data,
    type = 'multiBarHorizontalChart',
    group = 'Medal'
  )
  n1$chart(
    color = c('#C98910', '#A8A8A8', '#965A38'),
    stacked = TRUE,
    margin = list(left = 100),
    showControls = FALSE,
    tooltip = "#! function(key, x, y, e, graph) {
        return '<p><b>' + key + '</b>: ' +  y + '</p>'
    } !#"
  )
  n1$yAxis(tickFormat = "#! function(d){return d3.format('.0f')(d)} !#")
  return(n1)
}
```

For the web-application, we need a function that would return only the chart fragment, without the entire HTML. This is achieved using the `inlineChart` function

```S
inlineChart <- function(event, year){
  n1 <- sochiChart(event, year)
  n1$set(height = 650)
  paste(capture.output(n1$show('inline')), collapse ='\n')
}
```

### Add OpenCPU App

We have all the required functions in the R package to turn in into a web-app. The first step is to create a boilerplate HTML page with all the js/css assets that we will require.

```html
<!doctype HTML>
<meta charset = 'utf-8'>
<html>
  <head>
    <title>Sochi Olympics App using OpenCPU</title>
    <link href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css" rel='stylesheet'>
    <link href='nvd3/css/nv.d3.css' rel='stylesheet' >
    <script src='nvd3/js/jquery-1.8.2.min.js' type='text/javascript'></script>
    <script src='nvd3/js/d3.v3.min.js' type='text/javascript'></script>
    <script src='nvd3/js/nv.d3.min-new.js' type='text/javascript'></script>
    <script src='nvd3/js/fisheye.js' type='text/javascript'></script>
    <script src='opencpu/opencpu-0.4.js' type='text/javascript'></script>
    <script src='//ajax.googleapis.com/ajax/libs/angularjs/1.2.1/angular.min.js'></script>
  </head>
  <body ng-app>
  
  </body>
</html>
```






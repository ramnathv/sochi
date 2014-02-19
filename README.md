## Sochi Olympics Medal Tally

This is an [OpenCPU](http://opencpu.org) application that uses the [NVD3](http://nvd3.org) binding in [rCharts](http://rcharts.io) to visualize the medal counts by event in the Sochi Winter Olympics. Data is scraped from the [Sochi Olympics website](http://www.sochi2014.com/en)

![Imgur](http://i.imgur.com/hrbo8r4.png)

### Quick Start

The easiest way to run this webapp locally is to install the `sochi` package from `github`

```S
install.packages('XML', type = 'source')
devtools::install_github('ramnathv/sochi')
library(opencpu)
opencpu$browse('/library/sochi/www')
```


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
<meta charset='utf-8'>
<html>
  <head>
    <title>Sochi Olympics App using OpenCPU</title>
    <link href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css" rel='stylesheet'>
    <link href='nvd3/css/nv.d3.css' rel='stylesheet' >
    <script src='nvd3/js/jquery-1.8.2.min.js' type='text/javascript'></script>
    <script src='nvd3/js/d3.v3.min.js' type='text/javascript'></script>
    <script src='nvd3/js/nv.d3.min-new.js' type='text/javascript'></script>
    <script src='opencpu/opencpu-0.4.js' type='text/javascript'></script>
    <script src='//ajax.googleapis.com/ajax/libs/angularjs/1.2.1/angular.min.js'></script>
  </head>
  <body ng-app>
    ...
  </body>
</html>
```

Now, we need to build an AngularJS controller, that would accept two inputs, `event` and `year` and call the `inlineChart` function to return the chart html. Here is a brief explanation of how this works. The controller function `SochiCtr` is doing three things:

1. Sets the initial values of `events`, `event`, `years` and `year`.
2. Defines a `makeChart` function that uses OpenCPU to call `inlineChart` and return the chart fragment.
3. Watches for changes in `event` and `year` and calls `makeChart` to update the chart.

```js
function SochiCtrl($scope){
  $scope.events = ['all', 'alpine-skiing', 'cross-country', 'freestyle-skiing', 
    'nordic-combined',  'ski-jumping', 'biathlon', 'short-track', 'snowboard', 
    'bobsleigh', 'figure-skating', 'luge', 'skeleton', 'speed-skating']
  $scope.event = $scope.events[0]
  $scope.years = ["2014", "2010", "2006", "2002", "1996", "1992", "1988", "1984"]
  $scope.year = $scope.years[0]    
  
  $scope.makeChart = function(){
    var req = ocpu.rpc("inlineChart",  {"event": $scope.event, "year": $scope.year}, 
      function(output){   
        $('#sochi').html(output)
      }).fail(function(text){
         alert("Error: " + req.responseText);
      });
    }
  $scope.$watchCollection('[event, year]', function(newValues){
    $scope.makeChart({event: newValues[0], year: newValues[1]})
  })
}
```

We now need to add the required HTML to display the controls and the chart. We use [Bootstrap](http://getbootstrap.com) for a nice HTML page out-of-the-box. The key is the two `<select>...</select>` boxes, which are dynamically populated by the controller. AngularJS uses the `$scope` variable to maintain two-way data binding, reducing the need for writting spaghetti update code.

```html
<div class='container'>
  <div class='row' id='medals'>
    <div class='col-md-3' ng-controller='SochiCtrl'>
      <select class='form form-control' ng-model='event' 
        ng-options='event for event in events'></select><br/>
      <select class='form form-control' ng-model='year' 
        ng-options='year for year in years'></select>
    </div>
    <div class='col-md-9'>
     <div id='sochi'></div>
    </div>
  </div>
</div>
```






getMedalCounts = function(){
  options(stringsAsFactors = F)
  standings = readHTMLTable(
    'http://www.sochi2014.com/en/medal-standings', which = 1,
    colClasses = c('character', 'character', rep('numeric', 4))
  )
  standings_m = melt(subset(standings, Total > 0), 
    id = c('Country', 'Rank'),
    variable.name = 'Medal', value.name = 'Count'
  )
  return(standings_m)
}

sochiChart <- function(){
  standings_m = getMedalCounts()
  n1 <- nPlot(Count ~ Country, 
    data = subset(standings_m, as.character(Medal) != "Total"),
    type = 'multiBarHorizontalChart',
    group = 'Medal'
  )
  n1$chart(
    color = c('#C98910', '#A8A8A8', '#965A38'),
    stacked = TRUE,
    margin = list(left = 100),
    showControls = FALSE
  )
  n1$yAxis(tickFormat = "#! function(d){return d3.format('.0f')(d)} !#")
  return(n1)
}

saveChart <- function(){
  n1 <- sochiChart()
  n1$set(height = 700)
  n1$save('output.html', cdn = T)
  return(invisible())
}

inlineChart <- function(){
  n1 <- sochiChart()
  n1$set(height = 650)
  paste(capture.output(n1$show('inline')), collapse ='\n')
}

getMedalCounts = function(event = 'all'){
  options(stringsAsFactors = F)
  if (event == 'all'){
    standings <- readHTMLTable(
      'http://www.sochi2014.com/en/medal-standings', which = 1,
      colClasses = c('character', 'character', rep('numeric', 4))
    )
  } else {
    standings <- readHTMLTable(
      paste0('http://www.sochi2014.com/en/', event), 
      which = 2, skip = 1,
      colClasses = c('character', 'character', rep('numeric', 4))
    )
    names(standings) = c('Rank', 'Country', 'Gold', 'Silver', 'Bronze', 'Total')
  }
  standings_m = melt(subset(standings, Total > 0), 
    id = c('Country', 'Rank'),
    variable.name = 'Medal', value.name = 'Count'
  )
  standings_m = subset(standings_m, as.character(Medal) != "Total")
  return(standings_m)
}

sochiChart <- function(event){
  data = getMedalCounts(event)
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

saveChart <- function(event){
  n1 <- sochiChart(event)
  n1$set(height = 700)
  n1$save('output.html', cdn = T)
  return(invisible())
}

inlineChart <- function(event){
  n1 <- sochiChart(event)
  n1$set(height = 650)
  paste(capture.output(n1$show('inline')), collapse ='\n')
}

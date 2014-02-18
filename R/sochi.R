#' Get Medal Counts
getMedalCounts = function(event = 'all', year = '2014'){
  options(stringsAsFactors = F)
  standings = do.call(readHTMLTable, makePayload(event, year))
  names(standings) = c('Rank', 'Country', 'Gold', 'Silver', 'Bronze', 'Total')
  standings_m = melt(subset(standings, Total > 0), 
    id = c('Country', 'Rank'),
    variable.name = 'Medal', value.name = 'Count'
  )
  standings_m = subset(standings_m, as.character(Medal) != "Total")
  return(standings_m)
}

makePayload = function(event, year){
  colClasses = c('character', 'character', rep('numeric', 4))
  if (year != '2014'){
    event = ifelse(event == 'all', "", 
      paste(toupper(substr(strsplit(event, '-')[[1]], 1, 1)), collapse = '')
    )
    list(
      doc = sprintf('http://www.sochi2014.com/en/medal-history?year=%s&sport=%s', year, event),
       which = 1, skip = NULL, colClasses = colClasses
    )
  } else {
    if (event == 'all'){
      list(
        doc = 'http://www.sochi2014.com/en/medal-standings',
         which = 1, skip = NULL, colClasses = colClasses
      )
    } else {
      list(
        doc =  paste0('http://www.sochi2014.com/en/', event),
         which = 2, skip = 1, colClasses = colClasses
      )
    }
  }
}

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

saveChart <- function(event, year){
  n1 <- sochiChart(event, year)
  n1$set(height = 700)
  n1$save('output.html', cdn = T)
  return(invisible())
}

inlineChart <- function(event, year){
  n1 <- sochiChart(event, year)
  n1$set(height = 650)
  paste(capture.output(n1$show('inline')), collapse ='\n')
}

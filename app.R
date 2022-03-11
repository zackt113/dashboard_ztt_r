library(dash)
library(dashHtmlComponents)
library(dashCoreComponents)
library(ggplot2)
library(plotly)
library(dplyr)

app <- Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP)

movie <- read.csv('data/movies_clean_df.csv') %>% 
  setNames(c("Index", "Title", "Major_Genre","Duration","Year", "US_Revenue",
             "IMDB_Rating", "MPAA_Rating"))


app$layout(
  dbcContainer(
    list(
      dccGraph(id='plot-area'),
      htmlBr(),
      htmlLabel('Year'),
      dccRangeSlider(
        id='year_range',
        step = 1,
        min = 1980,
        max = 2016,
        marks = list("1980"="1980", "2016"="2016"),
        value = list(1990, 2005)
        )
    )
  )
)

app$callback(
  output('plot-area', 'figure'),
  list(input('year_range', 'value')),
  function(year) {
    p <- movie %>% 
      filter(Year >= year[1] & Year <= year[2]) %>% 
        ggplot(aes(x = Duration, 
                   y = IMDB_Rating, 
                   color = Major_Genre)) +
        geom_point() +
      xlab ("IMDB Rating") +
      ylab("Duration (in mins)") +
      ggtitle("Duration Vs. IMDB Rating") +
      ggthemes::scale_color_tableau() +
      theme_bw()
    p <- p + guides(fill=guide_legend(title="Genre"))
    ggplotly(p)
  }
)

app$run_server(host =  '0.0.0.0')

# This is the file to set up UI for the covid 19 dashboard
# 2020-03-27
# MJW

ui <- navbarPage(
  "Novel Coronavirus Global Pandemic",
  theme = shinytheme("cerulean"),
  
  #tabPanel("Introduction"),
  tabPanel("Global",
           highchartOutput(outputId = "worldmap"),
           column(6, highchartOutput(outputId = "no_countries")),
           column(6, highchartOutput(outputId = "total_cases_ranking")),
           column(6, highchartOutput(outputId = "total_deaths_ranking")),
           column(6, highchartOutput(outputId = "death_rate")),
           column(12, highchartOutput(outputId = "time_series"))),
  tabPanel("New Zealand",
           column(12, align = "center", tags$h3("Covid 19 in New Zealand (DHB)")),
           column(3),
           column(6,leafletOutput(outputId = "nzmap", height = 600, width = "100%")),
           column(3))#,
  #tabPanel("More")
)

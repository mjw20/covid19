# This is the file to set up UI for the covid 19 dashboard
# 2020-03-27
# MJW

ui <- navbarPage(
  "Novel Coronavirus Pandemic",
  theme = shinytheme("cerulean"),
  
  #tabPanel("Introduction"),
  tabPanel("Global",
           highchartOutput(outputId = "worldmap")),
  tabPanel("New Zealand"),
  tabPanel("More")
)

# This is the file to set up UI for the covid 19 dashboard
# 2020-03-27
# MJW

ui <- navbarPage(
  "Novel Coronavirus Global Pandemic",
  theme = shinytheme("cerulean"),
  
  #tabPanel("Introduction"),
  tabPanel("Global",
           highchartOutput(outputId = "worldmap"),
           useShinydashboard(),
           infoBox(title = "Total Cases", value = max(sum(global_today$total_cases), world_info_display$total_cases), width = 3, color = "olive", icon = shiny::icon("user-md")),
           infoBox(title = "Total Deaths", value = max(sum(global_today$total_deaths),world_info_display$total_deaths), width = 3, color = "olive", icon = shiny::icon("bible")),
           infoBox(title = "New Cases", value = max(sum(global_today$new_cases),world_info_display$new_cases), width = 3, color = "olive", icon = shiny::icon("ambulance")),
           infoBox(title = "New Deaths", value = world_info_display$new_deaths, width = 3, color = "olive", icon = shiny::icon("bed")),
           column(12, highchartOutput(outputId = "time_series")),
           column(12, highchartOutput(outputId = "trend_comparing")),
           column(6, highchartOutput(outputId = "no_countries")),
           column(6, highchartOutput(outputId = "total_cases_ranking")),
           column(6, highchartOutput(outputId = "total_deaths_ranking")),
           column(6, highchartOutput(outputId = "death_rate"))),
  tabPanel("New Zealand",
           highchartOutput(outputId = "nzmap_hi"))#,
  #tabPanel("More")
)

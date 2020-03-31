# This is the file to set up UI for the covid 19 dashboard
# 2020-03-27
# MJW

ui <- navbarPage(
  "Covid-19 Global Pandemic",
  theme = shinytheme("cosmo"),
  
  #tabPanel("Introduction"),
  tabPanel("Global",
           highchartOutput(outputId = "worldmap", height = "500px"),
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
           highchartOutput(outputId = "nzmap_hi", height = "500px"),
           infoBox(title = "Active Cases", value = nrow(df_nzmoh_all), width = 3, color = "navy", icon = shiny::icon("hospital")),
           infoBox(title = "Confirmed Cases", value = (df_nzmoh_all %>% group_by(type) %>% summarise(n = n()))$n[1], width = 3, color = "navy", icon = shiny::icon("frown")),
           infoBox(title = "Probable Cases", value = (df_nzmoh_all %>% group_by(type) %>% summarise(n = n()))$n[2], width = 3, color = "navy", icon = shiny::icon("question")),
           infoBox(title = "Total Deaths", value = as.numeric(df_world_latest[which(df_world_latest$location == "New Zealand"), "total_deaths"]), width = 3, color = "navy", icon = shiny::icon("cross")),
           #column(4),
           column(12, align = "center", DT::dataTableOutput(outputId = "nz_current", width = "50%")),
           #column(4),
           column(12, highchartOutput(outputId = "nz_ts")),
           column(6, highchartOutput(outputId = "nzdhb_column")),
           column(6, highchartOutput(outputId = "nzgender_pie")),
           column(6, highchartOutput(outputId = "nz_ethnicty_pie")),
           column(6, highchartOutput(outputId = "nz_age_column")),
           column(6, highchartOutput(outputId = "nz_oversea")),
           column(6),
           column(12, highchartOutput(outputId = "nz_travel_routes", height = "500px")))#,
  #tabPanel("More")
)

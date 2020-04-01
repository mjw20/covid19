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
           column(6, highchartOutput(outputId = "time_series_total")),
           column(6, highchartOutput(outputId = "time_series__total_log")),
           column(6, highchartOutput(outputId = "time_series")),
           column(6, highchartOutput(outputId = "time_series_log")),
           column(6, highchartOutput(outputId = "trend_comparing")),
           column(6, highchartOutput(outputId = "trend_comparing_log")),
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
           column(12, align = "center", DT::dataTableOutput(outputId = "nz_current", width = "50%")),
           column(6, highchartOutput(outputId = "nz_total")),
           column(6, highchartOutput(outputId = "nz_total_log")),
           column(12, highchartOutput(outputId = "nz_ts")),
           column(6, highchartOutput(outputId = "nzdhb_column")),
           column(6, highchartOutput(outputId = "nzgender_pie")),
           column(6, highchartOutput(outputId = "nz_ethnicty_pie")),
           column(6, highchartOutput(outputId = "nz_age_column")),
           column(6, highchartOutput(outputId = "nz_oversea")),
           column(6),
           column(12, highchartOutput(outputId = "nz_travel_routes", height = "500px"))),
  tabPanel("Data",
           h3("Global Data from European Centre for Disease Prevention and Control"),
           DT::dataTableOutput(outputId = "world_data_ecdc"),
           h3("Global Data (Latest) from Johns Hopkins"),
           DT::dataTableOutput(outputId = "world_data_john"),
           h3("New Zealand Data from Ministry of Health NZ"),
           DT::dataTableOutput(outputId = "nz_data")),
  tabPanel("Declaration",
           h3("Statement"),
           HTML("This R Shiny App is designed for tracking the changes of Covid-19 Global Pandemic, it is solely for my own resarch interest, and not for profit or business. <br/>
                Since I live in New Zealand, so beisdes the global situation, the dashboard is more concentrate on New Zealand. <br>
                The major package used in this App is highcharter, and thanks to their generous policy to make it free for personal users!!!"),
           h3("Data Sources"),
           HTML("This App uses data from 3 different sources: <br/>"),
           tags$ul(
             tags$li("European Centre for Disease Prevention and Control", tags$a(href = "https://covid.ourworldindata.org/data/ecdc/full_data.csv", "Click here!")), 
             tags$li("Johns Hopkins data", tags$a(href = "https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series", "Click here!")), 
             tags$li("Ministry of Health New Zealand", tags$a(href = "https://www.health.govt.nz/our-work/diseases-and-conditions/covid-19-novel-coronavirus/covid-19-current-situation/covid-19-current-cases", "Click here!"))
           ),
           HTML("As the 3 sources are not updating their data at the same time, so sometimes there will be synchronisation issues. <br/>
                I have tried my best to provide the most accurate and updated figures in this App from open sources data <br/>"),
           h3("Contact Details"),
           HTML("Advices, comments, and corrections or simply say hi are more than welcome, <br/> feel free to contact me via email at mjw20@outlook.com"))
)

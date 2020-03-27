# This is the file to set up SERVER for the covid 19 dashboard
# 2020-03-27
# MJW

server <- function(input, output){
  output$worldmap <- renderHighchart({
    hcmap(map = "custom/world", data = df_world_latest, value = "total_cases",
          joinBy = "iso-a3",
          name = "Current Situation",
          dataLabels = list(enabled = TRUE, format = '{point.name}'),
          borderColor = "#FAFAFA", borderWidth = 0.1) %>% 
      hc_tooltip(useHTML = TRUE,
                 pointFormat = "Total Cases: {point.total_cases} <br/> Total Deaths: {point.total_deaths}") %>% 
      hc_colorAxis(minColor = "green", maxColor = "red", max = max(df_world_latest$total_cases), type = "logarithmic") %>% 
      hc_title(text = "Covid-19 Global Pandemic")
  })
}




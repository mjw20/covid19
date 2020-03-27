# This is the file to set up SERVER for the covid 19 dashboard
# 2020-03-27
# MJW

server <- function(input, output){
  output$worldmap <- renderHighchart({
    hcmap(map = "custom/world")
  })
}


hcmap(map = "custom/world", data = df_world_latest, value = "total_cases",
      joinBy = "iso-a3", name = "Total Cases",
      dataLabels = list(enabled = TRUE, format = '{point.name}'),
      borderColor = "#FAFAFA", borderWidth = 0.1) 

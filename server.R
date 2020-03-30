# This is the file to set up SERVER for the covid 19 dashboard
# 2020-03-27
# MJW

server <- function(input, output){
  
  # Page Global
  
  output$worldmap <- renderHighchart({
    hcmap(map = "custom/world", data = global_latest, value = "total_cases",
          joinBy = "iso-a3",
          name = "Current Situation",
          dataLabels = list(enabled = TRUE, format = '{point.name}'),
          borderColor = "#FAFAFA", borderWidth = 0.1) %>% 
      hc_tooltip(useHTML = TRUE,
                 pointFormat = "{point.location} <br/> Total Cases: {point.total_cases} <br/> Total Deaths: {point.total_deaths}") %>% 
      hc_colorAxis(minColor = "green", maxColor = "red", max = max(global_latest$total_cases), type = "logarithmic") %>% 
      hc_title(text = "Covid-19 Global Pandemic") %>% 
      hc_exporting(enabled = TRUE, filename = "global_pandemic_map") %>% 
      hc_mapNavigation(enabled = TRUE)
  })
  
  output$time_series <- renderHighchart({
    df_world %>% 
      filter(location %in% c(df_world_latest_top20$location, "New Zealand")) %>% 
      hchart(type = "line", hcaes(x = date, y = total_cases, group = location)) %>% 
      hc_title(text = "Time Series per Country (Top 20 + New Zealand)") %>% 
      hc_xAxis(title = "") %>% 
      hc_yAxis(title = list(text = "total cases")) %>% 
      hc_exporting(enabled = TRUE, filename = "time_series20")
  })
  
  output$trend_comparing <- renderHighchart({
    world_trend %>%  
      hchart(type = "line", hcaes(x = stamp, y = total_cases, group = location)) %>% 
      hc_title(text = "Trend Comparing Over Time (Top 20 + New Zealand)") %>% 
      hc_xAxis(title = "") %>% 
      hc_yAxis(title = list(text = "total cases")) %>% 
      hc_exporting(enabled = TRUE, filename = "trend_series20")
  })
  
  output$no_countries <- renderHighchart({
    df_transit <- df_world %>% filter(total_cases > 0, location != "World", location != "International") %>%  
      group_by(date) %>% summarise(no_countries = length(unique(location))) %>% 
      mutate(Diff = no_countries - lag(no_countries))
    
    repeat{
      df_transit$no_countries[which(df_transit$Diff < 0)] = df_transit$no_countries[which(df_transit$Diff < 0) - 1]
      df_transit <- df_transit %>% mutate(Diff = no_countries - lag(no_countries))
      if(min(df_transit$Diff, na.rm = TRUE) == 0){break}
    }
    df_transit$date <- as.character(df_transit$date)
    df_transit %>% hchart(type = "column", hcaes(x = date, y = no_countries), name = "number of countries") %>% 
      hc_title(text = "No. of Countries Hitted by Covid-19") %>% 
      hc_xAxis(title = "") %>% 
      hc_yAxis(title = list(text = "no. of countries")) %>% 
      hc_exporting(enabled = TRUE, filename = "no_countries")
  })
  
  output$total_cases_ranking <- renderHighchart({
    
    df_world_latest %>% filter(location != "World", location != "International") %>%
      arrange(desc(total_cases)) %>%
      slice(1:20) %>% 
      hchart(type = "bar", hcaes(x = location, y = total_cases), name = "total cases", color = "red") %>% 
      hc_title(text = "Total Cases per Country (Top 20)") %>% 
      hc_yAxis(title = list(text = "no. of cases")) %>% 
      hc_xAxis(title = "") %>% 
      hc_exporting(enabled = TRUE, filename = "total_cases20")
  })
  
  output$total_deaths_ranking <- renderHighchart({
    
    df_world_latest %>% filter(location != "World", location != "International") %>%
      arrange(desc(total_deaths)) %>%
      slice(1:20) %>% 
      hchart(type = "bar", hcaes(x = location, y = total_deaths), name = "total deaths", color = "grey") %>% 
      hc_title(text = "Death Cases per Country (Top 20)") %>% 
      hc_yAxis(title = list(text = "no. of deaths")) %>% 
      hc_xAxis(title = "") %>% 
      hc_exporting(enabled = TRUE, filename = "total_deaths20")
  })
  
  output$death_rate <- renderHighchart({
    
    df_world_latest %>% filter(location != "World", location != "International") %>% 
      mutate(death_rate = total_deaths/total_cases) %>% arrange(desc(total_cases), desc(death_rate)) %>% 
      slice(1:20) %>% 
      mutate(death_rate = round(death_rate*100, digits = 3)) %>% 
      hchart(type = "column", hcaes(x = location, y = death_rate), name = "Death Rate", color = "black",
             tooltip = list(pointFormat = "death rate: {point.death_rate}%")) %>% 
      hc_title(text = "Death Rate per Country (Top 20)") %>% 
      hc_xAxis(title = "") %>% 
      hc_yAxis(title = list(text = "death rate %")) %>% 
      hc_exporting(enabled = TRUE, filename = "death_rate20")
    
  })
  
  
  
  # Page New Zealand
  
  output$nzmap_hi <- renderHighchart({
    df <- df_nzmoh %>% group_by(DHB) %>%
      summarise(total_cases = n()) %>% mutate(DHB2015_Na = DHB)
    
    highchart() %>%
      hc_add_series_map(Myhcmap, df = df, value = "total_cases", 
                        name = "total cases", joinBy = "DHB2015_Na", showInLegend = T,
                        dataLabels = list(enabled = TRUE, format = '{point.DHB2015_Na}'),
                        borderColor = "#FAFAFA", borderWidth = 0.1) %>% 
      hc_tooltip(useHTML = TRUE,
                 pointFormat = "{point.DHB2015_Na} <br/> Total Cases: {point.total_cases}") %>% 
      hc_colorAxis(minColor = "green", maxColor = "red", max = max(df$total_cases)) %>% 
      hc_title(text = "Covid-19 New Zealand DHB") %>% 
      hc_exporting(enabled = TRUE, filename = "nz_pandemic_map") %>% 
      hc_mapNavigation(enabled = TRUE)
    
  })
  
  output$nz_ts <- renderHighchart({
    df_nzmoh_all %>% group_by(`Report Date`, type) %>% 
      summarise(count = n()) %>% 
      mutate(date = as.Date(`Report Date`)) %>% 
      hchart(type = "line", hcaes(x = date, y = count, group = type)) %>% 
      hc_title(text = "Time Series (New Zealand DHB)") %>% 
      hc_xAxis(title = "") %>% 
      hc_yAxis(title = list(text = "no. of cases")) %>% 
      hc_exporting(enabled = TRUE, filename = "time_series_nz")
  })
  
  # output$nzmap <- renderLeaflet({
  #   leaflet(nz_dhb) %>%
  #     addProviderTiles("Esri.WorldStreetMap") %>% 
  #     addPolygons(weight = 1, fillColor = ~pal(confirmed_cases),fillOpacity = 0.4,
  #                 label = lapply(labs, htmltools::HTML),
  #                 highlightOptions = highlightOptions(weight = 0.05, color = "#FAFAFA", bringToFront = TRUE)) %>% 
  #     setView(lat = -41.2865, lng = 174.7762, zoom = 5) %>% 
  #     addLegend(pal = pal, values = ~confirmed_cases, opacity = 0.7, title = NULL, position = "bottomright")
  # })
  
  output$nzdhb_column <- renderHighchart({
    df_nzmoh_all %>% group_by(DHB, type) %>% summarise(count = n()) %>% arrange(desc(count)) %>% 
      hchart(type = "column", hcaes(x = DHB, y = count, group = type)) %>% 
      hc_title(text = "Ranking Cases by DHB") %>% 
      hc_xAxis(title = "") %>% 
      hc_yAxis(title = list(text = "no. of cases")) %>% 
      hc_exporting(enabled = TRUE, filename = "column_dhb_nz")
  })
  
  output$nzgender_pie <- renderHighchart({
    highchart() %>% 
      hc_chart(type = "pie") %>% 
      hc_add_series_labels_values(labels = df_nzgender$Sex, 
                                  values = df_nzgender$count, 
                                  name = "no. of total cases",
                                  dataLabels = list(enabled = TRUE,
                                                    format = '{point.name}: {point.percentage:.1f} %')) %>% 
      hc_title(text = "Gender (Total Cases)") %>% 
      hc_exporting(enabled = TRUE, filename = "gender_pie_nz")
  })
}




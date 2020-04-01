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
  
  output$time_series_total <- renderHighchart({
    df_world %>% filter(location != "World", location != "International") %>% 
      group_by(date) %>% summarise(total_cases = sum(total_cases)) %>% 
      hchart(type = "line", hcaes(x = date, y = total_cases), name = "no. of cases") %>%
      hc_title(text = "Total Cases (World) OVer Time") %>% 
      hc_xAxis(title = list(text = "Date")) %>% 
      hc_yAxis(title = list(text = "total cases")) %>% 
      hc_exporting(enabled = TRUE, filename = "time_series_total")
  })
  
  output$time_series__total_log <- renderHighchart({
    df_world %>% filter(location != "World", location != "International") %>% 
      group_by(date) %>% summarise(total_cases = sum(total_cases)) %>% 
      mutate(total_cases_log = log(total_cases)) %>% 
      hchart(type = "line", hcaes(x = date, y = total_cases_log), name = "no. of cases",
             tooltip = list(pointFormat = "no. of cases: {point.total_cases}")) %>%
      hc_title(text = "Total Cases (World & Logarithm) OVer Time") %>% 
      hc_xAxis(title = list(text = "Date")) %>% 
      hc_yAxis(title = list(text = "total cases"), labels = list(formatter = JS("function () {
        return Math.round(Math.exp(this.axis.defaultLabelFormatter.call(this)));
    }"))) %>% 
      hc_exporting(enabled = TRUE, filename = "time_series_total")
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
  
  output$time_series_log <- renderHighchart({
    df_world %>% 
      filter(location %in% c(df_world_latest_top20$location, "New Zealand")) %>% 
      mutate(total_cases_log = log(total_cases)) %>% 
      hchart(type = "line", hcaes(x = date, y = total_cases_log, group = location),
             tooltip = list(pointFormat = "{point.location}: {point.total_cases}")) %>%
      hc_title(text = "Time Series (Logarithm) per Country (Top 20 + New Zealand)") %>% 
      hc_xAxis(title = "") %>% 
      hc_yAxis(title = list(text = "total cases"), labels = list(formatter = JS("function () {
        return Math.round(Math.exp(this.axis.defaultLabelFormatter.call(this)));
    }"))) %>% 
      hc_exporting(enabled = TRUE, filename = "time_series20_log")
  })
  
  output$trend_comparing <- renderHighchart({
    world_trend %>%  
      hchart(type = "line", hcaes(x = stamp, y = total_cases, group = location)) %>% 
      hc_title(text = "Trend Comparing Over Time (Top 20 + New Zealand)") %>% 
      hc_xAxis(title = "") %>% 
      hc_yAxis(title = list(text = "total cases")) %>% 
      hc_exporting(enabled = TRUE, filename = "trend_series20")
  })
  
  output$trend_comparing_log <- renderHighchart({
    world_trend %>%  
      mutate(total_cases_log = log(total_cases)) %>% 
      hchart(type = "line", hcaes(x = stamp, y = total_cases_log, group = location),
             tooltip = list(pointFormat = "{point.location}: {point.total_cases}")) %>% 
      hc_title(text = "Trend (Logarithm) Comparing Over Time (Top 20 + New Zealand)") %>% 
      hc_xAxis(title = "") %>% 
      hc_yAxis(title = list(text = "total cases"), labels = list(formatter = JS("function () {
        return Math.round(Math.exp(this.axis.defaultLabelFormatter.call(this)));
    }"))) %>% 
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
    df_transit %>% hchart(type = "column", hcaes(x = date, y = no_countries), name = "number of countries",
                          dataLabels = list(enabled = TRUE)) %>% 
      hc_title(text = "No. of Countries Hitted by Covid-19") %>% 
      hc_xAxis(title = "") %>% 
      hc_yAxis(title = list(text = "no. of countries")) %>% 
      hc_exporting(enabled = TRUE, filename = "no_countries")
  })
  
  output$total_cases_ranking <- renderHighchart({
    
    df_world_latest %>% filter(location != "World", location != "International") %>%
      arrange(desc(total_cases)) %>%
      slice(1:20) %>% 
      hchart(type = "bar", hcaes(x = location, y = total_cases), name = "total cases", color = "red",
             dataLabels = list(enabled = TRUE)) %>% 
      hc_title(text = "Total Cases per Country (Top 20)") %>% 
      hc_yAxis(title = list(text = "no. of cases")) %>% 
      hc_xAxis(title = "") %>% 
      hc_exporting(enabled = TRUE, filename = "total_cases20")
  })
  
  output$total_deaths_ranking <- renderHighchart({
    
    df_world_latest %>% filter(location != "World", location != "International") %>%
      arrange(desc(total_deaths)) %>%
      slice(1:20) %>% 
      hchart(type = "bar", hcaes(x = location, y = total_deaths), name = "total deaths", color = "grey",
             dataLabels = list(enabled = TRUE)) %>% 
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
             dataLabels = list(enabled = TRUE, format = "{point.death_rate}%"),
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
  
  output$nz_current <- DT::renderDataTable({
    nz_current$`New in last 24 hours` <- as.numeric(nz_current$`New in last 24 hours`)
    datatable(nz_current, rownames = FALSE, width = 700)
  })
  
  output$nz_total <- renderHighchart({
    df_nzmoh_all %>% group_by(`Date of report`) %>% 
      summarise(count = n()) %>% 
      mutate(date = as.Date(`Date of report`, "%d/%m/%Y")) %>% 
      arrange(date) %>%
      mutate(total = cumsum(count)) %>% 
      hchart(type = "line", hcaes(x = date, y = total), dataLabels = list(enabled = TRUE)) %>% 
      hc_title(text = "Time Series Total Cases (New Zealand)") %>% 
      hc_xAxis(title = "") %>% 
      hc_yAxis(title = list(text = "no. of cases")) %>% 
      hc_exporting(enabled = TRUE, filename = "time_series_nz")
  })
  
  output$nz_total_log <- renderHighchart({
    df_nzmoh_all %>% group_by(`Date of report`) %>% 
      summarise(count = n()) %>% 
      mutate(date = as.Date(`Date of report`, "%d/%m/%Y")) %>% 
      arrange(date) %>%
      mutate(total = cumsum(count)) %>% 
      mutate(total_log = log(total)) %>% 
      hchart(type = "line", hcaes(x = date, y = total_log), dataLabels = list(enabled = TRUE, format = "{point.total}"),
             tooltip = list(pointFormat = "no. of cases: {point.total}")) %>% 
      hc_title(text = "Time Series (Logarithm) Total Cases (New Zealand)") %>% 
      hc_xAxis(title = "") %>% 
      hc_yAxis(title = list(text = "total cases"), labels = list(formatter = JS("function () {
        return Math.round(Math.exp(this.axis.defaultLabelFormatter.call(this)));
    }"))) %>% 
      hc_exporting(enabled = TRUE, filename = "trend_series20")
  })
  
  output$nz_ts <- renderHighchart({
    df_nzmoh_all %>% group_by(`Date of report`, type) %>% 
      summarise(count = n()) %>% 
      mutate(date = as.Date(`Date of report`, "%d/%m/%Y")) %>% 
      arrange(desc(date), type) %>%
      hchart(type = "line", hcaes(x = date, y = count, group = type), dataLabels = list(enabled = TRUE)) %>% 
      hc_title(text = "Time Series (New Zealand)") %>% 
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
      hchart(type = "column", hcaes(x = DHB, y = count, group = type), dataLabels = list(enabled = TRUE)) %>% 
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
      hc_plotOptions(pie = list(size = 250)) %>% 
      hc_title(text = "Gender (Total Cases)") %>% 
      hc_exporting(enabled = TRUE, filename = "gender_pie_nz")
  })
  
  output$nz_ethnicty_pie <- renderHighchart({
    highchart() %>% 
      hc_chart(type = "pie") %>% 
      hc_add_series_labels_values(labels = nz_ethnicity$Ethnicity, 
                                  values = nz_ethnicity$`No. of cases`, 
                                  name = "no. of cases",
                                  dataLabels = list(enabled = TRUE,
                                                    format = '{point.name}: {point.percentage:.1f} %')) %>%
      hc_plotOptions(pie = list(size = 250)) %>% 
      hc_title(text = "Ethnicity (Total Cases)") %>% 
      hc_exporting(enabled = TRUE, filename = "ethnicity_pie_nz")
  })
  
  output$nz_age_column <- renderHighchart({
    df_nzmoh_all %>% group_by(`Age group`) %>% summarise(count = n()) %>%
      mutate(`Age group` = factor(`Age group`, levels = c("< 1", "1 to 4", "5 to 9", "10 to 14", "15 to 19", "20 to 29", "30 to 39", "40 to 49", "50 to 59", "60 to 69", "70+", "Unknown"))) %>% 
      arrange(`Age group`, .by_group = TRUE) %>% 
      hchart(type = "column", hcaes(x = `Age group`, y = count), color = "orange", dataLabels = list(enabled = TRUE)) %>% 
      hc_title(text = "Age Group (Total Cases)") %>% 
      hc_xAxis(title = "") %>% 
      hc_yAxis(title = list(text = "no. of cases")) %>% 
      hc_exporting(enabled = TRUE, filename = "column_age_nz")
  })
  
  output$nz_oversea <- renderHighchart({
    df_plot <- df_nzmoh_all %>% group_by(`International travel`) %>% summarise(count = n()) %>% arrange(desc(count))
    df_plot$`International travel`[which(df_plot$`International travel` == "")] <- "NA"
    df_plot %>% 
      hchart(type = "bar", hcaes(x = `International travel`, y = count), name = "no. of cases", color = "skyblue", 
             dataLabels = list(enabled = TRUE)) %>% 
      hc_title(text = "International Travel (Total Cases)") %>% 
      hc_xAxis(title = "") %>% 
      hc_yAxis(title = list(text = "no. of cases")) %>% 
      hc_exporting(enabled = TRUE, filename = "overseas_nz")
  })
  
  output$nz_travel_routes <- renderHighchart({
    hcmap(map = "custom/world", showInLegend = FALSE, data = global_latest, value = "total_cases",
          joinBy = "iso-a3", name = "local situation",
          borderColor = "#FAFAFA", borderWidth = 0.1) %>% 
      hc_add_series(data = df_flight, type = "mapbubble", name = "Cases travel to NZ from", maxSize = '10%', color = "red",
                    dataLabels = list(enabled = TRUE, format = '{point.name}', color = "black")) %>% 
      #hc_add_series(data = air_lines, type = "mapline", name = "flight route") %>% 
      hc_title(text = "Oversea cases to New Zealand") %>% 
      hc_exporting(enabled = TRUE, filename = "travel_map") %>% 
      hc_mapNavigation(enabled = TRUE)
    
  })
  
  
  # Data Page
  
  output$world_data_ecdc <- DT::renderDataTable({
    datatable(df_world)
  }) 
  
  output$world_data_john <- DT::renderDataTable({
    datatable(global_today)
  })
  
  output$nz_data <- DT::renderDataTable({
    datatable(df_nzmoh_all, options = list(pageLength = 25))
  })
}




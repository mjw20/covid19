# This is the file gathering data for the covid 19 dashboard
# 2020-03-27
# MJW


# World Data from https://ourworldindata.org/coronavirus-source-data
# and it is originally from European CDC

df_world <- read_csv("https://covid.ourworldindata.org/data/ecdc/full_data.csv")

df_world_latest <- df_world %>% 
  group_by(location) %>% 
  summarise(total_cases = max(total_cases),
            total_deaths = max(total_deaths))

df_world_latest$`iso-a3` <- countrycode(df_world_latest$location, origin = 'country.name', destination = 'iso3c')
df_world_latest$`iso-a2` <- countrycode(df_world_latest$location, origin = 'country.name', destination = 'iso2c')


df_world_latest_top20 <- df_world_latest %>% 
  filter(location != "World", location != "International") %>%
  arrange(desc(total_deaths)) %>%
  slice(1:20)



# New Zealand data is from Ministry of Health, public data
moh_url <- "https://www.health.govt.nz/our-work/diseases-and-conditions/covid-19-novel-coronavirus/covid-19-current-situation/covid-19-current-cases/covid-19-current-cases-details"
moh_webpage <- read_html(moh_url)
df_nzmoh <- html_table(moh_webpage)[[1]]
df_nzmoh$DHB <- str_replace_all(df_nzmoh$DHB, "&", "and")


# world map data from highcharter
world_mapdata <- get_data_from_map(download_map_data("custom/world"))

# nz map from leaflet and stats nz shapfile

nz_dhb <- readOGR(dsn = "./data/dhb_shapefile", layer = "district-health-board-2015")

temp_df <- nz_dhb@data

temp_df <- 
  temp_df %>% left_join(
    df_nzmoh %>% group_by(DHB) %>%
      summarise(total_cases = n()), by = c("DHB2015_Na" = "DHB")
  )

temp_df[is.na(temp_df)] <- 0

nz_dhb$confirmed_cases <- temp_df$total_cases

nz_dhb <- nz_dhb[nz_dhb$DHB2015_Na != "Area outside District Health Board", ]
quant_df <- as.numeric(quantile(nz_dhb@data$confirmed_cases))
pal <- colorBin("RdYlGn", domain = nz_dhb@data$confirmed_cases, bins = quant_df, reverse = TRUE)
labs <- lapply(seq(nrow(nz_dhb@data)), function(i) {
  paste0( 'DHB: ', nz_dhb@data[i, "DHB2015_Na"], '<br>', 
          "Confirmed Cases: ", nz_dhb@data[i, "confirmed_cases"]) 
})


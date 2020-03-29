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
  arrange(desc(total_cases)) %>%
  slice(1:20)

world_trend <- lapply(c(df_world_latest_top20$location, "New Zealand"), FUN = df_transform_20)
world_trend <- do.call(rbind, world_trend)

world_info_display <- df_world %>% filter(location == "World", date == max(date))


# Another set of world data to compare:
# https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series

global_comfirmed <- read_csv("https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv")
global_deaths <- read_csv("https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")
global_recovered <- read_csv("https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv")

names(global_comfirmed)[ncol(global_comfirmed)] <- "today"
names(global_comfirmed)[ncol(global_comfirmed)-1] <- "yesterday"
names(global_deaths)[ncol(global_deaths)] <- "today"
names(global_recovered)[ncol(global_recovered)] <- "today"

global_comfirmed_today <- global_comfirmed %>% 
  group_by(`Country/Region`) %>% 
  summarise(total_cases = sum(today),
            new_cases = sum(today) - sum(yesterday))

global_deaths_today <- global_deaths %>% 
  group_by(`Country/Region`) %>% 
  summarise(total_deaths = sum(today))

global_recovered_today <- global_recovered %>% 
  group_by(`Country/Region`) %>% 
  summarise(total_recovered = sum(today))

global_today <- global_comfirmed_today %>% left_join(global_deaths_today, by = "Country/Region") %>% 
  left_join(global_recovered_today, by = "Country/Region")

global_today$`iso-a3` <- countrycode(global_today$`Country/Region`, origin = 'country.name', destination = 'iso3c')
global_today$`iso-a2` <- countrycode(global_today$`Country/Region`, origin = 'country.name', destination = 'iso2c')

# New Zealand data is from Ministry of Health, public data
moh_url <- "https://www.health.govt.nz/system/files/documents/pages/covid-19-confirmed-probable-cases-29mar20.xlsx"
# moh_webpage <- read_html(moh_url)
# df_nzmoh <- html_table(moh_webpage)[[1]]
GET(moh_url, write_disk(tf <- tempfile(fileext = ".xlsx")))
df_nzmoh <- read_excel(tf, sheet="Confirmed")
df_nzmoh$DHB <- str_replace_all(df_nzmoh$DHB, "&", "and")

df_nzmoh_probable <- read_excel(tf, sheet="Probable")

# world map data from highcharter
world_mapdata <- get_data_from_map(download_map_data("custom/world"))

# nzmap

Myhcmap <- jsonlite::fromJSON("./data/nzdhb.geojson", simplifyVector = F)


# nz map from leaflet and stats nz shapfile

# nz_dhb <- readOGR(dsn = "./data/dhb_shapefile", layer = "district-health-board-2015")
# 
# temp_df <- nz_dhb@data
# 
# temp_df <- 
#   temp_df %>% left_join(
#     df_nzmoh %>% group_by(DHB) %>%
#       summarise(total_cases = n()), by = c("DHB2015_Na" = "DHB")
#   )
# 
# temp_df[is.na(temp_df)] <- 0
# 
# nz_dhb$confirmed_cases <- temp_df$total_cases
# 
# nz_dhb <- nz_dhb[nz_dhb$DHB2015_Na != "Area outside District Health Board", ]
# quant_df <- as.numeric(quantile(nz_dhb@data$confirmed_cases))
# pal <- colorBin("RdYlGn", domain = nz_dhb@data$confirmed_cases, bins = quant_df, reverse = TRUE)
# labs <- lapply(seq(nrow(nz_dhb@data)), function(i) {
#   paste0( 'DHB: ', nz_dhb@data[i, "DHB2015_Na"], '<br>', 
#           "Confirmed Cases: ", nz_dhb@data[i, "confirmed_cases"]) 
# })


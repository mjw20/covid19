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

# New Zealand data is from Ministry of Health, public data
moh_url <- "https://www.health.govt.nz/our-work/diseases-and-conditions/covid-19-novel-coronavirus/covid-19-current-situation/covid-19-current-cases/covid-19-current-cases-details"
moh_webpage <- read_html(moh_url)
df_nzmoh <- html_table(moh_webpage)[[1]]


# world map data from highcharter
world_mapdata <- get_data_from_map(download_map_data("custom/world"))

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

global_latest <- full_join(na.omit(global_today), na.omit(df_world_latest), by = "iso-a3")
names(global_latest)[1] <- "country"

global_latest <- global_latest %>% group_by(`iso-a3`) %>% 
  mutate(
    total_cases = max(total_cases.x, total_cases.y, na.rm = TRUE),
    total_deaths = max(total_deaths.x, total_deaths.y, na.rm = TRUE)
  )

global_latest$location[which(is.na(global_latest$location))] <- global_latest$country[which(is.na(global_latest$location))]

# New Zealand data is from Ministry of Health, public data

# url <- "https://www.health.govt.nz/our-work/diseases-and-conditions/covid-19-novel-coronavirus/covid-19-current-situation/covid-19-current-cases/covid-19-current-cases-details"
# html <- paste(readLines(url), collapse="\n")
# matched <- str_match_all(html, "<a href=\"(.*?)\"") %>% as.data.frame()
# nzdf_path <- as.character(matched$X2[grep("/system/files/documents/pages/", matched$X2)])
# moh_url <- paste0("https://www.health.govt.nz", nzdf_path)
moh_url <- "https://www.health.govt.nz/our-work/diseases-and-conditions/covid-19-novel-coronavirus/covid-19-current-situation/covid-19-current-cases/covid-19-current-cases-details"
moh_webpage <- read_html(moh_url)
df_nzmoh <- html_table(moh_webpage)[[1]]
# GET(moh_url, write_disk(tf <- tempfile(fileext = ".xlsx")))
# df_nzmoh <- read_excel(tf, sheet = 1, skip = 3)
df_nzmoh$DHB <- str_replace_all(df_nzmoh$DHB, "&", "and")

#df_nzmoh_probable <- read_excel(tf, sheet= 2, skip = 3)
df_nzmoh_probable <- html_table(moh_webpage)[[2]]
df_nzmoh$type = "confirmed"
df_nzmoh_probable$type = "probable"

names(df_nzmoh_probable) <- names(df_nzmoh)

df_nzmoh_all = rbind(df_nzmoh, df_nzmoh_probable)

# somehow there is one observation that is "60 to 69" and after group_by it gives two 60 to 69!!!

df_nzmoh_all$`Age group`[grep("6", df_nzmoh_all$`Age group`)] <- "60 to 69"

df_nzgender <- df_nzmoh_all %>% group_by(Sex) %>% summarise(count = n())
df_nzgender$Sex[which(df_nzgender$Sex == "")] <- "NA"


moh_url2 <- "https://www.health.govt.nz/our-work/diseases-and-conditions/covid-19-novel-coronavirus/covid-19-current-situation/covid-19-current-cases"
moh_webpage2 <- read_html(moh_url2)

nz_current <- html_table(moh_webpage2)[[1]]
nz_ethnicity <- html_table(moh_webpage2)[[3]]
#nz_travel <- html_table((moh_webpage2))[[4]]

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

### Constructing Flight Routes
country_gis_url <- "https://developers.google.com/public-data/docs/canonical/countries_csv"
country_gis_web <- read_html(country_gis_url)
country_gis <- html_table(country_gis_web)[[1]]

df_flight_nz <-  df_nzmoh_all %>% filter(`Last country before return` != "") %>% 
  group_by(`Last country before return`) %>% summarise(count = n()) %>% ungroup()

df_flight_nz$`Last country before return`[which(df_flight_nz$`Last country before return` == "England")] <- "United Kingdom"
df_flight_nz$`Last country before return`[which(df_flight_nz$`Last country before return` == "Scotland")] <- "United Kingdom"

df_flight_nz <- df_flight_nz %>% group_by(`Last country before return`) %>% summarise(count = sum(count))

df_flight_nz$`iso-a2` <- countrycode(df_flight_nz$`Last country before return`, origin = 'country.name', destination = 'iso2c')

df_flight_nz <- df_flight_nz %>% left_join(country_gis, by = c("iso-a2" = "country"))

df_flight_nz <- na.omit(df_flight_nz)

df_flight <- data.frame(name = df_flight_nz$`Last country before return`,
                        lat = df_flight_nz$latitude,
                        lon = df_flight_nz$longitude,
                        z = df_flight_nz$count)

df_flight2 <- data.frame(id = df_flight$name,
                         lat = df_flight$lat,
                         lon = df_flight$lon)
# # pre-construct the map
# map_world <- hcmap(map = "custom/world", showInLegend = FALSE)
# 
# # extract the transformation-info
# trafo <- map_world$x$hc_opts$series[[1]]$mapData$`hc-transform`$default
# 
# # convert to coordinates
# flight_coordinates <- df_flight %>% select("lat", "lon")
# coordinates(flight_coordinates) <- c("lon", "lat")
# 
# # convert world geosystem WGS 84 into transformed crs
# proj4string(flight_coordinates) <- CRS("+init=epsg:4326") # WGS 84
# flight_coordinates2 <- spTransform(flight_coordinates, CRS(trafo$crs)) # 
# 
# # re-transform coordinates according to the additionnal highcharts-parameters
# image_coords_x <- (flight_coordinates2$lon - trafo$xoffset) * trafo$scale * trafo$jsonres + trafo$jsonmarginX
# image_coords_y <- -((flight_coordinates2$lat - trafo$yoffset) * trafo$scale * trafo$jsonres + trafo$jsonmarginY)
# 
# # construct the path
# path <- paste("M", sapply(1:nrow(df_flight), path_function), sep = "")
# # information for drawing the beeline
# air_lines <- data.frame(
#   name = "line",
#   path = path, 
#   lineWidth = 2
# )

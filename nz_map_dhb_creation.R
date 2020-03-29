# Create GeoJSON out of NZ DHB shapefile in R

library(rgdal)
library(geojsonio)
library(spdplyr)
library(rmapshaper)
# Import Shapefile into R.
dhb_nzdf <- readOGR(dsn = "./data/dhb_shapefile", 
                  layer = "district-health-board-2015", verbose = FALSE)

dhb_nzdf <- dhb_nzdf[dhb_nzdf$DHB2015_Na != "Area outside District Health Board", ]

# Convert SP Data Frame to GeoJSON.
dhb_nzdf_json <- geojson_json(dhb_nzdf)
# Simplify the geometry information of GeoJSON.
dhb_nzdf_json_sim <- ms_simplify(dhb_nzdf_json)
# Keep only the polygons inside the bbox (boundary box).
dhb_nzdf_clipped <- ms_clip(dhb_nzdf_json_sim, bbox = c(165, -50, 180, -30))
# Save it to a local file system.
geojson_write(dhb_nzdf_clipped, file = "./data/nzdhb.geojson")


#Use geojsonio to make data compatible with hcmap
Myhcmap <- jsonlite::fromJSON("./data/nzdhb.geojson", simplifyVector = F)
Myhcmap<- geojsonio::as.json(Myhcmap, keep_vec_names = TRUE)

#Draw map:

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

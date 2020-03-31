# This is the file contains all the packages for the covid 19 dashboard
# 2020-03-27
# MJW

lib_list <- c("tidyverse",
              "rgdal",
              "rvest",
              "xml2",
              "highcharter",
              "shiny",
              "shinydashboard",
              "shinythemes",
              "shinyWidgets",
              "readxl",
              "httr",
              "countrycode",
              "rsconnect",
              "leaflet",
              "rgdal",
              "DT")


packages_info <- sapply(lib_list, function(x) {
  if (!(x %in% installed.packages())) {
    install.packages(x)
  }
  library(x, character.only = TRUE)
})

# library(tidyverse)
# library(rgdal)
# library(rvest)
# library(xml2)
# library(highcharter)
# library(shiny)
# library(shinydashboard)
# library(shinythemes)
# library(shinyWidgets)
# library(readxl)
# library(httr)
# library(countrycode)
# library(rsconnect)
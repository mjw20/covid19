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
              "countrycode")


packages_info <- sapply(lib_list, function(x) {
  if (!(x %in% installed.packages())) {
    install.packages(x)
  }
  library(x, character.only = TRUE)
})

# This is the master file for the covid 19 dashboard
# 2020-03-27
# MJW

library(tidyverse)
library(rgdal)
library(rvest)
library(xml2)
library(highcharter)
library(shiny)
library(shinydashboard)
library(shinythemes)
library(shinyWidgets)
library(readxl)
library(httr)
library(countrycode)
library(rsconnect)
#library(leaflet)
library(rgdal)
library(jsonlite)
library(DT)
library(stringr)

# to deploy the dashboard, one cannot use the pacakges.R to get all the libraries
# source("packages.R")
source("./function.R")
source('./data_processing.R')
source('./ui.R')
source('./server.R')


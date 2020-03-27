# This is the file gathering data for the covid 19 dashboard
# 2020-03-27
# MJW


# World Data from https://ourworldindata.org/coronavirus-source-data
# and it is originally from European CDC

df_world <- read_csv("https://covid.ourworldindata.org/data/ecdc/full_data.csv")

# New Zealand data is from Ministry of Health, public data
moh_url <- "https://www.health.govt.nz/our-work/diseases-and-conditions/covid-19-novel-coronavirus/covid-19-current-situation/covid-19-current-cases/covid-19-current-cases-details"
moh_webpage <- read_html(moh_url)
df_nzmoh <- html_table(moh_webpage)[[1]]

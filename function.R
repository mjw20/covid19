# Compare top 20 + nz trend from day 1

df_transform_20 <- function(country){
  df_transform <- df_world %>% filter(location == country, total_cases > 0)
  df_transform$stamp <- 1:nrow(df_transform)
  df_transform$stamp <- paste("Day", df_transform$stamp)
  return(df_transform)
}

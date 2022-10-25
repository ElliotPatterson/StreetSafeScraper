library(tidycensus)
library(sf)
source("/Users/elliotpatterson/Documents/census_key.R")

load_variables(2020, "acs5")
nc_counties = tidycensus::get_acs(geography = "county", state = "NC", variables = "B19013_001E", geometry = T)

nc_counties %>% st_geometry() %>% plot

nc_counties %>% st_write("outputs/nc_counties.shp", delete_layer=T)
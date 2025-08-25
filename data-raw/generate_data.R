library(tidyverse)
library(dm)
library(sf)

sf::sf_use_s2(FALSE)

# Loading up to date tables
inv_tbl <- read_csv("../ENI_Listing/EML/data_objects/inv_tbl.csv")
taxo_tbl <- read_csv("../ENI_Listing/EML/data_objects/taxo_tbl.csv")
meow_tbl <- read_csv("../ENI_Listing/EML/data_objects/meow_tbl.csv")
origin_tbl <- read_csv("../ENI_Listing/EML/data_objects/origin_tbl.csv")

dm_data <- readRDS("../ENI_Listing/00-Data/02-Clean/NIS_Europe_RDBM.rds")

# Creating sf df

land <- rnaturalearth::ne_countries(scale = "large", returnclass = "sf")

bbox <- sf::st_as_sfc(sf::st_bbox(land)) # boîte englobante
ocean <- sf::st_difference(bbox, sf::st_union(land))

meow_eco <- meow_tbl %>%
  sf::st_as_sf(wkt = "WKT", crs = "WGS84") %>%
  sf::st_intersection(ocean) %>%
  dplyr::mutate(WKT = if_else(
    st_geometry_type(WKT) == "GEOMETRYCOLLECTION",
    st_collection_extract(WKT),
    WKT
    )
  )

meow_prov <- meow_eco %>%
  mutate(WKT = st_make_valid(WKT)) %>%
  group_by(PROVINCE) %>%
  reframe(REALM, RLM_CODE, PROVINCE, PROV_CODE, geometry = st_union(WKT)) %>%
  ungroup() %>%
  distinct(PROV_CODE, .keep_all = TRUE) %>%
  relocate(REALM, RLM_CODE, PROVINCE, PROV_CODE)

meow_rlm <- meow_eco %>%
  mutate(WKT = st_make_valid(WKT)) %>%
  group_by(REALM) %>%
  reframe(REALM, RLM_CODE, geometry = st_union(WKT)) %>%
  ungroup() %>%
  distinct(REALM, .keep_all = TRUE) %>%
  relocate(REALM, RLM_CODE)

# Saving the datasets

save(dm_data, meow_eco, meow_prov, meow_rlm, file = "inst/app/data/shiny_app_data.rda")

# Cleanning some names

meow <- meow_eco %>%
  select(-ALT_CODE) # Remove this useless column

# Exporting the datasets

usethis::use_data(inv_tbl, taxo_tbl, origin_tbl, meow, overwrite = TRUE)

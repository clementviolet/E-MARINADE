library(tidyverse)
library(sf)

sf::sf_use_s2(FALSE)

# Loading up to date tables
introduction <- read_csv("../ANIS-E_update/00-data/02-releases/v1.0.1/introduction.csv")
pathway <- read_csv("../ANIS-E_update/00-data/02-releases/v1.0.1/pathway.csv")
taxonomy <- read_csv("../ANIS-E_update/00-data/02-releases/v1.0.1/taxonomy.csv")
taxonomy_identifiers <- read_csv("../ANIS-E_update/00-data/02-releases/v1.0.1/taxonomy_identifiers.csv")
meow_tbl <- read_csv("../ANIS-E_update/00-data/02-releases/v1.0.1/meow.csv")
origin <- read_csv("../ANIS-E_update/00-data/02-releases/v1.0.1/origin.csv")

# Creating sf df

land <- rnaturalearth::ne_countries(scale = "large", returnclass = "sf")

bbox <- sf::st_as_sfc(sf::st_bbox(land)) # boîte englobante
ocean <- sf::st_difference(bbox, sf::st_union(land))

meow <- meow_tbl %>%
  sf::st_as_sf(wkt = "WKT", crs = "WGS84") %>%
  sf::st_intersection(ocean) %>%
  dplyr::mutate(WKT = if_else(
    st_geometry_type(WKT) == "GEOMETRYCOLLECTION",
    st_collection_extract(WKT),
    WKT
    )
  )

meow_prov <- meow %>%
  mutate(WKT = st_make_valid(WKT)) %>%
  group_by(PROVINCE) %>%
  reframe(REALM, RLM_CODE, PROVINCE, PROV_CODE, geometry = st_union(WKT)) %>%
  ungroup() %>%
  distinct(PROV_CODE, .keep_all = TRUE) %>%
  relocate(REALM, RLM_CODE, PROVINCE, PROV_CODE)

meow_rlm <- meow %>%
  mutate(WKT = st_make_valid(WKT)) %>%
  group_by(REALM) %>%
  reframe(REALM, RLM_CODE, geometry = st_union(WKT)) %>%
  ungroup() %>%
  distinct(REALM, .keep_all = TRUE) %>%
  relocate(REALM, RLM_CODE)

# Saving the datasets

save(
  introduction, pathway, taxonomy,
  taxonomy_identifiers, origin,
  meow, meow_prov, meow_rlm,
  file = "inst/app/data/shiny_app_data.rda"
)

# Exporting the datasets

usethis::use_data(
  introduction, pathway,
  taxonomy, taxonomy_identifiers,
  origin, meow, overwrite = TRUE
  )

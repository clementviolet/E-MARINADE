library(tidyverse)
library(dm)
library(sf)

sf_use_s2(FALSE)

splitting_polygon <- function(x){

  out <- x %>%
    group_split(ECO_CODE_X) %>%
    map(function(x){

      if(st_geometry_type(x) == "GEOMETRYCOLLECTION"){

        x <- x %>%
          st_collection_extract("POLYGON")
      }

      out <- st_cast(x, "POLYGON", warn = FALSE) %>%
        mutate(geometry = st_as_text(WKT)) %>%
        select(-WKT)

    }) %>%
    list_rbind()

  return(out)
}

dm_data <- readRDS("Data/NIS_Europe_RDBM.rds")

meow <- dm_data[["meow_tbl"]] %>%
  st_as_sf(wkt = "WKT", crs = 4326)

land <- rnaturalearth::ne_countries(scale = "large", returnclass = "sf") %>%
  st_make_valid() %>%
  {suppressMessages({st_union(.)})}


suppressMessages({
  
  suppressWarnings({
    
    meow_eco <- st_difference(meow, land) %>%
      splitting_polygon() %>%
      select(-WKT) %>%
      st_as_sf(wkt = "geometry", crs = 4326) %>%
      group_by(
        REALM, RLM_CODE, 
        PROVINCE, PROV_CODE, 
        ECOREGION, ECO_CODE,
        ECO_CODE_X
      ) %>%
      summarise(geometry = st_union(geometry), .groups = "drop") %>%
      arrange(RLM_CODE, PROV_CODE, ECO_CODE_X)
    
  })
  
})


suppressMessages({
  
  suppressWarnings({
    
    meow_prov <- meow %>%
      group_by(
        REALM, RLM_CODE, 
        PROVINCE, PROV_CODE
      ) %>%
      summarise(geometry = st_union(WKT), .groups = "drop") %>%
      st_difference(land) %>%
      group_by(
        REALM, RLM_CODE, 
        PROVINCE, PROV_CODE
      ) %>%
      summarise(geometry = st_union(geometry), .groups = "drop") %>%
      arrange(RLM_CODE, PROV_CODE)
    
  })
  
})


suppressMessages({
  
  suppressWarnings({
    
    meow_rlm <- meow %>%
      group_by(RLM_CODE, REALM) %>%
      summarise(geometry = st_union(WKT), .groups = "drop") %>%
      st_difference(land) %>%
      group_by(RLM_CODE, REALM) %>%
      summarise(geometry = st_union(geometry), .groups = "drop") %>%
      arrange(RLM_CODE)
    
  })
  
})

save(meow_eco, meow_prov, meow_rlm, file = "data/meow.RData")
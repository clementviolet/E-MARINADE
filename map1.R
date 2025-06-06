library(tidyverse)
library(dm)
library(leaflet)
library(sf)

sf_use_s2(FALSE)

load("data/meow.RData")

dm_data <- readRDS("Data/NIS_Europe_RDBM.rds")

nis_origin_map <- function(x = "PROV"){
  
  metadata_meow <- meow_eco %>%
    st_drop_geometry() %>%
    select(ECO_CODE_X, ECOREGION:REALM) %>%
    distinct(ECO_CODE_X, .keep_all = TRUE)
  
  nb_origin_nis <- dm_data[["origin_tbl"]] %>%
    left_join(metadata_meow, by = "ECO_CODE_X")
  
  if(x == "ECO"){
    
    nb_origin_nis_ecoregion <- nb_origin_nis %>%
      count(ECO_CODE_X)
    
    data_plot <- meow_eco %>%
      left_join(nb_origin_nis_ecoregion, by = "ECO_CODE_X")
    
    pal <- colorNumeric("viridis", NULL)
    
    m <- leaflet(data_plot) %>%
      addTiles(options = tileOptions(
        minZoom = 2, maxZoom = 18,
        noWrap = TRUE
      )
      ) %>%
      addPolygons(
        color = "grey", weight = 1,
        fillOpacity = 1,
        fillColor = ~pal(log1p(n)),
        popup = glue::glue(
          "Ecoregion: {data_plot$ECOREGION}<br>",
          "NIS count (origin): {data_plot$n}<br>"
        ),
        label = glue::glue(
          "Ecoregion: {data_plot$ECOREGION} | ",
          "NIS count (origin): {data_plot$n}"
        ),
      ) %>%
      addLegend(
        pal = pal, values = ~log1p(n),
        title = "NIS Count (origin)",
        labFormat = labelFormat(transform = function(x) round(expm1(x))),
        opacity = 1
      ) %>%
      setMaxBounds(
        lng1 = -180, lat1 = -90,
        lng2 = 180, lat2 = 90
      ) %>%
      setView(lng = 0, lat = 0, zoom = 2)
    
    return(m)
    
  }else if(x == "PROV"){
    
    nb_origin_nis_prov <- nb_origin_nis %>%
      group_by(PROV_CODE) %>%
      distinct(SpeciesID, .keep_all = TRUE) %>%
      ungroup() %>%
      count(PROV_CODE)
    
    data_plot <- meow_prov %>%
      left_join(nb_origin_nis_prov, by = "PROV_CODE")
    
    pal <- colorNumeric("viridis", NULL)
    
    m <- leaflet(data_plot) %>%
      addTiles(options = tileOptions(
        minZoom = 2, maxZoom = 18,
        noWrap = TRUE
      )
      ) %>%
      addPolygons(
        color = "grey", weight = 1,
        fillOpacity = 1,
        fillColor = ~pal(log1p(n)),
        popup = glue::glue(
          "Province: {data_plot$PROVINCE}<br>",
          "NIS count (origin): {data_plot$n}<br>"
        ),
        label = glue::glue(
          "Province: {data_plot$PROVINCE} | ",
          "NIS count (origin): {data_plot$n}"
        ),
      ) %>%
      addLegend(
        pal = pal, values = ~log1p(n),
        title = "NIS Count (origin)",
        labFormat = labelFormat(transform = function(x) round(expm1(x))),
        opacity = 1
      ) %>%
      setMaxBounds(
        lng1 = -180, lat1 = -90,
        lng2 = 180, lat2 = 90
      ) %>%
      setView(lng = 0, lat = 0, zoom = 2)
    
    return(m)
    
  }else{
    
    nb_origin_nis_realm <- nb_origin_nis %>%
      group_by(REALM, RLM_CODE) %>%
      distinct(SpeciesID, .keep_all = TRUE) %>%
      ungroup() %>%
      count(RLM_CODE)
    
    data_plot <- meow_rlm %>%
      left_join(nb_origin_nis_realm, by = "RLM_CODE")
    
    pal <- colorNumeric("viridis", NULL)
    
    m <- leaflet(data_plot) %>%
      addTiles(options = tileOptions(
        minZoom = 2, maxZoom = 18,
        noWrap = TRUE
      )
      ) %>%
      addPolygons(
        color = "grey", weight = 1,
        fillOpacity = 1,
        fillColor = ~pal(log1p(n)),
        popup = glue::glue(
          "REALM: {data_plot$REALM}<br>",
          "NIS count (origin): {data_plot$n}<br>"
        ),
        label = glue::glue(
          "Realm: {data_plot$REALM} | ",
          "NIS count (origin): {data_plot$n}"
        ),
      ) %>%
      addLegend(
        pal = pal, values = ~log1p(n),
        title = "NIS Count (origin)",
        labFormat = labelFormat(transform = function(x) round(expm1(x))),
        opacity = 1
      ) %>%
      setMaxBounds(
        lng1 = -180, lat1 = -90,
        lng2 = 180, lat2 = 90
      ) %>%
      setView(lng = 0, lat = 0, zoom = 2)
    
    return(m)
    
  }
  
}

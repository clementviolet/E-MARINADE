meow_europe <- meow_eco %>%
  filter(ECO_CODE_X %in% c(2, 20:27, 29:36, 44)) %>%
  filter(!ECO_CODE_X %in% c(21, 23))

suppressMessages({
  
  europe_cent <- meow_europe %>%
    st_union() %>% 
    st_centroid() %>%
    st_coordinates()
  
})

invasion_eu_map <- function(year = 2023){
  
  nb_inv_ecoregion <- dm_data[["inv_tbl"]] %>%
    filter(is.na(Year) | Year <= year) %>%
    distinct(SpeciesID, Ecoregion_Code, .keep_all = TRUE) %>%
    count(Ecoregion_Code)
  
  data_plot <- meow_europe %>%
    left_join(nb_inv_ecoregion, by = c("ECO_CODE_X" = "Ecoregion_Code"))
  
  pal <- colorNumeric("viridis", NULL)
  
  m <- leaflet(data_plot) %>%
    addTiles(options = tileOptions(
      minZoom = 3, maxZoom = 18,
      noWrap = TRUE
    )
    ) %>%
    addPolygons(
      color = "grey", weight = 1,
      fillOpacity = 1,
      fillColor = ~pal(log1p(n)),
      popup = glue::glue(
        "Ecoregion: {data_plot$ECOREGION}<br>",
        "NIS count: {if_else(is.na(data_plot$n), 0, data_plot$n)}<br>"
      ),
      label = glue::glue(
        "Ecoregion: {data_plot$ECOREGION} | ",
        "NIS count: {if_else(is.na(data_plot$n), 0, data_plot$n)}"
      ),
    ) %>%
    addLegend(
      pal = pal, values = ~log1p(n),
      title = "NIS Count",
      labFormat = labelFormat(transform = function(x) round(expm1(x))),
      opacity = 1, na.label = "0"
    ) %>%
    setMaxBounds(
      lng1 = -30, lat1 = 20,
      lng2 = 45, lat2 = 85
    ) %>%
    setView(lng = europe_cent[1], lat = europe_cent[2], zoom = 3)
  
  return(m)
  
}
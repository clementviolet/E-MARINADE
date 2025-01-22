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
    left_join(nb_inv_ecoregion, by = c("ECO_CODE_X" = "Ecoregion_Code")) %>%
    replace_na(list(n = 0))
  
  pal <- colorBin("viridis", NULL, bins = seq(0, 800, 5))
  
  m <- leaflet(data_plot) %>%
    addTiles(options = tileOptions(
      minZoom = 3, maxZoom = 18,
      noWrap = TRUE
    )
    ) %>%
    addPolygons(
      color = "grey", weight = 1,
      fillOpacity = 1,
      fillColor = ~pal(n),
      popup = glue::glue(
        "Ecoregion: {data_plot$ECOREGION}<br>",
        "NIS count: {data_plot$n}<br>"
      ),
      label = glue::glue(
        "Ecoregion: {data_plot$ECOREGION} | ",
        "NIS count: {data_plot$n}"
      ),
    ) %>%
    addLegend(
      colors = pal(c(0, 100, 200, 300, 400, 500, 600, 700, 800)),
      labels = as.character(c(0, 100, 200, 300, 400, 500, 600, 700, 800)),
      title = "NIS Count",
      labFormat = labelFormat(transform = function(x) x),
      opacity = 1, na.label = "0"
    ) %>%
    setMaxBounds(
      lng1 = -30, lat1 = 20,
      lng2 = 45, lat2 = 85
    ) %>%
    setView(lng = europe_cent[1], lat = europe_cent[2], zoom = 3)
  
  return(m)
  
}

pal(c(0, 25, 50, 100, 150, 200, 300, 400, 600, 800))

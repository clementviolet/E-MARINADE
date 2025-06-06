meow_europe <- meow_eco %>%
  filter(ECO_CODE_X %in% c(2, 20:27, 29:36, 44))

suppressWarnings({
  
  europe_cent <- meow_europe %>%
    sf::st_union() %>% 
    sf::st_centroid() %>%
    sf::st_coordinates()
  
})

invasion_eu_map <- function(year = 2023){
  
  nb_inv_ecoregion <- dm_data$inv_tbl %>%
    filter(is.na(Year) | Year <= year) %>%
    dplyr::distinct(SpeciesID, Ecoregion_Code, .keep_all = TRUE) %>%
    dplyr::count(Ecoregion_Code)
  
  data_plot <- meow_europe %>%
    dplyr::left_join(nb_inv_ecoregion, by = c("ECO_CODE_X" = "Ecoregion_Code")) %>%
    tidyr::replace_na(list(n = 0)) %>%
    filter(n > 0)
  
  pal <- leaflet::colorBin("viridis", NULL, bins = seq(0, 600, 5))
  
  m <- leaflet::leaflet(data_plot) %>%
    leaflet::addTiles(options = leaflet::tileOptions(
      minZoom = 3, maxZoom = 18,
      noWrap = TRUE
    )
    ) %>%
    leaflet::addPolygons(
      color = "grey", weight = 1,
      fillOpacity = 1,
      fillColor = ~pal(n),
      popup = glue::glue(
        "Ecoregion: {data_plot$ECOREGION}<br>",
        "Unique NIS count: {data_plot$n}<br>"
      ),
      label = glue::glue(
        "Ecoregion: {data_plot$ECOREGION} | ",
        "Unique NIS count: {data_plot$n}"
      ),
      layerId = ~ECO_CODE_X
    ) %>%
    leaflet::addLegend(
      colors = pal(c(0, 100, 200, 300, 400, 500, 600)),
      labels = as.character(c(0, 100, 200, 300, 400, 500, 600)),
      title = "NIS Count",
      labFormat = leaflet::labelFormat(transform = function(x) x),
      opacity = 1, na.label = "0"
    ) %>%
    leaflet::setMaxBounds(
      lng1 = -30, lat1 = 20,
      lng2 = 45, lat2 = 85
    ) %>%
    leaflet::setView(lng = europe_cent[1], lat = europe_cent[2], zoom = 3)
  
  return(m)
  
}

invasion_eu_table <- function(ecoregion) {
  DT::renderDT({
    if (length(ecoregion()) == 0) {
      
      data <- dm_data$taxo_tbl %>% 
        dplyr::left_join(dm_data$inv_tbl, by = "SpeciesID") %>% 
        dplyr::left_join(
          meow_eco, c("Ecoregion_Code" = "ECO_CODE_X"), 
          relationship = "many-to-many"
        ) %>%
        dplyr::slice(0) # Make an empty table
      
    } else {
      
      data <- dm_data$taxo_tbl %>% 
        dplyr::left_join(dm_data$inv_tbl, by = "SpeciesID") %>% 
        filter(Ecoregion_Code %in% ecoregion()) %>%
        dplyr::arrange(Ecoregion_Code) %>%
        dplyr::left_join(
          meow_eco, c("Ecoregion_Code" = "ECO_CODE_X"), 
          relationship = "many-to-many"
        ) %>%
        dplyr::distinct(Species, Ecoregion_Code, .keep_all = TRUE)
    }
    
    DT::datatable(
      data = data %>%  dplyr::select(
        Kingdom:Species, AphiaID:ncbiID, 
        Year:MSFD_subregion, 
        REALM, RLM_CODE, 
        PROVINCE, PROV_CODE, 
        ECOREGION, ECO_CODE = Ecoregion_Code,
        Source, DB
      ),
      filter = "top", extensions = c("Buttons", "Scroller"), 
      options = list(
        dom = "Bfrtip", buttons = c("copy", "csv", "excel"),
        deferRender = TRUE, scrollY = 200, scrollX = 400, scroller = TRUE
      )
    )
  })
}
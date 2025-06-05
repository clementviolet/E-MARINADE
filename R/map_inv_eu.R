meow_europe <- meow_eco %>%
  filter(ECO_CODE_X %in% c(2, 20:27, 29:36, 44))

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
    replace_na(list(n = 0)) %>%
    filter(n > 0)
  
  pal <- colorBin("viridis", NULL, bins = seq(0, 600, 5))
  
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
        "Unique NIS count: {data_plot$n}<br>"
      ),
      label = glue::glue(
        "Ecoregion: {data_plot$ECOREGION} | ",
        "Unique NIS count: {data_plot$n}"
      ),
      layerId = ~ECO_CODE_X
    ) %>%
    addLegend(
      colors = pal(c(0, 100, 200, 300, 400, 500, 600)),
      labels = as.character(c(0, 100, 200, 300, 400, 500, 600)),
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

invasion_eu_table <- function(ecoregion) {
  renderDT({
    if (length(ecoregion()) == 0) {
      
      data <- dm_data$taxo_tbl %>% 
        left_join(dm_data$inv_tbl, by = "SpeciesID") %>% 
        left_join(
          meow_eco, c("Ecoregion_Code" = "ECO_CODE_X"), 
          relationship = "many-to-many"
        ) %>%
        slice(0) # Make an empty table
      
    } else {
      
      data <- dm_data$taxo_tbl %>% 
        left_join(dm_data$inv_tbl, by = "SpeciesID") %>% 
        filter(Ecoregion_Code %in% ecoregion()) %>%
        arrange(Ecoregion_Code) %>%
        left_join(
          meow_eco, c("Ecoregion_Code" = "ECO_CODE_X"), 
          relationship = "many-to-many"
        ) %>%
        distinct(Species, Ecoregion_Code, .keep_all = TRUE)
    }
    
    datatable(
      data = data %>%  select(
        Kingdom:Species, AphiaID:ncbiID, 
        Year:MSFD_subregion, 
        REALM, RLM_CODE, 
        PROVINCE, PROV_CODE, 
        ECOREGION, ECO_CODE = Ecoregion_Code,
        Source, DB
      ), #select(AphiaID, Ecoregion = ECOREGION, Country, Kingdom:Species),
      filter = "top", extensions = c("Buttons", "Scroller"), 
      options = list(
        dom = "Bfrtip", buttons = c("copy", "csv", "excel"),
        deferRender = TRUE, scrollY = 200, scrollX = 400, scroller = TRUE
      )
    )
  })
}
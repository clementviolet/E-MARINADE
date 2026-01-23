meow_europe <- meow %>%
  dplyr::filter(ECO_CODE_X %in% c(2, 20:27, 29:36, 44))

suppressWarnings({
  
  europe_cent <- meow_europe %>%
    sf::st_union() %>% 
    sf::st_centroid() %>%
    sf::st_coordinates()
  
})

invasion_eu_map <- function(year = 2024){
  
  nb_inv_ecoregion <- dm_data$inv_tbl %>%
    dplyr::filter(is.na(year) | year <= year) %>%
    dplyr::filter(!is.na(ECO_CODE_X)) %>%
    dplyr::distinct(taxonID, ECO_CODE_X, .keep_all = TRUE) %>%
    dplyr::count(ECO_CODE_X)
  
  data_plot <- meow_europe %>%
    dplyr::left_join(nb_inv_ecoregion, by = c("ECO_CODE_X")) %>%
    tidyr::replace_na(list(n = 0)) %>%
    dplyr::filter(n > 0)
  
  pal <- leaflet::colorBin("viridis", NULL, bins = seq(0, 700, 5))
  
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
        dplyr::left_join(dm_data$inv_tbl, by = "taxonID") %>% 
        dplyr::left_join(
          meow, by ="ECO_CODE_X", 
          relationship = "many-to-many"
        ) %>%
        dplyr::left_join(
          taxoIdentifiers, by = "taxonID"
        ) %>%
        dplyr::slice(0) # Make an empty table
      
    } else {
      
      data <- dm_data$taxo_tbl %>% 
        dplyr::left_join(dm_data$inv_tbl, by = "taxonID") %>%
        dplyr::left_join(
          taxoIdentifiers, by = "taxonID"
        ) %>%
        dplyr::filter(ECO_CODE_X %in% ecoregion()) %>%
        dplyr::arrange(ECO_CODE_X) %>%
        dplyr::left_join(
          meow, by = "ECO_CODE_X", 
          relationship = "many-to-many"
        ) %>%
        dplyr::distinct(acceptedNameUsage, ECO_CODE_X, .keep_all = TRUE)
    }
    
    DT::datatable(
      data = data %>% 
        dplyr::select(
        kingdom:acceptedNameUsage, `WoRMS AphiaID`:`AlgaeBAse Taxonomic ID`, 
        year:occurrenceRemarks, 
        REALM, RLM_CODE, 
        PROVINCE, PROV_CODE, 
        ECOREGION, ECO_CODE_X,
        associatedReferences, references
      ) %>%
        dplyr::rename(
          Kingdom = kingdom,
          Phylum = phylum,
          Class = class,
          Order = order,
          Family = family,
          Genus = genus,
          Year = year,
          Country = country,
          References = references
        ),
      filter = "top", extensions = c("Buttons", "Scroller"), 
      options = list(
        dom = "Bfrtip", buttons = c("copy", "csv", "excel"),
        deferRender = TRUE, scrollY = 200, scrollX = 400, scroller = TRUE
      )
    )
  }, server = FALSE)
}
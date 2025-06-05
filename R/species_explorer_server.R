speciesExplorerServer <- function(input, output, session, dm_data, taxo, meow_eco) {
  
  output$speciesTaxoTable <- renderDT({
    datatable(
      taxo %>% select(Kingdom:Species, AphiaID:algaebaseID),
      selection = "multiple",
      filter = "top",
      extensions = c("Buttons", "Scroller"),
      options = list(
        dom = "Bfrtip", buttons = c("copy", "csv", "excel"),
        scrollY = 200, scrollX = 400, scroller = TRUE
      )
    )
  })
  
  selected_species <- reactive({
    req(input$speciesTaxoTable_rows_selected)
    unique(taxo[input$speciesTaxoTable_rows_selected, "SpeciesID", drop = TRUE])
  })
  
  output$selectedSpecies <- renderUI({
    req(selected_species())
    species_name <- taxo %>%
      filter(SpeciesID %in% selected_species()) %>%
      pull(Species) %>%
      unique()
    HTML(paste(species_name, collapse = ", "))
  })
  
  # Combined Map
  output$speciesCombinedMap <- renderLeaflet({
    
    if(length(input$speciesTaxoTable_rows_selected) == 0){
      
      # Return an empty leaflet map centered over the ocean
      leaflet() %>%
        addTiles()
      
    }else{
      
      req(selected_species())
      
      origin_data <- dm_data$origin_tbl %>%
        filter(SpeciesID %in% selected_species())
      
      inv_data <- dm_data$inv_tbl %>%
        filter(SpeciesID %in% selected_species())
      
      native_polygons <- meow_eco %>% filter(ECO_CODE_X %in% origin_data$ECO_CODE_X)
      inv_polygons <- meow_eco %>% filter(ECO_CODE_X %in% inv_data$Ecoregion_Code)
      
      leaflet() %>%
        addTiles() %>%
        {
          map <- .
          if (nrow(native_polygons) > 0) {
            map <- map %>%
              addPolygons(
                data = native_polygons,
                fillColor = "#2c7bb6", fillOpacity = 0.7, color = "#1c5c99", weight = 1,
                label = ~ECOREGION,
                group = "Native"
              )
          }
          if (nrow(inv_polygons) > 0) {
            map <- map %>%
              addPolygons(
                data = inv_polygons,
                fillColor = "#d7191c", fillOpacity = 0.5, color = "#a31616", weight = 1,
                label = ~ECOREGION,
                group = "Introduced"
              )
          }
          map %>%
            addLegend(
              position = "bottomright",
              colors = c("#2c7bb6", "#d7191c")[c(nrow(native_polygons) > 0, nrow(inv_polygons) > 0)],
              labels = c("Native", "Introduced")[c(nrow(native_polygons) > 0, nrow(inv_polygons) > 0)],
              title = NULL
            )
        }
      
    }
  })
  
  # DT tables for data download
  output$invDataTable <- renderDT({
    req(selected_species())
    inv_data <- dm_data$inv_tbl %>%
      filter(SpeciesID %in% selected_species()) %>%
      left_join(meow_eco, by = c("Ecoregion_Code" = "ECO_CODE_X")) %>%
      left_join(taxo, by = "SpeciesID") %>%
      select(
        Kingdom:Species, AphiaID:ncbiID, 
        Year:MSFD_subregion, 
        REALM, RLM_CODE, 
        PROVINCE, PROV_CODE, 
        ECOREGION, ECO_CODE = Ecoregion_Code,
        Source, DB
      )
    
    datatable(inv_data, extensions = c("Buttons", "Scroller"),
              options = list(dom = "Bfrtip", buttons = c("copy", "csv", "excel"),
                             scrollY = 200, scrollX = 400, scroller = TRUE))
  })
  
  output$originDataTable <- renderDT({
    req(selected_species())
    
    origin_data <- dm_data$origin_tbl %>%
      filter(SpeciesID %in% selected_species()) %>%
      left_join(meow_eco, by = c("ECO_CODE_X" = "ECO_CODE_X")) %>%
      left_join(taxo, by = "SpeciesID") %>% 
      select(
        Kingdom:Species, AphiaID:ncbiID, 
        REALM, RLM_CODE, 
        PROVINCE, PROV_CODE, 
        ECOREGION, ECO_CODE = ECO_CODE_X,
        Source, Comment
      )
    
    if(is.na(origin_data$ECO_CODE)){
      
      origin_data <- origin_data %>%
        slice(0)
      
    }else{
      
      origin_data <- dm_data$origin_tbl %>%
        filter(SpeciesID %in% selected_species()) %>%
        left_join(meow_eco, by = c("ECO_CODE_X" = "ECO_CODE_X")) %>%
        left_join(taxo, by = "SpeciesID") %>% 
        select(
          Kingdom:Species, AphiaID:ncbiID, 
          REALM, RLM_CODE, 
          PROVINCE, PROV_CODE, 
          ECOREGION, ECO_CODE = ECO_CODE_X,
          Source, Comment
        )
      
    }
    
    datatable(origin_data, extensions = c("Buttons", "Scroller"),
              options = list(dom = "Bfrtip", buttons = c("copy", "csv", "excel"),
                             scrollY = 200, scrollX = 400, scroller = TRUE))
  })
  
}

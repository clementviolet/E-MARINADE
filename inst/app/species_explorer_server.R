speciesExplorerServer <- function(id, dm_data, meow_eco) {
  
  moduleServer(id, function(input, output, session) {
    
    ns <- session$ns
    
    default_text <- "Caulerpa taxifolia\n417798"
    
    input_mode <- shiny::reactive({ input$inputMode })
    
    user_has_typed <- shiny::reactive({
      input_mode() == "text" &&
        !is.null(input$textSp) &&
        input$textSp != "" &&
        input$textSp != default_text
    })
    
    sp_input <- shiny::reactive({
      shiny::req(input$textSp)
      lines <- unlist(strsplit(input$textSp, "\n"))
      trimmed <- stringr::str_trim(lines)
      trimmed <- trimmed[trimmed != ""]
      is_aphia <- stringr::str_detect(trimmed, "^\\d+$")
      list(
        species = trimmed[!is_aphia],
        aphia = trimmed[is_aphia]
      )
    })
    
    matched_sp <- shiny::reactive({
      shiny::req(user_has_typed())
      sp <- sp_input()$species
      dm_data$taxo_tbl$Species[dm_data$taxo_tbl$Species %in% sp]
    })
    
    matched_aphia <- shiny::reactive({
      shiny::req(user_has_typed())
      aphia <- as.numeric(sp_input()$aphia)
      dm_data$taxo_tbl$AphiaID[dm_data$taxo_tbl$AphiaID %in% aphia]
    })
    
    # output$textSPOut2 <- shiny::renderPrint({
    #   list(
    #     user_has_typed = user_has_typed(),
    #     inputMode = input$inputMode,
    #     matched_sp = matched_sp(),
    #     matched_aphia = matched_aphia(),
    #     invalid_sp_name = sp_input()$species[!sp_input()$species %in% dm_data$taxo_tbl$Species],
    #     aphia_not_found = as.numeric(sp_input()$aphia)[
    #       !as.numeric(sp_input()$aphia) %in% dm_data$taxo_tbl$AphiaID
    #     ]
    #   )
    # })
    
    output$validSpeciesNameSuccess <- shiny::renderUI({
      
      if (input$inputMode != "text") return(NULL)
      
      if (!user_has_typed()) return(NULL)
      
      valid <- matched_sp()
      
      if (length(valid) > 0) {
        shinydashboard::box(
          title = "✅ Success",
          status = "success",
          solidHeader = TRUE,
          width = 12,
          paste("Recognised species:", paste(valid, collapse = ", "))
        )
      }
    })
    
    output$validAphiaSuccess <- shiny::renderUI({
      
      if (input$inputMode != "text") return(NULL)
      
      if (!user_has_typed()) return(NULL)
      
      valid <- matched_aphia()
      
      if (length(valid) > 0) {
        shinydashboard::box(
          title = "✅ Success",
          status = "success",
          solidHeader = TRUE,
          width = 12,
          paste("Recognised AphiaIDs:", paste(valid, collapse = ", "))
        )
      }
    })
    
    output$invalidSpeciesNameWarning <- renderUI({
      
      if (input$inputMode != "text") return(NULL)
      
      if (!user_has_typed()) return(NULL)
      
      invalid <- sp_input()$species[!sp_input()$species %in% dm_data$taxo_tbl$Species]
      
      # if (TRUE) {
      if (length(invalid) > 0) {
        shinydashboard::box(
          title = "⚠️ Warning",
          status = "warning",
          solidHeader = TRUE,
          width = 12,
          paste("Unrecognised species:", paste(invalid, collapse = ", "))
        )
      }
    })
    
    output$invalidAphiaWarning <- shiny::renderUI({
      if (input$inputMode != "text") return(NULL)
      
      if (!user_has_typed()) return(NULL)
      
      aphia <- as.numeric(sp_input()$aphia)
      invalid <- aphia[!aphia %in% dm_data$taxo_tbl$AphiaID]

      if (length(invalid) > 0) {
        shinydashboard::box(
          title = "⚠️ Warning",
          status = "warning",
          solidHeader = TRUE,
          width = 12,
          paste("Unrecognised AphiaIDs:", paste(invalid, collapse = ", "))
        )
      }
    })
    
    matched_species_ids <- reactive({
      if (input_mode() == "text") {
        if (!user_has_typed()) return(NULL)
        sp <- sp_input()$species
        aphia <- as.numeric(sp_input()$aphia)
        dm_data$taxo_tbl %>%
          dplyr::filter(Species %in% sp | AphiaID %in% aphia) %>%
          dplyr::pull(SpeciesID) %>%
          unique()
      } else {
        req(input$speciesTaxoTable_rows_selected)
        unique(dm_data$taxo_tbl[input$speciesTaxoTable_rows_selected, "SpeciesID", drop = TRUE])
      }
    })
    
    output$speciesTaxoTable <- DT::renderDT({
      DT::datatable(
        dm_data$taxo_tbl %>% dplyr::select(Kingdom:Species, AphiaID:algaebaseID),
        selection = if (input_mode() == "table") "multiple" else "none",
        filter = "top",
        extensions = c("Buttons", "Scroller"),
        options = list(
          dom = "Bfrtip", buttons = c("copy", "csv", "excel"),
          scrollY = 200, scrollX = 400, scroller = TRUE
        )
      )
    })
    
    output$selectedSpecies <- renderUI({
      req(matched_species_ids())
      species_name <- dm_data$taxo_tbl %>%
        dplyr::filter(SpeciesID %in% matched_species_ids()) %>%
        dplyr::pull(Species) %>%
        unique()
      shiny::HTML(paste(species_name, collapse = ", "))
    })
    
    output$speciesCombinedMap <- leaflet::renderLeaflet({
      selected <- tryCatch(matched_species_ids(), error = function(e) NULL)
      if (length(selected) == 0 || is.null(selected)) {
        leaflet::leaflet() %>% leaflet::addTiles()
      } else {
        origin_data <- dm_data$origin_tbl %>%
          dplyr::filter(SpeciesID %in% selected)
        inv_data <- dm_data$inv_tbl %>%
          dplyr::filter(SpeciesID %in% selected)
        native_polygons <- meow_eco %>%
          dplyr::filter(ECO_CODE_X %in% origin_data$ECO_CODE_X)
        inv_polygons <- meow_eco %>%
          dplyr::filter(ECO_CODE_X %in% inv_data$Ecoregion_Code)
        
        map <- leaflet::leaflet() %>% leaflet::addTiles()
        if (nrow(native_polygons) > 0) {
          map <- map %>%
            leaflet::addPolygons(data = native_polygons,
                                 fillColor = "#2c7bb6", fillOpacity = 0.7,
                                 color = "#1c5c99", weight = 1,
                                 label = ~ECOREGION,
                                 group = "Native")
        }
        if (nrow(inv_polygons) > 0) {
          map <- map %>%
            leaflet::addPolygons(data = inv_polygons,
                                 fillColor = "#d7191c", fillOpacity = 0.5,
                                 color = "#a31616", weight = 1,
                                 label = ~ECOREGION,
                                 group = "Introduced")
        }
        map %>%
          leaflet::addLegend(
            position = "bottomright",
            colors = c("#2c7bb6", "#d7191c")[c(nrow(native_polygons) > 0, nrow(inv_polygons) > 0)],
            labels = c("Native", "Introduced")[c(nrow(native_polygons) > 0, nrow(inv_polygons) > 0)],
            title = NULL
          )
      }
    })
    
    # DataTables
    output$invDataTable <- DT::renderDT({
      req(matched_species_ids())
      inv_data <- dm_data$inv_tbl %>%
        dplyr::filter(SpeciesID %in% matched_species_ids()) %>%
        dplyr::left_join(meow_eco, by = c("Ecoregion_Code" = "ECO_CODE_X")) %>%
        dplyr::left_join(dm_data$taxo_tbl, by = "SpeciesID") %>%
        dplyr::select(Kingdom:Species, AphiaID:ncbiID, Year:MSFD_subregion,
                      REALM, RLM_CODE, PROVINCE, PROV_CODE,
                      ECOREGION, ECO_CODE = Ecoregion_Code, Source, DB)
      
      DT::datatable(inv_data, extensions = c("Buttons", "Scroller"),
                    options = list(dom = "Bfrtip", buttons = c("copy", "csv", "excel"),
                                   scrollY = 200, scrollX = 400, scroller = TRUE))
    })
    
    output$originDataTable <- DT::renderDT({
      req(matched_species_ids())
      origin_data <- dm_data$origin_tbl %>%
        dplyr::filter(SpeciesID %in% matched_species_ids()) %>%
        dplyr::left_join(meow_eco, by = c("ECO_CODE_X" = "ECO_CODE_X")) %>%
        dplyr::left_join(dm_data$taxo_tbl, by = "SpeciesID") %>%
        dplyr::select(Kingdom:Species, AphiaID:ncbiID, REALM, RLM_CODE,
                      PROVINCE, PROV_CODE, ECOREGION, ECO_CODE = ECO_CODE_X,
                      Source, Comment)
      
      if (all(is.na(origin_data$ECO_CODE))) {
        origin_data <- origin_data %>% dplyr::slice(0)
      } else {
        origin_data <- origin_data %>% dplyr::filter(!is.na(ECO_CODE))
      }
      
      DT::datatable(origin_data, extensions = c("Buttons", "Scroller"),
                    options = list(dom = "Bfrtip", buttons = c("copy", "csv", "excel"),
                                   scrollY = 200, scrollX = 400, scroller = TRUE))
    })
    
    # Create a button to de-select the rows of the first table
    proxy <- DT::dataTableProxy("speciesTaxoTable")
    
    observeEvent(input$clearSelection, {
      proxy %>% DT::selectRows(NULL)
    })
    
  })
  
}
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
    }, server = FALSE)
    
    output$SpeciesListPicker <- shiny::renderUI({
      
      ids <- matched_species_ids()
      if (is.null(ids)) ids <- character(0)
      
      choices <- dm_data$taxo_tbl %>%
        dplyr::filter(SpeciesID %in% ids) %>%
        dplyr::distinct(SpeciesID, Species) %>%
        dplyr::arrange(Species)
      
      shinyWidgets::pickerInput(
        inputId = ns("SpeciesListPicker"),
        label = "Select Species to Map below", 
        choices = stats::setNames(choices$SpeciesID, choices$Species),
        multiple = TRUE,
        options = shinyWidgets::pickerOptions(container = "body", 
                                              actionsBox = TRUE),
        width = "100%"
      )
      
    })
    
    selected_species_ids <- reactive({
      if (input_mode() == "text") {
        # In text mode, use what the user picked from the pickerInput
        
        input$SpeciesListPicker
        
      } else {
        # In table mode, use matched_species_ids()
        matched_species_ids()
      }
    })
    
    output$speciesCombinedMap <- leaflet::renderLeaflet({
      
      selected <- selected_species_ids()
      
      # Handle empty selections
      if (is.null(selected) || length(selected) == 0) {
        
        return(leaflet::leaflet() %>% leaflet::addTiles())
        
      }
      
      # Ensure IDs are the correct type
      selected <- as.numeric(selected)  # make sure to match SpeciesID column type
      
      # Filter origin and invasion data
      origin_data <- dm_data$origin_tbl %>%
        dplyr::filter(SpeciesID %in% selected) %>%
        dplyr::add_count(ECO_CODE_X)
      
      inv_data <- dm_data$inv_tbl %>%
        dplyr::filter(SpeciesID %in% selected) %>%
        dplyr::arrange(SpeciesID, Year) %>%
        dplyr::distinct(SpeciesID, Ecoregion_Code, .keep_all = TRUE) %>%
        dplyr::add_count(Ecoregion_Code)
      
      # Get matching polygons
      native_polygons_unique <- meow_eco %>%
        dplyr::filter(ECO_CODE_X %in% origin_data$ECO_CODE_X[origin_data$n == 1])
      
      native_polygons_multiple <- meow_eco %>%
        dplyr::filter(ECO_CODE_X %in% origin_data$ECO_CODE_X[origin_data$n > 1])
      
      inv_polygons_unique <- meow_eco %>%
        dplyr::filter(ECO_CODE_X %in% inv_data$Ecoregion_Code[inv_data$n == 1])
      
      inv_polygons_multiple <- meow_eco %>%
        dplyr::filter(ECO_CODE_X %in% inv_data$Ecoregion_Code[inv_data$n > 1])
      
      nat_inv_polygons <- dplyr::distinct(origin_data, ECO_CODE_X) %>%
        dplyr::filter(ECO_CODE_X %in% dplyr::pull(dplyr::distinct(inv_data, Ecoregion_Code), Ecoregion_Code)) %>%
        dplyr::distinct(ECO_CODE_X, .keep_all = TRUE) %>%
        dplyr::left_join(meow_eco, by = "ECO_CODE_X") %>%
        sf::st_as_sf()
      
      # Remove the polygon of native and inv polygons in case nat_inv polygon is
      # not null
      
      if(nrow(nat_inv_polygons) > 0){
        
        native_polygons_unique <- native_polygons_unique %>%
          dplyr::filter(!ECO_CODE_X %in% nat_inv_polygons$ECO_CODE_X)
        
        native_polygons_multiple <- native_polygons_multiple %>%
          dplyr::filter(!ECO_CODE_X %in% nat_inv_polygons$ECO_CODE_X)
        
        inv_polygons_unique <- inv_polygons_unique %>%
          dplyr::filter(!ECO_CODE_X %in% nat_inv_polygons$ECO_CODE_X)
        
        inv_polygons_multiple <- inv_polygons_multiple %>%
          dplyr::filter(!ECO_CODE_X %in% nat_inv_polygons$ECO_CODE_X)
        
      }
      
      native_polygons_unique <- native_polygons_unique %>%
        dplyr::distinct(ECO_CODE_X, .keep_all = TRUE)
      
      native_polygons_multiple <- native_polygons_multiple %>%
        dplyr::distinct(ECO_CODE_X, .keep_all = TRUE)
      
      inv_polygons_unique <- inv_polygons_unique %>%
        dplyr::distinct(ECO_CODE_X, .keep_all = TRUE)
      
      inv_polygons_multiple <- inv_polygons_multiple %>%
        dplyr::distinct(ECO_CODE_X, .keep_all = TRUE)
      
      # Build base map
      map <- leaflet::leaflet() %>% leaflet::addTiles()
      
      if (nrow(native_polygons_unique) > 0) {
        map <- map %>%
          leaflet::addPolygons(
            data = native_polygons_unique,
            fillColor = "#4db3ff", fillOpacity = 0.5,
            color = "#1c5c99", weight = 1,
            label = ~ECOREGION,
            group = "Native"
          )
      }
      
      if (nrow(native_polygons_multiple) > 0) {
        map <- map %>%
          leaflet::addPolygons(
            data = native_polygons_multiple,
            fillColor = "#1c5c99", fillOpacity = 1,
            color = "#1c5c99", weight = 1,
            label = ~ECOREGION,
            group = "NativeMul"
          )
      }
      
      if (nrow(inv_polygons_unique) > 0) {
        map <- map %>%
          leaflet::addPolygons(
            data = inv_polygons_unique,
            fillColor = "#d7191c", fillOpacity = 0.5,
            color = "#a31616", weight = 1,
            label = ~ECOREGION,
            group = "Introduced"
          )
      }
      
      if (nrow(inv_polygons_multiple) > 0) {
        map <- map %>%
          leaflet::addPolygons(
            data = inv_polygons_multiple,
            fillColor = "#4d0c01", fillOpacity = 1,
            color = "#4d0c01", weight = 1,
            label = ~ECOREGION,
            group = "IntroducedMul"
          )
      }
      
      if (nrow(nat_inv_polygons) > 0) {
        map <- map %>%
          leaflet::addPolygons(
            data = nat_inv_polygons,
            fillColor = "#ffeb33", fillOpacity = 0.8,
            color = "#a39622", weight = 1,
            label = ~ECOREGION,
            group = "IntroducedNative"
          )
      }
      
      # Add legend (conditionally)
      map %>%
        leaflet::addLegend(
          position = "bottomleft",
          opacity = 1,
          colors = c("#4db3ff", "#1c5c99", "#ffeb33", "#ff0000", "#4d0c01")[c(nrow(native_polygons_unique) > 0, nrow(native_polygons_multiple) > 0, nrow(nat_inv_polygons) > 0, nrow(inv_polygons_unique) > 0, nrow(inv_polygons_multiple) > 0)],
          labels = c("Native", "Native multiple sp.", "Native and Introduced", "Introduced", "Introduced multiple sp.")[c(nrow(native_polygons_unique) > 0, nrow(native_polygons_multiple) > 0,  nrow(nat_inv_polygons) > 0, nrow(inv_polygons_unique) > 0, nrow(inv_polygons_multiple) > 0)],
          title = NULL
        )
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
    }, server = FALSE)
    
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
    }, server = FALSE)
    
    # Create a button to de-select the rows of the first table
    proxy <- DT::dataTableProxy("speciesTaxoTable")
    
    observeEvent(input$clearSelection, {
      proxy %>% DT::selectRows(NULL)
    })
    
  })
  
}
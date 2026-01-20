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
    
    
    taxo_lvl <- shiny::reactive({
      shiny::req(input$selectTaxoLvl)
      
      input$selectTaxoLvl
    })
    
    sp_input <- shiny::reactive({
      shiny::req(input$textSp)
      lines <- unlist(strsplit(input$textSp, "\n"))
      trimmed <- stringr::str_trim(lines)
      trimmed <- trimmed[trimmed != ""]
      
      if(taxo_lvl() == "Species"){
        
        is_aphia <- stringr::str_detect(trimmed, "^\\d+$")
        
      } else{
        
        is_aphia <- FALSE
        
      }
      
      list(
        species = trimmed[!is_aphia],
        aphia = trimmed[is_aphia]
      )
      
    })
    
    matched_sp <- shiny::reactive({
      
      shiny::req(user_has_typed())
      taxon <- sp_input()$species
      
      if(taxo_lvl() == "Kingdom"){
        
        dm_data$taxo_tbl$acceptedNameUsage[dm_data$taxo_tbl$kingdom %in% taxon]
        
      } else if(taxo_lvl() == "Phylum"){
        
        dm_data$taxo_tbl$acceptedNameUsage[dm_data$taxo_tbl$phylum %in% taxon]
        
      } else if(taxo_lvl() == "Class"){
        
        dm_data$taxo_tbl$acceptedNameUsage[dm_data$taxo_tbl$class %in% taxon]
        
      } else if(taxo_lvl() == "Order"){
        
        dm_data$taxo_tbl$acceptedNameUsage[dm_data$taxo_tbl$order %in% taxon]
        
      } else if(taxo_lvl() == "Family"){
        
        dm_data$taxo_tbl$acceptedNameUsage[dm_data$taxo_tbl$family %in% taxon]
        
      } else if(taxo_lvl() == "Genus"){
        
        dm_data$taxo_tbl$acceptedNameUsage[dm_data$taxo_tbl$genus %in% taxon]
        
      } else{
        
        dm_data$taxo_tbl$acceptedNameUsage[dm_data$taxo_tbl$acceptedNameUsage %in% taxon]
        
      }
    })
    
    matched_aphia <- shiny::reactive({
      
      shiny::req(user_has_typed())
      
      if(taxo_lvl() == "Species"){
        
        aphia <- as.numeric(sp_input()$aphia)
        
        taxon_id <- dm_data$taxo_identifiers %>%
          filter(title == "AphiaID", identifier == aphia) %>%
          pull(taxonID)
        
        dm_data$taxo_tbl$taxonID[dm_data$taxo_tbl$taxonID %in% taxon_id]
        
      } else{
        
        NULL
        
      }
      
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
          title = "✅ Success - Recognised taxon/taxa",
          status = "success",
          solidHeader = TRUE,
          width = 12,
          paste(valid, collapse = ", ")
        )
      }
    })
    
    output$validAphiaSuccess <- shiny::renderUI({
      
      if (input$inputMode != "text") return(NULL)
      
      if (!user_has_typed()) return(NULL)
      
      valid_taxon_id <- matched_aphia()
      
      valid <- taxo_identifiers %>%
        filter(taxonID %in% valid_taxon_id) %>%
        pull(`WoRMS AphiaID`)
      
      if (length(valid) > 0) {
        shinydashboard::box(
          title = "✅ Success - Recognised AphiaID(s)",
          status = "success",
          solidHeader = TRUE,
          width = 12,
          paste(valid, collapse = ", ")
        )
      }
    })
    
    output$invalidSpeciesNameWarning <- renderUI({
      
      if (input$inputMode != "text") return(NULL)
      
      if (!user_has_typed()) return(NULL)
      
      
      invalid <- sp_input()$species[!sp_input()$species %in% dm_data$taxo_tbl$acceptedNameUsage]
      
      taxon <- sp_input()$species
      
      if(taxo_lvl() == "Kingdom"){
        
        invalid <- taxon[!taxon %in% dm_data$taxo_tbl$kingdom]
        
      } else if(taxo_lvl() == "Phylum"){
        
        invalid <- taxon[!taxon %in% dm_data$taxo_tbl$phylum]
        
      } else if(taxo_lvl() == "Class"){
        
        invalid <- taxon[!taxon %in% dm_data$taxo_tbl$class]
        
      } else if(taxo_lvl() == "Order"){
        
        invalid <- taxon[!taxon %in% dm_data$taxo_tbl$order]
        
      } else if(taxo_lvl() == "Family"){
        
        invalid <- taxon[!taxon %in% dm_data$taxo_tbl$family]
        
      } else if(taxo_lvl() == "Genus"){
        
        invalid <- taxon[!taxon %in% dm_data$taxo_tbl$genus]
        
      } else{
        
        invalid <- taxon[!taxon %in% dm_data$taxo_tbl$acceptedNameUsage]
        
      }
      
      # if (TRUE) {
      if (length(unique(invalid)) > 0) {
        shinydashboard::box(
          title = "⚠️ Warning - Unrecognised taxon/taxa",
          status = "warning",
          solidHeader = TRUE,
          width = 12,
          paste(invalid, collapse = ", ")
        )
      }
    })
    
    output$invalidAphiaWarning <- shiny::renderUI({
      if (input$inputMode != "text") return(NULL)
      
      if (!user_has_typed()) return(NULL)
      
      aphia <- as.numeric(sp_input()$aphia)
      
      aphia_df <- dm_data$taxo_identifiers %>%
        filter(title == "AphiaID")
      
      invalid <- aphia[!aphia %in% aphia_df$identifier]

      if (length(invalid) > 0) {
        shinydashboard::box(
          title = "⚠️ Warning - Unrecognised AphiaIDs",
          status = "warning",
          solidHeader = TRUE,
          width = 12,
          paste(invalid, collapse = ", ")
        )
      }
    })
    
    matched_species_ids <- reactive({
      if (input_mode() == "text") {
        if (!user_has_typed()) return(NULL)
        
        taxon <- sp_input()$species
        aphia <- as.numeric(sp_input()$aphia)
        
        
        if(taxo_lvl() == "Kingdom"){
          
          dm_data$taxo_tbl %>%
            dplyr::filter(kingdom %in% taxon) %>%
            dplyr::pull(taxonID) %>%
            unique()
          
        } else if(taxo_lvl() == "Phylum"){
          
          dm_data$taxo_tbl %>%
            dplyr::filter(phylum %in% taxonID) %>%
            dplyr::pull(taxonID) %>%
            unique()
          
        } else if(taxo_lvl() == "Class"){
          
          dm_data$taxo_tbl %>%
            dplyr::filter(class %in% taxonID) %>%
            dplyr::pull(taxonID) %>%
            unique()
          
        } else if(taxo_lvl() == "Order"){
          
          dm_data$taxo_tbl %>%
            dplyr::filter(order %in% taxonID) %>%
            dplyr::pull(taxonID) %>%
            unique()
          
        } else if(taxo_lvl() == "Family"){
          
          dm_data$taxo_tbl %>%
            dplyr::filter(family %in% taxonID) %>%
            dplyr::pull(taxonID) %>%
            unique()
          
        } else if(taxo_lvl() == "Genus"){
          
          dm_data$taxo_tbl %>%
            dplyr::filter(genus %in% taxonID) %>%
            dplyr::pull(taxonID) %>%
            unique()
          
        } else{
            
          taxon_ID <- taxo_identifiers %>%
            filter(`WoRMS AphiaID` %in% aphia) %>%
            pull(taxonID)
          
          dm_data$taxo_tbl %>%
            dplyr::filter(acceptedNameUsage %in% taxon | taxonID %in% taxon_ID) %>%
            dplyr::pull(taxonID) %>%
            unique()
          
        }
      } else {
        req(input$speciesTaxoTable_rows_selected)
        unique(dm_data$taxo_tbl[input$speciesTaxoTable_rows_selected, "taxonID", drop = TRUE])
      }
    })
    
    output$speciesTaxoTable <- DT::renderDT({
      DT::datatable(
        dm_data$taxo_tbl %>% 
          dplyr::left_join(
            dplyr::distinct(
              dplyr::select(dm_data$inv_tbl, taxonID, EU_native),
              taxonID, .keep_all = TRUE
            ), 
            by = "taxonID") %>%
          dplyr::left_join(
            taxo_identifiers, by = "taxonID"
          ) %>%
        dplyr::select(kingdom:acceptedNameUsage, EU_native, `WoRMS AphiaID`:`AlgaeBAse Taxonomic ID`),
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
        dplyr::filter(taxonID %in% ids) %>%
        dplyr::distinct(taxonID, acceptedNameUsage) %>%
        dplyr::arrange(acceptedNameUsage)
      
      shinyWidgets::pickerInput(
        inputId = ns("SpeciesListPicker"),
        label = "Refine species to plot and show in the tables", 
        choices = stats::setNames(choices$taxonID, choices$acceptedNameUsage),
        multiple = TRUE,
        options = shinyWidgets::pickerOptions(container = "body", 
                                              actionsBox = TRUE),
        width = "100%"
      )
      
    })
    
    selected_species_ids <- reactive({
      input$SpeciesListPicker
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
        dplyr::filter(taxonID %in% selected, !is.na(ECO_CODE_X)) %>%
        dplyr::add_count(ECO_CODE_X)
      
      inv_data <- dm_data$inv_tbl %>%
        dplyr::filter(establishmentMeans == "introduced") %>%
        dplyr::filter(taxonID %in% selected) %>%
        dplyr::arrange(taxonID, year) %>%
        dplyr::distinct(taxonID, ECO_CODE_X, .keep_all = TRUE) %>%
        dplyr::add_count(ECO_CODE_X)
      
      crypt_data <- dm_data$inv_tbl %>%
        dplyr::filter(establishmentMeans == "uncertain") %>%
        dplyr::filter(taxonID %in% selected) %>%
        dplyr::arrange(taxonID, year) %>%
        dplyr::distinct(taxonID, ECO_CODE_X, .keep_all = TRUE) %>%
        dplyr::add_count(ECO_CODE_X)
      
      # Get matching polygons
      native_polygons_unique <- meow_eco %>%
        dplyr::filter(ECO_CODE_X %in% origin_data$ECO_CODE_X[origin_data$n == 1])
      
      native_polygons_multiple <- meow_eco %>%
        dplyr::filter(ECO_CODE_X %in% origin_data$ECO_CODE_X[origin_data$n > 1])
      
      inv_polygons_unique <- meow_eco %>%
        dplyr::filter(ECO_CODE_X %in% inv_data$ECO_CODE_X[inv_data$n == 1])
      
      inv_polygons_multiple <- meow_eco %>%
        dplyr::filter(ECO_CODE_X %in% inv_data$ECO_CODE_X[inv_data$n > 1])
      
      crypt_polygons_unique <- meow_eco %>%
        dplyr::filter(ECO_CODE_X %in% crypt_data$ECO_CODE_X[inv_data$n == 1])
      
      crypt_polygons_multiple <- meow_eco %>%
        dplyr::filter(ECO_CODE_X %in% crypt_data$ECO_CODE_X[inv_data$n > 1])
      
      inv_crypt_eco_code <- inv_data %>%
        dplyr::bind_rows(crypt_data) %>%
        dplyr::group_split(ECO_CODE_X) %>%
        purrr::keep(~{all(c("uncertain", "introduced") %in% unique(.$establishmentMeans))}) %>%
        purrr::list_rbind()
        
      nat_inv_crypt_polygons <- origin_data %>%
        dplyr::distinct(ECO_CODE_X) %>%
        dplyr::filter(
          ECO_CODE_X %in% c(
            inv_crypt_eco_code$ECO_CODE_X, inv_polygons_unique$ECO_CODE_X, 
            inv_polygons_multiple$ECO_CODE_X, crypt_polygons_unique$ECO_CODE_X,
            crypt_polygons_multiple$ECO_CODE_X
          )
        ) %>%
        dplyr::distinct(ECO_CODE_X, .keep_all = TRUE) %>%
        dplyr::left_join(meow_eco, by = "ECO_CODE_X") %>%
        sf::st_as_sf()
      
      # Dealing with the case we have introduced and cryptogenic in the same polygon
      
      if(nrow(inv_crypt_eco_code) > 0){
        
        inv_polygons_unique <- inv_polygons_unique %>%
          dplyr::filter(!ECO_CODE_X %in% inv_crypt_eco_code$ECO_CODE_X)
        
        inv_polygons_multiple <- inv_polygons_multiple %>%
          dplyr::filter(!ECO_CODE_X %in% inv_crypt_eco_code$ECO_CODE_X)
        
        crypt_polygons_unique <- crypt_polygons_unique %>%
          dplyr::filter(!ECO_CODE_X %in% inv_crypt_eco_code$ECO_CODE_X)
        
        crypt_polygons_multiple <- crypt_polygons_multiple %>%
          dplyr::filter(!ECO_CODE_X %in% inv_crypt_eco_code$ECO_CODE_X)
        
        inv_crypt_polygons <- meow_eco %>%
          dplyr::filter(ECO_CODE_X %in% inv_crypt_eco_code$ECO_CODE_X)
        
      } else {
        
        inv_crypt_polygons <- meow_eco %>%
          dplyr::filter(is.na(ECO_CODE_X))
        
      }
      
      # Remove the polygon of native and inv polygons in case nat_inv polygon is
      # not null
      
      if(nrow(nat_inv_crypt_polygons) > 0){
        
        native_polygons_unique <- native_polygons_unique %>%
          dplyr::filter(!ECO_CODE_X %in% nat_inv_crypt_polygons$ECO_CODE_X)
        
        native_polygons_multiple <- native_polygons_multiple %>%
          dplyr::filter(!ECO_CODE_X %in% nat_inv_crypt_polygons$ECO_CODE_X)
        
        inv_polygons_unique <- inv_polygons_unique %>%
          dplyr::filter(!ECO_CODE_X %in% nat_inv_crypt_polygons$ECO_CODE_X)
        
        inv_polygons_multiple <- inv_polygons_multiple %>%
          dplyr::filter(!ECO_CODE_X %in% nat_inv_crypt_polygons$ECO_CODE_X)
        
        crypt_polygons_unique <- crypt_polygons_unique %>%
          dplyr::filter(!ECO_CODE_X %in% nat_inv_crypt_polygons$ECO_CODE_X)
          
        crypt_polygons_multiple <- crypt_polygons_multiple %>%
          dplyr::filter(!ECO_CODE_X %in% nat_inv_crypt_polygons$ECO_CODE_X)
        
        inv_crypt_polygons <- inv_crypt_polygons %>%
          dplyr::filter(!ECO_CODE_X %in% nat_inv_crypt_polygons$ECO_CODE_X)
        
      }
      
      native_polygons_unique <- native_polygons_unique %>%
        dplyr::distinct(ECO_CODE_X, .keep_all = TRUE)
      
      native_polygons_multiple <- native_polygons_multiple %>%
        dplyr::distinct(ECO_CODE_X, .keep_all = TRUE)
      
      inv_polygons_unique <- inv_polygons_unique %>%
        dplyr::distinct(ECO_CODE_X, .keep_all = TRUE)
      
      inv_polygons_multiple <- inv_polygons_multiple %>%
        dplyr::distinct(ECO_CODE_X, .keep_all = TRUE)
      
      crypt_polygons_unique <- crypt_polygons_unique %>%
        dplyr::distinct(ECO_CODE_X, .keep_all = TRUE)
      
      crypt_polygons_multiple <- crypt_polygons_multiple %>%
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
      
      if (nrow(crypt_polygons_unique) > 0) {
        map <- map %>%
          leaflet::addPolygons(
            data = crypt_polygons_unique,
            fillColor = "#ffeb33", fillOpacity = 0.5,
            color = "#a39622", weight = 1,
            label = ~ECOREGION,
            group = "Cryptogenic"
          )
      }
      
      if (nrow(crypt_polygons_multiple) > 0) {
        map <- map %>%
          leaflet::addPolygons(
            data = crypt_polygons_multiple,
            fillColor = "#e8b600", fillOpacity = 1,
            color = "#c29800", weight = 1,
            label = ~ECOREGION,
            group = "CryptogenicMul"
          )
      }
      
      if (nrow(inv_crypt_polygons) > 0) {
        map <- map %>%
          leaflet::addPolygons(
            data = inv_crypt_polygons,
            fillColor = "#fc8700", fillOpacity = 0.8,
            color = "#c46900", weight = 1,
            label = ~ECOREGION,
            group = "IntroducedCrypt"
          )
      }
      
      if (nrow(nat_inv_crypt_polygons) > 0) {
        map <- map %>%
          leaflet::addPolygons(
            data = nat_inv_crypt_polygons,
            fillColor = "grey", fillOpacity = 0.8,
            color = "grey50", weight = 1,
            label = ~ECOREGION,
            group = "IntroducedCrypt"
          )
      }
      
      # Add legend (conditionally)
      map %>%
        leaflet::addLegend(
          position = "bottomleft",
          opacity = 1,
          colors = c("#4db3ff", "#1c5c99", "#ffeb33", "#e8b600", "#fc8700", "grey", "#ff0000", "#4d0c01")[c(nrow(native_polygons_unique) > 0, nrow(native_polygons_multiple) > 0, nrow(crypt_polygons_unique) > 0, nrow(crypt_polygons_multiple) > 0, nrow(inv_crypt_polygons) > 0, nrow(nat_inv_crypt_polygons) > 0, nrow(inv_polygons_unique) > 0, nrow(inv_polygons_multiple) > 0)],
          labels = c("Native", "Native multiple sp.", "Cryptogenic", "Cryptogenic multiple sp.","Introduced or Cryptogenic", "Native, Introduced or Cryptogenic", "Introduced", "Introduced multiple sp.")[c(nrow(native_polygons_unique) > 0, nrow(native_polygons_multiple) > 0, nrow(crypt_polygons_unique) > 0, nrow(crypt_polygons_multiple) > 0, nrow(inv_crypt_polygons) > 0, nrow(nat_inv_crypt_polygons) > 0, nrow(inv_polygons_unique) > 0, nrow(inv_polygons_multiple) > 0)],
          title = NULL
        )
    })
    
    # DataTables
    output$invDataTable <- DT::renderDT({
      req(input$SpeciesListPicker)
      
      taxon_id <- dm_data$taxo_tbl %>%
        dplyr::filter(taxonID %in% as.numeric(input$SpeciesListPicker)) %>%
        dplyr::pull(taxonID)
      
      
      inv_data <- dm_data$inv_tbl %>%
        dplyr::filter(taxonID %in% taxon_id) %>%
        dplyr::left_join(meow_eco, by = "ECO_CODE_X") %>%
        dplyr::left_join(dm_data$taxo_tbl, by = "taxonID") %>%
        dplyr::left_join(
          taxo_identifiers, by = "taxonID"
        ) %>%
        dplyr::select(
          kingdom:acceptedNameUsage, `WoRMS AphiaID`:`AlgaeBAse Taxonomic ID`, 
          year:occurrenceRemarks,
          REALM, RLM_CODE, 
          PROVINCE, PROV_CODE, 
          ECOREGION, ECO_CODE_X,
          associatedReferences, references
        )
      
      DT::datatable(inv_data, extensions = c("Buttons", "Scroller"), filter = "top",
                    options = list(dom = "Bfrtip", buttons = c("copy", "csv", "excel"),
                                   scrollY = 200, scrollX = 400, scroller = TRUE))
    }, server = FALSE)
    
    output$originDataTable <- DT::renderDT({
      req(input$SpeciesListPicker)
      
      taxon_id <- dm_data$taxo_tbl %>%
        dplyr::filter(taxonID %in% as.numeric(input$SpeciesListPicker)) %>%
        dplyr::pull(taxonID)
      
      
      origin_data <- dm_data$origin_tbl %>%
        dplyr::filter(taxonID %in% taxon_id) %>%
        dplyr::left_join(meow_eco, by = "ECO_CODE_X") %>%
        dplyr::left_join(dm_data$taxo_tbl, by = "taxonID") %>%
        dplyr::left_join(
          taxo_identifiers, by = "taxonID"
        ) %>%
        dplyr::select(
          kingdom:acceptedNameUsage, `WoRMS AphiaID`:`AlgaeBAse Taxonomic ID`,
          REALM, RLM_CODE, 
          PROVINCE, PROV_CODE, 
          ECOREGION, ECO_CODE_X,
          references, occurrenceRemarks
        )
      
      if (all(is.na(origin_data$ECO_CODE_X))) {
        origin_data <- origin_data %>% dplyr::slice(0)
      } else {
        origin_data <- origin_data %>% dplyr::filter(!is.na(ECO_CODE_X))
      }
      
      DT::datatable(origin_data, extensions = c("Buttons", "Scroller"), filter = "top",
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
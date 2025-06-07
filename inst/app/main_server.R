################
# SERVER LOGIC #
################

server <- function(input, output, session){
  
  source(
    system.file("app/map_inv_eu.R", package = "emarinade"),
    local = TRUE
  )
  source(
    system.file("app/species_explorer_server.R", package = "emarinade"),
    local = TRUE
  )
  
  #############################
  #            Home           #
  #############################
  
  #############################
  # European Introduction Map #
  #############################
  
  # Make selected_ecoregion accessible to all outputs
  selected_ecoregions <- shiny::reactiveVal(character(0))
  
  shiny::observeEvent(input$InvasionMap_shape_click, {
    clicked_id <- input$InvasionMap_shape_click$id
    current <- selected_ecoregions()
    
    if (clicked_id %in% current) {
      selected_ecoregions(setdiff(current, clicked_id))  # remove if already selected
    } else {
      selected_ecoregions(c(current, clicked_id))  # add to selection
    }
  })
  
  shiny::observeEvent(input$resetTable, {
    selected_ecoregions(character(0))
  })
  
  
  output$InvasionMap <- leaflet::renderLeaflet({
    
    invasion_eu_map()
    
  })
  
  output$selectedRegion <- shiny::renderUI({
    if (length(selected_ecoregions()) == 0) {
      shiny::HTML("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
    } else {
      eco_names <- meow_eco %>%
        filter(ECO_CODE_X %in% selected_ecoregions()) %>%
        dplyr::pull(ECOREGION) %>%
        unique()
      
      # Wrap each name in a <div>, then place them in a 2-column container
      shiny::HTML(paste0(
        "<div style='column-count: 2; column-gap: 20px; max-width: 600px;'>",
        paste(sprintf(
          "<div style='break-inside: avoid; display: inline-block; margin-bottom: 5px;'>%s</div>", 
          eco_names
        ), collapse = ""),
        "</div>"
      ))
    }
  })
  
  output$InvspeciesDataTable <- invasion_eu_table(selected_ecoregions)
  
  #############################
  #      Species Research     #
  #############################
  
  speciesExplorerServer(input, output, session, dm_data, meow_eco)
  
  proxy <- DT::dataTableProxy("speciesTaxoTable")
  
  # Create a button to de-select the rows of the first table
  shiny::observeEvent(input$clearSelection, {
    
    proxy %>%
      DT::selectRows(NULL)
    
  })
  
}
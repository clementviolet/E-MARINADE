##################
# DATA WRANGLING #
##################

dm_data <- readRDS("../data/NIS_Europe_RDBM.rds")

taxo <- dm_data[["taxo_tbl"]]

load("../data/meow.RData")

################
# SERVER LOGIC #
################

source("plot_cumsum_inv_europe.R")
source("synchronise_sliders.R")
source("map_inv_eu.R")
source("map_inv_origin.R")
source("plot_setup_orgin.R")

################
# SERVER LOGIC #
################


server <- function(input, output, session){
  
  #############################
  #            Home           #
  #############################
  
  #############################
  # European Introduction Map #
  #############################
  
  # output$InvCumSumAll <- renderPlot(cumsum_nis_all_eu())
  
  # sync_slider_input("obs_year_slid", "obs_year_inpt", session)
  
  # Make selected_ecoregion accessible to all outputs
  selected_ecoregions <- reactiveVal(character(0))
  
  observeEvent(input$InvasionMap_shape_click, {
    clicked_id <- input$InvasionMap_shape_click$id
    current <- selected_ecoregions()
    
    if (clicked_id %in% current) {
      selected_ecoregions(setdiff(current, clicked_id))  # remove if already selected
    } else {
      selected_ecoregions(c(current, clicked_id))  # add to selection
    }
  })
  
  observeEvent(input$resetTable, {
    selected_ecoregions(character(0))
  })
  
  
  output$InvasionMap <- renderLeaflet({
    
    # invasion_eu_map(input$obs_year_slid)
    invasion_eu_map()
    
  })
  
  output$selectedRegion <- renderUI({
    if (length(selected_ecoregions()) == 0) {
      HTML("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
    } else {
      eco_names <- meow_eco %>%
        filter(ECO_CODE_X %in% selected_ecoregions()) %>%
        pull(ECOREGION) %>%
        unique()
      
      # Wrap each name in a <div>, then place them in a 2-column container
      HTML(paste0(
        "<div style='column-count: 2; column-gap: 20px; max-width: 500px;'>",
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
  # European Introduction Map #
  #############################
  
  output$OriginMap <- renderLeaflet({
    
    nis_origin_map(input$meow_select)
    
  })
  
  output$OriginUpSet <- renderPlot({
    
    upset_plot(input$select_taxo_setup)
    
  })
  
  #############################
  #       Species Tables      #
  #############################
  
  output$speciesDataTable <- renderDT(
    datatable(
      data = taxo %>% select(Kingdom:Species, AphiaID:algaebaseID),
      filter = "top", extensions = c("Buttons", "Scroller"), 
      options = list(
        dom = "Bfrtip", extend = 'collection', buttons = c("copy", "csv", "excel"), # Buttons,
        deferRender = TRUE, scrollY = 200, scrollX = 200, scroller = TRUE # Scroller
      )
    ),
    server = FALSE
  )
  
  #############################
  #   Species Tables & Map    #
  #############################
  
  # Create a reactive value to store selected region
  selected_ecoregion <- reactiveVal(NULL)
  
  # Update on map click
  observeEvent(input$OriginMap2_shape_click, {
    selected_ecoregion(input$OriginMap2_shape_click$id)
  })
  
  # Reset when reset button is clicked
  observeEvent(input$resetTable, {
    selected_ecoregion(NULL)
  })
  
  
  output$speciesDataTable2 <- renderDT({

    
    if (is.null(selected_ecoregion())) {
      
      data <- dm_data$taxo_tbl %>% 
        left_join(dm_data$origin_tbl, by = "SpeciesID") %>% 
        left_join(
          meow_eco, c("ECO_CODE_X" = "ECO_CODE_X"), 
          relationship = "many-to-many"
        ) %>%
        distinct(Species, PROV_CODE, .keep_all = TRUE)
      
      datatable(
        data = data %>% select(AphiaID, PROVINCE, Kingdom:Species),
        filter = "top", extensions = c("Buttons", "Scroller"), 
        options = list(
          dom = "Bfrtip", extend = 'collection', buttons = c("copy", "csv", "excel"), # Buttons,
          deferRender = TRUE, scrollY = 200, scrollX = 400, scroller = TRUE # Scroller
        )
      )
      
    } else{
      
      clicked_province <- input$OriginMap2_shape_click$id
      
      data <- dm_data$taxo_tbl %>% 
        left_join(dm_data$origin_tbl, by = "SpeciesID") %>% 
        left_join(
          meow_eco, c("ECO_CODE_X" = "ECO_CODE_X"), 
          relationship = "many-to-many"
        ) %>%
        filter(PROV_CODE == clicked_province) %>%
        arrange(PROV_CODE) %>%
        distinct(Species, PROV_CODE, .keep_all = TRUE)
      
      datatable(
        data = data %>% select(AphiaID, PROVINCE, Kingdom:Species),
        filter = "top", extensions = c("Buttons", "Scroller"), 
        options = list(
          dom = "Bfrtip", extend = 'collection', buttons = c("copy", "csv", "excel"), # Buttons,
          deferRender = TRUE, scrollY = 200, scrollX = 400, scroller = TRUE # Scroller
        )
      )
      
    }
    
  })
  
  output$OriginMap2 <-  renderLeaflet({
    
    metadata_meow <- meow_eco %>%
      st_drop_geometry() %>%
      select(ECO_CODE_X, ECOREGION:REALM) %>%
      distinct(ECO_CODE_X, .keep_all = TRUE)
    
    nb_origin_nis <- dm_data[["origin_tbl"]] %>%
      left_join(metadata_meow, by = "ECO_CODE_X")
    
    nb_origin_nis_prov <- nb_origin_nis %>%
      group_by(PROV_CODE) %>%
      distinct(SpeciesID, .keep_all = TRUE) %>%
      ungroup() %>%
      count(PROV_CODE)
    
    data_plot <- meow_prov %>%
      left_join(nb_origin_nis_prov, by = "PROV_CODE")
    
    pal <- colorNumeric("viridis", NULL)
    
    leaflet(data_plot) %>%
      addTiles(options = tileOptions(
        minZoom = 2, maxZoom = 18,
        noWrap = TRUE
      )
      ) %>%
      addPolygons(
        color = "grey", weight = 1,
        fillOpacity = 1,
        fillColor = ~pal(log1p(n)),
        popup = glue::glue(
          "Province: {data_plot$PROVINCE}<br>",
          "NIS count (origin): {data_plot$n}<br>"
        ),
        label = glue::glue(
          "Province: {data_plot$PROVINCE} | ",
          "NIS count (origin): {data_plot$n}"
        ),
        layerId = ~PROV_CODE
      ) %>%
      addLegend(
        pal = pal, values = ~log1p(n),
        title = "NIS Count (origin)",
        labFormat = labelFormat(transform = function(x) round(expm1(x))),
        opacity =1
      ) %>%
      setMaxBounds(
        lng1 = -180, lat1 = -90,
        lng2 = 180, lat2 = 90
      ) %>%
      setView(lng = 0, lat = 0, zoom = 2)
    
  })
  
}
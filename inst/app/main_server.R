################
# SERVER LOGIC #
################

server <- function(input, output, session){
  
  source(
    system.file("app/server_inv_map.R", package = "anise"),
    local = TRUE
  )
  source(
    system.file("app/server_species_explorer.R", package = "anise"),
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
  
  output$InvTableDef <- shiny::renderTable({
    
    tibble::tribble(
      ~Variable,	~Definition,
      "Kingdom", "The full scientific name of the kingdom in which the taxon is classified",
      "Phylum", "The full scientific name of the phylum or division in which the taxon is classified",	
      "Class", 	"The full scientific name of the class in which the taxon is classified",
      "Order", "The full scientific name of the order in which the taxon is classified",	
      "Family", "The full scientific name of the family in which the taxon is classified",
      "Genus", "The full scientific name of the genus in which the taxon is classified",
      "Acceptednameusage", 	"The full name, with authorship and date information if known, of the currently valid (zoological) or accepted (botanical) taxon",
      "WoRMS AphiaID", "WoRMS Aphia ID unique taxon identifier",
      "ITIS Taxonomic Serial Number", "ITIS TSN unique taxon identifier",	
      "BOLD taxonomic ID", "BOLD unique taxon identifier",
      "Fishbase taxonomic ID", "Fishbase unique taxon identifier",
      "NCBI Taxonomic ID", "NCBI unique taxon identifier",	
      "Algaebase Taxonomic ID", "Algaebase unique taxon identifier",	
      "Year", "The four-digit year in which the dwc:Event occurred, according to the Common Era Calendar",
      "Country", "The name of the country or major administrative unit in which the dcterms:Location occurs",
      "EU_native", "Is the taxon native from one of the European ecoregion",
      "Establishmentmeans", "Statement about whether an organism has been introduced to a given place and time through the direct or indirect activity of modern humans",
      "Occurrenceremarks", "Comments or notes about the occurrence",
      "REALM", "Realm name",
      "RLM_CODE", "Code of the Realm",
      "PROVINCE", "Province name",
      "PROV_CODE", "Code of the Province",
      "ECOREGION", "Ecoregion name",
      "ECO_CODE_X", "Code of the Ecoregion in a short format",
      "Associatedreferences", "A list (concatenated and separated) of identifiers (publication, bibliographic reference, global unique identifier, URI) of literature associated with the occurrence",
      "References", "A related resource that is referenced, cited, or otherwise pointed to by the described resource"
    )
  })
  
  #############################
  #      Species Explorer     #
  #############################
  speciesExplorerServer("species_explorer", dm_data, meow_eco)
  
  
  output$IntroTableDef <- shiny::renderTable({

    tibble::tribble(
      ~Variable,	~Definition,
      "Kingdom", "The full scientific name of the kingdom in which the taxon is classified",
      "Phylum", "The full scientific name of the phylum or division in which the taxon is classified",
      "Class", 	"The full scientific name of the class in which the taxon is classified",
      "Order", "The full scientific name of the order in which the taxon is classified",
      "Family", "The full scientific name of the family in which the taxon is classified",
      "Genus", "The full scientific name of the genus in which the taxon is classified",
      "Acceptednameusage", 	"The full name, with authorship and date information if known, of the currently valid (zoological) or accepted (botanical) taxon",
      "WoRMS AphiaID", "WoRMS Aphia ID unique taxon identifier",
      "ITIS Taxonomic Serial Number", "ITIS TSN unique taxon identifier",
      "BOLD Taxonomic ID", "BOLD unique taxon identifier",
      "Fishbase Taxonomic ID", "Fishbase unique taxon identifier",
      "NCBI Taxonomic ID", "NCBI unique taxon identifier",
      "Algaebase taxonomic ID", "Algaebase unique taxon identifier",
      "Year", "The four-digit year in which the dwc:Event occurred, according to the Common Era Calendar",
      "Country", "The name of the country or major administrative unit in which the dcterms:Location occurs",
      "EU_native", "Is the taxon native from one of the European ecoregion",
      "Establishmentmeans", "Statement about whether an organism has been introduced to a given place and time through the direct or indirect activity of modern humans",
      "Occurrenceremarks", "Comments or notes about the occurrence"
    )
  })
  
  output$NatRangeDef <- shiny::renderTable({

    tibble::tribble(
      ~Variable,	~Definition,
      "Kingdom", "The full scientific name of the kingdom in which the taxon is classified",
      "Phylum", "The full scientific name of the phylum or division in which the taxon is classified",
      "Class", 	"The full scientific name of the class in which the taxon is classified",
      "Order", "The full scientific name of the order in which the taxon is classified",
      "Family", "The full scientific name of the family in which the taxon is classified",
      "Genus", "The full scientific name of the genus in which the taxon is classified",
      "Acceptednameusage", 	"The full name, with authorship and date information if known, of the currently valid (zoological) or accepted (botanical) taxon",
      "WoRMS AphiaID", "WoRMS Aphia ID unique taxon identifier",
      "ITIS Taxonomic Serial Number", "ITIS TSN unique taxon identifier",
      "BOLD Taxonomic ID", "BOLD unique taxon identifier",
      "Fishbase Taxonomic ID", "Fishbase unique taxon identifier",
      "NCBI Taxonomic ID", "NCBI unique taxon identifier",
      "Algaebase Taxonomic ID", "Algaebase unique taxon identifier",
      "REALM", "Realm name",
      "RLM_CODE", "Code of the Realm",
      "PROVINCE", "Province name",
      "PROV_CODE", "Code of the Province",
      "ECOREGION", "Ecoregion name",
      "ECO_CODE_X", "Code of the Ecoregion in a short format",
      "References", "A related resource that is referenced, cited, or otherwise pointed to by the described resource",
      "Occurrenceremarks", "Comments or notes about the occurrence"
    )
  })
  
}
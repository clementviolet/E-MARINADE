speciesSearchUI <- function(id) {
  ns <- shiny::NS(id)
  
  shinydashboard::tabItem(
    tabName = "species_search",
    
    shiny::fluidRow(
      shiny::column(width = 12, shiny::tags$h1("Species Explorer"))
    ),
    
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::tags$p(
          "Click on a row in the taxonomic table or use the input field to filter by species/AphiaIDs.",
          shiny::tags$sup(
            shiny::tags$a(href = "#note-1", "1")
            )
          ),
        shiny::tags$p("In the tables below, you will be able to access and download the information about the introduced and native range.")
      )
    ),
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::radioButtons(
          inputId = ns("inputMode"),
          label = "Select Input Mode:",
          choices = c("Table selection" = "table", "Text input" = "text"),
          selected = "table",
          inline = TRUE
        )
      )
    ),
    
    # Always render the text input field (server will handle logic)
    shiny::conditionalPanel(
      condition = sprintf("input['%s'] == 'text'", ns("inputMode")),
      shiny::fluidRow(
        shiny::column(
          width = 12,
          shiny::selectInput(
            inputId = ns("selectTaxoLvl"),
            "Select taxonomic level of interest. Note: If you have selected a taxonomic rank higher than Species, the search by AphiaID will not be available.",
            c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"),
            selected = "Species"
          )
        ),
        shiny::column(
          width = 12,
          shiny::textAreaInput(
            inputId = ns("textSp"),
            label = "Species or AphiaIDs (one per line).",
            value = "Caulerpa taxifolia\n417798",
            width = "50%", rows = 6
          )
        )
      )
    ),
    
    # shiny::fluidRow(
    #   shiny::column(width = 12, shiny::verbatimTextOutput(ns("textSPOut2")))
    # ),
    
    # Alerts – always rendered, but controlled in server with req(input$inputMode == "text")
    shiny::fluidRow(
      shiny::column(6, shiny::uiOutput(ns("validSpeciesNameSuccess"))),
      shiny::column(6, shiny::uiOutput(ns("invalidSpeciesNameWarning")))
    ),
    shiny::fluidRow(
      shiny::column(6, shiny::uiOutput(ns("validAphiaSuccess"))),
      shiny::column(6, shiny::uiOutput(ns("invalidAphiaWarning")))
    ),
    
    # DT Table shown only if table mode is selected
    shiny::conditionalPanel(
      condition = sprintf("input['%s'] == 'table'", ns("inputMode")),
      shiny::fluidRow(
        shiny::column(
          width = 12,
          shinycssloaders::withSpinner(
            DT::DTOutput(ns("speciesTaxoTable")),
            color = "blue"
          )
        )
      ),
    ),
    
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::uiOutput(ns("SpeciesListPicker"))  # Renders the picker from the server
      )
    ),
    
    shiny::fluidRow(
      shiny::column(width = 12, leaflet::leafletOutput(ns("speciesCombinedMap"), height = "600px"))
    ),
    
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::br(), shiny::br(),
        shiny::tags$p(
          shiny::tags$strong("NB:"), "If a species has no known native area, the ",
          shiny::tags$span("Native Range", style = "font-weight: bold; background-color: #f0f0f0; padding: 2px 6px; border-radius: 4px; border: 1px solid #ccc;"),
          " subpanel will be empty."
        )
      )
    ),
    
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shinydashboard::tabBox(
          width = 12,
          shiny::tabPanel("Introduced Range",
                          shinycssloaders::withSpinner(
                            DT::DTOutput(ns("invDataTable")),
                            color = "blue"
                          )
          ),
          shiny::tabPanel("Native Range",
                          shinycssloaders::withSpinner(
                            DT::DTOutput(ns("originDataTable")),
                            color = "blue"
                          )
          )
        )
      )
    ),
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::tags$hr(),
        shiny::tags$div(
          id = "note-1",
          style = "font-size: 12px; color: grey;",
          shiny::tags$sup("1"), "Searching by AphiaID is currently supported only at the species level. Future versions will extend this feature to all taxonomic levels."
        )
      )
    ),
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::tags$h3("Fields Definitions"),
        shiny::tags$h4("Introduced Range"), 
        shiny::tableOutput("IntroTableDef"),
        shiny::tags$h4("Native Range"),
        shiny::tableOutput("NatRangeDef"),
      )
    )
  )
}
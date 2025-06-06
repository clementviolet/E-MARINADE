speciesSearchUI <- function() {
  shinydashboard::tabItem(
    tabName = "species_search",
    shiny::fluidRow(
      shiny::column(width = 12, shiny::tags$h1("Species Explorer"))
    ),
    shiny::fluidRow(
      shiny::column(width = 12,
             shiny::tags$p("Click on a row in the taxonomic table to explore a NIS distribution accross its introduced and native ranges."),
             shiny::tags$p("In the tables below, you will be able to access and download the informations about the introduced and native range.")
             )
    ),
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shinycssloaders::withSpinner(
          DT::DTOutput("speciesTaxoTable"),
          color = "blue")
        )
    ),
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::br(), shiny::br(),
        shiny::div(
          style = "display: flex; align-items: center; justify-content: flex-start; gap: 20px; margin-bottom: 20px;",
          shiny::div(
            style = "font-size: 16px; color: #444;",
            shiny::tags$span("Selected Species: "),
            shiny::htmlOutput("selectedSpecies", inline = TRUE)
          ),
          shiny::actionButton("clearSelection", "Clear Selection",
                       class = "btn btn-secondary",
                       style = "padding: 6px 15px; font-size: 14px;")
        )
      )
    ),
    shiny::fluidRow(
      shiny::column(width = 12, leaflet::leafletOutput("speciesCombinedMap", height = "600px"))
    ),
    shiny::fluidRow(
      shiny::column(width = 12,
             shiny::br(), shiny::br(),
             shiny::tags$p(
               shiny::tags$strong("NB:"), "If a species has no known native area, the ",
               shiny::tags$span("Native Range", style = "font-weight: bold; background-color: #f0f0f0; padding: 2px 6px; border-radius: 4px; border: 1px solid #ccc;"),
               "subpanel will be empty."
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
                     DT::DTOutput("invDataTable"),
                     color = "blue")
                   ),
          shiny::tabPanel("Native Range", shinycssloaders::withSpinner(
            DT::DTOutput("originDataTable"),
            color = "blue")
            )
        )
      )
    )
  )
}

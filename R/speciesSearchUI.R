speciesSearchUI <- function() {
  tabItem(
    tabName = "species_search",
    fluidRow(
      column(width = 12, tags$h1("Species Explorer"))
    ),
    fluidRow(
      column(width = 12,
             tags$p("Click on a row in the taxonomic table to explore a NIS distribution accross its introduced and native ranges."),
             tags$p("In the tables below, you will be able to access and download the informations about the introduced and native range.")
             )
    ),
    fluidRow(
      column(width = 12, DTOutput("speciesTaxoTable") %>% withSpinner(color = "blue"))
    ),
    fluidRow(
      column(
        width = 12,
        br(), br(),
        div(
          style = "display: flex; align-items: center; justify-content: flex-start; gap: 20px; margin-bottom: 20px;",
          div(
            style = "font-size: 16px; color: #444;",
            tags$span("Selected Species: "),
            htmlOutput("selectedSpecies", inline = TRUE)
          ),
          actionButton("clearSelection", "Clear Selection",
                       class = "btn btn-secondary",
                       style = "padding: 6px 15px; font-size: 14px;")
        )
      )
    ),
    fluidRow(
      column(width = 12, leafletOutput("speciesCombinedMap", height = "600px"))
    ),
    fluidRow(
      column(width = 12,
             br(), br(),
             tags$p(
               tags$strong("NB:"), "If a species has no known native area, the ",
               tags$span("Native Range", style = "font-weight: bold; background-color: #f0f0f0; padding: 2px 6px; border-radius: 4px; border: 1px solid #ccc;"),
               "subpanel will be empty."
              )
      )
    ),
    fluidRow(
      column(
        width = 12,
        tabBox(
          width = 12,
          tabPanel("Introduced Range", DTOutput("invDataTable") %>% withSpinner(color = "blue")),
          tabPanel("Native Range", DTOutput("originDataTable") %>% withSpinner(color = "blue"))
        )
      )
    )
  )
}

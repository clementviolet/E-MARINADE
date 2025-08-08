invMapUI <- function() {
  shinydashboard::tabItem(
    tabName = "inv_map",
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::tags$h1("European Introduction")
      )
    ),
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::tags$h2("European Introduction Map"),
        shiny::tags$p(
          "Use the map below to explore non-indigenous species (NIS) present in each Eureopan ecoregion. ",
          "Click on one or multiple polygons to select ecoregions and view the corresponding NIS in the table. ",
          "You can filter the table using the column headers, export the data using the buttons above the table, ",
          "and reset your selection at any time by clicking the ",
          shiny::tags$span("Reset Table", style = "font-weight: bold; background-color: #f0f0f0; padding: 2px 6px; border-radius: 4px; border: 1px solid #ccc;"),
          "button. "
        )
      )
    ),
    shiny::fluidRow(
      shiny::column(
        width = 12,
        leaflet::leafletOutput("InvasionMap", height = "600px")
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
            shiny::tags$span("Selected Ecoregion: "),
            shiny::htmlOutput("selectedRegion", inline = TRUE)
          ),
          shiny::actionButton(
            "resetTable", "Reset Table",
            class = "btn btn-lg",
            style = "padding: 10px 30px; font-size: 16px; margin: 0;"
          )
        ),
        shiny::br(),
        shinycssloaders::withSpinner(
          DT::DTOutput("InvspeciesDataTable"),
          color = "blue"
        )
      )
    )
  )
}

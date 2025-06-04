invMapUI <- function() {
  tabItem(
    tabName = "inv_map",
    fluidRow(
      column(
        width = 12,
        tags$h1("European Introduction")
      )
    ),
    fluidRow(
      column(
        width = 12,
        tags$h2("European Introduction Map"),
        tags$p(
          "Use the map below to explore non-indigenous species (NIS) present in each Eureopan ecoregion. ",
          "Click on one or multiple polygons to select ecoregions and view the corresponding NIS in the table. ",
          "You can filter the table using the column headers, export the data using the buttons above the table, ",
          "and reset your selection at any time by clicking the ",
          tags$span("Reset Table", style = "font-weight: bold; background-color: #f0f0f0; padding: 2px 6px; border-radius: 4px; border: 1px solid #ccc;"),
          "button. "
        )
      )
    ),
    fluidRow(
      column(
        width = 12,
        leafletOutput("InvasionMap", height = "600px")
      )
    ),
    fluidRow(
      column(
        width = 12,
        br(), br(),
        div(
          style = "display: flex; align-items: center; justify-content: flex-start; gap: 20px; margin-bottom: 20px;",
          div(
            style = "font-size: 16px; color: #444;",
            tags$span("Selected Ecoregion: "),
            htmlOutput("selectedRegion", inline = TRUE)
          ),
          actionButton(
            "resetTable", "Reset Table",
            class = "btn btn-lg",
            style = "padding: 10px 30px; font-size: 16px; margin: 0;"
          )
        ),
        br(),
        DTOutput("InvspeciesDataTable") %>% withSpinner(color = "blue")
      )
    )
  )
}

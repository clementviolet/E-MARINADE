library(shiny)

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
        tags$h2("European Introduction Rate")
      )
    ),
    fluidRow(
      column(
        width = 12,
        tags$p("Plot showing the cumulative number of NIS observed in European waters")
      )
    ),
    fluidRow(
      column(
        width = 12,
        plotOutput("InvCumSumAll", height = "400px")
      )
    ),
    fluidRow(
      column(
        width = 12,
        tags$h2("European Introduction Map")
      )
    ),
    fluidRow(
      column(
        width = 12,
        tags$p(
          "The slider and numeric input control the year of first sighting, including species sighted earlier."
        )
      )
    ),
    fluidRow(
      column(
        width = 6,
        sliderInput("obs_year_slid", "", min = 1492, max = 2023, value = 1492, sep = "")
      ),
      column(
        width = 6,
        numericInput("obs_year_inpt", "", min = 1942, max = 2023, value = 1492)
      )
    ),
    fluidRow(
      column(
        width = 12,
        leafletOutput("InvasionMap", height = "600px")
      )
    )
  )
}

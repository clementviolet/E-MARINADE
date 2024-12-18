library(shiny)
library(shinycssloaders)

tableTabUI <- function() {
  tabItem(
    tabName = "table",
    dataTableOutput("speciesDataTable") %>% withSpinner(color = "blue")
  )
}

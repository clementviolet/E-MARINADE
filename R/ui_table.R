tableTabUI <- function() {
  tabItem(
    tabName = "table",
    DTOutput("speciesDataTable") %>% withSpinner(color = "blue")
  )
}

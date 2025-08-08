homeTabUI <- function() {
  shinydashboard::tabItem(
    tabName = "home",
    shiny::includeMarkdown(system.file("www/home.md", package = "emarinade"))
  )
}
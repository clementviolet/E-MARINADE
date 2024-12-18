library(shiny)

homeTabUI <- function() {
  tabItem(
    tabName = "home",
    includeMarkdown("../www/home.md")
  )
}
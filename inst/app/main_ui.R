###########
# LOAD UI #
###########

source("inst/app/ui_styles.R", local = TRUE)
source("inst/app/ui_home.R", local = TRUE)
source("inst/app/ui_inv_map.R", local = TRUE)
# source("ui_table.R")
# source("ui_org_map.R")
# source("ui_table_map.R")
source("inst/app/speciesSearchUI.R", local = TRUE)

sidebar <- function(){
  
  shinydashboard::dashboardSidebar(
    width = 300,
    shinydashboard::sidebarMenu(
      shiny::HTML(
        paste0(
          "<br><br>",
          "<img style = 'display: block; margin-left: auto; margin-right: auto;' src='wwww/Logo_EMARINADE.png' width = '186'>",
          "<br>"
        )
      ),
      shinydashboard::menuItem(
        "Home",
        tabName = "home",
        icon = shiny::icon("home")
      ),
      shinydashboard::menuItem(
        "European Introduction Map",
        tabName = "inv_map", icon = shiny::icon("map")
      ),
      shinydashboard::menuItem(
        "Species Explorer",
        tabName = "species_search", icon = shiny::icon("globe")
      )
    )
  )
}

body <- function(){
  
  shinydashboard::dashboardBody(
    shinydashboard::tabItems(
      homeTabUI(),
      invMapUI(),
      speciesSearchUI()
    )
  )
  
}

ui <- shinydashboard::dashboardPage(
  skin = "blue",
  header = shinydashboard::dashboardHeader(
    title = shiny::tagList(
      shiny::tags$div(
        style = "line-height: 1.2;",
        shiny::tags$strong("E-MARINADE"),
        shiny::tags$div(
          "Mapping the Origins and Spread of Marine Non-Indigenous Species in European Waters",
          style = "font-size: 12px; color: #ccc;"
        )
      )
    ),
    titleWidth = 300
  ),
  sidebar = sidebar(),
  body = shinydashboard::dashboardBody(
    globalStyles(),
    shinydashboard::tabItems(
      homeTabUI(),
      invMapUI(),
      speciesSearchUI()
    )
  )
)

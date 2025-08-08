###########
# LOAD UI #
###########

source(
  system.file("app/ui_styles.R", package = "emarinade"),
  local = TRUE
)

source(
  system.file("app/ui_home.R", package = "emarinade"),
  local = TRUE
)

source(
  system.file("app/ui_inv_map.R", package = "emarinade"),
  local = TRUE
)

source(
  system.file("app/speciesSearchUI.R", package = "emarinade"),
  local = TRUE
)

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
      )#,
      # shinydashboard::menuItem(
      #   "Species Text",
      #   tabName = "text_sp", icon = shiny::icon("file-lines")
      # )
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
    title = "E-MARINADE",
    #   shiny::tagList(
    #   shiny::tags$div(
    #     style = "line-height: 1.2;",
    #     shiny::tags$strong("E-MARINADE"),
    #     shiny::tags$div(
    #       "Mapping the Origins and Spread of Marine Non-Indigenous Species in European Waters",
    #       style = "font-size: 12px; color: #ccc;"
    #     )
    #   )
    # ),
    titleWidth = 300
  ),
  sidebar = sidebar(),
  body = shinydashboard::dashboardBody(
    globalStyles(),
    shinydashboard::tabItems(
      homeTabUI(),
      invMapUI(),
      speciesSearchUI("species_explorer")
    )
  )
)

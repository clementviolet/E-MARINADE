###########
# LOAD UI #
###########

source(
  system.file("app/ui_styles.R", package = "anise"),
  local = TRUE
)

source(
  system.file("app/ui_home.R", package = "anise"),
  local = TRUE
)

source(
  system.file("app/ui_inv_map.R", package = "anise"),
  local = TRUE
)

source(
  system.file("app/ui_species_explorer.R", package = "anise"),
  local = TRUE
)

sidebar <- function(){
  
  shinydashboard::dashboardSidebar(
    width = 300,
    shinydashboard::sidebarMenu(
      shiny::HTML(
        paste0(
          "<br><br>",
          "<img style = 'display: block; margin-left: auto; margin-right: auto;' src='wwww/Logo_ANIS-E.svg' width = '186'>",
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
    title = "ANIS-E",
    #   shiny::tagList(
    #   shiny::tags$div(
    #     style = "line-height: 1.2;",
    #     shiny::tags$strong("ANIS-E"),
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
    shiny::tags$head(
      shiny::tags$link(rel = "shortcut icon", href = "wwww/favicon.ico"),
      shiny::tags$link(rel = "apple-touch-icon", sizes = "180x180", href = "wwww/apple-touch-icon.png"),
      shiny::tags$link(rel = "icon", type = "image/png", sizes = "32x32", href = "wwww/favicon-32x32.png"),
      shiny::tags$link(rel = "icon", type = "image/png", sizes = "16x16", href = "wwww/favicon-16x16.png")
    ),
    shinydashboard::tabItems(
      homeTabUI(),
      invMapUI(),
      speciesSearchUI("species_explorer")
    )
  )
)

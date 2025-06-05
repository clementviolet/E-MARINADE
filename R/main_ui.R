###########
# LOAD UI #
###########

source("ui_home.R")
source("ui_inv_map.R")
source("ui_table.R")
source("ui_styles.R")
source("ui_org_map.R")
source("ui_table_map.R")
source("speciesSearchUI.R")

sidebar <- function(){
  
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      HTML(
        paste0(
          "<br>",
          "&emsp;PLACE DU LOGO",
          "<br><br>"
        )
      ),
      menuItem(
        "Home",
        tabName = "home",
        icon = icon("home")
      ),
      menuItem(
        "European Introduction Map",
        tabName = "inv_map", icon = icon("map")
      ),
      menuItem(
        "Species Explorer",
        tabName = "species_search", icon = icon("globe")
      )#,
      # menuItem(
      #   "European NIS Origins",
      #   tabName = "org_map", icon = icon("map")
      # ),
      # menuItem(
      #   "Species Tables",
      #   tabName = "table", icon = icon("table")
      # ),
      # menuItem(
      #   "Species Table & Map",
      #   tabName = "table_map", icon = icon("table")
      # )
    )
  )
}

body <- function(){
  
  dashboardBody(
    tabItems(
      homeTabUI(),
      invMapUI(),
      speciesSearchUI()#,
      # OrgMapUI(),
      # tableTabUI(),
      # tableMapUI()
    )
  )
  
}

ui <- fluidPage(
  globalStyles(),
  dashboardPage(
    skin = "blue",
    dashboardHeader(title = "NIS Atlas of European Waters", titleWidth = 300),
    sidebar(),
    body()
  )
)

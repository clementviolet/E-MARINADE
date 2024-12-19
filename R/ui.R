##################################
# Biodiversity in National Parks #
# by Alessio Benedetti           #
# ui.R file                      #
##################################

library(shiny)
library(shinydashboard)

# library(leaflet)
# library(shinydashboard)
# library(collapsibleTree)
# library(shinycssloaders)
# library(DT)
# library(tigris)

###########
# LOAD UI #
###########

source("ui_home.R")
source("ui_inv_map.R")
source("ui_table.R")
source("ui_styles.R")
source("ui_org_map.R")

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
        "European NIS Origins",
        tabName = "org_map", icon = icon("map")
      ),
      menuItem(
        "Species Tables",
        tabName = "table", icon = icon("table")
      )
    )
  )
}

body <- function(){
  
  dashboardBody(
    tabItems(
      homeTabUI(),
      invMapUI(),
      OrgMapUI(),
      tableTabUI()
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

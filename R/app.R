# Library
# library(tidyverse)
# library(shiny)
# library(shinydashboard)
# library(shinycssloaders)
# library(ComplexUpset)
# library(leaflet)
# library(DT)
# library(dm)
# library(sf)

#' Title
#' 
#' @importFrom dplyr filter
#' @returns NULL
#' @export
#'
shiny_emarinade <- function(){
  
  suppressMessages({

    sf::sf_use_s2(FALSE)

  })

  data_env <- new.env()
  data_path <- system.file("app/data/shiny_app_data.rda", package = "emarinade")
  load(data_path, envir = data_env)

  dm_data <- dm::dm_get_tables(data_env$dm_data)

  meow_eco <- data_env$meow_eco
  meow_prov <- data_env$meow_prov
  meow_rlm <- data_env$meow_rlm

  rm(data_env)

  # Shiny App per say

  # Shiny ressources
  # There is a bug in the way shiny expose the files in the www folder. 
  # Normally it is automatic
  shiny::addResourcePath("wwww", system.file("www", package = "emarinade"))

  source(
    system.file("app/main_ui.R", package = "emarinade"),
    local = TRUE
  )
  
  source(
    system.file("app/main_server.R", package = "emarinade"),
    local = TRUE
  )

  # Run the application

  shiny::shinyApp(ui = ui, server = server)
  
  
}


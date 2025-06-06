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
  load("inst/app/data/shiny_app_data.rda", envir = data_env)

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

  source("inst/app/main_ui.R", local = TRUE)
  source("inst/app/main_server.R", local = TRUE)

  # Run the application

  shiny::shinyApp(ui = ui, server = server)
  
  
}


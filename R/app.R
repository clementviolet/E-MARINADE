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
  
  europe_ecoregions <- c(2, 20:27, 29, 30:36, 44)

  rm(data_env)
  
  # Retrieve species native of EU but NIS in other part of EU
  
  eu_nativeID <- dm_data$origin_tbl %>% 
    dplyr::filter(ECO_CODE_X %in% europe_ecoregions) %>% 
    dplyr::pull(SpeciesID) %>% 
    unique()
  
  dm_data$inv_tbl <- dm_data$inv_tbl %>%
    dplyr::mutate(
      EU_native = dplyr::if_else(SpeciesID %in% eu_nativeID, TRUE, FALSE),
      .after = "Country"
    )
  
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


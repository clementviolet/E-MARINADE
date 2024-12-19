library(shiny)
library(tidyverse)
library(sf)
library(ComplexUpset)
library(DT)
library(dm)
theme_set(theme_minimal())
theme_update(panel.grid.minor = element_blank())


##################
# DATA WRANGLING #
##################

dm_data <- readRDS("../data/NIS_Europe_RDBM.rds")

taxo <- dm_data[["taxo_tbl"]]

load("../data/meow.RData")

################
# SERVER LOGIC #
################

source("plot_cumsum_inv_europe.R")
source("synchronise_sliders.R")
source("map_inv_eu.R")
source("map_inv_origin.R")
source("plot_setup_orgin.R")

################
# SERVER LOGIC #
################


server <- function(input, output, session){
  
  #############################
  #            Home           #
  #############################
  
  #############################
  # European Introduction Map #
  #############################
  
  output$InvCumSumAll <- renderPlot(cumsum_nis_all_eu())
  
  sync_slider_input("obs_year_slid", "obs_year_inpt", session)
  
  output$InvasionMap <- renderLeaflet({
    
    invasion_eu_map(input$obs_year_slid)
    
  })
  
  #############################
  # European Introduction Map #
  #############################
  
  output$OriginMap <- renderLeaflet({
    
    nis_origin_map(input$meow_select)
    
  })
  
  output$OriginUpSet <- renderPlot({
    
    upset_plot(input$select_taxo_setup)
    
  })
  
  #############################
  #       Species Tables      #
  #############################
  
  output$speciesDataTable <- renderDT(
    datatable(
      data = taxo %>% select(Kingdom:Species, AphiaID:algaebaseID),
      filter = "top", extensions = c("Buttons", "Scroller"), 
      options = list(
        dom = "Bfrtip", extend = 'collection', buttons = c("copy", "csv", "excel"), # Buttons,
        deferRender = TRUE, scrollY = 200, scrollX = 200, scroller = TRUE # Scroller
      )
    ),
    server = FALSE
  )
}
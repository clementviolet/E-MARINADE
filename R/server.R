library(shiny)
library(tidyverse)
library(DT)
library(dm)

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
  
  #############################
  #       Species Tables      #
  #############################
  
  output$speciesDataTable <- renderDT(
    taxo %>% select(Kingdom:Species, AphiaID:algaebaseID),
    filter = "top",
    colnames = c(
      "Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species",
      "AphiaID", "tsnID", "boldID", "eolID", "fishbaseID", "algaebaseID"
    )
  )
}
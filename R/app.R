# Library
library(tidyverse)
library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(ComplexUpset)
library(leaflet)
library(DT)
library(dm)
library(sf)

sf_use_s2(FALSE)

theme_set(theme_minimal())
theme_update(panel.grid.minor = element_blank())

# Shiny App per say

source("main_ui.R")
source("main_server.R")

# Run the application 

shinyApp(ui = ui, server = server)


# Library
suppressPackageStartupMessages(library(tidyverse))
library(shiny)
library(shinydashboard)
library(leaflet)
library(dm)


# Functions



# Shiny App per say

source("ui.R")
source("server.app")

# Run the application 

shinyApp(ui = ui, server = server)


# README

## Instalation des dépandances

**Important** : Avant de tenter de lancer l'application Shiny, il est nécessaire
que les packages suivant soient intasllés sur l'ordinateur.

```
library(tidyverse)
library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(ComplexUpset)
library(leaflet)
library(DT)
library(dm)
library(sf)

# library(glue)
# library(scales)
```

Vous pouvez facilement les installer/mettre à jour via cette commande :

```
packages <- c(
  "tidyverse", "shiny", "shinydashboard", "shinycssloaders", "ComplexUpset",
  "leaflet", "DT", "dm", "sf", "glue", "scales"
)

install.packages(packages)
```
## Lancement de l'application

Vous pouvez lancer l'application après avoir ouvert le script `R/app.R` qui se
trouve dans le dossier `R/`.

Une fois le script ouvert, vous n'avez qu'à utiliser le raccourcis suivant :
`CTRL + SHIFT + ENTER` ou bien cliquer sur le bouton `Run App` dans la barre
haute où se trouvent le script.

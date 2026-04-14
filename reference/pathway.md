# Introduction Pathway data

A `tibble` containing the information on the introduction pathway of
non-indigenous taxa present in the Shiny app. This dataset can be useful
when working with the database programmatically.

## Usage

``` r
pathway
```

## Format

### `pathway`

A `tibble` data frame with 9,038 rows and 3 columns:

- pathwayID:

  An identifier for the set of pathway information. Identifier specific
  to the data set.

- occurenceID:

  An identifier for the occurrence. Identifier specific to the data set

- pathway:

  The process by which a dwc:Organism came to be in a given place at a
  given time.

## Source

ANIS-E R package

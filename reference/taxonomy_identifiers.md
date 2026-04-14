# Taxonomic Identifiers Information data

A `tibble` containing the information on the taxonomic identifiers of
taxa present in the Shiny app. This dataset can be useful when working
with the database programmatically.

## Usage

``` r
taxonomy_identifiers
```

## Format

### `taxonomy_identifiers`

A `tibble` data frame with 5,893 rows and 5 columns:

- identifierID:

  An identifier for the set of taxon information. Identifier specific to
  the data set.

- taxonID:

  An identifier for the set of taxon information. Identifier specific to
  the data set.

- title:

  An optional display label for the URL that the publisher may prefer be
  displayed with the identifier or link.

- identifier:

  Other known identifier used for the same taxon. Can be a URL pointing
  to a webpage, an xml or rdf document, a DOI, UUID or any other
  identifer.

- subject:

  Keywords qualifying the identifier

## Source

ANIS-E package

# Taxonomy Information data

A `tibble` containing the information on the taxonomy of taxa present in
the Shiny app. This dataset can be useful when working with the database
programmatically.

## Usage

``` r
taxonomy
```

## Format

### `taxonomy`

A `tibble` data frame with 2,016 rows and 8 columns:

- taxonID:

  An identifier for the set of taxon information. Identifier specific to
  the data set.

- Kingdom, Phylum, Class, Order, Family, Genus:

  The full scientific name in which the taxon is classified

- acceeptedNameUsage:

  The full name, with authorship and date information if known, of the
  currently valid (zoological) or accepted (botanical) taxon.

## Source

ANIS-E package

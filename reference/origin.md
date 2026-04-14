# Native range records

A `tibble` containing information about the native range of taxa listed
as non-indigenous species in the Shiny app. This dataset can be useful
when working with the database programmatically.

## Usage

``` r
origin
```

## Format

### `origin`

A `tibble` data frame with 46,014 rows and 5 columns:

- locationID:

  An identifier for the set of origine information. Identifier specific
  to the data set

- taxonID:

  An identifier for the set of taxon information. Identifier specific to
  the data set.

- ECO_CODE_X:

  Code of the Ecoregion in a short format. See
  [meow](https://clementviolet.github.io/E-MARINADE/reference/meow.md)
  documentation.

- nativeEurope:

  Indicates whether the taxon’s native range includes one or more of the
  European marine ecoregions defined by Spalding et al., namely
  Adriatic, Aegean Sea, Alboran Sea, Azores Canaries Madeira, Baltic
  Sea, Black Sea, Celtic Seas, Faroe Plateau, Ionian Sea, Levantine Sea,
  North and East Iceland, North Sea, Northern Norway and Finnmark, South
  and West Iceland, South European Atlantic Shelf, Southern Norway,
  Tunisian Plateau/Gulf of Sidra, and Western Mediterranean.

- references:

  A related resource that is referenced, cited, or otherwise pointed to
  by the described resource.

- occurrenceRemarks:

  Comments or notes about the native range.

## Source

ANIS-E package

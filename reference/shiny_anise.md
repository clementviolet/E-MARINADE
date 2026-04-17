# Launch the ANIS-E Shiny app

Starts the interactive **ANIS-E** application bundled with the package.
The function loads prebuilt data objects and then runs the Shiny
UI/server.

## Usage

``` r
shiny_anise()
```

## Value

A `shiny.appobj` (the running app). The function is usually called for
its side effect of launching the app.

## See also

Dataset documentation:
[taxonomy](https://clementviolet.github.io/ANIS-E/reference/taxonomy.md),
[introduction](https://clementviolet.github.io/ANIS-E/reference/introduction.md),
[origin](https://clementviolet.github.io/ANIS-E/reference/origin.md),
[taxonomy](https://clementviolet.github.io/ANIS-E/reference/taxonomy.md),
[taxonomy_identifiers](https://clementviolet.github.io/ANIS-E/reference/taxonomy_identifiers.md),
[meow](https://clementviolet.github.io/ANIS-E/reference/meow.md).

## Examples

``` r
if (FALSE) { # \dontrun{
  shiny_anise()
} # }
```

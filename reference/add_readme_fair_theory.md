# Add Readme File

Writes a README file to a specific path.

## Usage

``` r
add_readme_fair_theory(path, title, ...)
```

## Arguments

- path:

  Character, indicating the directory in which to create the FAIR
  theory.

- title:

  Character, indicating the theory title. Default: `NULL`

- ...:

  Additional arguments passed to other functions.

## Value

Invisibly returns a logical value, indicating whether the function was
successful or not.

## Examples

``` r
add_readme_fair_theory(path = tempdir(), title = "My Theory")
```

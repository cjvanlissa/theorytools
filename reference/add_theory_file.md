# Add Theory File

Writes a theory file to a specific path.

## Usage

``` r
add_theory_file(path, theory_file = "theory.txt")
```

## Arguments

- path:

  Character, indicating the directory in which to create the FAIR
  theory.

- theory_file:

  Character, referring to existing theory file(s) to be copied, or a new
  theory file to be created. Default `NULL` does nothing.

## Value

Invisibly returns a logical value, indicating whether the function was
successful or not.

## Examples

``` r
add_theory_file(path = tempdir(), theory_file = "theory.txt")
```

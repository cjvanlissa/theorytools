# String Similarity

Wraps
[stringdistmatrix](https://rdrr.io/pkg/stringdist/man/stringdist.html)
to return a string similarity matrix (e.g., for use with
[code](https://cjvanlissa.github.io/theorytools/reference/code.md)).

## Usage

``` r
similarity_stringdist(x, ...)
```

## Arguments

- x:

  Character vector.

- ...:

  Arguments passed to
  [stringdistmatrix](https://rdrr.io/pkg/stringdist/man/stringdist.html).

## Value

`matrix`

## Examples

``` r
similarity_stringdist(c("cat", "a cat", "dog"))
#>       cat a cat dog
#> cat   1.0   0.6 0.4
#> a cat 0.6   1.0 0.0
#> dog   0.4   0.0 1.0
```

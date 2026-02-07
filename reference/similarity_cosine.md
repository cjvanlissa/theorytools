# Cosine Similarity

Compute cosine similarity between rows of matrix.

## Usage

``` r
similarity_cosine(x)
```

## Arguments

- x:

  Numeric matrix, where rows are cases and columns are features.

## Value

`matrix`

## Examples

``` r
set.seed(1)
similarity_cosine(matrix(runif(30), nrow = 3))
#>           [,1]      [,2]      [,3]
#> [1,] 1.0000000 0.7817204 0.8946771
#> [2,] 0.7817204 1.0000000 0.8068776
#> [3,] 0.8946771 0.8068776 1.0000000
```

# Filter Conditional Independencies

Removes all conditional independencies, obtained using
[impliedConditionalIndependencies](https://rdrr.io/pkg/dagitty/man/impliedConditionalIndependencies.html),
based on the variables available in `data`.

## Usage

``` r
filter_conditional_independencies(x, data)
```

## Arguments

- x:

  An object of class `dagitty.cis`.

- data:

  A `data.frame`.

## Value

An object of class `dagitty.cis`, or `NULL` if no conditional
independencies remain.

## See also

[`impliedConditionalIndependencies`](https://rdrr.io/pkg/dagitty/man/impliedConditionalIndependencies.html)

## Examples

``` r
dag <- dagitty::dagitty('dag {
x1 -> y
x2 -> y}')
df <- data.frame(x1 = rnorm(10), y = rnorm(10))
cis <- dagitty::impliedConditionalIndependencies(dag)
cis <- filter_conditional_independencies(cis, df)
is.null(cis)
#> [1] TRUE
```

# Add Significance Asterisks

Given a `data.frame` with a column containing p-values or two columns
containing the lower- and upper bounds of a confidence interval, adds a
column of significance asterisks.

## Usage

``` r
add_significance(x, p_column = NULL, ci_lb = NULL, ci_up = NULL, alpha = 0.05)
```

## Arguments

- x:

  A `data.frame`

- p_column:

  Atomic character, referring to the name of the column of p-values. If
  this is provided, the confidence interval is ignored. Default: `NULL`

- ci_lb:

  Atomic character, referring to the name of the column of the lower
  bound of a confidence interval. Default: `NULL`

- ci_up:

  Atomic character, referring to the name of the column of the upper
  bound of a confidence interval. Default: `NULL`

- alpha:

  Significance level, default: `.05`

## Value

A `data.frame`

## Examples

``` r
tmp <- add_significance(head(iris))
```

# Select Covariate Adjustment Sets from Data

Wraps
[adjustmentSets](https://rdrr.io/pkg/dagitty/man/adjustmentSets.html) to
construct a dataset with covariates that (asymptotically) allow unbiased
estimation of causal effects from observational data.

## Usage

``` r
select_controls(
  x,
  data,
  exposure = NULL,
  outcome = NULL,
  which_set = c("first", "sample", "all"),
  ...
)
```

## Arguments

- x:

  An input graph of class `dagitty`.

- data:

  A `data.frame` or object coercible by
  [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html).

- exposure:

  Atomic character, name of the exposure variable.

- outcome:

  Atomic character, name of the outcome variable.

- which_set:

  Atomic character, indicating which set of covariates to select in case
  there are multiple. Valid choices are in
  `c("first", "sample", "all")`, see Value.

- ...:

  Other arguments passed to
  [adjustmentSets](https://rdrr.io/pkg/dagitty/man/adjustmentSets.html)

## Value

If `which_set = "all"`, returns a list of `data.frames` to allow for
sensitivity analyses. Otherwise, returns a `data.frame`.

## See also

[`adjustmentSets`](https://rdrr.io/pkg/dagitty/man/adjustmentSets.html)

## Examples

``` r
dag <- dagitty::dagitty('dag {x -> y}')
df <- data.frame(x = rnorm(10), y = rnorm(10))
df1 <- select_controls(dag, df, exposure = "x", outcome = "y")
class(df1) == "data.frame"
#> [1] TRUE
df2 <- select_controls(dag, df, exposure = "x", outcome = "y", which_set = "sample")
class(df2) == "data.frame"
#> [1] TRUE
lst1 <- select_controls(dag, df, exposure = "x", outcome = "y", which_set = "all")
class(lst1) == "list"
#> [1] TRUE
```

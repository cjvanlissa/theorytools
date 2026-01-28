# Prune DAG Based on Adjustment Sets

Wraps
[adjustmentSets](https://rdrr.io/pkg/dagitty/man/adjustmentSets.html) to
construct a pruned DAG which only includes covariates that
(asymptotically) allow unbiased estimation of the causal effects of
interest.

## Usage

``` r
prune_dag(
  x,
  exposure = NULL,
  outcome = NULL,
  which_set = c("first", "sample", "all"),
  ...
)
```

## Arguments

- x:

  An input graph of class `dagitty`.

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
prune_dag(dag, exposure = "x", outcome = "y")
#> dag {
#> x
#> y
#> x -> y
#> }
```

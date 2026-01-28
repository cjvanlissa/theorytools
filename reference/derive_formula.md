# Derive Formulae From Augmented DAG

Uses the `form` attribute of edges in an augmented DAG to construct
formulae for the relationship between `exposure` and `outcome`.

## Usage

``` r
derive_formula(x, exposure, outcome, data = NULL, ...)
```

## Arguments

- x:

  An object of class `dagitty`.

- exposure:

  Atomic character, indicating the exposure node in `x`.

- outcome:

  Atomic character, indicating the outcome node in `x`.

- data:

  Optional, a `data.frame` to be used as environment for the formulae.
  Default: `NULL`

- ...:

  Additional arguments, passed to
  [`adjustmentSets`](https://rdrr.io/pkg/dagitty/man/adjustmentSets.html)

## Value

A `list` of objects with class `formula`.

## Details

The `form` attribute of an augmented DAG of class `dagitty` should
contain information about the functional form for the relationships
specified in the DAG. For this function, the `form` attribute must be an
additive function as also accepted by
[`formula`](https://rdrr.io/r/stats/formula.html). The `form` attribute
may contain a leading intercept and constant slopes, which will be
parsed out. If the `form` attribute does not meet these requirements,
the resulting `formula` may be invalid. For example:

- `form=".5+x1"` would return `~x1`.

- `form="2*x1*x2"` would return `~x1+x2+x1:x2`.

- `form="-.2-.2*I(x3^2)"` would return `~I(x3^2)`.

## See also

[`hasArg`](https://rdrr.io/r/methods/hasArg.html)
[`get_edges`](https://cjvanlissa.github.io/tidySEM/reference/get_edges.html)
[`adjustmentSets`](https://rdrr.io/pkg/dagitty/man/adjustmentSets.html)

## Examples

``` r
x <- dagitty::dagitty('dag {
C
O
X
Y
O <- X [form="I(X^2)"]
C -> X
Y -> O [form="Y*X"]
}')
f1 <- derive_formula(x, outcome = "O", exposure = "X")
f2 <- derive_formula(x, outcome = "O", exposure = "Y")
```

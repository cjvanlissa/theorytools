# Simulate Data from DAG

Simulates data from an (augmented) DAG, respecting the optional metadata
fields `form`, for functional form of relationships, and `distribution`,
for the distributions of exogenous nodes and residuals.

## Usage

``` r
simulate_data(
  x,
  beta_default = round(runif(1, min = -0.6, max = 0.6), 2),
  n = 500,
  run = TRUE,
  duplicated = "unique"
)
```

## Arguments

- x:

  An object of class `dagitty`.

- beta_default:

  Function used to specify missing edge coefficients. Default:
  `runif(1, min = -0.6, max = 0.6)`

- n:

  Atomic integer defining the sample size, default: `500`

- run:

  Logical, indicating whether or not to run the simulation. Default:
  `TRUE`.

- duplicated:

  Atomic character, indicating how to resolve duplicate terms from
  multiple edges pointing to the same node. Default: `"unique"`. See
  Details.

## Value

If `run` is `TRUE`, this function returns a `data.frame` with an
additional attribute called `attr( , which = "script")` that contains
the script for simulating data. If `run` is `FALSE`, this function
returns the script as `character` vector.

## Details

Data is simulated sequentially, first from exogenous nodes and then from
their descendants. If `x` is an augmented DAG with metadata indicating
the functional `form` of relationships and `distribution` of exogenous
nodes and residuals, this information is used. If this information is
absent, nodes and residuals are assumed to be normally distributed, and
edges are assumed to be linear, with coefficients samples based on
`beta_default`.

The argument `duplicated` controls how multiplicative terms are merged
across edges pointing to the same outcome node. The default
`duplicated = "unique"` removes terms that are duplicated across edges
(i.e., if two edges point to node `"O"`, and both edges specify `.5*E`,
the resulting function will say `.5*E`. However, if one edge specifies
`.2*E` and the other specifies `.3*E`, they are not duplicated and will
be added. Alternatively, `duplicated = "add"` just sums terms across all
edges pointing into the same outcome node.

## See also

[`get_nodes`](https://cjvanlissa.github.io/tidySEM/reference/get_nodes.html),
[`get_edges`](https://cjvanlissa.github.io/tidySEM/reference/get_edges.html)
[`exogenousVariables`](https://rdrr.io/pkg/dagitty/man/exogenousVariables.html)

## Examples

``` r
x <- dagitty::dagitty('
dag {
  X [distribution="rbinom(size = 2, prob = .5)"]
  Z [distribution="rexp()"]
  Y [distribution="rnorm()"]

  X -> Y [form="0.5+X"]
  Z -> Y [form="2*Z"]
  A -> X
}
')
txt <- simulate_data(x, n = 5, run = FALSE)
df <- simulate_data(x, n = 5, run = TRUE)
df_from_txt <- eval(parse(text = txt))
```

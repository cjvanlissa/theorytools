# Code Text Data

Create a reproducible script for coding qualitative text data by
sequentially assigning elements of `x` to specific labels.

## Usage

``` r
code(x, ...)

# S3 method for class 'character'
code(x, similarity = c("stringdist", "embeddings"), ...)

# S3 method for class 'code_list'
code(x, label = NULL, ...)

add_level(x, similarity = NULL, ...)
```

## Arguments

- x:

  An object for which a method exists.

- ...:

  Additional arguments passed to functions.

- similarity:

  Which method to use to compute similarity between entries. Defaults to
  `"stringdist"`, which uses
  [stringdistmatrix](https://rdrr.io/pkg/stringdist/man/stringdist.html).
  Option `"embeddings"` additionally requires passing the named argument
  `"model_path"`, which should point to a LLM downloaded with
  [download_huggingface](https://cjvanlissa.github.io/theorytools/reference/download_huggingface.md).

- label:

  Label to assign to elements identified via numeric indexing, passed
  via `...`.

## Value

A `list` with class `code_list`.

## Functions

- `add_level()`: In case of nested coding, use `add_level()` to add a
  level of coding to a `code_list` object.

## Examples

``` r
x <- c("autonomy [satisfaction] increases",
"competence [satisfaction] increases", "relatedness [satisfaction] increases"
, "motivation is more internalized", "motivation is more internalized",
"motivation is more internalized1", "event is more controlling",
"event is more controlling",
"event communicates more effectance information")
coded <- code(x)
coded <- code(coded, "need_satisfaction", 1:3)
coded <- code(coded, "internalization", 1:3)
coded <- code(coded, "functional_significance", 1:3)
coded <- add_level(coded)
coded <- code(coded, "random_level1", 1:2)
coded <- code(coded, "random_level2", 1)
coded
#> No more unassigned items.
```

# Get Vector Embeddings (uses Python)

This function wraps the 'transformers' library in 'Python', to obtain
vector embeddings (a numerical representation of meaning) for a
character vector based on a pretrained model.

## Usage

``` r
get_embeddings(x, model_path = NULL)
```

## Arguments

- x:

  Character vector of text to be embedded.

- model_path:

  Atomic character vector referring to a folder with a pretrained model.
  Default: NULL

## Value

Matrix

## Examples

``` r
if (FALSE) { # \dontrun{
if(requireNamespace("reticulate", quietly = TRUE)){
 tmp <- get_embeddings(c("cat", "my cat", "dog"),
 model_path = "scibert_scivocab_uncased")
 }
} # }
```

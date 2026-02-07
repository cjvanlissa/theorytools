# Download 'Hugging Face' Model

Download a model from 'Hugging Face' to a local folder, to be used in
e.g.
[get_embeddings](https://cjvanlissa.github.io/theorytools/reference/get_embeddings.md).

## Usage

``` r
download_huggingface(model, path, ...)
```

## Arguments

- model:

  Atomic character, referencing a model - typically of the form
  `"user/model"`.

- path:

  Atomic character, referencing a local folder where the model is
  installed.

- ...:

  Arguments passed to and from functions.

## Value

On succes: Atomic character, with the path to the local model. On
failure: `NULL`.

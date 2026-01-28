# Create a webexercises vignette

Wraps
[use_vignette](https://usethis.r-lib.org/reference/use_vignette.html) to
add a vignette or article to `vignettes/` with support for
`webexercises`.

## Usage

``` r
use_webex_vignette(name, title = NULL, type = c("vignette", "article"))
```

## Arguments

- name:

  Atomic character, vignette name. See
  [use_vignette](https://usethis.r-lib.org/reference/use_vignette.html).

- title:

  Atomic character, vignette title. See
  [use_vignette](https://usethis.r-lib.org/reference/use_vignette.html).

- type:

  Atomic character, one of `c("vignette", "article")`, defaults to
  `"vignette"`.

## Value

Returns `NULL` invisibly, called for its side effects.

## Examples

``` r
if (FALSE) { # \dontrun{
use_webex_vignette("vignette_with_quiz.Rmd", "Quiz people with webexercises")
} # }
```

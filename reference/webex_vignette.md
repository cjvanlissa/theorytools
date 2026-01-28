# Create Vignette with webexercises Support

This function wraps
[`rmarkdown::html_document`](https://pkgs.rstudio.com/rmarkdown/reference/html_document.html)
to configure compilation to embed the default webexercises CSS and
JavaScript files in the resulting HTML.

## Usage

``` r
webex_vignette(...)
```

## Arguments

- ...:

  Additional function arguments to pass to
  [`html_document`](https://pkgs.rstudio.com/rmarkdown/reference/html_document.html).

## Value

R Markdown output format to pass to 'render'.

## Details

Call this function as the `output_format` argument for the
[`render`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
function when compiling HTML documents from RMarkdown source.

## See also

[`render`](https://pkgs.rstudio.com/rmarkdown/reference/render.html),
[`html_document`](https://pkgs.rstudio.com/rmarkdown/reference/html_document.html)

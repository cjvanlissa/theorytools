# Download FAIR Theory

Downloads a FAIR theory archive from a 'Git' remote repository or
'Zenodo'.

## Usage

``` r
download_theory(id, path = ".")
```

## Arguments

- id:

  URL of the 'Git' repository or DOI of the 'Zenodo' archive.

- path:

  Character, indicating the directory in which to create the FAIR
  theory.

## Examples

``` r
download_theory(id = "https://github.com/cjvanlissa/tripartite_model.git",
path = file.path(tempdir(), "tripartite_git"))
download_theory(id = "10.5281/zenodo.14921521",
path = file.path(tempdir(), "tripartite_zenodo"))
```

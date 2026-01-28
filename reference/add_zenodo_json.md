# Add 'Zenodo' JSON File

Writes a '.zenodo.json' file to the specified path.

Writes a README file to a specific path.

## Usage

``` r
add_zenodo_json(path, title, upload_type, keywords)

add_zenodo_json_theory(path, title, keywords)
```

## Arguments

- path:

  Character, indicating the directory in which to create the FAIR
  theory.

- title:

  Character, indicating the theory title. Default: `NULL`

- upload_type:

  Character, indicating the upload type.

- keywords:

  Character vector of keywords.

## Value

Invisibly returns a logical value, indicating whether the function was
successful or not.

## See also

[`read_json`](https://jeroen.r-universe.dev/jsonlite/reference/read_json.html)

## Examples

``` r
add_zenodo_json(path = tempdir(), title = "Theory Title",
                upload_type = "software", keywords = "R")
add_zenodo_json_theory(path = tempdir(), title = "My Theory",
                       keywords = "secondkeyword")
add_zenodo_json_theory(path = tempdir(), title = "My Theory",
                       keywords = c("secondkeyword", "thirdkeyword"))
```

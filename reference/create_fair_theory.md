# Create FAIR Theory Repository

Partly automates the process of creating a FAIR theory repository, see
Details.

## Usage

``` r
create_fair_theory(
  path,
  title = NULL,
  theory_file = NULL,
  remote_repo = NULL,
  add_license = "cc0",
  ...
)
```

## Arguments

- path:

  Character, indicating the directory in which to create the FAIR
  theory.

- title:

  Character, indicating the theory title. Default: `NULL`

- theory_file:

  Character, referring to existing theory file(s) to be copied, or a new
  theory file to be created. Default `NULL` does nothing.

- remote_repo:

  Name of a 'GitHub' repository that exists or should be created on the
  current authenticated user's account, see
  [`gh_whoami`](https://gh.r-lib.org/reference/gh_whoami.html), Default:
  NULL

- add_license:

  PARAM_DESCRIPTION, Default: 'cc0'

- ...:

  Additional arguments passed to other functions.

## Value

Invisibly returns a logical value, indicating whether the function was
successful or not.

## Details

The following steps are executed sequentially:

1.  Create a project folder at `path`

2.  Initialize a local 'Git' repository at `path`

3.  If `remote_repo` refers to a user's existing 'GitHub' repository,
    add it as remote to the local 'Git' repository. Otherwise, create a
    new 'GitHub' repository by that name and add it as remote.

4.  Add theory file. If `theory_file` refers to an existing file, copy
    it to `path`. If `theory_file` refers to a new file, create it in
    `path`.

5.  Add the license named by `add_license`

6.  Add a README.md file

7.  Add 'Zenodo' metadata so that it recognizes the repository as a FAIR
    theory

8.  If it is possible to push to the remote repository, use
    [`git_update`](https://cjvanlissa.github.io/worcs/reference/git_update.html)
    to push the repository to 'GitHub'

## See also

[`git_repo`](https://docs.ropensci.org/gert/reference/git_repo.html)
[`add_license_file`](https://cjvanlissa.github.io/worcs/reference/add_license_file.html),
[`git_update`](https://cjvanlissa.github.io/worcs/reference/git_update.html)

## Examples

``` r
# Create a theory with no remote repository (for safe testing)
theory_dir <- file.path(tempdir(), "theory")
create_fair_theory(path = theory_dir,
                   title = "This is My Theory",
                   theory_file = "theory.txt",
                   remote_repo = NULL,
                   add_license = "cc0")

# Create a theory with a remote repository
if (FALSE) { # \dontrun{
theory_dir <- file.path(tempdir(), "theory_github")
out <- create_fair_theory(path = theory_dir,
                          title = "This is My GitHub Theory",
                          theory_file = "theory.txt",
                          remote_repo = "delete_test",
                          add_license = "ccby")
} # }
```

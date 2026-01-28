# These functions are better placed in worcs:
#' @importFrom utils getFromNamespace
with_cli_try <- utils::getFromNamespace("with_cli_try", "worcs")
cli_msg <- utils::getFromNamespace("cli_msg", "worcs")
is_quiet <- utils::getFromNamespace("is_quiet", "worcs")
git_connect_or_create <- utils::getFromNamespace("git_connect_or_create", "worcs")

#' @title Create FAIR Theory Repository
#' @description Partly automates the process of creating a FAIR theory
#' repository, see Details.
#' @param path Character, indicating the directory in which to create the FAIR
#' theory.
#' @param title Character, indicating the theory title. Default: `NULL`
#' @param theory_file Character, referring to existing theory file(s) to be
#' copied, or a new theory file to be created. Default `NULL` does nothing.
#' @param remote_repo Name of a 'GitHub' repository that exists or should be
#' created on the current authenticated user's account, see
#' \code{\link[gh]{gh_whoami}}, Default: NULL
#' @param add_license PARAM_DESCRIPTION, Default: 'cc0'
#' @param ... Additional arguments passed to other functions.
#' @return Invisibly returns a logical value,
#' indicating whether the function was successful or not.
#' @details The following steps are executed sequentially:
#'
#' 1. Create a project folder at `path`
#' 2. Initialize a local 'Git' repository at `path`
#' 3. If `remote_repo` refers to a user's existing 'GitHub' repository, add it
#'    as remote to the local 'Git' repository. Otherwise, create a new 'GitHub'
#'    repository by that name and add it as remote.
#' 4. Add theory file. If `theory_file` refers to an existing file, copy it to
#'    `path`. If `theory_file` refers to a new file, create it in `path`.
#' 5. Add the license named by `add_license`
#' 6. Add a README.md file
#' 7. Add 'Zenodo' metadata so that it recognizes the repository as a FAIR
#'    theory
#' 8. If it is possible to push to the remote repository, use
#'    \code{\link[worcs]{git_update}} to push the repository to 'GitHub'
#' @examples
#' # Create a theory with no remote repository (for safe testing)
#' theory_dir <- file.path(tempdir(), "theory")
#' create_fair_theory(path = theory_dir,
#'                    title = "This is My Theory",
#'                    theory_file = "theory.txt",
#'                    remote_repo = NULL,
#'                    add_license = "cc0")
#'
#' # Create a theory with a remote repository
#' \dontrun{
#' theory_dir <- file.path(tempdir(), "theory_github")
#' out <- create_fair_theory(path = theory_dir,
#'                           title = "This is My GitHub Theory",
#'                           theory_file = "theory.txt",
#'                           remote_repo = "delete_test",
#'                           add_license = "ccby")
#' }
#' @seealso
#'  \code{\link[gert]{git_repo}}
#'  \code{\link[worcs]{add_license_file}}, \code{\link[worcs]{git_update}}
#' @rdname create_fair_theory
#' @export
#' @importFrom gert git_init
#' @importFrom worcs add_license_file git_update
create_fair_theory <- function(path,
                            title = NULL,
                            theory_file = NULL,
                            remote_repo = NULL,
                            add_license = "cc0",
                            ...) {
  successes <- rep(TRUE, 8)
  names(successes) <- c("folder", "git", "remote", "theory", "license", "readme", "zenodo", "push")
  # Clean arguments
  if (is.null(add_license))
    add_license = "none"
  add_license <- tryCatch(
    add_license[1],
    error = function(e) {
      "none"
    }
  )

  # 1. Create project folder
  successes["folder"] <- with_cli_try("Create project folder", {
    if (!dir.exists(path)) {
      dir.create(path)
    }
  })

  # 2. Initialize Git repo
  successes["git"] <- with_cli_try("Initialize 'Git' repository", {
    gert::git_init(path = path)
  })


# Connect remote repo -----------------------------------------------------
  if(!is.null(remote_repo)){
    repo_properties <- git_connect_or_create(path, remote_repo)
    repo_url <- repo_properties$repo_url
    repo_exists <- repo_properties$repo_exists
    prior_commits <- repo_properties$prior_commits
    successes["remote"] <- repo_exists
  } else {
    repo_url <- ""
    repo_exists <- FALSE
    prior_commits <- FALSE
  }

# Add theory file ---------------------------------------------------------
  has_theory_file <- !is.null(theory_file)
  if (has_theory_file) {
    successes["theory"] <- add_theory_file(path = path, theory_file = theory_file)
  }

  # 1. Add LICENSE file
  if (!add_license == "none") {
    dots <- list(...)
    dots <- dots[which(names(dots) %in% c("version", "include_future", "copyright_holder"))]
    Args <- c(list(path = path, license = add_license), dots)
    successes["license"] <- do.call(worcs::add_license_file, args = Args)
  }

  # 1. Add readme.md
  successes["readme"] <- add_readme_fair_theory(path = path, title = title, repo_url = repo_url, repo_exists = repo_exists)

# Add Zenodo metadata -----------------------------------------------------
  successes["zenodo"] <- add_zenodo_json(path,
                                         title = paste0("FAIR theory: ", title),
                                         upload_type = "model",
                                         keywords = "fairtheory")


# Push local repo to remote -----------------------------------------------

  if(repo_exists & isFALSE(prior_commits)){
    worcs::git_update(message = "Initial commit", repo = path, files = ".")
    successes["push"] <- TRUE
  }

# Output ------------------------------------------------------------------
  return(invisible(all(successes)))
}

#' @title Add Readme File
#' @description Writes a README file to a specific path.
#' @inheritParams create_fair_theory
#' @inherit create_fair_theory return
#' @examples
#' add_readme_fair_theory(path = tempdir(), title = "My Theory")
#' @rdname add_readme_fair_theory
#' @export
add_readme_fair_theory <- function(path, title, ...){
  dots <- list(...)
  if(!all(c("test_repo", "repo_exists") %in% names(dots))){
    repo_url <- try(gert::git_remote_list(repo = path)$url[1], silent = TRUE)
    repo_exists <- isFALSE(inherits(repo_url, "try-error"))
  } else {
    repo_url <- dots[["repo_url"]]
    repo_exists <- dots[["repo_exists"]]
  }

  with_cli_try("Creating README.md", {
    lines_readme <- c(
      "# FAIR theory: Theory Title Goes Here",
      "",
      "# Description",
      "",
      "This is a FAIR theory, see Van Lissa et al., in preparation.",
      "",
      "# Interoperability",
      "",
      "Explain what the theory can be reused for, and how.",
      "",
      "# Contributing",
      "",
      "If you want to contribute to this project, please get involved. You can do so in three ways:",
      "",
      "1. **To discuss the current implementation and discuss potential changes**, file a 'GitHub' issue",
      "2. **To directly propose changes**, send a pull request containing the proposed changes",
      "3. **To create a derivative theory**, please fork the repository",
      "",
      "If you fork the repository, please cite this repository (see below), and add it as a related work (below and by adding the appropriate metadata on 'Zenodo').",
      "",
      "By participating in this project, you agree to abide by the [Contributor Covenant](https://www.contributor-covenant.org/version/2/0/code_of_conduct.html).",
      "",
      "## Related works",
      "",
      "Optionally, cite the canonical reference for the theory implemented in this repository here. This is redundant with adding the cross-reference in 'Zenodo', but may be useful nonetheless.",
      "",
      "## Citing this work",
      "",
      "See this project's 'Zenodo' page for the preferred citation."
    )
    if(!is.null(title)) lines_readme[1] <- gsub("Theory Title Goes Here", title, lines_readme[1], fixed = TRUE)
    if (repo_exists) {
      lines_readme[15:17] <- paste0(lines_readme[15:17],
                                    " [here](",
                                    gsub(".git", "", repo_url, fixed = TRUE),
                                    c("/issues)", "/pulls)", "/fork)"))
    }
    writeLines(lines_readme, file.path(path, "README.md"))

  })
}

#' @title Add Theory File
#' @description Writes a theory file to a specific path.
#' @inheritParams create_fair_theory
#' @inherit create_fair_theory return
#' @examples
#' add_theory_file(path = tempdir(), theory_file = "theory.txt")
#' @rdname add_theory_file
#' @export
add_theory_file <- function(path, theory_file = "theory.txt"){
  if(length(theory_file) > 1){
    out <- sapply(theory_file, function(x){ add_theory_file(path = path, theory_file = x) })
    return(invisible(all(out)))
  }
  if(!dir.exists(path)) stop("Path does not exist.")
  existing_theory_file <- file.exists(theory_file)
  if (existing_theory_file) {
    with_cli_try("Copying theory file {.val {theory_file}}", {
      out <- file.copy(normalizePath(theory_file), file.path(path, basename(theory_file)))
      if (!out) stop()
    })
  } else {
    with_cli_try("Creating new theory file {.val {theory_file}}", {
      file.create(file.path(path, theory_file))
    })
  }
  return(invisible(file.exists(file.path(path, basename(theory_file)))))
}

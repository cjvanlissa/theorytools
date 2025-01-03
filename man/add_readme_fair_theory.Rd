% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_fair_theory.R
\name{add_readme_fair_theory}
\alias{add_readme_fair_theory}
\title{Add Readme File}
\usage{
add_readme_fair_theory(title, path, ...)
}
\arguments{
\item{title}{Character, indicating the theory title. Default: \code{NULL}}

\item{path}{Character, indicating the directory in which to create the FAIR
theory. The default value \code{"."} points to the current directory.}

\item{...}{Additional arguments passed to other functions.}
}
\value{
Invisibly returns a logical value,
indicating whether the function was successful or not.
}
\description{
Writes a README file to a specific path.
}
\examples{
add_readme_fair_theory(title = "My Theory", path = tempdir())
}

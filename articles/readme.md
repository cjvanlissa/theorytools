# What to Include in a README?

A README file will often be the first point of contact for users of any
project, including FAIR theories. It should contain all information
people need to get started with using your FAIR theory. A README is a
basic form of documentation with directions on how to use a FAIR theory.
It serves as a guide for others to understand, evaluate, and build upon
your work. A comprehensive and clear README file is essential for making
your FAIR theory accessible and reusable.

Below, we outline the key sections to include in a README file for a
FAIR theory:

### 1. Title

Provide a clear title for your theory. We recommend prefacing the title
with the words `FAIR theory:`, just like a systematic review should have
the words `systematic review` in the title, to help sentient readers
immediately identify it as such.

### 2. Description

Provide a plain-text description of the theory and its scope. This could
be a one- to two-sentence summary of what the theory explains or
predicts, and the context or field of study where the theory applies.

### 3. Interoperability

Most README files contain a section labeled “Getting Started”,
“Instructions for Use”, or “How to Use”. From a FAIR perspective, such a
section might be better labeled “Interoperability”. We propose using
this section to explicitly address the theory’s X-interoperability,
telling users exactly what they can use the theory for, and how.

> **X-interoperability:** Tells you what you can do with a theory, and
> how.

### 4. Contributing

Pertaining to the Reusability criterion of the FAIR principles, this
section should tell users the *social expectations regarding reuse and
contributions*.

### 5. License

The legal complement to the preceding *Contributing* section, this
section should refer readers to the LICENSE file to learn about the
*legal conditions of reuse*.

### 6. Citing this Work

Tell users how to cite the theory. Note that this section is redundant
with the Zenodo archive, which has a preferred citation field. The
disadvantage of redundant information is that you may have to maintain
this section of the README going forward. The advantage is that
documenting related works in the README makes it more readily accessible
to users. We suggest a compromise: retain this section, but use it to
direct the reader to the preferred citation on the Zenodo page.

### 7. Related Works

This section should refer to the work that the FAIR theory is derived
from, or documented in. Again, this is redundant with metadata entered
in Zenodo. We nevertheless recommend using this section to direct the
reader to Zenodo, and optionally, to document one canonical reference
for the theory that is unlikely to change going forward.

## Example: The Empirical Cycle

Below, we break down the README file of our implementation of De Groot’s
empirical cycle as a FAIR theory:

The title is prefaced with `FAIR theory`:

    # FAIR theory: The Empirical Cycle

The description gives further information about the theory and its
scope:

    ## Description

    This is a FAIR implementation of De Groot and Spiekerman's "empirical cycle" theory, a theory of cumulative knowledge acquisition through scientific research.

The Interoperability section tells readers how the theory is
implemented, and in which ways it can be reused:

    ## Interoperability

    The theory is implemented in the DOT language for describing graphs.

    ### Rendering the theory using graphviz

    See the graphviz manual for more information: https://graphviz.org

There are specific instructions on how to contribute to the project:

    ## Contributing

    If you want to contribute to this project, please get involved. You can do so in three ways:

    1. **To discuss the current implementation and discuss potential changes**, file a ‘GitHub’ issue [here](https://github.com/cjvanlissa/empirical_cycle/issues)
    2. **To directly propose changes**, send a pull request containing the proposed changes [here](https://github.com/cjvanlissa/tidySEM/pulls)
    3. **To create a derivative theory**, please fork the repository [here](https://github.com/cjvanlissa/empirical_cycle/fork). Please cite this repository (see below), and add this repository as a related work (below and by adding the appropriate metadata on Zenodo).

    By participating in this project, you agree to abide by the [Contributor
    Covenant](https://www.contributor-covenant.org/version/2/0/code_of_conduct.html).

The Related Works section gives one canonical reference, and directs
readers to Zenodo:

    ## Related Works

    See this project's Zenodo page for cross-references to related work. 

    This repository contains an implementation of the "empirical cycle", a model proposed by De Groot and Spiekerman (1969, p. 28)

    > De Groot, A. D., & Spiekerman, J. A. A. (1969). Methodology: Foundations of inference and research in the behavioral sciences. De Gruyter Mouton. https://doi.org/10.1515/9783112313121

The preferred citation section only directs readers to Zenodo to prevent
redundancy:

    ## Citing this work

    See [this project's Zenodo page](https://doi.org/10.5281/zenodo.14552329) for the preferred citation.

### Complete Readme

The complete resulting readme.MD is shown below (click to expand).

``` r
# FAIR theory: The Empirical Cycle

## Description

This is a FAIR implementation of De Groot and Spiekerman's "empirical cycle"
theory, a theory of cumulative knowledge acquisition through scientific
research.

## Interoperability

The theory is implemented in the DOT language for describing graphs.

### Rendering the theory using graphviz

See the graphviz manual for more information: https://graphviz.org

## Contributing

If you want to contribute to this project, please get involved. You can do so in
three ways:

1. **To discuss the current implementation and discuss potential changes**, file
a ‘GitHub’ issue [here](https://github.com/cjvanlissa/empirical_cycle/issues)
2. **To directly propose changes**, send a pull request containing the proposed
changes [here](https://github.com/cjvanlissa/tidySEM/pulls)
3. **To create a derivative theory**, please fork the repository
[here](https://github.com/cjvanlissa/empirical_cycle/fork). Please cite this
repository (see below), and add this repository as a related work (below and by
adding the appropriate metadata on Zenodo).

By participating in this project, you agree to abide by the [Contributor
Covenant](https://www.contributor-covenant.org/version/2/0/code_of_conduct.html).

## Related Works

See this project's Zenodo page for cross-references to related work. 

This repository contains an implementation of the "empirical cycle", a model
proposed by De Groot and Spiekerman (1969, p. 28)

> De Groot, A. D., & Spiekerman, J. A. A. (1969). Methodology: Foundations of
> inference and research in the behavioral sciences. De Gruyter Mouton.
> https://doi.org/10.1515/9783112313121

## Citing this work

See [this project's Zenodo page](https://doi.org/10.5281/zenodo.14552329) for
the preferred citation.
```

By including these sections, your README file will serve as a robust
guide for understanding, using, and extending your FAIR theory, ensuring
its accessibility and reusability for diverse audiences.

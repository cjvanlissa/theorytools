# Synthetic Data: Longitudinal Study of Australian Children

This synthetic dataset, based on "Growing Up in Australia - the
Longitudinal Study of Australian Children" (LSAC). This longitudinal
study covers a representative sample of about 10.000 children and their
families, and aims to examine children's development from early
childhood through to adolescence and adulthood. All variables pertain to
the mother; note that fathers also play an important and sometimes
unique role in children's emotional development.

## Usage

``` r
data(lsac)
```

## Format

A data frame with 8214 rows and 6 variables.

## Details

Except for "coping", all variables were created by taking the row means
of several items, omitting missing values. The corresponding item names
from the LSAC codebook are given below.

|                          |           |                     |                                     |
|--------------------------|-----------|---------------------|-------------------------------------|
| **warmth**               | `numeric` | `fpa03m1-fpa03m6`   | Parental warmth scale               |
| **relationship_quality** | `numeric` | `fre04m1-fre04m7`   | Hendrick relationship quality scale |
| **temperament_negreact** | `numeric` | `fse13a1-fse13a4`   | Temperament scale for reactivity    |
| **emotion_regulation**   | `numeric` | `fse03c3a-fse03c3e` | SDQ Emotional problems scale        |
| **social_functioning**   | `numeric` | `fgd04b2a-fgd04b2e` | Peds QL social functioning          |
| **coping**               | `numeric` | `fhs26m2`           | Level of coping                     |

## References

Australian Institute of Family Studies. (2020, March 23). Growing Up in
Australia.

# Typologizing Economic Return Pathways of Injured Workers
### Focusing on Income Recovery Rate and Latent Growth Modeling

> 11th PSWCI Academic Conference · Son Danha · Heo Jaehee · Hwang Sahyun · [🇰🇷 한국어](README_KO.md)

## Overview
We constructed a **Real Income Recovery Index (RIRI)** benchmarked against the living wage and identified 4 heterogeneous trajectories via **LCGA**. Using SHAP, PSM, and policy simulation, we empirically demonstrate the limitations of current rehabilitation services and propose data-driven alternatives.

$$RIRI_w = \frac{Q_{irr,w} \times W_{pre}}{LW_w} \times \frac{CPI_{pre}}{CPI_w} \times 100$$

## Key Findings
- Injury severity **does not** determine recovery trajectories (SHAP rank 6)
- **Age, health, and psychological state** are the real determinants
- Women are **92% less likely** to reach the stably high-income group (p<.001)
- **93%+** of Groups 1 & 2 fall below the OECD poverty line
- Only **social rehabilitation for the chronically unrecovered** showed significant effect (ATT=+3.12, p=.028)

## Trajectories (k=4, Entropy=0.905)

| Group | Label | n | % |
|--|--|--|--|
| 1 | Chronically Unrecovered | 702 | 27.6% |
| 2 | Declining Vulnerable | 352 | 13.8% |
| 3 | Partially Recovered | 897 | 35.3% |
| 4 | Stably High-Income | 591 | 23.3% |

## Stack
`Python 3.12` · `R 4.x` · pandas · scikit-learn · shap · lcmm

## Data
[Korea Workers' Compensation & Welfare Service](https://pswci.kcomwel.or.kr) — raw data not included.

<div align="center"><sub>11th PSWCI Academic Conference · 2026</sub></div>

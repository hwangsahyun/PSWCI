### Typology and Determinants of Economic Recovery Trajectories among Industrially Injured Workers

<sub>Focusing on the Income Recovery Rate and Latent Growth Modelling</sub>  
<sub>**Sahyun Hwang** (first author) · Jaehee Hur · Danha Son</sub>  
<sub>Selected for the poster session, 11th PSWCI Academic Conference (2026) · [🇰🇷 한국어](README_KO.md)</sub>

#### Overview

<sub>Studies of injured workers usually rely on employment status alone, which hides heterogeneity in long-term income. We construct a **Real Income Recovery Index (RIRI)** benchmarked against the Seoul living wage, classify recovery trajectories with **LCGA**, and examine their determinants and the group-specific effects of rehabilitation services.</sub>

$$RIRI_w = \frac{Q_{irr,w} \times W_{pre}}{LW_w} \times \frac{CPI_{pre}}{CPI_w} \times 100$$

<sub>$Q_{irr,w}$: income-substitution quality weight · $W_{pre}$: pre-injury monthly income · $LW_w$: Seoul living wage · RIRI = 100 means full recovery to the living-wage level</sub>

#### Methods

<sub>LCGA (k = 4) · BCH-corrected multinomial logistic regression · SHAP · Propensity score matching · OECD poverty line and minimum wage as external benchmarks</sub>

#### Trajectories
<sub>* k = 4, entropy = 0.905</sub>

| Group | Trajectory | % |
|---|---|---|
| 1 | Chronic poverty | 27.6 |
| 2 | Declining | 13.8 |
| 3 | Partial recovery | 35.3 |
| 4 | Stable high income | 23.2 |

#### Key Findings

- <sub>93.6% (Group 1) and 92.9% (Group 2) remained below the OECD poverty line</sub>
- <sub>Age, subjective health and psychological state were the main determinants; disability grade ranked 6th in SHAP importance</sub>
- <sub>Three health and psychological variables alone identified vulnerable workers (AUC = 0.711)</sub>
- <sub>Women were 92% less likely than men to enter the stable high-income group (p < .001)</sub>
- <sub>Of 16 group × service combinations, only social rehabilitation for the chronic-poverty group showed a significant effect (ATT = +3.12, p = .028)</sub>

#### Stack
![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)
![R](https://img.shields.io/badge/R-276DC3?style=flat-square&logo=r&logoColor=white)

<sub>pandas · scikit-learn · shap · lcmm</sub>

#### Data
<sub>Panel Study of Workers' Compensation Insurance, 2nd cohort, waves 1–5 (2018–2022), [Korea Workers' Compensation & Welfare Service](https://pswci.kcomwel.or.kr). Raw data are not included in this repository.</sub>

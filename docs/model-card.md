# Model card

## Model type

Three-factor confirmatory factor analysis followed by a latent-variable structural equation model estimated in `lavaan` with robust maximum likelihood and full-information maximum likelihood for missing indicators.

## Intended purpose

Demonstrate a reproducible SEM workflow that integrates measurement validation, group comparability, structural paths, indirect effects, and diagnostics.

## Intended users

- Quantitative researchers and evaluation analysts
- Measurement and assessment teams
- Applied data scientists reviewing latent-variable methods

## Data

All 2,400 observations are synthetic. The constructs, indicators, groups, and outcome are generated specifically for this portfolio demonstration. No real person or institution is represented.

## Constructs

- Support: four continuous indicators
- Engagement: four continuous indicators
- Academic confidence: three continuous indicators
- Follow-up achievement: one observed continuous outcome

## Group analysis

Measurement invariance is evaluated across middle- and high-school groups. Passing scalar invariance in a synthetic benchmark demonstrates the workflow; it does not guarantee that a real instrument would be invariant across age, language, disability, race/ethnicity, culture, administration mode, or time.

## Missing data

The workflow uses FIML under a missing-at-random assumption conditional on included variables. That assumption cannot be proven from observed data. Real analyses should describe missingness, add relevant auxiliary variables where justified, and perform sensitivity analyses.

## Limitations

- Synthetic fit cannot establish real-world validity.
- Global fit does not prove the proposed model is uniquely correct.
- Latent variables remain dependent on the content and quality of their indicators.
- Indirect effects are statistical decompositions, not automatically mechanisms.
- The model does not account for school-level clustering in the reference specification.
- The design does not identify causal effects.

## Appropriate extensions

Real applications may require multilevel SEM, longitudinal invariance, categorical-indicator estimators, survey weights, complex sampling corrections, preregistered alternative models, or external validation.

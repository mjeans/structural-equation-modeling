# Analysis plan

## Objective

Evaluate a prespecified three-factor measurement model and estimate structural associations among support, engagement, academic confidence, and follow-up achievement in synthetic student data.

## Sample

The generator produces 2,400 records split evenly between middle- and high-school groups. Eleven continuous survey indicators use a 1–5 bounded response scale. Missingness is introduced as a modest function of baseline performance and grade band so the workflow can demonstrate full-information maximum likelihood.

## Measurement sequence

1. Fit the pooled three-factor CFA.
2. Review robust CFI, TLI, RMSEA with confidence interval, and SRMR.
3. Inspect standardized loadings, composite reliability, and average variance extracted.
4. Fit configural invariance across grade bands.
5. Constrain loadings for metric invariance.
6. Constrain loadings and intercepts for scalar invariance.
7. Evaluate changes in CFI and RMSEA alongside absolute fit.

The prespecified practical thresholds are |ΔCFI| ≤ 0.010 and ΔRMSEA ≤ 0.015. These are decision aids, not universal laws. Substantive judgment and parameter-level diagnostics remain necessary.

## Structural sequence

After establishing acceptable measurement behavior, estimate the prespecified structural model using robust maximum likelihood and FIML. Report:

- unstandardized and fully standardized paths
- model-based standard errors and confidence intervals
- specific indirect effects
- the serial indirect effect
- total indirect and total associations
- R² for endogenous variables
- global fit indices

## Diagnostics

Check convergence, residual variances, standardized loadings, large modification indices, and missingness. Modification indices are diagnostic signals only; they do not authorize post hoc model changes without theoretical justification and independent validation.

## Interpretation

No structural coefficient will be described as causal. The synthetic design is useful for demonstrating estimation and reporting, not for identifying an intervention effect.

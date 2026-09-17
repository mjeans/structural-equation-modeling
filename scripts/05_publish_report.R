suppressPackageStartupMessages(library(lavaan))
source("R/portfolio_report.R")
measurement <- readRDS("artifacts/measurement_models.rds")$pooled_cfa
structural <- readRDS("artifacts/structural_model.rds")
interval_table <- function(fit, operator) {
  s <- standardizedSolution(fit, type = "std.all", se = TRUE, ci = TRUE)
  s[s$op == operator, c("lhs", "rhs", "est.std", "se", "ci.lower", "ci.upper")]
}
loadings <- interval_table(measurement, "=~")
paths <- interval_table(structural, "~")
stopifnot(nrow(loadings) == 11L,
          all(is.finite(loadings$se)), all(loadings$ci.lower < loadings$est.std),
          all(paths$ci.lower < paths$est.std), all(paths$ci.upper > paths$est.std))
write.csv(loadings, "outputs/standardized_loading_intervals.csv", row.names = FALSE)
write.csv(paths, "outputs/standardized_path_intervals.csv", row.names = FALSE)
forest <- function(data, title, axis) {
  labels <- if (axis == "Standardized factor loading") paste(data$lhs, ":", data$rhs) else paste(data$lhs, "<-", data$rhs)
  data$label <- factor(labels, levels = rev(labels))
  ggplot(data, aes(est.std, label)) +
    geom_vline(xintercept = 0, color = "#687b89", linetype = 2) +
    geom_segment(aes(x = ci.lower, xend = ci.upper, yend = label), color = "#087e83", linewidth = .8) +
    geom_point(color = "#087e83", size = 2.7) +
    labs(title = title, subtitle = "Synthetic data; robust model-based 95% Wald intervals on the standardized scale",
         x = axis, y = NULL, caption = "Intervals use standardizedSolution SEs, not unstandardized SEs attached to standardized coefficients.")
}
publish_plot(forest(loadings, "Measurement before structure", "Standardized factor loading"),
             "assets/loading-intervals.svg", "Standardized factor loadings",
             "Eleven standardized loadings with matching standardized-scale model-based confidence intervals.", width = 12, height = 7)
publish_plot(forest(paths, "Adjusted structural associations", "Standardized path coefficient"),
             "assets/path-intervals.svg", "Standardized structural paths",
             "Conditional associations and 95 percent model-based intervals, not causal effects.", width = 12, height = 7)
fits <- rbind(read.csv("outputs/cfa_fit_indices.csv"), read.csv("outputs/sem_fit_indices.csv"))
write_research_report(c("# Executed measurement and structural-model report", "",
  "## Question and population", "",
  "Do 11 continuous survey indicators recover support, engagement, and confidence, and how are these latent constructs associated with later achievement? The 2,400 records are synthetic; the generating structure is known. Robust maximum likelihood with FIML handles incomplete continuous indicators under the modeled missing-at-random assumptions.", "",
  "## Measurement evidence", "", md_table(fits[, c("model", "cfi", "tli", "rmsea", "srmr")]), "",
  "![Standardized loading estimates and intervals](../assets/loading-intervals.svg)", "",
  md_table(loadings), "", "### Group comparability", "", md_table(read.csv("outputs/measurement_invariance.csv")), "",
  "[Composite reliability](reliability.csv) and [indicator missingness](missingness_summary.csv). Excellent fit is expected under the data-generating model, not a promise of comparable real-data fit.", "",
  "## Structural associations", "", "![Standardized paths and uncertainty](../assets/path-intervals.svg)", "", md_table(paths), "",
  "### Indirect associations (unstandardized scale)", "", md_table(read.csv("outputs/indirect_effects.csv")[, c("lhs", "est", "se", "ci.lower", "ci.upper")]), "",
  "The indirect-effect table uses unstandardized estimates and matching unstandardized intervals. The plots use standardizedSolution estimates and corresponding standardized-scale SEs. Neither uses bootstrap intervals.", "",
  "## Diagnostics and limitations", "",
  "Fully observed baseline and binary grade covariates are treated as fixed (fixed.x = TRUE). The prior specification estimated their moments and produced a near-zero robust covariance direction concentrated on the exactly balanced binary grade variance. Conditioning on these observed covariates removes that redundant direction; structural point estimates changed by less than 0.000001 in the diagnostic comparison. Tests now require a positive-definite parameter covariance. Missing exogenous covariates fail explicitly rather than silently dropping cases.", "",
  "[Residual variances](residual_variances.csv), [modification indices](modification_indices.csv), and [explained variance](r_squared.csv) remain available for review. Suggested modifications do not automatically change the model. Model fit cannot establish causal identification, temporal ordering of latent constructs, absence of confounding, or real-world measurement validity. FIML does not solve missing-not-at-random bias."))

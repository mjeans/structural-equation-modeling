suppressPackageStartupMessages(library(lavaan))

source("config/model_spec.R")
source("R/data_generation.R")
source("R/sem_helpers.R")

test_data_one <- generate_sem_data(n = 1200L, seed = sem_config$seed)
test_data_two <- generate_sem_data(n = 1200L, seed = sem_config$seed)

stopifnot(identical(test_data_one, test_data_two))
stopifnot(nrow(test_data_one) == 1200L)
stopifnot(all(table(test_data_one$grade_band) == 600L))
stopifnot(all(test_data_one$high_school %in% c(0L, 1L)))
stopifnot(all(vapply(
  test_data_one[measurement_items],
  function(x) all(x[!is.na(x)] >= 1 & x[!is.na(x)] <= 5),
  logical(1)
)))

pooled_fit <- cfa(
  measurement_model,
  data = test_data_one,
  estimator = "MLR",
  missing = "fiml",
  meanstructure = TRUE,
  std.lv = TRUE
)
stopifnot(lavInspect(pooled_fit, "converged"))
stopifnot(fitMeasures(pooled_fit, "cfi.scaled") > 0.95)
stopifnot(fitMeasures(pooled_fit, "rmsea.scaled") < 0.06)
stopifnot(all(standardized_loadings(pooled_fit)$std.all > 0.50))
stopifnot(all(composite_reliability(pooled_fit)$composite_reliability > 0.75))

configural_fit <- cfa(
  measurement_model,
  data = test_data_one,
  group = "grade_band",
  estimator = "MLR",
  missing = "fiml",
  meanstructure = TRUE,
  std.lv = TRUE
)
metric_fit <- cfa(
  measurement_model,
  data = test_data_one,
  group = "grade_band",
  group.equal = "loadings",
  estimator = "MLR",
  missing = "fiml",
  meanstructure = TRUE,
  std.lv = TRUE
)
scalar_fit <- cfa(
  measurement_model,
  data = test_data_one,
  group = "grade_band",
  group.equal = c("loadings", "intercepts"),
  estimator = "MLR",
  missing = "fiml",
  meanstructure = TRUE,
  std.lv = TRUE
)
invariance <- measurement_invariance_table(configural_fit, metric_fit, scalar_fit)
stopifnot(abs(invariance$delta_cfi[invariance$model == "metric"]) < 0.02)
stopifnot(abs(invariance$delta_cfi[invariance$model == "scalar"]) < 0.02)

sem_fit <- sem(
  structural_model,
  data = test_data_one,
  estimator = "MLR",
  missing = "fiml",
  meanstructure = TRUE,
  std.lv = TRUE,
  fixed.x = FALSE
)
stopifnot(lavInspect(sem_fit, "converged"))
stopifnot(fitMeasures(sem_fit, "cfi.scaled") > 0.95)
stopifnot(fitMeasures(sem_fit, "rmsea.scaled") < 0.06)

estimates <- parameterEstimates(sem_fit)
serial <- estimates[
  estimates$op == ":=" & estimates$lhs == "support_to_outcome_serial",
]
stopifnot(nrow(serial) == 1L)
stopifnot(serial$est > 0)
stopifnot(serial$pvalue < 0.05)

diagnostics <- model_diagnostics(sem_fit)
stopifnot(!any(diagnostics$residual_variances$negative_variance))

cat("All structural-equation-modeling pipeline checks passed.\n")

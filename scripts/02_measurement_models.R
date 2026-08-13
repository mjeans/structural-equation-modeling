suppressPackageStartupMessages(library(lavaan))

source("config/model_spec.R")
source("R/sem_helpers.R")

dir.create("artifacts", showWarnings = FALSE, recursive = TRUE)
dir.create("outputs", showWarnings = FALSE, recursive = TRUE)

sem_data <- read.csv(
  "data/synthetic_student_engagement.csv",
  stringsAsFactors = FALSE,
  na.strings = c("", "NA")
)
sem_data$grade_band <- factor(
  sem_data$grade_band,
  levels = c("Middle school", "High school")
)

pooled_cfa <- cfa(
  measurement_model,
  data = sem_data,
  estimator = "MLR",
  missing = "fiml",
  meanstructure = TRUE,
  std.lv = TRUE
)

configural_cfa <- cfa(
  measurement_model,
  data = sem_data,
  group = "grade_band",
  estimator = "MLR",
  missing = "fiml",
  meanstructure = TRUE,
  std.lv = TRUE
)

metric_cfa <- cfa(
  measurement_model,
  data = sem_data,
  group = "grade_band",
  group.equal = "loadings",
  estimator = "MLR",
  missing = "fiml",
  meanstructure = TRUE,
  std.lv = TRUE
)

scalar_cfa <- cfa(
  measurement_model,
  data = sem_data,
  group = "grade_band",
  group.equal = c("loadings", "intercepts"),
  estimator = "MLR",
  missing = "fiml",
  meanstructure = TRUE,
  std.lv = TRUE
)

fits <- list(
  pooled_cfa = pooled_cfa,
  configural_cfa = configural_cfa,
  metric_cfa = metric_cfa,
  scalar_cfa = scalar_cfa
)

if (!all(vapply(fits, lavInspect, logical(1), what = "converged"))) {
  stop("At least one measurement model failed to converge.")
}

saveRDS(fits, "artifacts/measurement_models.rds")

write.csv(
  fit_summary_row(pooled_cfa, "pooled_cfa"),
  "outputs/cfa_fit_indices.csv",
  row.names = FALSE
)
write.csv(
  standardized_loadings(pooled_cfa),
  "outputs/standardized_loadings.csv",
  row.names = FALSE
)
write.csv(
  composite_reliability(pooled_cfa),
  "outputs/reliability.csv",
  row.names = FALSE
)

invariance <- measurement_invariance_table(
  configural_cfa,
  metric_cfa,
  scalar_cfa
)
write.csv(
  invariance,
  "outputs/measurement_invariance.csv",
  row.names = FALSE
)

cat(sprintf(
  "Pooled CFA: CFI %.3f | TLI %.3f | RMSEA %.3f | SRMR %.3f\n",
  fitMeasures(pooled_cfa, "cfi.scaled"),
  fitMeasures(pooled_cfa, "tli.scaled"),
  fitMeasures(pooled_cfa, "rmsea.scaled"),
  fitMeasures(pooled_cfa, "srmr")
))
cat(sprintf(
  "Scalar step: delta CFI %.3f | delta RMSEA %.3f\n",
  invariance$delta_cfi[invariance$model == "scalar"],
  invariance$delta_rmsea[invariance$model == "scalar"]
))

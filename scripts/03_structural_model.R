suppressPackageStartupMessages(library(lavaan))

source("config/model_spec.R")
source("R/sem_helpers.R")

sem_data <- read.csv(
  "data/synthetic_student_engagement.csv",
  stringsAsFactors = FALSE,
  na.strings = c("", "NA")
)

structural_fit <- sem(
  structural_model,
  data = sem_data,
  estimator = "MLR",
  missing = "fiml",
  meanstructure = TRUE,
  std.lv = TRUE,
  fixed.x = FALSE
)

if (!lavInspect(structural_fit, "converged")) {
  stop("The structural model failed to converge.")
}

saveRDS(structural_fit, "artifacts/structural_model.rds")

fit_indices <- fit_summary_row(structural_fit, "structural_model")
estimates <- parameterEstimates(
  structural_fit,
  standardized = TRUE,
  ci = TRUE
)

paths <- estimates[
  estimates$op == "~",
  c("lhs", "op", "rhs", "label", "est", "se", "z", "pvalue", "ci.lower", "ci.upper", "std.all")
]
indirect_effects <- estimates[
  estimates$op == ":=",
  c("lhs", "op", "rhs", "label", "est", "se", "z", "pvalue", "ci.lower", "ci.upper", "std.all")
]
r_squared <- data.frame(
  outcome = names(inspect(structural_fit, "r2")),
  r_squared = unname(inspect(structural_fit, "r2")),
  row.names = NULL
)

write.csv(fit_indices, "outputs/sem_fit_indices.csv", row.names = FALSE)
write.csv(round_numeric(paths), "outputs/structural_paths.csv", row.names = FALSE)
write.csv(round_numeric(indirect_effects), "outputs/indirect_effects.csv", row.names = FALSE)
write.csv(round_numeric(r_squared), "outputs/r_squared.csv", row.names = FALSE)

cat(sprintf(
  "Structural model: CFI %.3f | TLI %.3f | RMSEA %.3f | SRMR %.3f\n",
  fit_indices$cfi,
  fit_indices$tli,
  fit_indices$rmsea,
  fit_indices$srmr
))
cat(sprintf(
  "Serial indirect effect: %.3f (p %.4f)\n",
  indirect_effects$est[indirect_effects$lhs == "support_to_outcome_serial"],
  indirect_effects$pvalue[indirect_effects$lhs == "support_to_outcome_serial"]
))

suppressPackageStartupMessages(library(lavaan))

source("config/model_spec.R")
source("R/sem_helpers.R")

sem_data <- read.csv(
  "data/synthetic_student_engagement.csv",
  stringsAsFactors = FALSE,
  na.strings = c("", "NA")
)
structural_fit <- readRDS("artifacts/structural_model.rds")
diagnostics <- model_diagnostics(structural_fit)

write.csv(
  missingness_summary(sem_data, measurement_items),
  "outputs/missingness_summary.csv",
  row.names = FALSE
)
write.csv(
  diagnostics$residual_variances,
  "outputs/residual_variances.csv",
  row.names = FALSE
)
write.csv(
  diagnostics$modification_indices,
  "outputs/modification_indices.csv",
  row.names = FALSE
)

if (any(diagnostics$residual_variances$negative_variance)) {
  stop("A negative residual variance was detected.")
}

cat(sprintf(
  "Diagnostics passed: %s residual variances checked; %s large modification indices reported for review.\n",
  nrow(diagnostics$residual_variances),
  nrow(diagnostics$modification_indices)
))

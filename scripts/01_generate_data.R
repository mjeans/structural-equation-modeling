source("config/model_spec.R")
source("R/data_generation.R")

dir.create("data", showWarnings = FALSE, recursive = TRUE)

sem_data <- generate_sem_data(
  n = sem_config$sample_size,
  seed = sem_config$seed
)

write.csv(
  sem_data,
  "data/synthetic_student_engagement.csv",
  row.names = FALSE,
  na = ""
)

cat(sprintf(
  "Generated %s synthetic records: %s middle-school and %s high-school records.\n",
  format(nrow(sem_data), big.mark = ","),
  sum(sem_data$grade_band == "Middle school"),
  sum(sem_data$grade_band == "High school")
))

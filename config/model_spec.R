sem_config <- list(
  seed = 20260813L,
  sample_size = 2400L,
  minimum_group_n = 500L,
  invariance_delta_cfi = 0.010,
  invariance_delta_rmsea = 0.015
)

support_items <- paste0("support_", 1:4)
engagement_items <- paste0("engagement_", 1:4)
confidence_items <- paste0("confidence_", 1:3)
measurement_items <- c(support_items, engagement_items, confidence_items)

measurement_model <- '
  support =~ support_1 + support_2 + support_3 + support_4
  engagement =~ engagement_1 + engagement_2 + engagement_3 + engagement_4
  confidence =~ confidence_1 + confidence_2 + confidence_3
'

structural_model <- '
  support =~ support_1 + support_2 + support_3 + support_4
  engagement =~ engagement_1 + engagement_2 + engagement_3 + engagement_4
  confidence =~ confidence_1 + confidence_2 + confidence_3

  engagement ~ a * support + baseline_to_engagement * baseline_z + grade_to_engagement * high_school
  confidence ~ b * engagement + c * support + baseline_to_confidence * baseline_z + grade_to_confidence * high_school
  followup_score ~ d * confidence + e * engagement + f * support + baseline_to_outcome * baseline_z + grade_to_outcome * high_school

  support_to_confidence_indirect := a * b
  support_to_outcome_via_engagement := a * e
  support_to_outcome_via_confidence := c * d
  support_to_outcome_serial := a * b * d
  support_to_outcome_total_indirect := (a * e) + (c * d) + (a * b * d)
  support_to_outcome_total := f + (a * e) + (c * d) + (a * b * d)
'

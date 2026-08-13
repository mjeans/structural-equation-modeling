clamp <- function(x, lower, upper) {
  pmin(pmax(x, lower), upper)
}

make_indicator <- function(latent, loading, intercept = 3) {
  residual_sd <- sqrt(1 - loading^2)
  clamp(intercept + loading * latent + rnorm(length(latent), 0, residual_sd), 1, 5)
}

generate_sem_data <- function(n = 2400L, seed = 20260813L) {
  stopifnot(n >= 600L, n %% 2L == 0L)
  set.seed(seed)

  grade_band <- rep(c("Middle school", "High school"), each = n / 2L)
  high_school <- as.integer(grade_band == "High school")
  school_id <- sprintf("SCH-%02d", sample(seq_len(24L), n, replace = TRUE))

  baseline_z <- rnorm(n)
  support <- rnorm(n, mean = -0.08 * high_school, sd = 1)
  engagement <-
    0.55 * support + 0.22 * baseline_z - 0.12 * high_school + rnorm(n, 0, 0.72)
  confidence <-
    0.48 * engagement + 0.18 * support + 0.22 * baseline_z +
    0.05 * high_school + rnorm(n, 0, 0.70)
  followup_score <-
    70 + 7.0 * baseline_z + 4.0 * engagement + 4.5 * confidence +
    1.5 * support - 1.0 * high_school + rnorm(n, 0, 5.5)

  data <- data.frame(
    student_id = sprintf("STU-%05d", seq_len(n)),
    school_id = school_id,
    grade_band = grade_band,
    high_school = high_school,
    baseline_z = round(baseline_z, 4),
    followup_score = round(followup_score, 2),
    support_1 = make_indicator(support, 0.82),
    support_2 = make_indicator(support, 0.76),
    support_3 = make_indicator(support, 0.72),
    support_4 = make_indicator(support, 0.68),
    engagement_1 = make_indicator(engagement, 0.84),
    engagement_2 = make_indicator(engagement, 0.79),
    engagement_3 = make_indicator(engagement, 0.73),
    engagement_4 = make_indicator(engagement, 0.69),
    confidence_1 = make_indicator(confidence, 0.86),
    confidence_2 = make_indicator(confidence, 0.78),
    confidence_3 = make_indicator(confidence, 0.71),
    stringsAsFactors = FALSE
  )

  item_names <- grep("^(support|engagement|confidence)_", names(data), value = TRUE)
  lower_baseline <- as.integer(data$baseline_z < -0.5)

  for (item_index in seq_along(item_names)) {
    item <- item_names[[item_index]]
    missing_probability <- plogis(
      -3.25 + 0.35 * lower_baseline + 0.12 * high_school +
        0.05 * ((item_index - 1L) %% 3L)
    )
    data[[item]][runif(n) < missing_probability] <- NA_real_
  }

  numeric_items <- c(item_names, "followup_score")
  data[numeric_items] <- lapply(data[numeric_items], function(x) round(x, 3))
  data
}

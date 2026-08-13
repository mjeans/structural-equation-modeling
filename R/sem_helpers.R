required_fit_measures <- c(
  "chisq.scaled", "df.scaled", "pvalue.scaled",
  "cfi.scaled", "tli.scaled", "rmsea.scaled",
  "rmsea.ci.lower.scaled", "rmsea.ci.upper.scaled", "srmr"
)

fit_summary_row <- function(fit, model_name) {
  values <- lavaan::fitMeasures(fit, required_fit_measures)
  data.frame(
    model = model_name,
    chisq = unname(values[["chisq.scaled"]]),
    df = unname(values[["df.scaled"]]),
    p_value = unname(values[["pvalue.scaled"]]),
    cfi = unname(values[["cfi.scaled"]]),
    tli = unname(values[["tli.scaled"]]),
    rmsea = unname(values[["rmsea.scaled"]]),
    rmsea_lower = unname(values[["rmsea.ci.lower.scaled"]]),
    rmsea_upper = unname(values[["rmsea.ci.upper.scaled"]]),
    srmr = unname(values[["srmr"]]),
    stringsAsFactors = FALSE
  )
}

round_numeric <- function(data, digits = 3L) {
  numeric_columns <- vapply(data, is.numeric, logical(1))
  data[numeric_columns] <- lapply(data[numeric_columns], round, digits = digits)
  data
}

standardized_loadings <- function(fit) {
  estimates <- lavaan::parameterEstimates(fit, standardized = TRUE)
  estimates <- estimates[estimates$op == "=~", , drop = FALSE]
  round_numeric(estimates[c("lhs", "rhs", "est", "se", "pvalue", "std.all")])
}

composite_reliability <- function(fit) {
  standardized <- lavaan::standardizedSolution(fit)
  factors <- unique(standardized$lhs[standardized$op == "=~"])

  rows <- lapply(factors, function(factor_name) {
    loadings <- standardized$est.std[
      standardized$op == "=~" & standardized$lhs == factor_name
    ]
    error_variance <- 1 - loadings^2
    omega <- sum(loadings)^2 / (sum(loadings)^2 + sum(error_variance))
    ave <- sum(loadings^2) / (sum(loadings^2) + sum(error_variance))
    data.frame(
      factor = factor_name,
      indicators = length(loadings),
      composite_reliability = omega,
      average_variance_extracted = ave
    )
  })

  round_numeric(do.call(rbind, rows))
}

measurement_invariance_table <- function(configural, metric, scalar) {
  fits <- list(configural = configural, metric = metric, scalar = scalar)
  table <- do.call(rbind, Map(fit_summary_row, fits, names(fits)))
  table$delta_cfi <- c(NA_real_, diff(table$cfi))
  table$delta_rmsea <- c(NA_real_, diff(table$rmsea))
  round_numeric(table)
}

missingness_summary <- function(data, variables) {
  data.frame(
    variable = variables,
    n_missing = vapply(data[variables], function(x) sum(is.na(x)), integer(1)),
    percent_missing = vapply(
      data[variables],
      function(x) mean(is.na(x)) * 100,
      numeric(1)
    ),
    row.names = NULL
  ) |>
    round_numeric()
}

model_diagnostics <- function(fit) {
  estimates <- lavaan::parameterEstimates(fit, standardized = TRUE)
  residual_variances <- estimates[
    estimates$op == "~~" & estimates$lhs == estimates$rhs,
    c("lhs", "est", "se", "pvalue", "std.all")
  ]
  residual_variances$negative_variance <- residual_variances$est < 0

  modification_indices <- lavaan::modindices(fit, sort. = TRUE)
  modification_indices <- modification_indices[
    modification_indices$mi >= 10,
    c("lhs", "op", "rhs", "mi", "epc", "sepc.all")
  ]

  list(
    residual_variances = round_numeric(residual_variances),
    modification_indices = round_numeric(head(modification_indices, 20L))
  )
}

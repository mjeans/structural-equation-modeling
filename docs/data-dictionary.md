# Data dictionary

| Field | Type | Role | Definition |
|---|---|---|---|
| `student_id` | Character | Identifier | Synthetic unique record ID |
| `school_id` | Character | Reporting | Synthetic school identifier; not modeled in the reference SEM |
| `grade_band` | Character | Group | Middle school or high school |
| `high_school` | Binary | Covariate | High-school indicator used in the structural model |
| `baseline_z` | Numeric | Covariate | Standardized synthetic baseline performance |
| `followup_score` | Numeric | Outcome | Synthetic later achievement score |
| `support_1`–`support_4` | Numeric | Indicators | Four bounded continuous support indicators |
| `engagement_1`–`engagement_4` | Numeric | Indicators | Four bounded continuous engagement indicators |
| `confidence_1`–`confidence_3` | Numeric | Indicators | Three bounded continuous academic-confidence indicators |

Indicator values range from 1 to 5 and include deterministic missingness under a fixed seed. They are treated as approximately continuous for this robust-ML demonstration. A real analysis of coarse ordinal responses should evaluate an ordinal estimator and thresholds explicitly.

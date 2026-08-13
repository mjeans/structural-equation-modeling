.PHONY: all data measurement structural diagnostics test clean

all: data measurement structural diagnostics test

data:
	Rscript scripts/01_generate_data.R

measurement: data
	Rscript scripts/02_measurement_models.R

structural: measurement
	Rscript scripts/03_structural_model.R

diagnostics: structural
	Rscript scripts/04_diagnostics.R

test:
	Rscript tests/test_pipeline.R

clean:
	rm -rf data artifacts
	rm -f outputs/*.csv

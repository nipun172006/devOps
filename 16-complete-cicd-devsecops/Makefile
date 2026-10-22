PYTHON ?= python

.PHONY: lint test sast sca secrets validate run

lint:
	$(PYTHON) -m ruff check app tests scripts

test:
	mkdir -p reports
	$(PYTHON) -m pytest tests -v --cov=app --cov-report=term-missing --cov-report=xml:reports/coverage.xml --junitxml=reports/junit.xml

sast:
	$(PYTHON) -m bandit -r app -ll

sca:
	$(PYTHON) -m pip_audit -r requirements.txt --strict

secrets:
	$(PYTHON) scripts/secret_scan.py .

validate: lint test sast sca secrets

run:
	SOURCE_REVISION=local $(PYTHON) -m flask --app app.main run --port 8080

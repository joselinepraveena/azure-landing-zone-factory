.PHONY: fmt check test validate

fmt:
	terraform fmt -recursive

test:
	python3 scripts/validate-request.py config/vending-requests/sample-sandbox.json
	python3 -m unittest discover -s tests -p "test_*.py"

validate:
	terraform -chdir=platform/alz init -backend=false
	terraform -chdir=platform/alz validate
	terraform -chdir=platform/vending init -backend=false
	terraform -chdir=platform/vending validate

check: test validate
	terraform fmt -check -recursive

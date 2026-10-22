TF ?= terraform
PLAN ?= tfplan

.PHONY: init fmt validate test plan apply output state destroy clean

init:
	$(TF) init

fmt:
	$(TF) fmt -recursive

validate:
	$(TF) fmt -check -recursive
	$(TF) validate

test:
	$(TF) test

plan:
	$(TF) plan -out=$(PLAN)

apply:
	$(TF) apply $(PLAN)

output:
	$(TF) output

state:
	$(TF) state list

destroy:
	$(TF) plan -destroy
	$(TF) destroy

clean:
	$(TF) fmt -check -recursive

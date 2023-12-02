s3_bucket := examon-lambdas
project := petshop
package_dir := package
default: help ;

#########################################
# Help
#########################################
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  infra_create"
	@echo "  infra_destroy"
	@echo "  fn_build resource=<resource> name=<name>"
	@echo "  fn_upload resource=<resource> name=<name>"
	@echo "  fn_zip resource=<resource> name=<name>"
	@echo "  fn_test resource=<resource> name=<name>"
	@echo "  fn_clean resource=<resource> name=<name>"
	@echo "  fn_deploy"
	@echo "  fn_deploy_all"
	@echo ""
	@echo "Resources:"
	@echo "  pet (create, create, get, index, listener, update)"
.PHONY: help

#########################################
# Terraform
#########################################
infra_create:
	cd terraform/site && \
	terraform init && \
	terraform plan && \
	terraform apply -auto-approve
.PHONY: infra_create

infra_destroy:
	cd terraform/site && \
	terraform destroy -auto-approve
.PHONY: infra_destroy

#########################################
# Lambdas
#########################################

fn_build:
	cd "handlers/${resource}/${name}" && \
	rm -rf ${package_dir} && \
	poetry config virtualenvs.in-project true && \
    poetry install && \
	mkdir -p ${package_dir} && \
    poetry export --without-hashes --format requirements.txt --output ${package_dir}/requirements.txt && \
    poetry run pip install --no-deps --upgrade --cache-dir ./.pip_cache --requirement ${package_dir}/requirements.txt --target package && \
    cp -R src ${package_dir}
.PHONY: fn_build

fn_upload:
	cd "handlers/${resource}/${name}" && \
	aws s3 cp "${name}_${resource}.zip" s3://${s3_bucket} && \
	aws lambda update-function-code --function-name "${project}_${name}_${resource}" \
	--s3-bucket ${s3_bucket} --s3-key "${name}_${resource}.zip" > /dev/null
.PHONY: fn_upload

fn_zip:
	cd "handlers/${resource}/${name}" && \
	cd package && \
	zip -r -D --exclude requirements.\* --recurse-paths ${name}_${resource}.zip * && \
	cd .. && \
	mv "${package_dir}/${name}_${resource}.zip" .
.PHONY: fn_zip

fn_test:
	cd "handlers/${resource}/${name}" && \
	poetry run pytest
.PHONY: tests

fn_clean:
	cd "handlers/${resource}/${name}" && \
	rm -rf ${package_dir} && \
	rm -rf ./.pip_cache && \
	rm -rf ./.pytest_cache && \
	rm -rf ./.venv && \
	rm -rf ./*.zip && \
	rm -rf ./__pycache__

fn_deploy: fn_build fn_zip fn_upload
.PHONY: fn_all

#########################################
# Aggregate
#########################################

fn_deploy_all:
	$(MAKE) fn_deploy resource=pet name=create
	$(MAKE) fn_deploy resource=pet name=delete
	$(MAKE) fn_deploy resource=pet name=get
	$(MAKE) fn_deploy resource=pet name=index
	$(MAKE) fn_deploy resource=pet name=listener
	$(MAKE) fn_deploy resource=pet name=update
.PHONY: fn_deploy_all
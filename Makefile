s3_bucket := examon-mirror-storage-lambdas
project := storage_mirror
package_dir := package
region := eu-west-1
account_id := 478119378221
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

build_libs:
	cd "libs/mirror_storage_support" && \
	poetry env use 3.11.8 && \
	poetry config virtualenvs.in-project true && \
	poetry install && \
	poetry build
.PHONY: fn_build_libs

fn_build:
	cd "handlers/${resource}/${name}" && \
	rm -rf ${package_dir} && \
	poetry env use 3.11.8 && \
	poetry config virtualenvs.in-project true && \
    poetry install && \
	mkdir -p ${package_dir} && \
    poetry export --without-hashes --format requirements.txt --output ${package_dir}/requirements.txt && \
    poetry run pip install --no-deps --upgrade --cache-dir ./.pip_cache --requirement ${package_dir}/requirements.txt --target package && \
    cp -R src ${package_dir}
.PHONY: fn_build

fn_layer_zip:
	cd "handlers/${resource}/${name}" && \
	poetry export -f requirements.txt --output requirements.txt && \
	mkdir -p python && \
    pip install -r requirements.txt -t python/ && \
    zip -r ${name}_${resource}_layer.zip python && \
	rm -rf python && \
	rm -rf requirements.txt
.PHONY: fn_zip

fn_layer_upload:
	cd "handlers/${resource}/${name}" && \
	aws s3 cp "${name}_${resource}_layer.zip" s3://${s3_bucket} && \
	aws lambda publish-layer-version --layer-name "${project}_${name}_${resource}_layer" \
	--content S3Bucket=${s3_bucket},S3Key="${name}_${resource}_layer.zip" > /dev/null
.PHONY: fn_upload

fn_layer_apply:
	LATEST_VERSION=$$(aws lambda list-layer-versions --layer-name "${project}_${name}_${resource}_layer" --query 'LayerVersions[0].Version' --output text) && \
	aws lambda update-function-configuration --function-name "${project}_${name}_${resource}" \
    --layers "arn:aws:lambda:${region}:${account_id}:layer:${project}_${name}_${resource}_layer:$${LATEST_VERSION}" > /dev/null

fn_zip:
	cd "handlers/${resource}/${name}" && \
	cd package && \
	zip -r -D --exclude requirements.\* --recurse-paths ${name}_${resource}.zip * && \
	cd .. && \
	mv "${package_dir}/${name}_${resource}.zip" .
.PHONY: fn_zip

fn_zip_mini:
	cd "handlers/${resource}/${name}" && \
	cd package && \
	zip -r -D ${name}_${resource}_mini.zip src && \
	cd .. && \
	mv "${package_dir}/${name}_${resource}_mini.zip" .
.PHONY: fn_zip

fn_upload_mini:
	cd "handlers/${resource}/${name}" && \
	aws s3 cp "${name}_${resource}_mini.zip" s3://${s3_bucket} && \
	aws lambda update-function-code --function-name "${project}_${name}_${resource}" \
	--s3-bucket ${s3_bucket} --s3-key "${name}_${resource}_mini.zip" > /dev/null
.PHONY: fn_upload_mini

fn_upload:
	cd "handlers/${resource}/${name}" && \
	aws s3 cp "${name}_${resource}.zip" s3://${s3_bucket} && \
	aws lambda update-function-code --function-name "${project}_${name}_${resource}" \
	--s3-bucket ${s3_bucket} --s3-key "${name}_${resource}.zip" > /dev/null
.PHONY: fn_upload_mini

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
.PHONY: fn_deploy_mini

libs_clean:
	rm -rf libs/petshop_support

#########################################
# Aggregate
#########################################

fn_build_all:
	$(MAKE) fn_build resource=storage name=create
	$(MAKE) fn_build resource=storage name=get

fn_deploy_all:
	$(MAKE) fn_deploy resource=storage name=create
	$(MAKE) fn_deploy resource=storage name=get
.PHONY: fn_deploy_all

fn_clean_all:
	$(MAKE) fn_clean resource=storage name=create
	$(MAKE) fn_clean resource=storage name=get
.PHONY: fn_clean_all

#########################################
# Main
#########################################

all: build_libs fn_build_all

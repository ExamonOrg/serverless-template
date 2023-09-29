package_dir := package

export PYTHONPATH := .

# This will build the lambda handler and create a zip file
build: package zip
.PHONY: build

tests:
	poetry run pytest
.PHONY: tests

package:
	rm -rf ${package_dir} && \
	poetry config virtualenvs.in-project true && \
  poetry install && \
	mkdir -p ${package_dir} && \
  poetry export --without-hashes --format requirements.txt --output ${package_dir}/requirements.txt && \
  poetry run pip install --no-deps --upgrade --cache-dir ./.pip_cache --requirement ${package_dir}/requirements.txt --target package && \
  cp -R src ${package_dir}
.PHONY: package

zip:
	zip -r --exclude requirements.\* --recurse-paths app.zip package/*
.PHONY: zip

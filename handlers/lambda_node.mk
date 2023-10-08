build: clean package zip
.PHONY: build

test:
	npm run test
.PHONY: tests

package:
	rm -rf ${package_dir} && \
    npm install
.PHONY: package

zip:
	zip -r ${package_name} node_modules/ src/ package.json package-lock.json index.js
.PHONY: zip

clean:
	rm -rf node_modules && \
	rm -rf ${package_name}
.PHONY: clean

.PHONY: help clean html html-multiversion serve

help:
	@echo "Available targets:"
	@echo "  html              - Build HTML documentation (single version)"
	@echo "  html-multiversion - Build HTML documentation for all versions"
	@echo "  clean             - Remove build directory"
	@echo "  serve             - Serve documentation locally (after build)"

html:
	sphinx-build -b html . _build/html

html-multiversion:
	sphinx-multiversion . _build/html

clean:
	rm -rf _build

serve:
	cd _build/html && python -m http.server 8000


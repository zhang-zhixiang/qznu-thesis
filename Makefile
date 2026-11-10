# 泉州师范学院本科毕业论文 LaTeX 模板
# 常用命令：make / make check / make test / make clean

SHELL := /bin/bash
LATEXMK ?= latexmk
PYTHON ?= python3
MAIN := qznu-thesis
BUILD := build

.PHONY: all build check test clean dist view

all: build

build:
	./scripts/build.sh

check: build
	$(PYTHON) scripts/check_content.py
	$(PYTHON) scripts/check_pdf.py $(BUILD)/$(MAIN).pdf --log $(BUILD)/$(MAIN).log

test: build
	./tests/run_tests.sh

dist: build
	mkdir -p dist
	cp $(BUILD)/$(MAIN).pdf dist/qznu-thesis.pdf
	@echo "输出：dist/qznu-thesis.pdf"

view: build
	@if command -v open >/dev/null 2>&1; then \
		open $(BUILD)/$(MAIN).pdf; \
	elif command -v xdg-open >/dev/null 2>&1; then \
		xdg-open $(BUILD)/$(MAIN).pdf; \
	else \
		echo "请手动打开 $(BUILD)/$(MAIN).pdf"; \
	fi

clean:
	-$(LATEXMK) -C -outdir=$(BUILD) $(MAIN).tex >/dev/null 2>&1 || true
	rm -rf $(BUILD) dist

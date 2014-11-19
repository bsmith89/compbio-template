PROJ_DIRS = $(shell find . \( -name ".git" \) -prune -o -type d -print)

all:   docs figs
figs:

# Don't delete any intermediate files
.SECONDARY:

.PHONY: all docs figs

# -----------------------
#  Analysis Recipes
# -----------------------

# -----------------------
#  Documentation Recipes
# -----------------------

ALL_DOCS_MD = $(foreach d,${PROJ_DIRS}, $(wildcard ${d}/*.md))
ALL_DOCS_HTML = $(patsubst %.md,%.html, ${ALL_DOCS_MD})

docs: ${ALL_DOCS_HTML}

pandoc_recipe_md2html = \
cat $< \
| pandoc -f markdown -t html5 -s \
			--highlight-style pygments --mathjax \
			--toc --toc-depth=4 \
			--css static/main.css \
> $@
%.html: %.md
	${pandoc_recipe_md2html}


# -----------------
#  Cleanup Recipes
# -----------------

clean:
	rm -f ${ALL_DOCS_HTML}

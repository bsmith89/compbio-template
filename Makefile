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

# ------------------------
#  Initialization Recipes
# ------------------------
SEMAPHORE = .initialized
${SEMAPHORE}:
	[ ! -e ${SEMAPHORE} ]
	# Create the initialization semaphor.
	touch $@
.PHONY: ${SEMAPHORE}

base_init: ${SEMAPHORE}
	git submodule update --init --recursive
	# Configure IPYNB output filtering
	git config --local filter.dropoutput_ipynb.clean scripts/utils/ipynb_output_filter.py
	git config --local filter.dropoutput_ipynb.smudge cat

init_from_project: base_init

init_from_template: base_init
	# Remove the template remote
	git remote remove origin
	# Link README to project notes, instead of template notes.
	unlink README.md
	ln -s NOTE.md README.md
	# Remove all of the commits after the first, leaving files intact,
	# add files created/changed during initialization,
	# and amend the first commit with everything else.
	# TL;DR Squash everything to a single first commit.
	git reset --soft $(git rev-list --max-parents=0 HEAD)
	git add -A
	git commit --amend -em "Clean project.  Let's get started!"

# -----------------
#  Cleanup Recipes
# -----------------

clean:
	rm -f ${ALL_DOCS_HTML}

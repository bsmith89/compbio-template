# Preface {{{1
# User help message {{{2
define HELP_MSG

================================
 Analysis Makefile Documentation
================================

SYNOPSIS
    Run project operations using make commands.

TARGETS
    all
        Generate all. (By default this includes all figures,
        results, and documentation based on user-defined recipes.)

    docs
        Compile markdown files (e.g. NOTE.md, TEMPLATE.md) into HTML (uses
        Pandoc).

    figs
        Carry out the pipeline to ultimately generate figures of the results.

    res
        Carry out the pipeline to ultimately generate quantitative results
        files.

    help
        Show this help message.

    init
        Initialize the project:
            (1) venv
            (2) python-reqs
            (2) data-dirs
            (3) configure git to automatically clean IPython notebooks;
            (4) OPTIONAL: remove the 'origin' git remote
            (5) OPTIONAL: squash the commit history into a single
                'Initial commit';
            (6) create `.git/.initialized` to indicate that these steps are
                completed.

    venv
        Create the virtualenv if absent.

    python-reqs
        Install all python requirements from requirements.txt and
        all requirements.txt to the venv.

    data-dirs
        Create all data directories listed in $${DATA_DIRS}
        Default: raw/ seq/ tre/ img/ fig/ res/

EXAMPLES
    make init  # Initialize the project.
    make all   # Carry out all defined steps in the project.

GNU MAKE HELP:


endef
export HELP_MSG


# ========================
#  Standard Configuration {{{2
# ========================
# One failing step in a recipe causes the whole recipe to fail.
.POSIX:

# Don't delete intermediate files.
.SECONDARY:

# Delete targets if there is an error while executing a rule.
.DELETE_ON_ERROR:

# The target `all` needs to be the first one defined (besides special
# targets) in order for it to be made on running `make` without a target.
.PHONY: all
all:

HELP_TRGTS = help h HELP Help
.PHONY: ${HELP_TRGTS}
${HELP_TRGTS}:
	@echo "$$HELP_MSG" "$$(${MAKE} -h)" | less

# All recipes are run as though they are within the virtualenv.
# WARNING: This may cause difficult to debug problems.
VENV = ./venv
export VIRTUAL_ENV = $(abspath ${VENV})
export PATH := ${VIRTUAL_ENV}/bin:${PATH}

# TODO: Include a tmp/ dir?  Use it for what?
DATA_DIRS += etc/ ipynb/ raw/ meta/ res/ fig/

# Use this file to include sensitive data that shouldn't be version controlled.
# Others forking this project will need to create their own local.mk.
# If local.mk is vital and you would like the user to be alerted to its
# absence, remove the preceeding '-'.
-include local.mk

# ====================
#  User Configuration {{{1
# ====================

# Major targets {{{2
.PHONY: docs figs res
docs:
figs:
res:

# What files are generated on `make all`?
all: docs figs res

# Compute environment {{{2
# Name, and directory, of the python virtual environment:
VENV = ./venv
# All recipes are run as though they are within the virtualenv.
# WARNING: This may cause difficult to debug problems.
# To deactivate, thereby running all recipes from the global python
# environment, comment out the following line:
export VIRTUAL_ENV = $(abspath ${VENV})

# Use the following line to add to the PATH of all recipes.
# WARNING: These executibles will not necessarily be available in the same
# way from the command line, so you may get difficult to debug problems.
export PATH := ${VIRTUAL_ENV}/bin:${PATH}
# TODO: Deal with virtualenvs in a more transparent way.

# Cleanup settings {{{2
# Use the following line to add files and directories to be deleted on `make clean`:
CLEANUP +=

# Initialization settings {{{2
# What directories to generate on `make data-dirs`.
# By default, already includes etc/ ipynb/ raw/ meta/ res/ fig/
DATA_DIRS +=

# ==============
#  Data {{{1
# ==============
# User defined recipes for cleaning up and initially parsing data.
# e.g. Slicing out columns, combining data sources, alignment, generating
# phylogenies, etc.

# =======================
#  Analysis {{{1
# =======================
# User defined recipes for analyzing the data.
# e.g. Calculating means, distributions, correlations, fitting models, etc.
# Basically anything that *could* go into the paper as a table.


# ==================
#  Graphing {{{1
# ==================
# User defined recipes for plotting figures.  These should use
# the targets of analysis recipes above as their prerequisites.


# =======================
#  Documentation {{{1
# =======================
# TODO: Consider splitting out all of the constant parts of this file into
# a new Makefile
ALL_DOCS = TEMPLATE NOTE
ALL_DOCS_HTML = $(addsuffix .html,${ALL_DOCS})
MATHJAX = "https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"

%.html: %.md
	pandoc -f markdown -t html5 -s --highlight-style pygments \
        --mathjax=${MATHJAX} --toc --toc-depth=4 --css static/main.css $^ > $@

docs: ${ALL_DOCS_HTML} fig/Makefile.png

# Visualize makefile with cytoscape.
# requires:
# https://bitbucket.org/jpbarrette/makegrapher
# details at: https://code.google.com/p/makegrapher
res/Makefile.complete: Makefile
	${MAKE} --makefile=$^ -npr > $@

res/Makefile.dot: res/Makefile.complete
	make_grapher.py -T $^ -o $@ >/dev/null

fig/%.png: res/%.dot
	dot -Tpng -Grankdir=BT -Nshape=plaintext < $^ > $@

tags:
	ctags -R

# =================
#  Cleanup {{{1
# =================
.PHONY: clean
clean:
	rm -rf ${CLEANUP}

# ========================
#  Initialization Recipes {{{1
# ========================
.PHONY: init
init: .git/.initialized
.git/.initialized:
	@${MAKE} .git-new-branch
	@[ "${VENV}" ] && ${MAKE} ${VENV}
	@${MAKE} python-reqs
	@${MAKE} data-dirs
	@${MAKE} .link-readme
	@${MAKE} .ipynb-filter-config
	@${MAKE} .git-initial-commit
	touch $@

define VENV_ACTIVATE_MSG

A python3 virtual environment has been made in `${VENV}`.

Python called from recipes in `Makefile` will automatically use this virtual
environment.  To activate ${VENV} for the command-line, however,
run `source ${VENV}/bin/activate`.

endef
export VENV_ACTIVATE_MSG

${VENV}:
	python3 -m venv $@
	@echo "$$VENV_ACTIVATE_MSG"


PIP_REQS = requirements.txt

.PHONY: python-reqs data-dirs
python-reqs: | ${VENV}
	pip install --upgrade --no-deps -r ${PIP_REQS}
	pip install -r ${PIP_REQS}

data-dirs:
	mkdir -p ${DATA_DIRS}

.PHONY: .link-readme .confirm-git-mangle \
        .git-branch .git-initial-commit \
		.ipynb-filter-config

.link-readme:
	unlink README.md
	ln -s NOTE.md README.md

# TODO: Fix up some things assuming I don't always want to initialize
# from a template, and sometime I want to go from a project.
.git-new-branch:
	-git branch -m template
	-git remote rename origin template-origin
	git checkout master || git checkout -b master

.git-initial-commit:
	git add -A
	git commit -em "[NEW PROJECT]"

.ipynb-filter-config:
	git config --local filter.dropoutput_ipynb.clean ipynb_output_filter
	git config --local filter.dropoutput_ipynb.smudge cat

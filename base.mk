# User help message {{{1
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
        Compile markdown files (e.g. NOTE.md, TEMPLATE.md) into HTML using
        Pandoc.

    figs
        Carry out the pipeline to ultimately generate figures of the results.

    res
        Carry out the pipeline to ultimately generate quantitative results
        files.

    help
        Show this help message.

    init
        Initialize a new project (from a template):
            (1) ${VENV}
            (2) python-reqs
            (3) data-dirs
            (4) link README.md to NOTE.md (from TEMPLATE.md)
            (5) configure git to automatically clean IPython notebooks;
            (6) rename the 'origin' git remote to 'template'
            (7) initial project commit
            (8) create `.git/.initialized` to indicate that these steps are
                completed.

    reinit
        Reinitialize a project:
            (1) ${VENV}
            (2) python-reqs
            (3) data-dirs
            (4) configure git to automatically clean IPython notebooks;
            (5) create `.git/.initialized` to indicate that these steps are
                completed.

    ${VENV}
        Create the virtualenv if absent.  The name is set by $${VENV}.

    python-reqs
        Install all python requirements from `requirements.txt` to the venv.

    data-dirs
        Create all data directories. Directories set in $${DATA_DIRS}.
        (${DATA_DIRS})

EXAMPLES
    make reinit  # Reinitialize a project.
    make all     # Carry out all defined steps in the project.

See `man make` for help with GNU Make.


endef
export HELP_MSG

# ========================
#  Standard Configuration {{{1
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
	@echo "$$HELP_MSG" | more

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
#  Documentation {{{1
# =======================
# TODO: Consider splitting out all of the constant parts of this file into
# a new Makefile
ALL_DOCS = TEMPLATE NOTE
ALL_DOCS_HTML = $(addsuffix .html,${ALL_DOCS})
MATHJAX = "https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"

main.bib: ${EXTERNAL_BIBS}
	scripts/sort_bib.py $^ > $@

# If EXTERNAL_BIBS, should be defined in local.mk
# BIB_FILE defined in Makefile User Config Section
ifdef ${EXTERNAL_BIBS}
${BIB_FILE}: ${EXTERNAL_BIBS}
	scripts/sort_bib.py $^ > $@
endif

%.html: %.md
	pandoc -f markdown -t html5 -s --highlight-style pygments \
		--filter pandoc-citeproc \
        --mathjax=${MATHJAX} --toc --toc-depth=4 --css static/main.css $^ > $@

docs: ${ALL_DOCS_HTML} fig/Makefile.reduced.png

# Visualize makefile with cytoscape.
# requires:
# https://bitbucket.org/jpbarrette/makegrapher
# details at: https://code.google.com/p/makegrapher
res/Makefile.complete: Makefile
	${MAKE} --makefile=$^ -npr > $@

res/Makefile.dot: res/Makefile.complete
	make_grapher.py -T $^ -o $@ >/dev/null

res/Makefile.reduced.dot: scripts/clean_makefile_graph.py res/Makefile.dot
	$(word 1,$^) -d '^raw/ab1' -d '^bin/utils/' -d '^\.' -d '\.git' \
                 -d '(submodules|venv|python-reqs|init)' \
                 -k '^raw/mcra' -k '^(all|res|figs|docs|Makefile)$$' \
                 $(word 2,$^) > $@

fig/%.png: res/%.dot
	dot -Tpng -Nshape=plaintext -Edir=back < $^ > $@

tags:
	ctags -R

# =================
#  Cleanup {{{1
# =================
.PHONY: clean
clean:
	rm -rf ${CLEANUP}

# ========================
#  Initialization {{{1
# ========================
.PHONY: init
INIT_SEMAPHOR=.git/.initialized
init: ${INIT_SEMAPHOR}

${INIT_SEMAPHOR}:
	@${MAKE} .git-new-branch
	@[ "${VENV}" ] && ${MAKE} ${VENV}
	@${MAKE} python-reqs
	@${MAKE} data-dirs
	@${MAKE} .link-readme
	@${MAKE} .ipynb-filter-config
	@${MAKE} .git-initial-commit
	touch $@

reinit:
	@[ "${VENV}" ] && ${MAKE} ${VENV}
	@${MAKE} python-reqs
	@${MAKE} data-dirs
	@${MAKE} .git-ipynb-filter-config
	touch ${INIT_SEMAPHOR}

.merge-template:
	git fetch template-source
	git merge template-source

# Python Environment {{{2
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


PIP_REQS = $(wildcard requirements.txt)

.PHONY: python-reqs data-dirs
python-reqs: | ${VENV}
	for req_file in ${PIP_REQS}; do \
        pip install --upgrade --no-deps -r $$req_file ; \
        pip install -r $$req_file ; \
    done

# Install compbio-scripts with a local repository that can be edited.
PACKAGE_DIR=./packages
SEQUTILS_URL=https://github.com/bsmith89/compbio-scripts
SEQUTILS_DIR=${PACKAGE_DIR}/sequtils
.editable-sequtils: | ${VENV}
	mkdir -p ${PACKAGE_DIR}
	rm -rf ${SEQUTILS_DIR}
	git clone ${SEQUTILS_URL} ${SEQUTILS_DIR}
	-pip uninstall sequtils
	pip install -e ${SEQUTILS_DIR}

# Repository Structure {{{2
data-dirs:
	mkdir -p ${DATA_DIRS}

.PHONY: .link-readme .confirm-git-mangle \
        .git-branch .git-initial-commit \
		.git-ipynb-filter-config

.link-readme:
	unlink README.md
	ln -s NOTE.md README.md

# Git Configuration {{{2
# TODO: Fix up some things assuming I don't always want to initialize
# from a template, and sometime I want to go from a project.
.git-new-branch:
	git branch -m template
	git remote rename origin template-source
	git checkout -B master
	git branch -d template

.git-initial-commit:
	git add -A
	git commit -em "NEW PROJECT: [Name]"

.ipynb-filter-config:
	git config --local filter.dropoutput_ipynb.clean scripts/ipynb_output_filter
	git config --local filter.dropoutput_ipynb.smudge cat

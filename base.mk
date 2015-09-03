# User help message {{{1
define PROJECT_HELP_MSG

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
            (6) rename the 'origin' git remote to 'template-source'
            (7) make a new branch 'master' and remove the origin branch
            (8) initial project commit
            (9) create `.git/.initialized` to indicate that these steps are
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

    merge-template:
        Pull in changes to the template remote 'template-source'.

EXAMPLES
    make reinit  # Reinitialize a project.
    make all     # Carry out all defined steps in the project.

See `man make` for help with GNU Make.


endef
export PROJECT_HELP_MSG

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
	@echo "$$PROJECT_HELP_MSG" | more

# All recipes are run as though they are within the virtualenv.
# WARNING: This may cause difficult to debug problems.
VENV = ./.venv
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
ALL_DOCS = TEMPLATE NOTE
ALL_DOCS_HTML = $(addsuffix .html,${ALL_DOCS})
MATHJAX = "https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"

# If EXTERNAL_BIBS, should be defined in local.mk
# BIB_FILE defined in Makefile User Config Section
# TODO: Why does this think that BIB_FILE is unset when I'm importing
# this entire file from Makefile (where main.bib IS set)?1?!
ifdef ${EXTERNAL_BIBS}
${BIB_FILE}: ${EXTERNAL_BIBS}
	scripts/sort_bib.py $^ > $@
endif

PANDOC_OPTS_GENERAL = -f markdown --smart --highlight-style pygments \
                      --filter pandoc-citeproc --toc --toc-depth=4 -o $@

%.html: %.md header.yaml ${BIB_FILE}
	pandoc ${PANDOC_OPTS_GENERAL} -t html5 --standalone --mathjax=${MATHJAX} \
        --css static/main.css $(word 1,$^) $(word 2,$^)

%.docx: %.md ${BIB_FILE}
	pandoc ${PANDOC_OPTS_GENERAL} -t docx $(word 1,$^) $(word 2,$^)

%.pdf: %.md ${BIB_FILE}
	pandoc ${PANDOC_OPTS_GENERAL} -t latex $(word 1,$^) $(word 2,$^)

docs: ${ALL_DOCS_HTML} fig/Makefile.reduced.png

# Visualize makefile with cytoscape.
# requires:
# https://bitbucket.org/jpbarrette/makegrapher
# details at: https://code.google.com/p/makegrapher
res/Makefile.complete: Makefile
	${MAKE} --makefile=$^ -npr > $@

res/Makefile.dot: scripts/parse_make_db.py res/Makefile.complete
	$^ > $@

res/Makefile.reduced.dot: scripts/clean_makefile_graph.py res/Makefile.dot
	$(word 1,$^) -d '^raw/ab1' -d '^bin/utils/' -d '^\.' -d '\.git' \
                 -d '(submodules|${VENV}|python-reqs|init)' \
                 -k '^raw/mcra' -k '^(all|res|figs|docs|Makefile)$$' \
                 $(word 2,$^) > $@

fig/Makefile.reduced.%: res/Makefile.reduced.dot
	dot -T$* -Edir=back -Nshape=plaintext < $^ > $@

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
.PHONY: init reinit merge-template data-dirs
INIT_SEMAPHOR=.git/.initialized
init: ${INIT_SEMAPHOR}

${INIT_SEMAPHOR}:
	@${MAKE} .git-new-branch
	@[ "${VENV}" ] && ${MAKE} ${VENV}
	@${MAKE} python-reqs
	@${MAKE} data-dirs
	@${MAKE} .link-readme
	@${MAKE} .git-ipynb-filter-config
	@${MAKE} INITIAL_COMMIT_OPTIONS='${INITIAL_COMMIT_OPTIONS}' .git-initial-commit
	@${MAKE} .git-pager-config
	touch $@

# TODO: Figure out why the explicit passing of INITIAL_COMMIT_OPTIONS is required.

reinit:
	@[ "${VENV}" ] && ${MAKE} ${VENV}
	@${MAKE} python-reqs
	@${MAKE} data-dirs
	@${MAKE} .git-ipynb-filter-config
	@${MAKE} .git-pager-config
	touch ${INIT_SEMAPHOR}

merge-template:
	git fetch template-source
	git merge template-source

# Python Environment {{{2
.PHONY: python-reqs .editable-sequtils
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

PACKAGE_DIR=./packages

python-reqs: | ${VENV}
	@python --version
	@which python
	for req_file in ${PIP_REQS}; do \
        pip install --upgrade --no-deps --src ${PACKAGE_DIR} -r $$req_file ; \
        pip install -r $$req_file ; \
    done

# Repository Structure {{{2
.PHONY: .link-readme data-dirs

data-dirs:
	mkdir -p ${DATA_DIRS}

.link-readme:
	unlink README.md
	ln -s NOTE.md README.md

# Git Configuration {{{2
.PHONY: .git-new-branch .git-initial-commit \
		.git-ipynb-filter-config .git-pager-config

# TODO: Fix up some things assuming I don't always want to initialize
# from a template, and sometime I want to go from a project.
.git-new-branch:
	git branch -m template
	git remote rename origin template-source
	git checkout -B master
	git branch -d template

define INITIAL_PROJECT_COMMIT_MSG
Initial project commit.

# PLEASE CUSTOMIZE THIS MESSAGE.
endef
export INITIAL_PROJECT_COMMIT_MSG

INITIAL_COMMIT_OPTIONS = -e

.git-initial-commit:
	git add -A
	git commit ${INITIAL_COMMIT_OPTIONS} -m "$$INITIAL_PROJECT_COMMIT_MSG"

.git-ipynb-filter-config:
	git config --local filter.dropoutput_ipynb.clean \
        scripts/ipynb_output_filter.py
	git config --local filter.dropoutput_ipynb.smudge cat

# Since Makefiles mix tabs and spaces, the default 8 spaces is too large
.git-pager-config:
	git config --local core.pager 'less -x4'

# Testing {{{1
.PHONY: test

# The way I have it designed currently, each test independently saves
# git's state and restores it in the end with an exit trap.
# TODO: Make the _test branch once; each script checks if it's in it, but
# otherwise leaves well-enough alone.
test:
	bash t/run_tests.sh t

test-%:
	bash t/run_tests.sh t/$*

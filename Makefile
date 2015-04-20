# Preface {{{1
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
			(1) submodules
			(2) venv
			(3) python-reqs
			(3) data-dirs
			(4) configure git to automatically clean IPython notebooks;
			(5) remove the 'origin' git remote;
			(6) squash the commit history into a single 'Initial commit';
			(7) create `.initialized` to indicate that these steps are
			    completed.

	submodules
		Initialize and update all git submodules (see `.gitmodules`).

	venv
		Create the virtualenv if absent.

	python-reqs
		Install all python requirements from requirements.txt and
		all <SUBMODULE>/requirements.txt to the venv.

	data-dirs
		Create all data directories listed in $${DATA_DIRS}
		Default: raw/ seq/ tre/ img/ fig/ res/

EXAMPLES
	make init  # Initialize the project.
	make all   # Carry out all defined steps in the project.

NOTE
	Sensitive data should not be included in `Makefile`, since that
	file is frequently version controlled.  Instead `local.mk` is included so
	that sensitive values can be included and then referenced as variables.

GNU MAKE HELP:


endef
export HELP_MSG


# ========================
#  Standard Configuration
# ========================
# One failing step in a recipe causes the whole recipe to fail.
.POSIX:

# Don't delete intermediate files.
.SECONDARY:

# The target `all` needs to be the first one defined (besides special
# targets) in order for it to be made on running `make` without a target.
.PHONY: all
all:

HELP_TRGTS = help h HELP Help
.PHONY: ${HELP_TRGTS}
${HELP_TRGTS}:
	@echo "$$HELP_MSG" "$$(${MAKE} -h)" | less

# All recipes are run as though they are within the virtualenv.
VENV = ./venv
export VIRTUAL_ENV = $(abspath ${VENV})
export PATH := ${VIRTUAL_ENV}/bin:${PATH}

DATA_DIRS = etc/ ipynb/ raw/ meta/ res/ fig/

# Use this file to include sensitive data that shouldn't be version controlled.
-include local.mk

# ====================}}}
#  User Configuration {{{0
# ====================
# Use the following line to add project directories with executibles
# to the `make` recipe path:
# export PATH := <BIN-DIR-A>:<BIN-DIR-B>:${PATH}

# Use the following line to add files to be deleted on `make clean`:
CLEANUP = ${ALL_DOCS_HTML}

# What directories to generate on `make data-dirs`.
# By default, already includes etc/ ipynb/ raw/ meta/ res/ fig/
# DATA_DIRS += seq/ tre/ img/

# Add prerequisites to the major phony targets.
.PHONY: docs figs res
docs: ${ALL_DOCS_HTML}
figs:
res:

# What files are generated on `make all`?
all: docs figs res

# }}}
# ==============
#  Data Recipes
# ==============
# User defined recipes for cleaning up and initially parsing data.
# e.g. Slicing out columns, combining data sources, alignment, generating
# phylogenies, etc.


# =======================
#  Analysis Recipes
# =======================
# User defined recipes for analyzing the data.
# e.g. Calculating means, distributions, correlations, fitting models, etc.
# Basically anything that *could* go into the paper as a table.


# ==================
#  Graphing Recipes
# ==================
# User defined recipes for plotting figures.  These should use
# the targets of analysis recipes above as their prerequisites.


# =======================
#  Documentation Recipes {{{1
# =======================
TEMPLATE = TEMPLATE
NOTE = NOTE
TODO = TODO
ALL_DOCS = ${TEMPLATE} ${NOTE} ${TODO}
ALL_DOCS_HTML = $(addsuffix .html,${ALL_DOCS})

%.html: %.md
	cat $^ \
	| pandoc -f markdown -t html5 -s \
				--highlight-style pygments --mathjax \
				--toc --toc-depth=4 \
				--css static/main.css \
	> $@

# =================
#  Cleanup Recipes {{{1
# =================
.PHONY: clean
clean:
	rm -f ${CLEANUP}

# ========================
#  Initialization Recipes {{{1
# ========================
.PHONY: init
init: .git/.initialized
.git/.initialized:
	@${MAKE} submodules
	@${MAKE} venv
	@${MAKE} python-reqs
	@${MAKE} data-dirs
	@${MAKE} .link-readme
	@${MAKE} .ipynb-filter-config
	-@${MAKE} .git-mangle
	touch $@

.PHONY: venv submodule python-reqs data-dirs
venv:
	[ -f $@ ] || python3 -m venv ${VENV}

# Git Submodules:
SUBMODULE_DIRS := $(shell git submodule | sed 's:^ ::' | cut -d" " -f2)
SUBMODULES = $(patsubst %,%/.git,${SUBMODULE_DIRS})

submodules: ${SUBMODULES}
${SUBMODULES}: .gitmodules
	git submodule update --init --recursive ${@D}

SUBMODULE_PIP_REQS = $(wildcard $(patsubst %,%/requirements.txt,${SUBMODULE_DIRS}))
PIP_REQS = requirements.txt ${SUBMODULE_PIP_REQS}

python-reqs: venv
	for req_file in ${PIP_REQS} ; do \
		pip install --upgrade --no-deps -r $$req_file ; \
		pip install -r $$req_file ; \
	done

data-dirs:
	mkdir -p ${DATA_DIRS}

.PHONY: .link-readme .confirm-git-mangle \
		.git-mangle .ipynb-filter-config
.link-readme:
	unlink README.md
	ln -s NOTE.md README.md

define INIT_OPTS_MSG

You are about to remove the remote repository labeled 'origin' and squash the
commit history into a single commit.  This procedure makes sense for
initializing a new project from a template project, where the history of the
template is unimportant and you do not want to push or pull changes to the
remote repository from which you cloned the template.

Alternatively, if you are initializing a previously started project, you most
likely do not want to lose the commit history, and you may want to push or pull
changes from the remote.  In that case, respond with something other than "y"
or "Y" to the following prompt.  `make` will thow an error, but initialization
will work as intended.

endef
export INIT_OPTS_MSG

.confirm-git-mangle:
	@echo
	@echo "$$INIT_OPTS_MSG"
	@echo
	@read -rp "Are you sure you want to remove the remote and squash the commit history? [y/N]: " MANGLE ; \
	[ $$MANGLE == "y" ] || [ $$MANGLE == "Y" ]

.git-mangle: .confirm-git-mangle
	git remote remove origin
	git branch -m master
	git reset --soft $$(git rev-list --max-parents=0 HEAD)
	git add -A
	git commit --amend -m "Initial commit."

%/requirements.txt: %/.git

# IPython Notebook Output Filter Configuration
bin/utils/ipynb_output_filter.py: bin/utils/.git

.ipynb-filter-config: bin/utils/ipynb_output_filter.py
	git config --local filter.dropoutput_ipynb.clean bin/utils/ipynb_output_filter.py
	git config --local filter.dropoutput_ipynb.smudge cat

# Preface {{{1
define HELP_MSG

================================
 Analysis Makefile Documentation
================================

SYNOPSIS
	Run project operations using make commands.

TARGETS
	all
		Generate all figures and documentation based on user-defined recipes.

	docs
		Compile markdown files (e.g. NOTE.md, TEMPLATE.md) into HTML (uses
		Pandoc).

	figs
		Carry out the pipeline to ultimately generate figures of the results.

	help
		Show this help message.

	init
		Initialize the project:
			(1) make submodules
			(2) make venv
			(3) configure git to automatically clean IPython notebooks;
			(4) remove the 'origin' git remote;
			(5) squash the commit history into a single 'Initial commit';
			(6) create `.initialized` to indicate that these steps are
			    completed.

	submodules
		Initialize and update all git submodules (see `.gitmodules`).

	venv
		Create the virtualenv if absent.

	python-reqs
		Install all python requirements from requirements.txt and
		all <SUBMODULE>/requirements.txt to the venv.

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

# Use this file to include sensitive data that shouldn't be version controlled.
-include local.mk

# ========================
#  Standard Configuration
# ========================
VENV = ./venv

# One failing step in a recipe causes the whole recipe to fail.
.POSIX:

# Don't delete intermediate files.
.SECONDARY:

.PHONY: all figs
all:   docs figs
figs:

HELP_TRGTS = help h HELP Help
.PHONY: ${HELP_TRGTS}
${HELP_TRGTS}:
	@echo "$$HELP_MSG" "$$(${MAKE} -h)" | less

export VIRTUAL_ENV = $(abspath ${VENV})
export PATH := ${VIRTUAL_ENV}/bin:${PATH}

# }}}

# ====================
#  User Configuration
# ====================

# Use the following template to add directories with executibles to the
# `make` recipe path.
# export PATH := <BIN-DIR>:${PATH}


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
# All directories which are part of the project (since all of these might have
# documentation and notes to be compiled.)
PROJ_DIRS := $(shell find . \( -name ".git" \) -prune -o -type d -print)

TEMPLATE = TEMPLATE
TEMPLATE_MD_NAME = ${TEMPLATE}.md
TEMPLATE_MD_MAIN = ./${TEMPLATE_MD_NAME}
TEMPLATE_MD_AUX = $(foreach d,${PROJ_DIRS}, $(wildcard ${d}/${TEMPLATE_MD_NAME}))
TEMPLATE_MD_PREX = ${TEMPLATE_MD_MAIN} ${TEMPLATE_MD_AUX}
TEMPLATE_HTML = ${TEMPLATE}.html

NOTE = NOTE
NOTE_MD_NAME = ${NOTE}.md
NOTE_MD_MAIN = ./${NOTE_MD_NAME}
NOTE_MD_AUX = $(foreach d,${PROJ_DIRS}, $(wildcard ${d}/${NOTE_MD_NAME})) ${TODO_MD_MAIN}
TODO = TODO
TODO_MD_MAIN = TODO.md
NOTE_MD_PREX = ${NOTE_MD_MAIN} ${NOTE_MD_AUX} ${TODO_MD_MAIN}
NOTE_HTML = ${NOTE}.html

ALL_DOCS_HTML = ${TEMPLATE_HTML} ${NOTE_HTML}

.PHONY: docs
docs: ${ALL_DOCS_HTML}

MD2HTML = \
cat $^ \
| pandoc -f markdown -t html5 -s \
			--highlight-style pygments --mathjax \
			--toc --toc-depth=4 \
			--css static/main.css \
> $@

${TEMPLATE_HTML}: ${TEMPLATE_MD_PREX}
	${MD2HTML}

${NOTE_HTML}: ${NOTE_MD_PREX}
	${MD2HTML}

# =================
#  Cleanup Recipes {{{1
# =================
.PHONY: clean
clean:
	rm -f ${ALL_DOCS_HTML} ${CLEANUP}

# ========================
#  Initialization Recipes {{{1
# ========================
SEMAPHORE = .git/.initialized
init: initialization ${SEMAPHORE}

initialization: venv submodules
	@${MAKE} python-reqs

${SEMAPHORE}:
	unlink README.md
	ln -s NOTE.md README.md
	@${MAKE} _ipynb_filter
	@${MAKE} _remove_remote
	@${MAKE} _squash_history

_remove_remote:
	@set -e ; \
	while [ -z "$$UNREMOTE" ] ; do \
		read -rp "Would you like to unset the remote repository? [y/N]: " UNREMOTE ; \
	done ; \
	if [ $$UNREMOTE != "y" ] && [ $$UNREMOTE != "Y" ] ; then \
		: ; \
	else \
		echo "git remote remove origin" ; \
		git remote remove origin ; \
	fi

_squash_history:
	@set -e ; \
	while [ -z "$$SQUASH" ] ; do \
		read -rp "Would you like to squash the commit history? [y/N]: " SQUASH ; \
	done ; \
	if [ $$SQUASH != "y" ] && [ $$SQUASH != "Y" ] ; then \
		: ; \
	else \
		echo "git branch -m master" ; \
		git branch -m master ; \
		echo "git reset --soft $$(git rev-list --max-parents=0 HEAD)" ; \
		git reset --soft $$(git rev-list --max-parents=0 HEAD) ; \
		echo "git add -A" ; \
		git add -A ; \
		echo "git commit --amend -m 'Initial commit.'" ; \
		git commit --amend -m "Initial commit." ; \
	fi



# Git Submodules:
SUBMODULE_DIRS := $(shell git submodule | sed 's:^ ::' | cut -d" " -f2)
SUBMODULES = $(patsubst %,%/.git,${SUBMODULE_DIRS})
SUBMODULE_PIP_REQS = $(wildcard $(patsubst %,%/requirements.txt,${SUBMODULE_DIRS}))

submodules: ${SUBMODULES}

${SUBMODULES}: .gitmodules
	git submodule update --init --recursive ${@D}

bin/utils/ipynb_output_filter.py: bin/utils/.git

_ipynb_filter:
	@${MAKE} bin/utils/ipynb_output_filter.py
	# Configure IPYNB output filtering
	git config --local filter.dropoutput_ipynb.clean bin/utils/ipynb_output_filter.py
	git config --local filter.dropoutput_ipynb.smudge cat

# Python virtual environment recipes:
.PHONY: venv
venv: ${VENV}/bin/activate

${VENV}/bin/activate:
	[ -f $@ ] || python3 -m venv ${VENV}
	touch $@

PIP_REQS = requirements.txt ${SUBMODULE_PIP_REQS}
python-reqs: venv ${PIP_REQS}
	for req_file in ${PIP_REQS} ; do \
		pip install --upgrade -r $$req_file ; \
	done

%/requirements.txt: %/.git

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
		Initialize and update all requirements.

	venv
		Create the virtualenv if absent and install from `requirements.txt`.

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
init: venv submodules ${SEMAPHORE}
	${MAKE} _install_python_reqs


# Base initialization recipes:
define CONFIRM_SQUASH

You are initializing a new project from the current repository. If you would
like to treat this repository as a template then the entire previous commit
history will be squashed into a single initial commit and the git remote will
be removed to ensure that you don't push changes to the template.  If, instead,
you are initializing from a prior project, you most likely do NOT want the
commit history to be squashed.  The remote will also be retained."

endef
export CONFIRM_SQUASH

${SEMAPHORE}: .git/config
	unlink README.md
	ln -s NOTE.md README.md
	@set -e ; \
	while [ -z "$$SQUASH" ] ; do \
		echo "$$CONFIRM_SQUASH" ; \
		read -rp "Would you like to squash the commit history? [y/N]: " SQUASH ; \
	done ; \
	if [ $$SQUASH != "y" ] && [ $$SQUASH != "Y" ] ; then \
		: ; \
	else \
		${MAKE} _remove_remote; \
		${MAKE} _squash_history; \
	fi
	touch $@

_remove_remote:
	-git remote remove origin

_squash_history:
	git branch -m master
	git reset --soft $$(git rev-list --max-parents=0 HEAD)
	git add -A
	git commit --amend -m "Initial commit."


# Git Submodules:
SUBMODULE_DIRS := $(shell git submodule | sed 's:^ ::' | cut -d" " -f2)
SUBMODULES = $(patsubst %,%/.git,${SUBMODULE_DIRS})
SUBMODULE_PIP_REQS = $(wildcard $(patsubst %,%/requirements.txt,${SUBMODULE_DIRS}))

submodules: ${SUBMODULES}

${SUBMODULES}: .gitmodules
	git submodule update --init --recursive ${@D}

bin/utils/ipynb_output_filter.py: bin/utils/.git

.git/config: bin/utils/ipynb_output_filter.py
	# Configure IPYNB output filtering
	git config --local filter.dropoutput_ipynb.clean bin/utils/ipynb_output_filter.py
	git config --local filter.dropoutput_ipynb.smudge cat
	touch $@

# Python virtual environment recipes:
.PHONY: venv
venv: ${VENV}/bin/activate

${VENV}/bin/activate:
	[ -f $@ ] || python3 -m venv ${VENV}
	touch $@

PIP_REQS = requirements.txt ${SUBMODULE_PIP_REQS}
_install_python_reqs: ${PIP_REQS}
	for req_file in ${PIP_REQS} ; do \
		pip install --upgrade -r $$req_file ; \
	done

%/requirements.txt: %/.git

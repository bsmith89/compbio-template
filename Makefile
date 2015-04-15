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


# ========================
#  Standard Configuration
# ========================
VENV = ./venv

# One failing step in a recipe causes the whole recipe to fail.
.POSIX:

# Don't delete intermediate files.
.SECONDARY:

# The target `all` needs to be the first one defined (besides special
# targets) in order for it to be made on running `make` without a target.
.PHONY: all docs figs res
all:
docs:
figs:
res:

HELP_TRGTS = help h HELP Help
.PHONY: ${HELP_TRGTS}
${HELP_TRGTS}:
	@echo "$$HELP_MSG" "$$(${MAKE} -h)" | less

# All recipes are run as though they are within the virtualenv.
export VIRTUAL_ENV = $(abspath ${VENV})
export PATH := ${VIRTUAL_ENV}/bin:${PATH}

# }}}

# ====================
#  User Configuration
# ====================

# Use this file to include sensitive data that shouldn't be version controlled.
-include local.mk

# Use the following line to add project directories with executibles
# to the `make` recipe path:
# export PATH := <BIN-DIR-A>:<BIN-DIR-B>:${PATH}

# Use the following line to add files to be deleted on `make clean`:
CLEANUP +=

# What files are generated on `make all`?
all: docs figs res

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

define MD2HTML
cat $^ \
| pandoc -f markdown -t html5 -s \
			--highlight-style pygments --mathjax \
			--toc --toc-depth=4 \
			--css static/main.css \
> $@
endef

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
.PHONY: init
init: .git/.initialized
.git/.initialized:
	@${MAKE} submodules
	@${MAKE} venv
	@${MAKE} python-reqs
	@${MAKE} .link-readme
	@${MAKE} .ipynb-filter-config
	-@${MAKE} .git-mangle
	touch $@

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
changes from the remote.

endef
export INIT_OPTS_MSG

.confirm-git-mangle:
	@echo
	@echo $$INIT_OPTS_MSG
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

.PHONY: venv submodule python-reqs
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


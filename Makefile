# ---------------
#  Configuration
# ---------------
PYTHON = venv/bin/python
PYTHON3 = venv/bin/python3

# All directories which are part of the project (since all of these might have
# documentation and notes to be compiled.)
PROJ_DIRS = $(shell find . \( -name ".git" \) -prune -o -type d -print)


# ------------------
#  Special Targets
# ------------------
# This special target means that the first failing command in a recipe will
# cause the whole recipe to fail.
.POSIX:

# Some recipes don't actually make any files:
.PHONY: all docs figs venv

all:   docs figs
figs:

define HELP_MSG

This is a help message for making this project.  It has not been written yet.
echo things

endef
export HELP_MSG
help:
	@echo "$$HELP_MSG"

# --------------
#  Data Recipes
# --------------

# -----------------------
#  Analysis Recipes
# -----------------------

# -----------------------
#  Documentation Recipes
# -----------------------
ALL_DOCS_MD = $(foreach d,${PROJ_DIRS}, $(wildcard ${d}/*.md))
ALL_DOCS_HTML = $(patsubst %.md,%.html, ${ALL_DOCS_MD})

docs: ${ALL_DOCS_HTML}

MD2HTML = \
cat $< \
| pandoc -f markdown -t html5 -s \
			--highlight-style pygments --mathjax \
			--toc --toc-depth=4 \
			--css static/main.css \
> $@

%.html: %.md
	${MD2HTML}

# ------------------------
#  Initialization Recipes
# ------------------------
SEMAPHORE = .initialized
init: venv ${SEMAPHORE}

define CONFIRM_SQUASH

You are initializing a new project from the current repository. If you would
like to treat this repository as a template then the entire previous commit
history will be squashed into a single initial commit and the git remote will
be removed to ensure that you don't push changes to the template.  If, instead,
you are initializing from a prior project, you most likely do NOT want the
commit history to be squashed.  The remote will also be retained."

endef
export CONFIRM_SQUASH

# Base initialization recipes:
${SEMAPHORE}: .git/config
	unlink README.md
	ln -s NOTE.md README.md
	@while [ -z "$$SQUASH" ] ; do \
		echo "$$CONFIRM_SQUASH" ; \
		read -rp 'Would you like to squash the commit history? [y/N]: ' SQUASH ; \
	done ; \
	if [ $$SQUASH != "y" ] && [ $$SQUASH != "Y" ] ; then \
		: ; \
	else \
		make _remove_remote; \
		make _squash_history; \
	fi
	touch $@
	

_remove_remote:
	git remote remove origin

_squash_history:
	git reset --soft $$(git rev-list --max-parents=0 HEAD)
	git add -A
	git commit --amend -em "Initial commit"

# Git submodule recipes:
SUBMODULES = scripts/utils/.git
submodules: ${SUBMODULES}

${SUBMODULES}: .gitmodules
	git submodule update --init --recursive ${@D}
	touch $@

scripts/utils/ipynb_output_filter.py: scripts/utils/.git

.git/config: scripts/utils/ipynb_output_filter.py
	# Configure IPYNB output filtering
	git config --local filter.dropoutput_ipynb.clean \
					   scripts/utils/ipynb_output_filter.py
	git config --local filter.dropoutput_ipynb.smudge cat
	touch $@

# Python virtual environment recipes:
venv: venv/bin/activate

PIP_REQUIREMENTS = requirements.pip scripts/utils/requirements.pip
venv/bin/activate: ${PIP_REQUIREMENTS}
	[ -f $@ ] || python3 -m venv venv
	source $@ ; \
	for req_file in ${PIP_REQUIREMENTS} ; do \
		pip install -r $$req_file ; \
	done
	touch $@

scripts/utils/requirements.pip: scripts/utils/.git

# -----------------
#  Cleanup Recipes
# -----------------
clean:
	rm -f ${ALL_DOCS_HTML}

# ====================
#  Project Makefile
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
VENV = .venv

# Documentation settings {{{2
BIB_FILE=doc/main.bib

# Cleanup settings {{{2
# Use the following line to add files and directories to be deleted on `make clean`:
CLEANUP +=

# Initialization settings {{{2
# What directories to generate on `make data-dirs`.
# By default, already includes etc/ ipynb/ raw/ meta/ res/ fig/
DATA_DIRS +=

# FINALLY: Include base makefile {{{2
include base.mk

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

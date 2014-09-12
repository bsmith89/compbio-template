# Computation Biology Project Template #
## Directory Structure and Conventions ##
In order to make projects more rational, here I define a standard
directory/file structure which is intended to be universal for computational
biology projects.

## Requirements ##
 -  [`pandoc`](http://johnmacfarlane.net/pandoc/) (1.13.1+)
    -  to compile markdown files into pretty html

## Directory/Workflow Conventions ##
### `NOTES.md` ###
This is the core notebook for the project.
All experiments and conclusions should be clearly described in the
"Notebook" section below.
Along with the project's `Makefile`, this notebook should allow you to
run and understand the entire analysis which was carried out.

### `Makefile` ###
The entire workflow of the analysis.

Reproduce the full analysis with a single command:

```bash
$ make all
```

### `raw/` ###
All of the raw (meta)data needed to recreate the entire analysis.
This should be kept in the exact same format as it is available publicly.
While these files are not version controlled, they _should_ all be available
in an online repository.

### `raw/NOTES.md` ###
 -  Required: Describes (in detail) where all of the data came from.
 -  Good: Instructions for retrieving all of the data from an online
    repository.
 -  Great: Recipe for data retrieval included in `Makefile`.

### `meta/` ###
All of the experiment metadata, formatted conveniently for downstream analysis.
Tab separated values (`.tsv`) is the preferred format.
The files in this directory are usually minimally processed versions of
the original metadata files stored in `raw/`.

### `seq/` ###
Intermediate analysis files which contain sequence.
The extension portion of these file names should indicate the format of the
data, while the `.` separated words which make up the file name loosely
describe the workflow used to produce the file.

For example: `16S.ungap.afn` would be FASTA formatted multiple nucleotide
sequence alignment (`.afn`) which has had all gap positions
removed (`.ungap.`).

### `tre/` ###
Intermediate analysis files which contain phylogenetic or taxonomic trees.
As above, the extension describes the file format and the `.` separated
parts of the name describe the workflow.

For example: `16S.afn.ungap.nwk` is a Newick formatted phylogenetic tree
generated from `seq/16S.ungap.afn`.

### `res/` ###
Any intermediate results which cannot be easily placed in another directory.
For instance, a TSV of pairwise sequence distances.

### `res/NOTES.md` ###
Description of the intermediate results and what they're good for.

### `static/` ###
Files (usually images) which are included in notebooks.
These files are version controlled, so that a respository (e.g. github)
can compile the notebook with the images.
Despite being version controlled, they should never change: no diffing binary
data!
Future analysis may completely remove the workflow which produced these files,
but, in order to record the research process, the results are maintained in
this folder.

### `bin/` ###
Executable files which carry out any parts of the pipeline requiring more
than a `Makefile` recipe.


### `bin/*` ###
These scripts (and source code to be compiled) _are_ version controlled,
unlike data files.
Scripts should be well documented.

 -  Required: Each script has a docstring (comment at the top after the
    shebang) which describes the use of the script from the command line.
 -  Good: Scripts are well commented, explaining the logic of any difficult
    to understand code.
 -  Great: Scripts are designed with full help text, conforming to POSIX
    standards.

Scripts should take any data which only needs to be used once from STDIN.
If this can be accomplished in multiple ways scripts should take the largest
files (usually a sequence file) from STDIN and smaller metadata files as
positional arguments.
This is designed to make streaming pipelines an easy transition.

Scripts should be designed for portability.

 -  Required: Scripts accept all input data externally.
    Data files are _not_ hard coded into the script.
 -  Good: Variable parameters of the analysis are accepted as positional
    arguments, and options.
    Logical defaults are acceptable.
    Parameters are _not_ hard-coded into the scripts.
 -  Great: Scripts are constructed in a modular design.
    e.g. Python scripts divide logical chunks into "public" functions so that
    those parts can be imported by other scripts.

### `ipynb/` ###
IPython notebooks, useful for fast prototyping and exploratory analysis.
They are _not_ good for version control, since they include a bunch of the
output data in the same file.
They are also not conducive to reproducing a result after external files
and directories have been changed.
This is largely because they have file paths hard-coded in.
IPYNBs should be used kinda like the 'Notebook' section of this document;
They are a record of a thought-process/workflow, but are not guarenteed to
execute the same way after subsequent commits.
Instead, important analyses should be ported over to version controlled
scripts.

### `ipynb/*` ###
Notebooks start with `cd ..`; all code is run from the project's root
directory.

Before being committed to git, IPYNBs should have their output and line
numbers wiped, so as to avoid committing binary data, or arbitrary changes;
re-running your notebook shouldn't change it in the eyes of git.
To do this in an automated fashion, see
[this git smudge/clean filter](http://github.com/bsmith89/ipynb-outfilt).

### `fig/` ###
Finished figures.
"Publishable" output of analysis.

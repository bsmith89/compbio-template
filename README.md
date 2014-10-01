# Computation Biology Project Template #
In order to make projects more rational, here I define a standard
project structure which is intended to be universal for computational
biology projects.

## Notes ##
_All files which describe the project are version controlled._

### `NOTES.md` ###
This is the core notebook for the project.
All experiments and conclusions should be clearly described in the
"Notebook" section below.
Along with the project's `Makefile`, this notebook should allow you to
run and understand the entire analysis which was carried out.

### `TODO.md` ###
What is left to do in this project.

### `README.md` ###
This file, describing the layout of the project.

### `static/` ###
Files (usually images) which are included in notebooks.
These files are version controlled, so that a respository (e.g. github)
can compile the notebook with the images.
Despite being version controlled, they should never change: no diffing binary
data!
Future analysis may completely remove the workflow which produced these files,
but, in order to record the research process, the results are maintained in
this folder.

`main.css` is used in the compilation of HTML versions of notes written in
markdown.

## Code ##
_All project code is version controlled._

### `Makefile` ###
The entire workflow of the analysis.

Reproduce the full analysis with a single command:

```bash
$ make all
```

Any data processing which is computationally intensive should save intermediate
files in order to utilize `make`'s piece-wise build.

### `bin/` ###
Executable files which carry out any parts of the pipeline requiring more
than a `Makefile` recipe.
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
If this can be accomplished in multiple ways, one rule of thumb is for  scripts
to take the largest files (usually a sequence file) from STDIN and smaller
metadata files as positional arguments.
This is designed to make streaming pipelines an easy transition.

Scripts should be designed for portability.

 -  Good: Scripts accept all input data externally.
    Data files are _not_ hard coded into the script.
 -  Great: Variable parameters of the analysis are accepted as positional
    arguments, and options.
    Logical defaults are acceptable.
    Parameters are _not_ hard-coded into the scripts.
 -  Greatest: Scripts are constructed in a modular design.
    e.g. Python scripts divide logical chunks into "public" functions so that
    those parts can be imported by other scripts.

### `bin/fig/` ###
Executable scripts which _normally_:

 -  Produce figures in PDF format, saving them to `fig/`;
 -  Require intermediate results in a tabular format produced by code in
    `bin/` and saved in `res/`;
 -  Have the same file name (minus the extension) as the figure produced.

### `bin/pbs/` ###
Scripts to be submitted to `qsub` of the PBS batch computing system.
These are used to carry out computationally intensive steps in the analysis
pipeline.
They do not replace, however, `Makefile` as a complete description of the
pipeline.
Perhaps best practice would be to just set up the environment and then run
`make` directly...?

e.g. `example.pbs`:

```bash
#!/usr/bin/env sh
#PBS -V
#PBS -m a
#PBS -l nodes=4:ppn=4,walltime=10:00:00,pmem=500mb

# Change to the directory from which the job was submitted.
cd ${PBS_O_WORKDIR}

# Activate a python virtual environment.
source ~/.virtualenvs/compbioenv/bin/activate

# Run make to produce a particular output.
# Alternatively, you could run the entire analysis in this script.
make tre/computationally_difficult.nwk
# Consider using make's '-o' flag to prevent regenerating requirement files.

```

### `ipynb/` ###
IPython notebooks, useful for fast prototyping and exploratory analysis.
They are _not_ good for version control, since they include a bunch of the
output data in the same file.
They are also not conducive to reproducing a result after external files
and directories have been changed.
This is largely because they have file paths hard-coded in.
IPYNBs should be used kinda like the `NOTES.md` files;
They are a record of a thought-process/workflow, but are not guarenteed to
execute the same way after subsequent commits.
Instead, important analyses should be ported over to version controlled
scripts.

Before being committed to git, IPYNBs should have their output and line
numbers wiped, so as to avoid committing binary data, or arbitrary changes;
re-running your notebook shouldn't change it in the eyes of git.
To do this in an automated fashion, see
[this git smudge/clean filter](https://gist.github.com/bsmith89/4a32efdeda6495d2ba4e).

## Configuration ##
_All configuration files are version controlled._

This lets me change particular components in just one place.
Anyone who forks the template or any project based on it will then have the
same configuration.

### `profile_default/` ###
A custom IPython profile
which changes a few things from the built-in default:

 -  IPython notebooks display figures inline by default;
 -  The default editor is full `vim`;
 -  Tab completion is more like `bash`;
 -  Running `ipython notebook` from the command line is convenient;
    -  This will start a server in the `ipynb/` subdirectory;
    -  When `ipython` kernels are subsequently started, the current working directory
       is changed to the root of the project (i.e. `cd ..`).

See
[IPython's documentation](http://ipython.org/ipython-doc/dev/config/intro.html).

### `matplotlibrc` ###
A custom matplotlib profile for compbio projects.
This lets me change particular components of matplotlib plotting in one place.
All figures will have the same config.

See
[matplotlib's documentation](http://matplotlib.org/users/customizing.html).


## Data ##
_Data is not version controlled._

Instead, it should be easy to regenerate data, by downloading raw data from
an external repository and then re-running the pipeline.

### `raw/` ###
All of the raw (meta)data needed to recreate the entire analysis.
This should be kept in the exact same format as it is available publicly.
While these files are not version controlled, they _should_ all be available
in an online repository.

`raw/NOTES.md` describes everything a third party (including yourself in
a month) needs to know about the raw data.

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
This nameing scheme is not a replacement for both liberal note-taking
and coding the pipeline into the `Makefile`.

For example: `16S.align.ungap.afn` would be multiple
sequence alignment (`.align.`) in nuceotide FASTA format (`.afn`)
which has had all gap positions removed (`.ungap.`).

### `tre/` ###
Intermediate analysis files which contain phylogenetic or taxonomic trees.
As above, the extension describes the file format and the `.` separated
parts of the name describe the workflow.

For example: `16S.afn.ungap.nwk` is a Newick formatted phylogenetic tree
generated from `seq/16S.ungap.afn`.

### `res/` ###
Any intermediate results which cannot be easily placed in another directory.
For instance, a TSV of pairwise sequence distances.

A description of the intermediate results and what they're good for can be
found in `res/NOTES.md`.


## Final Results ###
_Final results are not version controlled._

### `fig/` ###
Finished figures.
"Publishable" output of analysis.

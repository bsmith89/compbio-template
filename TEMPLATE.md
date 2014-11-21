---
title: "Computation Biology Project Template"
author: "[Byron J. Smith](http://byronjsmith.com/)"
...

In order to make projects more rational, here is a standard
project structure which is intended to be a superset of most computational
biology projects.

A git repository which implements this template is available
[on Github](http://github.com/bsmith89/compbio-template).

# Quick Start #

```bash
# Clone the *template* and initialize
git clone https://github.com/bsmith89/compbio-template new-project
make init_from_template
# ---OR---
# Clone a *project* and initialize
git clone http://github.com/USERNAME/compbio-project new-project
make init_from_project


# Remove unneeded directories and files from the repository.
# e.g. if not analyzing images, sequence data, or phylogenetic trees:
git rm -r img/ seq/ tre/

# Optional: Make a python virtual environment
python3 -m venv env
source env/bin/activate

# Install required python packages
pip3 install -r requirements.pip -r scripts/utils/requirements.pip
# Don't forget to install requirements for the scripts/utils submodule

```


# Example Workflow #

```bash
# Name the project; write a description;
# create a preliminary list of objectives.
vim NOTES.md TODO.md

# Download raw data from an online repository
cd raw/
curl -O http://mydata.com/raw/seq.tgz
tar -xzvf seq.tgz
cd ..

# Write a thorough description of the raw data
vim raw/NOTE.md

# Write a recipe (or two) to recreate the download protocol
vim Makefile

# Move and standardize naming of data files.
cp raw/seq/sample1.fn seq/sample001.fn

# Move and reformat the metadata.
cat raw/seq/metadata.tsv | sed '1,1d' > meta/samples.tsv

# Write makefile recipes for these operations.
vim Makefile

# Describe and commit progress
vim NOTE.md
git add raw/NOTE.md Makefile NOTE.md
git commit -m "Downloaded and described data."

# Run data through an analysis pipeline (e.g. an all-by-all BLASTx)
makeblastdb -in seq/sample001.fn -input_type fasta
blastx -db seq/sample001 -query seq/sample001.fn \
       -outfmt '6 qseqid sseqid evalue'
       -out res/sample001.all_way.blastx_out
vim Makefile  # Write makefile recipes for the above.

# Prototype an analysis on this data.
ipython3 notebook

# Describe what was done, including an output figure.
vim NOTE.md
mv fig/histogram.png static/2014-11-17_fig1.png

# Commit this progress
git add static/2014-11-17_fig1.png NOTE.md
git commit -m "Updated notes with a prototyped analysis."

# Write a script to do this analysis reproducibly
vim scripts/analysis.py
chmod +x scripts/analysis.py
cat res/sample001.all_way.blastx_out \
    | scripts/analysis.py
    > res/sample001.all_way.blastx_out.analysis.tsv

# Add a recipe to run the analysis
vim Makefile
git add scripts/analysis.py Makefile
git commit -m "Script to carry out analysis."

# Additional analysis
# ...
# ...

# Publish the project to github
git remote add origin git@github.com:USERNAME/new-project.git
git push -u origin

```

# User Guide and Project Structure#
## Notes Files ##
_All files which describe the project are version controlled._

Notes files are written in
[Pandoc Markdown][pdmd]
and may be compiled for reading.
(A recipe to compile markdown files into HTML is defined in the Makefile.)

[pdmd]: <http://johnmacfarlane.net/pandoc/demo/example9/pandocs-markdown.html>

This default recipe includes a script
for rendering LaTeX math in attractive typeset.
This should work
--- as long as there's an internet connection ---
for either inline math ($\chi^2$, for instance) or blocks of math:

$$
\chi^2
$$

-  `NOTE.md`

    This is the core notebook for the project.
    All experiments and conclusions should be clearly described in the
    "Notebook" section below.
    Along with the project's `Makefile`, this notebook should allow a 3rd party
    to run and understand the entire analysis which was carried out.

-  `TODO.md`

    List of remaining tasks.

-  `TEMPLATE.md`

    This file, describing how to use the template and the project's
    directory structure.
    Additional `*/TEMPLATE.md` files serve as directory placeholders for git
    and describe consistant naming schemes for particular file types.

-  `static/`

    Files (usually images) which are included in notebooks.
    These files are version controlled, so that a remote
    repository (e.g. github) can compile the notebook with the images.
    Despite being version controlled, they should never change:
    no diffing binary data!
    Future analysis may completely remove the workflow which produced
    these files,
    but, in order to record the research process,
    the results are maintained in this folder.

-  `static/main.css`

    Used in the compilation of HTML versions of notes written in
    markdown.

## Code ##
_All project code is version controlled._

-  `Makefile`

    Ideally, the entire analysis.
    Reproduce the full analysis with a single command:

    ```bash
    $ make all

    ```

    Any data processing which is computationally intensive should save
    intermediate files in order to utilize `make`'s piece-wise build.

-  `scripts/`

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
    If this can be accomplished in multiple ways, one rule of thumb is for
    scripts to take the largest files (usually a sequence file) from STDIN and
    smaller metadata files as positional arguments.
    This is designed to make streaming pipelines an easy transition.

    Scripts should be designed for portability.

    -  Good: Scripts accept all input data externally.
       Data files are _not_ hard coded into the script.
    -  Great: Variable parameters of the analysis are accepted as positional
       arguments, and options.
       Logical defaults are acceptable.
       Parameters are _not_ hard-coded into the scripts.
    -  Greatest: Scripts are constructed in a modular design.
       e.g. Python scripts divide logical chunks into "public" functions so
       that those parts can be imported by other scripts.

    Scripts for which all of these recommendations are met,
    and where the routine may be useful in other projects,
    are great candidates for inclusion in the `scripts/utils/` submodule.

-  `scripts/utils/`

    A [git submodule](http://git-scm.com/book/en/Git-Tools-Submodules)
    of utility scripts and executables.

    Any analysis scripts that can be used by other projects should ultimately
    end up in this [repository](https://github.com/bsmith89/compbio-scripts).

-  `scripts/fig`

    Executable scripts which _normally_:
    -  Produce figures in PDF format, saving them to `fig/`;
    -  Require intermediate results in a tabular format, saved in `res/`;
    -  Usually have a name which is identical to or a substring of the figure
        produced.

-  `scripts/pbs/`

    Scripts to be submitted to the PBS batch computing system (`qsub`).
    These are used to carry out computationally intensive steps in the analysis
    pipeline.
    They do not replace, however, `Makefile` as a complete description of the
    pipeline.
    Perhaps best practice would be to just set up the environment and then run
    `make` directly...?

    e.g. example.pbs:

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
    make tre/computationally_difficult.nwk
    # Consider using make's '-o' flag to prevent regenerating requirement
    # files.

    ```

-  `ipynb/`

    IPython notebooks, useful for fast prototyping and exploratory analysis.
    In there raw form, they are _not_ good for version control,
    since they include a bunch of the output data in the same file.
    They are also not conducive to reproducing a result after external files
    and directories have been changed.
    This is largely because they have file paths hard-coded in.
    IPYNBs should be used kinda like the `NOTE.md` files;
    They are a record of a thought-process/workflow, but are not guarenteed to
    execute the same way after subsequent commits.
    Instead, important analyses should be ported over to version controlled
    scripts, and ideally included as recipes in `Makefile`.

    Before being committed to git, IPYNBs should have their output and line
    numbers wiped, so as to avoid committing binary data, or arbitrary changes;
    re-running a notebook shouldn't change it in the eyes of git.
    To do this in an automated fashion, a clean/smudge filter has been included
    in `scripts/utils`, and the initalization recipes in Makefile configure git to
    run the filter when staging files to be commited.
    While this won't erase the output from the local copy of the notebook,
    forks of the project will get an 'un-run' version.

    IPython has been configured (see `profile_default/` below)
    so that starting a notebook server from the
    command line will look for `*.ipynb` files in `ipynb/`,
    but the working directory will be set back to the root directory when a
    notebook is loaded.
    Just calling `ipython3 notebook` from the root directory is best.

## Configuration and Environment ##
_All configuration files are version controlled._

Distributing configuration files with the template,
and version-controlling them in projects allows customization of components
in just one place.
Anyone who forks the template or any project based on it will then have the
same configuration.

-  `.initialized`

    Empty file used to signal whether or not the project has been initialized.
    The file is created on running `make init_from_project`,
    which adds the IPython notebook filter to the project's git configuration,
    or `make init_from_template` which _also_:

    1. Removes the template remote repository.
    2. Squashes the entire git history into a single
        initial commit.

-  `profile_default/`

    A custom IPython profile
    which changes a few things from the built-in default:

    -  IPython notebooks display figures inline by default;
    -  The default editor is full `vim`;
    -  Tab completion is more like `bash`;
    -  Running `ipython3 notebook` from the command line is convenient:
        -  The server look for notebook files in the `ipynb/` subdirectory;
        -  When loaded, the working directory for the notebook is automatically
            changed to the root of the project (i.e. `cd ..`).

    See
    [IPython's documentation][ipy-config].

    [ipy-config]: <http://ipython.org/ipython-doc/dev/config/intro.html>

-  `matplotlibrc`

    A custom matplotlib profile for compbio projects.
    Change matplotlib styles in a central place.
    All figures will have the same config.

    See
    [matplotlib's documentation](http://matplotlib.org/users/customizing.html).

-  `.gitattributes` / `.gitignore` / `.gitmodules`

    Configuration files for `git`.

## Data ##
_Data is not version controlled._

-  `raw/`

    All of the raw data and metadata needed to recreate the entire analysis.
    This should be kept in the exact same format as it is available publicly;
    if you're going to rename files, remove header lines, or reformat,
    these processed versions of the data should be stored in directories
    other than `raw/`.
    While raw data files are not version controlled, they _should_ all be
    available in an online repository.
    `raw/NOTE.md` describes everything a third party
    (or the author a month later)
    needs to know about the raw data.

    -  Required: Describes (in detail) where all of the data came from.
    -  Good: Instructions for retrieving all of the data from an online
        repository.
    -  Great: Recipe for data retrieval included in `Makefile`.

    It is also advisable to save data in directories named by the date it was
    collected, or the date of the experiment
    so growth curves started on October 20th, 2014, would be stored in
    `raw/2014-10-20/growth-curve.csv`, and
    `raw/NOTE.md` would describe the experiment and this file in detail.

Intermediate data files are separated into directories based on their content.
The extension portion of these file names should indicate the format of the
data, while the '`.`' separated words which make up the file name loosely
describe the workflow used to produce the file.
For example:
-  `seq/16S.align.ungap.afn` would be multiple sequence alignment (`.align.`)
    in nuceotide FASTA format (`.afn`) which has had all gap positions removed
    (`.ungap.`).
-  `tre/16S.align.ungap.nwk` is a Newick formatted phylogenetic tree generated
    from `seq/16S.align.ungap.afn`.

A subset of filename keyword recommendations are document in `*/TEMPLATE.md`
files in various directories.
This naming scheme is not a replacement for both liberal note-taking
and a programmatic description of the pipeline in the `Makefile`.

-  `meta/`

    All of the experiment metadata, formatted conveniently for downstream
    analysis.
    Tab separated values (`.tsv`) with headers is the preferred format.
    The files in this directory are usually minimally processed versions of
    the original metadata files stored in `raw/`.
    Column titles should be explained in `meta/NOTE.md`.

-  `seq/`

    Intermediate analysis files which contain sequence.


-  `tre/`

    Intermediate analysis files which contain phylogenetic or taxonomic trees.


-  `res/`

    Any intermediate results which cannot be easily placed in another
    directory.
    For instance, a TSV of pairwise sequence distances.


## Final Results ##
_Final results are not version controlled._

-  `fig/`

    All 'final' output from an analysis, usually figures or tables.
    Figures don't have to be good enough for a publication, they just
    have to represent the culmination of an analysis.

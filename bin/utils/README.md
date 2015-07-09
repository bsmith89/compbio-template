A collection of useful scripts for computational biology.

Intended to be used as a submodule of a computation biology project
(e.g. based on [this template](https://github.com/bsmith89/compbio-template)).

Scripts should be well documented.

-  Required: Each script has a docstring (comment at the top after the
   shebang) which describes the use of the script from the command line.
-  Good: Scripts are well commented, explaining the logic of any difficult
   to understand code.
-  Great: Scripts are designed with full help text, conforming to POSIX
   standards.

Scripts should take any data which only needs to be used once from STDIN.
If this can be accomplished in multiple ways, one rule of thumb is for scripts
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

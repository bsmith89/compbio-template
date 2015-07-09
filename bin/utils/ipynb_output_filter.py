#! /usr/bin/env python
"""From http://stackoverflow.com/a/20844506/1951857

To use::

    # Add the script to your path
    chmod +x path/to/this/ipynb_output_filter.py
    echo "*.ipynb    filter=dropoutput_ipynb" >> ~/.gitattributes
    git config --global core.attributesfile ~/.gitattributes
    git config --global filter.dropoutput_ipynb.clean ipynb_output_filter.py
    git config --global filter.dropoutput_ipynb.smudge cat

When you run ``git status`` you'll see changes not yet staged, but
diff-ing, committing, etc. should all ignore the output/prompt number
portions of the notebook.

You may find that ``git add *.ipynb`` cleans up your status output without
changing the content of the staging area.

"""

import sys
from IPython.nbformat import read, write, NO_CONVERT

def clean(in_handle, out_handle):
    json_in = read(in_handle, NO_CONVERT)

    if "signature" in json_in.metadata:
        json_in.metadata.pop("signature")
    for cell in json_in.cells:
        if "outputs" in cell:
            cell.outputs = []
        if "execution_count" in cell:
            cell.execution_count = None
        if "prompt_number" in cell:
            cell.pop("prompt_number")
        if "metadata" in cell:
            cell.metadata = {}

    write(json_in, out_handle, NO_CONVERT)


if __name__ == '__main__':
    args = sys.argv[1:]
    if len(args) == 0:
        clean(sys.stdin, sys.stdout)
    elif len(args) == 1:
        with open(args[0]) as handle:
            clean(handle, sys.stdout)
    else:
        raise ValueError("Too many CL arguments passed to program.")

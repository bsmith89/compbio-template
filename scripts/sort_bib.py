#!/usr/bin/env python
"""Sort all of the entries in the files found in the arguments.

Prints the sorted entries to stdout.

Entry recognition is based on the @ARTICLE command syntax, so @PREAMBLE,
@COMMENT, and @STRING are all treated as bibleography entries.
with the string leading up to the first comma used as the key.

TODO: Fix the sorting to deal correctly with non-entry items in the file.

"""


import sys
import re
import itertools

def entries(path):
    in_entry = False  # In case the file starts with text not inside an entry.
    current_entry = []
    with open(path) as f:
        for line in f:
            if line[0] == "@":
                if in_entry:
                    yield ''.join(current_entry)
                in_entry = True
                current_entry = [line]
            else:
                current_entry.append(line)
        if in_entry:
            yield ''.join(current_entry)


def get_key(entry):
    match = re.match(r"^@[a-zA-Z]+\{([^,]*),", entry)
    entry = match.group(1)
    return entry

if __name__ == '__main__':
    entries_chain = itertools.chain(*[entries(path) for path in sys.argv[1:]])
    sorted_entries = sorted(entries_chain, key=lambda e: get_key(e))
    for entry in sorted_entries:
        sys.stdout.write(entry)

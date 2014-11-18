#!/usr/bin/env bash -xe

LOCKFILE=.initialized
if [ -e "$LOCKFILE" ]; then
    echo "This project appears to have already been initialized." >&2
    echo "If you are sure this is in error:" >&2
    echo "    rm `$LOCKFILE`" >&2
    echo "    `$0`" >&2
    exit 1
fi

git submodule update --init --recursive
# Remove the template remote
git remote remove origin
# Configure IPYNB output filtering
git config --local filter.dropoutput_ipynb.clean scripts/utils/ipynb_output_filter.py
git config --local filter.dropoutput_ipynb.smudge cat
# Link README to project notes, instead of template notes.
unlink README.md
ln -s NOTE.md README.md
# Remove all of the commits after the first, leaving files intact,
# add files created/changed during initialization,
# and amend the first commit with everything else.
# TL;DR Squash everything to a single first commit.
git reset --soft $(git rev-list --max-parents=0 HEAD)
git add -A
git commit --amend -em "Clean project.  Let's get started!"
touch $LOCKFILE

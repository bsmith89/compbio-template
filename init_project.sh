#!/usr/bin/env bash -x

git submodule update --init --recursive
# Rename the remote and avoid accidentally pushing changes to the template.
git remote rename origin template
git config --unset branch.master.remote
# Configure IPYNB output filtering
git config --local filter.dropoutput_ipynb.clean utils/ipynb_output_filter.py
git config --local filter.dropoutput_ipynb.smudge cat
# Link README to project notes, instead of template notes.
unlink README.md
ln -s NOTE.md README.md
# Hard coded rm to avoid deleting something else accidentally.
rm init_project.sh
# Remove all of the commits after the first, leaving files intact,
# add files created/changed during initialization,
# and amend the first commit with everything else.
# TL;DR Squash everything to a single first commit.
git reset --soft $(git rev-list --max-parents=0 HEAD)
git add -A
git commit --amend -em "Clean project.  Let's get started!"

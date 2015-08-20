#!/usr/bin/env python3
"""Parse output of `make --dry-run --print-data-base` into dotfile."""

import sys
from networkx import DiGraph, write_dot

SPECIAL_TRGTS = {".POSIX", ".PHONY"}


def recipe_start(line):
    """Determine if a line looks like 'target: prerequisites'."""
    return (not line.startswith("#")) and \
           (not line.startswith("\t")) and \
           (': ' in line)


def database_recipes(lines):
    """Remove everything before explicit recipes in Makefile database."""
    before = True
    for line in lines:
        if before:
            if line.strip() == "# Files":
                before = False
        else:
            yield line


def chunk_recipes(lines):
    """Split explicit recipes into chunks."""
    current_chunk = []
    in_chunk = False
    for line in lines:
        if recipe_start(line):
            assert not in_chunk, (current_chunk, line)
            in_chunk = True
            current_chunk.append(line)
        elif in_chunk and (line == '\n'):
            yield ''.join(current_chunk)
            current_chunk = []
            in_chunk = False
        elif in_chunk:
            current_chunk.append(line)


def first_line(recipe):
    return recipe.split('\n')[0]


def parse_header(header):
    "Split recipe header into target, pre-requisites."
    trgt, rest = header.split(': ')
    preqs = [piece
             for piece in rest.split()
             if piece not in {"|", ":"}]
    return trgt, preqs


def to_graph(mapping):
    g = DiGraph()
    for trgt in mapping:
        if trgt not in SPECIAL_TRGTS:
            for preq in mapping[trgt]:
                g.add_edge(trgt, preq)
    return g


def main():
    with open(sys.argv[1]) as handle:
        recipes = chunk_recipes(database_recipes(handle.readlines()))
    headers = [first_line(recipe) for recipe in recipes]
    mapping = dict(parse_header(header) for header in headers)
    graph = to_graph(mapping)
    write_dot(graph, sys.stdout)


if __name__ == '__main__':
    main()

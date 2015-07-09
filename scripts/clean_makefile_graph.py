#!/usr/bin/env python3

import networkx as nx
import sys
import re
import argparse


def parse_args(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--drop', '--drop-regex', '-d', metavar='REGEX',
                        action='append', type=str,
                        help=("One or more regex patterns which match node "
                              "names which should be removed from the final "
                              "graph."))
    parser.add_argument('--keep', '--but-keep-regex', '-k', metavar='REGEX',
                        action='append', type=str,
                        help=("Regex patterns which should NOT be dropped "
                              "despite potentially matching one of the 'drop' "
                              "patterns; --keep takes priority over --drop."))
    parser.add_argument('infile', metavar='DOTFILE',
                        type=argparse.FileType('r'),
                        nargs='?', default=sys.stdin,
                        help=".dot file to be processes; defaults to stdin")
    args = parser.parse_args(argv[1:])
    return args


def matches_any(string, regex_list):
    return any(regex.search(string) for regex in regex_list)

def remove_node(node):
    """Re-connect sources to sinks."""
    pass

def main():
    args = parse_args(sys.argv)
    graph = nx.read_dot(args.infile)

    graph = graph.reverse()

    droppers = [re.compile(pattern) for pattern in args.drop]
    keepers = [re.compile(pattern) for pattern in args.keep]

    in_degree = graph.in_degree()
    degree = graph.degree()
    for node in graph.nodes():
        if matches_any(node, droppers) and not matches_any(node, keepers):
            graph.remove_node(node)
            continue
        if degree[node] == 0:
            graph.remove_node(node)
        elif in_degree[node] == 0:
            graph.node[node]['shape'] = 'hexagon'

    # After removing nodes, let's mark the new 'root' nodes
    # indicates nodes which look like roots but aren't.
    in_degree = graph.in_degree()
    for node in graph.nodes():
        if in_degree[node] == 0 and 'shape' not in graph.node[node]:
            graph.node[node]['shape'] = 'box'


    graph.graph = {}  # Clear all graph, edge, and node attributes
    # nx.write_dot(graph) should work,
    # but doesn't, because it calls nx.to_agraph(graph).clear()
    a = nx.to_agraph(graph)
    a.write(sys.stdout)

if __name__ == "__main__":
    main()

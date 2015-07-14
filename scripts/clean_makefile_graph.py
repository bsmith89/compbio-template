#!/usr/bin/env python3

import networkx as nx
import sys
import re
import argparse
from itertools import product


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

def get_detours(graph, nodes):
    """Return a edges that by-pass nodes."""

    get_parents = lambda node: list(graph.edge[node])
    rev_graph = graph.reverse()
    get_children = lambda node: list(rev_graph.edge[node])

    detours = []  # (child, new_parent)
    for node in nodes:
        parents = get_parents(node)
        i = 0
        while i < len(parents):
            parent = parents[i]
            if parent in nodes:
                parents.extend(get_parents(parent))  # Parents of the inacessable nodes become new parents
            i += 1
        parents = set(parents) - set(nodes)  # Remove the inacessable nodes

        children = set(get_children(node)) - set(nodes)
        detours.extend(product(children, parents))
    return set(detours)

def main():
    args = parse_args(sys.argv)
    graph = nx.read_dot(args.infile)

    droppers = [re.compile(pattern) for pattern in args.drop]
    keepers = [re.compile(pattern) for pattern in args.keep]

    rm_nodes = []
    num_parents = graph.out_degree()
    degree = graph.degree()
    for node in graph.nodes():
        if matches_any(node, droppers) and not matches_any(node, keepers):
            rm_nodes.append(node)
        elif degree[node] == 0:
            rm_nodes.append(node)
        elif num_parents[node] == 0:
            graph.node[node]['shape'] = 'hexagon'
        else:
            pass  # Node will not be changed.

    detours = get_detours(graph, rm_nodes)
    graph.remove_nodes_from(rm_nodes)
    graph.add_edges_from(detours, style='dashed')

    graph.graph = {}  # Clear all graph, edge, and node attributes
    # nx.write_dot(graph) should work,
    # but doesn't, because it calls nx.to_agraph(graph).clear()
    a = nx.to_agraph(graph)
    # print(graph.edge, file=sys.stderr)
    a.write(sys.stdout)

if __name__ == "__main__":
    main()

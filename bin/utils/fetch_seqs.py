#!/usr/bin/env python3
"""Given a file listing sequence IDs, pull those sequences
from a FASTA file.

"""

from Bio.SeqIO import parse, write
import sys
import argparse
import lib.cli as cli
import logging

logger = logging.getLogger(__name__)
logging.captureWarnings(True)

def get_recs(recs, get_ids):
    for rec in recs:
        if rec.id in get_ids:
            yield rec
        else:
            continue

def get_rec_list(recs, get_ids):
    map = {rec.id: rec for rec in recs}
    return [map[id] for id in get_ids]

def get_list(handle):
    out = []
    for line in handle:
        out.append(line.strip())
    return out

def _get_extra_args():
    p = argparse.ArgumentParser(add_help=False)
    g = p.add_argument_group(*cli.FMT_GROUP)
    g.add_argument("-m", "--match-order", action='store_true',
                   help="output in the same order as LIST")
    return p



def parse_args(argv):
    parser = argparse.ArgumentParser(description=__doc__,
                                     parents=[cli.get_base_parser(),
                                              cli.get_seq_out_parser(),
                                              cli.get_list_in_parser(),
                                              cli.get_seq_in_parser(),
                                              _get_extra_args(),
                                              ])
    args = parser.parse_args(argv[1:])
    return args

def main():
    args = parse_args(sys.argv)
    logging.basicConfig(level=args.log_level)
    logger.debug(args)

    if args.match_order:
        for rec in get_recs(parse(args.in_handle, args.fmt_infile),
                            get_list(args.list_handle)):
            write(rec, args.out_handle, args.fmt_outfile)
    else:
        recs = get_rec_list(parse(args.in_handle, args.fmt_infile),
                            get_list(args.list_handle))
        write(recs, args.out_handle, args.fmt_outfile)

if __name__ == '__main__':
    main()

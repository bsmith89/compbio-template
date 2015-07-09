#!/usr/bin/env python3
"""Reverse complement nucleotide sequences."""

from Bio.SeqIO import parse, write
import sys
import argparse
from copy import copy
import lib.cli as cli
import logging

logger = logging.getLogger(__name__)
logging.captureWarnings(True)

def revcompl_recs(records):
    """Reverse complement sequence from records.

    This geneator takes a iterable of Bio.SeqRecord objects and the same
    records with sequences reverse transcribed.

    """
    for rec in records:
        # TODO: Make sure that this shallow copy of rec
        # is safe.  Is rec.seq a mutable sequence?
        # No, right?
        rec = copy(rec)
        rec.seq = rec.seq.reverse_complement()
        yield rec

def parse_args(argv):
    parser = argparse.ArgumentParser(description=__doc__,
                                     parents=[cli.get_base_parser(),
                                              cli.get_seq_out_parser(),
                                              cli.get_seq_in_parser(),
                                              ])
    args = parser.parse_args(argv[1:])
    return args

def main():
    args = parse_args(sys.argv)
    logging.basicConfig(level=args.log_level)
    logger.debug(args)

    for rc_rec in revcompl_recs(parse(args.in_handle, args.fmt_infile)):
        write(rc_rec, args.out_handle, args.fmt_outfile)

if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Convert sequence files between formats using the BioPython package."""

from Bio.SeqIO import parse, write
import sys
import argparse
import lib.cli as cli
import logging

logger = logging.getLogger(__name__)
logging.captureWarnings(True)

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

    for rec in parse(args.in_handle, args.fmt_infile):
        write(rec, args.out_handle, args.fmt_outfile)

if __name__ == "__main__":
    main()

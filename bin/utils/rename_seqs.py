#!/usr/bin/env python3
"""Given a mapping from IDs to new IDs and a sequence file, output the latter
renamed.

"""

from Bio.SeqIO import parse, write
import sys
import argparse
import lib.cli as cli
import logging
from copy import copy

logger = logging.getLogger(__name__)
logging.captureWarnings(True)

def rename_recs(recs, name_map):
    for rec in recs:
        rec = copy(rec)
        if rec.id in name_map:
            logger.debug("Renaming {} to {}.".format(rec.id, name_map[rec.id]))
            rec.id = name_map[rec.id]
            rec.name = ""
            rec.description = ""
        yield rec

def get_map(handle):
    out = {}
    for line in handle:
        key, value = line.split()
        key = key.strip()
        value = value.strip()
        if key in out:
            raise RuntimeError("Key found twice in input file: {}".format(key))
        out[key.strip()] = value.strip()
    return out

def get_map_in_parser():
    p = argparse.ArgumentParser(add_help=False)
    g = p.add_argument_group(*cli.POS_GROUP)
    g.add_argument('map_handle',
                   help="tab separated file mapping old to new IDs",
                   metavar='MAP', type=argparse.FileType('r'))
    return p

def parse_args(argv):
    parser = argparse.ArgumentParser(description=__doc__,
                                     parents=[cli.get_base_parser(),
                                              cli.get_seq_out_parser(),
                                              get_map_in_parser(),
                                              cli.get_seq_in_parser(),
                                              ])
    args = parser.parse_args(argv[1:])
    return args

def main():
    args = parse_args(sys.argv)
    logging.basicConfig(level=args.log_level)
    logger.debug(args)

    for rec in rename_recs(parse(args.in_handle, args.fmt_infile),
                           get_map(args.map_handle)):
        logger.debug("Writing {}".format(rec.id))
        write(rec, args.out_handle, args.fmt_outfile)

if __name__ == '__main__':
    main()

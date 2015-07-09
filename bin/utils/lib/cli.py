"""Common command-line interface elements for sequence analysis utilities.

"""
# TODO: Consider adding a -V flag
# See the 'version' action:
# <https://docs.python.org/3/library/argparse.html#action>

import argparse
import sys
import logging


# <GROUP> = "<name>", "<description>"
LOG_GROUP = "logging options", ""
POS_GROUP = "positional arguments", ""
FMT_GROUP = "format options", ""
PAR_GROUP = "parameters", ""

# TODO: Provide more options here.  Presumably anything available in Biopython.
AVAIL_SEQ_FMTS = ['fasta', 'fastq', 'genbank', 'sff',
                  'swiss', 'tab', 'stockholm']
DEFAULT_SEQ_FMT = 'fasta'

AVAIL_ALIGN_FMTS = ['clustal', 'emboss', 'fasta', 'nexus', 'phylip',
                    'phylip-sequential', 'phylip-relaxed', 'stockholm']
DEFAULT_ALIGN_FMT = 'fasta'

DEFAULT_LOG_LVL = 30

logger = logging.getLogger(__name__)

class DropSequenceWarning(RuntimeWarning):
    pass

def get_base_parser():
    p = argparse.ArgumentParser(add_help=False)
    g = p.add_argument_group(*LOG_GROUP)
    g.add_argument("--log-level", type=int,
                   default=DEFAULT_LOG_LVL,
                   help=("logging level (higher=fewer messages)"
                         " DEFAULT: {}").format(DEFAULT_LOG_LVL))
    g.add_argument("-v", "--verbose",
                   dest='log_level', action='store_const', const=10,
                   help=("set loggin level to 10 (debug)"))
    h = p.add_argument_group(*FMT_GROUP)
    h.add_argument("-o", "--out-file", dest='out_handle',
                   type=argparse.FileType('w'),
                   metavar="OUTFILE", default=sys.stdout,
                   help=("write to file instead of stdout"))
    return p

def get_seq_in_parser(optional=True):
    if optional:
        in_handle_nargs = '?'
    else:
        in_handle_nargs = None

    p = argparse.ArgumentParser(add_help=False)
    g = p.add_argument_group(*POS_GROUP)
    g.add_argument("in_handle", nargs=in_handle_nargs,
                   type=argparse.FileType('r'),
                   metavar="SEQUENCE", default=sys.stdin,
                   help=("sequence file"))
    h = p.add_argument_group(*FMT_GROUP)
    h.add_argument("-f", "--in-fmt", "--from", dest='fmt_infile', type=str,
                   metavar="FORMAT", default=DEFAULT_SEQ_FMT,
                   choices=AVAIL_SEQ_FMTS,
                   help=("sequence file format of input"
                         " DEFAULT: {}").format(DEFAULT_SEQ_FMT))
    return p


def get_seq_out_parser():
    p = argparse.ArgumentParser(add_help=False)
    g = p.add_argument_group(*FMT_GROUP)
    g.add_argument("-t", "--out-fmt", "--to", dest='fmt_outfile', type=str,
                   metavar="FORMAT", default=DEFAULT_SEQ_FMT,
                   choices=AVAIL_SEQ_FMTS,
                   help=("sequence file format of output"
                         " DEFAULT: {}").format(DEFAULT_SEQ_FMT))
    g.add_argument("-d", "--drop", action="store_true",
                   help="drop records which do not meet minimum requirements.")
    return p

def get_align_in_parser(optional=False):
    if optional:
        in_handle_nargs = '?'
    else:
        in_handle_nargs = None

    p = argparse.ArgumentParser(add_help=False)
    g = p.add_argument_group(*POS_GROUP)
    g.add_argument('align_handle', nargs=in_handle_nargs,
                   type=argparse.FileType('r'),
                   metavar="ALIGNMENT",
                   help=("alignment file"))
    h = p.add_argument_group(*FMT_GROUP)
    h.add_argument('--align-fmt', dest='fmt_align', type=str,
                   metavar="FORMAT", default=DEFAULT_ALIGN_FMT,
                   choices=AVAIL_ALIGN_FMTS,
                   help=("file format of aligned protein sequences"
                         " DEFAULT: {}").format(DEFAULT_ALIGN_FMT))
    return p

def get_list_in_parser():
    p = argparse.ArgumentParser(add_help=False)
    g = p.add_argument_group(*POS_GROUP)
    g.add_argument('list_handle', help="list of sequence IDs",
                   metavar='LIST', type=argparse.FileType('r'))
    return p

def parse_args(argv):
    parser = argparse.ArgumentParser(description="Test parser.",
                                     parents=[get_base_parser(),
                                              get_align_in_parser(),
                                              get_seq_out_parser(),
                                              get_list_in_parser(),
                                              get_seq_in_parser(),
                                              ])
    args = parser.parse_args(argv[1:])

    return args

def main():
    args = parse_args(sys.argv)
    logging.basicConfig(level=args.log_level)
    logger.debug(args)

if __name__ == "__main__":
    main()

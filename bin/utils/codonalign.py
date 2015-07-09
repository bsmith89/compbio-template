#!/usr/bin/env python3
"""Align codons based on a corresponding amino-acid sequence.

"""

from Bio.SeqIO import parse, write
from Bio.Seq import Seq
from Bio.Alphabet import generic_dna, generic_protein, Gapped
import sys
import argparse
import lib.cli as cli
from copy import copy
import logging
from warnings import warn


logger = logging.getLogger(__name__)


class MismatchedSeqsError(Exception):
    """Attempted to align codons between mismatched sequences."""
    pass

def codons(sequence):
    """Return groups of 3 items from a sequence.
    
    This is specifically meant to return codons from an in-frame sequence."""
    codon = ""
    for nucl in sequence:
        codon += nucl
        if len(codon) == 3:
            yield codon
            codon = ""

def backalign(nucl, prot):
    align_nucl = []
    codon_iter = codons(nucl)
    prot.alphabet = Gapped(generic_protein)
    for amino in prot:
        if amino == ".":
            align_nucl += ["..."]
        elif amino.islower() or amino == '*':
            align_nucl += next(codon_iter).lower()
        elif amino == "-":
            align_nucl += ["---"]
        else:
            align_nucl += [next(codon_iter)]
    out = Seq("".join(align_nucl), alphabet=Gapped(generic_dna))
    if not out.ungap().translate().upper() == prot.ungap().upper():
        raise MismatchedSeqsError("Aligned codons do not match input AAs")
    return out

def backalign_recs(nucl_recs, prot_index):
    for nucl_rec in nucl_recs:
        out_rec = copy(nucl_rec)
        try:
            prot_rec = prot_index[nucl_rec.id]
        except KeyError:
            logger.warn(("No alignment found for {}. "
                         "Dropping.").format(nucl_rec.id))
            continue
        else:
            out_rec.seq = backalign(nucl_rec.seq, prot_rec.seq)
        yield out_rec

def parse_args(argv):
    parser = argparse.ArgumentParser(description=__doc__,
                                     parents=[cli.get_base_parser(),
                                              cli.get_seq_out_parser(),
                                              cli.get_align_in_parser(),
                                              cli.get_seq_in_parser(),
                                              ])
    args = parser.parse_args(argv[1:])

    return args

def main():
    args = parse_args(sys.argv)
    logging.basicConfig(level=args.log_level)
    logger.debug(args)

    align_index = {rec.id: rec
                   for rec in parse(args.align_handle, args.fmt_align)}

    for rec in backalign_recs(parse(args.in_handle, args.fmt_infile),
                              align_index):
        write(rec, args.out_handle, args.fmt_outfile)

if __name__ == '__main__':
    main()

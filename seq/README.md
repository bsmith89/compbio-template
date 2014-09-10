# `seq/` #

## Files ##
This directory contains a variety of sequence files.

`16S.*` refer to sequence files which originally come from the rrnDBs
16S sequence database.

`*.fn` means that a file is a nucleotide file in FASTA format.

`*.afn` is an aligned nucleotide FASTA.

`*.ungap.*` means that an alignment has had columns which are only
composed of gaps ('-') removed.

`*.head.*` and `*.tail.*` are files which only represent the top or bottom
fractions of the dataset, respectively.  These are to be used as sample data
in testing scripts.

`*.probseqs.*` is a file composed of only the ~~46 "problem" sequences identified
by Steve S.~~ 32 _uniq_ problem sequences provided by Steve.


`*.with_probseqs.*` is a file composed of _all_ sequences, including problem
sequences.

All files represent metadata about the data analyzed in this study.

## Conventions ##
### `*.tsv` ###
Tab-separated values.
Entries separated by tab characters, rows separated by newlines.
Should have column labels as the first row.
Comments should not be included in the file itself;
instead they can be added to this README.
Any field _can_ be quoted, (with double quotes)
but fields which contain tabs or newlines must be quoted.

TSVs should be parsed correctly by
[`pandas.read_table`](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.io.parsers.read_table.html).

### `*.csv` ###
TSVs are preferred (because they're easier to inspect manually),
but CSVs are acceptable.
See:
[`pandas.read_csv`](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.io.parsers.read_csv.html).

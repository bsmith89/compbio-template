<!-- Directory placeholder for res/ -->

## `res/` Conventions ##

### File Formats ###

| suffix   | meaning                | comments                       |
| ----     | ----                   | ----                           |
| `list`   | list of values         | one item per line              |
| `tsv`    | tab separated values   | see [`pandas.read_table`][prt] |
| `csv`    | comma separated values | see [`pandas.read_csv`][prc]   |

[prt]: <http://pandas.pydata.org/pandas-docs/stable/generated/pandas.io.parsers.read_table.html>
[prc]: <http://pandas.pydata.org/pandas-docs/stable/generated/pandas.io.parsers.read_csv.html>

TSVs with column titles are preferred (because they're easier to inspect
manually), but CSVs are acceptable.

<!-- /Placeholder -->

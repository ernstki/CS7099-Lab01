#   15SS_CS7099 Homework #1
### Finding open reading frames in human mtDNA

| Author  | Kevin Ernst |
|---------|-------------|
| Date    | 2015-02-03  |


# Prerequisites

Perl v5.14 or later. A Unix system is assumed (pathnames with forward
slashes).

All modules used in `findorfs.pl` should be included with a standard Perl
distribution (`Getopt::Long`, `FindBin`, and `Carp`).


# Installation and Invocation

```
tar zxvf ernst_cs7099_hw1.tar.gz
cd CS7099-Lab01
perl findorfs.pl | less
```

Zero-based representations for base indices may be turned on by supplying the
`-z` command-line argument.

A PostScript version of the report suitable for printing may be created with
the following command (assuming `a2ps` is installed):

```
# Substitute -o <filename> for -d to send directly to default printer
perl findorfs.pl -p | a2ps -1 -o ERNST_HW1.ps --stdin="ORFs in Human mtDNA"
```


# Testing

A rudimentary unit test suite is included in the tarball. `Test::More`,
`Data::Dump`, and `File::Spec` (plus dependencies) are required, and may be
installed via CPAN if not already part of your Perl installation.

To run the tests:

```
make test

# Or, for an individual test:
perl t/10_read_fasta.t
```


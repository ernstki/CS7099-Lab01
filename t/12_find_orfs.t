#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More qw( no_plan );
use Data::Dump qw( dd );
use FindBin;

use lib "$FindBin::Bin/../lib";
use CS7099Lib::Lab01 qw(
	&read_fasta &find_start_codons &find_orfs
	@START_CODONS @STOP_CODONS
	$INPUT_SEQ $CODON_SIZE $SEQ_LENGTH
);

my $seq    = '';
my $starts = {};
my $orfs   = {};

subtest 'Read in sequence file and find start codons' => sub {
    ok( $seq = read_fasta(), 'Read in the FASTA file' );
	ok( $starts = find_start_codons($seq),
	    "Call to find_start_codons() call doesn't fail" );
};

subtest 'Check output of find_orfs()' => sub {
    #cmp_ok(   );
	
};

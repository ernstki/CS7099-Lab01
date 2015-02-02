#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More qw( no_plan );
use FindBin;
use lib "$FindBin::Bin/../lib";
use CS7099Lib::Lab01 qw( &read_fasta $SEQ_LENGTH );

my $seq = '';
my $starts = {};

subtest 'Check output of read_fasta()' => sub {
    ok( $seq = read_fasta(), 'Read in the FASTA file' );
	ok( @$seq, 'Sequence came back with something' );
	ok( scalar(@$seq) == $SEQ_LENGTH,
		"Sequence has correct length ($SEQ_LENGTH)" );

};
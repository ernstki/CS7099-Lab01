#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More qw( no_plan );
use FindBin;
use lib "$FindBin::Bin/../lib";
use CS7099Lib::Lab01 qw(
	&read_fasta &find_start_codons &substring_match
	@START_CODONS @STOP_CODONS
	$INPUT_SEQ $CODON_SIZE $SEQ_LENGTH
);

my $seq = '';
my $starts = {};

subtest 'Check output of read_fasta()' => sub {
    ok( $seq = read_fasta(), 'Read in the FASTA file' );
	ok( @$seq, 'Sequence came back with something' );
	ok( scalar(@$seq) == $SEQ_LENGTH,
		"Sequence has correct length ($SEQ_LENGTH)" );

};

subtest 'Check output find_start_codons()' => sub {
	ok( $starts = find_start_codons($seq), "Function call doesn't fail" );
	ok( $starts, 'Got something back (not an empty hash)' );
	ok( scalar(keys(%$starts)) == $CODON_SIZE,
		'Number of reading frames equals $CODON_SIZE' );

	ok( 0, 'No duplicates in $starts (in each frame)' );

};

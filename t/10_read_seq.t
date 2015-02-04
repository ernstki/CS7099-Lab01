#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More qw( no_plan );
use FindBin;
use lib "$FindBin::Bin/../lib";
use CS7099Lib::Lab01 qw( &read_seq $SEQ_LENGTH );

my $seq = '';
my $starts = {};

subtest 'Check output of read_seq()' => sub {
    ok( $seq = read_seq(), 'Read in the input sequence (FASTA) file' );
    ok( @$seq, 'Sequence came back with something' );
    ok( scalar(@$seq) == $SEQ_LENGTH,
        "Sequence has correct length ($SEQ_LENGTH)" );
};

done_testing(1);
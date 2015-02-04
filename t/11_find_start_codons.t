#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More qw( no_plan );
use Data::Dump qw( dd pp );
use FindBin;
use lib "$FindBin::Bin/../lib";
use CS7099Lib::Lab01 qw(
    &read_seq &find_start_codons &substring_match
    @START_CODONS @STOP_CODONS
    $INPUT_SEQ $CODON_SIZE $SEQ_LENGTH
);

my $seq = '';
my $starts = {};


subtest 'Check output of find_start_codons()' => sub {
    ok( $seq = read_seq(), 'Read in the FASTA file' );
    ok( $starts = find_start_codons($seq),
        "Call to find_start_codons() call doesn't fail" );
    cmp_ok( @$starts, '>', 0, 'Got something back (not an empty array)' );

    # We don't pass back a 2D array anymore (all reading frames combined)
    #ok( scalar(@$starts) == $CODON_SIZE,
    #    'Number of reading frames equals $CODON_SIZE' );
        
};

subtest 'Check for duplicate positions in list of start codons' => sub {
    # We don't pass back a 2D array anymore (all reading frames combined)
    #for ( my $fr = 0; $fr < $CODON_SIZE; $fr++ ) {

    my %seen = ();
    my $pos;

    foreach my $item ( @$starts ) {
        fail("Found array/hashref for where position expected ($item)")
            if ref($item);

        $seen{ $item }++;
    } # for each position => codon pair

    # Make sure no duplicate keys
    foreach my $pos (keys(%seen)) { 
        fail("Found position $pos more than once") if ($seen{$pos} != 1);
    }

    # Cound the number of keys for start positions in this reading frame
    # and make sure it's the same as the number of keys in %seen.
    ok( scalar(@$starts) == scalar(keys(%seen)),
        "No duplicates in \$starts (in all frames)" );

    #} # for each reading frame
};

done_testing(2);

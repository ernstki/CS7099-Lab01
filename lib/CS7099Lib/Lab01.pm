####################################################################
##                                                                ##
##  @file    Lab01Lib.pm                                          ##
##  @brief   Library functions for CS7099 lab #1                  ##
##                                                                ##
##  @author  Kevin Ernst (ernstki@mail.uc.edu)                    ##
##  @date    1 February 2015                                      ##
##                                                                ##
####################################################################
use strict;
use warnings;
use autodie;
use Data::Dump qw( dd pp );

package CS7099Lib::Lab01;
require Exporter;
use vars qw( @ISA %EXPORT_TAGS );

@ISA = qw(Exporter);

%EXPORT_TAGS = (
    functions => [qw( read_fasta complement_seq find_start_codons find_orfs
                      get_codon_at get_seq_range get_seq_of_length
                      gc_content_of_range )],

    constants => [qw( @START_CODONS @STOP_CODONS
                      $CODON_SIZE $SEQ_LENGTH $MIN_GENE_LENGTH
                      $MIN_GC_CONTENT )],
                      
    internals => [qw( $INPUT_SEQ substring_match find_longest_orf
                      gc_content_of_seq )],
);

Exporter::export_tags('functions');
Exporter::export_ok_tags('constants', 'internals');

use Carp;
use Data::Dump qw( dd dump );         # For debugging statements
use English;                          # English names for magic variables

use vars qw(
    @START_CODONS @STOP_CODONS $INPUT_SEQ $CODON_SIZE $SEQ_LENGTH
    $MIN_GENE_LENGTH $MIN_GC_CONTENT
); 

#
#                            C O N S T A N T S
#                            =================

# Ref:
# https://www.idtdna.com/pages/docs/educational-resources/mitochondrial-dna.pdf
#@START_CODONS    = qw( ATG ATA ATT );
@START_CODONS    = qw( ATG ATA );
@STOP_CODONS     = qw( AGA AGG TAG TAA );
$INPUT_SEQ       = 'mtDNA_1-16569.fasta';
$CODON_SIZE      = 3;
$SEQ_LENGTH      = 0;      # updated by _read_fasta(), below
$MIN_GENE_LENGTH = 60;     # FIXME: allow as command-line option
$MIN_GC_CONTENT  = 35;     # %GC (FIXME: allow as command-line option)


#
#                           P R O T O T Y P E S
#                           ===================
sub read_fasta();
sub _read_fasta( $ );
sub complement_seq( $ );
sub find_start_codons( $ );
sub substring_match( $$$;$ );
sub find_orfs( $$ );
sub get_codon_at( $$ );
sub swrite( $@ );
sub get_seq_range( $$$;$ );
sub get_seq_of_length( $$$;$ );
sub gc_content_of_range( $$$ );
sub gc_content_of_seq( $$$ );

#
#                          S U B R O U T I N E S
#                          =====================

# Public (zero-argument) version of _read_fasta() which calls the "real"
# function with a hard-coded input filename.
sub read_fasta() {
    return _read_fasta($INPUT_SEQ);
}


# Private version of read_fasta() which actually reads the input FASTA file
# and generates an array representing the input sequence, one base per
# array element.
sub _read_fasta( $ ) {
    my $filename = shift;
    my $seq = [];

    open(FASTA, "<$filename") or die "Can't open $filename ($OS_ERROR)\n";

    while (<FASTA>) {
        next if /^>/;                # skip FASTA headers
        s/\r?\n?$//;                 # remove newlines
        next if /^$/;                # skip blank lines
        push @$seq, split(//, $_);
    }

    close FASTA;
    $SEQ_LENGTH = @$seq;
    return $seq;
} # read_fasta


# Given an array of bases as input, return the complement strand as an array
sub complement_seq( $ ) {
    my $seq = shift;
    my $cmp = [];

    foreach my $b (@$seq) {
    	# Watch out: the foreach loop index variable is an implicit alias for
    	# the *actual* contents of LIST (see: perlsyn)
        (my $c = $b ) =~ tr/ATCG/TAGC/;
        push @$cmp, $c;
    }

    return $cmp;
} # complement_seq


# Given an array of bases as input, return a two-dimensional array where the
# first dimension is reading frames of {0, 1, 2}-base offsets from the start of
# the sequence and the second is a list of start codons matching any sequence
# in @START_CODONS for that reading frame.
sub find_start_codons( $ ) {
    my $seq = shift;
    my ($pos, $codon);
    my $starts = [];

    for (my $frame = 0; $frame < $CODON_SIZE; $frame++) {
        #print "Reading frame $frame\n";
        #$starts->[$frame] = [];

        for ( $pos = $frame; $pos < $SEQ_LENGTH; $pos += $CODON_SIZE ) {

            # Stop processing if we don't have an entire codon to read at the
            # end.
            # FIXME: Keep reading, since mtDNA is circular.
            last if ( $SEQ_LENGTH - $pos < $CODON_SIZE );

            $codon = join('', @$seq[$pos .. $pos + $CODON_SIZE - 1]);

            foreach my $start (@START_CODONS) {

                if ( substring_match($seq, $start, $pos) ) {
                    #push @{$starts->[$frame]}, { $pos => $start };
                    #push @{$starts->[$frame]}, $pos;
                    push @{$starts}, $pos;
                }

            } # for each possible start codon in @START_CODONS

        } # for each codon

    } # for each reading frame (0 .. $CODON_SIZE - 1 offsets)

    # Sort before returning, since they're in reading frame order up until
    # now
    return [ sort { $a <=> $b } @$starts ];

} # find_start_codons


# Given a two-dimensional array of start codons by reading frame {0, 1, 2},
# return an array of hashes where the keys are the start posistions and the
# values are the lengths of the longest open reading frame (or undef if one
# can't be found before the end of the sequence).
sub find_orfs( $$ ) {
    my ( $seq, $starts ) = @_;

    #my $orfs = [];
    #for ( my $fr = 0; $fr < $CODON_SIZE; $fr++ ) {
    #    $orfs->[$fr] = {
    #        map { $_ => find_longest_orf($seq, $_) } @{$starts->[$fr]}
    #    };
    #}
    #return $orfs;

    return { map { $_ => find_longest_orf($seq, $_) } @{$starts} }

} # find_orfs


# Given an array of bases ($seq) and a starting position, find the longest
# open reading frame starting with $startpos that exceeds $MIN_GENE_LENGTH and
# return the total *length* of the sequence.
sub find_longest_orf( $$ ) {
    my ( $seq, $startpos ) = @_;
    my $longest = 0;
    my $orf = '';

    for ( my $pos = $startpos; $pos < $SEQ_LENGTH; $pos += $CODON_SIZE ) {

        # Stop processing if we don't have an entire codon to read.
        # FIXME: Keep reading, since mtDNA is circular.
        last if ( $SEQ_LENGTH - $pos < $CODON_SIZE );

        foreach my $stop (@STOP_CODONS) {

            if ( substring_match( $seq, $stop, $pos ) ) {
                return $pos - $startpos + $CODON_SIZE
                    unless ( ($pos - $startpos + 1) < $MIN_GENE_LENGTH );
            } # return length of ORF, unless it's not long enough

        } # for each valid stop codon

    } # for each codon until the end of the sequence

    return undef;
} # _find_open_reading_frame


# Given an array of bases ($seq), return the codon (consecutive bases of size
# $CODON_SIZE) found in $seq at position $pos.
sub get_codon_at( $$ ) {
    my ($seq, $pos) = @_;
    return join('', @$seq[$pos..$pos+$CODON_SIZE-1]);
}


# Given an array of bases ($seq), return a (sub)sequence range between $start
# and $end. Pretty-print (separate $CODON_SIZE bases with spaces) before
# returning if $pretty (the fourth argument) is given a truthy value.
sub get_seq_range( $$$;$ ) {
    my ( $seq, $start, $end, $pretty ) = @_;
    my $ret = '';

    carp "Warning: Range not an even multiple of codon size"
       unless ( ($end - $start + 1) % $CODON_SIZE == 0 );

    for (my $pos = $start; $pos < $end; $pos += $CODON_SIZE ) {
        $ret .= join('', @$seq[$pos..$pos+$CODON_SIZE-1]);
    }

    $ret =~ s/(\w{3})(?!$)/$1 /g if ($pretty);
    return $ret;
} # get_seq_range


# Return a (sub)sequence of $seq of $length bases beginning at $start. Pretty-
# print (separate $CODON_SIZE bases with spaces) before returning if $pretty
# (the fourth argument) is given a truthy value.
sub get_seq_of_length( $$$;$ ) {
    my ( $seq, $start, $length, $pretty ) = @_;

    carp "Warning: Length not an even multiple of codon size"
       unless ( $length % $CODON_SIZE == 0 );

    return get_seq_range($seq, $start, $start+$length-1);
} # get_seq_of_length


# Return true if sequence $seq (an array of bases) contains substring $substr at
# postition $pos. Print extra debugging output if $chatty is given as true.
sub substring_match( $$$;$ ) {
    my ($seq, $substr, $pos, $chatty) = @_;
    print "Substring match called to match $substr @ pos $pos\n" if $chatty;

    if ( join('', @$seq[$pos .. $pos + length($substr) - 1]) eq $substr ) {
        return 1;
    } else {
        return 0;
    }
} # substring_match


# Compute the % GC content (reported as a fraction) of the given range
sub gc_content_of_range( $$$ ) {
    my ($seq, $start, $end) = @_;
    my $gs_or_cs = 0;

    carp "Warning: Range not an even multiple of codon size"
       unless ( ($end - $start + 1) % $CODON_SIZE == 0 );

    for (my $pos = $start; $pos < $end + 1; $pos++) {
        $gs_or_cs++ if @$seq[$pos] eq 'G' || @$seq[$pos] eq 'C';
    }

    return $gs_or_cs / ($end - $start + 1) * 100;

} # gc_content_of_range


#sub gc_content_of_seq( $$$ );


# Source: http://perldoc.perl.org/perlform.html#Accessing-Formatting-Internals
sub swrite( $@ ) {
    croak "usage: swrite PICTURE ARGS" unless @_;
    my $format = shift;
    $^A = "";
    formline($format,@_);
    return $^A;
}
#!/usr/bin/env perl
####################################################################
##                                                                ##
##  @file    findorfs.pl                                          ##
##  @brief   CS7009 homework #1 - find ORFs in human mtDNA        ##
##                                                                ##
##  @author  Kevin Ernst (ernstki@mail.uc.edu)                    ##
##  @date    1 February 2015                                      ##
##                                                                ##
####################################################################
use strict;
use warnings;
use autodie;
#use Carp;                             # Warnings with (better) line numbers
#use Data::Dump qw( dd dump );         # For debugging statements
use English;                          # English names for magic variables
use FindBin;                          # Find where this script is
use Getopt::Long;                     # Command-line argument processing

use lib "$FindBin::Bin/lib";
use CS7099Lib::Lab01 qw( :DEFAULT :constants );

#
#                           P R O T O T Y P E S 
#                           ===================

sub codons_at_positions( @ );
sub sequences_by_ranges( @ );
#sub sequences_of_length( $$ );
sub display_report();
sub print_report();
sub _report();


#
#                     P R O C E S S   A R G U M E N T S
#                     =================================

my $zero_base       = '';
my $print_report    = '';
#my $seqs_by_ranges  = '';
#my $seqs_by_lengths = ();
#my $codons_at       = '';

GetOptions(
    'z|zero-base'            => \$zero_base,
    'p|print'                => \$print_report,
    #'c|codon-at|codons-at=s' => \$codons_at,
    #'s|sequence=s'           => \$seqs_by_ranges,
);


#
#                       M A K E   I T   H A P P E N
#                       ===========================

use vars qw ( $seq $orfs $genes );
my $seq    = read_seq();
my $starts = find_start_codons($seq);
my $orfs   = find_orfs($seq, $starts);
my $genes  = read_gene_list();

SWITCH: {
    #codons_at_positions($codons_at)       and last SWITCH if @codons_at;
    #sequences_by_range($seqs_by_ranges)   and last SWITCH if $seqs_by_ranges;
    #sequences_of_length($seqs_by_lengths) and last SWITCH if $seqs_by_lengths;
    print_report()                      and last SWITCH if $print_report;

    # else:
    display_report();
}


#
#                          S U B R O U T I N E S
#                          =====================

# Unimplemented at the moment :(
sub codons_at_positions( @ ) { } # codon_at_position
sub sequences_by_ranges( @ ) { } # sequence_range
sub sequences_of_length( $$ ) { } # sequence_of_length


# Create a formatted report of the open reading frames found in the target
# genome, suitable for printing (pages separated with linefeeds)
sub print_report() {
    # TODO Send to system default printer or create a PDF with GS
    $FORMAT_LINES_PER_PAGE = 58;
    _report();
}


# Display a formatted report of the open reading frames found in the target
# genome, suitable for display on screen (no linefeeds)
sub display_report() {
    $FORMAT_FORMFEED = "\n\n";
    _report();
}


# Internal function that does the actual work of making the report, using
# Perl formats (see 'perldoc perlform')
#
# TODO Allow sorting by Length, %GC Content, and Matches
sub _report() {

    my ($begin, $end, $length, $gc, $start, $stop, $gene, $match);

    format STDOUT_TOP =
Open Reading Frames in Human GRCh38 mtDNA Genome (@-based indices)
                                                  $zero_base?0:1

                                     Start  Stop                     Exact
Begin     End       Length    %GC    Codon  Codon  Strand      Gene  Match
--------  --------  --------  ----   -----  -----  ------  --------  -----
.
    format STDOUT =
@<<<<<<<  @<<<<<<<  @<<<<<<<  @#.#   @||||  @||||  @|||||  @>>>>>>>  @||||
$begin+1, $end+1,   $length,  $gc,   $start,$stop, 1,      $gene,    $match
.

    my $count = 0;
    foreach my $orf ( sort { $a <=> $b } keys(%$orfs) ) {
        $begin  = $orf + ($zero_base?0:1);
        $length = $orfs->{$orf};
        next if !$length;
        $end    = $begin + $length - 1;
        $gc     = gc_content_of_range($seq, $begin, $end);
        next if $gc < $MIN_GC_CONTENT;
        $start  = get_codon_at($seq, $begin);
        $stop   = get_codon_at($seq, $end - $CODON_SIZE + 1);

        # See if the position of the start codon coincides with one of the
        # protein-coding genes from the ENSEMBL data. (k *= 13; sigh.)
        $gene = $match = '';
        foreach my $g (@$genes) {
            # Since the ENSEMBL data is 1-indexed:
            if ( $g->{begin} == $orf + 1 ) {
                $gene  = $g->{gene};
                $match = '*' if ( $g->{end} == $orf + 1 + $length );
            }
        } # for each gene in the ENSEMBL list of protein-coding genes

        $count++;
        write;
    }

    printf(<<FOOTER, join(', ', @START_CODONS), join(', ', @STOP_CODONS), $count);

    Considering:

     Start codons :=  { %s }
     Stop  codons :=  { %s }

    ----------------------------------------------
     Total ORFS:  %d

FOOTER
} # _report

# GeneFinder.pl

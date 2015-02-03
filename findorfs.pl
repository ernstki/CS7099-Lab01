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
use Carp;                             # Warnings with (better) line numbers
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

use vars qw ( $seq $orfs );
my $seq = read_fasta();
my $starts = find_start_codons($seq);
my $orfs = find_orfs($seq, $starts);

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
    # TODO: Send to system default printer or create a PDF with GS
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
sub _report() {

    my ($begin, $end, $length, $gc, $start, $stop);

    format STDOUT_TOP =
Open Reading Frames in Human GRCh38 mtDNA Genome (@-based indices)
                                                  $zero_base?0:1

                                     Start  Stop
Begin     End       Length    %GC    Codon  Codon  Strand
--------  --------  --------  ----   -----  -----  ------
.
    format STDOUT =
@<<<<<<<  @<<<<<<<  @<<<<<<<  @#.#   @||||  @||||  @|||||
$begin+1, $end+1,   $length,  $gc,   $start,$stop, 1
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
        $count++;
        write;
    }

    printf(<<FOOTER, $count);

    ------------------------
     Total ORFS: %10d

FOOTER
} # _report

# GeneFinder.pl
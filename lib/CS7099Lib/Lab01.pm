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

package CS7099Lib::Lab01;
require Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw( &read_fasta &find_start_codons &find_orfs );
@EXPORT_OK = qw(
    &substring_match @START_CODONS @STOP_CODONS
    $INPUT_SEQ $CODON_SIZE $SEQ_LENGTH $MIN_GENE_LENGTH
);

use Carp;
use Data::Dump qw( dd dump );         # For debugging statements
use English;                          # English names for magic variables

use vars qw(
    @START_CODONS @STOP_CODONS $INPUT_SEQ $CODON_SIZE $SEQ_LENGTH
    $MIN_GENE_LENGTH
); 

#
#                            C O N S T A N T S
#                            =================

# Ref: https://www.idtdna.com/pages/docs/educational-resources/mitochondrial-dna.pdf
@START_CODONS    = qw( ATG ATA ATT );
@STOP_CODONS     = qw( AGA AGG );
$INPUT_SEQ       = 'mtDNA_1-16569.fasta';
$CODON_SIZE      = 3;
$SEQ_LENGTH      = 16569;  # FIXME: hard-coded
$MIN_GENE_LENGTH = 60;     # FIXME: allow as command-line option


#
#                           P R O T O T Y P E S
#                           ===================
sub read_fasta();
sub _read_fasta( $ );
sub find_start_codons( $ );
sub substring_match( $$$ );
sub find_orfs( $$ );
sub swrite( $@ );


sub read_fasta() {
	return _read_fasta($INPUT_SEQ);
}


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
    return $seq;
} # read_fasta


sub find_start_codons( $ ) {
	my $seq = shift;
	my ($pos, $codon);
	my $starts = [];
	
	# FIXME: Also scan in reverse direction.
    for (my $frame = 0; $frame < $CODON_SIZE; $frame++) {
        #print "Reading frame $frame\n";
        $starts->[$frame] = [];

        for ( $pos = $frame; $pos < $SEQ_LENGTH; $pos += $CODON_SIZE ) {
        
            # Stop processing if we don't have an entire codon to read at the
            # end.
            # FIXME: Keep reading, since mtDNA is circular.
            last if ( $#$seq - $pos < $CODON_SIZE - 1 );
        	
        	$codon = join('', @$seq[$pos .. $pos + $CODON_SIZE - 1]);

            foreach my $start (@START_CODONS) {

                if ( substring_match($seq, $start, $pos) ) {
                    #print "FOUND\t$pos\t$codon\n";
                    push @{$starts->[$frame]}, { $pos => $start };
                }

            } # for each possible start codon in @START_CODONS

        } # for each codon

    } # for each reading frame (0 .. $CODON_SIZE - 1 offsets)
    
    return $starts;
    
} # find_start_codons

sub find_orfs( $$ ) {
	my ( $seq, $starts ) = @_;
	my $orfs = [];
    for ( my $fr = 0; $fr < $CODON_SIZE; $fr++ ) {
    	@{$orfs->[$fr]} = [];
        push @{$orfs->[$fr]},
            map { $_ => _find_longest_orf($seq, $_) } @{$starts->[$fr]};
    }
    return $orfs;
} # find_orfs

# Find the longest open reading frame starting with $pos that exceeds
# $MIN_GENE_LENGTH:
sub _find_longest_orf( $$ ) {
	my ( $seq, $startpos ) = @_;
	my $longest = 0;
	my $orf = '';
	
	foreach my $stop (@STOP_CODONS) {
		for ( my $pos = $startpos; $pos < @$seq - $CODON_SIZE; $pos += $CODON_SIZE ) {
			if ( substring_match( $seq, $stop, $pos ) ) {
				print "$startpos, " . $startpos + $pos
				      . " - " . @$seq[$startpos..$pos] . "\n";
			}
		} # for each codon until the end of the sequence
		
	} # for each valid stop codon
    	
} # _find_open_reading_frame


# Return true if sequence $seq contains substring $substr at postition $pos
sub substring_match( $$$ ) {
	my ($seq, $substr, $pos) = @_;
		
	if ( join('', @$seq[$pos .. $pos + length($substr) - 1]) eq $substr ) {
		return 1;
	} else {
        return 0;
	}
} # substring_match


# Source: http://perldoc.perl.org/perlform.html#Accessing-Formatting-Internals
sub swrite( $@ ) {
    croak "usage: swrite PICTURE ARGS" unless @_;
    my $format = shift;
    $^A = "";
    formline($format,@_);
    return $^A;
}
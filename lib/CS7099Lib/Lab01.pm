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
@EXPORT = qw( &read_fasta &find_start_codons );
@EXPORT_OK = qw(
    &substring_match
    @START_CODONS @STOP_CODONS
    $INPUT_SEQ $CODON_SIZE $SEQ_LENGTH
);

use Carp;
use Data::Dump qw( dd dump );         # For debugging statements
use English;                          # English names for magic variables

use vars qw( @START_CODONS @STOP_CODONS $INPUT_SEQ $CODON_SIZE $SEQ_LENGTH ); 

# Ref: https://www.idtdna.com/pages/docs/educational-resources/mitochondrial-dna.pdf
@START_CODONS = qw( ATG ATA ATT );
@STOP_CODONS  = qw( AGA AGG );
$INPUT_SEQ    = 'mtDNA_1-16569.fasta';
$CODON_SIZE   = 3;
$SEQ_LENGTH   = 16569;  # FIXME: hard-coded


sub read_fasta();
sub _read_fasta( $ );
sub find_start_codons( $ );
sub substring_match( $$$ );
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
	my $starts = {};
	
	# FIXME: Also scan in reverse direction.
    for (my $frame = 0; $frame < $CODON_SIZE; $frame++) {
        print "Reading frame $frame\n";
        $starts->{$frame} = {};

        for ( $pos = $frame; $pos < $SEQ_LENGTH; $pos += $CODON_SIZE ) {
        
            # Stop processing if we don't have an entire codon to read at the
            # end.
            # FIXME: Keep reading, since mtDNA is circular.
            last if ( $#$seq - $pos < $CODON_SIZE - 1 );
        	
        	$codon = join('', @$seq[$pos .. $pos + $CODON_SIZE - 1]);

            foreach my $start (@START_CODONS) {

                if ( substring_match($seq, $start, $pos) ) {
                    #print "FOUND\t$pos\t$codon\n";
                    $starts->{$frame}->{$pos} = $start;
                }

            } # for each possible start codon in @START_CODONS

        } # for each codon

    } # for each reading frame (0 .. $CODON_SIZE - 1 offsets)
    
    return $starts;
    
} # find_start_codons


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
####################################################################
##                                                                ##
##  @file GeneFinder.pl                                           ##
##  @brief CS7009 homework #1 - find ORFs in human mtDNA          ##
##                                                                ##
##  @author  Kevin Ernst (ernstki@mail.uc.edu)                    ##
##  @date    1 February 2015                                      ##
##                                                                ##
####################################################################


package GeneFinder;
use vars qw( START_CODONS STOP_CODONS ); 

# Ref: https://www.idtdna.com/pages/docs/educational-resources/mitochondrial-dna.pdf
@START_CODONS = qw( ATG ATA ATT );
@STOP_CODONS  = qw( AGA AGG );


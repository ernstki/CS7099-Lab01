#!/usr/bin/env perl
####################################################################
##                                                                ##
##  @file GeneFinder.pl                                           ##
##  @brief CS7009 homework #1 - find ORFs in human mtDNA          ##
##                                                                ##
##  @author  Kevin Ernst (ernstki@mail.uc.edu)                    ##
##  @date    1 February 2015                                      ##
##                                                                ##
####################################################################
use strict;
use warnings;
use Carp;
use Data::Dump qw( dd dump );         # For debugging statements
use English;                          # English names for magic variables
use FindBin;

use lib "$FindBin::Bin/lib";
use CS7099Lib::Lab01;


my $seq = read_fasta();
my $starts = find_start_codons($seq);
my $orfs = find_orfs($seq, $starts);

#format REPORT =
#@<<  @<<<<<<<  @<<<<<<<  @<<<
#$fr, $start,   $stop,    $pctgc
#.


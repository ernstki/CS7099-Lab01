#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More qw( no_plan );           # Perl test framework
use FindBin;                            # to find *this* script
use File::Spec::Functions;              # for catdir and catfile

my @dotdot = ( $FindBin::Bin, '..' );
use lib catdir(@dotdot, 'lib' );
use CS7099Lib::Lab01 qw( $INPUT_SEQ );

subtest 'Required data files and libraries present?' => sub {
	ok( -f catfile(@dotdot, $INPUT_SEQ), 'Input FASTA file present?' );
	use_ok('CS7099Lib::Lab01');	
};

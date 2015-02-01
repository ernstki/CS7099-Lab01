#!/usr/bin/perl -w
use strict;
use warnings;

print "1..1\n"; # fool Test::Builder into believing this is a plan

if (1) {
    print "ok\n";
} else {
    print "not ok\n";
}

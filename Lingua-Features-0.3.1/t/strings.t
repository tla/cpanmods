#!/usr/bin/perl
# $Id: strings.t,v 1.2 2004/05/03 12:46:49 guillaume Exp $

use Lingua::Features;
use Test::More;
use strict;

# compute plan
open(STRINGS, 'strings') or die "unable to open strings: $!";
my @strings = <STRINGS>;
close(STRINGS);
plan tests => scalar @strings;

foreach my $string (@strings) {
    chomp $string;
    is(
	Lingua::Features::Structure->from_string($string)->to_string(),
	$string,
	"$string parsing"
    );
}

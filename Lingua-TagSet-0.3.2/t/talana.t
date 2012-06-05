#!/usr/bin/perl
# $Id: talana.t,v 1.2 2005/03/23 10:30:49 rousse Exp $

use Lingua::TagSet::Talana;
use Test::More;
use strict;

# compute plan
open(T2S, 't/talana2feature') or die "unable to open talana2feature: $!";
my @tags2strings = <T2S>;
close(T2S);
open(S2T, 't/feature2talana') or die "unable to open feature2talana: $!";
my @strings2tags = <S2T>;
close(S2T);
plan tests => @tags2strings + @strings2tags;

foreach my $test (@tags2strings ) {
    chomp $test;
    my ($tag, $string) = split(/\t/, $test);
    is(Lingua::TagSet::Talana->tag2string($tag), $string, "$tag conversion"); 
}

foreach my $test (@strings2tags) {
    chomp $test;
    my ($string, $tag) = split(/\t/, $test);
    is(Lingua::TagSet::Talana->string2tag($string), $tag, "$string conversion"); 
}

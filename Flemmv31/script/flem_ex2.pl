#!/usr/bin/env perl

###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de # 
# corpus étiquetés - Version 3.1				          #
# Copyright (C) 2004 (NAMER Fiammetta)					  #
###########################################################################

# Input (Treetagger) : 1 occurrence étiquetée par ligne
# Sortie souhaitée : XML

# script/flem_ex2.pl < tests/test_tt_1.input > tests/test_tt_12.xml 
# script/flem_ex2.pl < tests/pls.tt > tests/pls_2.xml

use lib 'lib';
use strict;
use warnings;
use Flemm;
use Flemm::Result;
use utf8;
binmode STDIN, ':encoding(UTF-8)';
binmode STDOUT, ':utf8';

my $lemm=new Flemm(
		   "Tagger" => "TreeTagger"
		   );

print "<?xml version='1.0' encoding='utf-8'?>\n\n";
print "<FlemmResults>\n";
while (<>) {
    chomp;

    my $res = $lemm->lemmatize($_);
    print $res->asXML."\n";

}
print "</FlemmResults>\n";

#!/usr/bin/env perl

###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de # 
# corpus étiquetés - Version 3.1				          #
# Copyright (C) 2004 (NAMER Fiammetta)					  #
###########################################################################

# Input (Brill) : 1 paragraphe par ligne
# Sortie souhaitée : XML

# script/flem_ex4.pl < tests/test_bll_1.input > tests/test_bll_1_4.xml
# script/flem_ex4.pl < tests/agatha.bll > tests/agatha_bll_4.xml

use lib 'lib';
use strict;
use warnings;
use Flemm;
use Flemm::Result;
use utf8;
binmode STDIN, ':encoding(UTF-8)';
binmode STDOUT, ':utf8';

my $lemm=new Flemm(
		   "Tagger" => "brill"
		   );

print "<?xml version='1.0' encoding='utf-8'?>\n\n";
print "<FlemmResults>\n";

while (<>) {
    chomp;
    
    foreach my $ff (split(/ /,$_)) {
	
	my $res = $lemm->lemmatize($ff);
	print $res->asXML."\n";
    }
}

print "</FlemmResults>\n";

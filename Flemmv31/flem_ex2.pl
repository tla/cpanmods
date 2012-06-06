#!/usr/bin/env perl

###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de # 
# corpus étiquetés - Version 3.1				          #
# Copyright (C) 2004 (NAMER Fiammetta)					  #
###########################################################################

# Input (Treetagger) : 1 occurrence étiquetée par ligne
# Sortie souhaitée : XML

# perl flem_ex2.pl < tests/test_tt_1.input > tests/test_tt_12.xml 
# perl flem_ex2.pl < tests/pls.tt > tests/pls_2.xml

use Flemm;
use Flemm::Result;

my $lemm=new Flemm(
		   "Tagger" => "TreeTagger"
		   );

print "<?xml version='1.0' encoding='ISO-8859-1'?>\n\n";
print "<FlemmResults>\n";
while (<>) {
    chomp;

    my $res = $lemm->lemmatize($_);
    print $res->asXML."\n";

}
print "</FlemmResults>\n";

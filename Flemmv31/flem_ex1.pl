#!/usr/bin/env perl

###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de # 
# corpus étiquetés - Version 3.1				          #
# Copyright (C) 2004 (NAMER Fiammetta)					  #
###########################################################################

# Input (Brill) : 1 paragraphe par ligne
# Sortie souhaitée : plate, un mot par ligne
# Logfile :

# perl flem_ex1.pl < tests/test_bll_1.input > tests/test_bll_1_1.plat
# perl flem_ex1.pl < tests/agatha.bll > tests/agatha_bll_1.plat
use Flemm;
use Flemm::Result;

my $lemm=new Flemm(
		   "Tagger" => "brill",
		   "Logname" => "/tmp/log_errors"
		   );

while (<>) {
    chomp;

    foreach my $ff (split(/ /,$_)) {
	my $res = $lemm->lemmatize($ff);
	print $res->getResult."\n";
    }
}


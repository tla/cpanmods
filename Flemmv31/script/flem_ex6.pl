#!/usr/bin/env perl

###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de # 
# corpus étiquetés - Version 3.1				          #
# Copyright (C) 2004 (NAMER Fiammetta)					  #
###########################################################################

# Input (Brill) : 1 paragraphe par ligne, ISO Latin 1
# Sortie souhaitée : plate, un mot par ligne, ISO Latin 1
# Logfile :

# script/flem_ex6.pl < tests/test_bll_1.iso1.input > tests/test_bll_1_1.iso1.plat

use lib 'lib';
use strict;
use warnings;
use Flemm;
use Flemm::Result;
use utf8;

my $lemm=new Flemm(
		   "Tagger" => "brill",
		   "Logname" => "/tmp/log_errors",
		   "Encoding" => "ISO-8859-1"
		   );

while (<>) {
    chomp;

    foreach my $ff (split(/ /,$_)) {
	my $res = $lemm->lemmatize($ff);
	print $res->getResult."\n";
    }
}


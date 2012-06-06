#!/usr/bin/env perl

###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de # 
# corpus étiquetés - Version 3.1				          #
# Copyright (C) 2004 (NAMER Fiammetta)					  #
###########################################################################

# Input (Treetagger) : 1 occurrence étiquetée par ligne
# Sortie souhaitée : plate
# Logfile 

# script/flem_ex5.pl < tests/test_tt_1.input > tests/test_tt_15.plat 
# script/flem_ex5.pl < tests/pls.tt > tests/pls_5.plat

use lib 'lib';
use strict;
use warnings;
use Flemm;
use Flemm::Result;
use utf8;
binmode STDIN, ':encoding(UTF-8)';
binmode STDOUT, ':utf8';

my $lemm=new Flemm(
		   "Tagger" => "Treetagger",
		   "Logname" => "/tmp/log_errors"
		   );

while (<>) {
    chomp;
    
    my $res = $lemm->lemmatize($_);
    print $res->getResult."\n";
    
}



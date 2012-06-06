#!/usr/bin/env perl

###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de # 
# corpus étiquetés - Version 3.1				          #
# Copyright (C) 2004 (NAMER Fiammetta)					  #
###########################################################################

# Input (Brill) : 1 paragraphe par ligne
# Sortie souhaitée : plate, 1 paragraphe par ligne


# script/flem_ex3.pl < tests/test_bll_1.input > tests/test_bll_1_3.plat
# script/flem_ex3.pl < tests/agatha.bll > tests/agatha_bll_3.plat

use lib 'lib';
use strict;
use warnings;
use Flemm;
use Flemm::Result;
use utf8;
binmode STDIN, ':encoding(UTF-8)';
binmode STDOUT, ':utf8';

my $lemm=new Flemm(
                'Tagger' => 'Brill'
               );
 
while (<>) {
    chomp;  

    my $res=$lemm->lemmatize($_);
    print $res->getResult."\n";
       
}




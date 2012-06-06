###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de # 
# corpus étiquetés - Version 3.1				          #
# Copyright (C) 2004 (NAMER Fiammetta)					  #
###########################################################################




FLEMMv3.1 is a Perl5 set of modules that performs 
inflectional analysis on French texts which have previously 
been tagged (i.e. by either the TreeTagger or the Brill tagger). This
is a small program, (60kb in a zipped format, excluded the test
programs and corpora) mainly rule-based (i.e. only a 3000 words
lexicon is used in order  to deal with exceptions). It runs on PCs or
Workstation, under Unix, Linux or Windows9x/NT/XP OS.

The returned Flemm result objects are likely to be displayed as 
XML structures.


      - To test Flemmv3.1
      - Changes wrt the previous version
      - Input Format
      - Description
      - Examples and test programs
      - Other functionalities
      - Distribution Content

===============
To test Flemmv3.1
===============

1) be sure to add the Flemmv3.1 directory address to the PERL5LIB environment variable, e.g.
   export PERL5LIB=~/Flemmv31

2) run :
   perl flemm.pl --entree ~/Flemmv31/tests/agatha.input --log --logname test_bll_1 --progress --format normal --tagger brill
   perl flemm.pl --entree ~/Flemmv31/tests/test_tt_1.input --sortie ~/Flemmv31/tests/test_tt_1.xml --format xml --tagger treetagger




================================
Changes wrt the previous version
================================

- updating according to the new Treetagger tagset (3.1)
- results designed as perl APIs
- fully documented modules (see perldoc function)
- inflectional features formatted according to the Multext norm.
- two possible displays of the results : either linear or xml formats.

See below for more details.

============
Input Format
============

FLEMM has to be provided  
with a tagged inflected form as input. At the time being, the only recognized 
tagset are Brill's 
(http://www.atilf.fr/WinBrill)
and Treetagger's  
(http://www.ims.uni-stuttgart.de/projekte/corplex/TreeTagger/DecisionTreeTagger.html). 


===========
Description
===========

FLEMM  computes the lemma of each inflected word (according 
to the tag) and also provided its  main morphological features :
- gender and number for adjectives, determiners, participles
- number for nouns
- gender, number, person and case for pronouns
- number, person, tense, mood and conjugation group for verbs

The features are encoded according to lexical specifications 
recommended for French by the MulText group
(http://www.lpl.univ-aix.fr/projects/multext), displaying them in
their compact format. In addition to the standard features, one field
has been added for verbs, in order to encode their inflectional family
(1st, 2nd or 3d conjugation group). The array below sums up the
attribute-value tables for the inflected part-of-speech. Please
consult the Multext Website for detailed information about value
meanings and correspondances. 


==================================================================
Nouns | cat | type | Gend | Nb | Case | SemType
------------------------------------------------------------------
      | N   | c,p  | m,f  | s,p|  -   |  -
==================================================================
Verbs | cat | type | Mood | Tns| Pers | Nb | Gend | Clitics |Group
------------------------------------------------------------------
      | V   | m,a  |i,s,m,|p,i,|1,2,3 |s,p |m,f   | -       |1,2,3
                   |n,p   |f,s
==================================================================
Adj   | cat | type    | dgr  |gend| nb | Case
------------------------------------------------------------------
      | A   | f,o,i,s | -    |m,f |s,p | -
==================================================================
Pro   | cat | type         | pers |gend| nb | case | poss
------------------------------------------------------------------
      | P   |p,d,i,s,t,r,x |1,2,3 |m,f |s,p | n,j,o| s,p
==================================================================
Det   | Cat | Type    | Pers |gend| nb | case | poss | quant
------------------------------------------------------------------
      | D   |a,d,i,s,t| 1,2,3|m,f |s,p |  -   | s,p  |d,i
==================================================================
PrepDet| Cat| Type | Pers |gend| nb | case | poss | quant
------------------------------------------------------------------
       |Sp+D|  a   |   -  |m,f |s,p |  -   |  -   |d
==================================================================             
                    


Moreover, FLEMM checks and fixes some segmentation or tagging 
errors. When asked by the user, the detected errors, together 
with the corresponding corrections,  are reported in special 
files.

Whatever the result of its tagging checking Flemm also returns 
the original tag provided by the tagger, 


========
Examples
========


1) The example below produces a linear output result from a Brill 
tagged input:

----------------------------------------
exple.pl
----------------------------------------
use Flemm;
use Flemm::Result;
my $lemm=new Flemm("Tagger" => "brill");
while (<>) {
    chomp;
    my $res = $lemm->lemmatize($_);
    print $res->getResult."\n";
}
----------------------------------------
----------------------------------------

echo 'fabrique/VCJ:sg' | perl exple.pl   

     -->
     fabrique/VCJ:Vmip1s--1	fabriquer || fabrique/VCJ:Vmip3s--1	fabriquer || fabrique/VCJ:Vmmp2s--1	fabriquer || fabrique/VCJ:Vmsp1s--1	fabriquer || fabrique/VCJ:Vmsp3s--1	fabriquer   

2) The example below produces an xml formatted result from a TreeTagger tagged
input:

----------------------------------------
exple.pl
----------------------------------------
  use Flemm;
  use Flemm::Result;
  my $lemm=new Flemm( );
  print "<?xml version='1.0' encoding='ISO-8859-1'?>\n\n";
  print "<FlemmResults>\n";
  while (<>) {
    chomp;
    my $res=$lemm->lemmatize($_);
    print $res->asXML."\n";
  }
  print "</FlemmResults>\n";
----------------------------------------
----------------------------------------

echo 'généralisent	VER:pres	généraliser' | perl exple.pl

   -->

<FlemmResult>
      <InflectedForm>généralisent</InflectedForm>
      <Category original-tagger='VER:pres'>VER(pres)</Category>
      <Analyses> <!-- généralisent      VER(pres):Vmip3p--1      généraliser || généralisent      VER(pres):Vmsp3p--1      généraliser -->
            <Analyse>
                  <Lemme>généraliser</Lemme>
                  <Features>
                        <Feature name='catmultext' value='V'/>
                        <Feature name='type' value='m'/>
                        <Feature name='mood' value='i'/>
                        <Feature name='tense' value='p'/>
                        <Feature name='pers' value='3'/>
                        <Feature name='gend' value='-'/>
                        <Feature name='nb' value='p'/>
                        <Feature name='clitic' value='-'/>
                        <Feature name='vclass' value='1'/>
                  </Features>
            </Analyse>
            <Analyse>
                  <Lemme>généraliser</Lemme>
                  <Features>
                        <Feature name='catmultext' value='V'/>
                        <Feature name='type' value='m'/>
                        <Feature name='mood' value='s'/>
                        <Feature name='tense' value='p'/>
                        <Feature name='pers' value='3'/>
                        <Feature name='gend' value='-'/>
                        <Feature name='nb' value='p'/>
                        <Feature name='clitic' value='-'/>
                        <Feature name='vclass' value='1'/>
                  </Features>
            </Analyse>
      </Analyses>

</FlemmResult>

3) In the distribution, several testing programs are provided with
relevant input samples :

Program name |  Requested tagger | Output      Format	| Logfiles
	     |  on the input     |			|		
==================================================================
flem_ex1.pl  |   brill		 | flat structures,     | yes
	     |			 |  1 per line		|
ex : 
perl flem_ex1.pl < tests/test_bll_1.input > tests/test_bll_1_1.plat
perl flem_ex1.pl < tests/agatha.bll > tests/agatha_bll_1.plat
------------------------------------------------------------------
flem_ex2.pl  |   tt		 | xml  structures,     | no
	     |			 |       		|
ex 
perl flem_ex2.pl < tests/test_tt_1.input > tests/test_tt_12.xml 
perl flem_ex2.pl < tests/pls.tt > tests/pls_2.xml
------------------------------------------------------------------
flem_ex3.pl  |   brill		 |flat  structures,     | no
	     |			 | 1 paragraph per line |
ex 
perl flem_ex3.pl < tests/agatha.bll > tests/agatha_bll_3.plat
------------------------------------------------------------------
flem_ex4.pl  |   brill		 | xml  structures,     | no
	     |			 |              	|
ex : 
perl flem_ex4.pl < tests/test_bll_1.input > tests/test_bll_1_4.xml
perl flem_ex4.pl < tests/agatha.bll > tests/agatha_bll_4.xml
------------------------------------------------------------------
flem_ex5.pl  |   tt		 | flat structures,     | yes
	     |			 |  1 per line		|
ex 
perl flem_ex5.pl < tests/test_tt_1.input > tests/test_tt_15.plat 
perl flem_ex5.pl < tests/pls.tt > tests/pls_5.plat

4) flemm.pl is a more complete test program. It is provided with several options :

Usage: perl flemm.pl       --entree input_file_address
                          [--sortie output_file_address]
                          [--log]
                          [--logname logfile_prefixes]
                          [--progess]
                          [--format (normal|xml)]
                          [--tagger (brill|treetagger)]

Arguments between [] are optional.

When --progress is chosen, a mark is displayed on the standard output,
that indicates the parsing progression
 
By default :

- when no --sortie is provided, the result is displayed in the
  input_file_address.lemm file 

- when --log is not mentioned, there is no file storing the correction
  of tagging and segmentation errors (if any). When --log is on, the
  logfile names are prefixed by the input_file_address, unless a
  prefix is provided as --logname value. 

- when --tagger is omitted, the default tagger is Treetagger


=====================
Other Functionalities
=====================

FLEMM checks and fixes some segmentation or tagging 
errors. When requested by the user, the detected errors, together 
with the corresponding corrections,  are reported in special 
files.

Examples : 


1) tagging log file
-------------------

phytoplancton / VNCFF ==>  phytoplancton/SBC
phytoplanctivores / ADJ2PAR ==>  phytoplanctivores/ADJ

2) Segmentation log file
-------------------------

,inhibiteurs  est réduit à inhibiteurs (SBC) 


====================
Distribution Content
====================

The following modules and subdirectories are included in the Flemmv31 tree:

Flemmv31:			 /Main module, and testing programs/
=========
Flemm.pm	LICENCE.txt	README.txt	flemm.pl
flem_ex1.pl	flem_ex2.pl	flem_ex3.pl	flem_ex4.pl
flem_ex5.pl


Flemmv31/Flemm:		/packages required to run Flemm.pm/
===============
Analyse.pm	Analyses.pm	Brill.pm	Exceptions.pm
Feature.pm	Features.pm	Lemmatizer.pm	Result.pm
TreeTagger.pm 

Flemmv31/Flemm/Utils:	/utils packages/
=====================
List.pm

Flemmv31/tests:		/sample input files, to be runned with the
===============    	testing programs : test_bll_1.input and
			agatha.bll are tagged with Brill,
			test_tt_1.input and pls.tt are tagged with
			Treetagger/  

test_bll_1.input	test_tt_1.input
agatha.bll		pls.tt


Flemmv31/EXCEP:		/the set of exception lists/
===============
adjectifs_finissant_par_CCe	adjectifs_finissant_par_Ve	adjectifs_finissant_par_aOUos
adjectifs_finissant_par_an_e	adjectifs_finissant_par_ane	adjectifs_finissant_par_ere
adjectifs_finissant_par_ine	adjectifs_finissant_par_is	adjectifs_finissant_par_man_e
adjectifs_finissant_par_oOUil	adjectifs_finissant_par_ol	adjectifs_finissant_par_sOUte
adjectifs_finissant_par_sse_s	adjectifs_finissant_par_ure	adjectifs_finissant_par_us
noms_finissant_par_AEus		noms_finissant_par_Cs		noms_finissant_par_ail_x
noms_finissant_par_as		noms_finissant_par_au_x		noms_finissant_par_aux
noms_finissant_par_e_ee		noms_finissant_par_euse		noms_finissant_par_eux
noms_finissant_par_i_s		noms_finissant_par_ier_e	noms_finissant_par_os
noms_finissant_par_ou_x		noms_finissant_par_ous		noms_finissant_par_u_s
noms_finissant_par_ys		verbes_finissant_par_ERer	verbes_finissant_par_FPHer
verbes_finissant_par_ayer	verbes_finissant_par_eCer_naccent	verbes_finissant_par_eLer_aigu
verbes_finissant_par_eMer_naccent	verbes_finissant_par_eNTer_aigu	verbes_finissant_par_ePer_naccent
verbes_finissant_par_eRer_naccent	verbes_finissant_par_eSer_naccent	verbes_finissant_par_eVer_aigu
verbes_finissant_par_ier	verbes_finissant_par_igner	verbes_finissant_par_irer
verbes_finissant_par_isser	verbes_finissant_par_ller	verbes_finissant_par_tter







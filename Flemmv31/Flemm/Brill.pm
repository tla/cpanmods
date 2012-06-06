#
###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de # 
# corpus étiquetés - Version 3.1					  #
# Copyright (C) 2004 (NAMER Fiammetta)					  #
###########################################################################

#
# Module qui convertit l'entrée en format interne,
# appelle le lemmatiseur et
# convertit le résultat en format de Brill
#
#
#
# $Id$
#

package Flemm::Brill;

use strict;

use IO::File;
use Flemm::Lemmatizer;
use Flemm::Result;

#
# Méthodes publiques
#

sub new {
    my $type = shift;
    my (%params)=@_;
    
    my $self={};
    
    bless $self,$type;

    if (exists $params{Logname}) {
	my $logname=$params{Logname};

	$self->{log}=1;

	$self->{etiq}=new IO::File ">$logname.etiq";
	die "Impossible de créer $logname.etiq\n" if (!defined $self->{etiq});

	$self->{seg}=new IO::File ">$logname.seg";
	die "Impossible de créer $logname.seg\n" if (!defined $self->{seg});
    }
    else {
	$self->{log}=0;
    }

    # Les objets de la classe Flemm::Brill  contiennent un objet
    # de la classe Flemm::Lemmatizer. C'est precisément celui-là que 
    # l'on crée à l'instruction suivante.

    $self->{lemmatizer}=new Flemm::Lemmatizer();

    return $self;
}

sub lemmatize {
    my $self=shift;
    my ($entree)=@_;
    my ($aa);
    my (@tab);

    my $res="";

    # Correction de  "./.</ph=1></</txt=000028>" en  "./.</ph=1></txt=000028>"
    $entree =~ s/\<\/\</\</g;
    
    # Espaçage de  "./.</ph=1></txt=000028>" en  "./.</ph=1> </txt=000028>"
    $entree =~ s/\>/\> /g;
    
    # Espaçage de  "BLA</ph=1>" en  "BLA </ph=1>"
    $entree =~ s/([^ ])\</$1 \</g;
    $entree =~ s/\s+/ /g;
    @tab = split(/ /,$entree);
    my $catBrill;

    foreach $aa (@tab) {
	
	my $nb_brill="";
	
	# Conservation du nombre calculé par BRill.
	
	if ($aa =~ /:(.*)$/) {
	    $nb_brill = $1;
	}
	
	$aa =~ s/(.):..$/$1/;
	
	$aa =~ /^([^\/]*)\/([^\/ \t]*)/;
	$catBrill=$2;

	if (($aa =~ /^\</)||($aa =~ /^.\/.$/)) {
	    $res .= $aa;
	} else {
	    $res .= $self->identifie($aa,$nb_brill);
	}
	
	# Pour texte:

	if ($res !~ /\>$/) {
	    $res .= " ";
	}
    }

    my $resobj= new Flemm::Result;
    $resobj->setResult($res);
    $resobj->setMultext($res);
    $resobj->setOriginalTag($catBrill);
    return($resobj);    
}


#
# Méthodes privées
#

sub log {
    my $self=shift;
    my ($where,$what)=@_;
    my $fh=$self->{$where};

    if ($self->{log}) {
	print $fh $what;
    }
}

sub identifie {
    my $self = shift;
    my($entree0, $nb_brill) = @_;
    
    my($entree,$lex,$tag1,$tag, $lex_en_maj);

    my($res)="";



    # Séquence entrée:
    $entree0 =~ /(.*)\/(.*)/;
    $lex=$1;
    $lex_en_maj=$1;
    $tag1=$2;


    # Transformation du mot en minuscules:
    $lex =~ tr/A-ZÀÂÉÈÊËÎÏÔÖÙÛÜ/a-zàâéèêëîïôöùûü/;

    # Suppression des signes de ponctuations 
    # en fin de mot, et des virgules au début

    if (($lex =~ /^([^\.\?!]+)(\.|!|\?|:)+$/) && 
        ($tag1 !~ /ABR/) &&
        ($tag1 ne "SBP")) {
	$lex = $1;
	$self->log('seg',"$lex_en_maj  est réduit à $lex ($tag1) \n");
    }


    if ($lex =~ /^(\.,|\-)+([^,\.]+)$/) {
        $lex = $2;
	$self->log('seg',"$lex_en_maj  est réduit à $lex ($tag1) \n");
    }

    # Séquence traitée :
    $entree = $lex."/".$tag1;
    
    if ($entree =~ /ADJ$/) { 

	if ($entree =~ /(.*[^\-].?)(-t)?-(je|tu|ils?|elles?|nous|vous|on)\//) {

	    $entree =~ s/(-t)?-(je|tu|ils?|elles?|nous|vous|on)\//\//;
	    $entree =~ s/(.*)\/(.*)/$1\/VCJ/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    $res = $self->iliad($entree0,$self->stemm_verbe($entree),$nb_brill);
	}

	else {
	    $res =  $self->iliad($entree0,$self->stemm_adjectif($entree),$nb_brill); 
	}
    }


    
    # Concerne PRO/PRV

    elsif ($entree =~ /(PRV|PRO)/) {

	if ($entree =~ /(.*[^\-].?)(-t)?-(je|tu|ils?|elles?|nous|vous|on)\//) {

	    $entree =~ s/(-t)?-(je|tu|ils?|elles?|nous|vous|on)\//\//;
	    $entree =~ s/(.*)\/(.*)/$1\/VCJ/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    $res = $self->iliad($entree0,$self->stemm_verbe($entree),$nb_brill);
	}

	elsif ($entree =~ /(-t)-(je|tu|ils?|elles?|nous|vous|on)\//) {

	    $lex = $2;
	    $entree =~ s/(.*)\/(.*)/$lex\/$2/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    $res = $self->iliad($entree0,$self->stemm_pro($entree),$nb_brill);
	}


	elsif (($self->{"lemmatizer"}->est_un_pronom_personnel($lex)) ||
	       ($self->{"lemmatizer"}->est_un_pronom_meme($lex)) ||
	       ($self->{"lemmatizer"}->est_un_pronom_invariable($lex))  ) {

	    $res = $self->iliad($entree0,$self->stemm_pro($entree),$nb_brill);
	}

	# Concerne PRV

	elsif (($tag1 =~ /PRV/) &&
	       ($lex =~ /^[jtsclm][e\']$/)) {
	    $res = $self->iliad($entree0,$self->stemm_pro($entree),$nb_brill);
	}


	# Concerne PRV

	elsif (($tag1 =~ /PRV/) &&
	       ($lex =~ /^(l\'_on$|-t-|-ce|-il)/)) {
	    $res = $self->iliad($entree0,$self->stemm_pro($entree),$nb_brill);
	}

	# Concerne PRV

	elsif ($tag1 =~ /PRV/) {

	    # Premiere approximation : si PRV echoue, alors c'est un ADJ

	    $entree =~ s/(.*)\/(.*)/$1\/ADJ/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    
	    $res = $self->iliad($entree0,$self->stemm_adjectif($entree),$nb_brill);
	}
	
	# Concerne PRO

	elsif  ($lex =~ /(ae|ashe|[0-9]|ante?|[oiïay]que|[ai]ble|iche)s?$/) {
	    $entree =~ s/(.*)\/(.*)/$1\/ADJ/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    $res = $self->iliad($entree0,$self->stemm_adjectif($entree),$nb_brill);
	}

	# Concerne PRO

	elsif  (($lex =~ /(thérapie|ose|ate)s?$/)&&($lex !~ /quelque_chose/)) {
	    $entree =~ s/(.*)\/(.*)/$1\/SBC/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    $res = $self->iliad($entree0,$self->stemm_nom($entree),$nb_brill);
	}
	# Concerne PRO

	else {
	    $res = $self->iliad($entree0,$self->stemm_pro($entree),$nb_brill);
	} 
	
    }


    elsif ($entree =~ /SBP\?/) {
	
	# Le 14 septembre
	if ($entree !~ /^rendez-vous/) {
	    $entree =~ s/(.*)\/(.*)/$1\/SBC/;

	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    $res = $self->iliad($entree0,$self->stemm_nom($entree),$nb_brill);
	}

	elsif ($entree =~ /(.*[^\-].?)(-t)?-(je|tu|ils?|elles?|nous|vous|on)\//) {

	    $entree =~ s/(-t)?-(je|tu|ils?|elles?|nous|vous|on)\//\//;
	    $entree =~ s/(.*)\/(.*)/$1\/VCJ/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    $res = $self->iliad($entree0,$self->stemm_verbe($entree),$nb_brill);
	}

	elsif ($lex =~ /(nine|oside|tion|mie|logie|[ai]bilité|age|isme|[ae]nce|tu[rd]e|métrie|ose|ase|mycète|ement)s?$/) {

	    $entree =~ s/(.*)\/(.*)/$1\/SBC/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    $res = $self->iliad($entree0,$self->stemm_nom($entree),$nb_brill);
	}

	elsif ($lex =~ /(mique|iste|logique|[ai]ble|phile|[ae]nte|mètre|teur|trice|ière)s?$/) {
	    
	    $entree =~ s/(.*)\/(.*)/$1\/ADJ/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    
	    $res = $self->iliad($entree0,$self->stemm_adjectif($entree),$nb_brill);
	}
	
	else {

	    $res = $self->iliad($entree0,$entree,$nb_brill);
	}
    }

    elsif ($entree =~ /SBP$/) {

	if ($entree =~ /(.*[^\-].?)(-t)?-(je|tu|ils?|elles?|nous|vous|on)\//) {

	    $entree =~ s/(-t)?-(je|tu|ils?|elles?|nous|vous|on)\//\//;
	    $entree =~ s/(.*)\/(.*)/$1\/VCJ/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    $res = $self->iliad($entree0,$self->stemm_verbe($entree),$nb_brill);
	}
	else {

	    $res = $self->iliad($entree0,$entree,$nb_brill);
	}
    }

    elsif ($entree =~ /(DTN|REL|DTC)/) {

	if (($self->{"lemmatizer"}->est_un_determinant_ou_une_relative_invariable($lex)) ||
	    ($lex =~ /(quel|^une?$|^des$|^les?$|^la$|^[ld]\'$|^aux?$|^du$|^ce|^[mts](ien(ne)?s?|on|a|es)$|^[nv](os|otre)$|^leurs?|^tel|^nul|^tou|^certain|^aucun)/)) {

	    $res = $self->iliad($entree0,$self->stemm_detrel($entree),$nb_brill);
	}
	
	elsif ($lex =~ /_de$/) {
	    $entree =~ s/(.*)\/(.*)/$1\/PREP/;
	    $entree0 =~ s/(.*)\/(.*)/$1\/PREP/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");


	    $res = $self->iliad($entree0,$entree,$nb_brill);
	}

	else {
	    $entree =~ s/(.*)\/(.*)/$1\/SBC/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    
	    $res = $self->iliad($entree0,$self->stemm_nom($entree),$nb_brill);
	}
	
    }



    elsif ($entree =~ /(VNCNT|ANCNT|ENCNT)/) {

	if ($entree =~ /ante?s?\//) {
	    $res = $self->iliad($entree0,$self->stemm_ppres($entree),$nb_brill);
	}
	elsif ($entree =~ /(.*[^\-].?)(-t)?-(je|tu|ils?|elles?|nous|vous|on)\//) {

	    $entree =~ s/(-t)?-(je|tu|ils?|elles?|nous|vous|on)\//\//;
	    $entree =~ s/(.*)\/(.*)/$1\/VCJ/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    $res = $self->iliad($entree0,$self->stemm_verbe($entree),$nb_brill);
	}

	else {
	    $entree =~ s/(.*)\/(.*)/$1\/ADJ/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");
	    
	    $res = $self->iliad($entree0,$self->stemm_adjectif($entree),$nb_brill);
	}
    }
    
    elsif  ($entree =~ /SBC/) {

	# Le 14 septembre
	if ($entree =~ /^rendez-vous/) {

	    $res = $self->iliad($entree0,$self->stemm_nom($entree),$nb_brill);
	}


	elsif ($entree =~ /(.*[^\-].?)(-t)?-(je|tu|ils?|elles?|nous|vous|on)\//) {

	    $entree =~ s/(-t)?-(je|tu|ils?|elles?|nous|vous|on)\//\//;
	    $entree =~ s/(.*)\/(.*)/$1\/VCJ/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");


	    $res = $self->iliad($entree0,$self->stemm_verbe($entree),$nb_brill);
	}

	else {
	    $res = $self->iliad($entree0,$self->stemm_nom($entree),$nb_brill);
	}
    }

    elsif ($entree =~ /(APAR|EPAR)/) {

	$res = $self->iliad($entree0,$self->stemm_ppasts($entree),$nb_brill);
    }

    # Tester les terminaisons potentielles des participes passés

    elsif ($entree =~ /(ADJ1PAR|VPAR|ADJ2PAR)/)  {

	if ($entree =~ /(.*[^\-].?)(-t)?-(je|tu|ils?|elles?|nous|vous|on)\//) {

	    $entree =~ s/(-t)?-(je|tu|ils?|elles?|nous|vous|on)\//\//;
	    $entree =~ s/(.*)\/(.*)/$1\/VCJ/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    $res = $self->iliad($entree0,$self->stemm_verbe($entree),$nb_brill);
	}

	elsif (($entree =~ /^(ha|ou)ï(e|es|s)?\//) ||
	       ($entree =~ /^mort(e|es|s)?\//) ||
	       ($entree =~ /(sous|soutes?)\//) ||
	       ($entree =~ /(clos|[^a]is|clus)(e|es)?\//) ||
	       ($entree =~ /(é|[^oa]i|[^aq]u|û|[vf]ert|[aeo]int|(f|tr)ait|(d|cr|f|fr|c|cu|du|lu|nu|ru)it)(e|es|s)?\//)) {
	    $res = $self->iliad($entree0,$self->stemm_ppasts($entree),$nb_brill);
	}
	else {
	    $entree =~ s/(.*)\/(.*)/$1\/ADJ/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    
	    $res = $self->iliad($entree0,$self->stemm_adjectif($entree),$nb_brill);
	}
    }

    # Tester les terminaisons potentielles des verbes a l'infinitif

    elsif ($entree =~ /VNCFF/)  {

	if ($entree =~ /(.*[^\-].?)(-t)?-(je|tu|ils?|elles?|nous|vous|on)\//) {

	    $entree =~ s/(-t)?-(je|tu|ils?|elles?|nous|vous|on)\//\//;
	    $entree =~ s/(.*)\/(.*)/$1\/VCJ/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    $res = $self->iliad($entree0,$self->stemm_verbe($entree),$nb_brill);
	}

	elsif (($entree =~ /cl[ou]re\//) ||
	       ($entree =~ /[ïe]r\//) ||
	       ($entree =~ /[^aeiy]ir\//) ||
	       ($entree =~ /[^aefghjklmnoqsuwxyz]re\//) ) {
	    $res = $self->iliad($entree0,$entree,$nb_brill);
	}
	else {
	    $entree =~ s/(.*)\/(.*)/$1\/SBC/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    
	    $res = $self->iliad($entree0,$self->stemm_nom($entree),$nb_brill);
	}
    }

    elsif ($entree =~ /(ACJ|ECJ)/) {
	$res = $self->iliad($entree0,$self->stemm_verbe($entree),$nb_brill);
    }

    # Tester les terminaisons potentielles des verbes
    elsif ($entree =~ /VCJ/) {

	$entree =~ s/(-t)?-(je|tu|ils?|elles?|nous|vous|on)\//\//;

	if (($entree =~ /^vont\//) ||
	    ($entree =~ /^(contre)?fou[st]\//) ||
	    ($entree =~ /^(ou|ha)ï[st]\//) ||
	    ($entree =~ /^meur[st]\//) ||
	    ($entree =~ /^(con)?vaincs?\//) ||
	    ($entree =~ /[rf]ont\//) ||
	    ($entree =~ /(a|ai|as|ât)\//) ||	    
	    ($entree =~ /clo[st]\//) ||
	    ($entree =~ /(e|es|is|it|ons|ez)\//) ||
	    ($entree =~ /[cm]ouds?\//) ||
	    ($entree =~ /[ébs]sou[st]\//) ||
	    ($entree =~ /[^aefgijkquwxyzo][ûu][st]\//) ||
	    # 14 septembre
	    ($entree =~ /(en|par|er|[im]eu|[sd]or|cour|[veaot]in)[st]\//) ||
	    ($entree =~ /([eao]nd|[oe]rd|rompt|sied|vêt|[bm][ae]t)s?\//) ||
	    ($entree =~ /[fvpl][ea]u[xt]\//) ||
	    ($entree =~ /(pla|na|para|pa|cro)ît\//)) {

	    if ($entree =~ /(gi|[^g]e|a|au)(a|ai|as|ât)\//) {
		$entree =~ s/(.*)\/(.*)/$1\/SBC/;
		$self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

		
		$res = $self->iliad($entree0,$self->stemm_nom($entree),$nb_brill);
	    }
	    else {
		$res = $self->iliad($entree0,$self->stemm_verbe($entree),$nb_brill);
	    }

	}
	else {
	    $entree =~ s/(.*)\/(.*)/$1\/SBC/;
	    $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");

	    
	    $res = $self->iliad($entree0,$self->stemm_nom($entree),$nb_brill);
	}
	
    }
    
    else  {
	$res = $self->iliad($entree0,$entree,$nb_brill);
    }
    


    return $res;
}		 

#######################################################

sub stemm_detrel {
    my $self=shift;

    my($a) = @_;
    
    my($lex,$b,$cat);
    
    my($res)="";
    
    $a=~ /^(.*)\/(DTN|REL|DTC)$/;
    
    $lex=$1;
    $cat = $2;
    
    $b= $self->{"lemmatizer"}->lemme_detrel($lex,$cat);

    $res = $cat." ".$lex." / ".$b;
    return $res;
}


sub stemm_pro {
    my $self = shift;
    my($a) = @_;
    
    my($lex,$etiq,$b);
    
    my($res)="";
    
    $a=~ /^(.*)\/(PRO|PRV)$/;
    
    $lex=$1;
    $etiq=$2;

    $b= $self->{"lemmatizer"}->lemme_pro($lex);

    $res = $etiq." ".$lex." / ".$b;
    return $res;
}


sub stemm_adjectif {
    my $self=shift;
    my($a) = @_;
    
    my($lex,$b);
    
    my($res) = "";
    
    $a=~ /^(.*)\/ADJ$/;
    
    $lex=$1;

    $b= $self->{"lemmatizer"}->lemme_adj($lex);

    $res = "ADJ ".$lex." / ".$b;
    return $res;
}

sub stemm_ppres {
    my $self=shift;

    my($a) = @_;
    
    my($lex,$cat,$b);
    
    my($res) = "";
    
    $a=~ /^(.*)\/(VNCNT|ANCNT|ENCNT)$/;
    
    $lex=$1;
    $cat=$2;

    $b= $self->{"lemmatizer"}->lemme_ppres($lex);

    $res = $cat." ".$lex." / ".$b;
    return $res;
}

sub stemm_ppasts {
    my $self=shift;

    my($a) = @_;
    
    my($lex,$cat,$b);

    my($res)="";

    $a=~ /^(.*)\/(ADJ1|ADJ2|APAR|EPAR|VPAR)(.*)$/;

    $lex=$1;
    $cat=$2.$3;

    $b= $self->{"lemmatizer"}->lemme_ppast($lex);

    $res = $cat." ".$lex." / ".$b;
    return $res;
}

sub stemm_nom {
    my $self=shift;

    my($a) = @_;

    my($lex,$b);

    my($res) = "";

    $a=~ /^(.*)\/SBC$/;


    $lex=$1;

    $b= $self->{"lemmatizer"}->lemme_nom($lex);
    $res = "SBC ".$lex." / ".$b;
    return $res;
}


sub stemm_verbe {
    my $self=shift;

    my($a) = @_;

    my($lex,$cat,$b);

    my($res) = "";

    $a=~ /^(.*)\/(ACJ|ECJ|VCJ)$/;

    $lex=$1;
    $cat=$2;

    $b= $self->{"lemmatizer"}->lemme_verbe($lex);

    $res = $cat." ".$lex." / ".$b;

    
    return $res;
    
}

sub iliad {
    my $self=shift;
    my($entree0,$entree,$nb_brill)= @_;

    my($etiq,$lex,$lex0,$lem,$deb,$reste, $reste0);

    my($res);



    $entree0 =~ /(.*)\/(.*):?.?.?$/;
    $lex0 = $1;
    $reste0 = $2;

    #print "$entree\n";
    if ($entree =~ /[^e]\'\/(ADV|PREP|SUB\$?)$/) {
	$entree =~ s/\'(\/)/e\1/;
    }
    
    # Par défaut le lemmatiseur produit une
    # analyse non déterministe pour "étaient 
    # (être/étayer)". Correction par rapport à
    # Brill où la catégorie est différente.

    if ($entree =~ /^ECJ étaient/) {
	$entree = "ECJ étaient / être, 3ppIMP, (3e groupe)";
    }
    
    if (($entree !~ /^ADJ /) &&
	($entree !~ /PAR /) &&
	($entree !~ /^DTN /) &&
	($entree !~ /^DTC /) &&
	($entree !~ /^REL /) &&
	($entree !~ /^PRO /) &&
	($entree !~ /^PRV /) &&
	($entree !~ /^SBC /) &&
	($entree !~ /^ACJ /) &&
	($entree !~ /^ECJ /) &&
	($entree !~ /^VCJ /) &&
	($entree !~ /NCNT /)) {
	
	$entree =~ /(.*)\/(.*):?.?.?$/;
	$lex = $1;
	# 11 aout 99
	#$lex =~ s/\'/e/;
	$res  = $lex0."/".$reste0."/".$lex;
    }
    
    # On remplace les séquences de blancs par une virgule 
    # (sauf mots composés avec "'")
    
    else {
	$entree =~ /^([^ ]*) (.*) \/ (.*)$/;
	$etiq = $1;
	$lex = $2;
	$lem=$3;
	
	# Si le mot contient des blancs, en tenir compte
	
	if (($lex =~ / /) && ($etiq =~ /VCJ/)) {
	    $lem =~ /^([^ ]*) ([^ ]*)([ ,])(.*)$/;
	    $deb = $1." ".$2;
	    $reste = $3.$4;
	    $reste =~ s/ /,/g;
	    $lem = $deb.$reste;
	}
	elsif ($lex !~ / /) {
	    
	    # on uniformise les séparateurs
	    $lem =~ s/ /,/g;
	}
	
	$lem =~ s/,,+/,/g;
	
	# On distingue les lignes contenant " ou ":
	if ($lem =~ /,ou,/) {
	    
	    $res = $self->distribue_ou($lex0,$lem,$lex,$etiq,$nb_brill);
	    
	}	
	
	# traitement de notation proprement dit
	else {
	    $lem =~ s/,/:/g;
	    $res = $self->decompose($etiq,$lem,$nb_brill);
	    $res = $lex0."/".$etiq.":".$res;

	    if ($res =~ /^(.*)XXX\/(.*)$/) {

		$res = $1."XXX/".$lex0;
	    }
	}
    }

    my @lsols = $self->distribution(($res));
    $res = join(" || ",@lsols);

    
    return $res;
}

sub distribue_ou {
    my $self=shift;
    my($lex0,$seq,$lex,$etiq,$nb_brill) = @_;

    my($forme_mot1,$groupe1,$flex1,$forme_mot2,$groupe2,$flex2);

    my($res)="";

    if ($etiq =~ /NCNT/) {
	$seq =~ /^([^,]*),(\([^\)]*\)),ou,([^,]*):(..):(\([^\)]*\)),?$/;
	$forme_mot1 = $1;
	$flex1 = $4;
	$groupe1 = $2;
	$forme_mot2 = $3;
	$flex2 = $flex1;
	$groupe2 = $5;
	
	$res = "{".$lex0."/".$etiq.":".$self->decompose($etiq,$forme_mot1.":".$flex1.":".$groupe1,$nb_brill);
	$res .= "|";
	$res .= $lex0."/".$etiq.":". $self->decompose($etiq, $forme_mot2.":".$flex2.":".$groupe2,$nb_brill)."}";
	
    }
    
    elsif ($etiq =~ /CJ/) {
	if ($seq =~ /^([^,]*),([1-3][^,\( ]*),(\([^\)]*\)),ou,([^,]*),([1-3][^,\( ]*),(\([^\)]*\)),?$/) {
	    
	    $forme_mot1 = $1;
	    $flex1 = $2;
	    $groupe1 = $3;
	    $forme_mot2 = $4;
	    $flex2 = $5;
	    $groupe2 = $6;
	}
	elsif  ($seq =~ /^([^,]*),(\([^\)]*\)),ou,([^,]*),(\([^\)]*\)),([1-3][^,]*),?$/) {
	    $forme_mot1 = $1;
	    $flex1 = $5;
	    $groupe1 = $2;
	    $forme_mot2 = $3;
	    $flex2 = $flex1;
	    $groupe2 = $4;
	}
	elsif  ($seq =~ /^([^,]*),([1-3][^, ]*),ou,([^,]*),([1-3][^,\( ]*),(\([^\)]*\)),?$/) {
	    $forme_mot1 = $1;
	    $flex1 = $2;
	    $groupe1 = $5;
	    $forme_mot2 = $3;
	    $flex2 = $4;
	    $groupe2 = $groupe1;
	}
	elsif  ($seq =~ /^([^ ]*),ou,([^,]*),([1-3][^, ]*),(\([^\)]*\)),?$/) {
	    $forme_mot1 = $1;
	    $flex1 = $3;
	    $groupe1 = $4;
	    $forme_mot2 = $2;
	    $flex2 = $flex1;
	    $groupe2 = $groupe1;
	}
	
	else {
	    #print "Notation de base incorrecte, verbe $lex\n";
	}
	
	$res = "{".$lex0."/".$etiq.":".$self->decompose($etiq,$forme_mot1.":".$flex1.":".$groupe1,$nb_brill);
	$res .= "|";
	$res .= $lex0."/".$etiq.":". $self->decompose($etiq, $forme_mot2.":".$flex2.":".$groupe2,$nb_brill)."}";
	
    }
    else {
	#Extention aux noms/adjectifs
	if  ($seq =~ /^([^,:]*):([mf_])([sp_])[:,]ou[:,]([^,:]*)[,:]([mf_])([sp_])[:,]?$/) {
	    $forme_mot1 = $1;
	    $flex1 = $2.$3;
	    $forme_mot2 = $4;
	    $flex2 = $5.$6;
	}
	elsif  ($seq =~ /^([^,:]*)[:,]ou[:,]([^,:]*):([mf_])([sp_])[:,]?$/) {
	    $forme_mot1 = $1;
	    $flex1 = $3.$4;
	    $forme_mot2 = $2;
	    $flex2 = $flex1;
	}
	
	else {
	    #print "Notation de base incorrecte, nom $lex\n";
	}
	
	$res = "{".$lex0."/".$etiq.":".$self->decompose($etiq,$forme_mot1.":".$flex1,$nb_brill);
	$res .= "|";
	$res .= $lex0."/".$etiq.":". $self->decompose($etiq,$forme_mot2.":".$flex2,$nb_brill)."}";
	
    }
    
    return $res;
}

# Affiche le mot lemmatise selon les conventions suivantes:
#
# pour les verbes conjugues (VCJ) :
# MotFlechi/Etiq:pers:nb:tps:mode/LemmeCalcule:gpe:FamilleFlex/
#
# pour les participes, les adjectifs, les noms, les determinants et 
# les pronoms relatifs (PPRES/PPAST/ADJ/SBC/DTN/REL) :
# MotFlechi/Etiq:genre:nb/LemmeCalcule:FamilleFlex/
#
# Pour les pronoms (PRO/PRV)
# MotFlechi/Etiq:pers:genre:nb:cas/LemmeCalcule:FamilleFlex/
#
# Valeurs possibles :
#
# pers : 1p,2p,3p,_
# genre : m,f,_
# nb : s,p,_
# tps : pst,impft,fut, ps
# mode : ind,subj,imp,cond,imper
# gpe : 1g,2g,3g
# FamilleFlex : _
#
# Pour chacune de ses realisations, les resultats ambigus 
# sont entre separes par '|' et places entre {}:
#
# ex1 :  {bruissant/PPRES:m:s/bruisser:1g/|bruissant/PPRES:m:s/bruire:3g/}
#
# ex2 : allions/VCJ:1p:{impft:ind|pst:subj}/aller:3g/
#

sub decompose {
    my $self=shift;
    my($etiq, $seq,$nb_brill) =@_;

    my(@tab);
    my($flex,$gd,$nb,$modele,$tps,$cas);
    my($per)="";
    my($res)="";
    my($famille_flex) =":_";

    # Valeur indéterminée par défaut pour $nb_brill

    if (($nb_brill ne "sg")&&
	($nb_brill ne "pl")) {
	$nb_brill = "_";
    }
    else {
	$nb_brill =~ s/(.).$/$1/;
    }

    @tab = split(':',$seq);

    # Calcul de la famille flexionnelle 
    # $famille_flex = $self->calcule_modele_flex($etiq, $tab[0]);

    $flex = $tab[1];

    # Les pronoms :

    if ($flex =~ /^([123_])([mf_])([sp_])([_naodMRSTU])$/) {

	$per=$1;
	$gd=$2;
	$nb=$3;

	# Raffinage de la valeur du nombre en substituant
	# à la valeur indéterminée la valeur calculée par Brill.

	
	if ($nb eq "_") {
	    $nb=$nb_brill;
	}

	$res = $per."p:".$gd.":".$nb.":";
	$cas = $4;
	if ($cas =~ /[_naod]/) {
	    $res .= $cas."/";
	}
	elsif ($cas =~ /M/) {
	    $res .= "{n|d|o}/";
	}
	elsif ($cas =~ /U/) {
	    $res .= "{a|d|o}/";
	}
	elsif ($cas =~ /R/) {
	    $res .= "{a|d}/";
	}
	elsif ($cas =~ /S/) {
	    $res .= "{a|o}/";
	}
	else {
	    # cas = T = d/o
	    $res .= "{d|o}/";
	}
    }

    # Déterminants, adjectifs, noms, participes passés

    elsif ($flex =~ /^([mf_])([sp_])$/) {
	$gd=$1;
	$nb=$2;
	
	# Raffinage de la valeur du nombre en substituant
	# à la valeur indéterminée la valeur calculée par Brill.

	
	if ($nb eq "_") {
	    $nb=$nb_brill;
	}

	$res = $gd.":".$nb."/";
    }

    elsif ($flex =~ /^([sp_])$/) {
	$nb=$1;
	# Raffinage de la valeur du nombre en substituant
	# à la valeur indéterminée la valeur calculée par Brill.

	
	if ($nb eq "_") {
	    $nb=$nb_brill;
	}
	$res = "_:".$1."/";
    }

    # Verbes conjugués :
    elsif ($flex =~ /^([1-3])\/?([1-3]?).(.)(.*)$/) {
	$res = $1;
	$per = $2;
	$nb = $3;

	# Raffinage de la valeur du nombre en substituant
	# à la valeur indéterminée la valeur calculée par Brill.

	
	if ($nb eq "_") {
	    $nb=$nb_brill;
	}

	$tps = $4;
	if ($per ne "") {
	    $res = "{".$res."|".$per."}";
	}
	$res .= "p:".$nb.":";

	if ($tps =~ /^(IMP\/PSTSUBJ|PSTSUBJ\/IMP)$/) {
	    $res .="{impft:ind|pst:subj}/";
	}
	elsif ($tps =~ /^(PSTIND\/SUBJ\/IMPER)$/) {
	    $res ="{".$res."pst:{ind|subj}|2p:s:pst:imper}/";
	}
	elsif ($tps =~ /^(PSTIND\/IMPER)$/) {
	    if ($flex =~ /ps/) {
		$res ="{".$res."pst:ind|2p:s:pst:imper}/";
	    }
	    else {
		$res .= "pst:{ind|imper}/";
	    }
	}
	elsif ($tps =~ /^(PSTSUBJ\/IMPER)$/) {
	    if ($flex =~ /ps/) {
		$res ="{".$res."pst:subj|2p:s:pst:imper}/";
	    }
	    else {
		$res .= "pst:{subj|imper}/";
	    }
	}
	elsif ($tps =~ /^(IMPER)$/) {
	    if ($flex =~ /ps/) {
		$res ="2p:s:pst:imper/";
	    }
	    else {
		$res .= "pst:imper/";
	    }
	}
	elsif ($tps =~ /^PST(_|IND\/SUBJ)?$/) {
	    $res .="pst:{ind|subj}/";
	}
	elsif ($tps =~ /^PS\/PSTIND$/) {
	    $res .="{pst|ps}:ind/";
	}
	elsif ($tps =~ /^PSTIND\/PS\/IMPER$/) {
	    $res ="{".$res."{pst|ps}:ind|2p:s:pst:imper}/";
	}
	elsif ($tps =~ /^PSTIND$/) {
	    $res .="pst:ind/";
	}
	elsif ($tps =~ /^PSTSUBJ$/) {
	    $res .="pst:subj/";
	}
	elsif ($tps =~ /^SUBJIMP$/) {
	    $res .="impft:subj/";
	}
	elsif ($tps =~ /^PS$/) {
	    $res .="ps:ind/";
	}
	elsif ($tps =~ /^IMP$/) {
	    $res .="impft:ind/";
	}
	elsif ($tps =~ /^FUT$/) {
	    $res .="fut:ind/";
	}
	elsif ($tps =~ /^COND$/) {
	    $res .="pst:cond/";
	}
	else {
	    $res .="xxx:xxx/";
	}
    }
    else {
	$res = "XXX/";

    }
    $res .= $tab[0];
    if (defined($tab[2])) {

	$modele = $tab[2];
	$modele =~ /^\(([1-3])/;
	$res .= ":".$1."g";
    }
    #$res .= $famille_flex."/";
    
    return $res;
}

sub distribution {
    my $self = shift;
    my(@lres_ambigus)=@_;
    
    my @lsols=();
    
    while (@lres_ambigus) {
	my $res_ambigu = shift(@lres_ambigus);
	
	$res_ambigu=~s/\t/ /;
	# Plus rien à faire
	if ($res_ambigu !~ /\{/) {
	    push(@lsols, $res_ambigu);
	    next;
	}
	
	# Encore des "{"
	
	my $avant="";
	my $apres="";
	
	$res_ambigu =~ /(.*)\{([^\}]*)\}(.*)/;
	$avant=$1;
	$apres=$3;
	my @lambig=split(/\|/,$2);
	foreach (@lambig) {
	    push(@lres_ambigus, $avant.$_.$apres);
	}
	
    }

    my %hash;
    foreach (@lsols) {
	#$hash{$_}++;
	$hash{$self->traduit_bl_en_multext($_)}++;
    }
    return (sort(keys(%hash)));
}	    

sub traduit_bl_en_multext {
    my $self = shift;
    my($chaine)=@_;
    
    my $traduit=$chaine;

    #print "-->$chaine<--\n";
    my ($tag,$per,$nb,$ge,$tse,$mde,$gp,$cas,$lem,$def,$aux);

    #Verbes
    if ($chaine =~/(ADJ[12]PAR|[VEA](CJ|PAR|NCNT|NCFF))/) {
	
	if ($chaine =~/(.*[AEV]CJ):([123\_])p:([sp\_]):([^:]*):([^\/]*)\/([^:]*):?([123])?g?/) {
	    $tag=$1;
	    $per=$2;
	    $nb=$3;
	    $tse=$4;
	    $mde=$5;
	    $lem=$6;
	    $gp=$7;
	    $ge="-";
	    
	    $mde =~ s/ind/i/;
	    $mde =~ s/subj/s/;
	    $mde =~ s/cond/c/;
	    $mde =~ s/imper/m/;
	    
	    $tse=~ s/pst/p/;
	    $tse=~ s/ps/s/;
	    $tse=~ s/impft/i/;
	    $tse=~ s/fut/f/;
	    
	}
	
	elsif ($chaine =~ /(.*[AEV](PAR|NCNT)):([mf\_]):([sp\_])\/([^:]*):?([123])?g?/) {
	    $tag=$1;
	    $mde="p";
	    $tse=$2;
	    $ge=$3;
	    $nb=$4;
	    $lem=$5;
	    $gp=$6;
	    $per="-";

	    if ($tse =~ /PAR/) {$tse = "s";} else {$tse = "p";}
	}

	elsif ($chaine =~ /(.*ADJ[12]PAR):([mf\_]):([sp\_])\/([^:]*):?([123])?g?/) {
	    $tag=$1;
	    $mde="p";
	    $tse="s";
	    $ge=$2;
	    $nb=$3;
	    $lem=$4;
	    $gp=$5;
	    $per="-";

	}

	elsif ($chaine =~ /(.*[VAE]NCFF)\/([^:]*):?([123])?g?/) {
	    $tag=$1;
	    $mde="n";
	    $tse="-";
	    $ge="-";
	    $nb="-";
	    $lem=$2;
	    $gp=$3;
	    $per="-";

	}
	
	if ($tag =~/(ADJ[12]PAR|V(PAR|NCNT|NCFF|CJ))/) { $aux="m";} else {$aux="a";}
	if ($gp eq "") {$gp="-";}
	$ge=~s/\_/-/;
	$per=~s/\_/-/;
	$nb=~s/\_/-/;
	    
	$traduit = $tag.":V".$aux.$mde.$tse.$per.$nb.$ge."-".$gp."\t".$lem;
	    
    }

    #Determinants
    elsif ($chaine =~ /(.*DTN):([mf\_]):([sp\_])\/([^:]*)/) {
	$tag=$1;
	$ge=$2;
	$nb=$3;
	$lem=$4;

	$ge=~s/\_/-/;
	$nb=~s/\_/-/;
	    
	$traduit = $tag.":D-3".$ge.$nb."---\t".$lem;
    }

    #Prep. agglutinées
    elsif ($chaine =~ /(.*DTC):([mf\_]):([sp\_])\/([^:]*)/) {
	$tag=$1;
	$ge=$2;
	$nb=$3;
	$lem=$4;

	$ge=~s/\_/-/;
	$nb=~s/\_/-/;
	    
	$traduit = $tag.":Sp+Da-".$ge.$nb."--d\t".$lem;
    }
   #Noms/Adj
    elsif ($chaine =~/(.*)(SBC|ADJ):([mf\_]):([sp\_])\/([^:]*)/) {
	$tag=$1.$2;
	$ge=$3;
	$nb=$4;
	$lem=$5;

	$ge=~s/\_/-/;
	$nb=~s/\_/-/;

	if ($tag =~ /ADJ/) {$traduit = $tag.":A--".$ge.$nb."--\t".$lem;}
	else {$traduit = $tag.":Nc".$ge.$nb."--\t".$lem;}
    }
   #Noms Propres
    elsif ($chaine =~/(.*SBP)\/([^:]*)/) {
	$tag=$1;
	$lem=$2;

	$traduit = $tag.":Np----\t".$lem;
    }

   #Noms/Adjs/Pronoms inconnus
    elsif ($chaine =~/(.*)(ADJ|SBC|PRO):XXX\/([^:]*)/) {
	$tag=$1;
	$mde=$2;
	$lem=$3;

	if ($mde =~ /PRO/) { $traduit = $tag.$mde.":P------\t".$lem; }
	elsif ($mde =~ /ADJ/) {$traduit = $tag.$mde.":A-----\t".$lem;}
	else {$traduit = $tag.$mde.":Nc----\t".$lem;}
    }

    #Pronoms 
    elsif ($chaine =~/(.*(PRV|PRO)):([123\_])p:([mf\_]):([sp\_]):([^\/]*)\/([^:]*)/) {
	$tag=$1;
	$mde=$2;
	$per=$3;
	$ge=$4;
	$nb=$5;
	$cas=$6;
	$lem=$7;

	$ge=~s/\_/-/;
	$per=~s/\_/-/;
	$cas=~s/\_/-/;
	$cas=~s/[ado]/j/;
	$nb=~s/\_/-/;

	if ($mde =~ /PRO/) {$mde="-";} else {$mde="p";}
	$traduit = $tag.":P".$mde.$per.$ge.$nb.$cas."-\t".$lem;
    }

    #Pronoms relatifs
    elsif ($chaine =~/(.*REL):([mf\_]):([sp\_])\/([^:]*)/) {
	$tag=$1;
	$mde="r";
	$per="-";
	$ge=$2;
	$nb=$3;
	$cas="-";
	$lem=$4;

	$ge=~s/\_/-/;
	$per=~s/\_/-/;
	$nb=~s/\_/-/;

	
	$traduit = $tag.":P".$mde.$per.$ge.$nb.$cas."-\t".$lem;
    }
    # Oublis ?
    elsif ($chaine =~/[A-Z]:/) {
	$traduit.="***";
    }
    return($traduit);
}

1;

=head1 NAME

Flemm::Brill - Lemmatisation du français à partir de corpus étiquetés

=head1 SYNOPSIS

use Flemm::Brill;

$lemm=new Flemm::Brill('Format' => 'Brill');

=head1 DESCRIPTION

Convertit un flot de type Brill au format interne, appelle le lemmatiseur et renvoie
un résultat au format Brill.

Avant d'appeler le lemmatiseur, vérifie et éventuellement corrige l'étiquetage et la
segmentation fournis par Brill (en consignant les éventuelles erreurs dans 
deux fichiers séparés).

=head1 METHODES

=over 3

=item new([Format => (simple|extended)],[Logname => logname_prefix])

La méthode new crée un objet de type Flemm::Brill, qui contient lui-même
un objet de type Flemm::Lemmatizer.

Si le paramètre Logname est fourni, les erreurs de segmentation seront consignées
dans un fichier dont le nom est constitué du préfixe fourni en paramètre et suffixé 
par .seg et les erreurs d'étiquetage seront consignées dans un fichier dont 
le nom est constitué du préfixe fourni en paramètre et suffixé par .etiq.

Le paramètre Format influe sur la forme du résultat qui sera délivré par la 
méthode Lemmatize.

=item lemmatize($tagger_input_line)

Le méthode lemmatize prend un résultat de Brill et délivre en sortie sa forme
lemmatisée et munie des traits morpho-flexionnels au format Multext et accompagnée 
de l'étiquette catégorielle d'origine. Le résultat renvoyé est un objet de la classe
Flemm::Result.


=back

=cut

=head1 SEE ALSO

Flemm::Result


=cut

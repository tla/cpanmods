#
###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de #
# corpus étiquetés - Version 3.1                                          #
# Copyright (C) 2004 (NAMER Fiammetta)                                    #
###########################################################################
#
# Module qui convertit l'entrée en format interne,
# appelle le lemmatiseur et
# convertit le résultat en format de TreeTagger
#
#
#
# $Id$
#

package Flemm::TreeTagger;

use strict;
use warnings;
no warnings 'uninitialized';
use utf8;

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
        my $enc = $params{Encoding};

        $self->{log}=1;

        $self->{etiq}=new IO::File ">$logname.etiq";
        die "Impossible de créer $logname.etiq\n" if (!defined $self->{etiq});
        binmode( $self->{etiq}, ":encoding($enc)" );

        $self->{seg}=new IO::File ">$logname.seg";
        die "Impossible de créer $logname.seg\n" if (!defined $self->{seg});
        binmode( $self->{seg}, ":encoding($enc)" );
    }
    else {
        $self->{log}=0;
    }

    # Les objets de la classe Flemm::TreeTagger contiennent un objet
    # de la classe Flemm::Lemmatizer. C'est precisément celui-là que 
    # l'on crée à l'instruction suivante.

    $self->{lemmatizer}=new Flemm::Lemmatizer();
    
    return $self;
}

sub lemmatize {
    my $self=shift;
    my ($entree)=@_;
    my $res="";

    $entree =~ /^(.*)\t(.*)\t(.*)$/;

    my $aa = $1."/".$2;
    my $catTT=$2;       
    my $val=$3;

    # 14/11/02 : On ajoute un paramètre qui mémorise la valeur initiale du lemme trouvé par TT
    # (pour tester si sa valeur est <unknown>)
    
    $res = $self->identifie($aa,$val);
    $res =~s/\//\t/g;
    
    # 14/11/02 On rétablit les "/" d'origine dans ff et lemme
    $res =~s/µ/\//g;
    
    # 23/10/03 On reporte la catégorie d'origine attribuée par 
    #TreeTagger, en dernière position (pour la BD)

    
    my $resobj=new Flemm::Result;

    $resobj->setResult($res);
    $resobj->setMultext($res);
    $resobj->setOriginalTag($catTT);

    return $resobj;
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
    # 14/11/02 : Grâce à $val, on sait si le TT avait calculé <unknown> comme lemme
    my($entree0, $val) = @_;
    
    my($entree,$lex,$tag1,$tag, $lex_en_maj);
    
    my($res)="";

    # Séquence entrée:
    $entree0 =~ /(.*)\/(.*)/;

    $lex=$1;
    $tag1=$2;

    # 14/11/02 : pendant le traitement, on remplace "/" dans les ff par "µ". On rétabli en sortie (flemm.perl)
    # après avoir remplacé les "/" du calcul de lemme par TAB.
    $lex =~s/\//µ/g;
    $lex_en_maj=$lex;
    $entree0= $lex."/".$tag1;

    #print "$entree0 --> $tag1\n" if $debug0;

    # Transformation du mot en minuscules:
    $lex = lc( $lex );
    
    # Suppression des signes de ponctuations 
    # en fin de mot,
    # 13 novembre 2002 : Suppression limitée aux pos fléchies
    
    if (($lex =~ /^([^\.\?!]+)(\.|!|\*|\?|\(|,|\[|\”|\“|\-)+$/) && 
        ($tag1 =~ /(ADJ|DET|NOM|PRO|VER)/)) {
        #($tag1 !~ /ABR/) &&
        #($tag1 ne "NPR")) 
        
        $lex =~ /^([^\.\?!]+)(\.|!|\*|\?|\(|,|\[|\”|\“|\-)+$/;
        $lex = $1;
        $self->log('seg',"$lex_en_maj  est réduit à $lex ($tag1) \n");
    }
    
    # et des virgules, parenthèses, tirets au début
    if ($lex =~ /^[\*\),\?\-:;\”\“]+([^\*,\?\):;\”\“]+)$/) {
        
        $lex = $1;
        #print "Voici $lex\n";
        $self->log('seg',"$lex_en_maj  est réduit à $lex ($tag1) \n");
    }
    
    # Séquence traitée :
    $entree = $lex."/".$tag1;
    
    #13/11/02 : Treetagger a corrigé cette erreur d'équitage
    #if ($entree =~ /(PRO:POS|ABR)$/) { 
    
    if ($entree =~ /(-t)-(je|tu|ils?|elles?|nous|vous|on)\//) {
        $entree = $2;
        $self->log('etiq',"$lex_en_maj / $tag1 ==>  $entree\n");
        $res = $self->iliad($entree0,$self->stemm_pro($entree));
    }

    #############################################################################################

    # 14/11/02 Concerne INT

    elsif (($entree =~ /\/INT/)&&($val =~/<unknown>/))  {

        # Si la forme commence par une majuscule --> nom propre
        if ($lex_en_maj=~/^[A-Z]/) {
            $entree =~ s/(.*)\/(.*)/$1\/NAM/;
            $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n" );
            $res = $self->iliad($entree0,$entree);
        }

        # Si la forme se termine par é, ée, ées, és --> participe passé
        elsif ($entree =~/ée?s?\//) {
            $entree =~ s/(.*)\/(.*)/$1\/VER:pper/;
            $self->log('etiq',"$lex_en_maj / $tag1 ==>  $entree\n");
            $res = $self->iliad($entree0,$self->stemm_ppasts($entree));
        }

        # Sinon --> nom commun
        else {
            $entree =~ s/(.*)\/(.*)/$1\/NOM/;
            $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");
            $res = $self->iliad($entree0,$self->stemm_nom($entree));
        }
    }

    #############################################################################################
    # VERBE SUBJONCTIFS

    # 14/11/02 Concerne VER(:aux):subi (traitement temporaire)

    # Si la valeur est 'unknown', on le traite comme un nom commun
    elsif (($entree =~ /\/VER(:aux)?:subi/)&&($val =~/<unknown>/))  {
        $entree =~ s/(.*)\/(.*)/$1\/NOM/;
        $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");
        $res = $self->iliad($entree0,$self->stemm_nom($entree));
    }

    # Sinon, on ne touche à rien : on fait analyser par le lemmatiseur

    elsif ($entree =~ /\/VER(:aux)?:subi/)  {

        $res = $self->iliad($entree0,$self->stemm_verbe($entree));
    }
    
    
    #############################################################################################
    # PRONOMS

    elsif ($entree =~ /PRO:?(POS|DEM|IND|PER)?/) {

        # Quelle que soit la spécif de PRO, si on reconnait un pronom personnel "irrégulier"
        # On appelle la fonction
        if (($self->{"lemmatizer"}->est_un_pronom_personnel($lex)) ||
            ($self->{"lemmatizer"}->est_un_pronom_meme($lex)) ||
            ($self->{"lemmatizer"}->est_un_pronom_invariable($lex))  ) {
            
            $res = $self->iliad($entree0,$self->stemm_pro($entree));
        }

        # PRO:POS désigne normalement un pronom possessif
        elsif (($tag1 =~ /PRO:POS/) && ($lex =~ /^(mien|tien|sien|nôtre|vôtre|leur)/)) {
            $res = $self->iliad($entree0,$self->stemm_pro($entree));
        }
        # PRO:IND désigne normalement un pronom indéfini
        elsif (($tag1 =~ /PRO:IND/) && ($lex =~ /^(chaque|quelque)/)) {
            $entree =~ s/(.*)\/(.*)/$1\/ADJ/;
            $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");
            #print "APRES : $entree\n";
            $res = $self->iliad($entree0,$self->stemm_adjectif($entree));
        }

        #13/11/02 : Une quantité de PRO:POS sont des noms propres en majuscule
        elsif (($lex_en_maj=~/^([A-Z]+)$/) && ($tag1=~/PRO:POS/)) {
            #print "AVANT : $entree\n";
            $entree =~ s/(.*)\/(.*)/$1\/NAM/;
            $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");
            #print "APRES : $entree\n";
            $res = $self->iliad($entree0,$entree);
        }

        # Mais PRO:POS est généralement un nom étranger, ou nom propre, ou ....
        # Par défaut : NOM
        elsif ($tag1 =~ /PRO:POS/) {
            $entree =~ s/(.*)\/(.*)/$1\/NOM/;
            $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");
            $res = $self->iliad($entree0,$self->stemm_nom($entree));
        }

        # Pronom personnel non spécifié
        elsif (($tag1 =~ /PRO$/) &&
               ($lex !~ /^(qui|que|quoi)$/)) {
            $entree =~ s/(.*)\/(.*)/$1\/NOM/;
            $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");
            $res = $self->iliad($entree0,$self->stemm_nom($entree));
        } 

        elsif ($tag1 =~ /PRO$/) {
            $res = $self->iliad($entree0,$self->stemm_pro($entree));
        }

        # Pronom personnel sujet
        elsif (($tag1 =~ /PRO:PER/) &&
               ($lex =~ /^[jtsclm][e\']$/)) {
            $res = $self->iliad($entree0,$self->stemm_pro($entree));
        } 
        
        elsif (($tag1 =~ /PRO:PER/) &&
               ($lex =~ /^(l\'\_on$|-t-|-ce|-il)/)) {
            
            $entree =~s/l\'\_on/on/;
            $entree =~s/\-t\-//;
            $entree =~s/\-(ce|il)/$1/;
            #print "-t-PRO:-->$entree<--\n";
            $res = $self->iliad($entree0,$self->stemm_pro($entree)); 
        } 
        
        
        # Concerne PRO (est-ce encore pertinent?)
        elsif ($lex =~ /(ae|ashe|[0-9]|ante?|aire|[oiïay]que|[ai]ble|iche)s?$/) {
            $entree =~ s/(.*)\/(.*)/$1\/ADJ/;
            $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");   
            $res = $self->iliad($entree0,$self->stemm_adjectif($entree));
        }

        # Concerne PRO
        elsif (($lex =~ /(ose|ate)s?$/)&&($lex !~ /quelque_chose/)) {
            $entree =~ s/(.*)\/(.*)/$1\/NOM/;
            $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");
            $res = $self->iliad($entree0,$self->stemm_nom($entree));
        } 

        elsif ($entree =~ /(-t)?-(je|tu|ils?|elles?|nous|vous|on)(\/.*)/) {     
            
            $entree = $2.$3;
            
            $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");
            $res = $self->iliad($entree0,$self->stemm_pro($entree));
        }
        # Concerne PRO
        else {
            $res = $self->iliad($entree0,$self->stemm_pro($entree));
        } 
    }

    #############################################################################################
    # DETERMINANTS

    elsif ($entree =~ /(DET|PRO:REL|PRP:det)/) {

        #On examine les déterminants
        if (($self->{"lemmatizer"}->est_un_determinant_ou_une_relative_invariable($lex)) ||
            ($lex =~ /(quel|^une?$|^des$|^les?$|^la$|^[ld]\'$|^aux?$|^du$|^ce|^[mts](ien(ne)?s?|on|a|es)$|^[nv](os|otre)$|^leurs?|^tel|^nul|^tou|^certain|^aucun)/)) { 
            $res = $self->iliad($entree0,$self->stemm_detrel($entree)); 
        } elsif ($lex =~ /_de$/) { 
            $entree =~ s/(.*)\/(.*)/$1\/PRP/; 
            $entree0 =~ s/(.*)\/(.*)/$1\/PRP/; 
            $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n"); 
            $res = $self->iliad($entree0,$entree); 
        }

        # Sur S&A, les DET mal codés sont en fait des noms propres ou étrangers (en majorité : il ya
        # aussi des noms et adjectifs)
        else { 
            $entree =~ s/(.*)\/(.*)/$1\/NAM/; 
            $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n"); 
            $res = $self->iliad($entree0,$entree); 
        } 
    } 

    #############################################################################################
    # PARTICIPES PRESENTS
    
    # Vérification des participes présent

    elsif ($entree =~ /VER(:aux)?:ppre/) { 

        if ($entree =~ /ant\//) { 
            $res = $self->iliad($entree0,$self->stemm_ppres($entree));  
        } else { 
            $entree =~ s/(.*)\/(.*)/$1\/ADJ/; 
            $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n"); 
            $res = $self->iliad($entree0,$self->stemm_adjectif($entree)); 
        } 
    } 
    
    #############################################################################################
    # NOMS
    elsif ($entree =~ /NOM/) { 
        $res = $self->iliad($entree0,$self->stemm_nom($entree)); 
    } 

    #############################################################################################
    # PARTICIPES PASSES

    elsif ($entree =~ /VER:aux:pper/) { 

        $res = $self->iliad($entree0,$self->stemm_ppasts($entree)); 
    } 

    #############################################################################################
    
    # Tester les terminaisons potentielles des participes passés 
    elsif ($entree =~ /VER:pper/) { 

        if (($entree =~ /^(ha|ou)ï(e|es|s)?\//) || 
            ($entree =~ /^mort(e|es|s)?\//) || 
            ($entree =~ /(sous|soutes?)\//) || 
            ($entree =~ /(clos|[^a]is|clus)(e|es)?\//) || 
            ($entree =~ /(é|[^oa]i|[^aq]u|û|[vf]ert|[aeo]int|(f|tr)ait|(d|cr|f|fr|c|cu|du|lu|nu|ru)it)(e|es|s)?\//)) { 
            $res = $self->iliad($entree0,$self->stemm_ppasts($entree)); 
        } else { 
            $entree =~ s/(.*)\/(.*)/$1\/ADJ/; 
            $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n"); 
            $res = $self->iliad($entree0,$self->stemm_adjectif($entree)); 
        } 
    } 

    #############################################################################################

    # Tester les terminaisons potentielles des verbes a l'infinitif 

    elsif ($entree =~ /VER(:aux)?:infi/) {

        if (($entree =~ /cl[ou]re\//) ||
            ($entree =~ /[ïe]r\//) ||
            ($entree =~ /[^aeiy]ir\//) ||
            ($entree =~ /[^aefghjklmnoqsuwxyz]re\//) ) {
            $res = $self->iliad($entree0,$entree);
        } else {
            $entree =~ s/(.*)\/(.*)/$1\/NOM/;
            $self->log('etiq', "$lex_en_maj / $tag1 ==>  $entree\n");
            $res = $self->iliad($entree0,$self->stemm_nom($entree));
        }
    }

    #############################################################################################
    # VERBES
    elsif ($entree =~ /VER:aux/) {
        $res = $self->iliad($entree0,$self->stemm_verbe($entree));
    }
    
    #############################################################################################
    
    # Tester les terminaisons potentielles des verbes conjugués
    
    elsif ($entree =~ /VER/) {
        
        if (($entree =~ /^(est|s?ont|vont|fut|eut)\//) ||
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
            ($entree =~ /[^aegijkquwxyzo][ûu][st]\//) ||
            # 14 septembre
            ($entree =~ /(en|par|er|[im]eu|[sd]or|cour|[veaot]in)[st]\//) ||
            ($entree =~ /([eao]nd|[oe]rd|rompt|sied|vêt|[bm][ae]t)s?\//) ||
            ($entree =~ /[fvpl][ea]u[xt]\//) ||
            ($entree =~ /(pla|na|para|pa|cro)ît\//)) {
            
            if ($entree =~ /(gi|ou|[^g]e|a|au)(a|ai|as|ât)\//) {
                $entree =~ s/(.*)\/(.*)/$1\/NOM/;
                $self->log('etiq',"$lex_en_maj / $tag1 ==>  $entree\n");
                
                
                $res = $self->iliad($entree0,$self->stemm_nom($entree));
            } else {
                $res = $self->iliad($entree0,$self->stemm_verbe($entree));
            }
            
        }

        
        else {
            $entree =~ s/(.*)\/(.*)/$1\/NOM/;
            $self->log('etiq',"$lex_en_maj / $tag1 ==>  $entree\n");
            $res = $self->iliad($entree0,$self->stemm_nom($entree));
        }
        
    }
    #############################################################################################
    # ADJECTIFS

    elsif ($entree =~ /ADJ/) {
        $res = $self->iliad($entree0,$self->stemm_adjectif($entree));
    }
    
    #############################################################################################
    
    else {
        $res = $self->iliad($entree0,$entree);
    }
    
    return $res;
}        

#
# Méthodes privées
#

sub stemm_detrel {
    my $self=shift;
    my($a) = @_;
    my($lex,$b,$cat);
    my($res)="";

    $a=~ /^(.*)\/(DET:.*|PRO:REL|PRP:det)$/;
    $lex=$1;
    $cat = $2;
    $b= $self->{"lemmatizer"}->lemme_detrel($lex,$cat);
    $res = $cat." ".$lex." / ".$b;

    #print "RES DE DET = $res\n";
    return $res;
}

sub stemm_pro {
    my $self = shift;
    my($a) = @_;
    my($lex,$etiq,$b);
    my($res)="";
    $a=~ /^(.*)\/(PRO.*)/;
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

    #print "ADJ : $a\n";
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
    $a=~ /^(.*)\/(VER(:aux)?:ppre)$/;
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
    $a=~ /^(.*)\/(VER(:aux)?:pper)$/;
    $lex=$1;
    $cat=$2;
    $b= $self->{"lemmatizer"}->lemme_ppast($lex);
    # 14/10/03 : pour distinguer verbes et participes ambigus (atteint, dit, ...), on renomme la cat
    # $cat =~ s/VER/VPP/;
    $res = $cat." ".$lex." / ".$b;
    return $res;
}

sub stemm_nom {
    my $self=shift;
    my($a) = @_;
    my($lex,$b);
    my($res) = "";
    $a=~ /^(.*)\/NOM$/;
    $lex=$1;
    $b= $self->{"lemmatizer"}->lemme_nom($lex);
    $res = "NOM ".$lex." / ".$b;
    return $res;
}


sub stemm_verbe {
    my $self=shift;
    my($a) = @_;
    my($lex,$cat,$b);
    my($res) = "";
    $a=~ /^(.*)\/(VER(:aux)?:(subp|simp|pres|impf|impe|futu|cond|subi))$/;
    $lex=$1;
    $cat=$2;
    $b= $self->{"lemmatizer"}->lemme_verbe($lex);
    $res = $cat." ".$lex." / ".$b;      
    return $res;
}

sub iliad {
    my $self=shift;
    my($entree0,$entree)= @_;
    my($etiq,$lex,$lex0,$lem,$deb,$reste, $reste0);
    my($res);
    $entree0 =~ /(.*)\/(.*)$/;
    $lex0 = $1;
    $reste0 = $2;
    if ($entree =~ /.*[^e]\'\/(ADV|PRP|KON)/) {
        $entree =~ s/\'/e/;
    }
    
    # Par défaut le lemmatiseur produit une
    # analyse non déterministe pour "étaient 
    # (être/étayer)". Correction par rapport à
    # Brill où la catégorie est différente.

    if ($entree =~ /^VER\(aux:impf\) étaient/) {
        $entree = "VER:aux:impf étaient / être, 3ppIMP, (3e groupe)";
    }

    #print "ENTREE = $entree\n";
    #print "ILIAD : $entree\n";
    if (($entree !~ /^ADJ /) &&
        ($entree !~ /:pper /) &&
        ($entree !~ /:cond /) &&
        ($entree !~ /:pres /) &&
        ($entree !~ /:futu /) &&
        ($entree !~ /:impf /) &&
        ($entree !~ /:impe /) &&
        ($entree !~ /:simp /) &&
        ($entree !~ /:subp /) &&
        ($entree !~ /:subi /) &&
        ($entree !~ /^DET/) &&
        ($entree !~ /^PRP:det/) &&
        ($entree !~ /^PRO/) &&
        ($entree !~ /^NOM /) &&
        ($entree !~ /:ppre /)) {
        
        #print "On ne calcule pas le lemme : $entree\n";
        $entree =~ /(.*)\/(.*)$/;
        $lex = $1;
        if ($entree =~ /NAM/) {
            # 14 novembre : On force la pos à être celle qui a éventuellement été 
            # reformulée par les fonctions précédentes

            #$res = $lex0."/".$reste0."/".$lex0;
            $res = $lex0."/NAM/".$lex0;
        } else {
            $reste0 =~ s/([A-Z][A-Z][A-Z])(:)(.*)$/$1($3)/;
            $res  = $lex0."/".$reste0."/".$lex;
        }
    }
    
    # On remplace les séquences de blancs par une virgule 
    # (sauf mots composés avec "'")
    
    else {
        $entree =~ /^([^ ]*) (.*) \/ (.*)$/;
        $etiq = $1;
        $lex = $2;
        $lem=$3;
        
        # Si le mot contient des blanc, en tenir compte
        
        if (($lex =~ / /) && ($etiq =~ /VER/)) {
            $lem =~ /^([^ ]*) ([^ ]*)([ ,])(.*)$/;
            $deb = $1." ".$2;
            $reste = $3.$4;
            $reste =~ s/ /,/g;
            $lem = $deb.$reste;
        } elsif ($lex !~ / /) {
            
            # on uniformise les séparateurs
            $lem =~ s/ /,/g;
        }
        
        $lem =~ s/,,+/,/g;
        
        # Reformatage de l'étiquette
        
        if ($etiq =~ /^([A-Z][A-Z][A-Z]):([^ ]*)$/) {
            $etiq = $1."(".$2.")";
        }

        # On distingue les lignes contenant " ou ":
        if ($lem =~ /,ou,/) {
            
            $res = $self->distribue_ou($lex0,$lem,$lex,$etiq);
        }       
        
        # traitement de notation proprement dit
        else {
            $lem =~ s/,/:/g;
            #if ($etiq =~ /(DET|rela|inter|det)/) {print "\n ETIQ = $etiq\nLEM = $lem\n";}
            $res = $self->decompose($etiq,$lem);
            # # Reformatage de l'étiquette

#           if ($etiq =~ /^([A-Z][A-Z][A-Z]):([^ ]*)$/) {
#               $etiq = $1."(".$2.")";
#           }
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
    my($lex0,$seq,$lex,$etiq) = @_;
    my($forme_mot1,$groupe1,$flex1,$forme_mot2,$groupe2,$flex2);
    my($res)="";
    if ($etiq =~ /ppre/) {
        $seq =~ /^([^,]*),(\([^\)]*\)),ou,([^,]*):(..):(\([^\)]*\)),?$/;
        $forme_mot1 = $1;
        $flex1 = $4;
        $groupe1 = $2;
        $forme_mot2 = $3;
        $flex2 = $flex1;
        $groupe2 = $5;
        
        $res = "{".$lex0."/".$etiq.":".$self->decompose($etiq,$forme_mot1.":".$flex1.":".$groupe1);
        $res .= "|";
        $res .= $lex0."/".$etiq.":". $self->decompose($etiq, $forme_mot2.":".$flex2.":".$groupe2)."}";  
    } elsif ($etiq =~ /VER([:\(]aux)?[:\(](cond|futu|impf|impe|pres|simp|sub[ip])/) {
        if ($seq =~ /^([^,]*),([1-3][^,\( ]*),(\([^\)]*\)),ou,([^,]*),([1-3][^,\( ]*),(\([^\)]*\)),?$/) {
            
            $forme_mot1 = $1;
            $flex1 = $2;
            $groupe1 = $3;
            $forme_mot2 = $4;
            $flex2 = $5;
            $groupe2 = $6;
        } elsif ($seq =~ /^([^,]*),(\([^\)]*\)),ou,([^,]*),(\([^\)]*\)),([1-3][^,]*),?$/) {
            $forme_mot1 = $1;
            $flex1 = $5;
            $groupe1 = $2;
            $forme_mot2 = $3;
            $flex2 = $flex1;
            $groupe2 = $4;
        } elsif ($seq =~ /^([^,]*),([1-3][^, ]*),ou,([^,]*),([1-3][^,\( ]*),(\([^\)]*\)),?$/) {
            $forme_mot1 = $1;
            $flex1 = $2;
            $groupe1 = $5;
            $forme_mot2 = $3;
            $flex2 = $4;
            $groupe2 = $groupe1;
        } elsif ($seq =~ /^([^ ]*),ou,([^,]*),([1-3][^, ]*),(\([^\)]*\)),?$/) {
            $forme_mot1 = $1;
            $flex1 = $3;
            $groupe1 = $4;
            $forme_mot2 = $2;
            $flex2 = $flex1;
            $groupe2 = $groupe1;
        } else {
            #print "Notation de base incorrecte, verbe $lex\n";
        }
        
        $res = "{".$lex0."/".$etiq.":".$self->decompose($etiq,$forme_mot1.":".$flex1.":".$groupe1);
        $res .= "|";
        $res .= $lex0."/".$etiq.":". $self->decompose($etiq, $forme_mot2.":".$flex2.":".$groupe2)."}";
        
    } else {
        #Extention aux noms/adjectifs
        if ($seq =~ /^([^,:]*):([mf_])([sp_])[:,]ou[:,]([^,:]*)[,:]([mf_])([sp_])[:,]?$/) {
            $forme_mot1 = $1;
            $flex1 = $2.$3;
            $forme_mot2 = $4;
            $flex2 = $5.$6;
        } elsif ($seq =~ /^([^,:]*)[:,]ou[:,]([^,:]*):([mf_])([sp_])[:,]?$/) {
            $forme_mot1 = $1;
            $flex1 = $3.$4;
            $forme_mot2 = $2;
            $flex2 = $flex1;
        } else {
            #print "Notation de base incorrecte, nom $lex\n";
        }
        
        $res = "{".$lex0."/".$etiq.":".$self->decompose($etiq,$forme_mot1.":".$flex1);
        $res .= "|";
        $res .= $lex0."/".$etiq.":". $self->decompose($etiq,$forme_mot2.":".$flex2)."}";
        
    }
    
    return $res;
}

# Affiche le mot lemmatise selon les conventions suivantes:
#
# pour les verbes conjugues (VER(:auxX)?:(cond|futu|impf|pres|simp|sub[ip])) :
# MotFlechi/Etiq:pers:nb:tps:mode/LemmeCalcule:gpe:FamilleFlex/
#
# pour les participes passés, les adjectifs, les noms, les determinants et 
# les pronoms relatifs (pper, ADJ, NOM, DET, PRE:det et PRE:rela) :
# MotFlechi/Etiq:genre:nb/LemmeCalcule:FamilleFlex/
#
# pour les participes présents(ppre) :
# MotFlechi/Etiq:_:_/LemmeCalcule:FamilleFlex/

# Pour les pronoms (PRO:(poss|pers|indef|demo|clit))
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
# sont entre separes par '|' et places entre {}. La catégorie de TreeTagger
# est restituée avec l'intégralité de ses informations; celles-ci sont 
# reformatées (mises entre parenthèses) pour éviter de les confondre avec 
# les traits qui suivent:
#
# ex1 :  {bruissant/VER(ppre):_:_/bruisser:1g/|bruissant/PPRES:_:_/bruire:3g/}
#
# ex2 : allions/VER(impf):1p:{impft:ind|pst:subj}/aller:3g/
#

sub decompose {
    my $self=shift;
    my($etiq, $seq) =@_;

    my(@tab);
    my($flex,$gd,$nb,$modele,$tps,$cas);
    my($per)="";
    my($res)="";
    my($famille_flex) =":_";


    @tab = split(':',$seq);

    # Calcul de la famille flexionnelle 
    # $famille_flex = $self->calcule_modele_flex($etiq, $tab[0]);

    $flex = $tab[1];

    # Les pronoms :

    if ($flex =~ /^([123_])([mf_])([sp_])([_naodMRSTU])$/) {

        $per=$1;
        $gd=$2;
        $nb=$3;

        $res = $per."p:".$gd.":".$nb.":";
        $cas = $4;
        if ($cas =~ /[_naod]/) {
            $res .= $cas."/";
        } elsif ($cas =~ /M/) {
            $res .= "{n|d|o}/";
        } elsif ($cas =~ /U/) {
            $res .= "{a|d|o}/";
        } elsif ($cas =~ /R/) {
            $res .= "{a|d}/";
        } elsif ($cas =~ /S/) {
            $res .= "{a|o}/";
        } else {
            # cas = T = d/o
            $res .= "{d|o}/";
        }
    }

    # Déterminants, adjectifs, noms, participes passés

    elsif ($flex =~ /^([mf_])([sp_])$/) {
        $gd=$1;
        $nb=$2;
        
        $res = $gd.":".$nb."/";
    } elsif ($flex =~ /^([sp_])$/) {
        $nb=$1;
        $res = "_:".$1."/";
    }

    # Verbes conjugués :
    elsif ($flex =~ /^([1-3])\/?([1-3]?).(.)(.*)$/) {
        $res = $1;
        $per = $2;
        $nb = $3;

        $tps = $4;
        if ($per ne "") {
            $res = "{".$res."|".$per."}";
        }
        $res .= "p:".$nb.":";

        if ($tps =~ /^(IMP\/PSTSUBJ|PSTSUBJ\/IMP)$/) {
            $res .="{impft:ind|pst:subj}/";
        } elsif ($tps =~ /^(PSTIND\/SUBJ\/IMPER)$/) {
            $res ="{".$res."pst:{ind|subj}|2p:s:pst:imper}/";
        } elsif ($tps =~ /^(PSTIND\/IMPER)$/) {
            if ($flex =~ /ps/) {
                $res ="{".$res."pst:ind|2p:s:pst:imper}/";
            } else {
                $res .= "pst:{ind|imper}/";
            }
        } elsif ($tps =~ /^(PSTSUBJ\/IMPER)$/) {
            if ($flex =~ /ps/) {
                $res ="{".$res."pst:subj|2p:s:pst:imper}/";
            } else {
                $res .= "pst:{subj|imper}/";
            }
        } elsif ($tps =~ /^(IMPER)$/) {
            if ($flex =~ /ps/) {
                $res ="2p:s:pst:imper/";
            } else {
                $res .= "pst:imper/";
            }
        } elsif ($tps =~ /^PST(_|IND\/SUBJ)?$/) {
            $res .="pst:{ind|subj}/";
        } elsif ($tps =~ /^PS\/PSTIND$/) {
            $res .="{pst|ps}:ind/";
        } elsif ($tps =~ /^PSTIND\/PS\/IMPER$/) {
            $res ="{".$res."{pst|ps}:ind|2p:s:pst:imper}/";
        } elsif ($tps =~ /^PSTIND$/) {
            $res .="pst:ind/";
        } elsif ($tps =~ /^PSTSUBJ$/) {
            $res .="pst:subj/";
        } elsif ($tps =~ /^SUBJIMP$/) {
            $res .="impft:subj/";
        } elsif ($tps =~ /^PS$/) {
            $res .="ps:ind/";
        } elsif ($tps =~ /^IMP$/) {
            $res .="impft:ind/";
        } elsif ($tps =~ /^FUT$/) {
            $res .="fut:ind/";
        } elsif ($tps =~ /^COND$/) {
            $res .="pst:cond/";
        } else {
            $res .="xxx:xxx/";
        }
    } else {
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
    #return $res;
}

sub distribution {
    my $self = shift;
    my(@lres_ambigus)=@_;
    
    my @lsols=();
    
    while (@lres_ambigus) {
        my $res_ambigu = shift(@lres_ambigus);
        
        #$res_ambigu=~s/\t/ /;
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
        $hash{$self->traduit_tt_en_multext($_)}++;
    }
    return (sort(keys(%hash)));
}           

sub traduit_tt_en_multext {
    my $self = shift;
    my($chaine)=@_;
    
    my $traduit=$chaine;

    #print "-->$chaine<--\n";
    my ($tag,$per,$nb,$ge,$tse,$mde,$gp,$cas,$lem,$def,$aux);

    #Verbes
    if ($chaine =~/VER/) {
        
        if ($chaine =~/(.*VER\((aux:)?[^\)]*\)):([123\_])p:([sp\_]):([^:]*):([^\/]*)\/([^:]*):?([123])?g?/) {
            $tag=$1;
            $aux=$2;
            $per=$3;
            $nb=$4;
            $ge="-";
            $tse=$5;
            $mde=$6;
            $lem=$7;
            $gp=$8;
            
            $mde =~ s/ind/i/;
            $mde =~ s/subj/s/;
            $mde =~ s/cond/c/;
            $mde =~ s/imper/m/;
            
            $tse=~ s/pst/p/;
            $tse=~ s/ps/s/;
            $tse=~ s/impft/i/;
            $tse=~ s/fut/f/;
            
            
        }
        elsif ($chaine =~/(.*VER\((aux:)?pper\)):([mf\_]):([sp\_])\/([^:]*):?([123])?g?/) {
            $tag=$1;
            $aux=$2;
            $ge=$3;
            $nb=$4;
            $lem=$5;
            $gp=$6;
            $tse="s";
            $mde="p";
            $per="-";
        }
        elsif ($chaine =~/(.*VER\((aux:)?ppre\)):([mf\_]):([sp\_])\/([^:]*):?([123])?g?/) {
            $tag=$1;
            $aux=$2;
            $ge=$3;
            $nb=$4;
            $lem=$5;
            $gp=$6;
            $tse="p";
            $mde="p";
            $per="-";
        }
        elsif ($chaine =~/(.*VER\((aux:)?infi\))\/([^:]*):?([123])?g?/) {
            $tag=$1;
            $aux=$2;
            $ge="-";
            $nb="-";
            $lem=$3;
            $gp=$4;
            $tse="-";
            $mde="n";
            $per="-";
        }

        $ge=~s/\_/-/;
        $nb=~s/\_/-/;
        $per=~s/\_/-/;
        if ($gp eq "") {$gp="-";}

        if ($aux =~ /aux/) {$aux="a";}
        else {$aux="m";}


        $traduit = $tag.":V".$aux.$mde.$tse.$per.$nb.$ge."-".$gp."\t".$lem;
    }

    #Determinants
    elsif ($chaine =~/(.*DET\((ART|POS|DEM|INT)\)):([mf\_]):([sp\_])\/([^:]*)/) {
        $tag=$1;
        $mde=$2;
        $per="-";
        $ge=$3;
        $nb=$4;
        $lem=$5;
        $def="-";
        
        $mde =~ s/ART/a/;
        $mde =~ s/POS/s/;
        $mde =~ s/DEM/d/;
        $mde =~ s/INT/t/;

        $ge=~s/\_/-/;
        $nb=~s/\_/-/;

        if ($mde =~ /[sd]/) {$def="d";}
        
        $traduit = $tag.":D".$mde."3".$ge.$nb."--".$def."\t".$lem;
        }

   #Prep. agglutinées
    elsif ($chaine =~/(.*PRP\(det\)):([mf\_]):([sp\_])\/([^:]*)/) {
        $tag=$1;
        $per="-";
        $ge=$2;
        $nb=$3;
        $lem=$4;
        $def="d";

        $ge=~s/\_/-/;
        $nb=~s/\_/-/;

        $traduit = $tag.":Sp+Da-".$ge.$nb."--".$def."\t".$lem;
    }

   #Noms/Adj
    elsif ($chaine =~/(.*)(NOM|ADJ):([mf\_]):([sp\_])\/([^:]*)/) {
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
    elsif ($chaine =~/(.*NAM)\/([^:]*)/) {
        $tag=$1;
        $lem=$2;

        $traduit = $tag.":Np----\t".$lem;
    }

    #Noms A traits inconnus (XXX)
    elsif ($chaine =~/(.*)(NOM|ADJ):XXX\/([^:]*)/) {
        $tag=$1;
        $mde=$2;
        $lem=$3;

        if ($mde =~ /NOM/) {$mde = "Nc";} else {$mde = "A-";}
        $traduit = $tag.":".$mde."----\t".$lem;
    }

    elsif ($chaine =~/(.*NOM).*:xxx\/([^:]*)/) {
        $tag=$1;
        $lem=$2;
        
        $traduit = $tag.":Nc----\t".$lem;
    }

    #Pronoms
    elsif ($chaine =~/(.*PRO(\((PER|IND|POS|DEM|INT|REL)\))?):([123\_])p:([mf\_]):([sp\_]):([^\/]*)\/([^:]*)/) {
        $tag=$1;
        $mde=$3;
        $per=$4;
        $ge=$5;
        $nb=$6;
        $cas=$7;
        $lem=$8;
        
        
        $mde =~ s/PER/p/;
        $mde =~ s/POS/s/;
        $mde =~ s/DEM/d/;
        $mde =~ s/INT/t/;
        $mde =~ s/IND/i/;
        $mde =~ s/REL/r/;

        $ge=~s/\_/-/;
        $per=~s/\_/-/;
        $cas=~s/\_/-/;
        $cas=~s/[ado]/j/;
        $nb=~s/\_/-/;

        if ($mde =~ /[sd]/) {$def="d";}
        if ($mde eq "") {$mde="-";}
        
        $traduit = $tag.":P".$mde.$per.$ge.$nb.$cas."-\t".$lem;
    }
    # Oublis ?
    elsif ($chaine =~/[A-Z]:/) {
        $traduit.="***";
    }
    return($traduit);
}




1;

__END__

=head1 NAME

Flemm::TreeTagger - Lemmatisation du français à partir de corpus étiquetés

=head1 SYNOPSIS

use Flemm::TreeTagger;

$lemm=new Flemm::Treetagger('Format' => 'TreeTagger');


=head1 DESCRIPTION

Convertit un flot de type TreeTagger au format interne, appelle le lemmatiseur et renvoie
un résultat au format TreeTagger.

Avant d'appeler le lemmatiseur, vérifie et éventuellement corrige l'étiquetage et la
segmentation fournis par TreeTagger (en consignant les éventuelles erreurs dans 
deux fichiers séparés).

=head1 METHODES

=over 3

=item new([Format => (simple|extended)],[Logname => logname_prefix])

La méthode new crée un objet de type Flemm::TreeTagger, qui contient lui-même
un objet de type Flemm::Lemmatizer.

Si le paramètre Logname est fourni, les erreurs de segmentation seront consignées
dans un fichier dont le nom est constitué du préfixe fourni en paramètre et suffixé 
par .seg et les erreurs d'étiquetage seront consignées dans un fichier dont 
le nom est constitué du préfixe fourni en paramètre et suffixé par .etiq.

Le paramètre Format influe sur la forme du résultat qui sera délivré par la 
méthode Lemmatize.

=item lemmatize($tagger_input_line)

Le méthode lemmatize prend un résultat de TreeTagger et délivre en sortie sa forme
lemmatisée et munie des traits morpho-flexionnels au format Multext et accompagnée 
de l'étiquette catégorielle d'origine. Le résultat renvoyé est un objet de la classe
Flemm::Result. 

=back

=cut

=head1 SEE ALSO

Flemm::Result


=cut


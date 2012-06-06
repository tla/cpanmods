###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de # 
# corpus étiquetés - Version 3.1										  #
# Copyright (C) 2004 (NAMER Fiammetta)									  #
###########################################################################
# $Id$
#

package Flemm::Lemmatizer;

use English;
use strict qw(vars refs subs);
use utf8;
no warnings 'uninitialized';

# Pre-declaration de variables globales
use vars qw($directory);

use Flemm::Exceptions;

#
##################################################################
# Methodes de classe (utilisees en externe)
##################################################################
#
sub new {
  my $type = shift;
  my ($path)=@_;
	
  my $self={};
	
  bless $self,$type;

  # Les objets de la classe Flemm::Lemmatizer contiennent un objet
  # de la classe Flemm::Exceptions. C'est precisément celui-là que 
  # l'on crée à l'instruction suivante.
  $self->{"exceptions"}=new Flemm::Exceptions($path);

  # L'instruction suivante va initialiser les champs:
  #	  $self->{"pronom_il"}
  #	  $self->{"pronom_meme"}
  #	  $self->{"pronom_inv"}
  #	  $self->{"ppres_irr"}
  #	  $self->{"detrel_inv"}

  $self->initialize();

  return $self;
}

#
##################################################################
# Methodes de classe (utilisees en interne)
##################################################################
#

sub initialize {
  my $self=shift;

  my %t_pronom_il=(
				   "je"	   => "il 1_sn",
				   "moi"   => "Lui|soi 1_s_", 
				   "toi"   => "Lui|soi 2_s_", 
				   "soi"   => "soi 3_sT", 
				   "tu"	   => "il 2_sn",
				   "il"	   => "il 3msn",
				   "elle"  => "il 3fsM",					 
				   "nous"  => "il|se|le|lui 1_p_",
				   "vous"  => "il|se|le|lui 2_p_",
				   "ils"   => "il 3mpn",
				   "elles" => "il 3fpM", 
				   "eux"   => "Lui|soi 3mpM", 
				   "me"	   => "se|le|lui 1_sR",
				   "te"	   => "se|le|lui 2_sR",
				   "le"	   => "le 3msa",
				   "la"	   => "le 3fsa",
				   "l'"	   => "le 3_sa",
				   "se"	   => "se 3__R",
				   "lui"   => "lui 3_sT",
				   "les"   => "le 3_pa",
				   "leur"  => "lui 3_pd"
				  ); 

  my %t_pronom_meme=(
					 "moi-même"	  => "Lui|soi-même 1_s_",
					 "toi-même"	  => "Lui|soi-même 2_s_",
					 "soi-même"	  => "soi-même 3_sU",
					 "elle-même"  => "Lui-même 3fs_",
					 "nous-mêmes"  => "Lui|soi-même 1_p_",
					 "vous-mêmes"  => "Lui|soi-même 2_p_",
					 "elles-mêmes" => "Lui-même 3fp_",
					 "eux-mêmes"   => "Lui-même 3mp_",
					 "lui-même"	  => "Lui-même 3ms_"

					); 

  my %t_pronom_inv=(
					"certains"	=> "3mp_",
					"plusieurs" => "3_p_", 
					"beaucoup"	=> "3_p_", 
					"personne"	=> "3_s_",
					"qui"		=> "3_s_", 
					"que"		=> "___a",
					"quiconque" => "3_s_", 
					"quoi"		=> "3_sU", 
					"rien"		=> "3_s_", 
					"on"		=> "3_sn",
					"en"		=> "___S",	
					"y"			=> "___S"
				   );
  my %t_ppres_irr=(
				   "ayant"		=> "avoir", 
				   "étant"		=> "être", 
				   "etant"		=> "être",
				   "gisant"		=> "gésir", 
				   "oyant"		=> "ouïr", 
				   "sachant"	=> "savoir", 
				   "resachant"	=> "resavoir", 
				   "allant"		=> "aller",
				   "maudissant" => "maudire"
				  );
  my %t_detrel_inv=(
					"où"		=> "__",
					"dont"		=> "__",
					"plusieurs" => "_p",
					"maints"	=> "mp",
					"maintes"	=> "fp",
					"chaque"	=> "_s",
					"de"		=> "__", 
					"que"		=> "__", 
					"qu'"		=> "__", 
					"qui"		=> "__",
					"divers"	=> "_p"
				   );

  # \%pronom_il veut dire "pointeur vers le hash pronom_il". En fait, même si
  # %toto en question est une variable locale à la methode, les données
  # qu'elle contient restent valides tant que quelqu'un les reference
  # (En l'occurrence quelqu'un = $self->{"pronom_il"}). Perl utilise un
  # ramasse miettes pour recuperer les zones de données qui ne sont plus
  # référencées par personne.
  $self->{"pronom_il"}=\%t_pronom_il;
  $self->{"pronom_meme"}=\%t_pronom_meme;
  $self->{"pronom_inv"}=\%t_pronom_inv;
  $self->{"ppres_irr"}=\%t_ppres_irr;
  $self->{"detrel_inv"}=\%t_detrel_inv;
}

sub est_une_exception {
  my $self=shift;
  my ($base,$liste)=@_;

  # Le champ $self{"exceptions"} est un objet de type exceptions.
  # On lui applique la méthode member de la classe (=package) exceptions.
  return $self->{"exceptions"}->member($base,$liste);
}


#
##################################################################
# Fonctions utilitaires (ce ne sont pas des méthodes de classe)
##################################################################
#

# Terminaisons infinitives en fonction des bases neutres des verbes du 3ème groupe:

sub base_en_ire {
  my ($base)=@_;
	
  my $res="";
	
  if ($base =~
	  /^(.*-)?(re|ré|r)?(é|réé|re|contre|entre|inter|mau|pré)?(déd|d|l|méd|sour|r)$|^(re|ré|r|in)?(ré|d)?écr$|.*scr$|^(pré|re|ré|r|in)?(dé)?conf$|^(pré|re|ré|r|in)?(fr|circonc|suff)$|^(pré|re|dé|mé|sur|ré|é)*(cons?|en|ins|entre|intro|in|pro|ré|tra|sé|ad)?(cu|du|tru|lu)$|^(entre-?)?(nu)$/ ) {
	$res = $base."ire";
  }
	
  return $res;
}

sub base_en_ir {
  my ($base)=@_;

  my $res="";
	
  if ($base =~
	  /^(.*-)?(res?|dé|cir|dis|ré?)?(abs|appar|con|contre|entre|main|ob|sou|ad|de|inter|ob|par|pré|pro|su[br]|at)?(t|v|mésav)en$|(re|ac|con|recon|en)quér$|^(con|pres|res?|dé)?[psm]ent$|^(dé|res?)?(pa|so)rt$|.*vêt$|^(r)?(re|entr[e-]?)?(c|déc)?(entr\' )?ouvr$|^(més|s)?ou?ffr$|.*cueill$|^(dé|re|tres|as|é)?([fs]a|bou)ill$|.*dorm$|^(acc|conc|disc|enc|parc|rec|sec|c|m)our$|^(des|res|as)?serv$|^(en|re)?fu$|^gés$/ ) {
	$res = $base."ir";
  }

  return $res;
}

sub base_en_oir {
  my ($base)=@_;

  my $res="";
	
  if ($base =~
	  /^(.*-)?((entr[e\']?)?(r|re|a?per|pré|précon|con|é|pro)?((dé)?pour?|sa|de|as|mes|équi|sur|pleu|(dé)?ce)?(mouv|v|fall|se|val|voul))$|^(dé|é)?ch$/ ) {
	$res = $base."oir";
  }

  return $res;
}

sub base_en_re {
  my ($base)=@_;
	
  my $res= "";

  if ($base =~
	  /^(.*-)?(con|mor|par|re|ré|corres|in|abs)?[pftc]ond$|^(con|més?|sous-|re?|ré|dés?)?(com|entre|pour|ap|su[rs]|at|dis|en|é|pré)?(absc|r|f|p|t|v|pr|a|de)(and|end|scend)$|^(é|re|dé|dis)?(mord|tord|perd)$|^(cor|inter)?romp$|^(contre|re)?fout$|.*(ba|me)tt$|.*[eao]ind$|.*vainc$|^(re|ré?)?(com|abs|dis|ex|sous)?(tr|pl|dépl|br)ai$|^tai$|^(mé|ac|dé)?croi$|^(em|im)?boi$|.*cl[ou]$|^(ab|re|é)?(déc|c|m|diss|abs|rés)oud$|.*suiv$|^(re|sur)?viv$|^(re|ré)?(mé|ap|com|dis|trans|ac|dé)?(conna|para|cro)ît$|^sourd$/ ) {
	$res = $base."re";
  }
	
  return $res;
}

# Recherche l'infinitif d'une base neutre du 3ème groupe:
# Si le resultat est "", alors c'est qu'il ne s'agit pas d'un 3ème groupe:

sub infinitif {
  my ($base)=@_;

  my $res="";
	
  $res = &base_en_ir($base);
  if ($res eq "") {
	$res = &base_en_re($base);
	if ($res eq "") {
	  $res = &base_en_ire($base);
	  if ($res eq "") {
		$res = &base_en_oir($base);
	  }
	}
  }
	
  return $res;
}

# Fournit les informations flexionnelles d'une terminaison en fonction du temps:

sub termi {
  my ($tps,$term) = @_;
	
  my $res1=",";
  my $res="";
	
  if ($term =~ /^(a|t|d|ât|it|ut|ût|ît)$/) {
	$res1 .= " 3ps";
	if ($tps =~ /^(pst|pstind|pstindseul)$/) {
	  $res = "PSTIND,";
	} elsif ($tps =~ /^subjimp$/) {
	  $res = "SUBJIMP,";
	} elsif ($tps =~ /^ft$/) {
	  $res = "FUT,";
	} elsif ($tps =~ /^(noft|ps)$/) {
	  $res = "PS,";
	} else {
	  $res = "PS/PSTIND,";
	}
  } elsif ($term eq "e") {
	$res1 .= " 1/3ps";
	if ($tps =~ /^(pst|noft|pstimp)$/) {
	  $res = "PSTIND/SUBJ/IMPER,";
	} elsif ($tps =~ /^(pstindimp)$/) {
	  $res = "PSTIND/IMPER,";
	} elsif ($tps =~ /^(pstsubjimper)$/) {
	  $res = "PSTSUBJ/IMPER,";
	} elsif ($tps =~ /^(imperseul)$/) {
	  $res = "IMPER,";
	} else {
	  $res = "PSTSUBJ";
	}
  } elsif ($term =~ /^(ent|ont|èrent|rent|irent)$/) {
	$res1 .= " 3pp";
	if ($tps =~ /^(ft)$/) {
	  $res = "FUT,";
	} elsif ( ($term eq "ont") || ($tps =~ /^(pstind|pstindimp)$/)) {
	  $res = "PSTIND,";
	} elsif ($tps =~ /^(pstsubj)$/) {
	  $res = "PSTSUBJ,";
	} elsif ($tps =~ /^(pst|noft|pstimp|pstimp1|pstsubjimp)$/) {
	  $res = "PSTIND/SUBJ,";
	} elsif ($tps =~ /^(pstindseul)$/) {
	  $res = "PSTIND,";
	} else {
	  $res = "PS, ";
	}
  } elsif ($term =~ /[yi](ons|ez)$/) {
	if ($term =~ /[yi]ons$/) {
	  $res1 .= " 1pp";
	} else {
	  $res1 .= " 2pp";
	}
	if ($tps eq "ft") {
	  $res = "COND, ";
	} elsif ($tps =~ /^(pst|pstsubj)$/) {
	  $res = "PSTSUBJ, ";
	} elsif ($tps =~ /^(pstsubjimper)$/) {
	  $res = "PSTSUBJ/IMPER, ";
	} elsif ($tps =~ /^(impseul)$/) {
	  $res = "IMP, ";
	} else {
	  $res = "PSTSUBJ/IMP, ";
	}
  } elsif ($term =~ /^(âmes|[îû]?mes|ons|âtes|[ûî]?tes|ez)$/) {
	if ($term =~ /^(âmes|[îû]?mes|ons)$/) {
	  $res1 .= " 1pp";
	} else {
	  $res1 .= " 2pp";
	}
	if ($tps eq "ft") {
	  $res = "FUT, ";
	} elsif ($tps eq "ps") {
	  $res = "PS, ";
	} elsif ($tps eq "pstindseul") {
	  $res = "PSTIND, ";
	} elsif ($tps eq "imperseul") {
	  $res = "IMPER, ";
	} else {
	  $res = "PSTIND/IMPER, ";
	}
  } elsif ($term =~ /^ait$/) {
	$res1 .= " 3ps";
		
	if ($tps eq "ft") {
	  $res = "COND, ";
	} else {
	  $res =  "IMP, ";
	}
  } elsif ($term eq "aient") {
	$res1 .= " 3pp";
	if ($tps eq "ft") {
	  $res = "COND, ";
	} else {
	  $res =  "IMP, ";
	}
  } elsif ($term =~ /^(ais|is|us|s|x)$/) {
	$res1 .= " 1/2ps";
	if ($tps eq "pstps") {
	  $res = "PSTIND/PS/IMPER, ";
	} elsif ($tps =~ /^(pst|pstind)$/) {
	  $res = "PSTIND/IMPER, ";
	} elsif ($tps =~ /^(pstindseul)$/) {
	  $res = "PSTIND, ";
	} elsif ($tps eq "ft") {
	  $res = "COND, ";
	} elsif ($tps eq "ps") {
	  $res = "PS, ";
	} else {
	  $res = "IMP, ";
	}
  } elsif ($term =~ /^es$/) {
	$res1 .= " 2ps";
	if ($tps =~ /^(pst|pstimp|pstimp1)$/) {
	  $res = "PSTIND/SUBJ, ";
	} elsif ($tps =~ /^(pstindseul)$/) {
	  $res = "PSTIND, ";
	} else {
	  $res = "PSTSUBJ, ";
	}
		
  } elsif ($term =~ /^(ai|as)$/) {
	if ($term =~ /ai$/) {
	  $res1 .= "1ps";
	} else {
	  $res1 .= "2ps";
	}
	if ($tps eq "ft") {
	  $res = "FUT, ";
	} elsif ($tps eq "pst") {
	  $res = "PSTIND/SUBJ, ";
	} else {
	  $res = "PS, ";
	}
  }

  $res = $res1.$res;

  return $res;
}
	
sub variation_ortho1 {
  my $self=shift;
  my ($base,$term) = @_;

  my ($a,$b);
  my $res="";

  if ($base =~ /^(.*)ç$/) {
	$res = $1."c";
  } elsif ($base =~ /^(.*)ge$/) {
	$res = $1."g";
  } elsif ($base =~ /^sèvr$/) {
	$res = "sevr";
  } elsif ($term =~ /^(e|es|ent|er(a[is]?|i?ons|i?ez|ont|ai[st]|aient))$/) {

	if ($base =~ /^(.*)è(vr|br|ch|cr|d|g|gl|j|gn|gr|gu|qu|tr|y)$/) {
	  $res = $1."é".$2;
	} elsif ($base eq "recèp") {
	  $res = "recép";
	  # il y a aussi receper;
	} elsif ($base =~ /^(.*)èc$/) {
	  $a=$1;
	  if ($self->est_une_exception($a,"V_eCer_naccent")) {
		$res= $a."ec";
	  } else {
		$res= $a."éc";
	  }
	} elsif ($base =~ /^(.*)èl$/) {
	  $a=$1;
	  if ($self->est_une_exception($a,"V_eLer_aigu")) {
		$res= $a."él";
	  } else {
		$res = $1."el";
	  }
	} elsif ($base =~ /^(.*)èm$/) {
	  $a=$1;
	  if ($self->est_une_exception($a,"V_eMer_naccent")) {
		$res= $a."em";
	  } else {
		$res= $a."ém";
	  }
	} elsif ($base =~ /^(.*)è(n|t)$/) {
	  $a=$1;
	  $b=$2;
	  if ($self->est_une_exception($a,"V_eNTer_aigu")) {
		$res= $a."é".$b;
	  } else {
		$res = $a."e".$b;
	  }
	} elsif ($base =~ /^(.*)èr$/) {
	  $a=$1;
	  if ($self->est_une_exception($a,"V_eRer_naccent")) {
		$res= $a."er";
	  } else {
		$res= $a."ér";
	  }
	} elsif ($base =~ /^(.*)ès$/) {
	  $a=$1;
	  if ($self->est_une_exception($a,"V_eSer_naccent")) {
		$res= $a."es";
	  } else {
		$res= $a."és";
	  }
	} elsif ($base =~ /^(.*)èv$/) {
	  $a=$1;
	  if ($self->est_une_exception($a,"V_eVer_aigu")) {
		$res= $a."év";
	  } else {
		$res = $a."ev";
	  }
	}
		
	# A l'exception d'une liste de verbes:

	elsif ( !($self->est_une_exception($base,"V_tt")) &&
			($base =~ /^(.*)(e)(t)t$/)) {
	  $res = $1.$2.$3;
	} elsif ( !($self->est_une_exception($base,"V_ll")) &&
			  ($base =~ /^(.*)(e)(l)l$/)) {
	  $res = $1.$2.$3;
	} elsif ($base =~ /^(.*)(a|o|u)i$/) {
	  $res = $1.$2."y";
	} else {
	  $res = $base;
	}
  } else {
	$res = $base;
  }

  return $res;
}


# Ne renvoie que la base neutralisée :

sub ortho_ps3 {
  my $self=shift;
  my ($base,$term) = @_;

  my $res="";

  if ($term =~ /^(it|is|ît|îmes|îtes|irent)$/) {

	if ($base =~ /(.*vain)qu$/) {
	  $res = $1."c";
	} elsif ($base =~ /^(con|re?|ré|sous-)?(absc|dé|pour|ap|des|corres|sus|at|mor|par|dis|en|é|pré|mé|as)?[rfcptv](and|ond|end)$|^(re|dé|dis)?[mtp][eo]rd$|.*romp$|.*batt$|.*serv$|.*fu$|.*suiv$/) {
	  $res = $base;

	} elsif ($base =~ /(.*)(sent|ment|pent|vêt|ouvr|ou?ffr|dorm)$/) {					
	  $res = $1.$2;
	} elsif ($base =~ /^(dé|re|ac|tres)?(part|port|sort|assaill|saill|faill|cueill|bouill)$/) {
	  $res = $1.$2;
	}
	# acquérir
	elsif ($base =~ /^(re)?(ac|con|en|re)?(qu)$/) {
	  $res = $1.$2.$3."ér";
	} elsif ($base =~ /(.*)(a|o|e)(ign)$/) {
	  $res = $1.$2."ind";
	} elsif ($base =~ /(.*)(cu|cr)i(s|v)$/) {
	  $res = $1.$2;
	} elsif ($base =~ /(.*)(cou)s$/) {
	  $res = $1.$2."d";
	}

	# Verbes en "(e)oir"

	elsif ($base =~ /(.*)(ass|surs)$/) {
	  $res = $1.$2."e";
	} elsif ($base =~ /^(re|ré)?(entre|pré)?(v)$/) {
	  $res = $1.$2.$3;
	}

	# "dire"et "rire" : si $term = it, alors aussi au présent.

	elsif ($base =~ /^(re|ré)?(contre|dé|inter|mau|mé|pré|re|sou)?(d|r)$/) {
	  $res = $1.$2.$3;
	}

	# Composés de "prendre"
	elsif ($base =~ /^(dés|m|ré|mé)?(ap|com|dé|entre|é|re|sur)?(pr)$/) {
	  $res = $1.$2.$3."end";
	}
	# Composés de "mettre"
	elsif ($base =~ /^(com|re|ré)?(ad|com|pro|d?é|entre|o|per|trans|sou)?(m)$/) {
	  $res = $1.$2.$3."ett";
	}

	# "confire,circoncire/frire/suffire" : si $term = it/is, 
	# alors aussi au présent.

	elsif ($base =~ /^(re)?(dé|cir)?(conf|conc|fr|suff)$/) {
	  $res = $1.$2.$3;
	} elsif ($base =~ /(.*)(cons?|dé|en|ins?|ro|ré|sé|tra)?(nu|lu|du|tru)(is)$/) {
	  $res = $1.$2.$3;
	} else {
	  $res = $base;
	}
  } elsif ($term =~ /^(ut|us|ût|ûmes|ûtes|urent)$/) {

	if ($base eq "résol") {
	  $res = "résoud";
	} elsif ($base =~ /^(com|dé)?(pl|t)$/) {
	  $res = $1.$2."ai";
	} elsif ($base =~ /^(re|é)?moul$/) {
	  $res = $1."moud";
	} elsif ($base =~ /^(re|sur)?(v)éc$/) {
	  $res = $1.$2."iv";
	} elsif ($base =~/^(im|em|mé)?(cr|b)$/) {
	  $res = $1.$2."oi";
	}

	# Verbes en "oir"

	elsif ($base =~ /(.*)ç$/) {
	  $res = $1."cev";
	} elsif ($base =~ /^(re)?s$/) {
	  $res = $1."sav";
	} elsif ($base =~ /^(re)?d$/) {
	  $res = $1."dev";
	} elsif ($base =~ /^(ém|prom|m|p)$/) {
	  $res = $1."ouv";
	}

		
	# Verbes en "ure/ire"

	elsif ($base =~ /^(con|ex|in|oc|re)?cl$/) {
	  $res = $1.$2."clu";
	}


	# Réguliers: valoir, vouloir, falloir, courir, mourir, pourvoir, choir, lire
	elsif ($base =~ /^(re|ré)?(ac|con|dis|en|par|se|dé|é|équi|pré|entre)?(val|voul|cour|mour|pourv|ch|l|fall)$/) {

	  $res = $1.$2.$3;
	} else {

	  $res = $base;
	}
  }

  return $res;
}

# Ne traite que les cas particuliers. Tous les autres sont traités 
# dans la fonction appelante.

sub ortho_fut3 {
  my $self=shift;
  my ($base)=@_;

  my $res="";

  if ($base =~ /(.*)(t|v)iend$/) {
	$res = $1.$2."en";
  } elsif ($base =~ /(.*)quer$/) {
	$res = $1."quér";
  } elsif ($base =~ /^(entrev|prév|rev|éch|v)er$/) {
	$res = $1;
  } elsif ($base =~ /(.*)(pourv|prév)oi$/) {
	$res = $1.$2;
  } elsif ($base =~ /^(re)?sau$/) {
	$res = $1."sav";
  } elsif ($base =~ /^faud$/) {
	$res = "fall";
  } elsif ($base =~ /^(vou)d$/) {
	$res = $1."l";
  } elsif ($base =~ /^pour$/) {
	$res = "pouv";
  } elsif ($base =~ /(.*)vaud$/) {
	$res = $1."val";
  } elsif ($base =~ /^(r)?(ass|surs|s)(eoi|ié|oi)$/) {
	$res = $1.$2."e";
  } elsif ($base =~ /(.*)(ch)oi$/) {
	$res = $1.$2;
  } else {
	$res=$base; 
  }
	
  return $res;
}
		
# Par défaut, la fonction renvoie la base. Si ensuite la fonction infinitif
# échoue, c'est qu'on a affaire à un verbe du premier groupe.

sub ortho_imp3 {
  my $self=shift;
  my ($base)=@_;

  my ($aux);
  my $res="";

  if ($base =~ /(.*)(fu)y$/) {
	$res = $1.$2;
  } elsif ($base =~ /^(re)?(entre|pré|re|pour|dépour)?voy$/) {
	$res = $1.$2."v";
  } elsif ($base =~ /^(sou)?(r)i$/) {
	$res = $1.$2;
  } elsif ($base =~ /^(sur|r?as|mes)?s(o|e)y$/) {
	$res = $1."se";
  } elsif ($base =~ /(.*)(pren)$/) {
	$res = $1.$2."d";
  }
	
  # baign,(dé)daign, éloign, empoign, (r)enseign, (res)saign,
  # soign, témoign,(r)encoigner, engeigner
	
  # sont du premier groupe. (dé)peign fait soit 
  # "(dé)peindre" soit "(dé)peigner", et est traité dans la 
  # fonction appelante.
	
  elsif ($base =~ /(.*)([aoe])ign$/) {
	$aux = $1.$2;
	if ($self->est_une_exception($base,"V_ign")) {
	  $res = $base;
	} else {
	  $res = $aux."ind";
	}
  } elsif ($base =~ /(.*)(vain)qu$/) {
	$res = $1.$2."c";
  } elsif ($base =~ /^(réé?|re|é|pré)?(dé|mé|sur)?(ad|contre|inter|pré|cons?|en|ins?|intro|suf|pro|tra|sé|entre)?(circonc|tru|du|lu|nu|cu|l|d|f|méd)is$/) {
	$res = $1.$2.$3.$4;
  } elsif ($base =~ /^(re|r|ré)?(é|circons|dé|trans|ins|pres|pros|sous)(cr)iv$/) {
	$res = $1.$2.$3;

  } elsif ($base =~ /(.*)(tra|cro)y$/) {
	$res = $1.$2."i";
  } elsif ($base =~ /(.*)(fai|plai|tai)s$/) {
	$res = $1.$2;
  } elsif ($base =~ /^(em|im)?buv$/) {
	$res = $1."boi";
  } elsif ($base =~ /^(abs|diss|rés)olv$/) {
	$res = $1."oud";
  } elsif ($base =~ /^(dé|re)?(cou)s$/) {
	$res = $1.$2."d";
  } elsif ($base =~ /^(re|é)?(mou)l$/) {
	$res = $1.$2."d";
  } else {
	$res = $base;
  }
	
  return $res;
}

		
# Par défaut, la fonction renvoie la base. Si ensuite la fonction infinitif
# échoue, c'est qu'on a affaire à un verbe du premier groupe.

sub ortho_pst3 {
  my $self=shift;
  my($base,$term)=@_;

  my $aux;
  my $res="";

  if ( ($term =~ /^[st]$/) && ($base =~ /(.*)(v|t)ien$/)) {
	$res = $1.$2."en";
  } elsif ( ($term =~ /^[st]$/) && ($base =~ /(.*)pla[iî]$/)) {
	$res = $1."plai";
  } elsif (($term =~ /^e(s|nt)?$/) && ($base =~ /(.*)(v|t)ienn$/)) {
	$res = $1.$2."en";
  } elsif (($term =~ /^(t|s|es?|ent)$/) && ($base =~ /(.*)qui[èe]r$/)) {
	$res = $1."quér";
  } elsif ( ($term =~ /^[st]$/) && ($base =~ /^(contre|con|pres|res?)?([ps]en|(dé)?m|(dé)?par|sor|(dé)?vê|fou)$/) ) {

	$res = $1.$2."t";
  } elsif (($term =~ /^[st]$/) && ($base =~/^(dé|é)?(bou)$/) ) {
	$res = $1.$2."ill";
  } elsif (($term =~ /^[st]$/) && ($base =~ /(.*)(en)?(dor)$/)) {
	$res = $1.$2.$3."m";
  } elsif ($base =~ /^meur$/) {
	$res = "mour";
  } elsif (($term =~ /^[st]$/) && ($base =~ /(.*)(dés|res)?(ser)$/)) {
	$res = $1.$2.$3."v";
  } elsif ($base =~ /^(en|re)?(fu)[i|y]$/) {
	$res = $1.$2;
  } elsif ($base =~ /(.*)çoiv?$/) {
	$res = $1."cev";
  } elsif ($base =~ /^(dé|re|ré?)?(pour|entre|pré)?voi$/) {
	$res = $1.$2."v";
  } elsif ($base =~ /^(re|dé|é)?ch(e|é|oi)$/) {
	$res = $1."ch";
  } elsif ($base =~ /^(re)?doiv?$/) {
	$res = $1."dev";
  } elsif ($base =~ /(.*)(p|m)euv?$/) {
	$res = $1.$2."ouv";
  } elsif ($base =~ /^(re)?pleu$/) {
	$res = $1."pleuv";
  } elsif ($base =~ /^fau$/) {
	$res = $1."fall";
  } elsif ($base =~ /^(re|pré|équi)?va(u|ill)$/) {
	$res = $1."val";
  } elsif ($base =~ /^veu(il)?l?/) {
	$res = "voul";
  } elsif (($term =~ /^e(s|nt)?$/) && ($base =~ /(.*)(sié|sey|soi|soy)$/)) {
	$res = $1."se";
  } elsif (($term =~ /^[tds]$/) && ($base =~ /(.*)(sie|soi)$/)) {
	$res = $1."se";
  } elsif (($term =~ /^(e|t|s|ent|i?ons|i?ez)$/) && ($base =~ /^(é|dé)(ch)o[yi]$/)) {
	$res = $1.$2;
  } elsif (($term =~ /^(ons|ez)$/) && ($base =~ /(.*)(fu)y$/)) {
	$res = $1.$2;
  } elsif (($term =~ /^(ons|ez)$/) &&
		   ($base =~ /^(re)?(entre|pré|re|pour|dépour)?voy$/)) {
	$res = $1.$2."v";
  } elsif (($term =~ /^(ons|ez)$/) && ($base =~ /(.*)(tra|cro)y$/)) {
	$res = $1.$2."i";
  } elsif (($term =~ /^(ons|ez)$/) && ($base =~ /^(em|im)?buv$/)) {
	$res = $1."boi";
  } elsif (($term =~ /^(ons|ez)$/) && ($base =~ /^(sur|r?as|mes)?s(o|e)y$/)) {
	$res = $1."se";
  } elsif (($term =~ /^(ons|ez)$/) && ($base =~ /(.*)(pren)$/)) {

	$res = $1.$2."d";
  } elsif (($term =~ /^[sd]$/) && ($base =~ /(.*)(sour|mou|cou|r|n)$/)) {

	$res = $1.$2."d";
  } elsif (($term =~ /^e(s|nt)?$/) && ($base =~ /(.*)(pren)n$/)) {
	$res = $1.$2."d";
  } elsif ( ($term =~ /^[st]$/) && ($base =~ /(.*)(me|ba)$/)) {
	$res = $1.$2."tt";
  } elsif (($term =~ /^[st]$/) && ($base =~ /(.*)(e|a|o)(in)$/) ) {
	$res = $1.$2.$3."d";
  }
	
  # baign,(dé)daign, éloign, empoign, (r)enseign, (res)saign,
  # soign, témoign	 sont du premier groupe. (dé)peign fait soit 
  # "(dé)peindre" soit "(dé)peigner", et est traité dans la 
  # fonction appelante.
	
  elsif ($base =~ /(.*)([aeo])ign$/) {
	$aux = $1.$2;
	if ($self->est_une_exception($base,"V_ign")) {
	  $res = $base;
	} else {
	  $res = $1.$2."ind";
	}
  } elsif ($base =~ /(.*)(vain)qu$/) {
	$res = $1.$2."c";
  } elsif (($term =~ /^(ons|ez|ent|es?)$/) && ($base =~ /(.*)(pl|t)(ai)s$/) ) {
	$res = $1.$2.$3;
  } elsif (($term =~ /^e(s|nt)?$/) &&
		   ($base =~ /(.*)(boi)v$/)) {
	$res = $1.$2;
  } elsif (($term =~ /^[st]$/) && ($base =~ /(.*)(boi)$/)) {
	$res = $1.$2;
  } elsif ($base =~ /(.*)cl(ô|os)$/) {
	$res = $1."clo";
  } elsif (($term =~ /^[st]$/) && ($base =~ /(.*)sou$/)) {
	$res = $1."soud";
  } elsif (($term =~ /^(es?|ons|ez|ent)$/) && ($base =~ /(.*)solv$/)) {
	$res = $1."soud";
  } elsif ( ($term =~ /^(es?|ons|ez|ent)$/) && ($base =~ /^(é|re)moul$/) ) {
	$res = $1."moud";
  } elsif (($term =~ /^(es?|ons|ez|ent)$/) && ($base =~ /(.*)cous$/) ) {
	$res = $1."coud";
  } elsif ( ($term =~/^(es?|ons|ez|ent)$/) && ($base =~ /^(non-)?(re|ré|rée|cir)?(dé|sur|é|mé)?(pres|entre|pros?|trans|contre|inter|mau|pré|intro|sur|en|cons?|ins?|tra|é|sé|sous|ad)?(lu|du|nu|cu|tru|l|d|cr|conf|circonc|suff)i(s|v)$/)) {
	$res = $1.$2.$3.$4.$5;
  } elsif ( $base =~ /^(sou)?(r)i$/) {
	$res = $1.$2;
  } else {
	$res = $base;
  }
	
  return $res;
}

sub verbe_regulier {
  my $self=shift;
  my ($vb)=@_;

  my ($aux,$term,$inf,$base);
  my $res="";

  # LE FUTUR/CONDITIONNEL

  # Le seul verbe dont la terminaison future est -éra:

  if ($vb =~ /^messiér(i?ons|i?ez|a[is]?|ont|aient|ai[st])$/) {
	$res = "messeoir".&termi("ft",$1)." (3e groupe)";
  }
	
  # Les composés de "traire"
	
  elsif ($vb =~ /^(re|ré?)?(abstr|distr|extr|soustr|tr|br)(ai)(s|t|ent)$/ ) {
	$res = $1.$2."aire".&termi("pst",$4)."(3e groupe)";
  }
	
  # Verbes en "-vrir",	
  # Futur/Conditionnel en "r", ou verbes du 1er groupe a 
  # l'imparfait/passé simple?
	
  elsif ($vb =~ /(.*)(c|fout|d|r|v|oi|au|ié|ai|clo|clu|tt|p)(r)(a[is]?|ont|i?ons|i?ez|ai[st]|aient)$/) {
	$inf = $4;
	$base = $1.$2;
	$aux = $1.$2.$3;
	$term = $3.$4;
		
	if (($base =~ /^(rec)?ouv$/)&& ($inf ne "a")) {
	  $term = &termi("noft",$inf);
	  $res = $aux."ir".$term." (3e groupe), ou ".
		$aux."er".$term." (1er groupe)";
	} elsif ($base =~ /^(c|(re)?déc|entr(\' )?|r)ouv$/) {
	  $res = $aux."ir".&termi("noft",$inf)."(3e groupe)";
	} else {
			
	  $res = &infinitif($self->ortho_fut3($base));	
			
	  if ($res eq "") {
				
		# Le verbe se termine par -rions: soit de la liste ier,
		# soit ambigu (colorier/colorer) soit imparfait:
				
		if (($inf =~ /^i(ez|ons)$/) && 
			($aux =~ /^(.*)(charr|cr|expropr|appropr|pr)$/)) {
		  $inf =~ s/i//;
		  $res = $aux."ier". &termi("pstind", $inf)." (1er groupe)";
		} elsif (($inf =~ /^(iez|ions)$/) && 
				 ($aux =~ /^(dé)?(par|color)$/)) {
		  $inf =~ s/i//;
		  $res = $aux."ier ". &termi("pstind", $inf)." (1er groupe) ou ".
			$aux."er". &termi("pstsubjimp", "i".$inf). " (1er groupe)";
		} else {
		  $res = &infinitif($self->ortho_imp3($base)); 
		  if ($res eq "") {
			$base = $aux;
			$term = $inf;
			$res = $self->variation_ortho1($base,$term).
			  "er".&termi("noft",$term)."(1er groupe)";
		  } else {
			$res .= &termi("imp",$inf)."(3e groupe)";
		  }
		}
	  } else {
		$res .= &termi("ft",$inf)."(3e groupe)";
	  }
	}
  }
	
  # Autres verbes du 1er groupes qui ressemblent a des futur:

  elsif ($vb=~ /^(cher|liser)(a[is]?|i?ons|i?ez|ai[st]|aient)$/) {
	$base=$1;
	$term=$2;
	$res = $base."er".&termi("noft",$term)."(1er groupe)";
  } elsif ($vb =~ /^(.*)(ir)(a[is]?|i?ons|i?ez|ai[st]|aient|ont)$/) {
	$base = $1.$2;
	$aux = $1;
	$term=$3;

	if ($self->est_une_exception($base,"V_irer")) {
	  $res =  $self->variation_ortho1($base,$term)."er".&termi("noft",$term)."(1er groupe)";
	}	
		
	# Les verbes en "ire" ou "ir"
		
	else {
	  $base = &base_en_ire($aux);

	  if ($base ne "") {
		$res = $base.&termi("ft",$term)." (3e groupe)";
	  } else {
		$res = $1."ir".&termi("ft",$term)." (2e groupe)";
	  }
	}
  } 
	
	
  # Futur/Conditionnel en "er"
	
  elsif ($vb =~ /^(ac|re)?(cueill|saill)(er)(a[is]?|ont|i?ons|i?ez|ai[ts]|aient)$/) {
	$base = $1.$2;
	$res = $base."ir".&termi("ft",$4)." (3e groupe)";
  } elsif ($vb =~ /(.*)(er)(a[is]?|ont|i?ons||i?ez|ai[ts]|aient)$/) {
	$base = $1;
	$term = $2.$3;

	$res = $self->variation_ortho1($base,$term)."er".&termi("ft",$3)." (1er groupe)";
  }
	
  # IMPARFAIT
	
  # Attention, les verbes comme "monnayer" ont
  # l'air d'être 
  # des imparfaits ...
	
  elsif ($self->est_une_exception($vb,"V_ayer")) {
	$vb =~ /(.*)aient$/;
	$res = $1."ayer, 3ppPST_ (1er groupe)";
  }

  # Attention, (dé)peigne(nt)/ai(ent)/(i)ons 
  # ont 2 bases possibles:
	
  elsif ($vb =~ /^(re)?(dé)?peign(i?ons|i?ez|es?|ent|ai[st]|aient)$/) {
	$res = $1.$2."peigner".&termi("pstimp",$3).
	  " (1er groupe) ou ".$1.
		$2."peindre".&termi("pstsubjimp",$3)." (3eme groupe)";
  }		
	
  # Attention, fonde(nt)/ai(ent)/(i)ons 
  # ont 2 bases possibles:
	
  elsif ($vb =~ /^(re)?(fond)(i?ons|i?ez|es?|ent|ai[st]|aient)$/) {
		
	$res = $1.$2."er".&termi("pstimp",$3).
	  " (1er groupe) ou ".$1.$2.
		"re".&termi("pstsubjimp",$3)." (3eme groupe)";
  }		
	
  # Les verbes de la liste d'exception sont du premier groupe, finissant par "iss":
	
  elsif ($vb =~ /(.*)iss(es?|i?ons|i?ez|ent|ai[st]|aient)$/) {
	$aux = $1;
	$term = $2;
	$base = $1."iss";
		
	if ($self->est_une_exception($base,"V_iss")) {

	  $res = $base."er".&termi("noft",$term)." (1er groupe)";
	} elsif ($aux =~ /^maud$/) {
	  $res = $aux."ire".&termi("pstimp",$term)." (3e groupe)";
	} elsif ($aux =~ /^pu$/) {
	  $res = "pouvoir".&termi("pstsubj",$term)." (3e groupe)";
	}
		
	# Présence de "iss"= présent (ind pl/subj) ou impft, 2eme groupe
	else {		

	  $res = $aux."ir".&termi("pstsubjimp",$term).
		" (2e groupe)";
	}
  }				
  # Les verbes en "ions" de la liste liste_ier sont 
  # des 1er groupe present:
	
  elsif ($vb =~ /^(par|affil|color|décolor|dépar|boug|tarif)i(ez|ons)$/) {
	$term = $2;
	$res = $1."er ". &termi("pstsubjimp", "i".$term)." ou ".
	  $1."ier ". &termi("pstind", $term)." (1er groupe) ";
  } elsif ($vb =~ /(.*)(i)(ez|ons)$/) {
	$base= $1;
	$term = $2.$3;
		
	if ($base =~ /^(é|dé|en)?clos$/) {
	  $res = $1."clore ". &termi("pstsubjimp", $term)." (3e groupe) ";
	} elsif ($base =~ /^(aff|escoff)$/) {
	  $res = $self->variation_ortho1($base."i",$term).
		"er ". &termi("pstind", $term)." (1er groupe)";
	} elsif (($self->est_une_exception($base,"V_fpher")) || 
			 ($base =~ /ff$/)) {
			
	  $res = $self->variation_ortho1($base,"i".$term).
		"er ". &termi("pstsubjimp", "i".$term)." (1er groupe)";
	}
		
	#Tous les verbes en "f/phier", et les autres de la liste:

	elsif (($base =~ /(ph|f)$/) || 
		   ($self->est_une_exception($base,"V_ier"))) {
			
	  $res = $self->variation_ortho1($base."i",$term).
		"er ". &termi("pstind", $term)." (1er groupe)";
	} else {
	  $res = &infinitif($self->ortho_imp3($base));
			
	  #	 si INFINITIF rejette l'hypothese que
	  # la base soit du 3ème groupe:
			
	  if ($res eq "") {
		$res = $self->variation_ortho1($base,"i".$term).
		  "er". &termi("pstsubjimp", "i".$term)." (1er groupe)";
	  } else {
		$res .= &termi("pstsubjimp", "i".$term)." (3e groupe)";
	  }
	}			
  }
	
  # Sinon, on appelle la fonction imparfait

  elsif ($vb =~ /(.*)ai(s|t|ent)$/) {
	$term = $2;
	$base = $1;
	$aux = $self->ortho_imp3($base);
	$res = &infinitif($aux); 
		
	#  si INFINITIF rejette l'hypothese que
	# la base soit du 3ème groupe:

	if ($res eq "") {
	  $res = $self->variation_ortho1($base,"ai".$term)."er".&termi("imp","ai".$term)." (1er groupe)";
	} else {
	  $res .= &termi("imp", "ai".$term)." (3e groupe)";
	}
  }
	
  # LE PASSÉ SIMPLE
	
  # Passé simple 1er groupe 
	
  elsif ($vb =~ /^(.*)(a[is]?|ât|â[tm]es|èrent)$/) {
	$base =$1;
	$term=$2;
		
	if ($vb =~ /^((ap|em)?p|(dé|em)?b|(dé)?m|g|h|t)âtes$/) {
	  $res = $base."âter, 2psPSTIND/SUBJ, (1er groupe)";
	} elsif ($vb =~ /^(bl|p)âmes$/) {
	  $res = $base."âmer, 2psPSTIND/SUBJ, (1er groupe)";
	} elsif ($term eq "ât") {
	  $res = $self->variation_ortho1($1,"ât")."er ". &termi("subjimp", $term)." (1er groupe)";
	} elsif ($term eq "èrent") {
			
	  if ($base =~ /^(re)?(con|ac|en)?(qu)i$/) {
		$res = $1.$2.$3."érir, 3ppPSTIND (3e groupe)";
	  }
			
	  # lacer vs lacérer
	  elsif ($base =~ /^lac$/) {
		$res = "lacer, 3ppPS ou lacérer, 3ppPSTIND/SUBJ (1er groupe)";
	  }

	  # liserer
			
	  elsif ($self->est_une_exception($base,"V_erer")) {
		$res = $self->variation_ortho1($base."èr","ent").
		  "er".&termi("pst",$term)." (1er groupe)";
	  } else {
		$res = $self->variation_ortho1($base,$term)."er".&termi("ps",$term)." (1er groupe)";
	  }					
	}
				 
	# Autres terminaisons du passé simple, premier groupe:
		
	else {
	  $res = $self->variation_ortho1($base,$term)."er".&termi("ps",$term)." (1er groupe)";
	}					
  }
	
  # Passé simple 3eme groupe, modèle "tenir/venir"

  elsif ($vb =~ /^(.*)(v|t)[iî]n(s|t|tes|mes|rent)$/) {
		
	$res = $1.$2."enir ";
	$term = $3;
	if ($vb =~ /înt$/) {
	  $res .= &termi("subjimp","ît");
	} else {
	  $res .= &termi("ps",$term);
	}
	$res .= " (3e groupe)";
  }

  # Passé simple 3eme groupe : plaire ou pleuvoir
	
  elsif ($vb =~ /^(re)?(pl)[ûu](t)$/) {
	$base = $1.$2;
	$res = $1.$2."aire	ou ".$1.$2."euvoir";
	$term = $3;
	if ($vb =~ /ût$/) {
	  $res .= &termi("subjimp", "ût");
	} else {
	  $res .= &termi("ps",$term);
	}
	$res .= " (3e groupe)";
  }
	
  # TErminaison en "urent" : passe simple ou present?
	
  elsif ($vb eq "murent") {
	$res = "murer, 3ppPST_, (1er groupe)  ou mouvoir, 3ppPS, (3e groupe)";
  } elsif ($vb eq "durent") {
	$res = "durer, 3ppPST_, (1er groupe)  ou devoir, 3ppPS, (3e groupe)";
  } elsif ($vb eq "moulurent") {
	$res = "moulurer, 3ppPST_, (1er groupe)	 ou moudre, 3ppPS, (3e groupe)";
  } elsif ($vb eq "perdurent") {
	$res = "perdurer, 3ppPST_, (1er groupe)";
  } elsif ($vb =~ /^(.*)(ur)(ent)$/) {
	$base = $1;
	$aux = $1.$2;
	$res =	 &infinitif($self->ortho_ps3($base,"urent"));
	if ($res ne "") {  
	  $res .= ", 3ppPS, (3e groupe)"; 
	} else {
	  $res = &infinitif($self->ortho_pst3($aux,"ent"));

	  if ($res eq "") {
		$res =	$self->variation_ortho1($aux,"ent")."er, 3ppPST_, (1er groupe)"; 
	  } else {
		$res .= ", 3ppPST_, (3e groupe)";
	  }
	}
  }
	
  # Passé simple 2/3eme groupe en "i/u"
	
  elsif ($vb =~ /^(.*)([^aoe])([iuûî][st]|î[tm]es|û[mt]es|irent)$/) {
	$base = $1.$2;
	$term = $3; 
		
	# Terminisons exceptionnelles
		
	if ($vb =~ /^(aff|enf|fl)ûtes$/) {
	  $res = $1."ûter, 2psPSTIND/SUBJ (1er groupe)";
	} elsif ($vb =~ /^(g)îtes$/) {
	  $res = $1."ûter, 2psPSTIND/SUBJ (1er groupe)";
	} elsif ($vb =~ /^abîmes$/) {
	  $res = "abîmer, 2psPSTIND/SUBJ (1er groupe)";
	} elsif ($vb =~ /^dîmes$/) {
	  $res = "dîmer, 2psPSTIND/SUBJ (1er groupe) ou dire, 1ppPS (3e groupe)";
	} elsif ($vb =~ /^(réad|ad)?(m)irent$/) {
	  $res = $1.$2."irer, 3ppPSTIND/SUBJ (1er groupe), ou ".
		$1.$2."ettre, 3ppPS (3e groupe)";
	} elsif ($vb =~ /^(re)?virent$/) {
	  $res = $1."virer, 3ppPSTIND/SUBJ (1er groupe), ou ".
		$1."voir, 3ppPS (3e groupe)";
	} elsif (($term =~ /^irent$/) && 
			 ($self->est_une_exception($base."ir","V_irer"))) {
	  $res = $self->variation_ortho1($base."ir","ent")."er, 3ppPST (1er groupe)";
	}
		
	# it/is est la marque (exclusive) du present/imperatif
	# de certains verbes du 3e groupe

	elsif (($term =~ /^i[ts]$/) && 
		   ($base =~ /^(re|ré)?(contre|dé|inter|mau|mé|pré|re|sou)?(d|r)$/)) {
	  $res = $1.$2.$3."ire ". &termi("pstps", $term)." (3e groupe)";
	} elsif (($term =~ /^i[ts]$/) && 
			 ($base =~ /^(sous-?|re|ré|rée|cir|pré)?(dé)?(ad|é|manus|pres|pros?|trans|intro|en|cons?|ins?|tra|sé)?(lu|du|nu|cu|tru|l|cr)$/)) {
	  $res = $1.$2.$3.$4."ire ". &termi("pstind", $term)." (3e groupe)";
	} elsif (($term =~ /^i[st]$/) && ($base =~ /^(re)?v$/)) {
	  $res = $1."vivre". &termi("pstind", $term)." ou ".$1."voir ". &termi("ps", $term)." (3e groupe)";
	} elsif (($term =~ /^i[ts]$/) && 
			 ($base =~ /^(re|ré)?(en|pour|sur)?(v|su)$/)) {
	  $res = $1.$2.$3."ivre ".&termi("pstind", $term)." (3e groupe)";
	} else {
	  $res =   &infinitif($self->ortho_ps3($base,$term));

	  if ($res eq "") {
				
		# Il s'agit d'un verbe du 2ème groupe, soit au 
		# subjonctif imparfait (ît), soit à l'indicatif présent sg
		# ou à l'impératif,
		# ou au passé simple (it/is):
				
		$res = $base."ir";
		if ($term =~ /ît$/) {
		  $res .= &termi("subjimp",$term);
		} elsif ($term =~ /î[mt]es$/) {
		  $res .= &termi("ps",$term);
		} else {
		  $res .= &termi("pstps",$term);
		}
				
		$res .= " (2e groupe)";
	  } else {
		if ($term =~ /[ûî]t$/) {
		  $res .= &termi("subjimp",$term);
		} else {
		  $res .= &termi("ps",$term);
		}
		$res .= " (3e groupe)";							
	  }
	}
  }
	
  # PRESENT (indicatif/subjonctif) et IMPERATIF

  # Le present des verbes du 2nd groupe a été traité dans les cas
  # ci-dessus. Restent les verbes du 3ème et du 1er groupe, 
  # dont les terminaisons sont	es/x/e/ez/ons/ent, t/d
	
  # Attention, pour les verbes *venir, *tenir, etc. la 3eme personne du sg du PST ind. 
  # ressemble a une 3eme ps du pl (vient = vivre, 3eme ppl, tient -> ti+ent, etc.)
	
  # Impératif "spécial" pour ces deux formes:

	
  elsif ($vb =~ /^(re)?(veuill|sach)(es?|i?ons|i?ez|ent)$/) {
	$base = $1.$2;
	$term = $3;
	if ($base =~ /sach/) {
	  $res = "savoir ";
	} else {
	  $res = "vouloir ";
	}
	if ($term eq "e") {
	  $res .= &termi("pstsubjimper",$term)." (3e groupe)";
	} elsif ($term =~ /^(ons|ez)$/) {
	  $res .= &termi("imperseul",$term)." (3e groupe)";
	} else {

	  $res .= &termi("pstsubj",$term)." (3e groupe)";
	} 
  } elsif ($vb =~ /^choient$/) {
	$res = "choir, 3ppPSTIND, (3e groupe) ou  choyer, 3ppPST_, (1er groupe)";
  } elsif ($vb =~ /(.*)(vainc)s?$/) {
	$res = $1.$2."re, ";
	if ($vb =~ /s$/) {
	  $res .= "1/2psPSTIND/IMPER,";
	} else {
	  $res .= "3psPSTIND,";
	}
	$res .= " (3e groupe)";
  } elsif ($vb =~ /^(rec)?ouvr(es?|ent)$/) {
	$term = &termi("pst",$2);
	$res = $1."ouvrir".$term." (3e groupe) ou ".
	  $1."ouvrer".$term." (1er groupe)";
  } elsif ($vb =~ /^(press|convi)ent$/) {
	$aux = $1;
	if ($aux eq "press") {
	  $base = "pressent";
	} else {
	  $base = "conven";
	}

	$res = $base."ir".&termi("pstind","t")." (3e groupe) ou ".$aux."er".&termi("pst","ent")." (1er groupe)";
  } elsif ($vb =~ /^faille$/) {
	$res = "faillir ou falloir, 3psPSTSUBJ, (3e groupe)";
  } elsif ($vb =~ /^(guillemett)(es?|ent)$/) {
	$res = "guillemeter".&termi("pst",$2)." (1er groupe)";
  } elsif (($vb =~ /(.*)(es?|ent|i?ons|i?ez|ds|ts|x|d|t)$/)|| 
		   ($vb =~ /(.*)([^dt])(s)$/)) {
	if ($vb =~ /^(res?|ré|cir|dis)?(abs|appar|par|con|contre|entre|main|ob|sou|ad|de|inter|pré|pro|sub|sur|at)?(v|t|dét|mésav)ien(s|t)$/) {

	  $base = $1.$2.$3."ien";
	  $term = $4;
	} elsif ($vb =~ /^(res?|con|pres|dé)?(s|m|p)(en)(s|t)$/) {

	  $base = $1.$2.$3;
	  $term = $4;
	} elsif ($vb =~ /(.*)(d|t)(s)$/) {
	  $base = $1;
	  $term = $3;
	} elsif (($vb =~ /(.*)(t)$/) && ($vb !~ /ent$/)) {
	  $base = $1;
	  $term = $2;
	} elsif ($vb =~ /(.*)(es?|ent|i?ez|i?ons|d)$/) {
	  $base = $1;
	  $term = $2;
	} elsif ($vb =~ /(.*)(s|x)$/) {
	  $base = $1;
	  $term = $2;
	}
		
	$aux = $self->ortho_pst3($base,$term);
		
	$res = &infinitif($aux);

	# INFINITIF reconnait que
	# la base est du 3ème groupe:	   
		
	if ($res ne "") {
	  if (($term eq "e") &&
		  ($res =~ /(.*saill|.*couvr|.*cueuill|défaill|.*ou?ffr|.*ouvr)ir$/)) {
		$res .= &termi("pst",$term)." (3e groupe)";
	  } elsif ($term =~ /^(x|es|t|d)$/) {
		$res .= &termi("pstindseul",$term)." (3e groupe)";
	  } elsif ($term =~ /^s$/) {
		$res .= &termi("pst",$term)." (3e groupe)";
	  } elsif ($vb =~ /^(sav|peuv|.*val|veul)ent$/) {
		$res .= &termi("pstindseul","ent")." (3e groupe)";
	  } elsif ($vb =~ /^(sach|puiss|vaill|veuill)ent$/) {
		$res .= &termi("pstsubj","ent")." (3e groupe)";
	  } elsif ($term =~ /^ent$/) {
		$res .= &termi("pst",$term)." (3e groupe)";
	  } else {
		$res .= &termi("pstsubj",$term)." (3e groupe)";
	  }
	}
		
	# INFINITIF rejette l'hypothese que
	# la base soit du 3ème groupe:		
		
	else {
	  $base =~ s/e$//;
	  $res =  $self->variation_ortho1($base,$term)."er".&termi("pst",$term)." (1er groupe)"; 
	}
  }

  return $res;
}


sub est_un_participe_present_irregulier {
  my $self=shift;
  my ($mot)=@_;

  return defined $self->{"ppres_irr"}->{$mot};
}

sub normalise_participe_present_irregulier {
  my $self=shift;
  my ($mot)=@_;

  return $self->{"ppres_irr"}->{$mot};
}

sub est_un_pronom_personnel {
  my $self=shift;
  my ($mot)=@_;

  return defined $self->{"pronom_il"}->{$mot};
}

sub est_un_pronom_meme {
  my $self=shift;
  my ($mot)=@_;

  return defined $self->{"pronom_meme"}->{$mot};
}

sub normalise_pronom_meme {
  my $self=shift;
  my ($mot)=@_;

  return $self->{"pronom_meme"}->{$mot};
}


sub normalise_pronom_personnel {
  my $self=shift;
  my ($mot)=@_;

  return $self->{"pronom_il"}->{$mot};
}

sub est_un_pronom_invariable {
  my $self=shift;
  my ($mot)=@_;

  return defined $self->{"pronom_inv"}->{$mot};
}

sub normalise_pronom_invariable {
  my $self=shift;
  my ($mot)=@_;

  return $self->{"pronom_inv"}->{$mot};
}

sub est_un_determinant_ou_une_relative_invariable {
  my $self=shift;
  my ($mot)=@_;

  return defined $self->{"detrel_inv"}->{$mot};
}

sub normalise_determinant_ou_relative_invariable {
  my $self=shift;
  my ($mot)=@_;

  return $self->{"detrel_inv"}->{$mot};
}

sub lemme_ppres {
  my $self=shift;
  my ($ppres)=@_;
	
  my ($base,$base2);
  my $res_term="__";
  my $res_groupe="(3e groupe)";

  my $res="";
	
  # La terminaison = toujours ant
		
  $ppres =~ /(.*)(ant)$/;
  $base = $1.$2;
  $base2 = $1;
	
  # Cas ambigus
	
  # fondant
  if ($base =~ /^fondant$/) {
	$res = "fonder, (1er groupe) ou fondre";
  }
	
  # bruisser/bruire
  elsif ($base =~ /^bruissant$/) {
	$res = "bruisser, (1er groupe) ou bruire";
  }
	
  # (dé)peignant
  elsif ($base =~ /^(dé)?peignant$/) {
	$res = $1."peigner, (1er groupe) ou ".$1."peindre";
  }
	
  # coudant
  elsif ($base =~ /^coudant$/) {
	$res = "couder";
	$res_groupe = "(1er groupe)";
  }
	
  # nuant
  elsif ($base =~ /^nuant$/) {
	$res = "nuer";
	$res_groupe = "(1er groupe)";
  }
	
  # pâtissant
  elsif ($base =~ /^pâtissant$/) {
	$res = "pâtir (2e groupe) ou pâtisser";
	$res_groupe = "(1er groupe)";
  }
	
  # tapissant
  elsif ($base =~ /^tapissant$/) {
	$res = "tapir (2e groupe) ou tapisser";
	$res_groupe = "(1er groupe)";
  }
	
  # vernissant
  elsif ($base =~ /^vernissant$/) {
	$res = "vernir (2e groupe) ou vernisser";
	$res_groupe = "(1er groupe)";
  }
	
  # moulant
  elsif ($base =~ /^(re|dé)?moulant$/) {
	$res = $1."mouler (1er groupe) ou ".$1."moudre";
  }
	
  # venant
  elsif ($base =~ /^venant$/) {
	$res = "vener (1er groupe) ou venir";
  }
	
  # ouvrant
  elsif ($base =~ /^(rec)?ouvrant$/) {
	$res = $1."ouvrer (1er groupe) ou ".$1."ouvrir";
  }
	
  # 3eme groupe:
	
  elsif ($self->est_un_participe_present_irregulier($base)) {
	$res = $self->normalise_participe_present_irregulier($base);
  } elsif ($self->est_une_exception($base2,"V_iss")) {
	$res = $base2."er";
	$res_groupe = "(1er groupe)";
  }
	
  # Connaître, paître, croître ...
	
  elsif ($base =~ /(.*)(a|o)issant$/) {
	$res = $1.$2."ître";
  }
	
  # voir, fuir 
  elsif ($base =~ /^(re)?(entre|pour|dépour|pré)?(vo|enfu|fu)yant$/) {
	$res = $1.$2.$3."ir";
  }

  # croire, traire
  elsif ($base =~ /(.*)(cro|tra)yant$/) {
	$res = $1.$2."ire";
  }
	
  # asseoir
  elsif ($base =~ /^(r?as|sur|mes)?(s)(oy|ey|é)ant$/) {
	$res = $1.$2."eoir";
  }
	
  # échoir
  elsif ($base =~ /(.*)(ch)éant$/) {
	$res = $1.$2."oir";
  }	 
	
  # peindre, craindre, joindre (vs 'enseigner')
  elsif ($base =~ /(.*)([aeo])ignant$/) {
	$base2 = $1.$2;
	if ($self->est_une_exception($base2."ign","V_ign")) {
	  $res = $base2."igner";
	  $res_groupe = "(1er groupe)";
	} else {
	  $res = $base2."indre";
	}
  }

  # prendre
  elsif ($base =~ /(.*)(pren)ant$/) {
	$res = $1.$2."dre";
  }
	
  # vaincre
  elsif ($base =~ /(.*)(vain)quant$/) {
	$res = $1.$2."cre";
  }

  # faire, plaire
  elsif ($base =~ /(.*fai|.*plai|^tai)sant$/) {
	$res = $1."re";
  }
	
  # boire
  elsif ($base =~ /(.*)buvant$/) {
	$res = $1."boire";
  }
	
  # clore
  elsif ($base =~ /(.*)closant$/) {
	$res = $1."clore";
  }
	
  # coudre
  elsif ($base =~ /(.*)cousant$/) {
	$res = $1."coudre";
  }

  # moudre
  elsif ($base =~ /^(é|re)?moulant$/) {
	$res = $1."moudre";
  }

  # soudre
  elsif ($base =~ /(.*)solvant$/) {
	$res = $1."soudre";
  }

  # lire, écrire, dire, confire, cuire
  elsif ($base =~ /^(non-)?(re|ré|rée|cir)?(dé|mé)?(ad|pres|entre|pros?|trans|contre|inter|mau|pré|intro|sur|cons?|ins?|tra|sé|sous)?(lu|du|endu|nu|cu|tru|é?l|d|é?cr|conf|circonc|suff)i(s|v)ant$/) {
	$res = $1.$2.$3.$4.$5."ire";
  }

  # rire
  elsif ( $base =~ /^(sou)?(r)iant$/) {
	$res = $1.$2."ire";
  } else {
		
	# 3eme groupe ? :
		
	$res =	&infinitif($base2);
		
	# 2eme groupe ?:

	if ($res eq "") {
	  if ($base =~ /(.*)(ï|i)ssant$/) {
		$res = $1.$2."r";
		$res_groupe = "(2e groupe)";
	  }
			
	  # 1er groupe ?:
	  else {
		$res_groupe= "(1er groupe)";
		if ($base =~ /(.*)(g)eant$/) {
		  $res = $1.$2."er";
		} elsif ($base =~ /(.*)çant$/) {
		  $res = $1."cer";
		} else {
		  $base =~ /(.*)ant$/;
		  $res = $1."er";
		}
	  }
	}
  }
	
  $res .= ":".$res_term.":".$res_groupe;
	
  return $res;
}

sub lemme_detrel {
  my $self=shift;
  my ($det,$etiq)=@_;

  my ($base,$term1,$term2);

  my $nb;
  my $res="";

  if ($det =~ /^(quel)?(qu)\'?$/) {
	$det = $1.$2."e";
  }
	
  #Cas Invariables
	
  if ($self->est_un_determinant_ou_une_relative_invariable($det)) {
	$res = $det." ".$self->normalise_determinant_ou_relative_invariable($det);
  } elsif (($det eq "des")&&($etiq =~ /(DTC|PRP:det)$/)) {
	$res = "du _p";
  } elsif ($det eq "des") {
	$res = "un _p";
  }

  # LE/LEQUEL
	
  elsif ($det =~ /^(l\'?|les|la|le)(quel)?(le|les|s)?$/) {
	$res = "le".$2;
	$term1 = $1;
	$term2 = $3;
		
	if ($term1 =~ /a/) {
	  $res .= " fs";
	} elsif ($term1 =~ /^l\'?$/) {
	  $res .= " _s";
	} elsif ($term1 =~ /e$/) {
	  $res .= " ms";
	} elsif ($term1 =~ /es$/) {
	  if (!defined ($term2)) {
		$res .= " _p";
	  } elsif ($term2 =~ /^s$/) {
		$res .= " mp";
	  } else {
		$res .= " fp";
	  }
	}
  }

  # AU/DU/

  elsif ($det =~ /^(d|a)(u|ux)$/) {
	$res = $1."u";
	$term1 = $2;
	if ($term1 =~ /x$/) {
	  $res .= " _p";
	} else {
	  $res .= " ms";
	}
  }
	
  # UN
	
  elsif ($det =~ /^(un|une)$/) {
	$res = "un";
	if ($res =~ /e$/) {
	  $res .= " fs";
	} else {
	  $res .= " ms";
	}
  }
	
  #AUQUEL/DUQUEL/*QUEL
	
  elsif ($det =~ /([^(d|du|au)]*)(du?|au)?(x|es)?(quel)(le|s|les)$/) {
	$res = $1.$2.$4;
	$term1 = $5;
	if ($det =~ /^desq/) {
	  $res = "duquel";
	}
	if (!defined($term1)) {
	  $res .= " ms";
	} elsif ($term1 =~ /le$/) {
	  $res .= " fs";
	} elsif ($term1 =~ /^s$/) {
	  $res .= " mp";
	} else {
	  $res .= " fp";
	}
  }
	
  # CE
	
  elsif ($det =~ /^(ce)(t|s|tte|ttes)?$/) {
	$res = $1;
	$term1 = $2;
	if ((!defined($term1))||($term1 =~ /^t$/)) {
	  $res .= " ms";
	} elsif ($term1 =~ /tte$/) {
	  $res .= " fs";
	} elsif ($term1 =~ /^s$/) {
	  $res .= " mp";
	} else {
	  $res .= " fp";
	}
  }
	
  # MON/TON/SON
	
  elsif ($det =~ /^(m|t|s)(on|a|es)$/) {
	$res = $1."on";
	$term1 = $2;
	if ($term1 =~ /on/) {
	  $res .= " ms";
	} elsif ($term1 =~ /a$/) {
	  $res .= " fs";
	} else {
	  $res .= " _p";
	}
  }
	
  # NOTRE/VOTRE
	
  elsif ($det =~ /^(n|v)(otre|os)$/) {
	$res = $1."otre";
	$term1 = $2;
	if ($term1 =~ /os/) {
	  $res .= " _p";
	} else {
	  $res .= " _s";
	}
  }
	
  # LEUR/QUELQUE
	
  elsif ($det =~ /^(leur|quelque|quelque)(s)?$/) {
	$res = $1;
	$term1 = $2;
	if (!defined($term1)) {
	  $res .= " _s";
	} else {
	  $res .= " _p";
	}
  }
	
  # MIEN/TIEN/SIEN/TEL/NUL (aussi sur les pros)
	
  elsif ($det =~ /^(mien|tien|sien|tel|nul)[ln]e?s?$/) {
		
	$res = $1;
	$term1 = " ms";
		
	if ($det =~ /es$/) {
	  $term1 = " fp";
	} elsif ($det =~ /s$/) {
	  $term1 = " mp";
	} elsif ($det =~ /e$/) {
	  $term1 = " fs";
	}
	$res .= $term1;
  }
	
  # Les autres partie du discours assimilables a des adj:
	
  # feminin
	
  elsif ($det =~ /(.*)es?$/) {
	$res = $1;
	$term1 = " fs";
		
	if ($det =~ /s$/) {
	  $term1 = " fp";
	}
	$res .= $term1;
  }
	
  # masculin pluriel
	
  elsif ($det =~ /(.*)s$/) {
		
	$res = $1;
	$term1 = " mp";
		
	if ($det eq "tous") {
	  $res = "tout";
	}
	$res .= $term1;
		
  }
	
  # masculin singulier
	
  else {
	$res = $det." ms";
  }
	
  return $res;
}


# Cas morphologique des pronoms : n(ominatif), a(ccusatif) o(blique) d(atif)
# et les disjonctions autorisees : M = n/d/o, R = a/d, S = a/o, T = d/o, U = a/d/o


sub lemme_pro {
  my $self=shift;
  my ($pro) = @_;

  my ($base,$term,$per,$nb,$ge);

  my $res="";
	
  # Cas Invariables
	
  if ($pro =~ /^(.*qu)\'?$/) {
	$pro = $1."e";
  } elsif ($pro =~ /^(j|t|s|m|c)\'?$/) {
	$pro = $1."e";
  }

  if ($self->est_un_pronom_invariable($pro)) {
	$res = $pro." ".$self->normalise_pronom_invariable($pro);
  } 
  elsif ($self->est_un_pronom_personnel($pro)) {
	$res = $self->normalise_pronom_personnel($pro);
  } 
 elsif ($self->est_un_pronom_meme($pro)) {
	$res = $self->normalise_pronom_meme($pro);
  } 
	
  # ENTR'ELLES/ENTRE-ELLES

  elsif ($pro =~ /^entr(e-|\')(nous|vous|eux|elles)$/) {
	$res = "entre-soi ";

	$nb = "3mpo";

	if ($pro =~ /nous/) {
	  $nb = "1_po";
	} elsif ($pro =~ /vous/) {
	  $nb = "2_po";
	} elsif ($pro =~ /elles/) {
	  $nb = "3fpo";
	}

	$res .= $nb;
  }

  # CE
	
  elsif ($pro =~ /^ce$/) {
	$res = "ce 3msn";
	
  } 
  elsif ($pro =~ /^cette$/) {
	$res = "ce 3fsn";
  } 
  elsif ($pro =~ /^ces$/) {
	$res = "ce 3_pn";
  } 
  elsif ($pro =~ /^(ça|ç\'?)$/) {
	$res = "ça 3_s_";
  }
	
  # CELUI
	
  elsif ($pro =~ /^(celui|celle|ceux|celles)(-ci|-là)?$/) {
	$res = "celui".$2." 3";
	$nb = "ms";
	if ($pro =~ /x(-ci|-là)?$/) {
	  $nb = "mp";
	} elsif ($pro =~ /s(-ci|-là)?$/) {
	  $nb = "fp";
	} elsif ($pro =~ /e(-ci|-là)?$/) {
	  $nb = "fs";
	}
	$res .= $nb."_";
  }

  # LE MÊME/AUTRE/NOTRE/VOTRE/LEUR
	
  elsif ($pro =~ /^(même|autre|nôtre|vôtre|leur)(s)?$/) {
	$res = $1;
	$nb = $2;
		
	if (!defined($nb)) {
	  $res .= " 3_s_";
	} else {
	  $res .= " 3_p_";
	}
  }
	
  # MIEN/TIEN/SIEN/TEL/NUL (aussi sur les dets)
	
  elsif ($pro =~ /^(mien|tien|sien|tel|nul|quel)[ln]e?s?$/) {
	$res = $1." 3";
	$nb = "ms";
		
	if ($pro =~ /es$/) {
	  $nb = "fp";
	} elsif ($pro =~ /s$/) {
	  $nb = "mp";
	} elsif ($pro =~ /e$/) {
	  $nb = "fs";
	}
	$res .= $nb."_";
  }
	
  # QUELQU'UN
	
  elsif ($pro =~ /^(quelques|quelqu)[\' -](un|une|unes|uns)$/) {
	$res = "quelqu\'un";

	$nb = " 3ms";
		
	if ($pro =~ /es$/) { 
	  $nb = " 3fp";		} elsif ($pro =~ /s$/) { 
	  $nb = " 3mp"; 
	} elsif ($pro =~ /e$/) { 
	  $nb = " 3fs"; 
	} 
	$res .= $nb."_"; 
  } 
	

	# Les autres partie du discours assimilables a des adj:
	# feminin
	
	elsif ($pro =~ /(.*)es?$/) { 
		
		$res = $1; 
		$nb = " 3fs"; 
		
		if ($pro =~ /s$/) { 
			$nb = " 3fp"; 
		} 
		$res .= $nb."_"; 
	} 
	
	# masculin pluriel 
	
	elsif ($pro =~ /(.*)s$/) { 
		 
		$res = $1; 
		$nb = " 3mp"; 
		
		if ($pro eq "tous") { 
			$res = "tout"; 
		} 
		$res .= $nb."_"; 
		
	} 
	 
	# masculin singulier 
	
	else  { 
		$res = $pro." 3ms_"; 
	} 
	
  #print "PRONOM : $pro $res\n";
	return $res; 
} 

sub lemme_nom { 
	my $self=shift; 
	my ($nom) = @_; 
 
	my ($base,$aux); 
	my $res_nb=" p"; 
	my $res=""; 
	
	# Cas particuliers 
	
	if ($nom eq "aulx") { 
		$res = "ail m"; 
	}
	elsif ($nom =~ /(.*)([\' ])?yeux$/) { 
		$res = $1.$2."oeil m";
	 }
	 elsif ($nom =~ /^(Mr|M\.?)$/) {
		$res = "monsieur m"; 
		$res_nb = " s"; 
	}
	elsif ($nom =~ /^(Mrs|MM|messieurs)$/) { 
		$res = "monsieur m"; 
	}
	elsif ($nom =~ /^Mme$/) { 
		$res = "madame f"; 
		$res_nb = " s"; 
	}
	elsif ($nom =~ /^Mes?$/) { 
		$res = "maître m"; 
		if ($nom =~ /s$/) { 
			$res_nb = " p"; 
		} 
		else { 
			$res_nb = " s"; 
		} 
	} 
	elsif ($nom =~ /^(Mmes|mesdames)$/) { 
		$res = "madame f"; 
	} 
	elsif ($nom =~ /^Mlle$/) { 
		$res = "mademoiselle f"; 
		$res_nb = " s"; 
	} 
	elsif ($nom =~ /^(Mlles|mesdemoiselles)$/) { 
		$res = "mademoiselle f"; 
	} 
	elsif ($nom =~ /(.*)([\' ])?cieux/) { 
		$res = $1.$2."ciel m"; 
	} 
	elsif ($nom =~ /(.*)([\' ])?aïeux/) { 
		$res = $1.$2."aïeul m"; 
	} 
	elsif ($nom eq "universaux") { 
		$res = "universel m"; 
	} 
	elsif ($nom eq "matériaux") { 
		$res = "matériel m"; 
	} 
	elsif ($nom eq "matches") { 
		$res = "match m"; 
	} 
	elsif ($nom eq "royalties") { 
		$res = "royalty f"; 
	} 
	elsif ($nom eq "blues") { 
		$res = "blues m"; 
		$res_nb = " s"; 
	} 
	elsif ($nom eq "fils") { 
		$res = "fil:mp,ou,fils m"; 
		$res_nb = " _"; 
	} 
	elsif ($nom eq "fois") { 
		$res = "foi:fp,ou,fois m"; 
		$res_nb = " _"; 
	} 
	elsif ($nom eq "fonds") { 
		$res = "fond:mp,ou,fonds m";
		$res_nb = " _";
	}
	elsif ($nom eq "cours") {
		$res = "cour:fp,ou,cours m";
		$res_nb = " _";
	}
	elsif ($nom	 =~ /(.*)-fils$/) {
		$res = $1."fils m";
		$res_nb = " _";
	}
	elsif ($nom	 =~ /^(moins|plus|mieux)$/) {
		$res = $1." m";
		$res_nb = " _";
	}
	
	# Noms terminés par -x
	# ====================
	
	# Invariables : -*x (* different de u, cf. plus bas), -z
	
	elsif ($nom =~ /([^u]x|z)$/) {
		$res = $nom." _";
		$res_nb = " _";
	}
	
	# Pluriel en "eaux", singulier en "eau"
	
	elsif ($nom =~ /(.*)(eau)x$/) {
		$res = $1.$2." _";
	}
	
	# Pluriel en "Xaux",  X different de "e"
	
	elsif ($nom =~ /(.*)(aux)$/) {
		$base=$1;
		
		if ($self->est_une_exception($nom,"N_aux")) {
			$res = $nom." m";
			$res_nb = " _";
		}						
		
		elsif ($self->est_une_exception($base,"N_aux2au")) {
			$res = $base."au m";
		}
		
		elsif ($self->est_une_exception($base,"N_aux2ail")) {
			$res = $base."ail m";
		}
		else {
			$res = $1."al m";
		}
	}

	# Pluriel en "eux". La plupart des noms en -eux sont invariables 
	# en nombre, sauf une liste qui correspond à un masculin pluriel.

	elsif ($nom =~ /(.*)(eux)$/) {
		$base=$1;
		 
		if ($self->est_une_exception($base."eu","N_eux")) {
			$res = $base."eu m";
			$res_nb = " p";
		}						
		else {
			$res = $nom." m";
			$res_nb = " _";
		}
	}

	# Pluriel en "oux"

	elsif ($nom =~ /(.*)(oux)$/) {
		$base=$1."ou";
		if ($self->est_une_exception($base,"N_oux2ou")) {
			$res = $base." m";
		}						
		else {
			$res = $nom." m";
			$res_nb = " _";
		}
	}

	# Tous les autres pluriels en "ux" sont 
	# de nombre indéterminé

	elsif ($nom =~ /(.*)ux$/) {
		$res=$nom." _";
		$res_nb = " _";
	}

	# Tous les autres pluriels en "x"  sont 
	# de nombre pluriel

	elsif ($nom =~ /(.*)x$/) {
		$res=$nom." _";
	}

# Noms terminés par -s
# ====================

	# Terminaison en ous

	elsif ($nom =~ /(.*)ous$/)	{
		$base = $1."ou";
		if ($self->est_une_exception($nom,"N_ous")) {
			$res=$nom." _";
			$res_nb = " _";
		}
		else {
			$res=$base." _";
		}
	}

	# Terminaison en -aus / -eus

	elsif ($nom =~ /(.*)([ae])us$/)	 {
		$base = $1.$2."u";
		
		if ($self->est_une_exception($nom,"N_aeus")) {	
			$res=$nom." _";
			$res_nb = " _";
		}
		else {
			$res=$base." _";
		}
	}

	# Terminaison en as 

	elsif ($nom =~ /(.*)as$/)  {
		$base = $1."a";
		
		if ($self->est_une_exception($nom,"N_as")) {
			$res= $nom." _";
			 $res_nb = " _";
		}
		else {
			$res=$base." _";
		}
	}

	# Terminaison en os

	elsif ($nom =~ /(.*)os$/)  {
		$base = $1."o";
		
		if ($self->est_une_exception($nom,"N_os")) {
			$res=$nom." _";
			$res_nb = " _";
		}
		else {
			$res=$base." _";
		}
	}

	# Pluriel en "ys"

	elsif ($nom =~ /(.*)(ys)$/) {
		$base=$1."y";
		
		if ($self->est_une_exception($nom,"N_ys") == 1) {
			$res = $nom." m";
			$res_nb = " _";
		}						
		else {
			$res = $base." m";
		}
	}

	# Terminaison en -ès, -és, -ês, -âs, -ôs, -ïs

	elsif  ($nom =~ /(.*)[èêâôï]s$/)  {
		$res=$nom." _";
		$res_nb = " _";
	}

# Noms se terminant par is, ies, i, us, ues, u
# ============================================

	# Terminaisons en is, ies, i

	# Exceptions feminin

	elsif ($nom =~ /^(ra|l|part|ba)ies?$/) {
		$res = $1."ie f";
		if ($nom =~ /s$/) {
			$res_nb = " p";
		}
		else {
			$res_nb = " s";
		}
	}	 
	
	# Si le nom est en -ies ou -is ou -ie ou -i
	
	elsif  ($nom =~ /(.*)ie?s?$/)  {
		$base = $1."i";
		
		# Le nom est en i(e)s et fait son singulier en i
		
		if ($self->est_une_exception($base,"N_is2i")==1) {
			$res=$base;
			if ($nom =~ /es$/) {
				$res .= " f";
			}
			elsif ($nom =~ /s$/) {
				$res .= " m";
			}
			elsif ($nom =~ /e$/) {
				$res .= " f";
				$res_nb = " s";
			} 
			else {
				$res .= " m";
				$res_nb = " s";
			}
		}
		
		# Le nom est en -ies, son singulier -ie est de genre intedermine
		
		elsif ($nom =~/(.*)es$/) {
			$res=$base."e _";
		}
		elsif ($nom =~/(.*)e$/) {
			$res=$base."e _";
			$res_nb = " s";
		}
		
		# Le nom est en -is, de genre et nombre intedermines
		
		else {
			$res=$nom." _";
			$res_nb = " _";
		}
	}
	
	# Noms se terminant pas u, us, ues
	
	elsif  ($nom =~ /(.*)([qg])ues?$/)	{
		$res = $1.$2."ue _";
		if ($nom =~ /e$/) {
			$res_nb = " s";
		}
	}
	
	elsif ($nom =~ /ambigus$/) {
		$res = $nom." m";
	}
	
	elsif  ($nom =~ /(^us|pus|reclus|(.*)gus)$/)  {
		$res = $nom." m";
		$res_nb = " _";
	}

	elsif  ($nom =~ /(.*)([^aeoqg])ue?s?$/)	 {
		
		$base = $1.$2."u";
		
		# Les exceptions au feminin
		
		if ($nom =~ /^(.*vu|(re)?tenu|ru|étendu|venu|battu)es?$/) {
			$res = $base."e f";
			if ($nom =~/e$/) {
				$res_nb = " s";
			}
		}
		
		# Les noms en us dont le singulier est u
		
		elsif (($nom =~ /us$/) &&
		   ($self->est_une_exception($base,"N_us2u")==1)) {
			$res=$base." _";
		}	   

		# Les noms en us/ues 
		
		else {
			
			# Est-il derive de participe passe de la 3eme conjugaison ?
			
			$res = $self->lemme_ppast($nom);
			$res =~ s/:..$//;
			
			if ($res =~ /(.*)(oir|ire)$/) {
				$aux = $1;
			}
			elsif ($res =~ /(.*)(.)(ir|re)$/) {
				$aux = $1.$2;
			}
			else {
				$aux =	"";
			}
			
			# Si oui, il a un genre et un nombre
			
			if (($aux ne "") && (&infinitif($aux) ne "")) {
				
				$res = $base;
				if ($nom =~ /es$/) {
					$res .= " f";
				}
				elsif ($nom =~ /e$/) {
					$res .= " f";
					$res_nb = " s";
				}
				elsif ($nom =~ /s$/) {
					$res .= " m";
				}
				else {
					$res .= " m";
					$res_nb = " s";
				}
			}
			
			# Si non, s'il est en -us, c'est un masculin invariable
			
			elsif ($nom =~ /us$/) {
				$res = $nom." m";
				$res_nb = " _";
			}
			
			# Si non, s'il est en -u, c'est un masculin singulier
			
			elsif ($nom =~ /u$/) {
				$res = $nom." m";
				$res_nb = " s";
			}

			# Si non, s'il est en -ue, c'est un féminin singulier
			
			elsif ($nom =~ /ue$/) {
				$res = $nom." f";
				$res_nb = " s";
			}
			
			# Si non, il est en -ues, c'est un pluriel de genre indetermine.
			
									 else {
									   $res=$base."e _";
									 }
								   }
	   }
	
	# Noms féminins dérivés d'un nom masculin
	# ========================================
	
	# Terminaison en -ée, -ées: noms féminin et féminin-pluriel de noms en -é,
	# ou noms en -ée de genre indéterminé ?
	
	elsif ($nom =~ /(.*)(é)es?$/) {
	  $base = $1.$2;


	  # On indique le genre, sans générer une base masculine

	  if ($self->est_une_exception($base,"N_ee2e") == 1) {
		$res=$base."e f";
	  } else {
		$res=$base."e _";
	  }
		
	  if ($nom =~ /e$/) {
		$res_nb = " s";
	  }
	}
	
  # Terminaison en -oresse(s), -eresse(s) : féminin et pluriel des noms en -eur:
	
  elsif ($nom =~ /(.*)([oe]resse)s?$/) {
	   
		
	# On indique le genre, sans générer une base masculine
	$res = $1.$2." f";
		
	if ($nom =~ /e$/) {
	  $res_nb = " s";
	}
		
  }								
	
  # Terminaison en -trice(s) : féminin et pluriel des noms en -eur:
	
  elsif ($nom =~ /(.*)(trice)s?$/) { 
		
	# On indique le genre, sans générer une base masculine
	$res = $1.$2." f";
		
	if ($nom =~ /e$/) {
	  $res_nb = " s";
	}
		
  }
	
  # Terminaison en -euse(s) : féminin et pluriel des noms en -eur/-eux:
	
  elsif ($nom =~ /(.*)(euse)s?$/) {

	# On indique le genre, sans générer une base masculine		
	$res = $1.$2." f";

	if ($nom =~ /e$/) {
	  $res_nb = " s";
	}
  }		 

  # Terminaison en -ière(s) : féminin et pluriel des noms en -ier,
  # Ou genre indéterminé ?
	
  elsif ($nom =~ /(.*)(ière)s?$/) {
	$base = $1;
		
	# On indique le genre, sans générer une base masculine		

	if ($self->est_une_exception($base,"N_iere2ier")==1) {
	  $res = $base."ière f";
	} else {
	  $res = $base."ière _";
	}
	if ($nom =~ /e$/) {
	  $res_nb = " s";
	}
  }						
	
  # Autres noms terminés par -s
  # ===========================
	
  elsif ($nom =~ /^s$/) {
	$res = $nom." _";
	$res_nb = " _";
  }
	
  # Cas des noms finissant par -<consonne>s
	
  elsif ($nom =~ /(.*)s$/) {
	$base = $1;

	if (($base =~ /s$/)||
		($self->est_une_exception($nom,"N_Cs")==1)) {
	  $res = $nom." _";
	  $res_nb = " _";
	} else {
	  $res = $base." _";
	}
  } else {
	$res = $nom." _";	
	$res_nb = " s";		
  }
	
	
  # Genre indéterminé (X) si le féminin/masculin n'est pas attesté
  if ($res !~ /^(.*) [fm_]$/) {
	$res = $1." X";
  }
	
  # On ajoute le nombre, par defaut pluriel.
	
  $res .= $res_nb;
	
  # On reformate le resultat.
	
  $res =~ s/ ([fm_X]) ([sp_])$/:$1$2/;

  return $res;
}

sub lemme_ppast {
  my $self=shift;
  my ($ppast) = @_;

  my($base);
  my $res_term="ms";
  my $res="";
	
  # La terminaison

  if ($ppast =~	 /.*es$/) {
	$res_term = "fp";
  } elsif ($ppast =~  /.*s$/) {
	$res_term = "mp";
  } elsif ($ppast =~  /.*e$/) {
	$res_term = "fs";
  }

  # Participes irréguliers

  if ($ppast =~ /^(né)e?s?$/) {
	$res = "naître";
  } elsif ($ppast =~ /^repue?s?$/) {
	$res = "repaître";
  } elsif ($ppast =~ /^(.*)fichue?s?$/) {
	$res = $1."fiche";
  } elsif ($ppast =~ /^(eu)e?s?$/) {
	$res = "avoir";
  } elsif ($ppast =~ /^été$/) {
	$res = "être";
  } elsif ($ppast =~ /^(occ|circonc)ise?s?$/) {
	$res = $1."ire";
	if ($ppast =~  /is$/) {
	  $res_term = "m_";
	}
  } elsif ($ppast =~ /^(bén)ite?s?$/) {
	$res = $1."ir";
  } elsif ($ppast =~ /^(tis)sue?s?$/) {
	$res = $1."tre";
  }

  # Participes en "é"

  elsif ($ppast =~ /(.*)ée?s?$/) {
	$res = $1."er";
  }

  # Participes en "os"

  elsif ($ppast =~ /^(ré|re)?(for|dé|é|en)?close?s?$/) {
	$res = $1.$2."clore";
	if ($ppast =~  /os$/) {
	  $res_term = "m_";
	}
  }

  # Participes en "it"

  elsif ($ppast =~ /^(-)?(ré|re|ré|entre)?(é|contre|dé|inter|mé|pré|ma[lu]|ins?|circons|pres|pros?|trans|sous|en|intro|tra|sé|for|par|satis|sur|abs|dis|ex|ad)?(d|cr|conf|cu|cond|du|fr|constru|tru|fa|tra)ite?s?$/) {
	$res = $1.$2.$3.$4."ire";	 
  }								
  
  # Participes en "i(s)"

  elsif ($ppast =~ /^(re|entre-?)?(suff|lu|nu)ie?s?$/) {
	$res = $1.$2."ire";
  } elsif ($ppast =~ /^(en|pour)?(suiv)ie?s?$/) {
	$res = $1.$2."re";
  } elsif ($ppast =~ /(.*)(qu)ise?s?$/) {
	$res = $1.$2."érir";
	if ($ppast =~  /is$/) {
	  $res_term = "m_";
	}
  } elsif ($ppast =~ /^(r)?(ass|surs|s)ise?s?$/) {
	$res = $1.$2."eoir";
	if ($ppast =~  /is$/) {
	  $res_term = "m_";
	}
  } elsif ($ppast =~ /(.*)(pr)ise?s?$/) {
	$res = $1.$2."endre";
	if ($ppast =~  /is$/) {
	  $res_term = "m_";
	}
  } elsif ($ppast =~ /^(ré|com|re)?(ad|com|pro|d?é|entre|o|per|trans|sou)?(m)ise?s?$/) {
	$res = $1.$2."mettre";
	if ($ppast =~  /is$/) {
	  $res_term = "m_";
	}
  } elsif ($ppast =~ /^(sou)?(ri)$/) {
	$res = $1.$2."re";
  } elsif ($ppast =~ /(.*)ïe?s?$/) {
	$res = $1."ïr";
  } elsif ($ppast =~ /(.*)i(s|e|es)?$/) {
	$res = $1."ir";
	$base = $1;
	if ($2 =~ /^s$/) {
	  if (&base_en_ir($base)) {
		$res_term = "m_";
	  } else {
		$res_term = "mp";
	  }
				
	}
  }
		

  # Participes en "ous/oute(s)" 

  elsif ($ppast =~ /(.*)(sou)(s|te|tes)$/) {
	$res = $1.$2."dre";
	if ($ppast =~  /us$/) {
	  $res_term = "m_";
	}
  }

  # variante
  elsif ($ppast =~ /(réso|abso|disso)lue?s?$/) {
	$res = $1."udre";
  }

  # Participes en "t(es)"
	
  elsif ($ppast =~ /^morte?s?$/) {
	$res = "mourir";
  } elsif ($ppast =~ /(.*)erte?s?$/) {
	$res = $1."rir";
  } elsif ($ppast =~ /(.*)(e|a|o)(in)te?s?$/) {
	$res = $1.$2.$3."dre";
  } elsif ($ppast =~ /(.*)te?s?$/) {
	$res = $1."re";
  }

  # Participes en "u(es)"

  elsif ($ppast =~ /(.*)(vainc|batt|end|ond|and|erd|ord|out|romp)ue?s?$/) {
	$res = $1.$2."re";
  } elsif ($ppast =~ /(.*)(clu)s?e?s?$/) {
	$res = $1.$2."re";
  } elsif ($ppast =~ /(.*)(fall|val|voul|ch)ue?s?$/) {
	$res = $1.$2."oir";
  } elsif ($ppast =~ /(.*)(conn|par)ue?s?$/) {
	$res = $1.$2."aître";
  } elsif ($ppast =~ /(.*)(cou|mou)(s|l)ue?s?$/) {
	$res = $1.$2."dre";
  } elsif ($ppast =~ /(.*)(réso|disso)lue?s?$/) {
	$res = $1.$2."udre";
  } elsif ($ppast =~ /(.*)çue?s?$/) {
	$res = $1."cevoir";
  } elsif ($ppast =~ /^(re)?plu(es?|e?s)$/) {
	$res = $1."plaire";
  } elsif ($ppast =~ /^(re)?plu$/) {
	$res = $1."pleuvoir ou ".$1."plaire";
  } elsif ($ppast =~ /^(compl|dépl|t)ue?s?$/) {
	$res = $1.$2."aire";
  } elsif ($ppast =~ /(.*)vécue?s?$/) {
	$res = $1."vivre";
  } elsif ($ppast =~ /(.*v)ue?s?$/) {
	$res = $1."oir";
  } elsif ($ppast =~ /(.*m|^p)(û|u)e?s?$/) {
	$res = $1."ouvoir";
  } elsif ($ppast =~ /^(re)?sue?s?$/) {
	$res = $1."savoir";
  } elsif ($ppast =~ /^(ac|dé|re|sur)(cr)ue?s?$/) {
	$res = $1.$2."oître";
  } elsif ($ppast =~ /^(.*ac|.*em)?(b|cr)ue?s?$/) {
	$res = $1.$2."oire";
  } elsif ($ppast =~ /^(.*é|.*re)?(l)ue?s?$/) {
	$res = $1.$2."ire";
  } elsif ($ppast =~ /^(.*re)?(d)(û|ues?|us)/) {
	$res = $1.$2."evoir";
  } elsif ($ppast =~ /^(re)?(cr)ûe?s?/) {
	$res = $1.$2."oître";
  } else {
	$ppast =~ /(.*)ue?s?/;
	$res = $1."ir";
  }

  $res .= ":".$res_term;
	
  return $res;
}
		
sub lemme_adj {
  my $self=shift;
  my ($adj)=@_;

  my ($base_adj,$base);
  my $res_nb=" s";
  my $res="";

  # Cas particuliers

  if ($adj =~ /(.*)fraîches?$/) {
	$res = $1."frais f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  } elsif ($adj =~ /^(marin)e$/) {
	$res = $1."e:__ ou ".$1." f";
	$res_nb = " s";
  }
  # Doit-on garder ca ?

  elsif ($adj =~ /^salvatrices?$/) {
	$res = "salvateur ou sauveur f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  } elsif ($adj =~ /(.*)sèches?$/) {
	$res = $1."sec f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  } elsif ($adj =~ /(.*)(bl|fr)anches?$/) {
	$res = $1.$2."anc f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  } elsif ($adj =~ /^(nouv|b|jum)(e)l(le)?s?$/) {
	$res = $1.$2."au";
	if ($adj =~ /les?$/) {
	  $res .= " f";
	} else {
	  $res .= " m";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  } elsif ($adj =~ /^(vi)(eux|eil|eille|eilles)$/) {
	$res = $1."eux";
	if ($adj =~ /les?$/) {
	  $res .= " f";
	} else {
	  $res .= " m";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	} elsif ($adj =~ /x$/) {
	  $res_nb = " _";
	}
  } elsif ($adj =~ /^(neu|veu)(v)es?$/) {
	$res = $1."f f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  } elsif ($adj =~ /^(.*-)?(m|f)ol(le)?s?$/) {
	$res = $1.$2."ou ";
	$base = $3;
	if (defined($base)) {
	  $res .= "f";
	} else {
	  $res .= "m";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  } elsif ($adj =~ /^(andalou)ses?$/) {
	$res = $1." f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  } elsif ($adj =~ /(.*)(long)ues?$/) {
	$res = $1.$2." f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  } elsif ($adj =~ /^tous$/) {
	$res = "tout m";
	$res_nb = " p";
  } elsif ($adj =~ /^(tiers|divers|pervers)$/) {
	$res = $adj." m";
	$res_nb = " p";
  } elsif ($adj =~ /(.*)grecques?$/) {
	$res = $1."grec f";
	if ($adj =~/s$/) {
	  $res_nb = " p";
	}
  } elsif ($adj =~ /(favori)tes?$/) {
	$res = $1." f";
	if ($adj =~/s$/) {
	  $res_nb = " p";
	}
  } elsif ($adj =~ /(.*)(cadu|publi|tur|fran)ques?$/) {
	$res = $1.$2."c f";
	if ($adj =~/s$/) {
	  $res_nb = " p";
	}
  }

  # Adjectif terminés par -x
  # =========================
	
  # Adjectifs terminés par -eaux -> eau, mp
	
  elsif ($adj =~ /(.*)eaux$/) {
	$res = $1."eau m";
	$res_nb = " p";
  }
	
  # Adjectifs terminés par -aux:
  # aux -> aux,
  # aux -> al

  elsif ($adj =~ /(.*)aux$/) {
	$base = $1;
	if ($adj =~ /^(déch|f|préjudici|pénitenti|quadrijum|sapienti)aux$/) {
	  $res = $adj." m";
	  $res_nb = " _";
	} else {
	  $res = $base."al m";
	  $res_nb = " p";
	}
  }
	
  # Adjectifs terminés par -eux: invariables en nombre (sauf feu, hébreu)
	
  elsif ($adj =~ /(.*)eux$/) {
	$base = $1;
	if ($base =~ /^(f|hébr)$/) {
	  $res = $base."eu m";
	  $res_nb = " p";
	} else {
	  $res = $1."eux m";
	  $res_nb = " _";
	}
  }
   
  # Adjectifs terminés par -oux: invariables en nombre (sauf andalou)
	
  elsif ($adj =~ /(.*)oux$/) {
	$base = $1;
	if ($base =~ /^(andal)$/) {
	  $res = $base."ou m";
	  $res_nb = " p";
	} else {
	  $res = $1."oux m";
	  $res_nb = " _";
	}
  }

	
  # Adjectifs terminés par -is, -as, -os, -us
  # ==========================================
	
  # Deux classes d'adjectifs termines par -is

  elsif ($adj =~ /(.*)([^oa])is$/) {
	$base_adj = $1.$2."i";

	if ($self->est_une_exception($adj,"A_is") == 1) {
	  $res = $adj." m";
	  $res_nb = " _";
	} else {
	  $res = $base_adj." m";
	  $res_nb = " p";
	}
  }

  # Presque tous les adjectifs en -ais/-ois sont ambigus en nombre

  elsif ($adj =~ /(.*)(ai|oi)s$/) {
	$base_adj = $1.$2;
	if ($base_adj =~ /^(bai|coi|gai|lai|vrai)$/) {
	  $res = $base_adj." m";
	  $res_nb = " p";
	} else {
	  $res = $base_adj."s m";
	  $res_nb = " _";
	}
  }
 
  # Deux classes d'adjectifs termines par -as/-os, tous de genre indéterminé:
	
  elsif ($adj =~ /(.*)(a|o)s$/) {
		
	$base = $1.$2;
	if ($self->est_une_exception($adj,"A_aOUos")==1) {
	  $res = $adj." _";
	  $res_nb = " _";
	} else {
	  $res = $base." _";
	  $res_nb = " p";
	}
  }
	
  # Deux classes d'adjectifs termines par -us
	
  elsif ($adj =~ /(.*)us$/) {
	$base_adj = $1.$2."u";
	if ($self->est_une_exception($adj,"A_us") == 1) {
	  $res = $adj." m";
	  $res_nb = " _";
	} else {
	  $res = $base_adj." m";
	  $res_nb = " p";
	}
  }
	
  # Les adjectifs terminés par Ls, avec L différent de a, o, e, ë sont des masculin-pluriel:
	
  elsif ($adj =~ /(.*)([^aoeë])s$/) {
	$res = $1.$2." m";
	$res_nb = " p";
  }
	
  # Adjectif terminés par -ë(s)
  # ==========================
	
  # Adjectifs terminés par -gu, -guë, -guës
	
  elsif ($adj =~ /(.*)(gu)ë?s?$/) {
	$base_adj = $1.$2;
	if ($adj =~ /ës?$/) {
	  $res = $base_adj." f";
	} else {
	  $res = $base_adj." m";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Adjectif terminés par -e(s)
  # ==========================
	
  # Adjectifs terminés par -ée, -ie, -ue : ce sont des féminins (pluriel si -s)
  # sauf liste d'exception
	
  elsif ($adj =~ /(.*)(é|i|([^gq]u))(e|es)$/) {
	$base = $1.$2."e";
	$base_adj = $1.$2;
		
	if ($self->est_une_exception($base,"A_Ve")==1) {
	  $res = $base." _";
	} else {
	  $res = $base_adj." f";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Masculin des adjectifs termines par -euses
	
  elsif ($adj =~ /(.*)euses?$/) {
	$base_adj = $1;
	if ($base_adj =~ /^(doût|dout|copi|piss)$/) {
	  $res = $1."eur ou ".$1."eux f";
	} elsif ($self->est_une_exception($base_adj,"N_euse")) {
	  $res = $base_adj."eur f";
	} else {
	  $res = $base_adj."eux f";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Adjectifs terminés par -ausse, auce, ause, iusse, iuse, iuce, ousse, ouse, ouce, 
  # Ce sont des féminin (pluriel) d'adjectifs en -[aio]ux
	
  elsif ($adj =~ /(.*)([aio])u(ss|c|s)es?$/) {
	$res = $1.$2."ux f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Adjectifs terminés par -rce, 
  # Ce sont des féminin (pluriel) d'adjectifs en -rs
	
  elsif ($adj =~ /(.*)rces?$/) {
	$res = $1."rs f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Adjectifs terminés par -oresse ou -eresse, 
  # Ce sont des féminin (pluriel) d'adjectifs en -eur
	
  elsif ($adj =~ /(.*)[oe]resses?$/) {
	$res = $1."eur f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Autres adjectifs terminés par -xesse, 
  # Ce sont des féminin (pluriel) d'adjectifs en -xe

  elsif ($adj =~ /(...+)(e)sses?$/) {
	$res = $1.$2." f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }

  # Adjectifs terminés par -trice, 
  # Ce sont des féminin (pluriel) d'adjectifs en -teur

  elsif ($adj =~ /(.*)trices?$/) {
	$res = $1."teur f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Adjectifs terminés par -mane : féminins de -man, ou genre indéterminé?
	
  elsif ($adj =~ /(.*)(man)es?$/) {
		
	$base = $1.$2;
	if ($self->est_une_exception($base,"A_man_e")==1) {
	  $res = $base." f";
	} else {
	  $res = $base."e _";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Autres adjectifs terminés par -ane: : féminins de -an, ou genre indéterminé?
	
  elsif ($adj =~ /(.*)(an)es?$/) {
	$base = $1.$2;
	$base_adj = $1.$2."e";
	if ($self->est_une_exception($base_adj,"A_ane")==1) {
	  $res = $base_adj." _";
	} else {
	  $res = $base." f";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Adjectifs terminés par -CCe
	
  elsif ($adj =~ /(.*)(.)\2es?$/) {
	$base = $1.$2;
	$base_adj = $1.$2.$2."e";
	if (($base_adj =~ /(colle|gramme|famille|bacille)$/)||
		($self->est_une_exception($base_adj,"A_CCe") == 1)) {
	  $res = $base_adj." _";
	} else {
	  $res = $base." f";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Adjectifs en :(.*)fère, (.*)tère, (.*)bère, (.*)cère, (.*)ler,(.*)père, (.*)vère + liste
  # sont invariables en genre, (sauf abeiller, houiller)
	
  elsif ($adj =~/(.*)ères?$/) {
	$base = $1."ère";
	if ((($base !~ /houillère$/) && 
		 ($base !~ /abeillère $/) &&
		 ($base =~ /(.*)([ftbclpv])ère$/)) ||
		($base =~ /(poly|oligo)mère$/) ||
		($self->est_une_exception($base,"A_ere") == 1)) {
	  $res = $base." _";
	} else {
	  $adj =~/(.*)ères?/;
	  $res = $1."er f";
	} 
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	} else {
	  $res_nb = " s";
	}
  }
	
  # Adjectifs en -ète, féminin de -et
	
  elsif ($adj =~ /(.*)(pl|cr|su|qui)ètes?$/) {
	$res = $1.$2."et f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Autres adjectifs terminés par -ète, invariables en genre
	
  elsif ($adj =~ /(.*)ètes?$/) {
	$res = $1."ète _";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }

  # Adjectifs en -ote, invariables en genre

  elsif ($adj =~ /(.*)(y|d|qu|ph|ni|tri|pri|p|cr|yg|li)otes?$/) {
	$res = $1.$2."ote _";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Autres adjectifs terminés par -ote, féminins de -ot
	
  elsif ($adj =~ /(.*)otes?$/) {
	$res = $1."ot f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Adjectifs terminés par -ête, tous invariables en genre,
  # sauf "prêt/prête"
	
  elsif ($adj =~ /(.*)êtes?$/) {
	if ($adj =~ /^prêt/) {
	  $res = "prêt f";
	} else {
	  $res = $1."ête _";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Adjectifs terminés par -ève, féminin de -ef
	
  elsif ($adj =~ /(.*)èves?$/) {
	$res = $1."ef f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Adjectifs terminés par -ive, -ïve, féminins de -if/-ïf
	
  elsif ($adj =~ /(.*)(i|ï)ves?$/) {
	$res = $1.$2."f f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }

  # Adjectifs terminés par -ine : féminin de -in, ou invariable en genre
  elsif ($adj =~ /(.*)ines?$/) {
	$base = $1."in";
	if (($adj =~ /(vicine|riocine|myosine|alanine|protéine|toxine|anidine)s?$/) ||
		($self->est_une_exception($adj,"A_ine") == 1)) {
	  $res = $base."e _";
	} else {
	  $res = $base." f";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Adjectifs terminés par -ile, -ole: : féminin de -il/-ol, ou invariable en genre
	
  elsif ($adj =~ /(.*)([oi])les?$/) {
	$base = $1.$2."l";
	if ($self->est_une_exception($base,"A_oOUil") == 1) {
	  $res = $base." f";
	} else {
	  $res = $base."e _";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }

  # Adjectifs terminés par -ure : féminin de -ur, ou invariable en genre
	
  elsif ($adj =~ /(.*)ures?$/) {
	$base = $1."ur";
	if (($adj =~ /(sulfure|mature)$/)||
		($self->est_une_exception($adj,"A_ure") == 1)) {
	  $res = $base."e _";
	} else {
	  $res = $base." f";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Adjectifs terminés par -ule :  invariable en genre, sauf 
  #	 "peul, saoul, seul et tamoul"
	
  elsif ($adj =~ /(.*)ules?$/) {
	$base = $1."ul";
	if ($base =~ /^(peul|saoul|seul|tamoul)$/) {
	  $res = $base." f";
	} else {
	  $res = $base."e _";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }

  # Adjectifs terminés par -use, -ute, -rse, -rte, -cte :
  # féminin de -us, -ut, -rs, -rt, -ct, ou invariable en genre
	
  elsif ($adj =~ /(.*)([urc])([st])es?$/) {
	$base = $1.$2.$3;
	if ($self->est_une_exception($base."e","A_sOUte") == 1) {
	  $res = $base."e _";
	} else {
	  $res = $base." f";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Adjectifs en -ate : féminin de -at, ou invariable en genre
	
  elsif ($adj =~ /(.*)ates?$/) {
	$base = $1."at";
	if ($base =~ /(.mat|hydrat|téat|[car]rat|oat|[tn]iat|rlat)$/) {
	  $res = $base."e _";
	} else {
	  $res = $base." f";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }

  # Adjectifs en -ite : : féminin de -it, ou invariable en genre
								
  elsif ($adj =~ /(.*)ites?$/) {
	$base = $1."it";
	if ($base =~ /(l|m|c|h|s|v|i|o[ndb]|[iaé]r|ab|[lrt]t|su|[mn]n|ocr|mo)it$/) {
	  $res = $base."e _";
	} else {
	  $res = $base." f";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }

  # Adjectifs en -aire : invariables en genre, sauf "clair, impair et pair"
								
  elsif ($adj =~ /(.*)aires?$/) {
	$base = $1."air";
	if ($base =~ /^(clair|impair|pair)$/) {
	  $res = $base." f";
	} else {
	  $res = $base."e _";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }

  # Adjectifs en -ose : féminin de -os, sauf "amorphose, grandiose, morose , rose"
								
  elsif ($adj =~ /(.*)oses?$/) {
	$base = $1."os";
	$base_adj = $base."e";
	if ($base_adj =~ /(saccharose|sucrose|^amorphose|^grandiose|^morose|^rose)$/) {
	  $res = $base_adj." _";
	} else {
	  $res = $base." f";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Tous les adjs recensés en -inte(s) sont le féminin de -int:

  elsif ($adj =~ /(.*)(int)es?$/) {
	$res = $1.$2." f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Tous les adjs recensés en -ide(s) sont invariables en genre, 
  # sauf "froid" et "laid":
	
  elsif ($adj =~ /(.*)(id)es?$/) {
	$base = $1.$2;
	if ($base =~ /^(froid|laid)$/) {
	  $res = $base." f";
	} else {
	  $res = $base."e _";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Les adjs terminés  en -urde(s)	sont le féminin de -urd, 
  # sauf "kurde"et "absurde":
	
  elsif ($adj =~ /(.*)urdes?$/) {
	$base = $1."urd";
	if ($base =~ /^(kurd|absurd)$/) {
	  $res = $base."e _";
	} else {
	  $res = $base." f";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Les adjs terminés  en -ale(s)  sont le féminin de -al, 
  # sauf liste et terminaiosn:
	
  elsif ($adj =~ /(.*)ales?$/) {
	$base = $1."al";
		
	if ($base =~ /(^m|^op|^ov|^ré|^s|^ét|még|céph|arv|pét|cad|éré|and)al$/) {
	  $res = $base."e _";
	} else {
	  $res = $base." f";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  } elsif ($adj =~ /(.*)(.)ptes?$/) {
	$base = $1.$2."pt";
	$base_adj = $2;
		
	if ($base_adj =~ /^[aoe]$/) {
	  $res = $base."e _";
	} else {
	  $res = $base." f";
	}
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Autres adjectifs termines par -e, -es.
  # Ceux qui correspondent à la description sont des féminins.
  # Pour l'instant, ce test est insuffisant.
	
  elsif ($adj =~ /(.*)(ûr|noir|[^rzsqg]u|[pd]u[rl]|is|[eau]nt|é|[^ae]un|[oa][run]d)es?$/) {
	$res = $1.$2." f";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Et par consequent, celui-ci aussi: tous les autres sont invariables en genre
	
  elsif ($adj =~ /(.*)(.*)es?$/) {
	$res = $1.$2."e _";
	if ($adj =~ /s$/) {
	  $res_nb = " p";
	}
  }
	
  # Toutes les autres terminaisons sont celles d'adjectifs masculin-singulier
  # ========================================================================
	
  else {
	$res=$adj." m";
  }

	
  $res .= $res_nb;
  $res =~ s/ ([mf_]) ([sp_])$/:$1$2/;	 

  return $res;
}

# Lemme des verbes conjugués

sub lemme_verbe { 
  my $self=shift; 
  my ($vb)=@_; 

  my ($aux,$term,$inf,$base); 
  my $res=""; 
 
  # neutralisation: 

  if ($vb =~ /^haï(.*)/) { 
	$vb = "hai".$1;
  }
	
  # Flexions lexicalisées (être,avoir,aller,faire, etc.)
	
  # gésir
  if ($vb =~ /^(gît|gisi?ons|gis(ait|ais|(ai)?ent)?)$/) {
	$res = "gésir";
	if ($vb =~	/.*(aient|ait|ais|ions)$/) {
	  $term = &termi("imp",$1);
	} elsif ($vb =~ /^g[iî]s?(s|t|ent|ons|ez)$/) {
	  $term = &termi("pstind",$1);
	}
		
	$res .= $term." (3e groupe)";
  } elsif ($vb =~ /^appert$/) {
	$res = "apparoir, 3psPSTIND, (3e groupe)";
  } elsif ($vb =~ /(.*)dites$/) {
	$res = $1."dire, 2ppPSTIND/IMPER, (3e groupe)";
  } elsif ($vb =~ /^chaut$/) {
	$res = "chaloir, 3psPSTIND, (3e groupe)";
  } elsif ($vb =~ /^(re)?sai(s|t)$/) {
	$res = $1."savoir".	 &termi("pstind",$2)." (3e groupe)";
  } elsif ($vb =~ /^tai(s|t)$/) {
	$res = "taire".	 &termi("pstind",$1)." (3e groupe)";
  }
	
  # naître/paître/connaître/paraître/croître et ses composés
	
  elsif ($vb =~ /^(re|ré)?(mé|ap|com|dis|trans|ac|dé|sur)?(na|pa|para|conna|cro)(is|ît|îtra[is]?|îtront|îtri?ons|îtri?ez|îtrai[st]|îtraient|issai[st]|isse(s|nt)?|issi?ons|issi?ez|issaient|quis|quî[mt]es|qui(ren)?t)$/) {
	$term = $4;
	$res = $1.$2.$3."ître";
	if ($term =~/^[iî](s|t)$/) {
	  $res .= &termi("pstind", $1);
	} elsif ($term =~/^îtr(.*)$/) {
	  $res .= &termi("ft",$1);
	} elsif ($term =~/^iss(.*)$/) {
	  $res .= &termi("pstimp1",$1);
	} else {
	  $term =~ /^qu(.*)$/;
	  $res .= &termi("ps",$1);
	}
	$res .= " (3e groupe)";
  } elsif ($vb =~ /^(re|ré)?(mé|ap|com|dis|trans)?(conn|par)(u|û)(s|t|mes|tes|rent)$/) {
	$res = $1.$2.$3."aître";
	$aux = $4;
	$term = $5;
	if (($aux eq "û") && ($term eq "t")) {
	  $res .= &termi("subjimp","ût");
	} else {
	  $res .= &termi("ps",$term);
	}
	$res .= " (3e groupe)";
  } elsif ($vb =~ /^crûmes$/) {
	$res = "croître	 ou croire, 1ppPS (3e groupe)";
  } elsif ($vb =~ /^crûtes$/) {
	$res = "croître	 ou croire, 2ppPS (3e groupe)";
  } elsif ($vb =~ /^(re|ré)?(accr|décr|cr|surcr)(u|û)(s|t|mes|tes|rent)$/) {
	$res = $1.$2."oître	 ou ".$1.$2."oire";
	$term = $4;
	$res .= &termi("ps",$term)." (3e groupe)";
  } elsif ($vb =~ /^(cr)û(s|t|rent)$/) {
	$res = "croître";
	$term = $2;
	if ($term eq "t") {
	  $res .= &termi("ps",$term)." ou croire ".&termi("subjimp", "ût")." (3e groupe)";
	} else {
	  $res .= &termi("ps",$term)." (3e groupe)";
	}
  } elsif ($vb =~ /^(surcr|recr)(u)(s|t|mes|tes|rent)$/) {
	$res = $1."oître";
	$term = $3;
	$res .= &termi("ps",$term)." (3e groupe)";
  }

  # faire et ses composés
  elsif ($vb =~ /^(re)?(contre|dé|for|mal|mé|par|satis|sur)?(fasses?|fassent|fassions|fassiez|fai[st]|font|faisai[st]|faisaient|fera[is]?|ferai[st]|feraient|feri?ons|feri?ez|fît|feront|fi[st]|fî[tm]es|firent|faisi?ons|faites|faisiez)$/) {
	$res = $1.$2."faire";
	if ($vb =~	/.*er(aient|ai[st]|ions|iez|ons|ez|a[is]?|ont)$/) {
	  $term = &termi("ft",$1);
	} elsif ($vb =~ /.*ais(aient|ai[st]|ions|iez)$/) {
	  $term = &termi("impseul",$1);
	} elsif ($vb =~ /.*ss(es?|ent|ions|iez)$/) {
	  $term = &termi("pstsubj",$1);
	} elsif ($vb =~ /.*f(ît)$/) {
	  $term = &termi("subjimp",$1);
	} elsif ($vb =~ /.*[^a][iî]([mt]es|t|s|rent)$/) {
	  $term =  &termi("ps",$1);
	} elsif ($vb =~ /.*f(ai)?s?(s|ont|t|ons)$/) {
	  $term = &termi("pstind",$2);
	} elsif ($vb =~ /.*faites$/) {
	  $term = &termi("pstind","ez");
	}
	$res .= $term." (3e groupe)";
  }

  # pouvoir

  elsif ($vb =~ /^puis$/) {
	$res = "pouvoir, 1/2psPSTIND, (3e groupe)";
  }
	
  # être
  elsif ($vb =~ /^(suis|est?|sommes|êtes|sont|soi[st]|soient|soyons|soyez|étai[st]|étaient|étions|étiez|furent|f[ûu][st]|fussent|fû[tm]es|sera[is]?|serai[st]|seraient|seront|seri?ons|seri?ez)$/) {
	$res = "être";
	if ($vb =~	/.*er(aient|ai[st]|i?ons|i?ez|a[is]?|ont)$/) {
	  $term = &termi("ft",$1);
	} elsif ($vb =~ /^étaient$/) {
	  $res = "étayer, 3ppPSTIND/SUBJ, (1er groupe), ou être".&termi("impseul","aient");
	} elsif ($vb =~ /^suis$/) {
	  $res = "suivre, ou être, 1/2psPSTIND/IMPER, ";
	} elsif ($vb =~ /.*(ai[st]|ions|iez)$/) {
	  $term = &termi("impseul",$1);
	} elsif ($vb =~ /.*soi(t|es|ent)$/) {
	  $term = &termi("pstsubj",$1);
	} elsif ($vb =~ /.*soi?(e|yons|yez)$/) {
	  $term = &termi("pstsubjimper",$1);
	} elsif ($vb =~ /^fussent$/) {
	  $term = " ,3ppSUBJIMP,";
	} elsif ($vb =~ /.*[uû]([tm]es|t|s|rent)$/) {
	  $aux = $1;
	  if ($vb =~ /ût$/) {
		$term = &termi("subjimp","û".$aux);
	  } else {
		$term =	 &termi("ps",$aux);
	  }
	} elsif ($vb =~ /s(ont|t)$/) {
	  $term = &termi("pstind",$1);
	} elsif ($vb =~ /^es$/) {
	  $term = ", 2psPSTIND,";
	} elsif ($vb =~ /^êtes$/) {
	  $term = ", 2ppPSTIND,";
	} else {
	  $term	 = ", 1ppPSTIND,";
	}
	$res .= $term." (3e groupe)";
  }

  # avoir
  elsif ($vb =~ /^(a[si]?|ai[t]|ayons|ayez|aie(s|nt)?|avi?ons|avi?ez|ont|avai[st]|avaient|aura[is]?|auri?on[st]|auri?ez|aurai[st]|auraient|eussent|e[ûu]t|eus|eû[mt]es|eurent)$/) {
	$res ="avoir";
	if ($vb =~	/.*ur(aient|ai[st]|i?ons|i?ez|a[is]?|ont)$/) {
	  $term = &termi("ft",$1);
	} elsif ($vb =~ /.*(aient|ai[st]|ions|iez)$/) {
	  $term = &termi("impseul",$1);
	} elsif ($vb =~ /ai(es|ent)$/) {
	  $term = &termi("pstsubj",$1);
	} elsif ($vb =~ /^eussent$/) {
	  $term = ", 3ppSUBJIMP,";
	} elsif ($vb =~ /a(i)?(e|yez|yons)$/) {
	  $term = &termi("pstsubjimper",$2);
	} elsif ($vb =~ /.*[uû](mes|t|rent|s)$/) {
	  $term =  &termi("ps",$1);
	} elsif ($vb =~ /(av)?(a|ons|ont)$/) {
	  $term = &termi("pstindseul",$2);
	} else {
	  $term = ", 1psPSTIND,";
	}
		
	$res .= $term." (3e groupe)";
  }
	
  # aller
  elsif ($vb =~ /^(va(is|s)?|vont|alli?ons|alli?ez|allai[ts]|allaient|alla[is]|allèrent|allâ[mt]es|ira[is]?|iront|irai[st]|iraient|iri?ons|iri?ez)$/) {
	$res ="aller";
	if ($vb =~	/.*ir(aient|ai[st]|i?ons|i?ez|a[is]?|ont)$/) {
	  $term = &termi("ft",$1);
	} elsif ($vb =~/vais$/) {
	  $term = ", 1psPSTIND, ";
	} elsif ($vb =~/vas$/) {
	  $term = ", 2psPSTIND, ";
	} elsif ($vb =~ /.*(aient|ai[ts]|ions|iez)$/) {
	  $term = &termi("imp",$1);
	} elsif ($vb =~ /aillent$/) {
	  $term = &termi("pstsubj",$1);
	} elsif ($vb =~ /l(â[tm]es|a[is]?|èrent)$/) {
	  $term =  &termi("ps",$1);
	} elsif ($vb =~ /vont$/) {
	  $term = ", 3ppPSTIND, ";
	} elsif ($vb =~ /va$/) {
	  $term = ", 3psPSTIND/IMPER, ";
	} else {
	  $vb =~ /ll(ons|ez)$/;
	  $term =  &termi("pstind",$1);
	}
		
	$res .= $term." (3e groupe)";		
  } elsif ($vb =~ /^aill(es?|ent)?$/) {
	$res = "aller".&termi("pstsubj",$1)." (3e groupe) ou ailler".&termi("pst",$1)." (1er groupe)";
  }

  # enverra
	
  elsif ($vb =~ /^(r)?enverr(a[is]?|ai[st]|i?ons|i?ez|aient|ont)$/) {
	$res =$1."envoyer".&termi("ft",$2)." (1er groupe)";
  }
	
  #bruire vs bruir (défectif)
	
  elsif ($vb =~ /^brui(t|ss(e|ait|aient|ent))$/) {
	$vb =~ /^brui(ss)?(.*)$/;
	$aux = $2;
	if ($aux =~ /^e$/) {
	  $term = &termi("pstsubj","e");
	} else {
	  $term = &termi("noft",$aux);
	}
	$res = "bruir".$term."(2e groupe), ou bruire".$term." (3e groupe)";
  } else {
	$res = $self->verbe_regulier($vb);
  }

  return $res;
}


1;


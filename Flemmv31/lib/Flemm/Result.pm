###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de # 
# corpus étiquetés - Version 3.1										  #
# Copyright (C) 2004 (NAMER Fiammetta)									  #
###########################################################################
#
# $Id$
#

package Flemm::Result;

use strict;
use warnings;
no warnings 'uninitialized';
use utf8;

use Flemm::Analyse;
use Flemm::Analyses;
use Flemm::Feature;
use Flemm::Features;

sub new {
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = {};
	bless $self, $class;
	
	$self->{ff}=undef;
	$self->{cat}=undef;
	$self->{anas}=undef;

	$self->{res}=undef;

	return $self;
}

sub getInflectedForm {
	my $self=shift;

	return $self->{ff};
}

sub setInflectedForm {
	my $self=shift;
	my ($ff)=@_;

	$self->{ff}=$ff;
}

sub getCategory {
	my $self=shift;

	return $self->{cat};
}

sub setCategory {
	my $self=shift;
	my ($cat)=@_;

	$self->{cat}=$cat;
}

sub getOriginalTag {
	my $self=shift;

	return $self->{oritag};
}

sub setOriginalTag {
	my $self=shift;
	my ($oritag)=@_;

	$self->{oritag}=$oritag;
}

sub getAnalyses {
	my $self=shift;

	return $self->{anas};
}

sub setAnalyses {
	my $self=shift;
	my ($anas)=@_;

	$self->{anas}=$anas;
}

# Exemple de sortie Multext
# FF			CAT		 :Multext		LEMME		|| encore ...
# généralisent	VER(pres):Vmip3p-1		généraliser || généralisent		VER(pres):Vmsp3p-1		généraliser

sub setMultext {
	my $self=shift;
	my ($multext)=@_;

	my @sols=split(/ \|\| /,$multext);

	my ($ff,$categorie);
	if ($sols[0]=~/(.*)\t(.*):([^:]*)\t(.*)/) {
		($ff, $categorie)=($1,$2);
	}
	elsif ($sols[0]=~/(.*)\t(.*)\t(.*)/) {
		($ff, $categorie)=($1,$2);
	}

	elsif ($sols[0]=~/([^\/]*)\/(.*):([^:]*)\t(.*)/) {
		($ff, $categorie)=($1,$2);
		$sols[0]=~s/\//\t/;
	}
	elsif ($sols[0]=~/([^\/]*)\/(.*)\/(.*)/) {
		($ff, $categorie)=($1,$2);
		$sols[0]=~s/\//\t/g;
	}
   elsif ($sols[0]=~/([^\/]*)\/(.*)/) {
		($ff, $categorie)=($1,$2);
		$sols[0]=~s/\//\t/;
	}


	$self->setInflectedForm($ff);
	$self->setCategory($categorie);

	$self->setAnalyses(new Flemm::Analyses);

	foreach my $sol (@sols) {
		my $ana=new Flemm::Analyse;

		if ($sol =~ /([^\/\t]*)\/([^\/\t]*)[\t\/]([^\/\t]*)/) { $sol = $1."\t".$2."\t".$3; }
		elsif ($sol =~ /([^\/\t]*)\/([^\/\t]*)/) { $sol = $1."\t".$2; }

		if ($sol =~/.*\t[^:]*\t(.*)/) {
			
			my($lemme)=$1;
			$ana->setLemme($lemme);
			$self->getAnalyses->add($ana);
		}
		else {
			my $features=new Flemm::Features;
			$ana->setFeatures($features);

			$sol=~/.*\t.*:(.*)\t(.*)/;
			my($traits)=$1;
			my($lemme)=$2;
			
			$ana->setLemme($lemme);
			
			my($catmultext,$type,$mood,$tense,$pers,$nb,$ge,$clit,$vclass,$case,$typesem,$degree,$pos,$quant);
			if ($traits =~/^V/) {
				($catmultext, $type, $mood, $tense, $pers,$nb,$ge,$clit,$vclass)= split(//,$traits);
			}
			elsif ($traits=~/^N/) {
				($catmultext,$type, $ge, $nb, $case,$typesem)= split(//,$traits);
			}
			elsif ($traits=~/^A/) {
				($catmultext,$type,$degree,$ge,$nb,$case)= split(//,$traits);
			}
			elsif ($traits=~/^P/) {
				($catmultext,$type,$pers,$ge,$nb,$case,$pos)= split(//,$traits);
			}
			elsif ($traits=~ /^D/) {
				($catmultext,$type,$pers,$ge,$nb,$case,$pos,$quant)= split(//,$traits);
			}
			elsif ($traits=~ /^(Sp\+D)(.*)/) {
				$catmultext=$1;
				($type,$pers,$ge,$nb,$case,$pos,$quant)= split(//,$2);
			}
			
			if (defined $catmultext) {
				my $feature=new Flemm::Feature('catmultext',$catmultext);
				$features->add($feature);
			}
			if (defined $type) {
				my $feature=new Flemm::Feature('type',$type);
				$features->add($feature);
			}
			if (defined $mood) {
				my $feature=new Flemm::Feature('mood',$mood);
				$features->add($feature);
			}
			if (defined $tense) {
				my $feature=new Flemm::Feature('tense',$tense);
				$features->add($feature);
			}
			if (defined $pers) {
				my $feature=new Flemm::Feature('pers',$pers);
				$features->add($feature);
			}
			if (defined $ge) {
				my $feature=new Flemm::Feature('gend',$ge);
				$features->add($feature);
			}
			if (defined $nb) {
				my $feature=new Flemm::Feature('nb',$nb);
				$features->add($feature);
			}
			if (defined $clit) {
				my $feature=new Flemm::Feature('clitic',$clit);
				$features->add($feature);
			}
			if (defined $vclass) {
				my $feature=new Flemm::Feature('vclass',$vclass);
				$features->add($feature);
			}
			if (defined $case) {
				my $feature=new Flemm::Feature('case',$case);
				$features->add($feature);
			}
			if (defined $pos) {
				my $feature=new Flemm::Feature('poss',$pos);
				$features->add($feature);
			}
			if (defined $typesem) {
				my $feature=new Flemm::Feature('typesem',$typesem);
				$features->add($feature);
			}
			if (defined $degree) {
				my $feature=new Flemm::Feature('degree',$degree);
				$features->add($feature);
			}
			if (defined $quant) {
				my $feature=new Flemm::Feature('quant',$quant);
				$features->add($feature);
			}
			
			$self->getAnalyses->add($ana);
		}
	}
}

sub setResult {
	my $self=shift;
	my ($res)=@_;

	$self->{res}=$res;
}

sub getResult {
	my $self=shift;

	return $self->{res};
}

sub asXML {
	my $self=shift;
	my $res="";
	
	$res="<FlemmResult>\n";
	$res.="\t<InflectedForm>".$self->getInflectedForm."</InflectedForm>\n";
	$res.="\t<Category original-tagger='".$self->getOriginalTag."'>".$self->getCategory."</Category>\n";
	if ($self->getAnalyses) {
		$res.="\t<Analyses> <!-- ".$self->getResult." -->\n";
		while (my $ana=$self->getAnalyses->next) {
			$res.="\t\t<Analyse>\n";
			$res.="\t\t\t<Lemme>".$ana->getLemme."</Lemme>\n";
			if ($ana->getFeatures) {
				$res.="\t\t\t<Features>\n";
				while (my $trait=$ana->getFeatures->next) {
					$res.="\t\t\t\t<Feature name='".$trait->getName."' value='".$trait->getValue."'/>\n";
				}
				$res.="\t\t\t</Features>\n";
			}
			$res.="\t\t</Analyse>\n";
		}
		$res.="\t</Analyses>\n";
	}
	$res.="</FlemmResult>\n";

	return $res;
}


1;

__END__

=head1 NAME

Flemm::Result - Lemmatisation du français à partir de corpus 
étiquetés.
Exploitation des résultats.

=head1 SYNOPSIS

=head2 Exemple 1 : input au format Brill, affichage linéaire des résultats 

  use Flemm;
  use Flemm::Result;
  my $lemm=new Flemm(
				"Tagger" => "Brill"
			   );
  while (<>) {
	chomp;
	my $res=$lemm->lemmatize($_);
	print $res->getResult."\n";

  }


echo 'fabrique/VCJ:sg' | ./exemple1.pl

	 ==> fabrique/VCJ:Vmip1s--1 fabriquer || fabrique/VCJ:Vmip3s--1		fabriquer || fabrique/VCJ:Vmmp2s--1		fabriquer || fabrique/VCJ:Vmsp1s--1		fabriquer || fabrique/VCJ:Vmsp3s--1		fabriquer 

=head2 Exemple 2 : input au format TreeTagger, affichage au format xml

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

echo 'généralisent		VER:pres		généraliser' | ./exemple2.pl

   ==>

<FlemmResult>
	  <InflectedForm>généralisent</InflectedForm>
	  <Category original-tagger='VER:pres'>VER(pres)</Category>
	  <Analyses> <!-- généralisent		VER(pres):Vmip3p--1		 généraliser || généralisent	  VER(pres):Vmsp3p--1	   généraliser -->
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


=head1 DESCRIPTION

Flemm::Result définit un objet résultat de l'analyse morpho-flexionnelle 
Un ensemble de méthodes permet d'exploiter les informations calculées.

Principales caractéristiques de l'objet:

=over 3

=item 

Conforme au format MulText

=item 

Le résultat comprend trois parties : la forme fléchie de départ, la catégorie de départ, ou 
réévaluée par Flemm, une liste d'analyses morpho-flexionnelles.

=item

Chaque analyse de la liste regroupe le lemme calculé, et la liste des traits 
pertinents.

=item

Deux analyses peuvent différer par un seul trait

=item

L'affichage est soit linéaire, soit en xml

=back

=cut

=head1 METHODES

=over 3

=item new()

La méthode new permet de créer un objet de type Flemm::Result.

=item getInflectedForm(), getCategory(), getOriginalTag(), getAnas()

Méthodes permettant d'accéder, respectivement à : 
la forme fléchie, la catégorie, la catégorie d'origine, 
l'ensembles des analyses

=item getResult()

Méthodes permettant d'accéder au résultat complet

=item setInflectedForm($ff), setCategory($cat), setOriginalTag($oritag), setAnas($anas)

Méthodes permettant de renseigner, respectivement: 
la forme fléchie, la catégorie, la catégorie d'origine, 
l'ensembles des analyses, d'une entrée

=item setResult($res)

Méthodes permettant de renseigner le  résultat complet d'une analyse

=item setMultext($sortie_multext)

analyse une sortie multext issue de l'analyse par Flemm et appelle
les méthodes d'affectation pertinentes : setInflectedForm($ff), 
setCategory($cat), setOriginalTag($oritag), setAnas($anas)

=item asXML()

construit un arbre xml représentant une analyse de Flemm, 
en appliquant les méthodes 
d'accès : getInflectedForm(), getCategory(), 
getOriginalTag(), getAnas()
ainsi que les méthodes d'accès au contenu d'une analyse, d'un trait, d'une liste de traits.

=back

=cut

=head1 SEE ALSO

Flemm::Analyses, Flemm::Analyse, Flemm::Features, Flemm::Feature

=cut

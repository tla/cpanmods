###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de # 
# corpus étiquetés - Version 3.1                                          #
# Copyright (C) 2004 (NAMER Fiammetta)                                    #
###########################################################################
#
# $Id$
#

package Flemm;

use strict;
use warnings;
use 5.008_001;
use utf8;

use vars qw/ $VERSION /;
$VERSION = '3.1';

use Flemm::Brill;
use Flemm::TreeTagger;

#
# Méthodes publiques
#

# Constructeur
# Renvoie un objet de type Flemm::Brill ou Flemm::TreeTagger
# Lance une exception si le type de Tagger n'est pas précisé
sub new {
    my $type=shift;
    my (%params)=@_;

    my $self=undef;
    my $tagger=undef;
    my %p;

    if (exists $params{Logname}) {
        $p{Logname}=$params{Logname};
    }
    
    if (exists $params{Format}) {
        $p{Format}=$params{Format};
    }
    
	$p{Encoding} = $params{Encoding} || 'utf8';
    
    if (exists $params{Tagger}) {
        $tagger=$params{Tagger};
        if ($tagger =~ /brill/i) {
            $self=new Flemm::Brill(%p);
        }
        elsif ($tagger =~ /(treetagger|tt)/i) {
            $self=new Flemm::TreeTagger(%p);
        }
        else {
            die "Flemm::new(): $tagger n'est pas un étiqueteur reconnu\n";
        }
    }
    else {
        $self=new Flemm::TreeTagger(%p);
    }
    
    return $self;
}

1;

__END__

=head1 NAME

Flemm - Lemmatisation du français à partir de corpus étiquetés

=head1 SYNOPSIS

=head2 Exemple1 (étiquetage Brill, sortie linéaire)

  use Flemm;
  use Flemm::Result;

  my $lemm=new Flemm(
                'Tagger' => 'Brill',
                'Logname' => '/tmp/log_errors'
               );
 

  while (<>) {
    chomp;
    my $res=$lemm->lemmatize($_);
    print $res->getResult;
}

echo 'fabriquera/VCJ:sg'|perl exemple1.pl > result_brill.txt
 
=head2 Exemple2 (étiquetage Treetagger, sortie xml)

  use Flemm;
  use Flemm::Result;
  my $lemm=new Flemm(
                'Logname' => '/tmp/log_errors'
               );
 
 print "<?xml version='1.0' encoding='ISO-8859-1'?>\n\n";
 print "<FlemmResults>\n";
  while (<>) {
    chomp;
    my $res=$lemm->lemmatize($_);
    print $res->asXML;
 }
 print "</FlemmResults>\n";


echo 'généralisent      VER:pres        généraliser'|perl exemple2.pl > result_tt.xml
 

=head1 DESCRIPTION

Flemm effectue l'analyse morpho-flexionnelle d'une forme fléchie étiquetée.
Le résultat inclut le lemme (forme non fléchie conventionnellement associée
à la forme analysée) ainsi que l'ensemble des traits flexionnels calculables
hors contexte. 
La définition et la valeur de ces traits sont conformes aux normes définies dans
Multext (http://www.lpl.univ-aix.fr/projects/multext/). 
Le résultat peut être affiché au format xml. 
L'affichage du résultat nécessite l'usage du module Flemm::Result;

Principales caractéristiques:

=over 3

=item * Etiquetage de l'input : Brill entraîné pour le français 
(http://www.atilf.fr) ou 
TreeTagger (http://www.ims.uni-stuttgart.de/projekte/corplex/TreeTagger/DecisionTreeTagger.html)

=item * basé sur règles + liste d'exceptions

=item * contrôle et éventuellement correction de l'étiquetage d'origine, en fonction de 
la terminaison de la forme fléchie

=back

=cut

=head1 METHODES

=over 3

=item new(%params)

La méthode new permet de créer un objet de type Flemm::Brill ou de type Flemm::TreeTagger, 
en fonction de la valeur du paramètre tagger.

Les paramètres possibles, passés à new via un hashage sont les suivants:

=over 4

=item * Tagger = (Brill|TreeTagger) (par défaut : TreeTagger)

=item * Logname = prefixe des fichiers log

=item * Format = (normal|xml), (par défaut : normal)

=back

La méthode de lemmatisation est appelée par l'objet crée, selon son 
type (Flemm::Brill ou Flemm::Treetagger) dans le module approprié 


=item Flemm::TreeTagger::lemmatize($input_string) /

=item Flemm::Brill::lemmatize($input_string)

Quel que soit son type, la méthode lemmatize se charge de la 
lemmatisation à proprement parler de $input_string, c'est à dire :

=over 4

=item * identifie la forme fléchie et la catégorie

=item * valide la catégorie et la corrige si nécessaire

=item * appelle les fonctions de  calcul du lemme et des traits morpho-flexionnels

=item * produit un résultat de type Flemm::Result;

=item * lui applique les méthodes qui identifie les différentes parties de l'analyse résultante de la lemmatisation

=back

=cut

=head1 SEE ALSO

Flemm::TreeTagger, Flemm::Brill, Flemm::Result


=cut

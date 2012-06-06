###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de # 
# corpus étiquetés - Version 3.1										  #
# Copyright (C) 2004 (NAMER Fiammetta)									  #
###########################################################################
#
# $Id$
#

package Flemm::Feature;

use strict;
use warnings;
use utf8;

sub new {
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = {};
	bless $self, $class;
	my ($name,$value)=@_;
	
	$self->{name}=$name;
	$self->{value}=$value;

	return $self;
}

sub getName {
	my $self=shift;

	return $self->{name};
}

sub getValue {
	my $self=shift;
	
	return $self->{value};
}

1;

__END__

=head1 NAME

Flemm::Feature - Lemmatisation du français à partir de corpus 
étiquetés.
Description d'un trait

=head1 SYNOPSIS

 use Flemm::Feature; 
 $feature=new Flemm::Feature;


=head1 DESCRIPTION

Flemm::Feature définit un objet décrivant un trait morpho-flexionnelle.
Les méthodes de ce module sont utilisées dans Flemm::Result, 
pour définir et réstituer l'attribut et la valeur de ce trait.

L'objet est constitué de :

=over 3

=item * un nom (le nom de l'attribut)

=item * une valeur (la valeur du trait)

=back

=cut

=head1 METHODES

=over 3

=item new($nom, $valeur)

La méthode new permet de créer un objet de type Flemm::Feature, en affectant respectivement,
la valeur '$nom' au champ 'name', et la valeur '$valeur' au champ 'value';

=item getName(), getValue()

Méthodes permettant d'accéder, respectivement à : 
le nom, la valeur d'un trait.


=back

=cut

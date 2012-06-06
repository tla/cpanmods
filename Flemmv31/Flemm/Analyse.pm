###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de # 
# corpus étiquetés - Version 3.1					  #
# Copyright (C) 2004 (NAMER Fiammetta)					  #
###########################################################################
#
# $Id$
#

package Flemm::Analyse;

use strict;

sub new {
    my $this = shift;
    my $class = ref($this) || $this;
    my $self = {};
    bless $self, $class;

    $self->{lemme}=undef;
    $self->{features}=undef;

    return $self;
}

sub getLemme {
    my $self=shift;

    return $self->{lemme};
}

sub setLemme {
    my $self=shift;
    my($lemme)=@_;

    $self->{lemme}=$lemme;
}

sub getFeatures {
    my $self=shift;

    return $self->{features};
}

sub setFeatures {
    my $self=shift;
    my ($features)=@_;

    $self->{features}=$features;
}

1;

__END__

=head1 NAME

Flemm::Analyse - Lemmatisation du français à partir de corpus 
étiquetés.
Description d'une analyse

=head1 SYNOPSIS

 use Flemm::Analyse; 
 my $ana=new Flemm::Analyse;


=head1 DESCRIPTION

Flemm::Analyse définit un objet décrivant une analyse morpho-flexionnelle.
Les méthodes de ce module sont utilisées dans Flemm::Result, 
pour définir et réstituer les différentes partie de cette analyse

L'objet est constitué de :

=over 3

=item * un lemme

=item * un ensemble de traits

=back

=cut

=head1 METHODES

=over 3

=item new()

La méthode new permet de créer un objet de type Flemm::Analyse.

=item getLemme(), getFeatures()

Méthodes permettant d'accéder, respectivement à : 
le lemme, l'ensemble des traits flexionnels.

=item setLemme($lemme), setFeatures($features)

Méthodes permettant de renseigner, respectivement: 
le lemme, l'ensemble des traits flexionnels.

=back

=cut

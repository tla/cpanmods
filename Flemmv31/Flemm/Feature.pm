###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du fran�ais � partir de # 
# corpus �tiquet�s - Version 3.1					  #
# Copyright (C) 2004 (NAMER Fiammetta)					  #
###########################################################################
#
# $Id$
#

package Flemm::Feature;

use strict;

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

Flemm::Feature - Lemmatisation du fran�ais � partir de corpus 
�tiquet�s.
Description d'un trait

=head1 SYNOPSIS

 use Flemm::Feature; 
 $feature=new Flemm::Feature;


=head1 DESCRIPTION

Flemm::Feature d�finit un objet d�crivant un trait morpho-flexionnelle.
Les m�thodes de ce module sont utilis�es dans Flemm::Result, 
pour d�finir et r�stituer l'attribut et la valeur de ce trait.

L'objet est constitu� de :

=over 3

=item * un nom (le nom de l'attribut)

=item * une valeur (la valeur du trait)

=back

=cut

=head1 METHODES

=over 3

=item new($nom, $valeur)

La m�thode new permet de cr�er un objet de type Flemm::Feature, en affectant respectivement,
la valeur '$nom' au champ 'name', et la valeur '$valeur' au champ 'value';

=item getName(), getValue()

M�thodes permettant d'acc�der, respectivement � : 
le nom, la valeur d'un trait.


=back

=cut

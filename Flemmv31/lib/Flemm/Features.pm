###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de # 
# corpus étiquetés - Version 3.1										  #
# Copyright (C) 2004 (NAMER Fiammetta)									  #
###########################################################################
#
# $Id$
#

package Flemm::Features;

use strict;
use warnings;
use utf8;

use Flemm::Utils::List;

our @ISA=qw(Flemm::Utils::List);

1;

__END__

=head1 NAME

Flemm::Result - Lemmatisation du français à partir de corpus 
étiquetés.
Gestion des analyses ambiguës

=head1 SYNOPSIS

 use Flemm::Features;
 $features=new Flemm::Features;

=head1 DESCRIPTION

L'objet de type Flemm::Features est un sous type de Flemm::Utils::List.
Cet objet permet d'appliquer à l'ensemble des traits caractérisant une analyse
d'une forme fléchie 
les méthodes appropriées pour leur construction, modification, destruction
 et d'accès.  

=head1 SEE ALSO

Flemm::Utils::List;


=cut

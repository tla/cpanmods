###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de # 
# corpus étiquetés - Version 3.1					  #
# Copyright (C) 2004 (NAMER Fiammetta)					  #
###########################################################################
#
# $Id$
#

package Flemm::Analyses;

use strict;

use Flemm::Utils::List;


our @ISA=qw(Flemm::Utils::List);

1;

__END__

=head1 NAME

Flemm::Result - Lemmatisation du français à partir de corpus 
étiquetés.
Gestion des analyses ambiguës

=head1 SYNOPSIS

 use Flemm::Analyses;
 use Flemm::Result;
 $res = new Flemm::Result();
 $res->setAnalyses(new Flemm::Analyses);

=head1 DESCRIPTION

L'objet de type Flemm::Analyses est un sous type de Flemm::Utils::List.
Cet objet permet d'appliquer à l'ensemble des analyses 
d'une forme fléchie 
les méthodes appropriées pour leur construction, modification, destruction
 et d'accès.  

=head1 SEE ALSO

Flemm::Utils::List;


=cut

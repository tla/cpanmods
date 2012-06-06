#
###########################################################################
# FLEMM-v3.1 -- French Lemmatizer : Lemmatisation du français à partir de #
# corpus étiquetés - Version 3.1					  #
# Copyright (C) 2004 (NAMER Fiammetta)				          #
###########################################################################
#

#
# $Id$
#

package Flemm::Exceptions;

use strict;

use File::Basename;

#
# Méthodes publiques
#

sub new {
    # La classe en premier argument (ex: exceptions)
    my $type = shift;

    # On construit une reference (= un pointeur) qui pointe vers un hashage vide
    my $self = {};

    # On donne un type à ce pointeur
    bless $self,$type;

    # On appelle la methode initialize pour cette reference
    $self->initialize();

    # On doit retourner la reference comme resultat du constructeur ($x = new ...)
    return $self;
}

sub member {
    my ($self)=shift;

    my($mot,$liste)=@_;
    
    return defined $self->{$liste}->{$mot};
}

sub dump {
    my ($self)=shift;
    
    foreach my $f (sort keys %{$self}) {
	print "$f\n";
	foreach my $e (sort keys %{$self->{$f}}) {
	    print"\t$e\n";
	}
    }
}

#
# Méthodes privées                                                      
#

sub initialize {
    my ($self)=shift;
    
    my ($chemin);

    $chemin = $INC{'Flemm.pm'}; # On récupère le répertoire d'installation de Flemm
    $chemin = dirname($chemin)."/EXCEP";
    
    $self->readFromFile($chemin."/noms_finissant_par_AEus","N_aeus");
    $self->readFromFile($chemin."/noms_finissant_par_ail_x","N_aux2ail");
    $self->readFromFile($chemin."/noms_finissant_par_as","N_as");
    $self->readFromFile($chemin."/noms_finissant_par_au_x","N_aux2au");
    $self->readFromFile($chemin."/noms_finissant_par_aux","N_aux");
    $self->readFromFile($chemin."/noms_finissant_par_e_ee","N_ee2e");
    $self->readFromFile($chemin."/noms_finissant_par_euse","N_euse");
    $self->readFromFile($chemin."/noms_finissant_par_eux","N_eux");
    $self->readFromFile($chemin."/noms_finissant_par_i_s","N_is2i");
    $self->readFromFile($chemin."/noms_finissant_par_ier_e","N_iere2ier");
    $self->readFromFile($chemin."/noms_finissant_par_os","N_os");
    $self->readFromFile($chemin."/noms_finissant_par_ou_x","N_oux2ou");
    $self->readFromFile($chemin."/noms_finissant_par_ous","N_ous");
    $self->readFromFile($chemin."/noms_finissant_par_u_s","N_us2u");
    $self->readFromFile($chemin."/verbes_finissant_par_ERer","V_erer");
    $self->readFromFile($chemin."/verbes_finissant_par_FPHer","V_fpher");
    $self->readFromFile($chemin."/verbes_finissant_par_eCer_naccent","V_eCer_naccent");
    $self->readFromFile($chemin."/verbes_finissant_par_eLer_aigu","V_eLer_aigu");
    $self->readFromFile($chemin."/verbes_finissant_par_eMer_naccent","V_eMer_naccent");
    $self->readFromFile($chemin."/verbes_finissant_par_eNTer_aigu","V_eNTer_aigu");
    $self->readFromFile($chemin."/verbes_finissant_par_ePer_naccent","V_ePer_naccent");
    $self->readFromFile($chemin."/verbes_finissant_par_eRer_naccent","V_eRer_naccent");
    $self->readFromFile($chemin."/verbes_finissant_par_eSer_naccent","V_eSer_naccent");
    $self->readFromFile($chemin."/verbes_finissant_par_eVer_aigu","V_eVer_aigu");
    $self->readFromFile($chemin."/verbes_finissant_par_ier","V_ier");
    $self->readFromFile($chemin."/verbes_finissant_par_irer","V_irer");
    $self->readFromFile($chemin."/verbes_finissant_par_isser","V_iss");
    $self->readFromFile($chemin."/verbes_finissant_par_ller","V_ll");
    $self->readFromFile($chemin."/verbes_finissant_par_tter","V_tt");
    $self->readFromFile($chemin."/verbes_finissant_par_ayer","V_ayer");
    $self->readFromFile($chemin."/verbes_finissant_par_igner","V_ign");
    $self->readFromFile($chemin."/adjectifs_finissant_par_ine","A_ine");
    $self->readFromFile($chemin."/adjectifs_finissant_par_oOUil","A_oOUil");
    $self->readFromFile($chemin."/adjectifs_finissant_par_ere","A_ere");
    $self->readFromFile($chemin."/adjectifs_finissant_par_ure","A_ure");
    $self->readFromFile($chemin."/adjectifs_finissant_par_CCe","A_CCe");
    $self->readFromFile($chemin."/adjectifs_finissant_par_is","A_is");
    $self->readFromFile($chemin."/adjectifs_finissant_par_man_e","A_man_e");
    $self->readFromFile($chemin."/adjectifs_finissant_par_ane","A_ane");
    $self->readFromFile($chemin."/adjectifs_finissant_par_sOUte","A_sOUte");
    $self->readFromFile($chemin."/adjectifs_finissant_par_aOUos","A_aOUos");
    $self->readFromFile($chemin."/adjectifs_finissant_par_us","A_us");
    $self->readFromFile($chemin."/adjectifs_finissant_par_Ve","A_Ve");
    $self->readFromFile($chemin."/noms_finissant_par_Cs","N_Cs");
    $self->readFromFile($chemin."/noms_finissant_par_ys","N_ys");
}

sub readFromFile {
    my ($self)=shift;
    
    my($file,$liste)=@_;
    
    open(LIST_FILE,$file) || die "$file: $!\n";
    
    while (<LIST_FILE>) {
	chop;
	s/\#.*//;
	s/"(.*)"/$1/;
	next if (/^$/);
	$self->{$liste}->{$_}++;
    }
    
    close(LIST_FILE);
}


1;

__END__

=head1 NAME

Flemm::Exceptions - Lemmatisation du français à partir de corpus étiquetés

=head1 DESCRIPTION

Les objets de type Flemm::Brill ou Flemm::TreeTagger inclue un objet de type
Flemm::Exceptions pour gérer les exceptions aux règles de lemmatisation.

=head1 METHODES

=over 3

=item new()

La méthode new charge les fichiers d'exceptions.

=item member($mot,$liste)

Renvoie vrai si $mot appartient à $liste.

=item dump()

Affiche sur la sortie standard le contenu de l'objet Flemm::Exceptions (à des fins de debug).

=back

=cut


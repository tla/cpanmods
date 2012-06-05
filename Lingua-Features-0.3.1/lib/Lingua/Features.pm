# $Id: Features.pm,v 1.16 2006/08/22 14:15:37 rousse Exp $
package Lingua::Features;

=head1 NAME

Lingua::Features - Natural languages features

=head1 VERSION

Version 0.3.2

=head1 DESCRIPTION

This module implements natural languages features in Perl. Its brings the
following advantages:

=over

=item - type verification

=item - features and values normalization

=item - smart comparisons between structures

=back

=head1 SYNOPSIS

    use Lingua::Features;

    my $struc = Lingua::Features::Structure->new(
        cat   => 'verb',
        type  => 'main',
        tense => [ qw/pres fut/ ],
        mode  => 'ind',
        pers  => '3',
        num   => 'sing'
    );

    print $struc->to_string();

    print $struc->to_xml();

=cut

use Lingua::Features::Structure;
use strict;
use warnings;

our $VERSION = '0.3.2';

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004-2006, INRIA.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Guillaume Rousse <grousse@cpan.org>

=cut

1;

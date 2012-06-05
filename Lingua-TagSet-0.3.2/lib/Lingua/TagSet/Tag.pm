# $Id: Tag.pm,v 1.3 2006/08/22 14:20:56 rousse Exp $
package Lingua::TagSet::Tag;

=head1 NAME

Lingua::TagSet::Tag - Tag object for Lingua::TagSet

=cut

use strict;
use warnings;

=head1 Constructor

=head2 new(I<%features>)

Creates and returns a new C<Lingua::TagSet::Tag> object.

=cut

sub new {
    my ($class, @tokens) = @_;

    my $self = bless {
        _tokens   => []
    }, $class;

    $self->set_tokens(@tokens) if @tokens;

    return $self;
}

=head2 $tag->get_tokens()

Returns the tokens composing the tag.

=cut

sub get_tokens {
    my ($self) = @_;
    return unless ref $self;

    return @{$self->{_tokens}};
}

=head2 $tag->set_tokens(I<@tokens>)

Sets the tokens composing the tag.

=cut

sub set_tokens {
    my ($self, @tokens) = @_;
    return unless ref $self;

    # initialize storage
    $self->{_tokens} = [];

    # set tokens
    for my $id (0 .. $#tokens) {
        $self->set_token($id, $tokens[$id]);
    }
}


=head2 $tag->get_token(I<$id>)

Returns one of the token composing the tag.

=cut

sub get_token {
    my ($self, $id) = @_;
    return unless ref $self;
    return unless defined $id;

    return $self->{_tokens}->[$id];
}

=head2 $tag->set_token(I<$id>, I<$values>)

Sets one of the token composing the tag.

=cut

sub set_token {
    my ($self, $id, $values) = @_;
    return unless ref $self;
    return unless defined $id;

    if ($values) {
        my %values;
        $values = [ $values ] unless ref $values eq 'ARRAY';
        foreach my $value (@{$values}) {
            $values{$value} = $value;
        }
        $self->{_tokens}->[$id] = [ sort keys %values ];
    } else {
        $self->{_tokens}->[$id] = undef;
    }
}

=head2 $tag->insert_token(I<$id>, I<$values>)

Insert a new token in the tag, and shift the existing ones.

=cut

sub insert_token {
    my ($self, $id, $values) = @_;
    return unless ref $self;
    return unless defined $id;

    if ($values) {
        my %values;
        $values = [ $values ] unless ref $values eq 'ARRAY';
        foreach my $value (@{$values}) {
            $values{$value} = $value;
        }
        splice @{$self->{_tokens}}, $id, 0, [ sort keys %values ];
    } else {
        splice @{$self->{_tokens}}, $id, 0, undef;
    }
}

1;

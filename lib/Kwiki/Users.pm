package Kwiki::Users;
use strict;
use warnings;
use Kwiki::Base '-Base';

const class_id => 'users';
const user_class => 'Kwiki::User';

sub all {
    ($self->current);
}

sub all_ids {
    ($self->current->id);
}

sub current {
    return $self->{current} = shift if @_;
    return $self->{current} if defined $self->{current};
    my $user_id = 
      $self->preferences->user_name->value ||
      'AnonymousGnome';
    $self->{current} = $self->new_user($user_id);
}

sub new_user { 
    $self->user_class->new($self->hub, shift);
}

package Kwiki::User;
use base 'Kwiki::Base';
                  
field 'id';
        
sub new() {
    my $class = shift;
    my $self = bless {}, $class;
    $self->hub(shift);
    $self->id(shift);
    return $self;
}   

1;

__DATA__

=head1 NAME

Kwiki::Users - Kwiki Users Base Class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Brian Ingerson <INGY@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2004. Brian Ingerson. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut

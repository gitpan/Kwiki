package Kwiki::Registry;
use strict;
use warnings;
use Spoon::Registry '-Base';

const registry_directory => './plugin';

sub add {
    my ($key, $value) = @_;
    return super
      unless $key eq 'preference' and @_ == 2;
    super($key, $value->id, object => $value);
}

1;

__DATA__

=head1 NAME

Kwiki::Registry - Kwiki Registry Base Class

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

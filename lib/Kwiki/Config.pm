package Kwiki::Config;
use strict;
use Spoon::Config '-base';

sub default_config {
    {
        config_class => 'Kwiki::Config',
        registry_class => 'Kwiki::Registry',
        hub_class => 'Kwiki::Hub',
        formatter_class => 'Kwiki::Formatter',
    }
}

1;

__END__

=head1 NAME 

Kwiki::Config - Kwiki Configuration Base Class

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

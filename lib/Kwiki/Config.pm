package Kwiki::Config;
use strict;
use warnings;
use Spoon::Config '-Base';

field main_page => 'HomePage';
field database_directory => 'database';
field script_name => undef;

sub init {
    $self->main_page;
    $self->script_name($ENV{SCRIPT_NAME});
}

sub default_classes {
    (
        cgi_class => 'Kwiki::CGI',
        config_class => 'Kwiki::Config',
        cookie_class => 'Kwiki::Cookie',
        formatter_class => 'Kwiki::Formatter',
        hub_class => 'Kwiki::Hub',
        pages_class => 'Kwiki::Pages',
        registry_class => 'Kwiki::Registry',
        template_class => 'Kwiki::Template::TT2',
    )
}

sub default_plugin_classes {
    (
        'Kwiki::Display', 
        'Kwiki::Edit', 
    )
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

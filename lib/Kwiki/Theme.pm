package Kwiki::Theme;
use strict;
use warnings;
use Kwiki::Plugin '-Base';
use Kwiki::Installer '-Base';

const class_id => 'theme';

sub register {
    my $register = shift;
    $register->add(preload => 'theme',
                   priority => 1,
                  );
}

sub init {
    super;
    my $theme_id = $self->theme_id;
    $self->template->add_path("theme/$theme_id/template/tt2")
      if -d "theme/$theme_id/template/tt2";
    $self->hub->css->add_path("theme/$theme_id/css")
      if -d "theme/$theme_id/css";
    $self->hub->javascript->add_path("theme/$theme_id/javascript")
      if -d "theme/$theme_id/javascript";
    $self->hub->css->add_file('kwiki.css');
}

1;

__DATA__

=head1 NAME

Kwiki::Theme - Kwiki Theme Plugin

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

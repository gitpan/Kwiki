package Kwiki::Theme;
use strict;
use warnings;
use Kwiki::Plugin '-Base';

const class_id => 'theme';

sub register {
    my $register = shift;
    $register->add(preload => 'theme',
                   priority => 1,
                  );
}

const default_template_path => "theme/%s/template/tt2";
const default_css_path => "theme/%s/css";
const default_javascript_path => "theme/%s/javascript";
const default_css_file => 'kwiki.css';

sub init {
    super;
    my $theme_id = $self->theme_id;
    my $template_path = 
      sprintf $self->default_template_path, $theme_id;
    $self->template->add_path($template_path)
      if -e $template_path;
    my $css_path = 
      sprintf $self->default_css_path, $theme_id;
    $self->hub->css->add_path($css_path)
      if -e $css_path;
    my $javascript_path = 
      sprintf $self->default_javascript_path, $theme_id;
    $self->hub->javascript->add_path($javascript_path)
      if -e $javascript_path;
    $self->hub->css->add_file($self->default_css_file);
    $self->hub->load_class('cookie');
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

package Kwiki::Config;
use strict;
use warnings;
use Spoon::Config '-Base';
use Kwiki::Installer '-base';

const class_id => 'config';
const class_title => 'Kwiki Configuration';
const config_file => 'config.yaml';
field script_name => undef;
const default_path => [ 'config' ];
field path => [];

sub init {
    $self->script_name($ENV{SCRIPT_NAME});
    $self->add_path(@{$self->default_path});
    $self->add_file($self->config_file);
}

sub paired_arguments { qw(-plugins) }
sub new {
    my ($args, @configs) = $self->parse_arguments(@_);
    $self = $self->SUPER::new(@configs);
    $self->add_plugins_file($args->{-plugins})
      if $args->{-plugins};
    return $self;
}

sub add_plugins_file {
    my $plugins_file = shift;
    return unless -f $plugins_file;
    my @plugins = grep {
        s/^([\w\:]+)\s*$/$1/;
    } io($plugins_file)->slurp;
    $self->add_config({plugin_classes => \@plugins});
}

sub default_classes {
    (
        cgi_class => 'Kwiki::CGI',
        command_class => 'Kwiki::Command',
        config_class => 'Kwiki::Config',
        cookie_class => 'Kwiki::Cookie',
        css_class => 'Kwiki::CSS',
        files_class => 'Kwiki::Files',
        formatter_class => 'Kwiki::Formatter',
        hub_class => 'Kwiki::Hub',
        javascript_class => 'Kwiki::Javascript',
        pages_class => 'Kwiki::Pages',
        preferences_class => 'Kwiki::Preferences',
        registry_class => 'Kwiki::Registry',
        template_class => 'Kwiki::Template::TT2',
        users_class => 'Kwiki::Users',
    )
}

sub add_file {
    my $file = shift
      or return;
    my $file_path = '';
    for (@{$self->path}) {
        $file_path = "$_/$file", last
          if -f "$_/$file";
    }
    return unless $file_path;
    my $hash = $self->hash_from_file($file_path);
    for my $key (keys %$hash) {
        next if defined $self->{$key};
        field $key;
        $self->{$key} = $hash->{$key};
    }
}

sub add_path {
    splice @{$self->path}, 0, 0, @_;
}

sub get_packed_files {
    my @return;
    my @packed = super;
    while (my ($name, $content) = splice(@packed, 0, 2)) {
        if ($name =~ /^(plugins|config\.yaml)$/) {
            next if -f $name;
        }
        push @return, $name, $content;
    }
    @return;
}

1;

__DATA__

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

__config/config.yaml__
site_title: Kwiki
main_page: HomePage
database_directory: database
character_encoding: UTF-8
__config.yaml__
logo_image: palm90.png
__plugins__
Kwiki::Display
Kwiki::Edit
Kwiki::Htaccess
Kwiki::Theme::Basic
Kwiki::Toolbar
Kwiki::Widgets

package Kwiki::Config;
use Spoon::Config -Base;
use mixin 'Kwiki::Installer';

const class_id => 'config';
const class_title => 'Kwiki Configuration';
const config_file => 'config.yaml';
field script_name => '';
const default_path => [ 'config' ];
field path => [];
field plugins_file => '';

sub init {
    $self->add_path(@{$self->default_path});
    $self->add_file($self->config_file);
}

sub paired_arguments { qw(-plugins) }
sub new {
    my ($args, @configs) = $self->parse_arguments(@_);
    $self = super(@configs);
    if (my $plugins_file = $args->{-plugins}) {
        $self->add_plugins_file($plugins_file);
        $self->plugins_file($plugins_file);
    }
    return $self;
}

sub add_plugins_file {
    my $plugins_file = shift;
    return unless -f $plugins_file;
    $self->add_config(
        {
            plugin_classes => [ $self->read_plugins($plugins_file) ],
        }
    );
}

sub read_plugins {
    my $plugins_file = io(shift);
    my @plugins = grep {
        s/^([\+\-]?[\w\:]+)\s*$/$1/;
    } $plugins_file->slurp;
    return @plugins unless grep /^[\+\-]/, @plugins or not @plugins;
    my $filename = $plugins_file->filename;
    die "Can't create plugins list"
      unless -e "../$filename";
    my $updir = io->updir->chdir;
    my @parent_plugins = $self->read_plugins($filename);
    for (@plugins) {
        my $remove = $_;
        $remove =~ s/^\-// or next;
        @parent_plugins = grep {$_ ne $remove} @parent_plugins;
    }
    my %have;
    @have{@parent_plugins} = ('1') x @parent_plugins;
    return @parent_plugins, grep {
        not /^\-/ and do {
            s/^\+//;
            not $have{$_};
        }
    } @plugins;
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
        headers_class => 'Spoon::Headers',
        hub_class => 'Kwiki::Hub',
        javascript_class => 'Kwiki::Javascript',
        pages_class => 'Kwiki::Pages',
        preferences_class => 'Kwiki::Preferences',
        registry_class => 'Kwiki::Registry',
        template_class => 'Kwiki::Template::TT2',
        users_class => 'Kwiki::Users',
    )
}

sub add_plugin {
    push @{$self->plugin_classes}, shift;
}

sub change_plugin {
    my ($new_class, $old_class) = @_;
    my $pattern = $old_class || do {
        my $temp = $new_class;
        $temp =~ s/^\w+:://;
        '\w+::' . $temp;
    };
    my $plugins = $self->plugin_classes;
    for (@$plugins) {
        last if s/$pattern/$new_class/;
    }
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

__DATA__

=head1 NAME 

Kwiki::Config - Kwiki Configuration Base Class

=head1 SYNOPSIS

    $self->hub->config->main_page;
    $self->config->site_title;

In templates:

    [% hub.config.script_name %]

=head1 DESCRIPTION

This class defines a singleton object that contains all the various
configuration values in your kwiki system. The configuration values come
from many different places.

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
logo_image: palm90.png
script_name: index.cgi
__!config.yaml__
# Put all local overrides/modifications to the config/* files in this
# file. Do not modify any of the files under the config/ directory as
# they will be overwritten by subsequent upgrades to Kwiki modules.
# See: http://www.kwiki.org/?ChangingConfigDotYaml
#
logo_image: palm90.png
__!plugins__
# This is a list of all the plugins your Kwiki is currently set up to use.
# Modify this list to suit your needs. After modification, run 'kwiki -update'
# to make the changes live. Alternately use 'kwiki -add ...', 
# 'kwiki -remove ...', and 'kwiki -install ...' to manage this list for you.
# See http://www.kwiki.org/InstallingPlugins
#
Kwiki::Display
Kwiki::Edit
Kwiki::Theme::Basic
Kwiki::Toolbar
Kwiki::Status
Kwiki::Widgets

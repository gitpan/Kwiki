package Kwiki::Command;
use strict;
use warnings;
use Kwiki::Base '-Base';

sub init {
    $self->use_class('config');
}

sub boolean_arguments { qw(-install -new -update -compress) }
sub process {
    my ($args, @values) = $self->parse_arguments(@_);
    return $self->new_kwiki if $args->{-new} or $args->{-install};
    return $self->update_kwiki if $args->{-update};
    return $self->compress_kwiki(@values) if $args->{-compress};
    return $self->usage;
}

sub new_kwiki {
    my @files = io('.')->all;
    die "Can't make new kwiki in a non-empty directory\n"
      if @files;
    $self->add_new_default_config;
    $self->install('files');
    $self->install('config');
    $self->install('display');
    $self->install('edit');
    $self->install('formatter');
    $self->install('pages');
    $self->install('theme');
    $self->install('toolbar');
    $self->install('widgets');
    $self->install('htaccess');
    $self->set_permissions;
    $self->create_registry;
    warn "\nKwiki software installed! Point your browser at this location.\n\n";
}

sub add_new_default_config {
    $self->hub->config->add_config(
        {
            display_class => 'Kwiki::Display',
            edit_class => 'Kwiki::Edit',
            files_class => 'Kwiki::Files',
            theme_class => 'Kwiki::Theme::Basic',
            toolbar_class => 'Kwiki::Toolbar',
            widgets_class => 'Kwiki::Widgets',
            htaccess_class => 'Kwiki::Htaccess',
        }
    );
}

sub install {
    my $class_id = shift;
    my $object = $self->hub->load_class($class_id)
      or return;
    return unless $object->can('extract_files');
    my $class_title = $self->hub->$class_id->class_title;
    warn "Extracting files for $class_title:\n";
    $self->hub->$class_id->extract_files;
    warn "\n";
}

sub update_kwiki {
    $self->install($_) for $self->all_class_ids;
    $self->set_permissions;
    $self->create_registry;
}

sub all_class_ids {
    my @all_modules;
    for my $key (keys %{$self->config}) {
        push @all_modules, $self->config->{$key}
          if $key =~ /_class/;
    }
    push @all_modules, @{$self->config->{plugin_classes} || []};
    map {
        eval "require $_; 1"
        ? $_->can('extract_files')
          ? do {
              my $class_id = $_->class_id;
              $self->hub->config->add_config({"${class_id}_class" => $_});
              ($_->class_id)
          }
          : ()
        : ();
    } @all_modules;
}

sub compress_kwiki {
    Spoon::Installer::compress_lib($self, @_);
}

sub set_permissions {
    my $umask = umask 0000;
    chmod 0777, qw(database plugin);
    chmod 0666, qw(database/HomePage);
    chmod 0755, qw(index.cgi);
    umask $umask;
}

sub create_registry {
    my $hub = Kwiki->new->load_hub('config.yaml', -plugins => 'plugins');
    my $registry = $hub->load_class('registry');
    my $registry_path = $registry->registry_path;
    warn "Generating Kwiki Registry '$registry_path'\n";
    $registry->update;
}

sub usage {
    warn <<END;
usage:
  kwiki -new                  # Generate a new Kwiki in an empty directory
  kwiki -install              # Same as kwiki -new
  kwiki -update               # Upgrade an existing Kwiki
END
}

1;

__DATA__

=head1 NAME 

Kwiki::Command - Kwiki Command Line Installer Module

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

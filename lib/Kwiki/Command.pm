package Kwiki::Command;
use strict;
use warnings;
use Kwiki::Base '-Base';

sub init {
    $self->use_class('config');
}

sub boolean_arguments { qw(-new -update -add -remove -install -compress) }
sub process {
    my ($args, @values) = $self->parse_arguments(@_);
    return $self->new_kwiki(@values)
      if $args->{-new};
    return $self->update_kwiki(@values)
      if $args->{-update};
    return $self->update_plugins('+', @values)
      if $args->{-add};
    return $self->update_plugins('-', @values)
      if $args->{-remove};
    return $self->install_plugins(@values)
      if $args->{-install};
    return $self->compress_kwiki(@values)
      if $args->{-compress};
    return $self->usage;
}

sub new_kwiki {
    chdir io->dir(shift || '.')->assert->open . '';
    die "Can't make new Kwiki in a non-empty directory\n"
      unless io('.')->empty;
    $self->add_new_default_config;
    $self->install('files');
    $self->install('config');
    $self->create_registry;
    $self->hub->load_registry;
    $self->install('display');
    $self->install('edit');
    $self->install('formatter');
    $self->install('users');
    $self->install('pages');
    $self->install('theme');
    $self->install('toolbar');
    $self->install('status');
    $self->install('widgets');
    $self->install('htaccess');
    $self->set_permissions;
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
            status_class => 'Kwiki::Status',
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
    chdir io->dir(shift || '.')->assert->open . '';
    die "Can't update non Kwiki directory!\n"
      unless -d 'plugin';
    $self->create_registry;
    $self->hub->load_registry;
    $self->install($_) for $self->all_class_ids;
    $self->set_permissions;
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

sub update_plugins {
    die "This operation must be performed inside a Kwiki installation directory"
      unless -f $self->config->plugins_file;
    my $mode = shift;
    return $self->usage unless @_;
    my $plugins_file = $self->config->plugins_file;
    my $plugins = io($plugins_file);
    my @lines = $plugins->chomp->slurp;
    for my $module (@_) {
        eval "require $module;1" or die $@ or
          ($module = "Kwiki::$module" and eval "require $module;1") or
            die "Invalid module '$module'";
        if ($mode eq '+') {
            next if grep /^$module$/, @lines;
            push @lines, $module;
            next;
        }
        @lines = grep {$_ ne $module} @lines;
    }
    $plugins->println($_) for @lines;
    $plugins->close;
    $self->config->add_plugins_file($plugins_file);
    $self->update_kwiki;
}

sub install_plugins {
    die "This operation must be performed inside a Kwiki installation directory"
      unless -f $self->config->plugins_file;
    return $self->usage unless @_;
    require Cwd;
    $self->cpan_setup;
    my @modules = @_;
    for (@_) {
        $self->fake_install($_);
        my $home = Cwd::cwd();
        CPAN::Shell->expand('Module', $_)->install;
        chdir $home;
    }
    $self->update_plugins('+', @modules);
}

sub cpan_setup {
    no warnings;
    require CPAN;
    require CPAN::Config;
    my $lib = io->dir('lib')->absolute;
    $ENV{PERL_MM_OPT} = "INSTALLSITELIB=$lib PREFIX=$lib"
      if $lib->exists;
    CPAN::Config->load;
    $CPAN::Config_loaded = 1;
    my $cpan_dir = io->dir('.cpan')->rel2abs;
    $CPAN::Config->{cpan_home} =
    $CPAN::Config->{build_dir} = $cpan_dir;
    $CPAN::Config->{keep_source_where} = 
      io->catdir($cpan_dir, 'sources')->name;
}

sub fake_install {
    return unless -d 'lib';
    my $module = shift;
    $module =~ s/::/\//g;
    $module .= '.pm';
    my $file = io->catfile('lib', $module);
    $file->assert->touch
      unless -f $file->name;
}

sub compress_kwiki {
    require Spoon::Installer;
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
  kwiki -new [path]           # Generate a new Kwiki
  kwiki -update [path]        # Upgrade an existing Kwiki
  kwiki -add Kwiki::Foo       # Add a plugin
  kwiki -remove Kwiki::Foo    # Remove a plugin
  kwiki -install Kwiki::Foo   # Download and install a plugin
END
}

1;

__DATA__

=head1 NAME 

Kwiki::Command - Kwiki Command Line Tool Module

=head1 SYNOPSIS

    > kwiki -new mykwiki
    > cd mykwiki
    > kwiki -install Kwiki::RecentChanges Kwiki::Archive::Rcs Kwiki::Revisions
    > vim config.yaml
    > kwiki -update
    > kwiki -remove RecentChanges

=head1 DESCRIPTION

Kwiki::Command is the module that does all the work of the C<kwiki>
command line tool. You can use C<kwiki> to install a new Kwiki, to
update a Kwiki configuration, to add and remove Kwiki plugins and to
download Kwiki plugins from CPAN. When you download the CPAN modules
they can either be installed in the system Perl libraries or locally
right in your kwiki dist. This is useful if you don't have root
permissions for your installation.

=head1 USAGES

There are many different commands you can do with the C<kwiki> command line
tool.

=over 4

=item * -new

Create a new kwiki with the command:

    kwiki -new

You must be inside an empty directory. Alternatively you can say:

    kwiki -new path/to/kwiki

The target directory must be empty or must not exist yet.

=back

=head1 AUTHOR

Brian Ingerson <INGY@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2004. Brian Ingerson. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut

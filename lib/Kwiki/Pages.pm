package Kwiki::Pages;
use strict;
use warnings;
use Kwiki::Base '-Base';
use mixin 'Kwiki::Installer';

const class_id => 'pages';
const class_title => 'Kwiki Pages';
const page_class => 'Kwiki::Page';
const meta_class => 'Kwiki::PageMeta';

sub init {
    $self->use_class('cgi');
    $self->use_class('config');
}

sub all {
    map {
        $self->new_page($_->filename)
    } io($self->current->database_directory)->all_files;
}

sub all_ids_newest_first {
    my $path = $self->current->database_directory;
    map {chomp; $_} `ls -1t $path`;
}   

sub all_since {
    my ($minutes) = @_;
    my @pages_since;
    for my $page_id ($self->all_ids_newest_first) {
        my $page = $self->new_page($page_id);
        last if $page->age_in_minutes > $minutes;
        push @pages_since, $page;
    }   
    return @pages_since;
}

sub current {
    return $self->{current} = shift if @_;
    return $self->{current} if defined $self->{current};
    return $self->{current} = $self->new_page($self->current_id);
}

sub current_id {
    return $self->cgi->page_id ||
           $self->uri_escape($self->config->main_page)
           or die;
}

sub new_page {
    my $page_id = shift;
    my $page = $self->page_class->new($self->hub, $page_id);
    $page->metadata($self->new_metadata($page_id));
    return $page;
}

sub new_metadata {
    my $page_id = shift or die;
    $self->meta_class->new($self->hub, $page_id);
}

sub kwiki_link {
    $self->new_page(shift)->kwiki_link;
}

package Kwiki::Page;
use Kwiki::ContentObject '-base';
use Kwiki ':char_classes';

field class_id => 'page';

sub database_directory {
    $self->hub->config->database_directory;
}

sub content {
    return $self->{content} = shift if @_;
    return $self->{content} if defined $self->{content};
    $self->load_content;
    return $self->{content};
}

sub metadata {
    return $self->{metadata} = shift if @_;
    $self->{metadata} ||= 
      $self->meta_class->new($self->hub, $self->id);
    return $self->{metadata} if $self->{metadata}->loaded;
    $self->load_metadata;
    return $self->{metadata};
}

sub update {
    $self->metadata->update($self);
    return $self;
}

sub store {
    super or return;
    my $hooks = $self->hub->registry->lookup->{page_store_hook}
      or return;
    for my $method (keys %$hooks) {
        my $class_id = $hooks->{$method}[0];
        $self->hub->load_class($class_id)->$method($self);
    }
}

sub kwiki_link {
    my ($label) = @_;
    my $page_id = $self->id;
    $label = $page_id
      unless defined $label;
    my $script = $self->hub->config->script_name || 'index.cgi';
    my $class = $self->active
      ? '' : ' class="empty"';
    qq(<a href="$script?$page_id"$class>$label</a>);
}

sub edit_by_link {
    my $user_name = $self->metadata->edit_by || 'UnknownUser';
    $user_name = $self->hub->config->user_default_name
      if $user_name =~ /[^$ALPHANUM]/;
    $self->hub->pages->kwiki_link($user_name);
}

sub edit_time {
    my $edit_time = $self->metadata->edit_unixtime ||
                    $self->modified_time;
    return $self->hub->have_plugin('time_zone')
    ? $self->hub->time_zone->format($edit_time)
    : $self->format_time($edit_time);
}

sub format_time {
    my $unix_time = shift;
    my $formatted = scalar gmtime $unix_time;
    $formatted .= ' GMT' 
      unless $formatted =~ /GMT$/;
    return $formatted;
}

sub modified_time {
    io->catfile($self->database_directory, $self->id)->mtime || 0;
}

sub age {
    $self->age_in_minutes;
}

sub age_in_minutes {
    $self->age_in_seconds / 60;
}

sub age_in_seconds {
    return $self->{age_in_seconds} = shift if @_;
    return $self->{age_in_seconds} if defined $self->{age_in_seconds};
    my $path = $self->database_directory;
    my $page_id = $self->id;
    return $self->{age_in_seconds} = int((-M "$path/$page_id") * 86400);
}

sub all {
    return (
        page_id => $self->id,
    );
}

sub to_html {
    my $content = @_ ? shift : $self->content; 
    $self->hub->load_class('formatter');
    $self->hub->formatter->text_to_html($content);
}

sub revision_number {
    $self->hub->load_class('archive')->revision_number($self);
}

package Kwiki::PageMeta;
use strict;
use warnings;
use Spoon::MetadataObject '-base';
use Kwiki::Plugin '-base';

const class_id => 'page_metadata';
field loaded => 0;

field edit_by => '';
field edit_time => '';
field edit_unixtime => '';

sub sort_order {
    qw(edit_by edit_time edit_unixtime)
}

sub file_path {
    join '/', $self->plugin_directory, $self->id;
}

sub load {
    $self->loaded(1);
    my $file_path = $self->file_path;
    return unless -f $file_path;
    my $hash = $self->parse_yaml_file($file_path);
    $self->from_hash($hash);
}

sub update {
    my $page = shift;
    $self->edit_by($self->hub->users->current->name);
    my $unixtime = time;
    $self->edit_time(scalar gmtime($unixtime));
    $self->edit_unixtime($unixtime);
}

sub store {
    my $file_path = $self->file_path;
    my $hash = $self->from_hash;
    $self->print_yaml_file($file_path, $hash);
}

package Kwiki::Pages;

1;
__DATA__

=head1 NAME

Kwiki::Pages - Kwiki Pages Base Class

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
__!database/HomePage__
=== Welcome to Your New Kwiki!

You have successfully installed a new Kwiki. Now you should /edit this page/ and start adding NewPages. For help on Kwiki syntax and other Kwiki issues, visit http://www.kwiki.org/?KwikiHelpIndex.

If this installation looks more mundane than you had expected after visiting Kwiki sites like http://www.kwiki.org, you need to install some *Kwiki plugins*. Some of the basic plugins you might want are:

* Kwiki::!RecentChanges
* Kwiki::Search
* Kwiki::!UserPreferences
* Kwiki::!UserName
* Kwiki::Archive::Rcs
* Kwiki::Revisions

These plugin modules are available on [CPAN http://search.cpan.org/search?query=kwiki&mode=dist]. Visit http://www.kwiki.org/?KwikiPluginInstallation to learn more about installing plugins.

--[http://www.kwiki.org/?BrianIngerson Brian Ingerson]

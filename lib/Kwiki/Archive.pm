package Kwiki::Archive;
use strict;
use warnings;
use Kwiki::Plugin '-Base';

const class_id => 'archive';
const class_title => 'Page Archive';

field 'user_name';

sub register {
    my $registry = shift;
    $registry->add(page_hook_store => 'commit');
}

sub init {
    $self->use_class('pages');
    if ($self->empty) {
        $self->generate;
        $self->user_name('kwiki-install');
        $self->commit_all;
    };
}

sub empty {
    io($self->plugin_directory)->empty;
}

sub generate {
    my $dir = $self->plugin_directory;
    umask 0000;
    chmod 0777, $dir;
}

sub commit_all {
    for my $page ($self->pages->all) {
        $self->commit($page);
    }
}

sub page_properties {
    my $page = shift;
    return {
        edit_by => $self->user_name || $page->metadata->edit_by,
        edit_time => $page->metadata->edit_time || scalar(gmtime),
        edit_unixtime => $page->metadata->edit_unixtime || scalar(time)
    };
}

sub revision_number {
    $self->history(shift)->[0]->{revision_id} || 0;    
}


1;

__DATA__

=head1 NAME 

Kwiki::Archive - Kwiki Page Archive Plugin Base Class

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

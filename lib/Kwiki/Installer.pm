package Kwiki::Installer;
use strict;
use warnings;
use Spoon::Installer '-Base';
use IO::All;

sub extract_files {
    my @files = $self->get_packed_files;
    while (@files) {
        my ($file_name, $file_contents) = splice(@files, 0, 2);
        my $file_path = join '/', $self->extract_to, $file_name;
        my $file = io($file_path)->assert;
        if (-f $file_path and $file->scalar eq $file_contents) {
            warn "  Skipping $file (unchanged)\n";
            next;
        }
        warn "  - $file\n";
        $self->set_file_content($file_path, $file_contents);
    }
}

1;

__DATA__

=head1 NAME

Kwiki::Installer - Kwiki Installer Base Class

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

package Kwiki::CSS;
use strict;
use warnings;
use Kwiki::Base '-Base';

const class_id => 'css';
const default_path => [ 'css' ];
field path => [];
field files => [];

sub init {
    $self->add_path(@{$self->default_path});
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
    my $files = $self->files;
    @$files = grep { not /\/$file$/ } @$files;
    push @$files, $file_path;
}

sub add_path {
    splice @{$self->path}, 0, 0, @_;
}

1;

__DATA__

=head1 NAME

Kwiki::CSS - Kwiki CSS Base Class

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

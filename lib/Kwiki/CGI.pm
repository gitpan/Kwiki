package Kwiki::CGI;
use strict;
use warnings;
use Spoon::CGI '-Base';
use Kwiki ':char_classes';

sub init {
    $self->add_params('page_id');
}

cgi 'action';
cgi 'button';

sub page_id {
    return $self->{page_id} = shift if @_;
    return $self->{page_id}
      if defined $self->{page_id};
    my $page_id = CGI::param('page_id');
    if (not defined $page_id) {
        my $query_string = CGI::query_string();
        $query_string =~ s/%([0-9a-fA-F]{2})/pack("H*", $1)/ge;
        if ($query_string =~ /^keywords=/) {
            $page_id = join ' ', grep $_, split /;?keywords=/, $query_string;
        }
        elsif ($ENV{QUERY_STRING} and $ENV{QUERY_STRING} =~ /[^=&]+&/) {
            ($page_id = $ENV{QUERY_STRING}) =~ s/(.*?)\&.*/$1/;
        }
    }
    $page_id = $self->uri_unescape($page_id);
    $page_id = '' if $page_id and $page_id =~ /[^$ALPHANUM]/;
    $page_id ||= $self->hub->config->main_page;
    $self->{page_id} = $page_id;
}

1;

__DATA__

=head1 NAME 

Kwiki::CGI - Kwiki CGI Base Class

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

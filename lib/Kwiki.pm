package Kwiki;
use strict;
use Spoon 0.13 '-base';
our $VERSION = '0.29_50';

const config_class => 'Kwiki::Config';

sub process {
    my $self = shift;
    $self->run_cgi(@_);
}

sub run_cgi {
    my $self = shift;
    my $hub = $self->load_hub(@_);
    my $html = $hub->process;
    if (defined $html) {
        if (ref $html) {
            print CGI::redirect($html->{redirect});
        } 
        else {
            $hub->load_class('cookie');
            my $header = $hub->cookie->header;
            $hub->encode($header);
            $hub->encode($html);
            print $header, $html;
        }
    }
    close STDOUT unless $self->using_debug;
    $hub->post_process;
}

# TODO Support CGI::Fast and mod_perl

1;

__END__

=head1 NAME 

Kwiki - The Kwiki Wiki Building Framework

=head1 SYNOPSIS

    use Kwiki;
    print Kwiki->new->debug->load_hub->load_class('formatter')->text_to_html($wiki_text);

=head1 DESCRIPTION

NOTE: This release of Kwiki is for developer experimentation only. It
      does not even produce a working wiki yet.

=head1 AUTHOR

Brian Ingerson <INGY@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2004. Brian Ingerson. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut

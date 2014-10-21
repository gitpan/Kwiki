package Kwiki;
use strict;
use warnings;
use Spoon 0.16 '-Base';
our $VERSION = '0.31';

const config_class => 'Kwiki::Config';

sub process {
    my $hub = $self->load_hub(@_);
    my $html = $hub->process;
    if (defined $html) {
        if (ref $html) {
            print CGI::redirect($html->{redirect});
        } 
        else {
            my $header = $hub->load_class('cookie')->header;
            $self->utf8_encode($header);
            $self->utf8_encode($html);
            print $header, $html;
        }
    }
    close STDOUT unless $self->using_debug;
    $hub->post_process;
}

1;

__DATA__

=head1 NAME

Kwiki - The Kwiki Wiki Building Framework

=head1 SYNOPSIS

    > kwiki -new cgi-bin/my-kwiki

    Kwiki software installed! Point your browser at this location.

=head1 DESCRIPTION

A Wiki is a website that allows its users to add pages, and edit any
existing pages. It is one of the most popular forms of web
collaboration. If you are new to wiki, visit
http://c2.com/cgi/wiki?WelcomeVisitors which is possibly the oldest
wiki, and has lots of information about how wikis work.

Kwiki is a Perl wiki implementation based on the Spoon application
architecture and using the Spiffy object orientation model. The major
goals of Kwiki are that it be easy to install, maintain and extend.

All the features of a Kwiki wiki come from plugin modules. The base
installation comes with the bare minimum plugins to make a working
Kwiki. To make a really nice Kwiki installation you need to install
additional plugins. Which plugins you pick is entirely up to you.
Another goal of Kwiki is that every installation will be unique.
When there are hundreds of plugins available, this will hopefully
be the case.

=head1 CGI::Kwiki

Kwiki is the successor of the popular CGI::Kwiki software. It is a
complete refactoring of that code. The new code has a lovely plugin API
and is much cleaner and extendable on all fronts.

There is currently no automated way to upgrade a CGI::Kwiki installation
to Kwiki. It's actually quite easy to do by hand. Instructions on how to
do it are here: http://www.kwiki.org/?KwikiMigrationByHand

=head1 RELEASE NOTES

This is the first release of the Kwiki distribution. I know that the
documentation is lacking. Please refer to http://www.kwiki.org for the
latest information. Proper documentation will follow soon.

=head1 CREDITS

I am currently employed by Socialtext, Inc. They make high quality
social software for enterprise deployment. Socialtext has a bold new
vision of building their products over Open Source software and
returning the generic source code to the community. This results in a
win/win effect for both entities. You get this shiny new wiki framework,
and Socialtext can take advantage of your plugins and bug fixes.

The Kwiki project would not be where it is now without their support. I
thank them.

 ---

Iain Truskett was probably the most active Kwiki community hacker before
his untimely death in Dec 2003. The underlying foundation of Kwiki has
been named "Spoon" in his honor. Rest in peace Spoon.

 ---

Ian (what's with all these Iai?ns??) Langworth has become a new Kwiki
warrior. He helped a lot with the maiden release. Expect a lot of
plugins to come from him! Thanks Ian.

 ---

Finally, big props to all the folks on http://www.kwiki.org and
irc://irc.freenode.net/#kwiki. Thanks for all the support!

=head1 AUTHOR

Brian Ingerson <INGY@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2004. Brian Ingerson. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut

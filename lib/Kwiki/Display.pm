package Kwiki::Display;
use strict;
use warnings;
use Kwiki::Plugin '-Base';

const class_id => 'display';
const screen_template => 'display_page_content.html';

sub register {
    my $registry = shift;
    $registry->add(action => 'display');
    $registry->add('has_preferences');
}

sub init {
    super;
    $self->add_preference($self->underline_links);
}

sub underline_links {
    my $p = $self->new_preference('underline_links');
    $p->query('Should hyperlinks be underlined?');
    $p->default(0);
    return $p;
}

sub display {
    my $page = $self->pages->current;
    return $self->redirect('action=edit&page_id=' . $page->id)
      unless $page->content;
    $self->render_screen(
        display_content => $self->pages->current->to_html,
    );
}

1;

__END__

=head1 NAME 

Kwiki::Display - Kwiki Page Display Plugin

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

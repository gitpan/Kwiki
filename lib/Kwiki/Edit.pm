package Kwiki::Edit;
use strict;
use warnings;
use Kwiki::Plugin '-Base';
# use Kwiki::Install '-base';

const class_id => 'edit';
const cgi_class => 'Kwiki::Edit::CGI';
const screen_template => 'edit_page_content.html';

sub register {
    my $registry = shift;
    $registry->add(action => 'edit');
}

sub edit {
    return $self->save
      if $self->cgi->Button eq 'SAVE';
    return $self->preview
      if $self->cgi->Button eq 'PREVIEW';
    $self->render_screen(
        page_content => $self->pages->current->content,
    );
}

sub save {
    my $page = $self->pages->current;
    $page->content($self->cgi->page_content);
    $page->store;
    return $self->redirect($page->id);
}

sub preview {
    $self->use_class('formatter');
    my $preview = $self->formatter->text_to_html($self->cgi->page_content);
    $self->render_screen(
        preview_content => $preview,
    );
}

package Kwiki::Edit::CGI;
use base 'Kwiki::CGI';

cgi 'Button';
cgi 'page_content' => qw(-newlines);

1;

__END__

=head1 NAME 

Kwiki::Edit - Kwiki Page Edit Plugin

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

__config/edit.yaml__
edit_save_button: SAVE
edit_preview_button: PREVIEW

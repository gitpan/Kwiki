package Kwiki::Edit;
use strict;
use warnings;
use Kwiki::Plugin '-Base';
use Kwiki::Installer '-base';

const class_id => 'edit';
const class_title => 'Page Edit';
const cgi_class => 'Kwiki::Edit::CGI';
const screen_template => 'edit_screen.html';
const config_file => 'edit.yaml';

sub register {
    my $registry = shift;
    $registry->add(action => 'edit');
    $registry->add(action => 'edit_contention');
    $registry->add(toolbar => 'edit_button', 
                   template => 'edit_button.html',
                   show_for => ['display', 'revisions', 'edit_contention'],
                  );
}

sub edit {
    return $self->save
      if $self->cgi->button eq $self->config->edit_save_button_text;
    return $self->preview
      if $self->cgi->button eq $self->config->edit_preview_button_text;
    my $page = $self->pages->current;
    my $content = $self->cgi->revision_id
      ? $self->hub->load_class('archive')->fetch($page, $self->cgi->revision_id)
      : $page->content;
    $content ||= $self->config->default_content;
    $self->render_screen(
        page_content => $content,
        page_time => $page->modified_time,
    );
}

sub save {
    my $page = $self->pages->current;
    $page->content($self->cgi->page_content);
    if ($page->modified_time != $self->cgi->page_time) {
        my $page_id = $page->id;
        return $self->redirect("action=edit_contention&page_id=$page_id");
    }
    $page->update->store;
    return $self->redirect($page->id);
}

sub preview {
    $self->use_class('formatter');
    my $preview = $self->formatter->text_to_html($self->cgi->page_content);
    $self->render_screen(
        preview_content => $preview,
    );
}

sub edit_contention {
    return $self->template->process('edit_contention.html');
}

package Kwiki::Edit::CGI;
use base 'Kwiki::CGI';

cgi 'page_content' => qw(-newlines);
cgi 'revision_id';
cgi 'page_time';

1;

package Kwiki::Edit;

__DATA__

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
edit_save_button_text: SAVE
edit_preview_button_text: PREVIEW
default_content: Enter your own page content here.
__template/tt2/edit_button.html__
<!-- BEGIN edit_button.html -->
[% rev_id = hub.revisions.revision_id %]
<a href="[% script_name %]?action=edit&page_id=[% page_id %][% IF rev_id %]&revision_id=[% rev_id %][% END %]" accesskey="e" title="Edit This Page">
[% INCLUDE edit_button_icon.html %]
</a>
<!-- END edit_button.html -->
__template/tt2/edit_button_icon.html__
<!-- BEGIN edit_book_button_icon.html -->
Edit
<!-- END edit_book_button_icon.html -->
__template/tt2/edit_contention.html__
<!-- BEGIN edit_contention.html -->
[% INCLUDE kwiki_layout_begin.html -%]
<div class="error">
<p>
While you were editing this page somebody else saved changes to
it. You need to start over and apply your changes to the latest
copy of the page.
</p>
<p>
You may also get this message if you saved some changes and then used
your browser's back button to return to the Edit screen and make more
changes. Always use the Kwiki Edit button to get to the Edit screen.
</p>
</div>
[% INCLUDE kwiki_layout_end.html -%]
<!-- END edit_contention.html -->
__template/tt2/edit_screen.html__
<!-- BEGIN edit_screen.html -->
[% INCLUDE kwiki_layout_begin.html %]
<script language="JavaScript" type="text/JavaScript"><!--
function clear_default_content(content_box) {
    if (content_box.value == '[% default_content %]') {
        content_box.value = '';
    }
}
--></script>
[% IF button == edit_preview_button_text %]
[% preview_content %]
<hr />
[% END %]
<form method="POST">
<input type="submit" name="button" value="[% edit_save_button_text %]" />
<input type="submit" name="button" value="[% edit_preview_button_text %]" />
<br />
<br />
<input type="hidden" name="action" value="edit" />
<input type="hidden" name="page_id" value="[% page_id %]" />
<input type="hidden" name="page_time" value="[% page_time %]" />
<textarea name="page_content" rows="25" cols="80" onfocus="clear_default_content(this)">
[%- page_content -%]
</textarea>
</form>
[% INCLUDE kwiki_layout_end.html %]
<!-- END edit_screen.html -->

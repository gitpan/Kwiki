package Kwiki::Display;
use strict;
use warnings;
use Kwiki::Plugin '-Base';
use Kwiki::Installer '-base';

const class_id => 'display';
const class_title => 'Page Display';
const screen_template => 'display_screen.html';

sub register {
    my $registry = shift;
    $registry->add(action => 'display');
    $registry->add(toolbar => 'home_button', 
                   template => 'home_button.html',
                  );
    $registry->add(preference => 'display_changed_by',
                   object => $self->display_changed_by
                  );
}

sub display_changed_by {
    my $p = $self->new_preference('display_changed_by');
    $p->query('Show a "Changed by ..." section on each page?');
    $p->default(0);
    return $p;
}

sub display {
    my $page = $self->pages->current;
    return $self->redirect('action=edit&page_id=' . $page->id)
      unless $page->exists;
    $self->page($page);
    $self->render_screen(page_html => $page->to_html);
}

1;

__DATA__

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
__template/tt2/home_button.html__
<!-- BEGIN home_button.html -->
<a href="[% script_name %]?[% main_page %]" accesskey="h" title="Home Page">
[% INCLUDE home_button_icon.html %]
</a>
<!-- END home_button.html -->
__template/tt2/home_button_icon.html__
<!-- BEGIN home_button_icon.html -->
Home
<!-- END home_button_icon.html -->
__template/tt2/display_screen.html__
<!-- BEGIN display_screen.html -->
[% IF hub.have_plugin('search') -%]
[% screen_title = "<a href=\"$script_name?action=search&search_term=$page_id\">$page_id</a>" -%]
[% END -%]
[% INCLUDE kwiki_layout_begin.html -%]
<div class="wiki">
[% page_html -%]
</div>
[% INCLUDE display_changed_by.html %]
[% INCLUDE kwiki_layout_end.html -%]
<!-- END display_screen.html -->
__template/tt2/display_changed_by.html__
<!-- BEGIN display_changed_by.html -->
[% IF hub.preferences.display_changed_by.value %]
[% page = hub.pages.current %]
<div style="background-color: #eee">
<em>
Last changed by [% page.edit_by_link %] at [% page.edit_time %]
</em>
</div>
[% END %]
<!-- END display_changed_by.html -->

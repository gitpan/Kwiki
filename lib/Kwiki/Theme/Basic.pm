package Kwiki::Theme::Basic;
use strict;
use warnings;
use Kwiki::Theme '-Base';
use mixin 'Kwiki::Installer';

const theme_id => 'basic';
const class_title => 'Basic Theme';

1;

__DATA__

=head1 NAME

Kwiki::Theme::Basic - Kwiki Basic Theme

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
__theme/basic/template/tt2/kwiki_screen.html__
[%- INCLUDE kwiki_doctype.html %]
<!-- BEGIN kwiki_screen.html -->
[% INCLUDE kwiki_begin.html %]
<table id="group"><tr>
<td id="group_1">
<div class="navigation">
<div id="title_pane">
<h1>
[% screen_title || self.class_title %]
</h1>
</div>

<div id="toolbar_pane">
[% hub.toolbar.html %]
[% IF hub.have_plugin('user_name') %]
[% INCLUDE user_name_title.html %]
[% END %]
</div>

<div id="status_pane">
[% hub.status.html %]
</div>
</div><!-- navigation -->

<hr />
<div id="content_pane">
[% INCLUDE $content_pane %]
</div>
<hr />

<div class="navigation">
<div id="toolbar_pane_2">
[% hub.toolbar.html %]
</div>
</div><!-- navigation -->
</td>

<td id="group_2">
<div class="navigation">
<div id="logo_pane">
<img src="[% logo_image %]" align="center" alt="Kwiki Logo" title="[% site_title %]" />
</div>
<br/>

<div id="widgets_pane">
[% hub.widgets.html %]
</div>
</div><!-- navigation -->

</td>
</tr></table>
[% INCLUDE kwiki_end.html %]
<!-- END kwiki_screen.html -->
__theme/basic/css/kwiki.css__
#logo_pane {
    text-align: center;
}
    
#logo_pane img {
    width: 90px;
}
    
#group {
    width: 100%;
}

#group_1 {
    vertical-align: top;
}

#group_2 {
    vertical-align: top;
    width: 125px;
}

body {
    background:#fff;        
}

h1, h2, h3, h4, h5, h6 {
    margin: 0px;
    padding: 0px;
    font-weight: bold;
}

.error, .empty {
    color: #f00;
}

div.navigation a:visited {
    color: #00f;
}

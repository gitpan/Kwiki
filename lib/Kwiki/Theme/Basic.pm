package Kwiki::Theme::Basic;
use strict;
use warnings;
use Kwiki::Theme '-Base';

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
__theme/basic/css/kwiki.css__
#logo_pane {
    text-align: center;
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
__theme/basic/css/toolbar.css__
div.toolbar a:visited {
    color: #00f;
}
__theme/basic/template/tt2/html_begin.html__
<!-- BEGIN html_begin.html -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title>[% site_title %]</title>
[% FOR css_file = hub.css.files -%]
  <link rel="stylesheet" type="text/css" href="[% css_file %]" />
[% END -%]
[% FOR javascript_file = hub.javascript.files -%]
  <script type="text/javascript" src="[% javascript_file %]"></script>
[% END -%]
  <link rel="shortcut icon" href="" />
  <link rel="start" href="index.cgi" title="Home" />
</head>
<body>
<!-- END html_begin.html -->
__theme/basic/template/tt2/html_end.html__
<!-- BEGIN html_end.html -->
</body>
</html>
<!-- END html_end.html -->
__theme/basic/template/tt2/kwiki_layout_begin.html__
<!-- BEGIN kwiki_layout_begin.html -->
[% INCLUDE html_begin.html %]
<table id="group"><tr>
<td id="group_1">
<div id="title_pane">
<h1>[% screen_title || page_id %]</h1>
</div>

<div id="toolbar_pane">
[% hub.toolbar.html %]
[% IF hub.have_plugin('user_name') %]
[% INCLUDE user_name_title.html %]
[% END %]
</div>

<div id="content_pane">
<hr />
<!-- END kwiki_layout_begin.html -->
__theme/basic/template/tt2/kwiki_layout_end.html__
<!-- BEGIN kwiki_layout_end.html -->
<hr />
</div>
<div id="toolbar_pane_2">
[% hub.toolbar.html %]
</div>
</td>

<td id="group_2">
<div id="logo_pane">
<img src="[% logo_image %]" align="center" alt="Kwiki Logo" title="[% site_title %]" />
</div>
<br/>
<div id="widgets_pane">
[% hub.widgets.html %]
</div>
</td>
</tr></table>
[% INCLUDE html_end.html %]
<!-- END kwiki_layout_end.html -->

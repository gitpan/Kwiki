package Kwiki::Toolbar;
use strict;
use warnings;
use Kwiki::Plugin '-Base';
use Kwiki::Installer '-base';

const class_id => 'toolbar';
const class_title => 'Kwiki Toolbar';
const toolbar_template => 'toolbar_pane.html';
const css_file => 'toolbar.css';

sub register {
    my $registry = shift;
    $registry->add(preload => 'toolbar');
}

sub html {
    my $lookup = $self->hub->registry->lookup;
    my $tools = $lookup->{toolbar}
      or return '';
    my %toolmap;
    for (keys %$tools) {
        my $array = $tools->{$_};
        push @{$toolmap{$array->[0]}}, {@{$array}[1..$#{$array}]};
    }
    my %classmap = reverse %{$lookup->{classes}};
    my $toolbar_content = join "|\n", grep {
        defined $_ and do {
            my $button = $_;
            $button =~ s/<!--.*?-->//gs;
            $button =~ /\S/;
        }
    } map {
        $self->show($_)
        ? defined($_->{template})
          ? $self->template->process($_->{template})
          : undef
        : undef
    } map {
        defined $toolmap{$_} ? @{$toolmap{$_}} : ()
    } map {
        $classmap{$_}
    } @{$self->hub->config->plugin_classes};
    $self->template->process($self->toolbar_template,
        toolbar_content => $toolbar_content,
    );
}

sub show {
    my $tool = shift;
    my $action = $self->hub->action;
    my $show = $tool->{show_for};
    if (defined $show) {
        for (ref($show) ? (@$show) : ($show)) {
            return 1 if $_ eq $action;
        }
        return 0;
    }
    my $omit = $tool->{omit_for};
    if (defined $omit) {
        for (ref($omit) ? (@$omit) : ($omit)) {
            return 0 if $_ eq $action;
        }
        return 1;
    }
    return 1;
}

1;

__DATA__

=head1 NAME

Kwiki::Toolbar - Kwiki Toolbar Plugin

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
__template/tt2/toolbar_pane.html__
<!-- BEGIN toolbar_pane.html -->
<div class="toolbar">
[% toolbar_content %]
</div>
<!-- END toolbar_pane.html -->

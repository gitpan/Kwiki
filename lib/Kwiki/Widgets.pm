package Kwiki::Widgets;
use strict;
use warnings;
use Kwiki::Plugin '-Base';
use mixin 'Kwiki::Installer';

const class_id => 'widgets';
const widgets_template => 'widgets_pane.html';

sub register {
    my $registry = shift;
    $registry->add(preload => 'widgets');
}

sub html {
    my $lookup = $self->hub->registry->lookup;
    my $widgets = $lookup->{widget}
      or return '';
    my %toolmap;
    for (keys %$widgets) {
        my $array = $widgets->{$_};
        push @{$toolmap{$array->[0]}}, {@{$array}[1..$#{$array}]};
    }
    my %classmap = reverse %{$lookup->{classes}};
    my $widgets_content = join "<br />\n", grep {
        defined $_ and do {
            my $button = $_;
            $button =~ s/<!--.*?-->//gs;
            $button =~ /\S/;
        }
    } map {
        $self->show($_)
        ? defined($_->{template})
          ? $self->template->process($_->{template}, 
              $self->hub->pages->current->all,
          )
          : undef
        : undef
    } map {
        defined $toolmap{$_} ? @{$toolmap{$_}} : ()
    } map {
        $classmap{$_}
    } @{$self->hub->config->plugin_classes};
    $self->template->process($self->widgets_template,
        widgets_content => $widgets_content,
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

Kwiki::Widgets - Kwiki Widgets Base Class

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
__template/tt2/widgets_pane.html__
<!-- BEGIN widgets_pane.html -->
<div class="widgets">
[% widgets_content %]
</div>
<!-- END widgets_pane.html -->

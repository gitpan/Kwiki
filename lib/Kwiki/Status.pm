package Kwiki::Status;
use strict;
use warnings;
use Kwiki::Plugin '-Base';
use mixin 'Kwiki::Installer';

const class_id => 'status';
const status_template => 'status_pane.html';

sub register {
    my $registry = shift;
    $registry->add(preload => 'status');
}

sub html {
    my $lookup = $self->hub->registry->lookup;
    my $status = $lookup->{status}
      or return '';
    my %toolmap;
    for (keys %$status) {
        my $array = $status->{$_};
        push @{$toolmap{$array->[0]}}, {@{$array}[1..$#{$array}]};
    }
    my %classmap = reverse %{$lookup->{classes}};
    my $status_content = join "<br />\n", grep {
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
    $self->template->process($self->status_template,
        status_content => $status_content,
    );
}

sub show {
    my $tool = shift;
    my $action = $self->hub->action;
    my $show = $tool->{show_if_preference};
    if (defined $show) {
        return $self->preferences->$show->value;
    }
    return 1;
}

1;

__DATA__

=head1 NAME

Kwiki::Status - Kwiki Status Base Class

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
__template/tt2/status_pane.html__
<!-- BEGIN status_pane.html -->
<div class="status">
[% status_content %]
</div>
<!-- END status_pane.html -->

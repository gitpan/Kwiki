package Kwiki::Plugin;
use strict;
use warnings;
use Spoon::Plugin '-Base';

stub 'class_id';
const cgi_class => '';
const config_file => '';
const css_file => '';
const javascript_file => '';
field 'page';

sub new {
    return $self if ref $self;
    super;
}

sub load() {
    my $class = shift;
    my $context = shift;
    die "NLW::Plugin::load() method reserved for Template Toolkit"
      unless ref $context eq 'Template::Context';
    my $self = bless {
        _CONTEXT => $context,
    }, $class;
    {
        no warnings;
        $self->hub($main::HUB); # XXX Need a better way for multihub stuff
    }
    $self->init;
    return $self;
}

sub init {
    $self->cgi_class
    ? $self->use_cgi($self->cgi_class)
    : $self->use_class('cgi');
    $self->use_class('config');
    $self->use_class('pages');
    $self->use_class('preferences');
    $self->use_class('template');
    $self->config->add_file($self->config_file);
    $self->hub->load_class('css')->add_file($self->css_file);
    $self->hub->load_class('javascript')->add_file($self->javascript_file);
}

sub render_screen {
    $self->template_process($self->screen_template, @_);
}

sub template_process {
    $self->hub->css->add_file($self->css_file)
      if $self->css_file;
    my $template = shift;
    $self->template->process($template, 
        self => $self,
        $self->cgi->all, 
        @_,
    );
}

sub redirect {
    return { redirect => $self->config->script_name . '?' . shift};
}

sub new_preference {
    $self->hub->load_class('preferences')->new_preference(scalar(caller), @_);
}

1;

__DATA__

=head1 NAME

Kwiki::Plugin - Kwiki Plugin Base Class

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

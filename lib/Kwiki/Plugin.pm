package Kwiki::Plugin;
use strict;
use warnings;
use Spoon::Plugin '-Base';
require Kwiki::Preferences;

const preference_class => 'Kwiki::Preference';
field preference_list => [];
const cgi_class => '';

sub new_preference {
    $self->preference_class->new(scalar caller, @_);
}

sub render_screen {
    $self->template_process($self->screen_template, @_);
}

sub template_process {
    my $template = shift;
    $self->template->process(
        $template, 
        $self->cgi->all, 
        @_
    );
}

sub redirect {
    return { redirect => $self->config->script_name . '?' . shift};
}

sub init {
    $self->cgi_class
    ? $self->use_cgi($self->cgi_class)
    : $self->use_class('cgi');
    $self->use_class('config');
    $self->use_class('pages');
    $self->use_class('template');
}

sub load_preference_values {
    my $values = $self->hub->preferences->load($self->class_id);
    for my $pref (@{$self->preference_list}) {
        $pref->value($values->{$pref->id});
    }
}

sub add_preference {
    my $preference = shift;
    push @{$self->{preference_list}}, $preference;
}

1;

package Kwiki::Preferences;
use strict;
# XXX circular dependency on Kwiki::Plugin. Fix when Spiffy::super nests.
# use warnings;
use Kwiki::Plugin '-Base';

field class_id => 'preferences';
field 'objects_with_preferences';

sub process {
    $self->get_objects_with_preferences;
    $self->save if $self->cgi->Button eq 'Save';
    return $self->render;
}

sub render {
    return $self->template_render('preferences_page.html',
        objects => $self->objects_with_preferences,
    );
}

sub save {
    my %cgi = $self->cgi->all;
    for my $object (@{$self->objects_with_preferences}) {
        my $settings = {};
        my $class_id = $object->class_id;
        for (sort keys %cgi) {
            if (/^${class_id}__(.*)/) {
                my $pref = $1;
                $pref =~ s/-boolean$//;
                $settings->{$pref} = $cgi{$_}
                  unless exists $settings->{$pref};
            }
        }
        if (keys %$settings) {
            $self->store($class_id, $settings);
        }
        $object->load_preference_values;
    }
}

sub get_objects_with_preferences {
    my @objects;
    for my $class_id (@{$self->hub->registry->lookup->has_preferences}) {
        my $object = $self->hub->load_class($class_id);
        push @objects, $object;
        $object->load_preference_values;
    }
    $self->objects_with_preferences(\ @objects);
}
    
#------------------------------------------------------------------------------#
package Kwiki::Preference;
use Kwiki::Base '-base';

field 'id';
field 'name';
field 'description';
field 'query';
field 'type';
field 'choices';
field 'default';
field 'handler';
field 'owner_id';
field 'value';

sub new() {
    my $class = shift;
    my $owner = shift;
    my $self = bless {}, $class;
    my $id = shift || '';
    $self->id($id);
    my $name = $id;
    $name =~ s/_/ /g;
    $name =~ s/\b(.)/\u$1/g;
    $self->name($name);
    $self->query("$name?");
    $self->type('boolean');
    $self->default(0);
    $self->handler("${id}_handler");
    $self->owner_id($owner->class_id);
    return $self;
}

sub value_label {
    my $choices = $self->choices
      or return '';
    return ${{@$choices}}{$self->value} || '';
}
    
sub form_element {
    my $type = $self->type;
    return $self->$type;
}

sub input {
    my $name = $self->owner_id . '__' . $self->id;
    my $value = defined $self->value ? $self->value : $self->default;
    return <<END
<input type="input" name="$name" value="$value" size="25" />
END
}

sub boolean {
    my $name = $self->owner_id . '__' . $self->id;
    my $value = defined $self->value ? $self->value : $self->default;
    my $checked = $value ? 'checked="checked"' : '';
    return <<END
<input type="checkbox" name="$name" value="1" $checked />
<input type="hidden" name="$name-boolean" value="0" $checked />
END
}

sub radio {
    my $i = 1;
    my @choices = @{$self->choices};
    my @values = grep {$i++ % 2} @choices;
    my $value = defined $self->value ? $self->value : $self->default;

    join "\n", 
        '<table bgcolor="#e0e0e0"><tr><td align="left">', 
        CGI::radio_group(
            -name => $self->owner_id . '__' . $self->id,
            -values => \@values,
            -default => $value,
            -labels => { @choices },
            -override => 1,
            -linebreak=>'true',
        ),
        '</td></tr></table>';
}

sub pulldown {
    my $i = 1;
    my @choices = @{$self->choices};
    my @values = grep {$i++ % 2} @choices;
    my $value = defined $self->value ? $self->value : $self->default;
    CGI::popup_menu(
        -name => $self->owner_id . '__' . $self->id,
        -values => \@values,
        -default => $value,
        -labels => { @choices },
        -override => 1,
    );
}

1;

package Kwiki::DataObject;
use strict;
use warnings;
use Kwiki::Base '-base';

stub 'class_id';
field 'id';

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->hub(shift);
    $self->id(shift);
    return $self;
}   

1;

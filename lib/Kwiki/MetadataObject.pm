package Kwiki::MetadataObject;
use strict;
use warnings;
use Kwiki::DataObject '-Base';

const class_id => 'metadata';

field loaded => 0;

sub from_hash {
    $self->loaded(1);
}

sub to_hash {
    my $hash = {};
    return $hash;
}

sub update {
}

1;

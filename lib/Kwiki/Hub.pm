package Kwiki::Hub;
use strict;
use warnings;
use Spoon::Hub '-Base';

sub action {
    $self->cgi->action || 'display';
}

1;

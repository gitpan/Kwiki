package Kwiki::Hub;
use strict;
use Spoon::Hub '-Base';

sub init { 
#     $self->load_class('cgi');
}

sub action {
    $self->cgi->action || 'display';
}

1;

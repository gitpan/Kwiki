package Kwiki::ContentObject;
use strict;
use warnings;
use Kwiki::DataObject '-Base';

field 'header';
field revision_id => '';

sub database_directory {
    join '/', $self->hub->config->database_directory, $self->class_id; 
}

sub exists {
    -e join '/', $self->data_directory, $self->id;
}

sub deleted {
}

sub active {
    return $self->exists && not $self->deleted;
}

sub load {
    my $metadata = $self->{metadata}
      or die "No metadata object in content object";
    my ($headers, $content) = $self->read(@_);
    $self->content($content);
    $metadata->from_hash($self->parse_metadata($headers));
    return $self;
}

sub load_content {
    my (undef, $content) = $self->read;
    $self->content($content);
    return $self;
}

sub load_metadata {
    my $metadata = $self->{metadata}
      or die "No metadata object in content object";
    my ($headers) = $self->read;
    $metadata->from_hash($self->parse_metadata($headers));
    return $self;
}

sub parse_metadata {
    my $headers = shift;
    my $metadata = {};
    return $metadata;
}

sub read {
    my $file_path;
    if (@_) {
        $file_path = shift;
        die "No such file $file_path"
          unless -f $file_path;
    }
    else {
        my $id = $self->id
          or die "No id for content object";
        $file_path = join '/', $self->database_directory, $id;
        return '' unless -e $file_path;
    }
    my $buffer = $self->utf8_decode(io($file_path)->scalar);
    $buffer =~ s/\015\012/\n/g;
    $buffer =~ s/\015/\n/g;

    my ($headers, $body) = ('XXX', $buffer);
    $headers = ''
      unless defined $headers;
    $body = ''
      unless defined $body;
    return ($headers, $body);
}

sub store {
    my $metadata = $self->{metadata}
      or die "No metadata for content object";
    my $body = $self->content;
    if (length $body) {
        $body =~ s/\r//g;
        $body =~ s/\n*\z/\n/;
    }
    else {
        $self->delete;
    }
    my $headers = $self->make_headers;
    $self->write_file($headers, $body);
}

sub make_headers {
    my $headers = '';
    return $headers;   
}

sub write_file {
    my ($headers, $body) = @_;
    my $id = $self->id
      or die "No id for content object";
    $body > io->catfile($self->database_directory, $id)->assert;
}

1;

package Kwiki::Command;
use strict;
use warnings;
use Kwiki::Base '-Base';

sub init {
    $self->use_class('config');
}

sub boolean_arguments { qw(-install -new -upgrade) }
sub process {
    my $args = $self->parse_arguments(@_);
    return $self->new_kwiki if $args->{-new} or $args->{-install};
    return $self->upgrade_kwiki if $args->{-upgrade};
    return $self->usage;
}

sub new_kwiki {
    die "Can't make new kwiki in a non-empty directory\n"
      if io('.')->all;
    $self->use_class('files');
    warn $self->files->extract_message;
    $self->files->extract_files;
    warn "Kwiki software installed! Point your browser at this location.\n\n"
}

sub usage {
    warn <<END;
usage:
  kwiki -new                  # Generate a new Kwiki in an empty directory
  kwiki -install              # Same as kwiki -new
  kwiki -upgrade              # Upgrade an existing Kwiki
END
}

1;

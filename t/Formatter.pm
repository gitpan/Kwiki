package My::Formatter;
use Kwiki::Formatter '-Base';

sub init {
    $self->hub->load_class('pages');
}

package Kwiki::CGI;
use strict;
use warnings;
use Spoon::CGI '-Base';

sub init {
    $self->add_params('page_id');
}

cgi 'action';

sub page_id {
    return $self->{page_id} = shift if @_;
    return $self->{page_id}
      if defined $self->{page_id};
    my $page_id = CGI::param('page_id');
    if (not defined $page_id) {
        my $query_string = CGI::query_string();
        $query_string =~ s/%([0-9a-fA-F]{2})/pack("H*", $1)/ge;
        if ($query_string =~ /^keywords=/) {
            $page_id = join ' ', grep $_, split /;?keywords=/, $query_string;
        }
        elsif ($ENV{QUERY_STRING} =~ /[^=&]+&/) {
            ($page_id = $ENV{QUERY_STRING}) =~ s/(.*?)\&.*/$1/;
        }
    }
    $page_id ||= $self->hub->config->main_page;
    $page_id =~ s/\W//g;
    $self->utf8_decode($page_id);
}

1;

package Kwiki::Pages;
use strict;
use warnings;
use Kwiki::Base '-Base';

const class_id => 'pages';
const page_class => 'Kwiki::Page';
const meta_class => 'Kwiki::Page::Meta';

sub init {
    $self->use_class('cgi');
    $self->use_class('config');
}

sub current {
    return $self->{current} = shift if @_;
    return $self->{current} if defined $self->{current};
    return $self->{current} = $self->new_page($self->current_id);
}

sub current_id {
    return $self->cgi->page_id ||
           $self->config->main_page
           or die;
}

sub new_page {
    my $page_id = shift;
    my $page = $self->page_class->new($self->hub, $page_id);
    $page->metadata($self->new_metadata($page_id));
    return $page;
}

sub new_metadata {
    my $page_id = shift or die;
    $self->meta_class->new($self->hub, $page_id);
}

package Kwiki::Page;
use strict;
use Kwiki::ContentObject '-base';

field class_id => 'page';

sub content_or_default {
    return $self->content || 'Insert text here.   ';
}

sub content {
    return $self->{content} = shift if @_;
    return $self->{content} if defined $self->{content};
    $self->load_content;
    return $self->{content};
}

sub metadata {
    return $self->{metadata} = shift if @_;
    $self->{metadata} ||= 
      $self->meta_class->new($self->hub, $self->id);
    return $self->{metadata} if $self->{metadata}->loaded;
    $self->load_metadata;
    return $self->{metadata};
}

sub age {
    $self->age_in_minutes;
}

sub age_in_minutes {
    $self->age_in_seconds / 60;
}

sub age_in_seconds {
    return $self->{age_in_seconds} = shift if @_;
    return $self->{age_in_seconds} if defined $self->{age_in_seconds};
    my $path = $self->hub->config->data_directory;
    my $page_id = $self->id;
    return $self->{age_in_seconds} = int((-M "$path/$page_id") * 86400);
}

sub all {
    return (
        page_id => $self->id,
    );
}

sub to_html_or_default {
    $self->to_html($self->content_or_default);
}

sub to_html {
    my $content = @_ ? shift : $self->content; 
    $self->hub->load_class('formatter');
    $self->hub->formatter->text_to_html($content);
}

package Kwiki::Page::Meta;
use strict;
use warnings;
use Kwiki::MetadataObject '-base';

sub key_order {
}

1;

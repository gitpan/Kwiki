use lib 't', 'lib';
use strict;
use warnings;
use TestChunks;
use Kwiki;
my $formatter = Kwiki->new->debug->load_hub->load_class('formatter');

for my $test ((test_chunks(qw(%%% <<<)))) {
    my $wiki_text = $test->chunk('%%%');
    my $expect_html = $test->chunk('<<<');
    my $got_html = $formatter->text_to_html($wiki_text);
    $got_html =~ s{^<div class="wiki">\n(.*)</div>\n\z}{$1}s;
    is($got_html, $expect_html);
}

__END__
%%%
* one
* two
<<<
<ul>
<li>one</li>
<li>two</li>
</ul>
%%%
  one &
  <two>
<<<
<pre>one &amp;
&lt;two&gt;
</pre>
%%%
This is how you {{*bold /text/*}} for future reference.
<<<
<p>
This is how you *bold /text/* for future reference.
</p>
%%%
*** one
* two
<<<
<ul><ul><ul>
<li>one</li>
</ul></ul>
<li>two</li>
</ul>

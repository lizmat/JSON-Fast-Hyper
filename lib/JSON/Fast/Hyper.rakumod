my constant $header = "[\n\n";
my constant $footer = " \n]";  # extra space intentional so from-json can chop
my subset Hyperable of Str where .starts-with($header) && .ends-with($footer);

use JSON::Fast:ver<0.19>:auth<cpan:TIMOTIMO>;
use ParaSeq:ver<0.2.7+>:auth<zef:lizmat>;

my proto sub to-json-hyper(|) {*}
my multi sub to-json-hyper(@_, *%_) {
    $header
      ~ @_.map({to-json $_, :!pretty, |%_}).join(",\n")
      ~ $footer
}
BEGIN &to-json-hyper.add_dispatchee(&to-json);

my proto sub from-json-hyper(|) {*}
my multi sub from-json-hyper(Hyperable:D $json) {
    (my $data := $json.substr(3,*-2))
      ?? $data.lines.&hyperize(128).map({from-json .chop}).List
      !! ()
}
BEGIN &from-json-hyper.add_dispatchee(&from-json);

sub EXPORT() {
    Map.new: (
      '&from-json' => &from-json-hyper,
      '&to-json'   => &to-json-hyper,
    )
}

# vim: expandtab shiftwidth=4

my constant $header = "[\n\n";
my constant $footer = " \n]";  # extra space intentional so from-json can chop
my subset Hyperable of Str where .starts-with($header) && .ends-with($footer);

use JSON::Fast:ver<0.16>;

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
      ?? $data.lines.hyper.map({from-json .chop}).List
      !! ()
}
BEGIN &from-json-hyper.add_dispatchee(&from-json);

sub EXPORT() {
    Map.new: (
      '&from-json' => &from-json-hyper,
      '&to-json'   => &to-json-hyper,
    )
}

=begin pod

=head1 NAME

JSON::Fast::Hyper - Read/Write hyperable JSON

=head1 SYNOPSIS

=begin code :lang<raku>

use JSON::Fast::Hyper;

my $json = to-json(@array);    # creates faster hyperable JSON

my $json = to-json(%hash);     # normal JSON

my @array = from-json($json);  # 2x faster if hyperable JSON

my %hash := from-json($json);  # normal speed

=end code

=head1 DESCRIPTION

JSON::Fast::Hyper is a drop-in wrapper for C<JSON::Fast>.  It provides the same
interface as C<JSON::Fast>, with two differences:

=head2 CONVERTING A LIST TO JSON

=begin code :lang<raku>

my $json = to-json(@array);    # creates faster hyperable JSON

=end code

When a list is converted to JSON, it will create a special hyperable version
of JSON that is still completely valid JSON for all JSON parsers, but which
can be interpreted in parallel when reading back.  To allow this feature,
the JSON will always be created as if the C<:pretty> named argument has been
specified as C<False>.

If your data structure is B<not> a C<Positional>, then it will just act as
the normal C<to-json> sub from C<JSON::Fast>.

=head2 CONVERTING JSON OF A LIST TO DATA STRUCTURE

=begin code :lang<raku>

my @array := from-json($json);  # 2x faster if hyperable JSON

=end code

When the JSON was created hyperable, then reading such JSON with C<from-json>
will return the original C<Positional> as a C<List>.  If the JSON was not
hyperable, it will call the normal C<from-json> sub from C<JSON::Fast>.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/JSON-Fast-Hyper .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2022 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4

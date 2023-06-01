my constant $header = "[\n\n";
my constant $footer = " \n]";  # extra space intentional so from-json can chop
my subset Hyperable of Str where .starts-with($header) && .ends-with($footer);

use JSON::Fast:ver<0.17>:auth<cpan:TIMOTIMO>;

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

=head1 TECHNICAL BACKGROUND

This module makes the C<to-json> and C<from-json> exported subs of
C<JSON::Fast> into a multi.  It adds a candidate taking a C<Positional>
to C<to-json>, and it adds a candidate to C<from-json> that takes the
specially formatted string created by that extra C<to-json> candidate.

The C<Positional> candidate of C<to-json> will create the JSON for each
of the elements separately, and joins them together with an additional
newline.  And then adds a specially formatted header and footer to the
result.  The resulting string is still valid JSON, readable by any
JSON decoder.  But when run through the C<from-json> sub provided by this
module, will decode elements in parallel.  Wallclock times are at about
50% for a 7MB JSON file, such as provided by the Raku Ecosystem Archive.
While only adding C<3 + number of elements> bytes to the resulting string.

A similar approach could be done for handling an C<Associative> at the
top level.  But this makes generally a lot less sense, as the amount of
information per key/value is usually vastly different, and JSON that
consists of an C<Associative> at the top, are usually not big enough to
warrant the overhead of hypering.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/JSON-Fast-Hyper .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2022, 2023 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4

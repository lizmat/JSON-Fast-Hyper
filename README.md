[![Actions Status](https://github.com/lizmat/JSON-Fast-Hyper/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/JSON-Fast-Hyper/actions) [![Actions Status](https://github.com/lizmat/JSON-Fast-Hyper/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/JSON-Fast-Hyper/actions) [![Actions Status](https://github.com/lizmat/JSON-Fast-Hyper/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/JSON-Fast-Hyper/actions)

NAME
====

JSON::Fast::Hyper - Read/Write hyperable JSON

SYNOPSIS
========

```raku
use JSON::Fast::Hyper;

my $json = to-json(@array);    # creates faster hyperable JSON

my $json = to-json(%hash);     # normal JSON

my @array = from-json($json);  # 2x faster if hyperable JSON

my %hash := from-json($json);  # normal speed
```

DESCRIPTION
===========

JSON::Fast::Hyper is a drop-in wrapper for `JSON::Fast`. It provides the same interface as `JSON::Fast`, with two differences:

CONVERTING A LIST TO JSON
-------------------------

```raku
my $json = to-json(@array);    # creates faster hyperable JSON
```

When a list is converted to JSON, it will create a special hyperable version of JSON that is still completely valid JSON for all JSON parsers, but which can be interpreted in parallel when reading back. To allow this feature, the JSON will be created ignoring the `:pretty` named argument.

If your data structure is **not** a `Positional`, then it will just act as the normal `to-json` sub from `JSON::Fast`.

CONVERTING JSON OF A LIST TO DATA STRUCTURE
-------------------------------------------

```raku
my @array := from-json($json);  # 2x faster if hyperable JSON
```

When the JSON was created hyperable, then reading such JSON with `from-json` will return the original `Positional` as a `List`. If the JSON was not hyperable, it will call the normal `from-json` sub from `JSON::Fast`.

TECHNICAL BACKGROUND
====================

This module makes the `to-json` and `from-json` exported subs of `JSON::Fast` into a multi. It adds a candidate taking a `Positional` to `to-json`, and it adds a candidate to `from-json` that takes the specially formatted string created by that extra `to-json` candidate.

The `Positional` candidate of `to-json` will create the JSON for each of the elements separately, and joins them together with an additional newline. And then adds a specially formatted header and footer to the result. The resulting string is still valid JSON, readable by any JSON decoder. But when run through the `from-json` sub provided by this module, will decode elements in parallel. Wallclock times are at about 45% (aka 2.2x as fast) for a 13MB JSON file, such as provided by the Raku Ecosystem Archive. While only adding `3 + number of elements` bytes to the resulting string.

A similar approach could be done for handling an `Associative` at the top level. But this makes generally a lot less sense, as the amount of information per key/value is usually vastly different, and JSON that consists of an `Associative` at the top, are usually not big enough to warrant the overhead of hypering.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/JSON-Fast-Hyper . Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2022, 2023, 2024, 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.


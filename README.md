[![Actions Status](https://github.com/lizmat/JSON-Fast-Hyper/workflows/test/badge.svg)](https://github.com/lizmat/JSON-Fast-Hyper/actions)

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

When a list is converted to JSON, it will create a special hyperable version of JSON that is still completely valid JSON for all JSON parsers, but which can be interpreted in parallel when reading back. To allow this feature, the JSON will always be created as if the `:pretty` named argument has been specified as `False`.

If your data structure is **not** a `Positional`, then it will just act as the normal `to-json` sub from `JSON::Fast`.

CONVERTING JSON OF A LIST TO DATA STRUCTURE
-------------------------------------------

```raku
my @array := from-json($json);  # 2x faster if hyperable JSON
```

When the JSON was created hyperable, then reading such JSON with `from-json` will return the original `Positional` as a `List`. If the JSON was not hyperable, it will call the normal `from-json` sub from `JSON::Fast`.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/JSON-Fast-Hyper . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2022 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.


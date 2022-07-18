Module: protocol-buffers-impl
Synopsis: 64-bit specific definitions


define constant $min-int32 :: <int> = -(2 ^ 31);
define constant $max-int32 :: <int> = (2 ^ 31) - 1;
define constant $max-uint32 :: <int> = (2 ^ 32) - 1;

define constant $min-int64 :: ga/<integer> = ga/-(0, ga/^(2, 63));
define constant $max-int64 :: ga/<integer> = ga/-(ga/^(2, 63), 1);
define constant $max-uint64 :: ga/<integer> = ga/-(ga/^(2, 64), 1);

define constant <int32> = limited(<int>, min: $min-int32, max: $max-int32);
define constant <uint32> = limited(<int>, min: $min-int32, max: $max-int32);

define constant <int64> = ga/<integer>;
// BUG: There are no `limited` methods on ga/<integer> so we can't limit this
// to the exact range of uint64, but at least this type can represent all the
// uint64 values.
define constant <uint64> = ga/<integer>;

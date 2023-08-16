Module: protocol-buffers-impl
Synopsis: 64-bit specific definitions


define constant $min-int32 :: <int> = -(2 ^ 31);
define constant $max-int32 :: <int> = (2 ^ 31) - 1;
define constant $max-uint32 :: <int> = (2 ^ 32) - 1;

define constant $min-int64 :: <big-int> = big--(0, big-^(2, 63));
define constant $max-int64 :: <big-int> = big--(big-^(2, 63), 1);
define constant $max-uint64 :: <big-int> = big--(big-^(2, 64), 1);

define constant <int32> = limited(<int>, min: $min-int32, max: $max-int32);
define constant <uint32> = limited(<int>, min: 0, max: $max-uint32);

// BUG: There are no `limited` methods on <big-int> so we can't limit this
// to the exact range of uint64, but at least this type can represent all the
// uint64 values.
define constant <int64> = <big-int>;
define constant <uint64> = <big-int>;

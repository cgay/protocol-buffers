Module: protocol-buffers-impl
Synopsis: 32-bit specific definitions


define constant $min-int32 :: ga/<integer> = - ga/^(2, 31);
define constant $max-int32 :: ga/<integer> = ga/-(ga/^(2, 31), 1);
define constant $max-uint32 :: ga/<integer> = ga/-(ga/^(2, 32), 1);

define constant $min-int64 :: ga/<integer> = ga/$minimum-integer;
define constant $max-int64 :: ga/<integer> = ga/$maximum-integer;
// BUG: This is the best we can do on 32-bit without infinite precision integers!
//      Should be 2^64 - 1
define constant $max-uint64 :: ga/<integer> = ga/$maximum-integer;

define constant <int32> = limited(ga/<integer>, min: $min-int32, max: $max-int32);
define constant <uint32> = limited(ga/<integer>, min: $min-int32, max: $max-int32);

define constant <int64> = limited(ga/<integer>, min: $min-int64, max: $max-int64);
define constant <uint64> = limited(ga/<integer>, min: 0, max: $max-uint64);


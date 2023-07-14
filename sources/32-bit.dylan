Module: protocol-buffers-impl
Synopsis: 32-bit specific definitions


// TODO: any code that uses these min/max values needs to use generic arithmetic.

define constant $min-int32 :: <big-int> = - big-^(2, 31);
define constant $max-int32 :: <big-int> = big--(big-^(2, 31), 1);
define constant $max-uint32 :: <big-int> = big--(big-^(2, 32), 1);

define constant $min-int64 :: <big-int> = $minimum-big-int;
define constant $max-int64 :: <big-int> = $maximum-big-int;
// BUG: This is the best we can do on 32-bit without infinite precision integers!
//      Should be 2^64 - 1
define constant $max-uint64 :: <big-int> = $maximum-big-int;

define constant <int32>  = limited(<big-int>, min: $min-int32, max: $max-int32);
define constant <uint32> = limited(<big-int>, min: $min-int32, max: $max-int32);

define constant <int64>  = limited(<big-int>, min: $min-int64, max: $max-int64);
define constant <uint64> = limited(<big-int>, min: 0,          max: $max-uint64);

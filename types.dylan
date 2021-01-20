Module: protocol-buffers-internal

// Superclass of all generated protocol buffer objects. "Message" is the only
// protocol buffer entity that user programs deal with directly, unless doing
// something with reflection, in which case see <descriptor>.
define open abstract class <message> (<object>)
  // Rather than allocating a slot for each `bool` field use one bit vector.
  slot %boolean-field-bits :: false-or(<bit-vector>);

  // Wire format bytes for fields that we didn't recognize during
  // deserialization, retained here so that they may be emitted if the proto is
  // re-serialized.
  slot %unrecognized-field-bytes :: false-or(<byte-vector>);

  // For proto2 we need to track whether a field has been explicitly set, so
  // that it may be distinguished from the field having the default value.  I
  // need to verify this in the spec, but I believe if it has been explicitly
  // set to the default value the value IS written during serialization and in
  // proto3 the default value is never written on the wire.
  slot %field-is-set :: <bit-vector>;
end class;

// Scalar types, as defined by the protobuf spec.
// https://developers.google.com/protocol-buffers/docs/proto3#scalar
define enum <scalar> ()
  $bool;
  $bytes;
  $double;
  $fixed32;
  $fixed64;
  $float;
  $int32;
  $int64;
  $sfixed32;
  $sfixed64;
  $sint32;
  $sint64;
  $string;
  $uint32;
  $uint64;
end enum;


define constant $max-int32 :: <int> = 2 ^ 31 - 1;
define constant $max-int64 :: <int> = $maximum-integer; // assume 64-bit

define constant <int32> = limited(<int>, min: -(2 ^ 31), max: $max-int32);
define constant <int64> = <int>;
define constant <uint32> = limited(<int>, min: 0, max: 2 ^ 31 - 1);
define constant <uint64> = limited(<int>, min: 0);

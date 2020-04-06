Module: protocol-buffers-impl

// The root of the type hierarchy for generated code objects.
define sealed abstract class <protocol-buffer-object> (<object>)
end class;

// Superclass of all generated protocol buffer messages.
define open abstract class <protocol-buffer-message> (<protocol-buffer-object>)

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

// Superclass of all generated protocol buffer enums.
define open abstract class <protocol-buffer-enum> (<protocol-buffer-object>)
end class;


// A set of constant to identify the scalar types defined in the protobuf spec.
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

// Generally assuming 64-bit platform for now.

define constant $max-int32 :: <int> = ash(1, 32) - 1;
define constant $min-int32 :: <int> = -ash(1, 32);
define constant $max-int64 :: <int> = $maximum-integer;
define constant $min-int64 :: <int> = $minimum-integer;

// In theory I should be able to redefine these all as equivalent to <int> at
// some point and it should omit some unnecessary type checks, then run
// benchmarks.

define constant <int32> = limited(<int>, min: -(2 ^ 31), max: $max-int32);
define constant <int64> = <int>;
define constant <uint32> = limited(<int>, min: 0, max: 2 ^ 32 - 1);
define constant <uint64> = <uint>;

define constant <index> = <uint>;

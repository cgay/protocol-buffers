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


// A set of constants to identify the scalar types defined in the protobuf
// spec.  https://developers.google.com/protocol-buffers/docs/proto3#scalar
define enum <scalar-type> ()
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

define constant <index> = <uint64>;

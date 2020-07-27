Module: protocol-buffers-internal

// Superclass of all generated protocol buffer objects.
define open abstract class <protobuf> (<object>) end;

// Scalar types, as defined by the protobuf spec.
// https://developers.google.com/protocol-buffers/docs/proto3#scalar
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

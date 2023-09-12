Module: protocol-buffers-impl

// The root of the type hierarchy for generated code objects.
define sealed abstract class <protocol-buffer-object> (<object>)
  // Tracking the parent descriptor makes it possible for the code generator to
  // determine the full Dylan name, which is based on the path from file level
  // to the message/enum definition. FileDescriptorSet has no
  // parent. FileDescriptorProto may or may not have a parent. Messages, enums,
  // fields, etc. always have a parent.
  //
  // TODO: this was a mistake. Because the .proto AST is implemented with
  // generated protobufs it was convenient to add this here, but this class is
  // the parent of every single run-time protobuf object so nothing should be
  // added to it unless absolutely necessary.
  //
  slot descriptor-parent :: false-or(<protocol-buffer-object>) = #f,
    init-keyword: parent:;
end class;

// Returns the original proto IDL name (in camelCase) of a descriptor.  This
// just makes it so we don't have to figure out everywhere whether to call
// file-descriptor-proto-name, descriptor-proto-name, et al.
define open generic descriptor-name
    (descriptor :: <protocol-buffer-object>) => (name :: <string>);

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
  //
  // TODO: have <proto2-message> and <proto3-message>?
  slot %field-is-set :: <bit-vector>;
end class;

ignore(%boolean-field-bits,
       %boolean-field-bits-setter,
       %unrecognized-field-bytes,
       %unrecognized-field-bytes-setter,
       %field-is-set, %field-is-set-setter);

// Superclass of all generated protocol buffer enums.

define open abstract class <protocol-buffer-enum> (<protocol-buffer-object>)
  constant slot enum-value-name :: <string>,
    required-init-keyword: name:;
  constant slot enum-value :: <int32>,
    required-init-keyword: value:;
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

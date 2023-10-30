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

// This is a quick and dirty way to manage enum name <-> value mappings.
// Is there a better way? (This is not thread safe for one thing.)
define constant $enum-mappings-name2value = make(<table>); // class -> <string-table>
define constant $enum-mappings-value2name = make(<table>); // class -> <table>

define method make
    (class :: subclass(<protocol-buffer-enum>), #key name :: <string>, value :: <int32>)
 => (enum :: <protocol-buffer-enum>)
  let enum = next-method();

  let name2value = element($enum-mappings-name2value, class, default: #f);
  if (~name2value)
    name2value := make(<string-table>);
    $enum-mappings-name2value[class] := name2value;
  end;
  name2value[name] := enum;

  let value2name = element($enum-mappings-value2name, class, default: #f);
  if (~value2name)
    value2name := make(<table>);
    $enum-mappings-value2name[class] := value2name;
  end;
  value2name[value] := enum;

  enum
end method;

define function enum-name-to-enum
    (class :: subclass(<protocol-buffer-enum>), name :: <string>)
 => (value :: false-or(<protocol-buffer-enum>))
  let name2value = element($enum-mappings-name2value, class, default: #f)
    | pb-error("%= does not name a generated protocol buffer enum class", class);
  element(name2value, name, default: #f)
end function;

define function enum-value-to-enum
    (class :: subclass(<protocol-buffer-enum>), value :: <int32>)
 => (name :: false-or(<protocol-buffer-enum>))
  let value2name = element($enum-mappings-value2name, class, default: #f)
    | pb-error("%= does not name a generated protocol buffer enum class", class);
  element(value2name, value, default: #f)
end function;

define function enum-name-to-value
    (class :: subclass(<protocol-buffer-enum>), name :: <string>)
 => (value :: false-or(<int32>))
  let enum = enum-name-to-enum(class, name);
  enum & enum.enum-value
end function;

define function enum-value-to-name
    (class :: subclass(<protocol-buffer-enum>), value :: <int32>)
 => (name :: false-or(<string>))
  let enum = enum-value-to-enum(class, value);
  enum & enum.enum-value-name
end function;

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

Module: protocol-buffers-impl
Synopsis: Support for the protobuf generated code. Base classes, introspection support, etc.


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
  // the parent of every single run-time protobuf instance so no slots should
  // be added to it unless absolutely necessary.
  //
  slot descriptor-parent :: false-or(<protocol-buffer-object>) = #f,
    init-keyword: parent:;
end class;

/* TODO:
define class <protocol-buffer-package> (<protocol-buffer-object>)
  constant slot package-bindings = make(<string-table>);

  // TODO: store package-level options
end class;
*/

// Returns the original proto IDL name (in camelCase and not the
// fully-qualified name) of a descriptor.  This just makes it so we don't have
// to figure out everywhere whether to call file-descriptor-proto-name,
// descriptor-proto-name, et al.
define open generic descriptor-name
    (descriptor :: <protocol-buffer-object>) => (name :: <string>);

//
// Messages
//

// Superclass of all generated protocol buffer messages.
define open abstract class <protocol-buffer-message> (<protocol-buffer-object>)

  // Rather than allocating a slot for each `bool` field use one bit vector.
  // TODO: Once this is implemented, document what are the offsets here.
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

// TODO: Not implemented yet.
ignore(%boolean-field-bits,
       %boolean-field-bits-setter,
       %unrecognized-field-bytes,
       %unrecognized-field-bytes-setter,
       %field-is-set, %field-is-set-setter);

//
// Enums
//

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

//
// Misc
//

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

// A type to clarify when something is used as an index into a sequence.
define constant <index> = <uint64>;


//
// Introspection
//

define class <introspection-data> (<object>)
  constant slot introspection-full-name :: <string>,
    required-init-keyword: full-name:;
  constant slot introspection-descriptor :: <protocol-buffer-object>,
    required-init-keyword: descriptor:;
  // This is a class for messages and enums but #f for fields.
  constant slot introspection-class :: false-or(<class>) = #f,
    init-keyword: class:;
end class;

define class <field-introspection-data> (<introspection-data>)
  constant slot introspection-getter :: <func>,
    required-init-keyword: getter:;
  constant slot introspection-setter :: <func>,
    required-init-keyword: setter:;
  constant slot introspection-adder :: false-or(<func>) = #f,
    init-keyword: adder:;
end class;

define constant $introspection-data = make(<table>);

// Maps fully-qualified name to an <introspection-data> instance.
define constant $introspection-data-by-name = make(<string-table>);

// TODO: back compat...remove after updating generated code.
define function set-introspection-data
    (desc :: <protocol-buffer-object>, name :: <string>, key, #rest keys) => ()
  apply(store, name, desc, key, keys);
end function;

// Called by generated code.  If you change this you'll want to create a
// backward compatibility function which you can remove after regenerating
// descriptor-pb.dylan and before comitting your changes. The name "store" and
// the #rest args are to keep the generated code somewhat concise.
define function store
    (name :: <string>, desc :: <protocol-buffer-object>, #rest args) => ()
  let (one, two, three) = apply(values, args);
  let idata
    = select (one by instance?)
        <class> =>
          // message or enum class
          make(<introspection-data>,
               full-name: name, descriptor: desc, class: one);
        <protocol-buffer-enum> =>
          // enum value
          make(<introspection-data>,
               full-name: name, descriptor: desc, class: object-class(one));
        <func> =>
          make(<field-introspection-data>,
               full-name: name, descriptor: desc,
               getter: one, setter: two, adder: three);
        otherwise =>
          pb-error("protobuf bug: bad introspection data for store(%=, %=, %=, ...)",
                   name, desc, one);
      end;
  for (object in list(name, desc, one, two, three))
    if (object)
      let table = iff(instance?(object, <string>),
                      $introspection-data-by-name,
                      $introspection-data);
      let old = element(table, object, default: #f);
      // Remove this check once introspection code is complete...
      old & pb-error("protobuf bug: attempt to store duplicate introspection data for %=",
                     old.introspection-full-name);
      table[object] := idata;
    end;
  end;
end function;

// Lookup introspection data for `key`, which may be a field getter/setter
// function, a message class, an enum class, an enum constant, or the
// fully-qualified name of any protobuf entity. (No leading '.' allowed.)
define generic introspect
    (key) => (i :: false-or(<introspection-data>));

define method introspect
    (key :: <object>) => (i :: false-or(<introspection-data>))
  element($introspection-data, key, default: #f)
end method;

define method introspect
    (fully-qualified-name :: <string>) => (i :: false-or(<introspection-data>))
  if (empty?(fully-qualified-name))
    pb-error("the empty string does not name any protocol buffer entity");
  end;
  element($introspection-data-by-name, fully-qualified-name, default: #f)
end method;

Module: protocol-buffers-impl

// This file implements by hand what we eventually expect to be able to generate for
// https://github.com/protocolbuffers/protobuf/blob/master/src/google/protobuf/descriptor.proto
// with the Dylan pbgen tool. It also functions as a way to brainstorm what the
// generated Dylan code should look like. That includes how the code should be formatted
// by the protoc plugin, which may not exactly match the usual Dylan style.

// This code reflects the fact that descriptior.proto uses proto2 syntax:
// * Optional and repeated fields are typed false-or(<foo>)
// * Required fields are typed <foo>, do not have an initial value, and
//   have a required-init-keyword:.

// End of line comments in the .proto file are placed at the end of the slot
// name line. Comments on lines by themselves are placed on a line by
// themselves in the Dylan code.

// Each repeated field slot is followed by a generated comment of the form
// "(repeated <type>)" since Dylan limited collections are difficult to work
// with. We may revisit this later.

// TODO: TEMPORARY. Probably should not use uncommon-dylan.
define constant <sequence> = <seq>;

// FileDescriptorSet
// The protocol compiler can output a FileDescriptorSet containing the .proto
// files it parses.
define sealed class <file-descriptor-set> (<protocol-buffer-message>)
  // The protocol compiler can output a FileDescriptorSet containing the .proto
  // files it parses.
  slot file-descriptor-set-file :: false-or(<sequence>),
    init-value: #f,
    init-keyword: file:;
end class <file-descriptor-set>;

// FileDescriptorProto
// Describes a complete .proto file.
define class <file-descriptor-proto> (<protocol-buffer-message>)
  slot file-descriptor-proto-name :: false-or(<string>), // file name, relative to root of source tree
    init-value: #f,
    init-keyword: name:;
  slot file-descriptor-proto-package :: false-or(<string>), // e.g. "foo", "foo.bar", etc.
    init-value: #f,
    init-keyword: package:;
  // Names of files imported by this file.
  slot file-descriptor-proto-dependency :: false-or(<sequence>), // repeated string
    init-value: #f,
    init-keyword: dependency:;
  // Indexes of the public imported files in the dependency list above.
  slot file-descriptor-proto-public-dependency :: false-or(<sequence>), // repeated int32
    init-value: #f,
    init-keyword: public-dependency:;
  // Indexes of the weak imported files in the dependency list.
  // For Google-internal migration only. Do not use.
  slot file-descriptor-proto-weak-dependency :: false-or(<sequence>), // repeated int32
    init-value: #f,
    init-keyword: weak-dependency:;
  // All top-level definitions in this file.
  slot file-descriptor-proto-message-type :: false-or(<sequence>), // repeated <descriptor-proto>
    init-value: #f,
    init-keyword: message-type:;
  slot file-descriptor-proto-enum-type :: false-or(<sequence>), // repeated <enum-descriptor-proto>
    init-value: #f,
    init-keyword: enum-type:;
  slot file-descriptor-proto-service :: false-or(<sequence>), // repeated <service-descriptor-proto>
    init-value: #f,
    init-keyword: service:;
  slot file-descriptor-proto-extension :: false-or(<sequence>), // repeated <field-descriptor-proto>
    init-value: #f,
    init-keyword: extension:;
  slot file-descriptor-proto-options :: false-or(/* TODO: <file-options> */ <object>),
    init-value: #f,
    init-keyword: options:;
  // This field contains optional information about the original source code.
  // You may safely remove this entire field without harming runtime
  // functionality of the descriptors -- the information is needed only by
  // development tools.
  slot file-descriptor-proto-source-code-info :: false-or(/* TODO: <source-code-info> */ <object>),
    init-value: #f,
    init-keyword: source-code-info:;
  // The syntax of the proto file.
  // The supported values are "proto2", "proto3", and "editions".
  slot file-descriptor-proto-syntax :: false-or(<string>),
    init-value: #f,
    init-keyword: syntax:;
  // The edition of the proto file, which is an opaque string.
  slot file-descriptor-proto-edition :: false-or(<string>),
    init-value: #f,
    init-keyword: edition:;
end class <file-descriptor-proto>;

// DescriptorProto
// Describes a message type.
define sealed class <descriptor-proto> (<protocol-buffer-message>)
  slot descriptor-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  slot descriptor-proto-field :: false-or(<sequence>), // repeated <field-descriptor-proto>
    init-value: #f,
    init-keyword: field:;
  slot descriptor-proto-extension :: false-or(<sequence>), // repeated <field-descriptor-proto>
    init-value: #f,
    init-keyword: extension:;
  slot descriptor-proto-nested-type :: false-or(<sequence>), // repeated <descriptor-proto>
    init-value: #f,
    init-keyword: nested-type:;
  slot descriptor-proto-enum-type :: false-or(<sequence>), // repeated <enum-descriptor-proto>
    init-value: #f,
    init-keyword: enum-type:;
  slot descriptor-proto-extension-range :: false-or(<sequence>), // repeated <descriptor-proto-extension-range>
    init-value: #f,
    init-keyword: extension-range:;
  slot descriptor-proto-oneof-decl :: false-or(<sequence>), // repeated <oneof-descriptor-proto>
    init-value: #f,
    init-keyword: oneof-decl:;
  slot descriptor-proto-options :: false-or(/* TODO: <message-options> */ <object>),
    init-value: #f,
    init-keyword: options:;
  slot descriptor-proto-reserved-range :: false-or(<sequence>), // repeated <descriptor-proto-reserved-range>
    init-value: #f,
    init-keyword: reserved-range:;
  slot descriptor-proto-reserved-name :: false-or(<sequence>), // repeated <string>
    init-value: #f,
    init-keyword: reserved-name:;
end class <descriptor-proto>;

// DescriptorProto.ExtensionRange
define sealed class <descriptor-proto-extension-range> (<protocol-buffer-message>)
  slot descriptor-proto-extension-range-start :: false-or(<int32>), // Inclusive.
    init-value: #f,
    init-keyword: start:;
  slot descriptor-proto-extension-range-end :: false-or(<int32>), // Exclusive.
    init-value: #f,
    init-keyword: end:;
  slot descriptor-proto-extension-range-options :: false-or(<extension-range-options>),
    init-value: #f,
    init-keyword: options:;
end class <descriptor-proto-extension-range>;

// DescriptorProto.ReservedRange
define sealed class <descriptor-proto-reserved-range> (<protocol-buffer-message>)
  slot descriptor-proto-reserved-range-start :: false-or(<int32>),
    init-value: #f,
    init-keyword: start:;
  slot descriptor-proto-reserved-range-end :: false-or(<int32>),
    init-value: #f,
    init-keyword: end:;
end class <descriptor-proto-reserved-range>;

// ExtensionRangeOptions
define sealed class <extension-range-options> (<protocol-buffer-message>)
  // The parser stores options it doesn't recognize here. See above.
  slot extension-range-options-uninterpreted-option :: false-or(<sequence>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
  // TODO: Do we need to do anything for this?
  // Clients can define custom options in extensions of this message. See above.
  //extensions 1000 to max;
end class <extension-range-options>;

// FieldDescriptorProto
// Describes a field within a message.
define sealed class <field-descriptor-proto> (<protocol-buffer-message>)
  slot field-descriptor-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  slot field-descriptor-proto-number :: false-or(<int32>),
    init-value: #f,
    init-keyword: number:;
  slot field-descriptor-proto-label :: false-or(<field-descriptor-proto-label>),
    init-value: #f,
    init-keyword: label:;
  // If type_name is set, this need not be set.  If both this and type_name
  // are set, this must be one of TYPE_ENUM, TYPE_MESSAGE or TYPE_GROUP.
  slot field-descriptor-proto-type :: false-or(<field-descriptor-proto-type>),
    init-value: #f,
    init-keyword: type:;
  // For message and enum types, this is the name of the type.  If the name
  // starts with a '.', it is fully-qualified.  Otherwise, C++-like scoping
  // rules are used to find the type (i.e. first the nested types within this
  // message are searched, then within the parent, on up to the root
  // namespace).
  slot field-descriptor-proto-type-name :: false-or(<string>),
    init-value: #f,
    init-keyword: type-name:;
  // For extensions, this is the name of the type being extended.  It is
  // resolved in the same manner as type_name.
  slot field-descriptor-proto-extendee :: false-or(<string>),
    init-value: #f,
    init-keyword: extendee:;
  // For numeric types, contains the original text representation of the value.
  // For booleans, "true" or "false".
  // For strings, contains the default text contents (not escaped in any way).
  // For bytes, contains the C escaped value.  All bytes >= 128 are escaped.
  slot field-descriptor-proto-default-value :: false-or(<string>),
    init-value: #f,
    init-keyword: default-value:;
  // If set, gives the index of a oneof in the containing type's oneof_decl
  // list.  This field is a member of that oneof.
  slot field-descriptor-proto-oneof-index :: false-or(<int32>),
    init-value: #f,
    init-keyword: oneof-index:;
  // JSON name of this field. The value is set by protocol compiler. If the
  // user has set a "json_name" option on this field, that option's value
  // will be used. Otherwise, it's deduced from the field's name by converting
  // it to camelCase.
  slot field-descriptor-proto-json-name :: false-or(<string>),
    init-value: #f,
    init-keyword: json-name:;

  slot field-descriptior-proto-options :: false-or(/* TODO: <FieldOptions> */ <object>),
    init-value: #f,
    init-keyword: options:;

  // If true, this is a proto3 "optional". When a proto3 field is optional, it
  // tracks presence regardless of field type.
  //
  // When proto3_optional is true, this field must be belong to a oneof to
  // signal to old proto3 clients that presence is tracked for this field. This
  // oneof is known as a "synthetic" oneof, and this field must be its sole
  // member (each proto3 optional field gets its own synthetic oneof). Synthetic
  // oneofs exist in the descriptor only, and do not generate any API. Synthetic
  // oneofs must be ordered after all "real" oneofs.
  //
  // For message fields, proto3_optional doesn't create any semantic change,
  // since non-repeated message fields always track presence. However it still
  // indicates the semantic detail of whether the user wrote "optional" or not.
  // This can be useful for round-tripping the .proto file. For consistency we
  // give message fields a synthetic oneof also, even though it is not required
  // to track presence. This is especially important because the parser can't
  // tell if a field is a message or an enum, so it must always create a
  // synthetic oneof.
  //
  // Proto2 optional fields do not set this flag, because they already indicate
  // optional with `LABEL_OPTIONAL`.
  slot field-descriptior-proto-proto3-optional :: <bool>,
    init-value: #f,
    init-keyword: proto3-optional:;
end class <field-descriptor-proto>;


// enum FieldDescriptorProto.Type
define class <field-descriptor-proto-type> (<protocol-buffer-enum>)
  constant slot field-descriptor-proto-type-name :: <string>,
    required-init-keyword: name:;
  slot field-descriptor-proto-type-value :: <int32>,
    required-init-keyword: value:;
end class <field-descriptor-proto-type>;

// 0 is reserved for errors.
// Order is weird for historical reasons.
define constant $field-descriptor-proto-type-type-double :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_DOUBLE",
         value: 1);
define constant $field-descriptor-proto-type-type-float :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_FLOAT",
         value: 2);
// Not ZigZag encoded.  Negative numbers take 10 bytes.  Use TYPE_SINT64 if
// negative values are likely.
define constant $field-descriptor-proto-type-type-int64 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_INT64",
         value: 3);
define constant $field-descriptor-proto-type-type-uint64 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_UINT64",
         value: 4);
// Not ZigZag encoded.  Negative numbers take 10 bytes.  Use TYPE_SINT32 if
// negative values are likely.
define constant $field-descriptor-proto-type-type-int32 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_INT32",
         value: 5);
define constant $field-descriptor-proto-type-type-fixed64 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_FIXED64",
         value: 6);
define constant $field-descriptor-proto-type-type-fixed32 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_FIXED32",
         value: 7);
define constant $field-descriptor-proto-type-type-bool :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_BOOL",
         value: 8);
define constant $field-descriptor-proto-type-type-string :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_STRING",
         value: 9);
// Tag-delimited aggregate.
// Group type is deprecated and not supported in proto3. However, Proto3
// implementations should still be able to parse the group wire format and
// treat group fields as unknown fields.
define constant $field-descriptor-proto-type-type-group :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_GROUP",
         value: 10);
define constant $field-descriptor-proto-type-type-message :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_MESSAGE",
         value: 11);

// New in version 2.
define constant $field-descriptor-proto-type-type-bytes :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_BYTES",
         value: 12);
define constant $field-descriptor-proto-type-type-uint32 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_UINT32",
         value: 13);
define constant $field-descriptor-proto-type-type-enum :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_ENUM",
         value: 14);
define constant $field-descriptor-proto-type-type-sfixed32 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_SFIXED32",
         value: 15);
define constant $field-descriptor-proto-type-type-sfixed64 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_SFIXED64",
         value: 16);
define constant $field-descriptor-proto-type-type-sint32 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_SINT32",
         value: 17);
define constant $field-descriptor-proto-type-type-sint64 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_SINT64",
         value: 18);
// end enum FieldDescriptorProto.Type


// enum FieldDescriptorProto.Label
define class <field-descriptor-proto-label> (<protocol-buffer-enum>)
  constant slot field-descriptor-proto-label-name :: <string>,
    required-init-keyword: name:;
  slot field-descriptor-proto-label-value :: <int32>,
    required-init-keyword: value:;
end class <field-descriptor-proto-label>;

// 0 is reserved for errors
define constant $field-descriptor-proto-label-label-optional :: <field-descriptor-proto-label>
  = make(<field-descriptor-proto-label>,
         name: "LABEL_OPTIONAL",
         value: 1);
define constant $field-descriptor-proto-label-label-required :: <field-descriptor-proto-label>
  = make(<field-descriptor-proto-label>,
         name: "LABEL_REQUIRED",
         value: 2);
define constant $field-descriptor-proto-label-label-repeated :: <field-descriptor-proto-label>
  = make(<field-descriptor-proto-label>,
         name: "LABEL_REPEATED",
         value: 3);
// end enum FieldDescriptorProto.Label

// Describes a oneof.
define class <oneof-descriptor-proto> (<protocol-buffer-message>)
  slot oneof-descriptior-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  slot oneof-descriptior-proto-options :: false-or(/* TODO: <OneofOptions> */ <object>),
    init-value: #f,
    init-keyword: options:;
end class <oneof-descriptor-proto>;

// Describes an enum type.
define class <enum-descriptor-proto> (<protocol-buffer-message>)
  slot enum-descriptior-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;

  slot enum-descriptior-proto-value :: false-or(<sequence>), // repeated EnumValueDescriptorProto
    init-value: #f,
    init-keyword: value:;

  slot enum-descriptior-proto-options :: false-or(<sequence>), // repeated EnumOptions
    init-value: #f,
    init-keyword: options:;

  // Range of reserved numeric values. Reserved numeric values may not be used
  // by enum values in the same enum declaration. Reserved ranges may not
  // overlap.
  //
  // Note that this is distinct from DescriptorProto.ReservedRange in that it
  // is inclusive such that it can appropriately represent the entire int32
  // domain.
  slot enum-descriptior-proto-reserved-range :: false-or(<sequence>), // repeated <enum-descriptor-proto-enum-reserved-range>
    init-value: #f,
    init-keyword: reserved-range:;

  // Reserved enum value names, which may not be reused. A given name may only
  // be reserved once.
  slot enum-descriptior-proto-reserved-name :: false-or(<string>),
    init-value: #f,
    init-keyword: reserved-name:;
end class <enum-descriptor-proto>;

// EnumDescriptorProto.EnumReservedRange
define class <enum-descriptor-proto-enum-reserved-range> (<protocol-buffer-message>)
  slot enum-descriptior-proto-enum-reserved-range-start :: false-or(<int32>),
    init-value: #f,
    init-keyword: start:;       // Inclusive.
  slot enum-descriptior-proto-enum-reserved-range-end :: false-or(<int32>),
    init-value: #f,
    init-keyword: end:;         // Inclusive.
end class <enum-descriptor-proto-enum-reserved-range>;

// Describes a value within an enum.
define class <enum-value-descriptor-proto> (<protocol-buffer-message>)
  slot enum-value-descriptior-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  slot enum-value-descriptior-proto-number :: false-or(<int32>),
    init-value: #f,
    init-keyword: number:;

  slot field-descriptior-proto-options :: false-or(/* TODO: <enum-value-options> */ <object>),
    init-value: #f,
    init-keyword: options:;
end class <enum-value-descriptor-proto>;

/* TODO: the rest...

// Describes a service.
message ServiceDescriptorProto {
  optional string name = 1;
  repeated MethodDescriptorProto method = 2;

  optional ServiceOptions options = 3;
}

// Describes a method of a service.
message MethodDescriptorProto {
  optional string name = 1;

  // Input and output type names.  These are resolved in the same way as
  // FieldDescriptorProto.type_name, but must refer to a message type.
  optional string input_type = 2;
  optional string output_type = 3;

  optional MethodOptions options = 4;

  // Identifies if client streams multiple client messages
  optional bool client_streaming = 5 [default = false];
  // Identifies if server streams multiple server messages
  optional bool server_streaming = 6 [default = false];
}


// ===================================================================
// Options

// Each of the definitions above may have "options" attached.  These are
// just annotations which may cause code to be generated slightly differently
// or may contain hints for code that manipulates protocol messages.
//
// Clients may define custom options as extensions of the *Options messages.
// These extensions may not yet be known at parsing time, so the parser cannot
// store the values in them.  Instead it stores them in a field in the *Options
// message called uninterpreted_option. This field must have the same name
// across all *Options messages. We then use this field to populate the
// extensions when we build a descriptor, at which point all protos have been
// parsed and so all extensions are known.
//
// Extension numbers for custom options may be chosen as follows:
// * For options which will only be used within a single application or
//   organization, or for experimental options, use field numbers 50000
//   through 99999.  It is up to you to ensure that you do not use the
//   same number for multiple options.
// * For options which will be published and used publicly by multiple
//   independent entities, e-mail protobuf-global-extension-registry@google.com
//   to reserve extension numbers. Simply provide your project name (e.g.
//   Objective-C plugin) and your project website (if available) -- there's no
//   need to explain how you intend to use them. Usually you only need one
//   extension number. You can declare multiple options with only one extension
//   number by putting them in a sub-message. See the Custom Options section of
//   the docs for examples:
//   https://developers.google.com/protocol-buffers/docs/proto#options
//   If this turns out to be popular, a web service will be set up
//   to automatically assign option numbers.

message FileOptions {

  // Sets the Java package where classes generated from this .proto will be
  // placed.  By default, the proto package is used, but this is often
  // inappropriate because proto packages do not normally start with backwards
  // domain names.
  optional string java_package = 1;


  // If set, all the classes from the .proto file are wrapped in a single
  // outer class with the given name.  This applies to both Proto1
  // (equivalent to the old "--one_java_file" option) and Proto2 (where
  // a .proto always translates to a single class, but you may want to
  // explicitly choose the class name).
  optional string java_outer_classname = 8;

  // If set true, then the Java code generator will generate a separate .java
  // file for each top-level message, enum, and service defined in the .proto
  // file.  Thus, these types will *not* be nested inside the outer class
  // named by java_outer_classname.  However, the outer class will still be
  // generated to contain the file's getDescriptor() method as well as any
  // top-level extensions defined in the file.
  optional bool java_multiple_files = 10 [default = false];

  // This option does nothing.
  optional bool java_generate_equals_and_hash = 20 [deprecated=true];

  // If set true, then the Java2 code generator will generate code that
  // throws an exception whenever an attempt is made to assign a non-UTF-8
  // byte sequence to a string field.
  // Message reflection will do the same.
  // However, an extension field still accepts non-UTF-8 byte sequences.
  // This option has no effect on when used with the lite runtime.
  optional bool java_string_check_utf8 = 27 [default = false];


  // Generated classes can be optimized for speed or code size.
  enum OptimizeMode {
    SPEED = 1;         // Generate complete code for parsing, serialization,
                       // etc.
    CODE_SIZE = 2;     // Use ReflectionOps to implement these methods.
    LITE_RUNTIME = 3;  // Generate code using MessageLite and the lite runtime.
  }
  optional OptimizeMode optimize_for = 9 [default = SPEED];

  // Sets the Go package where structs generated from this .proto will be
  // placed. If omitted, the Go package will be derived from the following:
  //   - The basename of the package import path, if provided.
  //   - Otherwise, the package statement in the .proto file, if present.
  //   - Otherwise, the basename of the .proto file, without extension.
  optional string go_package = 11;




  // Should generic services be generated in each language?  "Generic" services
  // are not specific to any particular RPC system.  They are generated by the
  // main code generators in each language (without additional plugins).
  // Generic services were the only kind of service generation supported by
  // early versions of google.protobuf.
  //
  // Generic services are now considered deprecated in favor of using plugins
  // that generate code specific to your particular RPC system.  Therefore,
  // these default to false.  Old code which depends on generic services should
  // explicitly set them to true.
  optional bool cc_generic_services = 16 [default = false];
  optional bool java_generic_services = 17 [default = false];
  optional bool py_generic_services = 18 [default = false];
  optional bool php_generic_services = 42 [default = false];

  // Is this file deprecated?
  // Depending on the target platform, this can emit Deprecated annotations
  // for everything in the file, or it will be completely ignored; in the very
  // least, this is a formalization for deprecating files.
  optional bool deprecated = 23 [default = false];

  // Enables the use of arenas for the proto messages in this file. This applies
  // only to generated classes for C++.
  optional bool cc_enable_arenas = 31 [default = true];


  // Sets the objective c class prefix which is prepended to all objective c
  // generated classes from this .proto. There is no default.
  optional string objc_class_prefix = 36;

  // Namespace for generated classes; defaults to the package.
  optional string csharp_namespace = 37;

  // By default Swift generators will take the proto package and CamelCase it
  // replacing '.' with underscore and use that to prefix the types/symbols
  // defined. When this options is provided, they will use this value instead
  // to prefix the types/symbols defined.
  optional string swift_prefix = 39;

  // Sets the php class prefix which is prepended to all php generated classes
  // from this .proto. Default is empty.
  optional string php_class_prefix = 40;

  // Use this option to change the namespace of php generated classes. Default
  // is empty. When this option is empty, the package name will be used for
  // determining the namespace.
  optional string php_namespace = 41;

  // Use this option to change the namespace of php generated metadata classes.
  // Default is empty. When this option is empty, the proto file name will be
  // used for determining the namespace.
  optional string php_metadata_namespace = 44;

  // Use this option to change the package of ruby generated classes. Default
  // is empty. When this option is not set, the package name will be used for
  // determining the ruby package.
  optional string ruby_package = 45;


  // The parser stores options it doesn't recognize here.
  // See the documentation for the "Options" section above.
  repeated UninterpretedOption uninterpreted_option = 999;

  // Clients can define custom options in extensions of this message.
  // See the documentation for the "Options" section above.
  extensions 1000 to max;

  reserved 38;
}

message MessageOptions {
  // Set true to use the old proto1 MessageSet wire format for extensions.
  // This is provided for backwards-compatibility with the MessageSet wire
  // format.  You should not use this for any other reason:  It's less
  // efficient, has fewer features, and is more complicated.
  //
  // The message must be defined exactly as follows:
  //   message Foo {
  //     option message_set_wire_format = true;
  //     extensions 4 to max;
  //   }
  // Note that the message cannot have any defined fields; MessageSets only
  // have extensions.
  //
  // All extensions of your type must be singular messages; e.g. they cannot
  // be int32s, enums, or repeated messages.
  //
  // Because this is an option, the above two restrictions are not enforced by
  // the protocol compiler.
  optional bool message_set_wire_format = 1 [default = false];

  // Disables the generation of the standard "descriptor()" accessor, which can
  // conflict with a field of the same name.  This is meant to make migration
  // from proto1 easier; new code should avoid fields named "descriptor".
  optional bool no_standard_descriptor_accessor = 2 [default = false];

  // Is this message deprecated?
  // Depending on the target platform, this can emit Deprecated annotations
  // for the message, or it will be completely ignored; in the very least,
  // this is a formalization for deprecating messages.
  optional bool deprecated = 3 [default = false];

  // Whether the message is an automatically generated map entry type for the
  // maps field.
  //
  // For maps fields:
  //     map<KeyType, ValueType> map_field = 1;
  // The parsed descriptor looks like:
  //     message MapFieldEntry {
  //         option map_entry = true;
  //         optional KeyType key = 1;
  //         optional ValueType value = 2;
  //     }
  //     repeated MapFieldEntry map_field = 1;
  //
  // Implementations may choose not to generate the map_entry=true message, but
  // use a native map in the target language to hold the keys and values.
  // The reflection APIs in such implementations still need to work as
  // if the field is a repeated message field.
  //
  // NOTE: Do not set the option in .proto files. Always use the maps syntax
  // instead. The option should only be implicitly set by the proto compiler
  // parser.
  optional bool map_entry = 7;

  reserved 8;  // javalite_serializable
  reserved 9;  // javanano_as_lite


  // The parser stores options it doesn't recognize here. See above.
  repeated UninterpretedOption uninterpreted_option = 999;

  // Clients can define custom options in extensions of this message. See above.
  extensions 1000 to max;
}
*/

// TODO: For now this is just enough to store the set of options used in
// descriptor.proto: default (stored in <field-descriptor-proto>.default-value),
// deprecated, and packed.
define class <field-options> (<protocol-buffer-message>)
  slot field-options-deprecated :: <bool>,
    init-value: #f,
    init-keyword: deprecated:;
  slot field-options-packed :: <bool>,
    init-value: #f,
    init-keyword: packed:;
end class <field-options>;

/*
message FieldOptions {
  // The ctype option instructs the C++ code generator to use a different
  // representation of the field than it normally would.  See the specific
  // options below.  This option is not yet implemented in the open source
  // release -- sorry, we'll try to include it in a future version!
  optional CType ctype = 1 [default = STRING];
  enum CType {
    // Default mode.
    STRING = 0;

    CORD = 1;

    STRING_PIECE = 2;
  }
  // The packed option can be enabled for repeated primitive fields to enable
  // a more efficient representation on the wire. Rather than repeatedly
  // writing the tag and type for each element, the entire array is encoded as
  // a single length-delimited blob. In proto3, only explicit setting it to
  // false will avoid using packed encoding.
  optional bool packed = 2;

  // The jstype option determines the JavaScript type used for values of the
  // field.  The option is permitted only for 64 bit integral and fixed types
  // (int64, uint64, sint64, fixed64, sfixed64).  A field with jstype JS_STRING
  // is represented as JavaScript string, which avoids loss of precision that
  // can happen when a large value is converted to a floating point JavaScript.
  // Specifying JS_NUMBER for the jstype causes the generated JavaScript code to
  // use the JavaScript "number" type.  The behavior of the default option
  // JS_NORMAL is implementation dependent.
  //
  // This option is an enum to permit additional types to be added, e.g.
  // goog.math.Integer.
  optional JSType jstype = 6 [default = JS_NORMAL];
  enum JSType {
    // Use the default type.
    JS_NORMAL = 0;

    // Use JavaScript strings.
    JS_STRING = 1;

    // Use JavaScript numbers.
    JS_NUMBER = 2;
  }

  // Should this field be parsed lazily?  Lazy applies only to message-type
  // fields.  It means that when the outer message is initially parsed, the
  // inner message's contents will not be parsed but instead stored in encoded
  // form.  The inner message will actually be parsed when it is first accessed.
  //
  // This is only a hint.  Implementations are free to choose whether to use
  // eager or lazy parsing regardless of the value of this option.  However,
  // setting this option true suggests that the protocol author believes that
  // using lazy parsing on this field is worth the additional bookkeeping
  // overhead typically needed to implement it.
  //
  // This option does not affect the public interface of any generated code;
  // all method signatures remain the same.  Furthermore, thread-safety of the
  // interface is not affected by this option; const methods remain safe to
  // call from multiple threads concurrently, while non-const methods continue
  // to require exclusive access.
  //
  //
  // Note that implementations may choose not to check required fields within
  // a lazy sub-message.  That is, calling IsInitialized() on the outer message
  // may return true even if the inner message has missing required fields.
  // This is necessary because otherwise the inner message would have to be
  // parsed in order to perform the check, defeating the purpose of lazy
  // parsing.  An implementation which chooses not to check required fields
  // must be consistent about it.  That is, for any particular sub-message, the
  // implementation must either *always* check its required fields, or *never*
  // check its required fields, regardless of whether or not the message has
  // been parsed.
  optional bool lazy = 5 [default = false];

  // Is this field deprecated?
  // Depending on the target platform, this can emit Deprecated annotations
  // for accessors, or it will be completely ignored; in the very least, this
  // is a formalization for deprecating fields.
  optional bool deprecated = 3 [default = false];

  // For Google-internal migration only. Do not use.
  optional bool weak = 10 [default = false];


  // The parser stores options it doesn't recognize here. See above.
  repeated UninterpretedOption uninterpreted_option = 999;

  // Clients can define custom options in extensions of this message. See above.
  extensions 1000 to max;

  reserved 4;  // removed jtype
}

message OneofOptions {
  // The parser stores options it doesn't recognize here. See above.
  repeated UninterpretedOption uninterpreted_option = 999;

  // Clients can define custom options in extensions of this message. See above.
  extensions 1000 to max;
}

message EnumOptions {

  // Set this option to true to allow mapping different tag names to the same
  // value.
  optional bool allow_alias = 2;

  // Is this enum deprecated?
  // Depending on the target platform, this can emit Deprecated annotations
  // for the enum, or it will be completely ignored; in the very least, this
  // is a formalization for deprecating enums.
  optional bool deprecated = 3 [default = false];

  reserved 5;  // javanano_as_lite

  // The parser stores options it doesn't recognize here. See above.
  repeated UninterpretedOption uninterpreted_option = 999;

  // Clients can define custom options in extensions of this message. See above.
  extensions 1000 to max;
}
*/

define class <enum-value-options> (<protocol-buffer-message>)
  // Is this enum value deprecated?
  // Depending on the target platform, this can emit Deprecated annotations
  // for the enum value, or it will be completely ignored; in the very least,
  // this is a formalization for deprecating enum values.
  slot enum-value-options-deprecated :: <bool>,
    init-value: #f,
    init-keyword: deprecated:;
  // The parser stores options it doesn't recognize here. See above.
  slot enum-value-options-uninterpreted-option :: false-or(<sequence>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
  // Clients can define custom options in extensions of this message. See above.
  // TODO: extensions 1000 to max;
end class <enum-value-options>;

/*
message ServiceOptions {

  // Note:  Field numbers 1 through 32 are reserved for Google's internal RPC
  //   framework.  We apologize for hoarding these numbers to ourselves, but
  //   we were already using them long before we decided to release Protocol
  //   Buffers.

  // Is this service deprecated?
  // Depending on the target platform, this can emit Deprecated annotations
  // for the service, or it will be completely ignored; in the very least,
  // this is a formalization for deprecating services.
  optional bool deprecated = 33 [default = false];

  // The parser stores options it doesn't recognize here. See above.
  repeated UninterpretedOption uninterpreted_option = 999;

  // Clients can define custom options in extensions of this message. See above.
  extensions 1000 to max;
}

message MethodOptions {

  // Note:  Field numbers 1 through 32 are reserved for Google's internal RPC
  //   framework.  We apologize for hoarding these numbers to ourselves, but
  //   we were already using them long before we decided to release Protocol
  //   Buffers.

  // Is this method deprecated?
  // Depending on the target platform, this can emit Deprecated annotations
  // for the method, or it will be completely ignored; in the very least,
  // this is a formalization for deprecating methods.
  optional bool deprecated = 33 [default = false];

  // Is this method side-effect-free (or safe in HTTP parlance), or idempotent,
  // or neither? HTTP based RPC implementation may choose GET verb for safe
  // methods, and PUT verb for idempotent methods instead of the default POST.
  enum IdempotencyLevel {
    IDEMPOTENCY_UNKNOWN = 0;
    NO_SIDE_EFFECTS = 1;  // implies idempotent
    IDEMPOTENT = 2;       // idempotent, but may have side effects
  }
  optional IdempotencyLevel idempotency_level = 34
      [default = IDEMPOTENCY_UNKNOWN];

  // The parser stores options it doesn't recognize here. See above.
  repeated UninterpretedOption uninterpreted_option = 999;

  // Clients can define custom options in extensions of this message. See above.
  extensions 1000 to max;
}


// A message representing a option the parser does not recognize. This only
// appears in options protos created by the compiler::Parser class.
// DescriptorPool resolves these when building Descriptor objects. Therefore,
// options protos in descriptor objects (e.g. returned by Descriptor::options(),
// or produced by Descriptor::CopyTo()) will never have UninterpretedOptions
// in them.
message UninterpretedOption {
  // The name of the uninterpreted option.  Each string represents a segment in
  // a dot-separated name.  is_extension is true iff a segment represents an
  // extension (denoted with parentheses in options specs in .proto files).
  // E.g.,{ ["foo", false], ["bar.baz", true], ["qux", false] } represents
  // "foo.(bar.baz).qux".
  message NamePart {
    required string name_part = 1;
    required bool is_extension = 2;
  }
  repeated NamePart name = 2;

  // The value of the uninterpreted option, in whatever type the tokenizer
  // identified it as during parsing. Exactly one of these should be set.
  optional string identifier_value = 3;
  optional uint64 positive_int_value = 4;
  optional int64 negative_int_value = 5;
  optional double double_value = 6;
  optional bytes string_value = 7;
  optional string aggregate_value = 8;
}

// ===================================================================
// Optional source code info

// Encapsulates information about the original source file from which a
// FileDescriptorProto was generated.
message SourceCodeInfo {
  // A Location identifies a piece of source code in a .proto file which
  // corresponds to a particular definition.  This information is intended
  // to be useful to IDEs, code indexers, documentation generators, and similar
  // tools.
  //
  // For example, say we have a file like:
  //   message Foo {
  //     optional string foo = 1;
  //   }
  // Let's look at just the field definition:
  //   optional string foo = 1;
  //   ^       ^^     ^^  ^  ^^^
  //   a       bc     de  f  ghi
  // We have the following locations:
  //   span   path               represents
  //   [a,i)  [ 4, 0, 2, 0 ]     The whole field definition.
  //   [a,b)  [ 4, 0, 2, 0, 4 ]  The label (optional).
  //   [c,d)  [ 4, 0, 2, 0, 5 ]  The type (string).
  //   [e,f)  [ 4, 0, 2, 0, 1 ]  The name (foo).
  //   [g,h)  [ 4, 0, 2, 0, 3 ]  The number (1).
  //
  // Notes:
  // - A location may refer to a repeated field itself (i.e. not to any
  //   particular index within it).  This is used whenever a set of elements are
  //   logically enclosed in a single code segment.  For example, an entire
  //   extend block (possibly containing multiple extension definitions) will
  //   have an outer location whose path refers to the "extensions" repeated
  //   field without an index.
  // - Multiple locations may have the same path.  This happens when a single
  //   logical declaration is spread out across multiple places.  The most
  //   obvious example is the "extend" block again -- there may be multiple
  //   extend blocks in the same scope, each of which will have the same path.
  // - A location's span is not always a subset of its parent's span.  For
  //   example, the "extendee" of an extension declaration appears at the
  //   beginning of the "extend" block and is shared by all extensions within
  //   the block.
  // - Just because a location's span is a subset of some other location's span
  //   does not mean that it is a descendant.  For example, a "group" defines
  //   both a type and a field in a single declaration.  Thus, the locations
  //   corresponding to the type and field and their components will overlap.
  // - Code which tries to interpret locations should probably be designed to
  //   ignore those that it doesn't understand, as more types of locations could
  //   be recorded in the future.
  repeated Location location = 1;
  message Location {
    // Identifies which part of the FileDescriptorProto was defined at this
    // location.
    //
    // Each element is a field number or an index.  They form a path from
    // the root FileDescriptorProto to the place where the definition.  For
    // example, this path:
    //   [ 4, 3, 2, 7, 1 ]
    // refers to:
    //   file.message_type(3)  // 4, 3
    //       .field(7)         // 2, 7
    //       .name()           // 1
    // This is because FileDescriptorProto.message_type has field number 4:
    //   repeated DescriptorProto message_type = 4;
    // and DescriptorProto.field has field number 2:
    //   repeated FieldDescriptorProto field = 2;
    // and FieldDescriptorProto.name has field number 1:
    //   optional string name = 1;
    //
    // Thus, the above path gives the location of a field name.  If we removed
    // the last element:
    //   [ 4, 3, 2, 7 ]
    // this path refers to the whole field declaration (from the beginning
    // of the label to the terminating semicolon).
    repeated int32 path = 1 [packed = true];

    // Always has exactly three or four elements: start line, start column,
    // end line (optional, otherwise assumed same as start line), end column.
    // These are packed into a single field for efficiency.  Note that line
    // and column numbers are zero-based -- typically you will want to add
    // 1 to each before displaying to a user.
    repeated int32 span = 2 [packed = true];

    // If this SourceCodeInfo represents a complete declaration, these are any
    // comments appearing before and after the declaration which appear to be
    // attached to the declaration.
    //
    // A series of line comments appearing on consecutive lines, with no other
    // tokens appearing on those lines, will be treated as a single comment.
    //
    // leading_detached_comments will keep paragraphs of comments that appear
    // before (but not connected to) the current element. Each paragraph,
    // separated by empty lines, will be one comment element in the repeated
    // field.
    //
    // Only the comment content is provided; comment markers (e.g. //) are
    // stripped out.  For block comments, leading whitespace and an asterisk
    // will be stripped from the beginning of each line other than the first.
    // Newlines are included in the output.
    //
    // Examples:
    //
    //   optional int32 foo = 1;  // Comment attached to foo.
    //   // Comment attached to bar.
    //   optional int32 bar = 2;
    //
    //   optional string baz = 3;
    //   // Comment attached to baz.
    //   // Another line attached to baz.
    //
    //   // Comment attached to qux.
    //   //
    //   // Another line attached to qux.
    //   optional double qux = 4;
    //
    //   // Detached comment for corge. This is not leading or trailing comments
    //   // to qux or corge because there are blank lines separating it from
    //   // both.
    //
    //   // Detached comment for corge paragraph 2.
    //
    //   optional string corge = 5;
    //   /* Block comment attached
    //    * to corge.  Leading asterisks
    //    * will be removed. */
    //   /* Block comment attached to
    //    * grault. */
    //   optional int32 grault = 6;
    //
    //   // ignored detached comments.
    optional string leading_comments = 3;
    optional string trailing_comments = 4;
    repeated string leading_detached_comments = 6;
  }
}

// Describes the relationship between generated code and its original source
// file. A GeneratedCodeInfo message is associated with only one generated
// source file, but may contain references to different source .proto files.
message GeneratedCodeInfo {
  // An Annotation connects some span of text in generated code to an element
  // of its generating .proto file.
  repeated Annotation annotation = 1;
  message Annotation {
    // Identifies the element in the original source .proto file. This field
    // is formatted the same as SourceCodeInfo.Location.path.
    repeated int32 path = 1 [packed = true];

    // Identifies the filesystem path to the original source .proto.
    optional string source_file = 2;

    // Identifies the starting offset in bytes in the generated code
    // that relates to the identified object.
    optional int32 begin = 3;

    // Identifies the ending offset in bytes in the generated code that
    // relates to the identified offset. The end offset should be one past
    // the last relevant byte (so the length of the text = end - begin).
    optional int32 end = 4;
  }
}
*/

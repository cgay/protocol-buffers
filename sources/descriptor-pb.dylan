Module: google-protobuf

// The protocol compiler can output a FileDescriptorSet containing the .proto
// files it parses.
define class <file-descriptor-set> (<protocol-buffer-message>)
  slot file-descriptor-set-file :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: file:;
end class <file-descriptor-set>;

define method add-file-descriptor-set-file
    (msg :: <file-descriptor-set>, new :: <file-descriptor-proto>) => (new :: <file-descriptor-proto>)
  let v = msg.file-descriptor-set-file;
  if (~v)
    v := make(<stretchy-vector>);
    msg.file-descriptor-set-file := v;
  end;
  add!(v, new);
  new
end method add-file-descriptor-set-file;

// Describes a complete .proto file.
define class <file-descriptor-proto> (<protocol-buffer-message>)
  // file name, relative to root of source tree
  slot file-descriptor-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  // e.g. "foo", "foo.bar", etc.
  slot file-descriptor-proto-package :: false-or(<string>),
    init-value: #f,
    init-keyword: package:;
  // Names of files imported by this file.
  slot file-descriptor-proto-dependency :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: dependency:;
  // Indexes of the public imported files in the dependency list above.
  slot file-descriptor-proto-public-dependency :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: public-dependency:;
  // Indexes of the weak imported files in the dependency list.
  // For Google-internal migration only. Do not use.
  slot file-descriptor-proto-weak-dependency :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: weak-dependency:;
  // All top-level definitions in this file.
  slot file-descriptor-proto-message-type :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: message-type:;
  slot file-descriptor-proto-enum-type :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: enum-type:;
  slot file-descriptor-proto-service :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: service:;
  slot file-descriptor-proto-extension :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: extension:;
  slot file-descriptor-proto-options :: false-or(<file-options>),
    init-value: #f,
    init-keyword: options:;
  // This field contains optional information about the original source code.
  // You may safely remove this entire field without harming runtime
  // functionality of the descriptors -- the information is needed only by
  // development tools.
  slot file-descriptor-proto-source-code-info :: false-or(<source-code-info>),
    init-value: #f,
    init-keyword: source-code-info:;
  // The syntax of the proto file.
  // The supported values are "proto2", "proto3", and "editions".
  //
  // If `edition` is present, this value must be "editions".
  slot file-descriptor-proto-syntax :: false-or(<string>),
    init-value: #f,
    init-keyword: syntax:;
  // The edition of the proto file, which is an opaque string.
  slot file-descriptor-proto-edition :: false-or(<string>),
    init-value: #f,
    init-keyword: edition:;
end class <file-descriptor-proto>;

define method add-file-descriptor-proto-dependency
    (msg :: <file-descriptor-proto>, new :: <string>) => (new :: <string>)
  let v = msg.file-descriptor-proto-dependency;
  if (~v)
    v := make(<stretchy-vector>);
    msg.file-descriptor-proto-dependency := v;
  end;
  add!(v, new);
  new
end method add-file-descriptor-proto-dependency;

define method add-file-descriptor-proto-public-dependency
    (msg :: <file-descriptor-proto>, new :: <int32>) => (new :: <int32>)
  let v = msg.file-descriptor-proto-public-dependency;
  if (~v)
    v := make(<stretchy-vector>);
    msg.file-descriptor-proto-public-dependency := v;
  end;
  add!(v, new);
  new
end method add-file-descriptor-proto-public-dependency;

define method add-file-descriptor-proto-weak-dependency
    (msg :: <file-descriptor-proto>, new :: <int32>) => (new :: <int32>)
  let v = msg.file-descriptor-proto-weak-dependency;
  if (~v)
    v := make(<stretchy-vector>);
    msg.file-descriptor-proto-weak-dependency := v;
  end;
  add!(v, new);
  new
end method add-file-descriptor-proto-weak-dependency;

define method add-file-descriptor-proto-message-type
    (msg :: <file-descriptor-proto>, new :: <descriptor-proto>) => (new :: <descriptor-proto>)
  let v = msg.file-descriptor-proto-message-type;
  if (~v)
    v := make(<stretchy-vector>);
    msg.file-descriptor-proto-message-type := v;
  end;
  add!(v, new);
  new
end method add-file-descriptor-proto-message-type;

define method add-file-descriptor-proto-enum-type
    (msg :: <file-descriptor-proto>, new :: <enum-descriptor-proto>) => (new :: <enum-descriptor-proto>)
  let v = msg.file-descriptor-proto-enum-type;
  if (~v)
    v := make(<stretchy-vector>);
    msg.file-descriptor-proto-enum-type := v;
  end;
  add!(v, new);
  new
end method add-file-descriptor-proto-enum-type;

define method add-file-descriptor-proto-service
    (msg :: <file-descriptor-proto>, new :: <service-descriptor-proto>) => (new :: <service-descriptor-proto>)
  let v = msg.file-descriptor-proto-service;
  if (~v)
    v := make(<stretchy-vector>);
    msg.file-descriptor-proto-service := v;
  end;
  add!(v, new);
  new
end method add-file-descriptor-proto-service;

define method add-file-descriptor-proto-extension
    (msg :: <file-descriptor-proto>, new :: <field-descriptor-proto>) => (new :: <field-descriptor-proto>)
  let v = msg.file-descriptor-proto-extension;
  if (~v)
    v := make(<stretchy-vector>);
    msg.file-descriptor-proto-extension := v;
  end;
  add!(v, new);
  new
end method add-file-descriptor-proto-extension;

// Describes a message type.
define class <descriptor-proto> (<protocol-buffer-message>)
  slot descriptor-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  slot descriptor-proto-field :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: field:;
  slot descriptor-proto-extension :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: extension:;
  slot descriptor-proto-nested-type :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: nested-type:;
  slot descriptor-proto-enum-type :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: enum-type:;
  slot descriptor-proto-extension-range :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: extension-range:;
  slot descriptor-proto-oneof-decl :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: oneof-decl:;
  slot descriptor-proto-options :: false-or(<message-options>),
    init-value: #f,
    init-keyword: options:;
  slot descriptor-proto-reserved-range :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: reserved-range:;
  // Reserved field names, which may not be used by fields in the same message.
  // A given name may only be reserved once.
  slot descriptor-proto-reserved-name :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: reserved-name:;
end class <descriptor-proto>;

define method add-descriptor-proto-field
    (msg :: <descriptor-proto>, new :: <field-descriptor-proto>) => (new :: <field-descriptor-proto>)
  let v = msg.descriptor-proto-field;
  if (~v)
    v := make(<stretchy-vector>);
    msg.descriptor-proto-field := v;
  end;
  add!(v, new);
  new
end method add-descriptor-proto-field;

define method add-descriptor-proto-extension
    (msg :: <descriptor-proto>, new :: <field-descriptor-proto>) => (new :: <field-descriptor-proto>)
  let v = msg.descriptor-proto-extension;
  if (~v)
    v := make(<stretchy-vector>);
    msg.descriptor-proto-extension := v;
  end;
  add!(v, new);
  new
end method add-descriptor-proto-extension;

define method add-descriptor-proto-nested-type
    (msg :: <descriptor-proto>, new :: <descriptor-proto>) => (new :: <descriptor-proto>)
  let v = msg.descriptor-proto-nested-type;
  if (~v)
    v := make(<stretchy-vector>);
    msg.descriptor-proto-nested-type := v;
  end;
  add!(v, new);
  new
end method add-descriptor-proto-nested-type;

define method add-descriptor-proto-enum-type
    (msg :: <descriptor-proto>, new :: <enum-descriptor-proto>) => (new :: <enum-descriptor-proto>)
  let v = msg.descriptor-proto-enum-type;
  if (~v)
    v := make(<stretchy-vector>);
    msg.descriptor-proto-enum-type := v;
  end;
  add!(v, new);
  new
end method add-descriptor-proto-enum-type;

define method add-descriptor-proto-extension-range
    (msg :: <descriptor-proto>, new :: <descriptor-proto-extension-range>) => (new :: <descriptor-proto-extension-range>)
  let v = msg.descriptor-proto-extension-range;
  if (~v)
    v := make(<stretchy-vector>);
    msg.descriptor-proto-extension-range := v;
  end;
  add!(v, new);
  new
end method add-descriptor-proto-extension-range;

define method add-descriptor-proto-oneof-decl
    (msg :: <descriptor-proto>, new :: <oneof-descriptor-proto>) => (new :: <oneof-descriptor-proto>)
  let v = msg.descriptor-proto-oneof-decl;
  if (~v)
    v := make(<stretchy-vector>);
    msg.descriptor-proto-oneof-decl := v;
  end;
  add!(v, new);
  new
end method add-descriptor-proto-oneof-decl;

define method add-descriptor-proto-reserved-range
    (msg :: <descriptor-proto>, new :: <descriptor-proto-reserved-range>) => (new :: <descriptor-proto-reserved-range>)
  let v = msg.descriptor-proto-reserved-range;
  if (~v)
    v := make(<stretchy-vector>);
    msg.descriptor-proto-reserved-range := v;
  end;
  add!(v, new);
  new
end method add-descriptor-proto-reserved-range;

define method add-descriptor-proto-reserved-name
    (msg :: <descriptor-proto>, new :: <string>) => (new :: <string>)
  let v = msg.descriptor-proto-reserved-name;
  if (~v)
    v := make(<stretchy-vector>);
    msg.descriptor-proto-reserved-name := v;
  end;
  add!(v, new);
  new
end method add-descriptor-proto-reserved-name;

define class <descriptor-proto-extension-range> (<protocol-buffer-message>)
  // Inclusive.
  slot descriptor-proto-extension-range-start :: false-or(<int32>),
    init-value: #f,
    init-keyword: start:;
  // Exclusive.
  slot descriptor-proto-extension-range-end :: false-or(<int32>),
    init-value: #f,
    init-keyword: end:;
  slot descriptor-proto-extension-range-options :: false-or(<extension-range-options>),
    init-value: #f,
    init-keyword: options:;
end class <descriptor-proto-extension-range>;

// Range of reserved tag numbers. Reserved tag numbers may not be used by
// fields or extension ranges in the same message. Reserved ranges may
// not overlap.
define class <descriptor-proto-reserved-range> (<protocol-buffer-message>)
  // Inclusive.
  slot descriptor-proto-reserved-range-start :: false-or(<int32>),
    init-value: #f,
    init-keyword: start:;
  // Exclusive.
  slot descriptor-proto-reserved-range-end :: false-or(<int32>),
    init-value: #f,
    init-keyword: end:;
end class <descriptor-proto-reserved-range>;

define class <extension-range-options> (<protocol-buffer-message>)
  // The parser stores options it doesn't recognize here. See above.
  slot extension-range-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <extension-range-options>;

define method add-extension-range-options-uninterpreted-option
    (msg :: <extension-range-options>, new :: <uninterpreted-option>) => (new :: <uninterpreted-option>)
  let v = msg.extension-range-options-uninterpreted-option;
  if (~v)
    v := make(<stretchy-vector>);
    msg.extension-range-options-uninterpreted-option := v;
  end;
  add!(v, new);
  new
end method add-extension-range-options-uninterpreted-option;

// Describes a field within a message.
define class <field-descriptor-proto> (<protocol-buffer-message>)
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
  slot field-descriptor-proto-options :: false-or(<field-options>),
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
  slot field-descriptor-proto-proto3-optional :: <boolean>,
    init-value: #f,
    init-keyword: proto3-optional:;
end class <field-descriptor-proto>;

define class <field-descriptor-proto-type> (<protocol-buffer-enum>) end;

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
// Length-delimited aggregate.
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
// Uses ZigZag encoding.
define constant $field-descriptor-proto-type-type-sint64 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_SINT64",
         value: 18);

define class <field-descriptor-proto-label> (<protocol-buffer-enum>) end;

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

// Describes a oneof.
define class <oneof-descriptor-proto> (<protocol-buffer-message>)
  slot oneof-descriptor-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  slot oneof-descriptor-proto-options :: false-or(<oneof-options>),
    init-value: #f,
    init-keyword: options:;
end class <oneof-descriptor-proto>;

// Describes an enum type.
define class <enum-descriptor-proto> (<protocol-buffer-message>)
  slot enum-descriptor-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  slot enum-descriptor-proto-value :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: value:;
  slot enum-descriptor-proto-options :: false-or(<enum-options>),
    init-value: #f,
    init-keyword: options:;
  // Range of reserved numeric values. Reserved numeric values may not be used
  // by enum values in the same enum declaration. Reserved ranges may not
  // overlap.
  slot enum-descriptor-proto-reserved-range :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: reserved-range:;
  // Reserved enum value names, which may not be reused. A given name may only
  // be reserved once.
  slot enum-descriptor-proto-reserved-name :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: reserved-name:;
end class <enum-descriptor-proto>;

define method add-enum-descriptor-proto-value
    (msg :: <enum-descriptor-proto>, new :: <enum-value-descriptor-proto>) => (new :: <enum-value-descriptor-proto>)
  let v = msg.enum-descriptor-proto-value;
  if (~v)
    v := make(<stretchy-vector>);
    msg.enum-descriptor-proto-value := v;
  end;
  add!(v, new);
  new
end method add-enum-descriptor-proto-value;

define method add-enum-descriptor-proto-reserved-range
    (msg :: <enum-descriptor-proto>, new :: <enum-descriptor-proto-enum-reserved-range>) => (new :: <enum-descriptor-proto-enum-reserved-range>)
  let v = msg.enum-descriptor-proto-reserved-range;
  if (~v)
    v := make(<stretchy-vector>);
    msg.enum-descriptor-proto-reserved-range := v;
  end;
  add!(v, new);
  new
end method add-enum-descriptor-proto-reserved-range;

define method add-enum-descriptor-proto-reserved-name
    (msg :: <enum-descriptor-proto>, new :: <string>) => (new :: <string>)
  let v = msg.enum-descriptor-proto-reserved-name;
  if (~v)
    v := make(<stretchy-vector>);
    msg.enum-descriptor-proto-reserved-name := v;
  end;
  add!(v, new);
  new
end method add-enum-descriptor-proto-reserved-name;

// Range of reserved numeric values. Reserved values may not be used by
// entries in the same enum. Reserved ranges may not overlap.
//
// Note that this is distinct from DescriptorProto.ReservedRange in that it
// is inclusive such that it can appropriately represent the entire int32
// domain.
define class <enum-descriptor-proto-enum-reserved-range> (<protocol-buffer-message>)
  // Inclusive.
  slot enum-descriptor-proto-enum-reserved-range-start :: false-or(<int32>),
    init-value: #f,
    init-keyword: start:;
  // Inclusive.
  slot enum-descriptor-proto-enum-reserved-range-end :: false-or(<int32>),
    init-value: #f,
    init-keyword: end:;
end class <enum-descriptor-proto-enum-reserved-range>;

// Describes a value within an enum.
define class <enum-value-descriptor-proto> (<protocol-buffer-message>)
  slot enum-value-descriptor-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  slot enum-value-descriptor-proto-number :: false-or(<int32>),
    init-value: #f,
    init-keyword: number:;
  slot enum-value-descriptor-proto-options :: false-or(<enum-value-options>),
    init-value: #f,
    init-keyword: options:;
end class <enum-value-descriptor-proto>;

// Describes a service.
define class <service-descriptor-proto> (<protocol-buffer-message>)
  slot service-descriptor-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  slot service-descriptor-proto-method :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: method:;
  slot service-descriptor-proto-options :: false-or(<service-options>),
    init-value: #f,
    init-keyword: options:;
end class <service-descriptor-proto>;

define method add-service-descriptor-proto-method
    (msg :: <service-descriptor-proto>, new :: <method-descriptor-proto>) => (new :: <method-descriptor-proto>)
  let v = msg.service-descriptor-proto-method;
  if (~v)
    v := make(<stretchy-vector>);
    msg.service-descriptor-proto-method := v;
  end;
  add!(v, new);
  new
end method add-service-descriptor-proto-method;

// Describes a method of a service.
define class <method-descriptor-proto> (<protocol-buffer-message>)
  slot method-descriptor-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  // Input and output type names.  These are resolved in the same way as
  // FieldDescriptorProto.type_name, but must refer to a message type.
  slot method-descriptor-proto-input-type :: false-or(<string>),
    init-value: #f,
    init-keyword: input-type:;
  slot method-descriptor-proto-output-type :: false-or(<string>),
    init-value: #f,
    init-keyword: output-type:;
  slot method-descriptor-proto-options :: false-or(<method-options>),
    init-value: #f,
    init-keyword: options:;
  // Identifies if client streams multiple client messages
  slot method-descriptor-proto-client-streaming :: <boolean>,
    init-value: #f,
    init-keyword: client-streaming:;
  // Identifies if server streams multiple server messages
  slot method-descriptor-proto-server-streaming :: <boolean>,
    init-value: #f,
    init-keyword: server-streaming:;
end class <method-descriptor-proto>;

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
define class <file-options> (<protocol-buffer-message>)
  // Sets the Java package where classes generated from this .proto will be
  // placed.  By default, the proto package is used, but this is often
  // inappropriate because proto packages do not normally start with backwards
  // domain names.
  slot file-options-java-package :: false-or(<string>),
    init-value: #f,
    init-keyword: java-package:;
  // Controls the name of the wrapper Java class generated for the .proto file.
  // That class will always contain the .proto file's getDescriptor() method as
  // well as any top-level extensions defined in the .proto file.
  // If java_multiple_files is disabled, then all the other classes from the
  // .proto file will be nested inside the single wrapper outer class.
  slot file-options-java-outer-classname :: false-or(<string>),
    init-value: #f,
    init-keyword: java-outer-classname:;
  // If enabled, then the Java code generator will generate a separate .java
  // file for each top-level message, enum, and service defined in the .proto
  // file.  Thus, these types will *not* be nested inside the wrapper class
  // named by java_outer_classname.  However, the wrapper class will still be
  // generated to contain the file's getDescriptor() method as well as any
  // top-level extensions defined in the file.
  slot file-options-java-multiple-files :: <boolean>,
    init-value: #f,
    init-keyword: java-multiple-files:;
  // This option does nothing.
  slot file-options-java-generate-equals-and-hash :: <boolean>,
    init-value: #f,
    init-keyword: java-generate-equals-and-hash:;
  // If set true, then the Java2 code generator will generate code that
  // throws an exception whenever an attempt is made to assign a non-UTF-8
  // byte sequence to a string field.
  // Message reflection will do the same.
  // However, an extension field still accepts non-UTF-8 byte sequences.
  // This option has no effect on when used with the lite runtime.
  slot file-options-java-string-check-utf8 :: <boolean>,
    init-value: #f,
    init-keyword: java-string-check-utf8:;
  slot file-options-optimize-for :: false-or(<file-options-optimize-mode>),
    init-value: #f,
    init-keyword: optimize-for:;
  // Sets the Go package where structs generated from this .proto will be
  // placed. If omitted, the Go package will be derived from the following:
  //   - The basename of the package import path, if provided.
  //   - Otherwise, the package statement in the .proto file, if present.
  //   - Otherwise, the basename of the .proto file, without extension.
  slot file-options-go-package :: false-or(<string>),
    init-value: #f,
    init-keyword: go-package:;
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
  slot file-options-cc-generic-services :: <boolean>,
    init-value: #f,
    init-keyword: cc-generic-services:;
  slot file-options-java-generic-services :: <boolean>,
    init-value: #f,
    init-keyword: java-generic-services:;
  slot file-options-py-generic-services :: <boolean>,
    init-value: #f,
    init-keyword: py-generic-services:;
  slot file-options-php-generic-services :: <boolean>,
    init-value: #f,
    init-keyword: php-generic-services:;
  // Is this file deprecated?
  // Depending on the target platform, this can emit Deprecated annotations
  // for everything in the file, or it will be completely ignored; in the very
  // least, this is a formalization for deprecating files.
  slot file-options-deprecated :: <boolean>,
    init-value: #f,
    init-keyword: deprecated:;
  // Enables the use of arenas for the proto messages in this file. This applies
  // only to generated classes for C++.
  slot file-options-cc-enable-arenas :: <boolean>,
    init-value: #f,
    init-keyword: cc-enable-arenas:;
  // Sets the objective c class prefix which is prepended to all objective c
  // generated classes from this .proto. There is no default.
  slot file-options-objc-class-prefix :: false-or(<string>),
    init-value: #f,
    init-keyword: objc-class-prefix:;
  // Namespace for generated classes; defaults to the package.
  slot file-options-csharp-namespace :: false-or(<string>),
    init-value: #f,
    init-keyword: csharp-namespace:;
  // By default Swift generators will take the proto package and CamelCase it
  // replacing '.' with underscore and use that to prefix the types/symbols
  // defined. When this options is provided, they will use this value instead
  // to prefix the types/symbols defined.
  slot file-options-swift-prefix :: false-or(<string>),
    init-value: #f,
    init-keyword: swift-prefix:;
  // Sets the php class prefix which is prepended to all php generated classes
  // from this .proto. Default is empty.
  slot file-options-php-class-prefix :: false-or(<string>),
    init-value: #f,
    init-keyword: php-class-prefix:;
  // Use this option to change the namespace of php generated classes. Default
  // is empty. When this option is empty, the package name will be used for
  // determining the namespace.
  slot file-options-php-namespace :: false-or(<string>),
    init-value: #f,
    init-keyword: php-namespace:;
  // Use this option to change the namespace of php generated metadata classes.
  // Default is empty. When this option is empty, the proto file name will be
  // used for determining the namespace.
  slot file-options-php-metadata-namespace :: false-or(<string>),
    init-value: #f,
    init-keyword: php-metadata-namespace:;
  // Use this option to change the package of ruby generated classes. Default
  // is empty. When this option is not set, the package name will be used for
  // determining the ruby package.
  slot file-options-ruby-package :: false-or(<string>),
    init-value: #f,
    init-keyword: ruby-package:;
  // The parser stores options it doesn't recognize here.
  // See the documentation for the "Options" section above.
  slot file-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <file-options>;

define method add-file-options-uninterpreted-option
    (msg :: <file-options>, new :: <uninterpreted-option>) => (new :: <uninterpreted-option>)
  let v = msg.file-options-uninterpreted-option;
  if (~v)
    v := make(<stretchy-vector>);
    msg.file-options-uninterpreted-option := v;
  end;
  add!(v, new);
  new
end method add-file-options-uninterpreted-option;

// Generated classes can be optimized for speed or code size.
define class <file-options-optimize-mode> (<protocol-buffer-enum>) end;

define constant $file-options-optimize-mode-speed :: <file-options-optimize-mode>
  = make(<file-options-optimize-mode>,
         name: "SPEED",
         value: 1);
// Generate complete code for parsing, serialization,
// etc.
define constant $file-options-optimize-mode-code-size :: <file-options-optimize-mode>
  = make(<file-options-optimize-mode>,
         name: "CODE_SIZE",
         value: 2);
// Use ReflectionOps to implement these methods.
define constant $file-options-optimize-mode-lite-runtime :: <file-options-optimize-mode>
  = make(<file-options-optimize-mode>,
         name: "LITE_RUNTIME",
         value: 3);

define class <message-options> (<protocol-buffer-message>)
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
  slot message-options-message-set-wire-format :: <boolean>,
    init-value: #f,
    init-keyword: message-set-wire-format:;
  // Disables the generation of the standard "descriptor()" accessor, which can
  // conflict with a field of the same name.  This is meant to make migration
  // from proto1 easier; new code should avoid fields named "descriptor".
  slot message-options-no-standard-descriptor-accessor :: <boolean>,
    init-value: #f,
    init-keyword: no-standard-descriptor-accessor:;
  // Is this message deprecated?
  // Depending on the target platform, this can emit Deprecated annotations
  // for the message, or it will be completely ignored; in the very least,
  // this is a formalization for deprecating messages.
  slot message-options-deprecated :: <boolean>,
    init-value: #f,
    init-keyword: deprecated:;
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
  slot message-options-map-entry :: <boolean>,
    init-value: #f,
    init-keyword: map-entry:;
  // javanano_as_lite
  // The parser stores options it doesn't recognize here. See above.
  slot message-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <message-options>;

define method add-message-options-uninterpreted-option
    (msg :: <message-options>, new :: <uninterpreted-option>) => (new :: <uninterpreted-option>)
  let v = msg.message-options-uninterpreted-option;
  if (~v)
    v := make(<stretchy-vector>);
    msg.message-options-uninterpreted-option := v;
  end;
  add!(v, new);
  new
end method add-message-options-uninterpreted-option;

define class <field-options> (<protocol-buffer-message>)
  // The ctype option instructs the C++ code generator to use a different
  // representation of the field than it normally would.  See the specific
  // options below.  This option is not yet implemented in the open source
  // release -- sorry, we'll try to include it in a future version!
  slot field-options-ctype :: false-or(<field-options-ctype>),
    init-value: #f,
    init-keyword: ctype:;
  // The packed option can be enabled for repeated primitive fields to enable
  // a more efficient representation on the wire. Rather than repeatedly
  // writing the tag and type for each element, the entire array is encoded as
  // a single length-delimited blob. In proto3, only explicit setting it to
  // false will avoid using packed encoding.
  slot field-options-packed :: <boolean>,
    init-value: #f,
    init-keyword: packed:;
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
  slot field-options-jstype :: false-or(<field-options-js-type>),
    init-value: #f,
    init-keyword: jstype:;
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
  //
  // As of May 2022, lazy verifies the contents of the byte stream during
  // parsing.  An invalid byte stream will cause the overall parsing to fail.
  slot field-options-lazy :: <boolean>,
    init-value: #f,
    init-keyword: lazy:;
  // unverified_lazy does no correctness checks on the byte stream. This should
  // only be used where lazy with verification is prohibitive for performance
  // reasons.
  slot field-options-unverified-lazy :: <boolean>,
    init-value: #f,
    init-keyword: unverified-lazy:;
  // Is this field deprecated?
  // Depending on the target platform, this can emit Deprecated annotations
  // for accessors, or it will be completely ignored; in the very least, this
  // is a formalization for deprecating fields.
  slot field-options-deprecated :: <boolean>,
    init-value: #f,
    init-keyword: deprecated:;
  // For Google-internal migration only. Do not use.
  slot field-options-weak :: <boolean>,
    init-value: #f,
    init-keyword: weak:;
  // The parser stores options it doesn't recognize here. See above.
  slot field-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <field-options>;

define method add-field-options-uninterpreted-option
    (msg :: <field-options>, new :: <uninterpreted-option>) => (new :: <uninterpreted-option>)
  let v = msg.field-options-uninterpreted-option;
  if (~v)
    v := make(<stretchy-vector>);
    msg.field-options-uninterpreted-option := v;
  end;
  add!(v, new);
  new
end method add-field-options-uninterpreted-option;

define class <field-options-ctype> (<protocol-buffer-enum>) end;

// Default mode.
define constant $field-options-ctype-string :: <field-options-ctype>
  = make(<field-options-ctype>,
         name: "STRING",
         value: 0);
define constant $field-options-ctype-cord :: <field-options-ctype>
  = make(<field-options-ctype>,
         name: "CORD",
         value: 1);
define constant $field-options-ctype-string-piece :: <field-options-ctype>
  = make(<field-options-ctype>,
         name: "STRING_PIECE",
         value: 2);

define class <field-options-js-type> (<protocol-buffer-enum>) end;

// Use the default type.
define constant $field-options-js-type-js-normal :: <field-options-js-type>
  = make(<field-options-js-type>,
         name: "JS_NORMAL",
         value: 0);
// Use JavaScript strings.
define constant $field-options-js-type-js-string :: <field-options-js-type>
  = make(<field-options-js-type>,
         name: "JS_STRING",
         value: 1);
// Use JavaScript numbers.
define constant $field-options-js-type-js-number :: <field-options-js-type>
  = make(<field-options-js-type>,
         name: "JS_NUMBER",
         value: 2);

define class <oneof-options> (<protocol-buffer-message>)
  // The parser stores options it doesn't recognize here. See above.
  slot oneof-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <oneof-options>;

define method add-oneof-options-uninterpreted-option
    (msg :: <oneof-options>, new :: <uninterpreted-option>) => (new :: <uninterpreted-option>)
  let v = msg.oneof-options-uninterpreted-option;
  if (~v)
    v := make(<stretchy-vector>);
    msg.oneof-options-uninterpreted-option := v;
  end;
  add!(v, new);
  new
end method add-oneof-options-uninterpreted-option;

define class <enum-options> (<protocol-buffer-message>)
  // Set this option to true to allow mapping different tag names to the same
  // value.
  slot enum-options-allow-alias :: <boolean>,
    init-value: #f,
    init-keyword: allow-alias:;
  // Is this enum deprecated?
  // Depending on the target platform, this can emit Deprecated annotations
  // for the enum, or it will be completely ignored; in the very least, this
  // is a formalization for deprecating enums.
  slot enum-options-deprecated :: <boolean>,
    init-value: #f,
    init-keyword: deprecated:;
  // javanano_as_lite
  // The parser stores options it doesn't recognize here. See above.
  slot enum-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <enum-options>;

define method add-enum-options-uninterpreted-option
    (msg :: <enum-options>, new :: <uninterpreted-option>) => (new :: <uninterpreted-option>)
  let v = msg.enum-options-uninterpreted-option;
  if (~v)
    v := make(<stretchy-vector>);
    msg.enum-options-uninterpreted-option := v;
  end;
  add!(v, new);
  new
end method add-enum-options-uninterpreted-option;

define class <enum-value-options> (<protocol-buffer-message>)
  // Is this enum value deprecated?
  // Depending on the target platform, this can emit Deprecated annotations
  // for the enum value, or it will be completely ignored; in the very least,
  // this is a formalization for deprecating enum values.
  slot enum-value-options-deprecated :: <boolean>,
    init-value: #f,
    init-keyword: deprecated:;
  // The parser stores options it doesn't recognize here. See above.
  slot enum-value-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <enum-value-options>;

define method add-enum-value-options-uninterpreted-option
    (msg :: <enum-value-options>, new :: <uninterpreted-option>) => (new :: <uninterpreted-option>)
  let v = msg.enum-value-options-uninterpreted-option;
  if (~v)
    v := make(<stretchy-vector>);
    msg.enum-value-options-uninterpreted-option := v;
  end;
  add!(v, new);
  new
end method add-enum-value-options-uninterpreted-option;

define class <service-options> (<protocol-buffer-message>)
  // Note:  Field numbers 1 through 32 are reserved for Google's internal RPC
  //   framework.  We apologize for hoarding these numbers to ourselves, but
  //   we were already using them long before we decided to release Protocol
  //   Buffers.
  // Is this service deprecated?
  // Depending on the target platform, this can emit Deprecated annotations
  // for the service, or it will be completely ignored; in the very least,
  // this is a formalization for deprecating services.
  slot service-options-deprecated :: <boolean>,
    init-value: #f,
    init-keyword: deprecated:;
  // The parser stores options it doesn't recognize here. See above.
  slot service-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <service-options>;

define method add-service-options-uninterpreted-option
    (msg :: <service-options>, new :: <uninterpreted-option>) => (new :: <uninterpreted-option>)
  let v = msg.service-options-uninterpreted-option;
  if (~v)
    v := make(<stretchy-vector>);
    msg.service-options-uninterpreted-option := v;
  end;
  add!(v, new);
  new
end method add-service-options-uninterpreted-option;

define class <method-options> (<protocol-buffer-message>)
  // Note:  Field numbers 1 through 32 are reserved for Google's internal RPC
  //   framework.  We apologize for hoarding these numbers to ourselves, but
  //   we were already using them long before we decided to release Protocol
  //   Buffers.
  // Is this method deprecated?
  // Depending on the target platform, this can emit Deprecated annotations
  // for the method, or it will be completely ignored; in the very least,
  // this is a formalization for deprecating methods.
  slot method-options-deprecated :: <boolean>,
    init-value: #f,
    init-keyword: deprecated:;
  slot method-options-idempotency-level :: false-or(<method-options-idempotency-level>),
    init-value: #f,
    init-keyword: idempotency-level:;
  // The parser stores options it doesn't recognize here. See above.
  slot method-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <method-options>;

define method add-method-options-uninterpreted-option
    (msg :: <method-options>, new :: <uninterpreted-option>) => (new :: <uninterpreted-option>)
  let v = msg.method-options-uninterpreted-option;
  if (~v)
    v := make(<stretchy-vector>);
    msg.method-options-uninterpreted-option := v;
  end;
  add!(v, new);
  new
end method add-method-options-uninterpreted-option;

// Is this method side-effect-free (or safe in HTTP parlance), or idempotent,
// or neither? HTTP based RPC implementation may choose GET verb for safe
// methods, and PUT verb for idempotent methods instead of the default POST.
define class <method-options-idempotency-level> (<protocol-buffer-enum>) end;

define constant $method-options-idempotency-level-idempotency-unknown :: <method-options-idempotency-level>
  = make(<method-options-idempotency-level>,
         name: "IDEMPOTENCY_UNKNOWN",
         value: 0);
define constant $method-options-idempotency-level-no-side-effects :: <method-options-idempotency-level>
  = make(<method-options-idempotency-level>,
         name: "NO_SIDE_EFFECTS",
         value: 1);
// implies idempotent
define constant $method-options-idempotency-level-idempotent :: <method-options-idempotency-level>
  = make(<method-options-idempotency-level>,
         name: "IDEMPOTENT",
         value: 2);

// A message representing a option the parser does not recognize. This only
// appears in options protos created by the compiler::Parser class.
// DescriptorPool resolves these when building Descriptor objects. Therefore,
// options protos in descriptor objects (e.g. returned by Descriptor::options(),
// or produced by Descriptor::CopyTo()) will never have UninterpretedOptions
// in them.
define class <uninterpreted-option> (<protocol-buffer-message>)
  slot uninterpreted-option-name :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: name:;
  // The value of the uninterpreted option, in whatever type the tokenizer
  // identified it as during parsing. Exactly one of these should be set.
  slot uninterpreted-option-identifier-value :: false-or(<string>),
    init-value: #f,
    init-keyword: identifier-value:;
  slot uninterpreted-option-positive-int-value :: false-or(<uint64>),
    init-value: #f,
    init-keyword: positive-int-value:;
  slot uninterpreted-option-negative-int-value :: false-or(<int64>),
    init-value: #f,
    init-keyword: negative-int-value:;
  slot uninterpreted-option-double-value :: false-or(<double-float>),
    init-value: #f,
    init-keyword: double-value:;
  slot uninterpreted-option-string-value :: false-or(<byte-vector>),
    init-value: #f,
    init-keyword: string-value:;
  slot uninterpreted-option-aggregate-value :: false-or(<string>),
    init-value: #f,
    init-keyword: aggregate-value:;
end class <uninterpreted-option>;

define method add-uninterpreted-option-name
    (msg :: <uninterpreted-option>, new :: <uninterpreted-option-name-part>) => (new :: <uninterpreted-option-name-part>)
  let v = msg.uninterpreted-option-name;
  if (~v)
    v := make(<stretchy-vector>);
    msg.uninterpreted-option-name := v;
  end;
  add!(v, new);
  new
end method add-uninterpreted-option-name;

// The name of the uninterpreted option.  Each string represents a segment in
// a dot-separated name.  is_extension is true iff a segment represents an
// extension (denoted with parentheses in options specs in .proto files).
// E.g.,{ ["foo", false], ["bar.baz", true], ["moo", false] } represents
// "foo.(bar.baz).moo".
define class <uninterpreted-option-name-part> (<protocol-buffer-message>)
  slot uninterpreted-option-name-part-name-part :: false-or(<string>),
    init-value: #f,
    init-keyword: name-part:;
  slot uninterpreted-option-name-part-is-extension :: <boolean>,
    init-value: #f,
    init-keyword: is-extension:;
end class <uninterpreted-option-name-part>;

// ===================================================================
// Optional source code info
// Encapsulates information about the original source file from which a
// FileDescriptorProto was generated.
define class <source-code-info> (<protocol-buffer-message>)
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
  slot source-code-info-location :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: location:;
end class <source-code-info>;

define method add-source-code-info-location
    (msg :: <source-code-info>, new :: <source-code-info-location>) => (new :: <source-code-info-location>)
  let v = msg.source-code-info-location;
  if (~v)
    v := make(<stretchy-vector>);
    msg.source-code-info-location := v;
  end;
  add!(v, new);
  new
end method add-source-code-info-location;

define class <source-code-info-location> (<protocol-buffer-message>)
  // Identifies which part of the FileDescriptorProto was defined at this
  // location.
  //
  // Each element is a field number or an index.  They form a path from
  // the root FileDescriptorProto to the place where the definition occurs.
  // For example, this path:
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
  slot source-code-info-location-path :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: path:;
  // Always has exactly three or four elements: start line, start column,
  // end line (optional, otherwise assumed same as start line), end column.
  // These are packed into a single field for efficiency.  Note that line
  // and column numbers are zero-based -- typically you will want to add
  // 1 to each before displaying to a user.
  slot source-code-info-location-span :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: span:;
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
  //   // Comment attached to moo.
  //   //
  //   // Another line attached to moo.
  //   optional double moo = 4;
  //
  //   // Detached comment for corge. This is not leading or trailing comments
  //   // to moo or corge because there are blank lines separating it from
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
  slot source-code-info-location-leading-comments :: false-or(<string>),
    init-value: #f,
    init-keyword: leading-comments:;
  slot source-code-info-location-trailing-comments :: false-or(<string>),
    init-value: #f,
    init-keyword: trailing-comments:;
  slot source-code-info-location-leading-detached-comments :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: leading-detached-comments:;
end class <source-code-info-location>;

define method add-source-code-info-location-path
    (msg :: <source-code-info-location>, new :: <int32>) => (new :: <int32>)
  let v = msg.source-code-info-location-path;
  if (~v)
    v := make(<stretchy-vector>);
    msg.source-code-info-location-path := v;
  end;
  add!(v, new);
  new
end method add-source-code-info-location-path;

define method add-source-code-info-location-span
    (msg :: <source-code-info-location>, new :: <int32>) => (new :: <int32>)
  let v = msg.source-code-info-location-span;
  if (~v)
    v := make(<stretchy-vector>);
    msg.source-code-info-location-span := v;
  end;
  add!(v, new);
  new
end method add-source-code-info-location-span;

define method add-source-code-info-location-leading-detached-comments
    (msg :: <source-code-info-location>, new :: <string>) => (new :: <string>)
  let v = msg.source-code-info-location-leading-detached-comments;
  if (~v)
    v := make(<stretchy-vector>);
    msg.source-code-info-location-leading-detached-comments := v;
  end;
  add!(v, new);
  new
end method add-source-code-info-location-leading-detached-comments;

// Describes the relationship between generated code and its original source
// file. A GeneratedCodeInfo message is associated with only one generated
// source file, but may contain references to different source .proto files.
define class <generated-code-info> (<protocol-buffer-message>)
  // An Annotation connects some span of text in generated code to an element
  // of its generating .proto file.
  slot generated-code-info-annotation :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: annotation:;
end class <generated-code-info>;

define method add-generated-code-info-annotation
    (msg :: <generated-code-info>, new :: <generated-code-info-annotation>) => (new :: <generated-code-info-annotation>)
  let v = msg.generated-code-info-annotation;
  if (~v)
    v := make(<stretchy-vector>);
    msg.generated-code-info-annotation := v;
  end;
  add!(v, new);
  new
end method add-generated-code-info-annotation;

define class <generated-code-info-annotation> (<protocol-buffer-message>)
  // Identifies the element in the original source .proto file. This field
  // is formatted the same as SourceCodeInfo.Location.path.
  slot generated-code-info-annotation-path :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: path:;
  // Identifies the filesystem path to the original source .proto.
  slot generated-code-info-annotation-source-file :: false-or(<string>),
    init-value: #f,
    init-keyword: source-file:;
  // Identifies the starting offset in bytes in the generated code
  // that relates to the identified object.
  slot generated-code-info-annotation-begin :: false-or(<int32>),
    init-value: #f,
    init-keyword: begin:;
  // Identifies the ending offset in bytes in the generated code that
  // relates to the identified object. The end offset should be one past
  // the last relevant byte (so the length of the text = end - begin).
  slot generated-code-info-annotation-end :: false-or(<int32>),
    init-value: #f,
    init-keyword: end:;
  slot generated-code-info-annotation-semantic :: false-or(<generated-code-info-annotation-semantic>),
    init-value: #f,
    init-keyword: semantic:;
end class <generated-code-info-annotation>;

define method add-generated-code-info-annotation-path
    (msg :: <generated-code-info-annotation>, new :: <int32>) => (new :: <int32>)
  let v = msg.generated-code-info-annotation-path;
  if (~v)
    v := make(<stretchy-vector>);
    msg.generated-code-info-annotation-path := v;
  end;
  add!(v, new);
  new
end method add-generated-code-info-annotation-path;

// Represents the identified object's effect on the element in the original
// .proto file.
define class <generated-code-info-annotation-semantic> (<protocol-buffer-enum>) end;

// There is no effect or the effect is indescribable.
define constant $generated-code-info-annotation-semantic-none :: <generated-code-info-annotation-semantic>
  = make(<generated-code-info-annotation-semantic>,
         name: "NONE",
         value: 0);
// The element is set or otherwise mutated.
define constant $generated-code-info-annotation-semantic-set :: <generated-code-info-annotation-semantic>
  = make(<generated-code-info-annotation-semantic>,
         name: "SET",
         value: 1);
// An alias to the element is returned.
define constant $generated-code-info-annotation-semantic-alias :: <generated-code-info-annotation-semantic>
  = make(<generated-code-info-annotation-semantic>,
         name: "ALIAS",
         value: 2);


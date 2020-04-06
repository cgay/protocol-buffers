Module: dylan-user

define library protocol-buffers
  use binary-data;
  use uncommon-dylan;

  export
    protocol-buffers,
    protocol-buffers-implementation;
end library;

define module protocol-buffers
/*
  create
    <int32>,
    <int64>,
    <uint32>,
    <uint64>,
    <sint32>,
    <sint64>,
    <fixed32>,
    <fixed64>,
    <sfixed32>,
    <sfixed64>;

  create
    <message>,
    <error>,
    initialized?,
    clear,
    byte-size,
    serialize,
    merge-from;

  // Macros that need to be exported to compile the generated code.
  create
    define-message,
    define-enum,
    define-extend,
    define-group,
    define-service;
*/
end module;

define module protocol-buffers-implementation
  use protocol-buffers;

  use binary-data;
  use uncommon-dylan;

  export
    <varint-frame>,
    varint-bytes;
end module;

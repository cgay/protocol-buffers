Module: dylan-user
Synopsis: Core definitions needed by google.protobuf generated code.


// Names that should be re-exported from the protocol-buffers module.
define module protocol-buffers-base-public
  create
    <protocol-buffer-object>,
    <protocol-buffer-enum>,
    <protocol-buffer-message>,
    <int32>, <uint32>, <int64>, <uint64>,
    // TODO: remove this after moving descriptor-name methods out of
    // google-protobuf module
    enum-value-name;
end module;

// Names that should not be reexported from the protocol-buffers module.
define module protocol-buffers-base-private
  create
    $max-field-number,
    store;
end module;

define module protocol-buffers-codegen-support
  use protocol-buffers-base-public, export: all;
  use protocol-buffers-base-private, export: all;
end module;

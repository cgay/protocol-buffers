Module: dylan-user
Synopsis: The public interface to protocol buffers


define module protocol-buffers
  create
    $max-field-number,

    <protocol-buffer-error>,
    <protocol-buffer-object>,
      <protocol-buffer-message>,

    descriptor-name,
    find-descriptor,

    <protocol-buffer-enum>,
    enum-name-to-enum,
    enum-name-to-value,
    enum-value,
    enum-value-name,
    enum-value-to-enum,
    enum-value-to-name,

    // Types
    <int32>, <uint32>, <int64>, <uint64>,

    // Code generator
    <generator>,
    generate-dylan-code,

    // For use by generated code. (TODO: define separate module for these.)
    set-introspection-data,

    // Introspection API
    introspect;
end module;

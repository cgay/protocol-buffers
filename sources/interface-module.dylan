Module: dylan-user
Synopsis: The public interface to protocol buffers


define module protocol-buffers
  use protocol-buffers-base-public, export: all;
  use google-protobuf, export: all;

  create
    <protocol-buffer-error>,

    descriptor-name,
    find-descriptor,

    enum-name-to-enum,
    enum-name-to-value,
    enum-value,
    // TODO: currently exported from protocol-buffers-codegen-support but
    // should be exported here instead, after moving descriptor-name methods
    // out of the google-protobuf module.
    //enum-value-name,
    enum-value-to-enum,
    enum-value-to-name,

    // Code generator
    <generator>,
    generate-dylan-code,

    // Introspection API
    introspect,
    <introspection-data>,
    <field-introspection-data>,
    introspection-full-name,
    introspection-descriptor,
    introspection-class,
    introspection-getter,
    introspection-setter,
    introspection-adder;
end module;

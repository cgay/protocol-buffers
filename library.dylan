Module: dylan-user

define library protocol-buffers
  // Libraries shared with test code. Should be kept in sync with
  // protocol-buffers-test library definition in library-test.dylan.
  use io,
    import: { format };
  use uncommon-dylan,
    import: { uncommon-dylan, uncommon-utils };

  export
    protocol-buffers;
end library;

// Interface
define module protocol-buffers
  // Generated code subclasses these types.
  create
    <protocol-buffer>,
    <message>,
    <enum>,
    <group>,
    <file>;
end module;

define module protocol-buffers-internal
  use protocol-buffers;

  use format,
    import: { format-to-string };
  // Modules shared with test code. Should be kept in sync with
  // protocol-buffers-internal from library-test.dylan.
//  use streams;                  // for <buffer> and buffer-* functions
  use uncommon-dylan;
  use uncommon-utils;
end module;

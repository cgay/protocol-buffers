Module: dylan-user

define library protocol-buffers-test
  use testworks;

  // Libraries share with main pb code. Should be kept in sync with
  // protocol-buffers library definition.
//  use io,
//    import: { streams };
  use uncommon-dylan,
    import: { uncommon-dylan, uncommon-utils };

  export protocol-buffers-internal;
end library;

define module protocol-buffers-internal
  use testworks;

  // Modules shared with main pb code. Should be kept in sync with
  // protocol-buffers-internal module in library.dylan.
//  use streams;                  // for <buffer> and buffer-* functions
  use uncommon-dylan;
  use uncommon-utils;

  // The export list has to be kept in sync with the `create` clauses in
  // library.dylan. :-( Still seems like a win over exporting everything
  // we want to test from protocol-buffers-internal.
  export
    <protobuf>;
end module;

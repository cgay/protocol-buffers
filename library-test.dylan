Module: dylan-user

// NOTE: This test library uses a different build strategy than normal.  The
// test code is compiled in the protocol-buffers-internal module, instead of
// using a different module and exporting all the names we want to test from
// that module.
//
// This has the drawback that the test module definitions must be kept up to
// date with the protocol-buffers-internal module and the LID files also
// overlap.  Hopefully this will be an overall win, because library imports
// should stabilize quickly vs maintaining exports for testing, and in the long
// run we can make this the standard and figure out a way to avoid the
// duplication.

define library protocol-buffers-test
  // Libraries only imported for the tests.
  use testworks;

  // ----------------------------------------------------------
  // Everything below here should be copied from library.dylan.
  // ----------------------------------------------------------

  // Libraries shared with test code. Should be kept in sync with
  // protocol-buffers-test library definition in library-test.dylan.
  use io,
    import: { format };
  use uncommon-dylan,
    import: { uncommon-dylan, uncommon-utils };

  export
    protocol-buffers;
end library;

// ----------------------------------------------------------------
// This entire module should be copied verbatim from library.dylan.
// ----------------------------------------------------------------

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
  // Modules imported only for the tests.
  use testworks;

  // ----------------------------------------------------------
  // Everything below here should be copied from library.dylan.
  // ----------------------------------------------------------
  use protocol-buffers;

  use format,
    import: { format-to-string };
  // Modules shared with test code. Should be kept in sync with
  // protocol-buffers-internal from library-test.dylan.
//  use streams;                  // for <buffer> and buffer-* functions
  use uncommon-dylan;
  use uncommon-utils;
end module;

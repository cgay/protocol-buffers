Module: dylan-user

define library protocol-buffers-test-suite
  // Libraries from Open Dylan
  use big-integers;
  use common-dylan, import: { threads };
  use generic-arithmetic;
  use io;
  use system;

  // Libraries from package dependencies
  use protocol-buffers;
  use strings;
  use testworks;
  use uncommon-dylan;
end library;

define module protocol-buffers-test-suite
  // Our own modules.
  use google-protobuf;          // generated from descriptor.proto
  use protocol-buffers;
  use protocol-buffers-impl;

  // Modules from Open Dylan
  use file-system;
  use format,
    rename: { format-to-string => sformat }; // for brevity
  use format-out;
  use generic-arithmetic,
    prefix: "big-",
    rename: { $maximum-integer => $maximum-big-int,
              $minimum-integer => $minimum-big-int,
              <integer> => <big-int> };
  use locators;
  use print;
  use standard-io;
  use streams;
  use threads;

  // Modules from package dependencies
  use strings;
  use testworks;
  use uncommon-dylan;
end module;

Module: dylan-user

define library protocol-buffers-test-suite
  // Libraries from Open Dylan
  use big-integers;
  use generic-arithmetic;
  use io;

  // Libraries from packages
  use protocol-buffers;
  use strings;
  use testworks;
  use uncommon-dylan;
end library;

define module protocol-buffers-test-suite
  // Modules from Open Dylan
  use format,
    rename: { format-to-string => sformat }; // for brevity
  use format-out;
  use generic-arithmetic,
    prefix: "big-",
    rename: { $maximum-integer => $maximum-big-int,
              $minimum-integer => $minimum-big-int,
              <integer> => <big-int> };
  use streams;

  // Modules from packages
  use google-protobuf;          // generated from descriptor.proto
  use protocol-buffers-impl;
  use strings;
  use testworks;
  use uncommon-dylan;
end module;

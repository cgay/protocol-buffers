Module: dylan-user

define library protocol-buffers-test-suite
  use big-integers;
  use generic-arithmetic;
  use io;
  use protocol-buffers;
  use testworks;
  use uncommon-dylan;
end library;

define module protocol-buffers-test-suite
  use format,
    rename: { format-to-string => sformat }; // for brevity
  use generic-arithmetic,
    prefix: "big-",
    rename: { $maximum-integer => $maximum-big-int,
              $minimum-integer => $minimum-big-int,
              <integer> => <big-int> };
  use protocol-buffers-impl;
  use streams;
  use testworks;
  use uncommon-dylan;
end module;

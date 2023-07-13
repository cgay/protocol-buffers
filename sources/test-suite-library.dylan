Module: dylan-user

define library protocol-buffers-test-suite
  use big-integers;
  use generic-arithmetic;
  use io,
    import: { format };
  use protocol-buffers;
  use testworks;
  use uncommon-dylan;
end library;

define module protocol-buffers-test-suite
  use format,
    rename: { format-to-string => sformat }; // for brevity
  use generic-arithmetic,
    prefix: "ga/";
  use protocol-buffers-impl;
  use testworks;
  use uncommon-dylan;
end module;

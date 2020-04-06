Module: dylan-user

define library protocol-buffers-test-suite
  use uncommon-dylan;
  use io,
    import: { format };
  use protocol-buffers;
  use testworks;
end library;

define module protocol-buffers-test-suite
  use format,
    rename: { format-to-string => sformat }; // for brevity
  use protocol-buffers-impl;
  use testworks;
  use uncommon-dylan;
end module;

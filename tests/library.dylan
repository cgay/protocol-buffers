Module: dylan-user

define library protocol-buffers-test
  use binary-data;
  use protocol-buffers;
  use testworks;
  use uncommon-dylan;
end;

define module protocol-buffers-test
  use binary-data;
  use protocol-buffers-implementation;
  use testworks;
  use uncommon-dylan;
end;

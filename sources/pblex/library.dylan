Module: dylan-user

define library pblex
  use common-dylan;
  use io, import: { format-out, streams };
  use system, import: { file-system };
  use protocol-buffers;
end library;

define module pblex
  use common-dylan;
  use file-system;
  use format-out;
  use protocol-buffers-impl;
  use streams;
end module;

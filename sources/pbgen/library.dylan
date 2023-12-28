Module: dylan-user
Synopsis: Generate Dylan code from a .proto file

define library pbgen
  use command-line-parser;
  use common-dylan, exclude: { simple-format };
  use io, import: { format-out, streams };
  use protocol-buffers;
  use system;
end library;

define module pbgen
  use command-line-parser;
  use common-dylan;
  use file-system;
  use format-out;
  use google-protobuf;
  use locators;
  use protocol-buffers;
  use streams;
end module;

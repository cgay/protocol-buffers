Module: dylan-user
Synopsis: Generate Dylan code from a .proto file

define library pbgen
  use command-line-parser;
  use common-dylan;
  use io;
  use protocol-buffers;
  use system;
  use uncommon-dylan;
end library;

define module pbgen
  use command-line-parser;
  use file-system;
  use format-out;
  use google-protobuf;
  use locators;
  use protocol-buffers-impl;
  use streams;
  use uncommon-dylan;
end module;

Module: dylan-user

define library protocol-buffers
  use big-integers;             // side-effect only
  use collections,
    import: { bit-vector };
  use common-dylan;
  use generic-arithmetic;
  use io;
  use strings;
  use system,
    import: { file-system, locators, threads };
  use uncommon-dylan,
    import: { byte-vector,
              machine-words,
              uncommon-dylan,
              uncommon-utils };

  export
    protocol-buffers,
    protocol-buffers-impl,
    google-protobuf;            // descriptor.proto generated code
end library;

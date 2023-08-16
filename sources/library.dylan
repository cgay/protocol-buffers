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
    import: { file-system, locators };
  use uncommon-dylan,
    import: { byte-vector,
              machine-words,
              uncommon-dylan,
              uncommon-utils };

  export
    google-protobuf,
    protocol-buffers,
    protocol-buffers-impl;
end library;

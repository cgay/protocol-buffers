Module: dylan-user

define library protocol-buffers
  use collections,
    import: { bit-vector };
  use io,
    import: { format };
  use uncommon-dylan,
    import: { byte-vector,
              uncommon-dylan,
              uncommon-utils };

  export
    protocol-buffers,
    protocol-buffers-impl;
end library;

// Interface module
define module protocol-buffers
  // These types are subclassed by generated code.
  create
    <protocol-buffer-object>,
      <protocol-buffer-message>,
      <protocol-buffer-enum>;
end module;

// Implementation module
define module protocol-buffers-impl
  use protocol-buffers;

  use bit-vector;
  use byte-vector,
    import: { <byte>, <byte-vector> };
  use format,
    rename: { format-to-string => sformat }; // for brevity
  use uncommon-dylan;
  use uncommon-utils;

  // For the test suite
  export
    $max-int32,
    $wire-type-32-bit,
    $wire-type-64-bit,
    $wire-type-length-delimited,
    $wire-type-varint,
    <buffer>,
    decode-uint32,
    decode-varint,
    encode-uint32,
    encode-varint,
    make-wire-tag,
    zigzag-encode-32,
    zigzag-encode-64;
end module;

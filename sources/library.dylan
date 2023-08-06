Module: dylan-user

define library protocol-buffers
  use big-integers;             // side-effect only
  use collections,
    import: { bit-vector };
  use generic-arithmetic;
  use io,
    import: { format, format-out, streams };
  use strings;
  use uncommon-dylan,
    import: { byte-vector,
              machine-words,
              uncommon-dylan,
              uncommon-utils };

  export
    protocol-buffers,
    protocol-buffers-impl;
end library;

// Interface module
define module protocol-buffers
  create
    <protocol-buffer-error>,
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
  use format-out;
  use generic-arithmetic,
    prefix: "big-",
    rename: { $maximum-integer => $maximum-big-int,
              $minimum-integer => $minimum-big-int,
              <integer> => <big-int> };
  use machine-words,
    import: { $machine-word-size };
  use streams;
  use strings;
  use uncommon-dylan;
  use uncommon-utils;

  export
    $max-int32,
    $max-int64,
    $max-uint32,
    $max-uint64,
    $min-int32,
    $min-int64,
    $wire-type-i32,
    $wire-type-i64,
    $wire-type-len,
    $wire-type-sgroup,
    $wire-type-egroup,
    $wire-type-varint,
    decode-int32,
    decode-uint32,
    decode-varint,
    encode-int32,
    encode-uint32,
    encode-varint,
    make-wire-tag,
    zigzag-encode-32,
    zigzag-encode-64,

    <lexer>,
    <lexer-error>,
    <token>,
    token-text,
    token-value,
    next-token,

    camel-to-kebob;
end module;

// Interface Definition Language (IDL) -- .proto file parser
define module idl
  use streams;
  use strings;
  use uncommon-dylan;
  use uncommon-utils;

  export
end module;

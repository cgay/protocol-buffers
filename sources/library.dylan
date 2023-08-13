Module: dylan-user

define library protocol-buffers
  use big-integers;             // side-effect only
  use collections,
    import: { bit-vector };
  use generic-arithmetic;
  use io,
    import: { format, format-out, print, streams };
  use strings;
  use system,
    import: { file-system, locators };
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
  use file-system;
  use format,
    rename: { format-to-string => sformat }; // for brevity
  use format-out;
  use generic-arithmetic,
    prefix: "big-",
    rename: { $maximum-integer => $maximum-big-int,
              $minimum-integer => $minimum-big-int,
              <integer> => <big-int> };
  use locators;
  use machine-words,
    import: { $machine-word-size };
  use print;                    // print[ing]-object
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

    // Lexer
    <lexer>,
    <lexer-error>,
    <token>,
    <punctuation-token>,
    <reserved-word-token>,
    <identifier-token>,
    <number-token>,
    <string-token>,
    <boolean-token>,
    <comment-token>,
    <whitespace-token>,
    token-text,
    token-value,
    read-token,

    // Parser
    <parser>,
    parse-file-stream,

    // descriptor.pb.dylan
    <file-descriptor-proto>,

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

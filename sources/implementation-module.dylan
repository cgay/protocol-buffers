Module: dylan-user

// This module is defined in a separate file so that it can depend on the
// google-protobuf module that is part of the generated code. That is, the
// google-protobuf module definition must be in a separate (generated) file and
// must precede this file in the LID.

define module protocol-buffers-impl
  use protocol-buffers;
  use google-protobuf;

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
  use standard-io;
  use streams;
  use strings;
  use threads,
    import: { dynamic-bind };
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

    // Lexer (probably don't need most of these)
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
    token-column,
    token-line,
    token-text,
    token-value,
    read-token,

    // Parser API
    <parser>,
    parse-file-stream,

    // Code generator API
    <generator>,
    generate-dylan-code,

    // Utilities
    camel-to-kebob,
    debug,

    // For testing only
    dylan-name,
    dylan-class-name,
    parse-option-name,
    token-comments;
end module;

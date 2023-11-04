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
  use date;
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

    // api.dylan
    $descriptors,               // needs clearing between tests

    // Lexer (probably don't need most of these)
    <boolean-token>,
    <comment-token>,
    <identifier-token>,
    <lexer-error>,
    <lexer>,
    <number-token>,
    <punctuation-token>,
    <reserved-word-token>,
    <string-token>,
    <token>,
    <whitespace-token>,
    read-token,
    token-column,
    token-line,
    token-text,
    token-value,

    // Parser
    $syntax-proto2,
    $syntax-proto3,
    <parse-error>,
    <parser>,
    attached-comments,
    consume-token,
    parse-field-options,
    parse-file-stream,
    parse-message,
    parse-uninterpreted-option-name,

    // Code generator
    <generator>,
    generate-dylan-code,
    parse-file,

    // Utilities
    camel-to-kebob,
    debug,
    dylan-class-name,
    dylan-name,
    parse-uninterpreted-option-name,
    token-comments;
end module;

Module: protocol-buffers-internal

// TODO(cgay): in general I'm not worrying about large 64-bit ints that don't
// fit in a Dylan <int> for now.  We'll need to handle it eventually, via
// either <double-integer> or <machine-word>. I don't know the best method.

// Relatedly, what should the 32-bit functions like zigzag-encode-32 do with
// inputs that are > 32-bit?  Truncate?  Error?  cl-protobufs truncates.

// https://developers.google.com/protocol-buffers/docs/encoding#structure
define constant $wire-type-varint :: <int> = 0;
define constant $wire-type-64-bit :: <int> = 1;
define constant $wire-type-length-delimited :: <int> = 2;
define constant $wire-type-start-group :: <int> = 3;
define constant $wire-type-end-group :: <int> = 4;
define constant $wire-type-32-bit :: <int> = 5;

// Make a field tag that precedes the field data itself. The tag is the
// combination of a wire type (3 bits) and a field number (29 bits).
define inline function make-wire-tag
    (field-number :: <int>, wire-type :: <int>) => (tag :: <int>)
  logior(ash<<(field-number, 3), wire-type)
end;

// Make a field tag to precede the field data itself, given the scalar type of
// the field data.
define function make-tag
    (field-number :: <int>, type :: <scalar>) => (tag :: <int>)
  let wire-type
    = select (type)
        $bool,
        $int32, $sint32, $uint32,
        $int64, $sint64, $uint64
          => $wire-type-varint;
        $fixed32,
        $float,
        $sfixed32
          => $wire-type-32-bit;
        $double,
        $fixed64,
        $sfixed64
          => $wire-type-64-bit;
        $bytes,
        $string
          => $wire-type-length-delimited;
      end;
  make-wire-tag(field-number, wire-type)
end function;

// Can `type` be used in a packed field?
define inline function packed-type?
    (type :: <scalar>) => (_ :: <bool>)
  type == $string | type == $bytes
end function;

// TODO
define constant <buffer> = <vector>;

// Decode a varint from `buf` starting at byte index `start`.
define function decode-varint
    (buf :: <buffer>, start :: <int>) => (i :: <int>, index :: <int>)
  let varint :: <int> = 0;
  let shift :: <int> = 0;
  let index :: <int> = start;
  let high-bit-set? = #t;
  for (i from 0 below 10,       // max 10 7-bit bytes on 64-bit.
       while: high-bit-set?)
    let byte :: <int> = buf[index];
    high-bit-set? := logbit?(7, byte);
    inc!(index);
    varint := logior(varint,
                     logand(ash<<(logand(byte, 127), shift),
                            $maximum-integer));
    inc!(shift, 7);
  end;
  values(varint, index)
end function;

// https://developers.google.com/protocol-buffers/docs/encoding
define inline function zigzag-encode-32
    (n :: <int32>) => (_ :: <int>)
  logxor(ash<<(n, 1), ash>>(n, 31))
end;

define inline function zigzag-decode-32
    (n :: <int32>) => (_ :: <int>)
  logxor(ash>>(n, 1), - logand(n, 1))
end;

define inline function zigzag-encode-64
    (n :: <int64>) => (_ :: <int>)
  logxor(ash<<(n, 1), ash>>(n, 63))
end;

define constant zigzag-decode-64 = zigzag-decode-32;

define inline function decode-int32
    (buf :: <buffer>, start :: <int>) => (n :: <int32>, index :: <int>)
  let (n, index) = decode-varint(buf, start);
  values(logand(n, $max-int32), index)
end;

define inline function decode-int64
    (buf :: <buffer>, start :: <int>) => (n :: <int64>, index :: <int>)
  let (n, index) = decode-varint(buf, start);
  values(logand(n, $max-int64), index)
end;


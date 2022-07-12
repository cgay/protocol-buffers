Module: protocol-buffers-impl

// https://developers.google.com/protocol-buffers/docs/encoding

// TODO(cgay): in general I'm not worrying about large 64-bit ints that don't
// fit in a Dylan <int> for now.  We'll need to handle it eventually, via
// either <double-integer> or <machine-word>. I don't know the best method.

// This'll do for a start. There's an interesting buffer implementation in
// cl-protobufs that allows for back-patching the lengths of length-encoded
// elements so that making two passes is unnecessary.
define constant <buffer> = limited(<stretchy-vector>, of: <byte>);

// Wire types
// 0  Varint            int32, int64, uint32, uint64, sint32, sint64, bool, enum
// 1  64-bit            fixed64, sfixed64, double
// 2  Length-delimited  string, bytes, embedded messages, packed repeated fields
// 3  Start group       groups (deprecated)
// 4  End group         groups (deprecated)
// 5  32-bit            fixed32, sfixed32, float
define constant $wire-type-varint :: <int> = 0;
define constant $wire-type-64-bit :: <int> = 1;
define constant $wire-type-length-delimited :: <int> = 2;
define constant $wire-type-start-group :: <int> = 3;
define constant $wire-type-end-group :: <int> = 4;
define constant $wire-type-32-bit :: <int> = 5;

// Make a field tag that precedes the field data itself. The tag is the
// combination of a wire type (3 bits) and a field number (29 bits).
define function make-wire-tag
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

define function zigzag-encode-32
    (n :: <int32>) => (_ :: <int>)
  logxor(ash<<(n, 1), ash>>(n, 31))
end;

define function zigzag-decode-32
    (n :: <int32>) => (_ :: <int>)
  logxor(ash>>(n, 1), - logand(n, 1))
end;

define function zigzag-encode-64
    (n :: <int64>) => (_ :: <int>)
  logxor(ash<<(n, 1), ash>>(n, 63))
end;

define function zigzag-decode-64
    (n :: <int64>) => (_ :: <int>)
  logxor(ash>>(n, 1), - logand(n, 1))
end;

// Encode integer `i` as a varint into `buffer`. The caller is responsible for
// ensuring that `i` is the appropriate size (see encode-int32 et al) by either
// truncating or signaling an error.
define function encode-varint
    (buf :: <buffer>, int :: <int>) => (nbytes :: <int>)
  iterate loop (i :: <int> = int, nbytes :: <int> = 1)
    let byte = logand(127, i);
    i := ash>>(i, 7);
    let done? = zero?(i);
    add!(buf, if (done?)
                byte
              else
                logior(128, byte) // more bytes to follow
              end);
    if (done?)
      nbytes
    else
      loop(i, nbytes + 1)
    end
  end
end function;

// Decode a varint from `buf` starting at byte index `start`.
define function decode-varint
    (buf :: <buffer>, start :: <index>) => (i :: <int>, _end :: <index>)
  let varint :: <int> = 0;
  let shift :: <int> = 0;
  let index :: <index> = start;
  let high-bit-set? = #t;
  for (i from 0 below 10,       // max 10 7-bit bytes on 64-bit.
       while: high-bit-set?)
    let byte :: <byte> = buf[index];
    high-bit-set? := logbit?(7, byte);
    varint := logior(varint,
                     logand(ash<<(logand(byte, 127), shift),
                            $maximum-integer));
    inc!(index);
    inc!(shift, 7);
  end;
  values(varint, index)
end function;

// Note that https://developers.google.com/protocol-buffers/docs/proto#updating
// explicitly specifies truncation of int32, uint32, and bool if the value is
// too big to fit in that type.

define function encode-uint32
    (buf :: <buffer>, n :: <int>) => (nbytes :: <int>)
  encode-varint(buf, logand(n, $max-int32))
end function;

define function decode-uint32
    (buf :: <buffer>, start :: <index>) => (n :: <uint32>, _end :: <index>)
  let (n, index) = decode-varint(buf, start);
  values(logand(n, $max-int32), index)
end function;

define function encode-uint64
    (buf :: <buffer>, n :: <int>) => (nbytes :: <int>)
  encode-varint(buf, n)
end function;

define function decode-uint64
    (buf :: <buffer>, start :: <index>) => (n :: <uint64>, _end :: <index>)
  decode-varint(buf, start)
end function;

define function encode-int32
    (buf :: <buffer>, n :: <int>) => (nbytes :: <int>)
  encode-varint(buf, logand(n, $max-int32))
end function;

define function decode-int32
    (buf :: <buffer>, start :: <index>) => (n :: <int32>, _end :: <index>)
  let (n, index) = decode-varint(buf, start);
  values(logand(n, $max-int32), index)
end function;

define function encode-int64
    (buf :: <buffer>, n :: <int>) => (nbytes :: <int>)
  encode-varint(buf, n)
end function;

define function decode-int64
    (buf :: <buffer>, start :: <index>) => (n :: <int64>, _end :: <index>)
  decode-varint(buf, start)
end function;

define function encode-sint32
    (buf :: <buffer>, n :: <int>) => (nbytes :: <int>)
  encode-varint(buf, zigzag-encode-32(logand(n, $max-int32)))
end function;

define function decode-sint32
    (buf :: <buffer>, start :: <index>) => (n :: <int32>, _end :: <index>)
  let (n, index) = decode-varint(buf, start);
  values(zigzag-decode-32(logand(n, $max-int32)), index)
end function;

define function encode-sint64
    (buf :: <buffer>, n :: <int>) => (nbytes :: <int>)
  encode-varint(buf, zigzag-encode-64(n));
end function;

define function decode-sint64
    (buf :: <buffer>, start :: <index>) => (n :: <int64>, _end :: <index>)
  let (n, index) = decode-varint(buf, start);
  values(zigzag-decode-64(n), index)
end function;

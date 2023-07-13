Module: protocol-buffers-test-suite

define function buffer
    (#rest bytes :: <byte>) => (v :: <buffer>)
  map-into(make(<buffer>, size: bytes.size), identity, bytes)
end function;

define test test-make-wire-tag ()
  assert-equal(#b1_000, make-wire-tag(1, $wire-type-varint));
  assert-equal(#b1_001, make-wire-tag(1, $wire-type-64-bit));
  assert-equal(#b111_101, make-wire-tag(7, $wire-type-32-bit));
  assert-equal(#b11111111_010, make-wire-tag(255, $wire-type-length-delimited));
end test;

define test test-encode/decode-varint ()
  for (item in list(list(0, buffer(0)),
                    list(1, buffer(1)),
                    list(300, buffer(#xAC, #x02)),
                    list(270, buffer(#x8E, #x02)),
                    list(86942, buffer(#x9E, #xA7, #x05)),
                    list($min-int32, buffer(3)),
                    list($max-int32, buffer(4)),
                    list($max-uint32, buffer(5)),
                    list($max-uint64, buffer(255, 255, 255, 255, 255, 255, 255, 255, #x1F)),
                    list($min-int64, buffer(255, 255, 255, 255, 255, 255, 255, 255, #x3F)),
                    list(-1, buffer(255, 255, 255, 255, 255, 255, 255, 255, 255, 1))))
    let (i, bytes) = apply(values, item);
    local
      method encode-varint-bytes (i :: ga/<integer>) => (bytes :: <vector>)
        let buf = make(<buffer>);
        let n = encode-varint(buf, i);
        copy-sequence(buf, end: n)
      end,
      method decode-varint-bytes (bytes :: <seq>) => (i :: ga/<integer>)
        let buf = apply(buffer, bytes);
        let (i, nbytes) = decode-varint(buf, 0);
        assert-equal(nbytes, bytes.size);
        i
      end;
    assert-equal(encode-varint-bytes(i), bytes);
    assert-equal(i, decode-varint-bytes(bytes));
  end for;
end test;

// Two benchmarks to give an idea (when compared to each other) how much of a
// slowdown generic-arithmetic causes.

define benchmark benchmark-encode-varint-$maximum-integer ()
  let buf = make(<buffer>, size: 10);
  for (i from 1 to 1_000_000)
    buf.size := 0;
    encode-varint(buf, $maximum-integer);
  end;
end benchmark;

define benchmark benchmark-encode-varint-max-uint64 ()
  let max-uint64 = ga/-(ga/^(2, 64), 1);
  let buf = make(<buffer>, size: 10);
  for (i from 1 to 1_000_000)
    buf.size := 0;
    encode-varint(buf, max-uint64);
  end;
end benchmark;

define constant $zigzag-32-bit-test-cases
  = #(#(0, 0),
      #(-1, 1),
      #(1, 2),
      #(-2, 3),
      #(2147483647, 4294967294),
      #(-2147483648, 4294967295));

define test test-zigzag-encode-32 ()
  for (item in $zigzag-32-bit-test-cases)
    let (orig, encoded) = apply(values, item);
    assert-equal(zigzag-encode-32(orig), encoded, sformat("zigzag-encode-32(%=)", orig));
  end;
end test;

define test test-zigzag-encode-64 ()
  for (item in concat($zigzag-32-bit-test-cases,
                      list(#(34359738368, 68719476736),  // 2 ^ 35
                           #(-34359738368, 68719476735) // -(2 ^ 35)
                             // TODO:
                             //#(9223372036854775807, 18446744073709551614), // 2 ^ 63 - 1
                             //#(-9223372036854775807, 18446744073709551615) // -(2 ^ 63)
                             )))
    let (orig, encoded) = apply(values, item);
    assert-equal(zigzag-encode-64(orig), encoded, sformat("zigzag-encode-64(%=)", orig));
  end;
end test;

define function round-trip-varint (n :: <int>, encoder, decoder)
  let buf = make(<buffer>);
  let nbytes = encoder(buf, n);
  check-true(sformat("for n = %d, encoded as %d bytes", n, nbytes),
             nbytes > 0 & nbytes <= 10);
  let (new-n, index) = decoder(buf, 0);
  check-equal(sformat("for n = %d, new-n = %d, index = %d", n, new-n, index),
              index, nbytes);
  check-equal("same value", n, new-n);
end function;

define test test-encode/decode-int32 ()
  local method round-trip (n)
          round-trip-varint(n, encode-int32, decode-int32)
        end;
  round-trip($min-int32);
  round-trip($min-int32 + 1);
  round-trip(-2);
  round-trip(-1);
  round-trip(0);
  round-trip(1);
  round-trip(2);
  round-trip($max-int32 - 1);
  round-trip($max-int32);
end test;

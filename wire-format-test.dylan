Module: protocol-buffers-internal

define test test-make-wire-tag ()
  assert-equal(#b1_000, make-wire-tag(1, $wire-type-varint));
  assert-equal(#b1_001, make-wire-tag(1, $wire-type-64-bit));
  assert-equal(#b111_101, make-wire-tag(7, $wire-type-32-bit));
  assert-equal(#b11111111_010, make-wire-tag(255, $wire-type-length-delimited));
end test;

define test test-decode-varint ()
  assert-equal(1, decode-varint(#[1], 0));
  assert-equal(300, decode-varint(#[172, 2], 0));
  // 8 bytes of 7 low bits each = 56 bits ++ 5 more bits ++ the sign bit ++
  // Dylan tag bits = 64, so this is the biggest integer we can encode for now.
  assert-equal($maximum-integer,
               decode-varint(#[255, 255, 255, 255, 255, 255, 255, 255, #x1F], 0));
end test;

define function encode-varint-for-test
    (i :: <int>) => (bytes :: <vector>)
  let buffer = make(<buffer>, size: 10);
  let n = encode-varint(buffer, i);
  copy-sequence(buffer, end: n)
end;

define test test-encode-varint ()
    assert-equal(1, 2);
end;

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
    assert-equal(zigzag-encode-32(orig), encoded, format-to-string("zigzag-encode-32(%=)", orig));
  end;
end test;

define test test-zigzag-encode-64 ()
  for (item in concat($zigzag-32-bit-test-cases,
                      #(#(34359738368, 68719476736),  // 2 ^ 35
                        #(-34359738368, 68719476735), // -(2 ^ 35)
                        #(9223372036854775807, 18446744073709551614), // 2 ^ 63 - 1
                        #(-9223372036854775807, 18446744073709551615)))) // -(2 ^ 63)
    let (orig, encoded) = apply(values, item);
    assert-equal(zigzag-encode-64(orig), encoded, format-to-string("zigzag-encode-64(%=)", orig));
  end;
end test;

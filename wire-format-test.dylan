Module: protocol-buffers-internal

define test test-make-wire-tag ()
  assert-equal(#b1000, make-wire-tag(1, $wire-type-varint));
  assert-equal(#b1001, make-wire-tag(1, $wire-type-64-bit));
  assert-equal(#b111101, make-wire-tag(7, $wire-type-32-bit));
end test;

define test test-decode-varint ()
  assert-equal(1, decode-varint(#[1], 0));
  assert-equal(300, decode-varint(#[172, 2], 0));
  // 8 bytes of 7 low bits each = 56 bits ++ 5 more bits
  // ++ the sign bit ++ Dylan tag bits = 64
  assert-equal(99, decode-varint(#[255, 255, 255, 255,
                                   255, 255, 255, 255,
                                   #b11111],
                                 0));
end test;

Module: protocol-buffers-implementation
Synopsis: https://developers.google.com/protocol-buffers/docs/encoding

define binary-data <varint-frame> (<container-frame>)
  repeated field varint-bytes :: <unsigned-byte>,
    reached-end?: frame < 128;
end;

// Turn a <varint-frame> into its integer value.
define method parse-frame
    (frame-type == <varint-frame>, packet :: <byte-sequence>, #key)
 => (int :: <integer>, next-unparsed :: <integer>)
  let int = 0;
  for (i from 0 below packet.size
  values(int, next-unparsed)
end method;

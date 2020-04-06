Module: protocol-buffers-implementation

// https://developers.google.com/protocol-buffers/docs/encoding#varints

define binary-data <varint-frame> (<container-frame>)
  repeated field varint-bytes :: <unsigned-byte>,
    reached-end?: frame < 128;
end;

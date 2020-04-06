# Protocol Buffers

Implementation of Google's protocol buffers for Dylan


# Status
embryonic


# Thoughts

* Implementation strategy:
  1. Start with proto3, no required fields, much simpler.
  1. Write and debug wire format.
  1. Write an example of the expected protoc generated code, by hand.
  1. Write some tests that use the example to parse protos from a file.
  1. Write protoc plugin.

     1. Package spec in .proto file indicates both library and module?
     1. Replace '.' with '-' in package spec.
     1. Just generate a module, with exports, but no library? An existing
        library can add the generated foo-proto-module.dylan file to its
        LID file and to the library easily enough.

  1. Write gRPC implementation and hook it into HTTP server.
  1. Write Text Format parser/printer (wrap C).
  1. Build system integration. LID file option:

       protocol-buffer: foo.proto -> foo-module.dylan, foo-library.dylan?

* Wrap C++, or do it all in Dylan?

* Protocol **buffers**. The intention is to use it as a buffer. For example if
  you have a high QPS gRPC service you don't want to allocate a new proto
  message per query when its lifetime is the query's lifetime. So the ability
  to re-use messages is important.

* Lazy (de)serialization

* Specialized (de)serializers. For example if the proto objects need to be
  initialized in a specific order. (That particular case could be handled via
  proto option annotations.)

* Object pools to reduce memory churn

* POD objects? Protocol buffers are intended to be Plain Old Data. I'm curious
  to see if there are differences in the way they can be implemented in Dylan.
  For example, can we have field options to make the corresponding Dylan slot
  be `constant` or `required-init-keyword:`?  Are there safe ways to add
  behavior to protoc-generated classes in Dylan?

* Can the [binary-data](https://github.com/cgay/binary-data) library be used
  for parsing?

* protoc plugin
  - needs integration into build process



## Generated code

Given this Text Format proto:

```protobuf
message Person {
  required string name = 1;
  required int32 id = 2;
  optional string email = 3;
}
```

use it like this

```dylan
let p = make(<person>,
             name: "John Doe",
             id: 123,
             email: "jdoe@example.com");
write-proto(stream, p);
write-text-proto(stream, p);
let p = read-proto(stream, <person>);
let p = read-text-proto(stream);
```

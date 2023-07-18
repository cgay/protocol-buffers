************
Design Notes
************

This isn't a design document, it's just a place to drop some notes. Might as
well keep them in Git.

Goals
=====



Decisions
=========

In my experience, for any non-trivial project there will be times down the road
when people working on the code will wonder "why the heck did they do it this
way?" This section is an attempt to answer those future questions. Please don't
laugh too hard!

IDL parser vs ``protoc`` plug-in
--------------------------------

There are two obvious choices for how to implement the Dylan code generation
for protobuf IDL: write a plug-in (in C++) for Google's ``protoc`` tool, or
write our own parser. We decided to write our own parser.

Pro ``protoc``:

* There are plenty of plug-ins to crib from so writing the actual code might be
  easier.

* As the protobuf IDL changes ``protoc`` will support the new changes and will
  presumable be backward compatible. For small changes we probably won't even
  have to update our code generator, at least until we add explicit support for
  the feature.

Pro Dylan:

* Parsing a ``.proto`` file isn't that hard anyway.

* Easier integration with the build system. Integrating a Dylan program into
  the Dylan build system can be done in-language rather than by invoking an
  external process, ``protoc``.

* Lower burden on Dylan users of protocol buffers. We don't want users to have
  to figure out how to install ``protoc``, configure the Open Dylan compiler to
  find it and so on.

* If our IDL parser is simple, making changes to support new protobuf features
  over time won't be very difficult anyway. It's hard to imagine protobufs
  suddenly changing in some fundamental way that would require a rewrite.

* We, and our users, can remain in our blissful non-C++ world.

Implementation Strategy
=======================

The following are roughly in order of which should be done first.

* Start with proto3, no required fields, if field has default value it's essentially
  unset, much simpler. No need for is-set vector, nor for %foo internal slot names and
  methods to guard their access. Do proto2 when proto3 functionally complete.

* DO NOT OPTIMIZE ANYTHING. Write simple, clear Dylan code without any attempt to
  optimize anything in advance. That comes later, based on benchmarks and profiling.

* Write and debug wire format.

* Write an example of the expected protoc generated code, by hand. This will help to
  tease out the generated code APIs.

* Write some tests that use the example to parse protos from a file.

* Write protoc plugin.

   For foo.proto with `package foo;`, generate

       * foo-proto.dylan
       * foo-proto-module.dylan

   Do not genarate a library. Instead, users can include the above two files in their LID
   file. This is more flexible and allows multiple protos (and non-proto Dylan code) to
   be in the same library and benefit from sealing optimizations.

   Generating the library definition can be an option later.

* Write gRPC implementation and hook it into HTTP server.

* Write Text Format parser/printer

* Build system integration. LID file option to invoke protoc:

     protocol-buffer: foo.proto -> foo-module.dylan, foo-library.dylan?

* Lazy decoding

* Specialized decoders. For example if the proto objects need to be initialized
  in a specific order. (That particular case could be handled via proto option
  annotations.)

* Arenas to reduce memory churn

* POD objects? Protocol buffers are intended to be Plain Old Data. In Go people
  often write wrapper types for protobuf types. I'm curious to see if there are
  differences in the way they can be implemented in Dylan.  For example, can we
  have field options to make the corresponding Dylan slot be `constant` (not if
  they need to be used with arenas) or `required-init-keyword:`?  Are there
  safe ways to add behavior to protoc-generated classes in Dylan?


TODO List
=========

Some specific reminders to myself as I go along.

* Lazy parsing

* Need to handle the few Dylan reserved words specially if they're used as a
  message field name etc. Also any macros imported into the generated code's
  module. Providing a dylan_name field option isn't enough because sometimes
  you need to interact with a .proto that you cannot modify. "end" is a common
  example.

* limited types for repeated slots. First pass, add a comment about
  the type, like "// repeated int32"

* Emit explicit "define generic" forms with the correct type unions.
  It will complicate the protoc plugin somewhat. How much of a win is
  it, if the generated code is sealed anyway?

* for now this code assumes the existence of certain base classes. These
  will be defined elsewhere and will need to be imported with a prefix so
  as not to conflict with generated class names.

* strings should be utf-8. proto3 validates that in setter methods.

* There's an interesting buffer implementation in cl-protobufs that allows for
  back-patching the lengths of length-encoded elements so that making two
  passes is unnecessary.



Proto2 Considerations
=====================

Summary: use a bit vector to indicate whether fields are set.

Optional values create a problem for boolean fields because one needs to
distinguish between true, false, and unset. All other types, whether numbers,
messages, or sequences can use :drm:`#f` and :func:`false-or` types for
"unset".

This means that boolean fields would need a small amount of extra code in a
field accessor wrapper method to return :const:`$unset` if the field is unset.

An alternative approach is to use bit vector to track which fields have been
set. Either way, the user must treat boolean fields specially by calling
``has-field?`` before using the value rather than just using it like
``my-boolean-field(m) | ...``.

Bit vector advantages:

* generated code is the same for all field types
* no need to use :func:`false-or` types for any primitive field type.

Bit vector disadvantages:

* uses slightly more storage overall.

It seems cleaner to use bit vectors.

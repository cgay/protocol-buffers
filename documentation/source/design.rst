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
  presumably be backward compatible. For small changes we probably won't even
  have to update our code generator, at least until we add explicit support for
  the feature.

Pro Dylan:

* Parsing a ``.proto`` file isn't that hard anyway. (Famous last words.)

* Easier integration with the build system. Integrating a Dylan program into
  the Dylan build system can be done in-language rather than by invoking an
  external process, ``protoc``.

* Lower burden on Dylan users of protocol buffers. We don't want users to have
  to figure out how to install ``protoc``, configure the Open Dylan compiler to
  find it and so on.

* If our IDL parser is simple, making changes to support new protobuf features
  over time won't be very difficult anyway. It's hard to imagine protobufs
  suddenly changing in some fundamental way that would require a rewrite.

* The big one: We, and our users, can remain in our blissful non-C++ world.

Implementation Strategy
=======================

The following are roughly in order of which should be done first.

* Start with proto3, no required fields, if field has default value it's essentially
  unset, much simpler. No need for is-set vector, nor for %foo internal slot names and
  methods to guard their access. Do proto2 when proto3 functionally complete.

  **Status:** This turned out to be naive because one of the first protos we
  need to convert is descriptor.proto, in the Google protobuf repo, which is
  proto2 format.

* DO NOT OPTIMIZE ANYTHING. Write simple, clear Dylan code without any attempt to
  optimize anything in advance. That comes later, based on benchmarks and profiling.

* Write and debug wire format.

  **Status:** much of this is done but
  https://github.com/dylan-lang/opendylan/issues/1377 is problematic for large
  integers.

* Write some tests that use the example to parse protos from a file.

* Write IDL parser.

  **Status:** Dec 2023, lexer complete, parser good enough to parse descriptor.proto
  but still only perhaps 50% done.

* Write code generator.

  **Status:** Dec 2023, can generate code for descriptor.proto

* **Done:** Build system integration. LID file option to invoke protoc:

     protocol-buffer: foo.proto -> foo-module.dylan, foo-library.dylan?

* Write Text Format parser/printer

* Write gRPC implementation and hook it into HTTP server.

* Arenas to reduce memory churn

* POD objects? Protocol buffers are intended to be Plain Old Data. In Go people
  often write wrapper types for protobuf types. I'm curious to see if there are
  differences in the way they can be implemented in Dylan.  For example, can we
  have field options to make the corresponding Dylan slot be ``constant`` (not
  if they need to be used with arenas) or ``required-init-keyword:``?  Are
  there safe ways to add behavior to protoc-generated classes in Dylan?

  **Status:** Dec 2023, it's now possible to build protos *into* a Dylan
  library and therefore non-generated code can add methods to sealed generic
  functions if it wants to. This should make it possible to, for example, make
  a subclass of a generated class that modifies the API of the generated code.

TODO List
=========

Some specific reminders to myself as I go along.

* Lazy decoding

* limited types for repeated slots. First pass, add a comment about
  the type, like "// repeated int32"

* Emit explicit "define generic" forms with the correct type unions.  It will
  complicate the codegen somewhat. How much of a win is it, if the generated
  code is sealed anyway? I think the IDE / LSP will emit a more specific
  arglist, for example, but since all accessors use the class name as a prefix
  they're not particularly "generic" generic functions.

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

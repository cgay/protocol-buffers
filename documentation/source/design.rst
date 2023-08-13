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

  **Status:** Aug 2023, lexer complete, parser underway.

* Write code generator.

  Write an example of the expected protoc generated code, by hand. This will
  help to tease out the generated code APIs.

  * option (dylan_module) = "foo";           // default to what?
  * option (dylan_gen_module_file) = false;  // default to true
  * option (dylan_gen_library_file) = false; // default to true

  **Status:** (Aug 2023) I wrote much of a hand translated version of
  descriptor.proto and now I have almost enough to use it in the parser code.

* Write gRPC implementation and hook it into HTTP server.

* Build system integration. LID file option to invoke protoc:

     protocol-buffer: foo.proto -> foo-module.dylan, foo-library.dylan?

* Write Text Format parser/printer

* Arenas to reduce memory churn

* POD objects? Protocol buffers are intended to be Plain Old Data. In Go people
  often write wrapper types for protobuf types. I'm curious to see if there are
  differences in the way they can be implemented in Dylan.  For example, can we
  have field options to make the corresponding Dylan slot be ``constant`` (not
  if they need to be used with arenas) or ``required-init-keyword:``?  Are
  there safe ways to add behavior to protoc-generated classes in Dylan?


TODO List
=========

Some specific reminders to myself as I go along.

* Lazy decoding

* Need to handle the few Dylan reserved words specially if they're used as a
  message field name etc. Also any macros imported into the generated code's
  module. Providing a dylan_name field option isn't enough because sometimes
  you need to interact with a .proto that you cannot modify. "end" is a common
  example.

  **Status:** Not a problem. Generated slot names all have the class (i.e.,
  message) name as a prefix.

* limited types for repeated slots. First pass, add a comment about
  the type, like "// repeated int32"

* Emit explicit "define generic" forms with the correct type unions.  It will
  complicate the codegen somewhat. How much of a win is it, if the generated
  code is sealed anyway? I think the IDE / LSP will emit a more specific
  arglist, for example.

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

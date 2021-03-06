# Protocol Buffers

Implementation of Google's protocol buffers for Dylan


# Status

embryonic


# Thoughts

* Implementation strategy:
  1. Start with proto3, no required fields, if field has default value it's
     essentially unset, much simpler. No need for is-set vector, nor for
     %foo internal slot names and methods to guard their access.
  1. Message field accessor functions will match the field names, without a
     prefix. The idea is that each proto package maps to a Dylan module and
     the field accessor methods will be sealed for performance. The expected
     usage is to import the module with a prefix: pb/options(msg).  (This
     may change, or we can annotate messages with a dylan_prefix option.)
  1. Write and debug wire format.
  1. Write an example of the expected protoc generated code, by hand.
  1. Write some tests that use the example to parse protos from a file.
  1. Write protoc plugin.

     For foo.proto with `package foo;`, generate

         1. foo-proto.dylan
         1. foo-proto-module.dylan

     Do not genarate a library. Instead, users can include the above two files
     in their LID file. This is more flexible because it allows multiple protos
     (and non-proto Dylan code) to be in the same library and benefit from
     sealing optimizations.

     There is added overhead for the user to create a library, but it seems
     worth it.

  1. Write gRPC implementation and hook it into HTTP server.
  1. Write Text Format parser/printer (wrap C).
  1. Build system integration. LID file option:

       protocol-buffer: foo.proto -> foo-module.dylan, foo-library.dylan?

* Wrap C++, or do it all in Dylan?

* Protocol **buffers**. The intention is to use it as a buffer. For example if
  you have a high QPS gRPC service you don't want to allocate a new proto
  message per query when its lifetime is the query's lifetime. So the ability
  to re-use messages is important. (I think this is more or less built in, via
  the `clear-*` methods.)

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
  for parsing? I like the idea but I don't really want to end up having to fix
  bugs in binary-data.

* protoc plugin
  - needs integration into build process


# Generated Code Guide

## Naming

Protocol buffer names are mapped to Dylan naming conventions following these
rules:

*  CamelCase is converted to lowercase-with-hyphens.
*  snake_case is converted to lowercase-with-hyphens.
*  Message names are surrounded by angle brackets. `message Foo` becomes
   `class <foo>`.
*  In package names, dots and underscore are converted to hyphen.

## Usage

Assume the following protocol buffer definitions in a file named `abc.proto`.

```protobuf
package abc;
syntax proto3;
message Person {
  string name = 1;
  int32 id = 2;
  message Address {
    string email = 1;
  }
  Address address = 3
  enum HairColor {
    UNKNOWN = 0;
    BLACK = 1;
    BLONDE = 2;
  }
  HairColor hair_color = 4 [default = BLACK];
}
```

Given the above `abc.proto` file, two Dylan files are generated:

1.  `abc-module.dylan`, the module definition file with appropriate exports.

    ```dylan
    Module: dylan-user

    define module abc
      use dylan;
      use protocol-buffers, prefix: "pb/";
      use uncommon-dylan, import: { enum-definer };
      export
        <person>,

        person-name,
        person-name-setter,
        person-name-set?,
        clear-person-name,

        person-id,
        person-id-setter,
        person-id-set?,
        clear-person-id,

        person-address,
        person-address-setter,
        person-address-set?,
        clear-person-address,

        person-hair-color,
        person-hair-color-setter,
        person-hair-color-set?,
        clear-person-hair-color,

        <person-address>,
        person-address-email,
        person-address-email-setter,
        person-address-email-set?,
        clear-person-address-email,

        // TODO: enums aren't finished yet
        <person-hair-color>,
        $person-hair-color-unknown,
        $person-hair-color-black,
        $person-hair-color-blonde;
    end module;
    ```

2.  `abc.dylan`, the main generated code.

    ```dylan
    Module: abc

    define sealed class <person> (pb/<message>)
      slot person-name :: <string> = "", init-keyword: name:;
      slot person-id :: <integer> = 0, init-keyword: id:;
      slot person-address :: false-or(<person-address>) = #f, init-keyword: address:;
      slot person-hair-color :: <person-hair-color> = $person-hair-color-black, init-keyword: hair-color:;
    end class;

    define sealed class <person-address> (pb/<message>)
      slot person-address-email :: <string> = "", init-keyword: email:;
    end class;

    define enum <person-hair-color> ()
      $person-hair-color-unknown = 0;
      $person-hair-color-black   = 1;
      $person-hair-color-blonde  = 2;
    end;
    ```

Create protobuf objects by passing initargs to `make` or by using setter
methods.

```dylan
let p = make(<person>,
             name: "John Doe",
             id: 123,
             address: make(<person-address>, email: "a@b"));
```

or

```dylan
let a = make(<person-address>);
a.person-address-email := "a@b";

let p = make(<person>);
p.person-name := "John Doe";
p.person-id := 123;
p.person-address := a;
```

Note that for the inner message "Address", the class name is
`<person-address>`, reflecting the nesting of the messages. This is necessary
to avoid conflicting with a top-level message named "Address".

Similarly, the slot getter/setter for the inner class must be prefixed with the
name of the outer class to reduce the possibility of name conflicts, so we have
`a.person-address-email`.

But notice that when passing initargs there is no possibility of conflict so
simply `email:` will work. This is because protobuf messages are Plain Old Data
objects and do not inherit from other message types.

To write/read a Person to/from a byte buffer or binary stream:

```dylan
write-binary(person, buffer-or-stream) => (nbytes :: <integer>)
read-binary(person, buffer-or-stream) => (nbytes :: <integer>)
```

To write/read a Person to/from a Text Format stream:

```dylan
let p = read-text-format(stream, <person>);
write-text-format(stream, p);
```

TODO: it can be useful to read/write sequences of protobuf objects to a
file. Overload the above methods for sequences?


# TODO List

Some specific reminders to myself as I go along.

* Lazy parsing

* Need to handle the few Dylan reserved words specially if they're used as a
  message field name etc. Also any macros imported into the generated code's
  module. Providing a dylan_name field option isn't enough because sometimes
  you need to interact with a .proto that you cannot modify. "end" is a common
  example.

* dylan_package option

* limited types for repeated slots. First pass, add a comment about
  the type, like "// repeated int32"

* Prefix slot names? Assuming for now that slot names exactly match
  message field names. It may be necessary to add a prefix, like
  "file-descriptor-proto-". Revisit later.

* Emit explicit "define generic" forms with the correct type unions.
  It will complicate the protoc plugin somewhat. How much of a win is
  it, if the generated code is sealed anyway?

* for now this code assumes the existence of certain base classes. These
  will be defined elsewhere and will need to be imported with a prefix so
  as not to conflict with generated class names.

* strings should be utf-8. proto3 validates that in setter methods.


# Proto2 Considerations

Optional values create a problem for boolean fields because one needs to
distinguish between true, false, and unset. All other types, whether numbers,
messages, or strings can use `#f` and `false-or` types for "unset". Repeated
fields can use `empty?`?

This means that boolean fields would need a small amount of extra code in a
field accessor wrapper method to return #"unset" if the field is unset.

An alternative approach is to use bit vector to track which fields have been
set. Either way, the user must treat boolean fields specially by calling
`has-field?` before using the value rather than just using it like
`my-boolean-field(m) | ...`.

Bit vector advantages:

* generated code is the same for all field types
* no need to use `false-or` types for any field type.

Bit vector disadvantages:

* uses slightly more storage overall.

It seems cleaner to use bit vectors.

# Protocol Buffers

Implementation of Google's protocol buffers


# Status

embryonic


# Implementation Strategy

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


# Generated Code Guide

## Naming

Protocol buffer names are mapped to Dylan naming conventions following these
rules:

*  CamelCase is converted to lowercase-with-hyphens.
*  snake_case is converted to lowercase-with-hyphens.
*  Message and enum names are surrounded by angle brackets. `message Foo`
   becomes `class <foo>`. Nested `message Bar` becomes `<foo-bar>`.
*  In package names, dot and underscore are converted to hyphen.

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
    option allow_alias = true;
    UNKNOWN = 0;
    BLACK = 1;
    black = 1;  // reminder to self that this is valid
    BLONDE = 2;
    blonde = 2;
  }
  HairColor hair_color = 4 [default = BLACK];
}
```

Given the above `abc.proto` file, at least two Dylan files are generated:

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
        clear-person-name,

        person-id,
        person-id-setter,
        clear-person-id,

        person-address,
        person-address-setter,
        clear-person-address,

        person-hair-color,
        person-hair-color-setter,
        clear-person-hair-color,

        <person-address>,
        person-address-email,
        person-address-email-setter,
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

    define primary class <person> (pb/<message>)
      slot person-name :: <string>,
        init-keyword: name:,
        init-value: "";
      slot person-id :: <int32>,
        init-keyword: id:
        init-value: 0;
      slot person-address :: false-or(<person-address>),
        init-keyword: address:,
        init-value: #f;
      slot person-hair-color :: <person-hair-color>
        init-keyword: hair-color:,
        init-value: $person-hair-color-black;
    end class;

    define primary class <person-address> (pb/<message>)
      slot person-address-email :: <string>,
        init-keyword: email:,
        init-value: "";
    end class;

    define enum <person-hair-color> ()
      $person-hair-color-unknown :: <int32> = 0;
      $person-hair-color-black   :: <int32> = 1;
      $person-hair-color-blonde  :: <int32> = 2;
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

To write/read a `Person` to/from a byte buffer or binary stream:

```dylan
let person = decode(<person>, buffer-or-stream);
let nbytes = encode(person, buffer-or-stream);
```

To write/read a `Person` to/from a Text Format stream:

```dylan
let person = decode-text-format(<person>, buffer-or-stream);
let nbytes = encode-text-format(person, stream);
```

# TODO List

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


# Proto2 Considerations

Summary: use a bit vector to indicate whether fields are set.

Optional values create a problem for boolean fields because one needs to
distinguish between true, false, and unset. All other types, whether numbers,
messages, or sequences can use `#f` and `false-or` types for "unset".

This means that boolean fields would need a small amount of extra code in a
field accessor wrapper method to return `$unset` if the field is unset.

An alternative approach is to use bit vector to track which fields have been
set. Either way, the user must treat boolean fields specially by calling
`has-field?` before using the value rather than just using it like
`my-boolean-field(m) | ...`.

Bit vector advantages:

* generated code is the same for all field types
* no need to use `false-or` types for any primitive field type.

Bit vector disadvantages:

* uses slightly more storage overall.

It seems cleaner to use bit vectors.

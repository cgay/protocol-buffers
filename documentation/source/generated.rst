********************
Generated Code Guide
********************

Guide to the generated Dylan code and how it maps from the :file:`.proto` file
Interface Definition Language (IDL).


Notes to be Integrated into Main Docs
=====================================

**TODO TODO TODO**

* It is possible for the name of a protobuf field and nested message or enum
  type to differ only by case. Since Dylan is not case sensitive this could
  cause a conflict. This isn't a problem, however, due to the generated message
  and enum types using Dylan's ``<class>`` naming convention.


Naming
======

Protocol buffer names are mapped to Dylan naming conventions following these
rules:

* CamelCase is converted to lowercase-with-hyphens.
* snake_case is converted to lowercase-with-hyphens.
* Message and enum names are surrounded by angle brackets. ``message Foo``
  becomes ``class <foo>``. Nested ``message Bar`` becomes ``<foo-bar>``.
* In package names, dot and underscore are converted to hyphen to make the
  Dylan module name, unless overridden by an option.


Usage
=====

Assume the following protocol buffer definitions in a file named
:file:`abc.proto`.

.. code-block:: protobuf

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

Given the above :file:`abc.proto` file, at least two Dylan files are generated:

1.  :file:`abc-module.dylan`, the module definition file with appropriate
    exports.

.. code-block:: dylan

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

2.  :file:`abc.dylan`, the main generated code.

.. code-block:: dylan

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

Create protobuf objects by passing initargs to :drm:`make` or by using setter
methods.

.. code-block:: dylan

   let p = make(<person>,
                name: "John Doe",
                id: 123,
                address: make(<person-address>, email: "a@b"));

or

.. code-block:: dylan

   let a = make(<person-address>);
   a.person-address-email := "a@b";

   let p = make(<person>);
   p.person-name := "John Doe";
   p.person-id := 123;
   p.person-address := a;

Note that for the inner message "Address", the class name is
``<person-address>``, reflecting the nesting of the messages. This is necessary
to avoid conflicting with a top-level message named "Address".

Similarly, the slot getter/setter for the inner class must be prefixed with the
name of the outer class to reduce the possibility of name conflicts, so we have
``a.person-address-email``.

But notice that when passing initargs there is no possibility of conflict so
simply ``email:`` will work. This is because protobuf messages are Plain Old Data
objects and do not inherit from other message types.

To write/read a ``Person`` to/from a byte buffer or binary stream:

.. code-block:: dylan

   let person = decode(<person>, buffer-or-stream);
   let nbytes = encode(person, buffer-or-stream);

To write/read a ``Person`` to/from a Text Format stream:

.. code-block:: dylan

   let person = decode-text-format(<person>, buffer-or-stream);
   let nbytes = encode-text-format(person, stream);

********************
Generated Code Guide
********************

This guide explains the Dylan APIs generated for protocol buffer Interface
Definition Language (IDL), usually just referred to as :file:`.proto` files.


The pbgen Application
=====================

The `protocol-buffers <https://github.com/cgay/protocol-buffers>`_ package
comes with an application called ``pbgen`` which may be used to generate Dylan
code from one or more libraries.  Example:

  .. code-block:: shell

     $ cd protocol-buffers
     $ dylan update
     $ dylan build pbgen
     $ _build/bin/pbgen -o /tmp --library-name nesting test-data/nesting.proto
     pbgen wrote /tmp/nesting-pb.dylan
     pbgen wrote /tmp/nesting-module-pb.dylan
     pbgen wrote /tmp/nesting-library-pb.dylan
     pbgen wrote /tmp/nesting.lid

``pbgen`` is a great way to check what the generated code looks like for a
``.proto`` file.  Pass any number of ``.proto`` files on the command line.


Using Protobufs in Open Dylan Projects
======================================

There are several ways to integrate protobufs into your projects.

Perhaps the simplest way is to manually run the `pbgen <#the-pbgen-application>`_
application, and commit the generated code to your source repository. This
allows a great deal of flexibility to modify or augment the code if you find it
necessary, and has the benefit of being able to see how the generated code
changes over time by looking at the commit history. However, it is a manual
step you must remember to run if the ``.proto`` file changes.

The second way is to add the ``.proto`` file to your ".lid" file. This, in
turn, has two options:

1. Generate a complete library that is added as a subproject to your
   library. We expect this to be the most common case.

2. Generate only Dylan modules and use them in your library.


Generate a Dylan Library
------------------------

Let's say you have a file called :file:`foo.proto` that you would like to add
to your project so you can use the generated code and you want that code
generated in its own library.

1. Create a file called, for example, :file:`protos.spec` that contains
   something like this::

     Origin: protobuf
     Files: foo.proto
     Library: foo-pb
     Directory: generated-code

   ``Origin:`` tells Open Dylan that it should invoke the build tool named
   "protobuf", which is a specially designed tool plugin similar to the ones
   for the Dylan parser generator and CORBA.

   ``Files:`` says to use :file:`foo.proto` as the only input file.  You may
   specify multiple files here by listing one on the next line, with leading
   whitespace, and so on. This is the same format as the ``Files:`` header in
   Dylan LID files.

   ``Library:`` says to generate a library definition file and a LID file both
   using the library name "foo-pb". We recommend using the ``-pb`` suffix for
   all Protobuf generated code libraries so that users familiar with the
   generated Dylan protobuf APIs will immediately know it's a protobuf
   generated library and will know what to expect from that library.

   ``Directory:`` specifies the directory in which to write the generated
   files, relative to the ``.spec`` file's directory. If not specified, the
   files are generated in the ``.spec`` file's directory.

2. Add ``protos.spec`` to your library's LID file. Open your ".lid" file and
   add this line::

     Other-Files: protos.spec

3. Remember to ``use`` the generated protobuf library and modules in your
   own library and module definitions.

4. Create a registry file for the ``foo-pb`` library. You can do this manually,
   as described in `Using Source Registries
   <https://opendylan.org/getting-started-cli/source-registries.html>`_ or, if
   you are using a workspace created with the `dylan
   <https://opendylan.org/package/dylan-tool/index.html>`_ tool:

   1. First try and compile your project without the registry entry for the
      ``foo-pb`` library. This generates the Dylan protobuf code, but fails to
      compile because it can't find the ``foo-pb`` library.

   2. Now run ``dylan update`` inside your workspace directory. Since the
      generated code is there, ``dylan update`` will find it and add a registry
      entry for it.

   3. Compile your project again. This time the compiler should find the
      ``foo-pb`` library and finish successfully.

   (We plan to streamline this process, but for now it should work.)

5. Compile your library.

   .. NOTE::

      Due to an issue with the Open Dylan project manager the protocol buffer
      code generation will only be invoked if you compile your project as a
      "user project", which only happens if it is opened directly via its
      ".lid" file rather than via the registry. So you must run
      ``dylan-compiler -build .../your-library.lid`` instead of just
      ``dylan-compiler -build your-library``. This will be fixed in the future.


Generate Only Dylan Modules
---------------------------

The second way to incorporate protobufs into your project is to generate Dylan
modules and code that are added to your library directly. The primary reason do
do it this way, instead of generating a separate library, is if you need to
augment the generated protobuf classes in some way.

For example, Protobuf messages are designed to be Plain Old Data (POD)
objects. You might decide, perhaps for compatibility or convenience reasons,
that you want to provide subclasses that add more behavior to the generated
classes, make them easier to construct, etc. Including the generated code
within another library provides a way to do this without having to "unseal" (or
"open") any of the generated generic functions or classes.

To use this method, simply follow step 1 in `Generate a Dylan Library`_ but
omit the ``Library:`` line in your ``.spec`` file. Make sure your library
definition uses the module generated for whatever ``package`` was specified in
:file:`foo.proto`.

There is no need to create a registry entry either, since there is no generated
library.


Naming
======

Protocol buffer names are mapped to Dylan naming conventions following these
rules:

* CamelCase is converted to lowercase-with-hyphens.

* snake_case is converted to lowercase-with-hyphens.

* Protobuf package names are converted to Dylan module names by replacing dot
  (".")  and underscore ("_") with hyphen ("-"), unless overridden by an
  option. If no package name is provided in the ``.proto`` file, the Dylan
  module name is the same as the file name, after removing the ``.proto``
  extension. For example::

    package nesting;             ==>    define module nesting ...
    package google.protobuf;     ==>    define module google-protobuf ...
    package foo_bar;             ==>    define module foo-bar ...

* Message and enum type names are surrounded by angle brackets.. ``message
  Foo`` generates Dylan class ``<foo>``. ``enum Bar`` generates class ``<bar>``

* Nested types result in concatenated Dylan class names. The following protobuf
  IDL results in these three Dylan class names: ``<foo>``, ``<foo-bar>``,
  ``<foo-type>``

  .. code-block:: protobuf

     message Foo {
       message Bar { ... }
       enum Type { ... }
     }

* Field names are the concatenation of the message name and the field, with the
  usual conversion to lowercase-with-hyphens:

  .. code-block:: protobuf

     message Person {
       optional string name = 1;
       message Address {
         optional string street1 = 1;
       }
     }

  The Dylan slot name for the ``name`` field is ``person-name``.
  The Dylan slot name for the ``street1`` field is ``person-address-street1``.

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

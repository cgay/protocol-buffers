Module: protocol-buffers-impl
Synopsis: Invoke the parser on a set of files and then
          Generate Dylan code from the parse tree.


// TODO (extremely incomplete list):
//
// * The package decl may appear anywhere in the file except before the syntax
//   decl. Test that this works.
//
// * There is no way to detect whether a bool field is set. See dylan-slot-type.

// Emit code for an object. Each emit method should end its output with \n.  Some methods
// accept dylan-parent: and/or proto-parent: keyword arguments. Both represent the name
// of the entity being emitted, but one is the Dylan name for it (without any adornments
// like "$" or "<...>") and the other is the fully-qualified protobuf name for it.
define generic emit-code
    (gen :: <generator>, object :: <protocol-buffer-object>, #key, #all-keys)
 => (#rest values);


// I kind of prefer ".pb.dylan", for unexplainable aesthetic reasons, but
// https://github.com/dylan-lang/opendylan/issues/1529 needs fixing first.
define constant $generated-file-suffix :: <string> = "-pb.dylan";
define constant $generated-module-suffix :: <string> = "-module-pb.dylan";
define constant $generated-library-suffix :: <string> = "-library-pb.dylan";


// Callers should normally supply two different file streams.
define class <generator> (<object>)
  constant slot generator-input-files :: <seq>,
    required-init-keyword: input-files:;
  constant slot generator-output-directory :: <directory-locator>,
    required-init-keyword: output-directory:;

  // If `library-name` is provided, then also output a library
  // definition. The library is optional so that Dylan protobuf code can be
  // compiled directly into another library.
  constant slot generator-library-name :: false-or(<string>) = #f,
    init-keyword: library-name:;

  // Maps Dylan module names to sequences of exported names.
  constant slot exported-names :: <string-table>
    = make(<string-table>);
  // Dylan module name to proto package name.
  constant slot module-to-package = make(<string-table>);

  // Keeps track of parsed files.
  constant slot generator-file-set :: <file-descriptor-set>
    = make(<file-descriptor-set>,
           file: make(<stretchy-vector>));

  // Maps from AST nodes (descriptors) to sequences of <comment-token> which
  // are the comments that precede the descriptor in the .proto file.
  constant slot attached-comments :: <object-table> = make(<table>);
end class;

define function app-name ()
  locator-name(as(<file-locator>, application-filename()))
end function;

// Exported
//
// Generate Dylan code based on the given generator configuration. In general,
// for each input file foo.proto writes foo-pb.dylan, plus for each package a
// {pkg}-module-pb.dylan for each distinct protobuf package.
//
// Values:
//   dylan-files: sequence of locators for generated Dylan code.
//   lid-file: locator for generated LID file, #f if no library file generated.
define function generate-dylan-code
    (gen :: <generator>)
 => (dylan-files :: <seq>, lid-file :: false-or(<file-locator>))
  let file-set = gen.generator-file-set;
  for (file in gen.generator-input-files)
    let (descriptor, comments-map) = parse-file(file);
    add!(file-descriptor-set-file(file-set), descriptor);
    // Copy descriptor-attached comments from parser to generator.
    for (tokens :: <seq> keyed-by desc in comments-map)
      gen.attached-comments[desc] := tokens;
    end;
  end;
  let output-files :: <list> = emit-code(gen, file-set);
  let library-name = gen.generator-library-name;
  let lid-file = #f;
  if (library-name)
    let output-dir = gen.generator-output-directory;
    let library-file
      = file-locator(output-dir, concat(library-name, $generated-library-suffix));
    with-open-file (stream = library-file,
                    direction: #"output",
                    if-exists: #"replace")
      let module-names = key-sequence(gen.exported-names);
      format(stream, $library-template, library-name, library-name,
             join(module-names, ",\n         "));
    end;
    output-files := pair(library-file, output-files);
    // TODO: output should be conditional. not all callers will want it.
    format-out("%s wrote %s\n", app-name(), library-file);
    force-out();

    lid-file := file-locator(output-dir, concat(library-name, ".lid"));
    with-open-file (stream = lid-file,
                    direction: #"output",
                    if-exists: #"replace")
      format(stream, "Library: %s\nFiles: %s\n",
             library-name,
             join(output-files, "\n       ", key: curry(as, <string>)));
    end;
    format-out("%s wrote %s\n", app-name(), lid-file);
    force-out();
  end;
  values(output-files, lid-file)
end function;

define function code
    (gen :: <generator>, format-string :: <string>, #rest args)
  apply(format, *code-stream*, format-string, args);
  force-output(*code-stream*);
end function;

define function emit-comments
    (gen :: <generator>, descriptor :: <protocol-buffer-object>,
     #key indent :: <string> = "")
  for (token in element(gen.attached-comments, descriptor, default: #[]))
    assert(instance?(token, <comment-token>),
           "token %= attached to %= is not a <comment-token>", token, descriptor);
    code(gen, sformat("%s%s\n", indent, token.token-text));
  end;
end function;

define function export (gen :: <generator>, name :: <string>)
  let names = element(gen.exported-names, *current-module*,
                      default: #f);
  if (~names)
    names := make(<stretchy-vector>);
    gen.exported-names[*current-module*] := names;
  end;
  add-new!(names, name, test: \=);
end function;



define method emit-code
    (gen :: <generator>, file-set :: <file-descriptor-set>, #key)
 => (output-files :: <seq>)
  // Emitting each file writes the -pb.dylan file directly, but also stores in
  // gen any names that should be exported. This way files that are in the same
  // protobuf "package" can later be emitted into a single -module-pb.dylan
  // file.

  // Output files must be returned in the order in which they should be added
  // to the Open Dylan project that contains the .spec file listing the .proto
  // inputs. Module files first, then the main generated code files.
  let output-files = #();
  for (file in file-set.file-descriptor-set-file)
    let output-file = emit-code(gen, file);
    output-files := pair(output-file, output-files);
  end;
  for (names keyed-by module-name in gen.exported-names)
    let output-file = emit-module-file(gen, module-name, names);
    output-files := pair(output-file, output-files);
  end;
  output-files
end method;

define function emit-module-file
    (gen :: <generator>, module-name :: <string>, names :: <seq>)
 => (locator :: <file-locator>)
  let output-dir = gen.generator-output-directory;
  let module-file
    = file-locator(output-dir, concat(module-name, $generated-module-suffix));
  with-open-file (stream = module-file,
                  direction: #"output",
                  if-exists: #"replace")
    format(stream, $module-template,
           gen.module-to-package[module-name],
           module-name,
           join(map(curry(concat, "    "),
                    names),
                ",\n"),
           module-name);
  end;
  format-out("%s wrote %s\n", app-name(), module-file);
  force-out();
  module-file
end function;


// The current file being processed, for looking up qualified names.
define thread variable *file-descriptor-proto* :: false-or(<file-descriptor-proto>) = #f;
define thread variable *code-stream* :: false-or(<stream>) = #f;
define thread variable *current-module* :: false-or(<string>) = #f;

define method emit-code
    (gen :: <generator>, file :: <file-descriptor-proto>, #key)
 => (locator :: <file-locator>)
  let output-dir = gen.generator-output-directory;
  let absfile = as(<file-locator>, file.file-descriptor-proto-name);
  let output-file = file-locator(output-dir,
                                 concat(locator-base(absfile),
                                        $generated-file-suffix));
  with-open-file (stream = output-file,
                  direction: #"output",
                  if-exists: #"replace")
    dynamic-bind (*current-module* = #f,
                  *code-stream* = stream,
                  *file-descriptor-proto* = file)
      code(gen,
           """
           Module: %s

           // *** This file was auto-generated by pbgen. ***
           //     Source: %s
           //     Date: %s


           """,
           dylan-module-name(gen, file),
           file.file-descriptor-proto-name,
           as-iso8601-string(current-date()));
      emit-comments(gen, file);
      for (enum in file.file-descriptor-proto-enum-type | #[])
        emit-code(gen, enum);
      end;
      for (message in file.file-descriptor-proto-message-type | #[])
        emit-code(gen, message);
      end;

      code(gen, """
           //
           // Introspection
           //


           """);
      // Introspection code must be emitted last so that it doesn't make illegal
      // forward reference to constants from enum's nested inside messages.
      let package-name = file.file-descriptor-proto-package;
      for (enum in file.file-descriptor-proto-enum-type | #[])
        emit-introspection-code(gen, enum, proto-parent: package-name);
      end;
      for (message in file-descriptor-proto-message-type(file) | #[])
        emit-introspection-code(gen, message, proto-parent: package-name);
      end;
    end dynamic-bind;
  end with-open-file;
  format-out("%s wrote %s\n", app-name(), output-file);
  force-out();
  output-file
end method;

// `parent` is provided if this is a nested message.
define method emit-code (gen :: <generator>, message :: <descriptor-proto>, #key parent)
  let camel-name = descriptor-proto-name(message);
  let full-name = dylan-name(camel-name, parent: parent);
  let class-name = concat("<", full-name, ">");

  // message class definition
  export(gen, class-name);
  emit-comments(gen, message);
  let after-class-def = make(<stretchy-vector>);
  code(gen,
       """
       define class %s (<protocol-buffer-message>)

       """, class-name);
  for (field in descriptor-proto-field(message) | #[])
    let thunk = emit-code(gen, field, message: message, parent: full-name);
    if (thunk)
      add!(after-class-def, thunk);
    end;
  end;
  code(gen,
       """
       end class %s;


       """, class-name);
  for (thunk in after-class-def)
    thunk()
  end;

  for (enum in descriptor-proto-enum-type(message) | #[])
    emit-code(gen, enum, parent: full-name);
  end;
  for (message in descriptor-proto-nested-type(message) | #[])
    emit-code(gen, message, parent: full-name);
  end;
  for (oneof in descriptor-proto-oneof-decl(message) | #[])
    emit-code(gen, oneof, parent: full-name);
  end;
end method;

define method emit-introspection-code
    (gen :: <generator>, enum :: <enum-descriptor-proto>,
     #key proto-parent :: false-or(<string>),
          dylan-parent :: false-or(<string>))
  let camel-name = enum.enum-descriptor-proto-name;
  let proto-name = iff(proto-parent,
                       concat(proto-parent, ".", camel-name),
                       camel-name); // No package declaration.
  let dylan-full-name = dylan-name(camel-name, parent: dylan-parent);
  let dylan-class-name = concat("<", dylan-full-name, ">");
  // We define a function and then call it, rather than just emit a begin/end block, to
  // get a better backtrace on error.
  let function-name = concat("initialize-", dylan-class-name);
  // TODO: set the options, reserved_range, and reserved_name fields
  code(gen, """
       define not-inline function %s ()
         let values = make(<stretchy-vector>);
         let e = make(<enum-descriptor-proto>,
                      name: %=,
                      value: values);
         store(%=, e, %s);

       """,
       function-name, camel-name, proto-name, dylan-class-name);
  for (value in enum.enum-descriptor-proto-value | #[])
    // TODO: set the options field
    let local-name = value.enum-value-descriptor-proto-name;
    let const-name = concat("$", dylan-name(local-name, parent: dylan-full-name));
    let proto-name = concat(proto-name, ".", local-name);
    code(gen,
         """
           let v = make(<enum-value-descriptor-proto>,
                        name: %=,
                        number: %d);
           add!(values, v);
           store(%=, v, %s);

         """,
         local-name, value.enum-value-descriptor-proto-number, proto-name, const-name);
  end;
  code(gen,
       """
       end function %s;
       %s();


       """,
       function-name, function-name);
end method;

define method emit-introspection-code
    (gen :: <generator>, message :: <descriptor-proto>,
     #key proto-parent :: false-or(<string>),
          dylan-parent :: false-or(<string>))
  let camel-name = message.descriptor-proto-name;
  let proto-name = iff(proto-parent,
                       concat(proto-parent, ".", camel-name),
                       camel-name); // No package declaration.
  let dylan-full-name = dylan-name(camel-name, parent: dylan-parent);
  let dylan-class-name = concat("<", dylan-full-name, ">");

  // Depth first
  for (enum in message.descriptor-proto-enum-type | #[])
    emit-introspection-code(gen, enum,
                            proto-parent: proto-name,
                            dylan-parent: dylan-full-name);
  end;
  for (msg in message.descriptor-proto-nested-type | #[])
    emit-introspection-code(gen, msg,
                            proto-parent: proto-name,
                            dylan-parent: dylan-full-name);
  end;

  // We define a function and then call it, rather than just emit a begin/end block, on
  // the theory that if an error occurs we'll get a better backtrace.
  let function-name = concat("initialize-", dylan-class-name);
  code(gen,
       """
       define not-inline function %s ()
         let fields = make(<stretchy-vector>);
         let m = make(<descriptor-proto>,
                      name: %=,
                      field: fields);
         store(%=, m, %s);

       """,
       function-name, camel-name, proto-name, dylan-class-name);
  // TODO: the rest of the message fields, e.g. nested types
  for (field in message.descriptor-proto-field,
       i from 0)
    let field-name = field.field-descriptor-proto-name;
    let getter = dylan-name(field-name, parent: dylan-full-name);
    let optvar = sformat("f%dopt", i);
    let field-proto-name = concat(proto-name, ".", field-name);
    let (label, adder)
      = select (field.field-descriptor-proto-label)
          $field-descriptor-proto-label-label-repeated
            => values("$field-descriptor-proto-label-label-repeated",
                      sformat("add-%s", getter));
          $field-descriptor-proto-label-label-optional
            => values("$field-descriptor-proto-label-label-optional", "#f");
          $field-descriptor-proto-label-label-required
            => values("$field-descriptor-proto-label-label-required", "#f");
          otherwise => "#f";
        end;
    code(gen,
         """
           let %s = make(<field-options>); // TODO: ...set field options...
           let f
             = make(<field-descriptor-proto>,
                    name: %=,
                    number: %d,
                    label: %s,
                    type: %s,
                    type-name: %=,
                    extendee: %=,
                    default-value: %=,
                    oneof-index: %=,
                    json-name: %=,
                    proto3-optional: %=,
                    options: %s);
           add!(fields, f);
           store(%=, f, %s, %s-setter, %s);

         """,
         optvar,
         field.field-descriptor-proto-name,
         field.field-descriptor-proto-number,
         label,
         field.field-descriptor-proto-type,  // fixme
         field.field-descriptor-proto-type-name,
         field.field-descriptor-proto-extendee,
         field.field-descriptor-proto-default-value,
         field.field-descriptor-proto-oneof-index,
         field.field-descriptor-proto-json-name, // fixme camelCasify
         field.field-descriptor-proto-proto3-optional,
         optvar, field-proto-name, getter, getter,
         adder);
  end for;
  code(gen, """
       end function %s;
       %s();


       """, function-name, function-name);
end method emit-introspection-code;

define method emit-code
    (gen :: <generator>, field :: <field-descriptor-proto>,
     #key message :: <descriptor-proto>,
          parent :: <string>)
  let camel-name = field.field-descriptor-proto-name;
  let init-keyword = dylan-name(camel-name);
  let getter = dylan-name(camel-name, parent: parent);
  let (dylan-type-name :: <string>,
       default-for-type :: <string>,
       base-type)
    = dylan-slot-type(*file-descriptor-proto*, message, field);
  export(gen, getter);
  export(gen, concat(getter, "-setter"));
  emit-comments(gen, field, indent: "  ");
  code(gen,
       """
         slot %s :: %s,
           init-value: %s,
           init-keyword: %s:;

       """,
       getter, dylan-type-name, default-for-type, init-keyword);
  if (field.field-descriptor-proto-label == $field-descriptor-proto-label-label-repeated)
    // Repeated fields get an add-* method.
    method ()
      export(gen, concat("add-", getter));
      code(gen,
           """
           define method add-%s
               (msg :: <%s>, new :: %s) => (new :: %s)
             let v = msg.%s;
             if (~v)
               v := make(<stretchy-vector>);
               msg.%s := v;
             end;
             add!(v, new);
             new
           end method add-%s;


           """,
           getter, parent, base-type, base-type, getter,
           getter, getter);
    end
  end
end method;

define method emit-code (gen :: <generator>, enum :: <enum-descriptor-proto>, #key parent)
  let camel-name = enum-descriptor-proto-name(enum);
  let local-name = dylan-name(camel-name);
  let full-name = dylan-name(camel-name, parent: parent);
  let class-name = concat("<", full-name, ">");
  export(gen, class-name);
  emit-comments(gen, enum);
  // No need to export -name or -value accessors because the API is to call
  // enum-value and enum-value-name on the value constants, and they're
  // inherited from the superclass.
  code(gen,
       """
       define class %s (<protocol-buffer-enum>) end;


       """, class-name);
  for (enum-value in enum-descriptor-proto-value(enum) | #[])
    emit-code(gen, enum-value, parent: full-name)
  end;
  code(gen, "\n");
end method;

define method emit-code (gen :: <generator>, enum-value :: <enum-value-descriptor-proto>,
                         #key parent :: <string>)
  let camel-name = enum-value-descriptor-proto-name(enum-value);
  let constant-name = concat("$", dylan-name(camel-name, parent: parent));
  let value = enum-value-descriptor-proto-number(enum-value);
  export(gen, constant-name);
  emit-comments(gen, enum-value);
  code(gen,
       """
       define constant %s :: <%s>
         = make(<%s>,
                name: %=,
                value: %d);

       """,
       constant-name, parent, parent, camel-name, value);
end method;

define method emit-code (gen :: <generator>, oneof :: <oneof-descriptor-proto>,
                         #key parent)
  emit-comments(gen, oneof);
  // TODO
  let name = dylan-name(oneof-descriptor-proto-name(oneof), parent: parent);
end method;

define constant $library-template
  = """
    Module: dylan-user
    Synopsis: Library definition generated from .proto files by pbgen.

    define library %s
      use common-dylan;
      use protocol-buffers;

      export %s;
    end library %s;

    """;

define constant $module-template
  = """
    Module: dylan-user
    Synopsis: Code generated for package %= by pbgen.

    define module %s
      use common-dylan;
      use protocol-buffers;

      export
    %s;
    end module %s;

    """;

define function dylan-module-name
    (gen :: <generator>, file :: <file-descriptor-proto>)
 => (name :: <string>)
  *current-module*
    | begin
        let package = file-descriptor-proto-package(file);
        let module-name
          = if (package)
              map(method (ch)
                    iff((ch == '.' | ch == '_'), '-', ch)
                  end,
                  package)
            else
              locator-base(as(<file-locator>,
                              file-descriptor-proto-name(file)))
            end;
        gen.module-to-package[module-name] := (package | module-name);
        *current-module* := module-name;
      end;
end function;

// `parent` should already have been run through camel-to-kebob.
define function dylan-name
    (camel :: <string>, #key parent) => (dylan-name :: <string>)
  let kebob = camel-to-kebob(camel);
  iff(parent, concat(parent, "-", kebob), kebob)
end function;

// `parent` should already have been run through camel-to-kebob.
define function dylan-class-name
    (camel :: <string>, #key parent) => (dylan-name :: <string>)
  concat("<",
         dylan-name(camel, parent: parent),
         ">")
end function;

// Determine the Dylan slot type and default value for a proto field.
define function dylan-slot-type
    (file :: <file-descriptor-proto>, message :: <descriptor-proto>,
     field :: <field-descriptor-proto>)
 => (dylan-type :: <string>, default :: <string>, base-type :: false-or(<string>))
  let label = field-descriptor-proto-label(field);
  let camel-type = field-descriptor-proto-type-name(field);
  let syntax = file-descriptor-proto-syntax(file);
  let (type-name, default)
    = select (camel-type by \=)
        "double" => values("<double-float>", "0.0d0");
        "float"  => values("<single-float>", "0.0");
        "int32"  => values("<int32>", "0");
        "int64"  => values("<int64>", "0");
        "uint32" => values("<uint32>", "0");
        "uint64" => values("<uint64>", "0");
        "sint32" => values("<sint32>", "0");
        "sint64" => values("<sint64>", "0");
        "fixed32" => values("<fixed32>", "0");
        "fixed64" => values("<fixed64>", "0");
        "sfixed32" => values("<sfixed32>", "0");
        "sfixed64" => values("<sfixed64>", "0");
        "bool" => values("<boolean>", "#f");
        "string" => values("<string>", "");
        "bytes" => values("<byte-vector>", "make(<byte-vector>, size: 0)");
        otherwise =>
          let descriptor = name-lookup(camel-type, file, message);
          values(full-dylan-class-name(descriptor),
                 "#f");
      end select;
  if (label = $field-descriptor-proto-label-label-repeated)
    values("false-or(<stretchy-vector>)",
           "#f",
           type-name)
  else
    select (syntax by \=)
      "proto2" =>
        values(iff(camel-type = "bool",
                   "<boolean>",
                   sformat("false-or(%s)", type-name)),
               "#f",
               type-name);
      "proto3" =>
        values(type-name, default);
      otherwise =>
        pb-error("syntax %= is not yet supported", syntax);
    end select
  end
end function;

// Determine the Dylan name of the descriptor by following its path to the
// root.
define function full-dylan-class-name
    (descriptor :: <protocol-buffer-object>) => (name :: <string>)
  iterate loop (desc = descriptor, names = #())
    if (desc)
      loop(desc.descriptor-parent,
           pair(desc.descriptor-name, names))
    else
      let name = join(names, "-", key: dylan-name);
      select (descriptor by instance?)
        <descriptor-proto>,
        <enum-descriptor-proto> =>
          concat("<", name, ">");
        otherwise =>
          name;
      end
    end
  end
end function;

// Given the (possibly qualified) name of a message or enum, find its Dylan
// name by traversing the AST based on the components of its name to verify
// that it refers to a valid object. A leading dot (.Foo.Bar.baz) is fully
// qualified and the search starts with `file`. Otherwise the search is
// relative and starts with `message` (where the reference occured) but also
// with fall-back to `file`. Return the Dylan class name. If not found, signal
// an error.
define function name-lookup
    (camel-type :: <string>, file :: <file-descriptor-proto>,
     message :: <descriptor-proto>)
 => (descriptor :: <protocol-buffer-object>)
  let absolute? = camel-type[0] == '.';
  let names = split(camel-type, '.', start: iff(absolute?, 1, 0));
  if (absolute?)
    lookup(camel-type, names, file)
  else
    lookup(camel-type, names, message)
      | lookup(camel-type, names, file)
  end
  | pb-error("invalid name %=: object not found", camel-type)
end function;

define function lookup
    (orig :: <string>, names :: <seq>, root :: <protocol-buffer-object>)
 => (descriptor :: false-or(<protocol-buffer-object>))
  iterate loop (i = 0, descriptor = root)
    if (i >= names.size)
      descriptor
    else
      let name = names[i];
      // Look for name in descriptor's messages...
      let messages = iff(instance?(descriptor, <file-descriptor-proto>),
                         descriptor.file-descriptor-proto-message-type,
                         descriptor.descriptor-proto-nested-type);
      let pos
        = messages & position(messages, name,
                              test: method (name, msg)
                                      descriptor-proto-name(msg) = name
                                    end);
      let message = pos & messages[pos];
      if (message)
        loop(i + 1, message)
      else
        // Current name component doesn't match a nested message at this depth
        // so check for a matching enum.
        let enums = iff(instance?(descriptor, <file-descriptor-proto>),
                        descriptor.file-descriptor-proto-enum-type,
                        descriptor.descriptor-proto-enum-type);
        let pos
          = enums & position(enums, name,
                             test: method (name, enum)
                                     enum-descriptor-proto-name(enum) = name
                                   end);
        pos & enums[pos]
      end
    end if
  end iterate
end function;

// Convert `camel` from CamelCase to kebob-case.
//
//   camel-to-kebob("CamelCase")            => "camel-case"
//   camel-to-kebob("TCPConnection")        => "tcp-connection"
//   camel-to-kebob("NewTCPConnection")     => "new-tcp-connection"
//   camel-to-kebob("new_RPC_DylanService") => "new-rpc-dylan-service"
//   camel-to-kebob("RPC_DylanService_get_request") => "rpc-dylan-service-get-request"
//   camel-to-kebob("TCP2Name3")            => "tcp2-name3"
//
// Caller is responsible for adding decorations such as "<" and ">" for class
// names.  Note that this function is not reversible, i.e., it is lossy
// w.r.t. the original name.
define function camel-to-kebob (camel :: <string>) => (kebob :: <string>)
  let len = camel.size;
  if (len == 0)
    ""
  else
    iterate loop (i = 1,
                  state = #"start",
                  chars = list(as-lowercase(camel[0])))
      if (i >= len)
        as(<string>, reverse!(chars))
      else
        let ch = camel[i];
        case
          // TODO: after upgrading to strings@2.0 remove calls to alphabetic?.
          alphabetic?(ch) & uppercase?(ch) =>
            loop(i + 1, #"upper",
                 select (state)
                   #"upper" =>
                     // TCPConnection => tcp-connection
                     iff((i + 1 < len) & alphabetic?(camel[i + 1]) & lowercase?(camel[i + 1]),
                         pair(as-lowercase(ch), pair('-', chars)),
                         pair(as-lowercase(ch), chars));
                   #"lower" =>
                     pair(as-lowercase(ch), pair('-', chars));
                   otherwise =>
                     pair(as-lowercase(ch), chars);
                 end);
          // TODO: after upgrading to strings@2.0 combine these two clauses
          // into one using alphanumeric?.
          alphabetic?(ch) & lowercase?(ch) =>
            loop(i + 1, #"lower", pair(ch, chars));
          decimal-digit?(ch) =>
            loop(i + 1, #"lower", pair(ch, chars));
          ch == '-' | ch == '_' =>
            loop(i + 1, #"start", pair('-', chars));
          ch == '.' =>
            loop(i + 1, #"start", pair('.', chars));
          otherwise =>
            pb-error("invalid name character: %=", ch);
        end case
      end if
    end iterate
  end
end function camel-to-kebob;

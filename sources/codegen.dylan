Module: protocol-buffers-impl
Synopsis: Invoke the parser on a set of files and then
          Generate Dylan code from the parse tree.


// TODO:
//
// * output the proto IDL name at the beginning and end of the Dylan code for it.
// * output the proto IDL comments in the appropriate place.
// * The package decl may appear anywhere in the file except before the syntax
//   decl. Test that this works.

// I kind of prefer ".pb.dylan", for unexplainable aesthetic reasons, but
// https://github.com/dylan-lang/opendylan/issues/1529 needs fixing first.
define constant $generated-file-suffix :: <string> = "-pb.dylan";
define constant $generated-module-suffix :: <string> = "-module-pb.dylan";


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
end class;

// Exported
define function generate-dylan-code
    (gen :: <generator>, #key)
  let file-set = gen.generator-file-set;
  for (file in gen.generator-input-files)
    let descriptor = parse-file(gen, file);
    add!(file-descriptor-set-file(file-set), descriptor);
  end;
  emit(gen, file-set);
  let library-name = gen.generator-library-name;
  if (library-name)
    let output-dir = gen.generator-output-directory;
    let library-file = file-locator(output-dir, library-name);
    with-open-file (stream = library-file,
                    direction: #"output",
                    if-exists: #"replace")
      format(stream, $library-template, library-name, library-name);
    end;
  end;
end function;

define function parse-file
    (gen :: <generator>, file :: <file-locator>)
 => (descriptor :: <file-descriptor-proto>)
  with-open-file (in-stream = file, direction: #"input")
    let descriptor
      = make(<file-descriptor-proto>, name: as(<string>, file));
    let lexer = make(<lexer>, stream: in-stream);
    parse-file-stream(make(<parser>, lexer: lexer),
                      descriptor);
    descriptor
  end
end function;

// Emit code for an object. Each emit method should end its output with \n.
// Note that some methods accept a parent: keyword argument. It should
// be the fully-qualified Dylan name of the parent, without any adornments
// like "$" or "<...>".
define generic emit
    (gen :: <generator>, object :: <protocol-buffer-object>, #key, #all-keys);

define function code
    (gen :: <generator>, format-string :: <string>, #rest args)
  apply(format, *code-stream*, format-string, args);
  force-output(*code-stream*);
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



define method emit
    (gen :: <generator>, file-set :: <file-descriptor-set>, #key)
  // Emitting each file writes the -pb.dylan file directly, but also stores in
  // gen any names that should be exported. This way files that are in the same
  // protobuf "package" can later be emitted into a single -module-pb.dylan
  // file.
  for (file in file-set.file-descriptor-set-file)
    emit(gen, file)
  end;
  for (names keyed-by module-name in gen.exported-names)
    emit-module-file(gen, module-name, names);
  end;
end method;

define function emit-module-file
    (gen :: <generator>, module-name :: <string>, names :: <seq>)
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
end function;


// The current file being processed, for looking up qualified names.
define thread variable *file-descriptor-proto* :: false-or(<file-descriptor-proto>) = #f;
define thread variable *code-stream* :: false-or(<stream>) = #f;
define thread variable *current-module* :: false-or(<string>) = #f;

define method emit (gen :: <generator>, file :: <file-descriptor-proto>, #key)
  debug("emit(<generator>, <file-descriptor-proto>) %=", file.file-descriptor-proto-name);
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
      code(gen, "Module: %s\n\n", dylan-module-name(gen, file));
      for (enum in file-descriptor-proto-enum-type(file) | #[])
        emit(gen, enum);
      end;
      for (message in file-descriptor-proto-message-type(file) | #[])
        emit(gen, message);
      end;
    end dynamic-bind;
  end with-open-file;
end method;

// `parent` is provided if this is a nested message.
define method emit (gen :: <generator>, message :: <descriptor-proto>,
                    #key parent)
  debug("emit(<generator>, <descriptor-proto>, parent: %=) %=", parent, message.descriptor-proto-name);
  let camel-name = descriptor-proto-name(message);
  let full-name = dylan-name(camel-name, parent: parent);
  let class-name = concat("<", full-name, ">");

  // message class definition
  export(gen, class-name);
  code(gen, "define class %s (<protocol-buffer-message>)\n", class-name);
  for (field in descriptor-proto-field(message) | #[])
    emit(gen, field, message: message, message-name: full-name);
  end;
  code(gen, "end class %s;\n\n", class-name);

  for (enum in descriptor-proto-enum-type(message) | #[])
    emit(gen, enum, parent: full-name);
  end;
  for (message in descriptor-proto-nested-type(message) | #[])
    emit(gen, message, parent: full-name);
  end;
  for (oneof in descriptor-proto-oneof-decl(message) | #[])
    emit(gen, oneof, parent: full-name);
  end;
end method;

define method emit (gen :: <generator>, field :: <field-descriptor-proto>,
                    #key message :: <descriptor-proto>, message-name :: <string>)
  debug("emit(<generator>, <field-descriptor-proto>, message-name: %=) %=",
        message-name, field.field-descriptor-proto-name);
  let camel-name = field-descriptor-proto-name(field);
  let local-name = dylan-name(camel-name);
  let getter = dylan-name(camel-name, parent: message-name);
  let (dylan-type-name :: <string>,
       default-for-type :: <string>)
    = dylan-slot-type(*file-descriptor-proto*, message, field);
  debug("<= dylan-slot-type: %=, default-for-type: %=", dylan-type-name, default-for-type);
  export(gen, getter);
  export(gen, concat(getter, "-setter"));
  code(gen, """  slot %s :: %s,
    init-value: %s,
    init-keyword: %s:;\n""",
       getter, dylan-type-name, default-for-type, local-name);
end method;

define method emit (gen :: <generator>, enum :: <enum-descriptor-proto>,
                    #key parent)
  debug("emit(<generator>, <enum-descriptor-proto>, parent: %=) %=", parent, enum.enum-descriptor-proto-name);
  let camel-name = enum-descriptor-proto-name(enum);
  let local-name = dylan-name(camel-name);
  let full-name = dylan-name(camel-name, parent: parent);
  let class-name = concat("<", full-name, ">");
  export(gen, class-name);
  // No need to export -name or -value accessors because the API is to call
  // enum-value and enum-value-name on the value constants, and they're
  // inherited from the superclass.
  code(gen, "define class %s (<protocol-buffer-enum>) end;\n\n", class-name);
  for (enum-value in enum-descriptor-proto-value(enum) | #[])
    emit(gen, enum-value, parent: full-name)
  end;
  code(gen, "\n");
end method;

define method emit
    (gen :: <generator>, enum-value :: <enum-value-descriptor-proto>,
     #key parent :: <string>)
  debug("emit(<generator>, <enum-value-descriptor-proto>, parent: %=) %=", parent, enum-value.enum-value-descriptor-proto-name);
  let camel-name = enum-value-descriptor-proto-name(enum-value);
  let constant-name = concat("$", dylan-name(camel-name, parent: parent));
  let value = enum-value-descriptor-proto-number(enum-value);
  export(gen, constant-name);
  code(gen, """define constant %s :: <%s>
  = make(<%s>,
         name: %=,
         value: %d);
""",
       constant-name, parent, parent, camel-name, value);
end method;

define method emit (gen :: <generator>, oneof :: <oneof-descriptor-proto>,
                    #key parent)
  debug("emit(<generator>, <oneof-descriptor-proto>, parent: %=) %=", parent, oneof.oneof-descriptor-proto-name);
  let name = dylan-name(oneof-descriptor-proto-name(oneof), parent: parent);
end method;

define constant $library-template
  = """Module: dylan-user
Synopsis: Library definition generated from .proto files by pbgen.

define library %s
  use common-dylan;
  use protocol-buffers;
end library %s;
""";

define constant $module-template
  = """Module: dylan-user
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
 => (dylan-type :: <string>, default :: <string>)
  let label = field-descriptor-proto-label(field);
  let camel-type = field-descriptor-proto-type-name(field);
  let syntax = file-descriptor-proto-syntax(file);
  debug("=> dylan-slot-type(%=, %=, %=, file, %=)",
        syntax, label, camel-type, descriptor-proto-name(message));
  if (label = $field-descriptor-proto-label-label-repeated)
    values("false-or(<stretchy-vector>)", "#f")
  else
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
    if (syntax = "proto2")
      // TODO: for now there is no way to detect whether a bool field is set.
      values(iff(camel-type = "bool",
                 "<boolean>",
                 iff(type-name = "<object>",
                     type-name,
                     sformat("false-or(%s)", type-name))),
             "#f")
    else
      values(type-name, default)
    end
  end
end function;

// Determine the Dylan name of the descriptor by following its path to the
// root. I
define function full-dylan-class-name
    (descriptor :: <protocol-buffer-object>) => (name :: <string>)
  iterate loop (desc = descriptor, names = #())
    debug("full-dylan-class-name: desc: %=, names: %=", desc, names);
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
    debug("lookup: loop(%d, %s)", i, descriptor);
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
                                      debug("name: %=, msg: %=", name, msg);
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
                                     debug("name: %=, msg: %=", name, enum);
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

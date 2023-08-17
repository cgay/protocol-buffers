Module: protocol-buffers-impl
Synopsis: Generate Dylan code from a protobuf IDL parse tree


// TODO:
//
// * output the proto IDL name at the beginning and end of the Dylan code for it.
// * output the proto IDL comments in the appropriate place.

// Callers should normally supply two different file streams.
define class <generator> (<object>)
  constant slot module-stream :: <stream> = *standard-output*,
    init-keyword: module-stream:;
  constant slot code-stream :: <stream> = *standard-output*,
    init-keyword: code-stream:;
  constant slot exported-names :: <stretchy-vector> = make(<stretchy-vector>);

  // If `library-name` is provided, then also output a library
  // definition. The library is optional so that Dylan protobuf code can be
  // compiled directly into another library.
  constant slot library-name :: false-or(<string>) = #f,
    init-keyword: library-name:;
  constant slot module-name :: false-or(<string>) = #f,
    init-keyword: module-name:;
end class;

// Exported
define function generate-dylan-code
    (gen :: <generator>, file :: <file-descriptor-proto>, #key)
  emit(gen, file);
end function;

// Emit code for an object. Each emit method should end its output with \n.
// Note that many methods accept a parent: keyword argument. It should
// be the fully-qualified Dylan name of the parent, without any adornments
// like "$" or "<...>".
define generic emit
    (gen :: <generator>, object :: <protocol-buffer-object>, #key, #all-keys);

define function code (gen :: <generator>, format-string :: <string>, #rest args)
  apply(format, gen.code-stream, format-string, args);
  force-output(gen.code-stream);
end function;

define function export (gen :: <generator>, name :: <string>)
  add-new!(gen.exported-names, name, test: \=);
end function;



define method emit
    (gen :: <generator>, file-set :: <file-descriptor-set>, #key)
  // TODO
  error("file sets not yet implemented");
end method;

define method emit (gen :: <generator>, file :: <file-descriptor-proto>, #key)
  debug("emit(<generator>, <file-descriptor-proto>)");
  code(gen, "Module: %s\n\n", dylan-module-name(gen, file));
  for (enum in file-descriptor-proto-enum-type(file) | #[])
    emit(gen, enum);
  end;
  for (message in file-descriptor-proto-message-type(file) | #[])
    emit(gen, message);
  end;
  emit-module-definition(gen, file);
end method;

define method emit (gen :: <generator>, message :: <descriptor-proto>,
                    #key parent)
  debug("emit(<generator>, <descriptor-proto>, parent: %=)", parent);
  let camel-name = descriptor-proto-name(message);
  let local-name = dylan-name(camel-name);
  let full-name = dylan-name(camel-name, parent: parent);
  let class-name = concat("<", full-name, ">");

  // message class definition
  export(gen, class-name);
  code(gen, "define class %s (<protocol-buffer-message>)\n", class-name);
  for (field in descriptor-proto-field(message) | #[])
    emit(gen, field, parent: full-name)
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
                    #key parent :: <string>)
  debug("emit(<generator>, <field-descriptor-proto>, parent: %=)", parent);
  let camel-name = field-descriptor-proto-name(field);
  let field-name = dylan-name(camel-name);
  let getter = dylan-name(camel-name, parent: parent);
  let slot-type = "<object>";
  // TODO: type field not filled in by parser yet.
  //    = dylan-type-name(field-descriptor-proto-type(field), parent: parent);
  //debug("field-descriptor-proto-type(field) => %=", field-descriptor-proto-type(field));
  export(gen, getter);
  export(gen, concat(getter, "-setter"));
  code(gen, """  slot %s :: %s,
    init-value: #f,
    init-keyword: %s:;\n""",
       getter, slot-type, field-name);
end method;

define method emit (gen :: <generator>, enum :: <enum-descriptor-proto>,
                    #key parent)
  debug("emit(<generator>, <enum-descriptor-proto>, parent: %=)", parent);
  let camel-name = enum-descriptor-proto-name(enum);
  let local-name = dylan-name(camel-name);
  let full-name = dylan-name(camel-name, parent: parent);
  let class-name = concat("<", full-name, ">");
  export(gen, class-name);
  // No need to export -name or -value accessors because the API is to call
  // enum-value and enum-value-name on the value constants, and they're
  // inherited from the superclass.
  code(gen, "define class %s (<protocol-buffer-enum>) end;\n\n", class-name);
  for (enum-value in enum-descriptor-proto-value(enum))
    debug("about to emit enum-value: %=", enum-value-descriptor-proto-name(enum-value));
    emit(gen, enum-value, parent: full-name)
  end;
  code(gen, "\n");
end method;

define method emit (gen :: <generator>, enum-value :: <enum-value-descriptor-proto>,
                    #key parent :: <string>)
  debug("emit(<generator>, <enum-value-descriptor-proto>, parent: %=)", parent);
  let camel-name = enum-value-descriptor-proto-name(enum-value);
  let constant-name = concat("$", dylan-name(camel-name, parent: parent));
  let value-type-name = "<object>"; // TODO
  let value = enum-value-descriptor-proto-number(enum-value);
  export(gen, constant-name);
  code(gen, """define constant %s :: %s
  = make(<%s>,
         name: %=,
         value: %d);
""",
       constant-name, value-type-name, parent, camel-name, value);
end method;

define method emit (gen :: <generator>, oneof :: <oneof-descriptor-proto>,
                    #key parent)
  debug("emit(<generator>, <oneof-descriptor-proto>, parent: %=)", parent);
  let name = dylan-name(oneof-descriptor-proto-name(oneof), parent: parent);
end method;

define function emit-module-definition
    (gen :: <generator>, file :: <file-descriptor-proto>)
  let stream = gen.module-stream;
  format(stream, $module-header);
  if (gen.library-name)
    format(stream, $library-template, gen.library-name, gen.library-name);
  end;
  let module-name = dylan-module-name(gen, file);
  format(stream, $module-template,
         module-name,
         join(map(curry(concat, "    "),
                  gen.exported-names),
              ",\n"),
         module-name);
end function;

define constant $module-header
  = """Module: dylan-user

// *** This code was automatically generated by pbgen. ***

""";

define constant $library-template
  = """define library %s
  use common-dylan;
  use protocol-buffers;
end library %s;

""";

define constant $module-template
  = """define module %s
  use common-dylan;
  use protocol-buffers;

  export
%s;
end module %s;
""";

define function dylan-module-name
    (gen :: <generator>, file :: <file-descriptor-proto>) => (name :: <string>)
  gen.module-name
    | map(method (ch)
            iff((ch == '.' | ch == '_'), '-', ch)
          end,
          file-descriptor-proto-package(file))
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
  let kebob = camel-to-kebob(camel);
  concat("<",
         iff(parent, concat(parent, "-", kebob), kebob),
         ">")
end function;

// `parent` should already have been run through camel-to-kebob.
define function dylan-type-name
    (proto-type :: <string>, #key parent) => (dylan-type :: <string>)
  select (proto-type by \=)
    "double" => "<double-float>";
    "float"  => "<single-float>";
    "int32"  => "<int32>";
    "int64"  => "<int64>";
    "uint32" => "<uint32>";
    "uint64" => "<uint64>";
    "sint32" => "<sint32>";
    "sint64" => "<sint64>";
    "fixed32" => "<fixed32>";
    "fixed64" => "<fixed64>";
    "sfixed32" => "<sfixed32>";
    "sfixed64" => "<sfixed64>";
    "bool" => "<boolean>";
    "string" => "<string>";
    "bytes" => "<byte-vector>";
    otherwise =>
      // Assume it's a derived message or enum type.
      dylan-class-name(proto-type, parent: parent)
  end select
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

Module: protocol-buffers-impl
Synopsis: Ad-hoc parser for .proto Interface Definition Language


// References used while writing this parser:
// * https://protobuf.dev/reference/protobuf/proto2-spec/
// * https://protobuf.dev/reference/protobuf/proto3-spec/
// * https://protobuf.com/docs/language-spec#character-classes
// * https://github.com/bufbuild/protocompile/blob/main/parser/

// The parser (next-token, expect-token) never sees or cares about whitespace.

// TODO: 2_147_483_646 (2^31 - 2) for message set wire format
define constant $max-field-number :: <int> = 536_870_911;

define class <parse-error> (<protocol-buffer-error>) end;

define function parse-error
    (format-string :: <string>, #rest args)
  signal(make(<parse-error>,
              format-string: format-string,
              format-arguments: args))
end function;

define class <parser> (<object>)
  constant slot %lexer :: <lexer>, required-init-keyword: lexer:;
  slot peeked-token :: false-or(<token>) = #f;

  // Maps AST nodes (<descriptor-proto> et al) to <token>s that contain
  // comments, so the comments can be carried through to generated code.
  constant slot attached-comments = make(<table>);

  // Previous non-whitespace, non-comment token. Initial use is to determine
  // whether a comment is an end-of-line comment or not, by checking whether
  // it has the same line as this token.
  slot previous-token :: false-or(<token>) = #f;
end class;

define function peek-token
    (parser :: <parser>) => (token :: false-or(<token>))
  parser.peeked-token
    | begin
        let token = read-token(parser.%lexer);
        while (instance?(token, <comment-token>))
          token := read-token(parser.%lexer);
        end;
        parser.peeked-token := token // #f when at EOF
      end
end function;

// TODO: rename to consume-token (or just peek and consume)
define function next-token
    (parser :: <parser>) => (token :: <token>)
  let token = parser.peeked-token
                | peek-token(parser)
                | parse-error("unexpected end of input encountered");
  parser.peeked-token := #f;
  parser.previous-token := token
end function;

define function unconsume-token
    (parser :: <parser>, token) => ()
  if (parser.peeked-token)
    parse-error("can't unconsume token %=, a token has already been peeked", token);
  elseif (~parser.previous-token)
    parse-error("can't unconsume token %=, there is no previous token", token);
  elseif (select (token by instance?)
            <token> => token ~== parser.previous-token;
            <string> => token ~= parser.previous-token.token-text;
          end)
    parse-error("can't unconsume token %=, not equal to previous token", token);
  else
    parser.peeked-token := token;
    parser.previous-token := #f; // could do better here
  end;
end function;

define generic expect-token
    (parser :: <parser>, token-specifier :: <object>) => (token :: <token>);

define method expect-token (parser :: <parser>, class :: <class>) => (token :: <token>)
  let token = next-token(parser);
  if (~instance?(token, class))
    parse-error("expected a token of type %= but got %=", class, token);
  end;
  token
end method;

define method expect-token (parser :: <parser>, text :: <string>) => (token :: <token>)
  expect-token(parser, list(text));
end method;

define method expect-token (parser :: <parser>, strings :: <seq>) => (token :: <token>)
  let token = next-token(parser);
  if (~member?(token.token-text, strings, test: \=))
    parse-error("expected token %s but got %=",
                join(strings, ", ",
                     key: method (s) sformat("%=", s) end,
                     conjunction: " or "),
                token);
  end;
  token
end method;


// Retrieve and discard tokens up to the next semicolon.
define function discard-statement (parser :: <parser>) => (#rest tokens)
  iterate loop (t = next-token(parser), tokens = #())
    if (t)
      if (t.token-value == ';')
        reverse!(tokens)
      else
        loop(next-token(parser), pair(t, tokens))
      end
    end
  end
end function;

define function maybe-attach-comments-to
    (parser :: <parser>, descriptor :: <protocol-buffer-object>, token :: <token>)
  if (~empty?(token.token-comments))
    let comments
      = element(parser.attached-comments, descriptor, default: #f)
          | make(<stretchy-vector>);
    add!(comments, token);
    parser.attached-comments[descriptor] := comments;
  end;
end function;

define function end-of-line-comment?
    (parser :: <parser>, token :: <token>) => (eol? :: <bool>)
  parser.previous-token
    & instance?(token, <comment-token>)
    & (parser.previous-token.token-line == token.token-line)
end function;

// Fills in the slots of `file-descriptor` based on the parse, but the
// file-descriptor-proto-name slot is the responsibility of the caller.
define function parse-file-stream
    (parser :: <parser>, file :: <file-descriptor-proto>) => ()
  iterate loop (token = next-token(parser))
    if (token)
      select (token.token-value)
        #"syntax" =>
          maybe-attach-comments-to(parser, file, token);
          expect-token(parser, "=");
          let token = expect-token(parser, list($syntax-proto2, $syntax-proto3, $syntax-editions));
          file-descriptor-proto-syntax(file)
            := token.token-text;
          expect-token(parser, ";");
        #"package" =>
          maybe-attach-comments-to(parser, file, token); // not quite right
          let package-name = parse-qualified-identifier(parser);
          file-descriptor-proto-package(file)
            := join(package-name, ".");
        #"option" =>
          maybe-attach-comments-to(parser, file, token); // not quite right
          let options = file.file-descriptor-proto-options | make(<file-options>);
          file.file-descriptor-proto-options := options;
          parse-file-option(parser, options);
        #"message" =>
          let package = file-descriptor-proto-package(file);
          let message = parse-message(parser, file, list(package), token);
          add-file-descriptor-proto-message-type(file, message);
        #"enum" =>
          add-file-descriptor-proto-enum-type(file, parse-enum(parser, #(), token));
        otherwise =>
          // Allow whitespace and comments to be ignored.
          if (~instance?(token, <comment-token>)
                & ~instance?(token, <whitespace-token>))
            parse-error("unexpected token: %s", token);
          end;
      end select;
      peek-token(parser) & loop(next-token(parser));
    end if;
  end iterate;
end function;

// The "option" token has just been consumed at file level, so consume up to
// the next semicolon and store the option value in the appropriate field in
// `options`.  "option maybe.fully.qualified.name = value ;"
define function parse-file-option
    (parser :: <parser>, options :: <file-options>) => ()
  let name-token = peek-token(parser) | next-token(parser);
  let name = name-token.token-text;
  // TODO: should be able to iterate over the fields of <file-options> rather than
  // enumerating them here. Code generator needs to emit introspection APIs.
  let setter
    = select (name by \=)
        "java_package"                  => file-options-java-package-setter;
        "java_outer_classname"          => file-options-java-outer-classname-setter;
        "java_multiple_files"           => file-options-java-multiple-files-setter;
        "java_generate_equals_and_hash" => file-options-java-generate-equals-and-hash-setter;
        "java_string_check_utf8"        => file-options-java-string-check-utf8-setter;
        "optimize_for"                  => file-options-optimize-for-setter;
        "go_package"                    => file-options-go-package-setter;
        "cc_generic_services"           => file-options-cc-generic-services-setter;
        "java_generic_services"         => file-options-java-generic-services-setter;
        "py_generic_services"           => file-options-py-generic-services-setter;
        "php_generic_services"          => file-options-php-generic-services-setter;
        "deprecated"                    => file-options-deprecated-setter;
        "cc_enable_arenas"              => file-options-cc-enable-arenas-setter;
        "objc_class_prefix"             => file-options-objc-class-prefix-setter;
        "csharp_namespace"              => file-options-csharp-namespace-setter;
        "swift_prefix"                  => file-options-swift-prefix-setter;
        "php_class_prefix"              => file-options-php-class-prefix-setter;
        "php_namespace"                 => file-options-php-namespace-setter;
        "php_metadata_namespace"        => file-options-php-metadata-namespace-setter;
        "ruby_package"                  => file-options-ruby-package-setter;
        otherwise                       => #f;
      end;
  if (setter)
    next-token(parser);         // consume peeked option name token
    expect-token(parser, "=");
    // optimize_for is the only non-primitive typed file option so handle it specially.
    // The rest we'll just treat as <object> for now, and depend on the setters to blow
    // up if the value has the wrong type. Is it possible to have user-defined
    // TODO: This will need to be more sophisticated to handle options like
    //          option (foo.bar.Message) = { a:1 b:2 c:3 };
    //       field-type(find-field(<file-descriptor-proto>, name))
    let type = iff(name = "optimize_for",
                   <file-options-optimize-mode>,
                   <object>);
    setter(parse-option-value(parser, type), options);
  else
    add-file-options-uninterpreted-option(options, parse-uninterpreted-option(parser));
  end;
  expect-token(parser, ";");
end function;

// Parse an option value and verify that it matches the expected type. If the given type
// is a protobuf enum type, then lookup the appropriate value based on the enum value
// name.
// TODO: maps, message literals....
define function parse-option-value
    (parser :: <parser>, type :: <type>) => (value, value-text :: <string>)
  let token = next-token(parser);
  let text = token.token-text;
  values(select (type by subtype?)
           <protocol-buffer-enum> =>
             instance?(token, <identifier-token>)
               | parse-error("expected an identifier: %=", token);
             enum-name-to-enum(type, text);
           <protocol-buffer-message> =>
             parse-error("message constant values are not yet implemented (%=)", token);
           otherwise =>
             let value = token.token-value;
             instance?(value, type)
               | parse-error("%= is not of the expected type, %=", token, type);
             value;
         end,
         text)
end function;

// The "message" token has just been consumed, at file level or nested in another message.
define function parse-message
    (parser :: <parser>, file :: <file-descriptor-proto>, parent-path :: <list>,
     message-token :: <token>)
 => (msg :: <descriptor-proto>)
  let name-token = next-token(parser);
  let name = name-token.token-text;
  let name-path = pair(name, parent-path);
  expect-token(parser, "{");
  let syntax = file-descriptor-proto-syntax(file);
  let message = make(<descriptor-proto>, name: name);
  register-descriptor(join(reverse(name-path), "."), message);
  block (done)
    while (#t)
      let token = next-token(parser);
      let text = token.token-text;
      select (token.token-value)
        #"repeated", #"optional", #"required" =>
          if (syntax ~= $syntax-proto2)
            parse-error("%= label not allowed in proto3 syntax file: %s", text, token);
          end;
          add-descriptor-proto-field
            (message, parse-message-field(parser, syntax, label: token));
        #"map", #"double", #"float", #"int32", #"int64", #"uint32", #"uint64",
        #"sint32", #"sint64", #"fixed32", #"fixed64", #"sfixed32", #"sfixed64",
        #"bool", #"string", #"bytes" =>
          if (syntax = $syntax-proto2)
            parse-error("proto2 field missing 'optional', 'required', or 'repeated' label: %s",
                        token);
          end;
          add-descriptor-proto-field
            (message, parse-message-field(parser, syntax, type: token));
        #"group" =>
          discard-statement(parser); // TODO: parse-group(parser);
        #"oneof" =>
          discard-statement(parser); // TODO: parse-oneof(parser);
        #"option" =>
          ;  // not yet: add!(options, parse-message-option(parser));
        #"extensions" =>
          parse-extensions-spec(parser, message);
        #"reserved" =>
          parse-reserved-spec(parser, message);
        #"message" =>
          add-descriptor-proto-nested-type
            (message, parse-message(parser, file, name-path, token));
        #"enum" =>
          add-descriptor-proto-enum-type
            (message, parse-enum(parser, name-path, token));
        #"extend" =>
          discard-statement(parser); // TODO: parse-extend(parser, message-names);
        ';' =>                    // empty statement,
          ;                       // do nothing
        '}' =>
          done();
        otherwise =>
          select (token by instance?)
            <identifier-token> =>
              // Looking at a proto3 message-, enum-, or group-typed field.
              if (syntax = $syntax-proto2)
                parse-error("proto2 field missing 'optional', 'required', or 'repeated' label: %s",
                            token);
              end;
              add-descriptor-proto-field
                (message, parse-message-field(parser, syntax, type: token));
            <comment-token> =>
              #f;
            otherwise =>
              parse-error("unexpected message element starting with %s", token);
          end;
      end select;
    end while;
  end block;
  for (field in descriptor-proto-field(message) | #[])
    field.descriptor-parent := message;
  end;
  for (child in descriptor-proto-nested-type(message) | #[])
    child.descriptor-parent := message;
  end;
  for (enum in descriptor-proto-enum-type(message) | #[])
    enum.descriptor-parent := message;
  end;
  maybe-attach-comments-to(parser, message, message-token);
  validate-message(parser, message);
  message
end function;

// Do consistency checks that require the entire message to have been parsed.
define function validate-message
    (parser :: <parser>, message :: <descriptor-proto>) => ()
  // Any reserved or extension ranges overlap each other?
  let ranges = concat(message.descriptor-proto-reserved-range | #[],
                      message.descriptor-proto-extension-range | #[]);
  for (range1 in ranges)
    for (range2 in ranges)
      if (range1 ~== range2 & ranges-overlap?(range1, range2))
        parse-error(sformat("range %= overlaps range %=", range1, range2));
      end;
    end;
  end;
  // Check for conflicting field names or numbers.
  for (field in descriptor-proto-field(message) | #())
    let name = field.field-descriptor-proto-name;
    let number = field.field-descriptor-proto-number;
    if (member?(name, message.descriptor-proto-reserved-name | #(), test: string-equal?))
      parse-error("invalid field name %=: this name is marked as reserved", name)
    end;
    // Any reserved fields used?
    for (range in message.descriptor-proto-reserved-range | #())
      if (number >= range.descriptor-proto-reserved-range-start
            & number < range.descriptor-proto-reserved-range-end)
        parse-error("invalid field number %= for field %=: marked as reserved",
                    number, name);
      end;
    end;
    // Any extensions field numbers used by normal fields?
    for (range in message.descriptor-proto-extension-range | #())
      if (number >= range.descriptor-proto-extension-range-start
            & number < range.descriptor-proto-extension-range-end)
        parse-error("invalid field number %= for field %=: part of an extension range",
                    number, name);
      end;
    end;
  end for;
end function;

// The "enum" token has just been consumed, at file level or nested in a message.
define function parse-enum
    (parser :: <parser>, parent-names :: <list>, enum-token :: <token>)
 => (enum :: <enum-descriptor-proto>)
  let name-token = next-token(parser);
  let name = name-token.token-text;
  let name-path = pair(name, parent-names);
  expect-token(parser, "{");
  let enum = make(<enum-descriptor-proto>, name: name);
  block (done)
    while (#t)
      let token = next-token(parser);
      select (token.token-value)
        #"option" =>
          discard-statement(parser);
        #"reserved" =>
          discard-statement(parser);
        '}' =>
          done();
        otherwise =>
          add-enum-descriptor-proto-value(enum, parse-enum-field(parser, token));
      end;
    end;
  end;
  enum.enum-descriptor-proto-value.size > 0
    | parse-error("enum %= must have at least one enum value",
                  join(reverse!(name-path), "."));
  for (value in enum.enum-descriptor-proto-value)
    value.descriptor-parent := enum;
  end;
  maybe-attach-comments-to(parser, enum, enum-token);
  register-descriptor(join(reverse(name-path), "."), enum);
  enum
end function;

// Parse "NAME = VALUE [ options ];" in an enum.
define function parse-enum-field
    (parser :: <parser>, name :: <token>)
 => (field :: <enum-value-descriptor-proto>)
  if (~instance?(name, <identifier-token>))
    parse-error("unexpected token type %s", name);
  end;
  // TODO: group is explicitly called out as reserved, but there must be others?
  if (name.token-text = "group")
    parse-error("'group' may not be used as an enum value name");
  end;
  expect-token(parser, "=");
  let number = expect-token(parser, <number-token>);
  let options = #f;
  if ('[' == token-value(expect-token(parser, #(";", "["))))
    options := parse-enum-value-options(parser);
  end;
  let enum-value
    = make(<enum-value-descriptor-proto>,
           name: name.token-text,
           number: number.token-value,
           options: options);
  options & (options.descriptor-parent := enum-value);
  maybe-attach-comments-to(parser, enum-value, name);
  enum-value
end function;

// TODO: this is the bare minimum to parse descriptor.proto
define function parse-enum-value-options
    (parser :: <parser>) => (options :: <enum-value-options>)
  let options = make(<enum-value-options>);
  iterate loop (token = next-token(parser))
    if (~token | token.token-value ~== '}')
      expect-token(parser, "=");
      let value = expect-token(parser, <boolean-token>);
      select (token.token-text by \=)
        "deprecated" =>
          enum-value-options-deprecated(options)
            := token-value(value);
        otherwise =>
          // TODO: store in uninterpreted-option slot.
          format-out("WARNING: ignoring enum value option %= = %=\n",
                     token.token-text, value.token-text);
      end select;
      if (',' == token-value(expect-token(parser, #(",", "]"))))
        loop(next-token(parser))
      end;
    end if;
  end iterate;
  options
end function;

// A QualifiedIdentifier (unlike a TypeName) may not have a leading dot
// or specify an extension (that is, it may not contain parens).
// Returns a sequence of string, without the intervening dots.
// https://protobuf.com/docs/language-spec#package-declaration
define function parse-qualified-identifier
    (parser :: <parser>) => (name :: <seq>)
  iterate loop (token = next-token(parser), names = #())
    let name = token.token-text;
    let tok = expect-token(parser, #(";", "."));
    if (tok.token-value == '.')
      loop(next-token(parser), pair(name, names))
    else
      reverse!(pair(name, names))
    end
  end
end function;

// Parse reserved fields and add them to reserved_range and reserved_name in
// message. Examples:
//   reserved 10 to 20, 50 to 100, 20000 to max;
//   reserved "foo", "bar", "baz";
define function parse-reserved-spec
    (parser :: <parser>, message :: <descriptor-proto>) => ()
  iterate loop (token = next-token(parser))
    let value = token.token-value;
    select (token by instance?)
      <string-token> =>
        if (value.size == 0
              | ~alphabetic?(value[0])
              | ~alphanumeric?(value))
          parse-error("reserved field name not a valid identifier: %s", value);
        end;
        add-descriptor-proto-reserved-name(message, value);
        if (',' == token-value(expect-token(parser, #[";", ","])))
          loop(next-token(parser));
        end;
      <number-token> =>
        if (~instance?(value, <int>)
              | value < 1
              | value > $max-field-number)
          parse-error("reserved fields must be field numbers in the range 1-%d: %s",
                      $max-field-number, token);
        end;
        // Note that range end is exclusive.
        let range = make(<descriptor-proto-reserved-range>, start: value, end: value + 1);
        add-descriptor-proto-reserved-range(message, range);
        let punct = next-token(parser);
        select (punct.token-value by \=)
          ';' =>
            #f;                 // done
          ',' =>
            loop(next-token(parser));
          #"to" =>
            let token2 = next-token(parser);
            let value2 = 1 + if (token2.token-value = #"max")
                               $max-field-number
                             else
                               token2.token-value
                             end;
            if (~instance?(value2, <int>) | value2 < value)
              parse-error("invalid reserved range end: %s", token2);
            end;
            descriptor-proto-reserved-range-end(range) := value2;
            if (',' == token-value(expect-token(parser, #[";", ","])))
              loop(next-token(parser));
            end;
          otherwise =>
            parse-error("unexpected token %s, want semicolon, comma or 'to'", punct);
        end;
      otherwise =>
        parse-error("unexpected token %s, want field name or number", token);
    end select
  end iterate
end function;

// Parse extensions and add them to extensions_range in message. Example:
//   extensions 10 to 20, 50 to 100, 20000 to max;
define function parse-extensions-spec
    (parser :: <parser>, message :: <descriptor-proto>) => ()
  iterate loop (token = next-token(parser))
    let value = token.token-value;
    if (value ~== ';')
      if (~instance?(token, <number-token>))
        parse-error("unexpected token %s, want field number", token);
      end;
      if (~instance?(value, <int>)
            | value < 1
            | value > $max-field-number)
        parse-error("extension range start must be in the range 1-%d: %s",
                    $max-field-number, token);
      end;
      // Note that range end is exclusive.
      let range = make(<descriptor-proto-extension-range>, start: value, end: value + 1);
      add-descriptor-proto-extension-range(message, range);
      let punct = next-token(parser);
      select (punct.token-text by \=)
        ";" =>
          #f;                 // done
        "[" =>
          parse-extension-range-options(parser, range);
          expect-token(parser, ";"); // and done
        "," =>
          loop(next-token(parser));
        "to" =>
          let token2 = next-token(parser);
          let value2 = token2.token-value;
          if (value2 == #"max") value2 := $max-field-number; end;
          (instance?(value2, <int>) & value <= value2)
            | parse-error("invalid extension range end: %s", token2);
          descriptor-proto-extension-range-end(range) := value2 + 1;
          if (',' == token-value(expect-token(parser, #[";", ","])))
            loop(next-token(parser));
          end;
        otherwise =>
          parse-error("unexpected token %s, want ';', '[', \"to\", or ','.", punct);
      end select;
    end if;
  end iterate
end function;

// Parse ExtensionRangeOptions into `range`.
define function parse-extension-range-options
    (parser :: <parser>, range :: <descriptor-proto-extension-range>) => ()
  iterate loop (token = next-token(parser))
    // TODO: for now just discard up to the "]"
    if (token & token.token-value ~== ']')
      loop(next-token(parser))
    end;
  end;
end function;

// Parse a message field. For proto2 syntax, `label` is supplied and we must parse the
// field type. For proto3 there is no label and `type` is supplied by the caller.
// https://protobuf.com/docs/language-spec#fields
define function parse-message-field
    (parser :: <parser>, syntax :: <string>,
     #key label :: false-or(<token>), type :: false-or(<token>))
 => (field :: <field-descriptor-proto>)
  let type = type | next-token(parser);
  // TODO: field types that are fully qualified names. skipping for now since
  // descriptor.proto doesn't use them.
  instance?(type, <identifier-token>)
    | parse-error("expected a message field type: %=", type);
  let name = next-token(parser);
  // TODO: group is explicitly called out as reserved, but there must be others?
  name.token-text = "group"
    & parse-error("'group' may not be used as a field name: %=", name);
  expect-token(parser, "=");
  let number = expect-token(parser, <number-token>);
  let delim = token-value(expect-token(parser, #(";", "[")));
  let (options, default, json-name) = ('[' == delim) & parse-field-options(parser);
  let field
    = make(<field-descriptor-proto>,
           name: name.token-text,
           number: number.token-value,
           label: label & select (label.token-value)
                            #"repeated" => $field-descriptor-proto-label-label-repeated;
                            #"required" => $field-descriptor-proto-label-label-required;
                            #"optional" => $field-descriptor-proto-label-label-optional;
                          end,
           default-value: default,
           json-name: json-name,
           // type: We just use type-name and don't bother with the type field.
           type-name: type.token-text,
           options: options,
           // TODO: what about syntax = "editions"?
           proto3-optional:
             label & label.token-text = "optional" & syntax = $syntax-proto3);
  options & (options.descriptor-parent := field);

  // Check whether there's an end-of-line comment for this field and add it to
  // the label or type token.
  //
  // An alternative would be to have the lexer save the first non-comment token
  // on a line and attach the EOL comment to that, but I didn't think of it
  // until now and since fields make up the bulk of the lines and EOL comments
  // aren't that common it doesn't seem worth it, at least for now.
  let eol-comment = peek-token(parser);
  if (eol-comment & end-of-line-comment?(parser, eol-comment))
    add!((label | type).token-comments, eol-comment);
    // The lexer has already collected this comment so clear it or it will also
    // be added as a full-line comment before the next field.
    clear-comments(parser.%lexer);
  end;
  maybe-attach-comments-to(parser, field, label);
  maybe-attach-comments-to(parser, field, type);
  field
end function parse-message-field;

// The opening "[" token has just been consumed. Consume through the matching ']' token.
// https://protobuf.com/docs/language-spec#fields
define function parse-field-options
    (parser :: <parser>)
 => (options :: <field-options>, default :: false-or(<string>), json-name :: false-or(<string>))
  // Special handling for the two "pseudo options", default and json_name.
  let default = #f;
  let json-name = #f;
  let options = make(<field-options>);
  iterate loop ()
    let name-token = next-token(parser);
    let equals = expect-token(parser, "=");
    select (name-token.token-text by \=)
      "ctype" =>
        field-options-ctype(options) := parse-option-value(parser, <field-options-ctype>);
      "default" =>
        let (_, value-text) = parse-option-value(parser, <object>);
        default := value-text;
      "deprecated" =>
        field-options-deprecated(options) := parse-option-value(parser, <bool>);
      "json_name" =>
        json-name := parse-option-value(parser, <string>);
      "jstype" =>
        field-options-jstype(options) := parse-option-value(parser, <field-options-js-type>);
      "lazy" =>
        field-options-lazy(options) := parse-option-value(parser, <bool>);
      "packed" =>
        field-options-packed(options) := parse-option-value(parser, <bool>);
      "unverified_lazy" =>
        field-options-unverified-lazy(options) := parse-option-value(parser, <bool>);
      "weak" =>
        field-options-weak(options) := parse-option-value(parser, <bool>);
      otherwise =>
        unconsume-token(parser, equals);
        let uoption = parse-uninterpreted-option(parser, token: name-token);
        add-field-options-uninterpreted-option(options, uoption);
    end select;
    if (',' == token-value(expect-token(parser, #(",", "]"))))
      loop()
    end;
  end iterate;
  values(options, default, json-name)
end function;

// Parse an uninterpreted (i.e., unrecognized by the protobuf spec) option from compact
// field options.
define function parse-uninterpreted-option
    (parser :: <parser>, #key token :: <token> = next-token(parser))
 => (option :: <uninterpreted-option>)
  let name = parse-uninterpreted-option-name(parser, token: token);
  expect-token(parser, "=");
  let option = make(<uninterpreted-option>, name: name);
  let value-token = peek-token(parser);
  let value = parse-option-value(parser, <object>);
  select (value-token by instance?)
    <identifier-token> =>
      uninterpreted-option-identifier-value(option) := value;
    <number-token> =>
      if (instance?(value, <float>))
        uninterpreted-option-double-value(option) := as(<double-float>, value);
      elseif (negative?(value))
        uninterpreted-option-negative-int-value(option) := value;
      else
        uninterpreted-option-positive-int-value(option) := value;
      end;
    <string-token> =>
      uninterpreted-option-string-value(option) := as(<byte-vector>, value);
    otherwise =>
      // TODO: What do they mean by aggregate value? Map literal? Message literal?  For
      // now just store the text. Might need to have parse-option-value (above) return
      // the full text of the multi-token literal to store here?
      debug("storing potentially incorrect uninterpreted-option-aggregate-value: %=",
            value-token.token-text);
      uninterpreted-option-aggregate-value(option) := value-token.token-text;
  end select;
  option
end function;

// Parse an option name into a sequence of NamePart objects.  Parsing ends
// after "=" consumed. Some examples of valid names:
//
//   - foo
//   - foo.(.a.fully.qualified.type).bar
//   - .foo.bar
//
// BNF: OptionName = ( SimpleName | ExtensionName ) [ dot OptionName ] .
define function parse-uninterpreted-option-name
    (parser :: <parser>, #key token :: <token> = next-token(parser))
 => (name-parts :: <stretchy-vector>)
  let parts = make(<stretchy-vector>);
  local method add-part (text, ext?)
          add!(parts, make(<uninterpreted-option-name-part>,
                           name-part: text,
                           is-extension: ext?));
        end;
  iterate loop (token = token, prev = #f, ext-parts = #f)
    select (token.token-value)
      '=' =>                    // done!
        unconsume-token(parser, token);
        iff(empty?(parts) | ext-parts,
            parse-error("incomplete option name (unmatched open paren?): %=", token),
            parts);
      '(' =>
        iff(ext-parts,
            parse-error("option name may not have nested parentheses: %=", token),
            loop(next-token(parser), '(', #()));
      '.' =>
        iff(prev == '.',
            parse-error("option name may not have two consecutive dots: %=", token),
            loop(next-token(parser), '.', ext-parts & pair(".", ext-parts)));
      ')' =>
        if (size(ext-parts | #()) > 0)
          add-part(join(reverse!(ext-parts), ""), #t);
          loop(next-token(parser), ')', #f)
        else
          parse-error("extension part of uninterpreted option name is empty: %=", token);
        end;
      otherwise =>
        instance?(token, <identifier-token>)
          | parse-error("unexpected token while parsing option name: %=", token);
        let name = token.token-text;
        if (ext-parts)
          loop(next-token(parser), #"id", pair(name, ext-parts))
        else
          add-part(name, #f);
          loop(next-token(parser), #"id", #f)
        end
    end select
  end iterate
end function;

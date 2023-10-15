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

define function next-token
    (parser :: <parser>, #key msg) => (token :: false-or(<token>))
  let peeked = parser.peeked-token;
  if (peeked)
    parser.peeked-token := #f;
    peeked
  else
    let token = read-token(parser.%lexer);
    while (instance?(token, <comment-token>))
      token := read-token(parser.%lexer);
    end;
    if (token
          & ~instance?(token, <whitespace-token>)
          & ~instance?(token, <comment-token>))
      parser.previous-token := token;
    end;
    token | (msg & parse-error(msg))
  end
end function;

define function peek-token
    (parser :: <parser>) => (token :: false-or(<token>))
  parser.peeked-token
    | (parser.peeked-token := read-token(parser.%lexer))
end function;

define generic expect-token
    (parser :: <parser>, token-specifier :: <object>) => (token :: <token>);

define method expect-token (parser :: <parser>, class :: <class>) => (token :: <token>)
  let token = next-token(parser);
  if (~instance?(token, class))
    parse-error("expected a token of type %= but got %=",
                class, sformat("%=", token));
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
                sformat("%=", token));
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
          let message = parse-message(parser, file, #(), token);
          add-file-descriptor-proto-message-type(file, message);
        #"enum" =>
          add-file-descriptor-proto-enum-type(file, parse-enum(parser, #(), token));
        otherwise =>
          // Allow whitespace and comments to be ignored.
          if (~instance?(token, <comment-token>)
                & ~instance?(token, <whitespace-token>))
            // Call sformat here because the default handler prints error messages with
            // the common-dylan version format, which doesn't call print-object.
            parse-error("unexpected token: %s", sformat("%=", token));
          end;
      end select;
      loop(next-token(parser));
    end if;
  end iterate;
end function;

define function parse-file-option
    (parser :: <parser>, options :: <file-options>) => ()
  let name :: <seq> = parse-option-name(parser); // consumes trailing '='
  let value = token-value(next-token(parser, msg: "while parsing option value"));
  expect-token(parser, ";");

  // Most FileOptions are useless to us so don't bother putting them in the
  // language-specific slots, just put them all into uninterpreted_option.
  let unopts = options.file-options-uninterpreted-option | make(<stretchy-vector>);
  options.file-options-uninterpreted-option := unopts;

  // UninterpretedOption is over-complex for a dynamically typed language so
  // (at least for now) I'm taking advantage of the fact that repeated fields
  // are represented with generically typed <stretchy-vector> and stuffing all
  // options into it as pairs.
  add!(unopts, pair(name, value));
  // TODO: faithfully use the descriptor.proto AST:
  // add-file-options-uninterpreted-option(options, option);
end function;

// OptionName = ( SimpleName | ExtensionName ) [ dot OptionName ] .
// Parse an option name of the form "foo", "foo.bar", "foo.(.bar.baz).quux",
// etc. into a sequence of name parts where '.', '(', and ')' represent
// themselves.
define function parse-option-name
    (parser :: <parser>) => (option :: <seq>)
  iterate loop (parts = #(), in-extension? = #f)
    let token = next-token(parser, msg: "while reading option name");
    select (token.token-value)
      '=' => reverse!(parts);   // done
      '(' => iff(in-extension?,
                 parse-error("nested '(' in option name not allowed"),
                 loop(pair('(', parts), #t));
      ')' => iff(in-extension?,
                 loop(pair(')', parts), #f),
                 parse-error("unexpected ')' in option name"));
      '.' => loop(pair('.', parts), in-extension?);
      otherwise =>
        if (~instance?(token, <identifier-token>))
          parse-error("only identifier token, '(', ')', or '.' in option name, got %=",
                      token.token-text);
        end;
        loop(pair(token.token-text, parts), in-extension?)
    end
  end iterate
end function;

define function parse-message
    (parser :: <parser>, file :: <file-descriptor-proto>, parent-path :: <list>, message-token :: <token>)
 => (msg :: <descriptor-proto>)
  let name-token = next-token(parser);
  let name = name-token.token-text;
  let name-path = pair(name, parent-path);
  expect-token(parser, "{");
  let syntax = file-descriptor-proto-syntax(file);
  let message = make(<descriptor-proto>, name: name);
  block (done)
    while (#t)
      let token = next-token(parser, msg: "expected a message element or '}'");
      let text = token.token-text;
      select (token.token-value)
        #"repeated", #"optional", #"required" =>
          if (syntax ~= $syntax-proto2)
            parse-error("%= label not allowed in proto3 syntax file: %s",
                        text, sformat("%s", token));
          end;
          add-descriptor-proto-field
            (message, parse-message-field(parser, syntax, label: token));
        #"map", #"double", #"float", #"int32", #"int64", #"uint32", #"uint64",
        #"sint32", #"sint64", #"fixed32", #"fixed64", #"sfixed32", #"sfixed64",
        #"bool", #"string", #"bytes" =>
          if (syntax ~= $syntax-proto3)
            parse-error("proto2 field missing 'optional', 'required', or 'repeated' label: %s",
                        sformat("%s", token));
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
          discard-statement(parser); // TODO: parse-message-extensions(parser);
        #"reserved" =>
          parse-reserved-field-spec(parser, message);
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
                            sformat("%s", token));
              end;
              add-descriptor-proto-field
                (message, parse-message-field(parser, syntax, type: token));
            <comment-token> =>
              #f;
            otherwise =>
              parse-error("unexpected message element starting with %s",
                          sformat("%=", token));
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
  // Any reserved fields used?
  for (field in descriptor-proto-field(message) | #())
    let name = field.field-descriptor-proto-name;
    let number = field.field-descriptor-proto-number;
    if (member?(name, message.descriptor-proto-reserved-name | #(), test: string-equal?))
      parse-error("invalid field name %=: this name is marked as reserved", name)
    end;
    for (range in message.descriptor-proto-reserved-range | #())
      if (number >= range.descriptor-proto-reserved-range-start
            & number < range.descriptor-proto-reserved-range-end)
        parse-error("invalid field number %= for field %=: this number is marked as reserved",
                    number, name);
      end;
    end;
  end;
end function;

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
  enum
end function;

define function parse-enum-field
    (parser :: <parser>, name :: <token>)
 => (field :: <enum-value-descriptor-proto>)
  if (~instance?(name, <identifier-token>))
    parse-error("unexpected token type %s", sformat("%=", name));
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
define function parse-reserved-field-spec
    (parser :: <parser>, message :: <descriptor-proto>) => ()
  iterate loop (token = next-token(parser))
    let value = token.token-value;
    select (token by instance?)
      <string-token> =>
        if (value.size == 0
              | ~alphabetic?(value[0])
              | ~alphanumeric?(value))
          parse-error("reserved field name not a valid identifier: %s",
                      sformat("%s", value));
        end;
        add-descriptor-proto-reserved-name(message, value);
        if (',' == token-value(expect-token(parser, #[";", ","])))
          loop(next-token(parser));
        end;
      <number-token> =>
        if (~instance?(value, <int>)
              | value < 1
              | value > $max-field-number)
          parse-error("reserved fields must be integers in the range 1-%d: %s",
                      $max-field-number, sformat("%s", token));
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
              parse-error("invalid reserved range end: %s", sformat("%s", token2));
            end;
            descriptor-proto-reserved-range-end(range) := value2;
            if (',' == token-value(expect-token(parser, #[";", ","])))
              loop(next-token(parser));
            end;
          otherwise =>
            parse-error("unexpected token %s, want semicolon, comma or 'to'",
                        sformat("%s", punct));
        end;
      otherwise =>
        parse-error("unexpected token %s, want field name or number",
                    sformat("%s", token));
    end select
  end iterate
end function;

define function parse-message-field
    (parser :: <parser>, syntax :: <string>,
     #key label :: false-or(<token>), // if provided, this is a proto2 field
          type :: false-or(<token>))  // if provided, this is a proto3 field
 => (field :: <field-descriptor-proto>)
  let type = type | next-token(parser);
  // TODO: field types that are fully qualified names. skipping for now since
  // descriptor.proto doesn't use them.
  if (~instance?(type, <reserved-word-token>)
        & ~instance?(type, <identifier-token>))
    parse-error("unexpected token type %s", sformat("%=", type));
  end;
  let name = next-token(parser);
  // TODO: group is explicitly called out as reserved, but there must be others?
  if (name.token-text = "group")
    parse-error("'group' may not be used as a field name");
  end;
  expect-token(parser, "=");
  let number = expect-token(parser, <number-token>);
  let default = #f;
  let options = #f;
  if ('[' == token-value(expect-token(parser, #(";", "["))))
    let (d, o) = parse-field-options(parser);
    default := d;
    options := o;
    // TODO: does this need expect-token(parser, ";")? write a test.
  end;
  let field
    = make(<field-descriptor-proto>,
           name: name.token-text,
           number: number.token-value,
           label: label & select (label.token-value)
                            #"repeated" => $field-descriptor-proto-label-label-repeated;
                            #"required" => $field-descriptor-proto-label-label-required;
                            #"optional" => $field-descriptor-proto-label-label-optional;
                          end,
           default-value: default,  // a string
           // type: We just use type-name and don't bother with the type field.
           type-name: type.token-text,
           options: options,
           // TODO: what about syntax = "2024"?
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

// TODO: For now this is just enough to handle the set of options used in
// descriptor.proto: default, deprecated, and packed.
define function parse-field-options
    (parser :: <parser>)
 => (default :: false-or(<string>), options :: <field-options>)
  let default = #f;
  let options = make(<field-options>);
  iterate loop (token = next-token(parser))
    if (token)
      expect-token(parser, "=");
      let value = next-token(parser);
      select (token.token-text by \=)
        "packed" =>
          field-options-packed(options) := token-value(value);
        "deprecated" =>
          field-options-deprecated(options) := token-value(value);
        "default" =>
          default := token-value(value);
        // TODO: handle more well-known options.
        otherwise =>
          // TODO: store in uninterpreted-option slot.
          format-out("WARNING: ignoring field option %= = %=\n",
                     token.token-text, value.token-text);
      end select;
      if (',' == token-value(expect-token(parser, #(",", "]"))))
        loop(next-token(parser))
      end;
    end if;
  end iterate;
  values(sformat("%=", default), options)
end function;

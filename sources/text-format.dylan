Module: protocol-buffers-impl
Synopsis: Parse protobuf text format


//
// parse-text-format
//

// Parse a Text Format message of type `class` from `source`.
define generic parse-text-format
    (class :: subclass(<protocol-buffer-message>), source)
 => (proto :: <protocol-buffer-message>);

define method parse-text-format
    (class :: subclass(<protocol-buffer-message>), file :: <file-locator>)
 => (proto :: <protocol-buffer-message>)
  with-open-file (stream = file, direction: #"input")
    parse-text-format(class, stream)
  end
end method;

define method parse-text-format
    (class :: subclass(<protocol-buffer-message>), text :: <string>)
 => (proto :: <protocol-buffer-message>)
  with-input-from-string (stream = text)
    parse-text-format(class, stream)
  end
end method;

define method parse-text-format
    (class :: subclass(<protocol-buffer-message>), stream :: <stream>)
 => (proto :: <protocol-buffer-message>)
  let desc = introspect(class);
  instance?(desc, <descriptor-proto>)
    | pb-error("%= does not name a protocol buffer message type", class);
  let message = make(class);
  parse-text-format-into!(message, stream);
  message
end method;

//
// parse-text-format-into!
//

// Parse a Text Format message from `source` into the given `message`.
define generic parse-text-format-into!
    (message :: <protocol-buffer-message>, source)
 => ();

define method parse-text-format-into!
    (message :: <protocol-buffer-message>, file :: <file-locator>)
 => ()
  with-open-file (stream = file, direction: #"input")
    parse-text-format-into!(message, stream)
  end
end method;

define method parse-text-format-into!
    (message :: <protocol-buffer-message>, text :: <string>)
 => ()
  with-input-from-string (stream = text)
    parse-text-format-into!(message, stream)
  end
end method;

define method parse-text-format-into!
    (message :: <protocol-buffer-message>, stream :: <stream>)
 => ()
  let parser = make(<parser>,
                    lexer: make(<lexer>,
                                stream: stream,
                                whitespace?: #f,
                                comments?: #f));
  parse-text-format-message(parser, message);
end method;

// TODO: move to idl-parser.dylan

// Parse fields in a Text Format message, storing the values into `message`.
// If `end-char` is not #f then the parse is expected to terminate with that
// character after all fields have been processed. Normally `end-char` is only
// #f when parsing a top-level message from a file stream, in which case EOF
// terminates the parse.
define function parse-text-format-message
    (parser :: <parser>, message :: <protocol-buffer-message>,
     #key end-char :: one-of('}', '>', #f))
 => (message :: <protocol-buffer-message>)
  let mdata = introspect(object-class(message))
    | parse-error("can't find protobuf descriptor for %=", message);
  let message-name = mdata.introspection-full-name;
  block (return)
    while (#t)
      let token = peek-token(parser);
      if (~token)
        if (end-char)
          parse-error("end of file while parsing %s message from stream", message-name);
        else
          return(message)
        end;
      end;
      token := consume-token(parser);
      select (token by instance?)
        <identifier-token> =>
          consume-optional-token(parser, ":");
          parse-text-format-field-value(parser, message, token, message-name);
        <punctuation-token> =>
          select (token.token-value)
            end-char  => return(message);
            '['       => parse-error("TODO: '[' SpecialFieldName ']'");
            otherwise =>
              parse-error("unexpected token %= while parsing %s message from stream",
                          token, message-name);
          end;
        otherwise =>
            parse-error("unexpected token %= while parsing %s message from stream",
                        token, message-name);
      end;
    end while;
  end block
end function;

// Parse a field value and store it in `message`.
define function parse-text-format-field-value
    (parser :: <parser>, message :: <protocol-buffer-message>,
     token :: <token>, message-name :: <string>) => ()
  let local-name = token.token-value;
  let field-name = concat(message-name, ".", local-name);
  // Could look up local-name in the message's field descriptors to allocate
  // less, but at a speed cost. Requires some refactoring to pass the message
  // descriptor into this function.
  let idata = introspect(field-name)
    // TODO: how do we handle unknown fields?
    | parse-error("unknown field name in %s message: %=", message-name, local-name);
  let setter :: <func> = idata.introspection-setter;
  let desc = idata.introspection-descriptor;
  let repeated? = (desc.field-descriptor-proto-label
                     == $field-descriptor-proto-label-label-repeated);
  let scalar-type = desc.field-descriptor-proto-scalar-type;
  let punct = peek-token(parser);
  let punct = punct & punct.token-value;
  let field-value
    = select (punct)
        '{', '<' =>
          subtype?(scalar-type, <protocol-buffer-message>)
            | parse-error("got %= but the type of field %s (%s) is not a"
                            " protobuf message type",
                          punct, field-name, desc.field-descriptor-proto-type-name);
          consume-token(parser);
          parse-text-format-message(parser, make(scalar-type),
                                    end-char: iff(punct == '{', '}', '>'));
        '[' =>
          repeated?
            | parse-error("got '[' but field %s is not a repeated field", field-name);
          consume-token(parser);
          parse-text-format-list(parser, scalar-type);
        otherwise =>
          token-value(consume-token(parser));
      end select;
  setter(field-value, message); // may signal a type error, but our job is done
end function;

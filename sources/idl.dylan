Module: protocol-buffers-impl
Synopsis: Ad-hoc, recursive descent parser for .proto Interface Definition Language

// References used while writing this parser:
// * https://protobuf.dev/reference/protobuf/proto2-spec/
// * https://protobuf.dev/reference/protobuf/proto3-spec/
// * https://protobuf.com/docs/language-spec#character-classes
// * https://github.com/bufbuild/protocompile/blob/main/parser/


define class <token> (<object>)
  constant slot token-text  :: <string>, required-init-keyword: text:;
  constant slot token-value :: <object>, required-init-keyword: value:;
  // TODO: reinstate the line+column slots. When a parse error occurs (note,
  // not a lexer error) we want to report the location of the first bad token.
end class;

define method print-object
    (token :: <token>, stream :: <stream>) => ()
  printing-object (token, stream)
    format(stream, "text: %=, value: %=", token.token-text, token.token-value)
  end;
end method;

define class <punctuation-token>   (<token>) end; // {, }, =, etc.
define class <reserved-word-token> (<token>) end;
define class <identifier-token>    (<token>) end;
define class <number-token>        (<token>) end;
define class <string-token>        (<token>) end;
define class <boolean-token>       (<token>) end;
define class <comment-token>       (<token>) end;
define class <whitespace-token>    (<token>) end;


define constant $reserved-words
  = #["bool", "bytes", "double", "enum", "extend", "extensions", "fixed32", "fixed64",
      "float", "group", "import", "inf", "int32", "int64", "map", "max", "message",
      "oneof", "option", "optional", "package", "public", "repeated", "required",
      "reserved", "returns", "rpc", "service", "sfixed32", "sfixed64", "sint32",
      "sint64", "stream", "string", "syntax", "to", "uint32", "uint64", "weak"];

define constant $well-known-tokens :: <string-table>
  = begin
      let t = make(<string-table>);
      for (c in ";,.:=(){}[]<>/")
        let text = make(<string>, size: 1, fill: c);
        t[text] := make(<punctuation-token>, text: text, value: c);
      end;
      for (text in $reserved-words)
        t[text] := make(<reserved-word-token>,
                        text: text,
                        value: as(<symbol>, text));
      end;
      t["true"] := make(<boolean-token>, text: "true", value: #t);
      t["false"] := make(<boolean-token>, text: "false", value: #f);
      t["nan"] := make(<number-token>, text: "nan", value: 0.0d0 / 0.0d0);
      t["inf"] := make(<number-token>, text: "nan", value: 1.0d0 / 0.0d0);
      // see read-numeric-literal
      t["-inf"] := make(<number-token>, text: "nan", value: -1.0d0 / 0.0d0);
      t
    end;

define class <lexer> (<object>)
  slot lexer-line :: <int> = 1;
  slot lexer-column :: <int> = 0;
  constant slot lexer-stream :: <stream>, required-init-keyword: stream:;
  // This is optional and solely for use in error messages.
  // Using <string> instead of <pathname> to avoid dependency on System library.
  constant slot lexer-file :: <string> = "<stream>", init-keyword: file:;
  constant slot lexer-whitespace? :: <bool> = #f, init-keyword: whitespace?:;
  constant slot lexer-comments? :: <bool> = #f, init-keyword: comments?:;
end class;

define generic read-token
  (lex :: <lexer>) => (token :: false-or(<token>));

define generic peek-char
  (lex :: <lexer>) => (char :: false-or(<char>));

define generic consume-char
  (lex :: <lexer>) => (char :: false-or(<char>));

define generic expect
  (lex :: <lexer>, text :: <string>) => ();


define class <lexer-error> (<protocol-buffer-error>) end;

define function lex-error
    (lex :: <lexer>, format-string :: <string>, #rest args)
  let location-args = list(lex.lexer-file, lex.lexer-line, lex.lexer-column);
  signal(make(<lexer-error>,
              format-string: concat("%s:%d:%d ", format-string),
              format-arguments: concat(location-args, args)))
end function;


define method peek-char (lex :: <lexer>) => (char :: false-or(<char>))
  peek(lex.lexer-stream, on-end-of-stream: #f)
end method;

define method consume-char (lex :: <lexer>) => (char :: false-or(<char>))
  let ch = read-element(lex.lexer-stream);
  if (ch == '\n')
    lex.lexer-column := 0;
    inc!(lex.lexer-line);
  else
    inc!(lex.lexer-column);
  end;
  ch
end method;

define method expect
    (lex :: <lexer>, text :: <string>) => ()
  for (c in text)
    let p = peek-char(lex);
    p | lex-error(lex, "end of stream encountered but was expecting %=", text);
    c == p | lex-error(lex, "expected %= (part of %=) but got %=", c, text, p);
    consume-char(lex);
  end;
end method;


// Should probably get rid of this but I want the brevity during development.
define inline function ord (c :: <char>) => (i :: <int>)
  as(<int>, c)
end function;

define inline function chr (i :: <int>) => (c :: <char>)
  as(<char>, i)
end function;

define inline function hex-value (ch :: <char>) => (i :: <int>)
  let n = ord(as-lowercase(ch));
  if (n < ord('a'))
    n - ord('0')
  else
    n - ord('a') + 10
  end
end function;

define method read-token
    (lex :: <lexer>) => (token :: false-or(<token>))
  let char = peek-char(lex);
  select (char)
    #f =>
      #f;  // end of stream
    ' ', '\n', '\r', '\t', '\f', '\<0B>' =>
      let token = read-whitespace(lex);
      iff(lex.lexer-whitespace?,
          token,
          read-token(lex));
    '/' =>
      let token = read-comment(lex);
      iff(lex.lexer-comments?,
          token,
          read-token(lex));
    '"', '\'' =>
      read-string-literal(lex);
    '=', '{', '}', '[', ']', '(', ')', '<', '>', ':', ';', ',' =>
      consume-char(lex);
      // (Could avoid making a string here.)
      let text = make(<string>, size: 1, fill: char);
      $well-known-tokens[text];
    '.' =>
      consume-char(lex);
      let ch = peek-char(lex);
      if (decimal-digit?(ch))
        read-numeric-literal(lex, char, 1, dot-seen?: #t)
      else
        $well-known-tokens["."]
      end;
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' =>
      read-numeric-literal(lex, char, 1);
    '-' =>
      consume-char(lex);
      read-numeric-literal(lex, peek-char(lex), -1);
    '+' =>
      consume-char(lex);
      read-numeric-literal(lex, peek-char(lex), 1);
    otherwise =>
      // According to the spec, identifiers must start with a letter, but
      // unit tests in Google's protobuf repo assume that leading
      // underscore is valid so...
      if (char == '_' | alphabetic?(char))
        read-identifier-or-reserved-word(lex)
      else
        lex-error(lex, "unexpected character: %c", char);
      end;
  end select
end method read-token;

define function read-whitespace (lex :: <lexer>) => (token :: <whitespace-token>)
  // (We might want to optimize the single space case.)
  let whitespace = make(<stretchy-vector>);
  for (c = peek-char(lex) then peek-char(lex),
       while: c & whitespace?(c))
    add!(whitespace, consume-char(lex))
  end;
  let text = as(<string>, whitespace);
  make(<whitespace-token>, text: text, value: text)
end function;

// EBNF (but what about negatives?):
// intLit     = decimalLit | octalLit | hexLit
// decimalLit = ( "1" ... "9" ) { decimalDigit }
// octalLit   = "0" { octalDigit }
// hexLit     = "0" ( "x" | "X" ) hexDigit { hexDigit }
//
// floatLit = ( decimals "." [ decimals ] [ exponent ]
//            | decimals exponent
//            | "."decimals [ exponent ] )
//            | "inf"
//            | "nan"
// decimals  = decimalDigit { decimalDigit }
// exponent  = ( "e" | "E" ) [ "+" | "-" ] decimals
//
// `char` is either a decimal digit or '.' and has not been consumed.
// `sign` is 1 or -1
// Note that "nan" and "inf" are handled via $well-known-tokens but
// "-inf" is handled here.
define function read-numeric-literal
    (lex :: <lexer>, char :: <char>, sign :: <int>, #key dot-seen?)
 => (token :: <token>)
  let text = make(<stretchy-vector>); // full text of token.
  let int = 0;
  let state = iff(dot-seen?, #"fraction", #"start");
  let frac = 0;
  let frac-length = 0;
  let exp = 0;
  let exp-sign = 1;
  local
    method token-terminator? (ch :: false-or(<char>))
      ~ch | member?(ch, " \n\r\t\f\<0B>/'\";,:=-+(){}[]<>") // do not include '.'
    end,
    method die (ch :: <char>, kind :: <string>)
      lex-error(lex, "invalid character %= in %s literal", ch, kind);
    end,
    method octal-int-token () => (token :: <token>)
      for (c in text)
        let i = as(<int>, c) - as(<int>, '0');
        i < 8 | die(c, "octal");
        int := ash<<(int, 3) + i;
      end;
      make(<number-token>, text: as(<string>, text), value: int * sign)
    end,
    method calc-decimal-int () => (i :: <int>)
      for (c in text)
        int := int * 10 + (as(<int>, c) - as(<int>, '0'))
      end;
      int := int * sign
    end,
    method float-token (ch) => (token :: <token>)
      token-terminator?(ch) | die(ch, "float");
      make(<number-token>,
           text: as(<string>, text),
           value: sign * (int + as(<double-float>, frac) / (10 ^ frac-length)) * (10.0d0 ^ (exp-sign * exp)))
    end,
    method process-char (ch :: false-or(<char>))
      select (state)
        #"start" =>
          select (ch)
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' =>
              #f;               // Just accumulate into `text`.
            '.' =>
              calc-decimal-int();
              state := #"fraction";
            'x' =>
              (text.size == 1 & text[0] == '0') | die(ch, "numeric");
              state := #"hex";
            'e', 'E' =>
              calc-decimal-int();
              state := #"exponent";
            'i' =>
              assert(sign == -1);
              expect(lex, "inf");
              $well-known-tokens["-inf"];
            otherwise =>
              if (text[0] == '0')
                octal-int-token()
              else
                calc-decimal-int();
                make(<number-token>, text: as(<string>, text), value: int)
              end;
          end;
        #"fraction" =>
          select (ch)
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' =>
              inc!(frac-length);
              frac := frac * 10 + (as(<int>, ch) - as(<int>, '0'));
            'e', 'E' =>
              state := #"exponent";
            otherwise =>
              float-token(ch);
          end;
        #"exponent" =>
          select (ch)
            '-' =>
              exp-sign := -1;
              state := #"exponent-digits";
            '+' =>
              state := #"exponent-digits";
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' =>
              exp := exp * 10 + (as(<int>, ch) - as(<int>, '0'));
              state := #"exponent-digits";
            otherwise =>
              float-token(ch);
          end;
        #"exponent-digits" =>
          select (ch)
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' =>
              exp := exp * 10 + (as(<int>, ch) - as(<int>, '0'));
            otherwise =>
              float-token(ch);
          end;
        #"hex" =>
          select (ch)
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' =>
              int := ash<<(int, 4) + (as(<int>, ch) - as(<int>, '0'));
            'a', 'b', 'c', 'd', 'e', 'f' =>
              int := ash<<(int, 4) + (as(<int>, ch) - as(<int>, 'a') + 10);
            'A', 'B', 'C', 'D', 'E', 'F' =>
              int := ash<<(int, 4) + (as(<int>, ch) - as(<int>, 'A') + 10);
            otherwise =>
              token-terminator?(ch) | die(ch, "hex");
              make(<number-token>, text: as(<string>, text), value: int * sign);
          end;
        otherwise =>
          lex-error(lex, "unknown state in numeric literal parser: %s", state);
      end;
    end method;
  iterate loop (ch = peek-char(lex))
    let maybe-token = process-char(ch);
    if (instance?(maybe-token, <token>))
      maybe-token
    elseif (~ch)
      lex-error(lex, "end of stream while parsing numeric literal");
    else
      consume-char(lex);
      add!(text, ch);
      loop(peek-char(lex))
    end
  end
end function read-numeric-literal;

// EBNF: ident = letter { letter | decimalDigit | "_" }
define function read-identifier-or-reserved-word (lex :: <lexer>) => (token :: <token>)
  // Caller already confirmed the peeked char is a letter.
  let identifier = make(<stretchy-vector>);
  iterate loop (ch = peek-char(lex))
    if (ch & (ch == '_' | alphanumeric?(ch)))
      add!(identifier, consume-char(lex));
      loop(peek-char(lex))
    end;
  end;
  let text = as(<string>, identifier);
  element($well-known-tokens, text, default: #f)
    | make(<identifier-token>, text: text, value: text)
end function;

define function read-comment (lex :: <lexer>) => (token :: <comment-token>)
  assert('/' == consume-char(lex));
  let comment = make(<stretchy-vector>);
  add!(comment, '/');
  let ch = peek-char(lex)
             | lex-error(lex, "end of stream while reading comment");
  add!(comment, consume-char(lex));
  select (ch)
    '*' =>
      iterate loop (prev = #f, ch = peek-char(lex))
        ch | lex-error(lex, "end of stream while reading block comment");
        ch == '\0' & lex-error(lex, "invalid character code 0 (zero) in block comment");
        add!(comment, consume-char(lex));
        if (~(prev == '*' & ch == '/'))
          loop(ch, peek-char(lex));
        end;
      end;
    '/' =>
      iterate loop (ch = peek-char(lex))
        if (ch & ch ~== '\n')
          ch == '\0' & lex-error(lex, "invalid character code 0 (zero) in line comment");
          add!(comment, consume-char(lex));
          loop(peek-char(lex));
        end;
      end;
    otherwise =>
      lex-error(lex, "expecting '/' or '*' for start of comment, got %=", ch);
  end select;
  let text = as(<string>, comment);
  make(<comment-token>, text: text, value: text)
end function;

// When this is called, consume-char will next return either " or '.
// https://protobuf.dev/reference/protobuf/proto3-spec/#string_literals
define function read-string-literal
    (lex :: <lexer>) => (token :: <token>)
  let delim = lex.consume-char;
  iterate loop (token-chars = #(), string-chars = #(), escaped? = #f)
    let char = peek-char(lex);
    if (~char)
      lex-error(lex, "end of stream encountered while parsing string constant");
    end;
    consume-char(lex);
    if (escaped?)
      if (char == '\\')
        loop(pair(char, token-chars), pair(char, string-chars), #f)
      else
        let (ch, new-token-chars)
          = process-escape-sequence(lex, char, pair(char, token-chars));
        if (instance?(ch, <int>))
          // *** Hack for unicode escapes: insert up to three byte characters.
          // Almost certainly incorrect, but at least we can parse it. ***
          let c3 = logand(ch, #xff);
          let c2 = logand(ash>>(ch, 8), #xff);
          let c1 = logand(ash>>(ch, 16), #xff);
          if (c1 > 0)
            string-chars := pair(chr(c1), string-chars);
          end;
          if (c1 > 0 | c2 > 0)
            string-chars := pair(chr(c2), string-chars);
          end;
          ch := chr(c3);
        end;
        loop(new-token-chars, pair(ch, string-chars), #f)
      end
    elseif (char == '\\')
      loop(pair(char, token-chars), string-chars, #t)
    elseif (char == delim)
      make(<string-token>,
           text: as(<string>, reverse!(token-chars)),
           value: as(<string>, reverse!(string-chars)))
    elseif (char == '\0' | char == '\n')
      lex-error(lex, "invalid character %= in string constant", char)
    else
      loop(pair(char, token-chars), pair(char, string-chars), #f)
    end
  end
end function read-string-literal;

// Read a string-literal escape sequence and turn it into a character.
// Return the characters that were consumed. Returning a type union is
// a hack to handle unicode. If the return value is an integer it's due
// to a \u escape code > 255.
define function process-escape-sequence
    (lex :: <lexer>, char :: <char>, token-chars :: <seq>)
 => (ch :: type-union(<char>, <int>), token-chars :: <seq>)
  select (char)
    'x', 'X' =>             // one or two hex digits
      let ch = consume-char(lex);
      token-chars := pair(ch, token-chars);
      let hex? = hexadecimal-digit?(ch);
      if (~hex?)
        lex-error(lex, #r"invalid hex escape in string literal: \%c%c", char, ch);
      end;
      let code = hex-value(ch);
      ch := peek-char(lex);
      if (hexadecimal-digit?(ch))
        consume-char(lex);
        token-chars := pair(ch, token-chars);
        code := code * 16 + hex-value(ch);
      end;
      values(chr(code), token-chars);
    'u', 'U' =>
      process-unicode-escape(lex, token-chars); // may return <int>
    'a' => values('\a', pair(char, token-chars));
    'b' => values('\b', pair(char, token-chars));
    'f' => values('\f', pair(char, token-chars));
    'n' => values('\n', pair(char, token-chars));
    'r' => values('\r', pair(char, token-chars));
    't' => values('\t', pair(char, token-chars));
    'v' => values('\<b>', pair(char, token-chars));
    '\\' => values('\\', pair(char, token-chars));
    '\'' => values('\'', pair(char, token-chars));
    '"' => values('"', pair(char, token-chars));
    otherwise =>
      if (~octal-digit?(char))
        lex-error(lex, "unrecognized escape character in string literal: %=", char);
      else
        // up to three octal dicits
        let code = ord(char) - ord('0');
        let ch = peek-char(lex);
        if (octal-digit?(ch))
          consume-char(lex);
          token-chars := pair(ch, token-chars);
          code := code * 8 + (ord(ch) - ord('0'));
          ch := peek-char(lex);
          if (octal-digit?(ch))
            consume-char(lex);
            token-chars := pair(ch, token-chars);
            code := code * 8 + (ord(ch) - ord('0'));
          end;
        end;
        values(chr(code), token-chars);
      end;
  end select
end function;

// EBNF:
// unicodeEscape = '\' "u" hexDigit hexDigit hexDigit hexDigit
// unicodeLongEscape = '\' "U" ( "000" hexDigit hexDigit hexDigit hexDigit hexDigit |
//                               "0010" hexDigit hexDigit hexDigit hexDigit
//
// We return an int with the full unicode value and let the caller
// pack it into a byte string. The \u has already been consumed.
define function process-unicode-escape
    (lex :: <lexer>, token-chars :: <seq>)
 => (unicode :: <int>, token-chars :: <seq>)
  local method consume-hex-char () => (c :: <char>)
          let ch = peek-char(lex);
          if (ch & ~hexadecimal-digit?(ch))
            lex-error(lex, "invalid character in unicode escape: %=", ch);
          end;
          consume-char(lex);    // signal EOF if ch is #f
          ch
        end;
  local method consume-hex-byte () => (i :: <int>)
          let c1 = consume-hex-char();
          let c2 = consume-hex-char();
          token-chars := pair(c2, pair(c1, token-chars));
          hex-value(c1) * 16 + hex-value(c2)
        end;
  let unicode :: <int>
    = ash<<(consume-hex-byte(), 8) + consume-hex-byte();
  values(if (unicode <= #x10)          // "\u000xxxxx" or "\u0010xxxx" case
           let uni = ash<<(unicode, 8) + consume-hex-byte();
           ash<<(uni, 8) + consume-hex-byte()
         else                          // "\uxxxx" case
           unicode
         end,
         token-chars)
end function;

////
//// Parser
////

// This is a temporary parser and Dylan code generator that operates directly
// on the IDL token stream. The plan is to eventually generate a <descriptor>
// instance for each message, enum, etc and emit those and generate Dylan code
// from that. This one is for bootstrapping the descriptor code by parsing
// descriptor.proto.

define class <parse-error> (<protocol-buffer-error>) end;

define function parse-error
    (format-string :: <string>, #rest args)
  signal(make(<parse-error>,
              format-string: format-string,
              format-arguments: args))
end function;

define class <parser> (<object>)
  constant slot %lexer :: <lexer>, required-init-keyword: lexer:;
end class;

define function next-token (parser :: <parser>) => (token :: false-or(<token>))
  let token = read-token(parser.%lexer);
  format-out("%=\n", token); force-out();
  token
end function;


define generic expect-token
    (parser :: <parser>, token-specifier :: <object>) => (token :: <token>);

define method expect-token (parser :: <parser>, class :: <class>) => (token :: <token>)
  let token = next-token(parser);
  if (~instance?(token, class))
    parse-error("expected a token of type %= but got %=",
                class, token.token-text);
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
                join(strings, ", ", conjunction: " or "),
                token.token-text);
  end;
  token
end method;


// Retrieve and discard tokens up to the next semicolon.
define function discard-statement (parser :: <parser>) => (#rest tokens)
  iterate loop (t = next-token(parser), tokens = #())
    if (t.token-value == ';')
      reverse!(tokens)
    else
      loop(next-token(parser), pair(t, tokens))
    end;
  end;
end function;

// Fills in the slots of `file-descriptor` based on the parse, but the
// file-descriptor-proto-name slot is the responsibility of the caller.
define function parse-file-stream
    (parser :: <parser>, file-descriptor :: <file-descriptor-proto>) => ()
  iterate loop (token = next-token(parser))
    if (token)
      select (token.token-value)
        #"syntax" =>
          expect-token(parser, "=");
          let token = expect-token(parser, #("proto2", "proto3", "editions"));
          file-descriptor-proto-syntax(file-descriptor)
            := token.token-text;
          expect-token(parser, ";");
        #"package" =>
          let package-name = parse-qualified-identifier(parser);
          file-descriptor-proto-package(file-descriptor)
            := join(package-name, ".");
        #"option" =>
          parse-file-option(parser, file-descriptor);
        #"message" =>
          if (~file-descriptor-proto-message-type(file-descriptor))
            file-descriptor-proto-message-type(file-descriptor)
              := make(<stretchy-vector>);
          end;
          add!(file-descriptor-proto-message-type(file-descriptor),
               parse-message(parser, file-descriptor, #()));
        #"enum" =>
          if (~file-descriptor-proto-enum-type(file-descriptor))
            file-descriptor-proto-enum-type(file-descriptor)
              := make(<stretchy-vector>);
          end;
          add!(file-descriptor-proto-enum-type(file-descriptor),
               parse-enum(parser, #()));
        otherwise =>
          parse-error("unexpected token: %=", token);
      end select;
      loop(next-token(parser));
    end if;
  end iterate;
end function;

// TODO: see if option parsers can share code.
define function parse-file-option
    (parser :: <parser>, file-descriptor :: <file-descriptor-proto>) => ()
  let option-name = expect-token(parser, <identifier-token>);
  expect-token(parser, "=");
  // TODO: finish option parsing. We don't care about most of the FileOptions
  // fields (java, swift, go, etc options) but there are a few we'll need to
  // handle, and there will probably be Dylan options at some point.
  discard-statement(parser);
end function;

define function parse-message
    (parser :: <parser>, file :: <file-descriptor-proto>, parent-names :: <list>)
 => (msg :: <descriptor-proto>)
  let name-token = next-token(parser);
  let name = name-token.token-text;
  let name-path = pair(name, parent-names);
  expect-token(parser, "{");
  let fields   = make(<stretchy-vector>);
  let messages = make(<stretchy-vector>);
  let enums    = make(<stretchy-vector>);
  let options  = make(<stretchy-vector>);
  block (done)
    while (#t)
      let token = parser.next-token;
      select (token.token-value)
        #"repeated", #"optional", #"required" =>
          add!(fields, parse-message-field(parser, file, label: token));
        #"map", #"double", #"float", #"int32", #"int64", #"uint32", #"uint64",
        #"sint32", #"sint64", #"fixed32", #"fixed64", #"sfixed32", #"sfixed64",
        #"bool", #"string", #"bytes" =>
          add!(fields, parse-message-field(parser, file, type: token));
        #"group" =>
          discard-statement(parser); // TODO: parse-group(parser);
        #"oneof" =>
          discard-statement(parser); // TODO: parse-oneof(parser);
        #"option" =>
          ;  // not yet: add!(options, parse-message-option(parser));
        #"extensions" =>
          discard-statement(parser); // TODO: parse-message-extensions(parser);
        #"reserved" =>
          discard-statement(parser); // TODO: parse-reserved-field-numbers(parser);
        #"message" =>
          add!(messages, parse-message(parser, file, name-path));
        #"enum" =>
          add!(enums, parse-enum(parser, name-path));
        #"extend" =>
          discard-statement(parser); // TODO: parse-extend(parser, message-names);
        ';' =>                    // empty statement,
          ;                       // do nothing
        '}' =>
          done();
        otherwise =>
          if (instance?(token, <identifier-token>))
            // Looking at a proto3 message-, enum-, or group-typed field.
            add!(fields, parse-message-field(parser, file, type: token));
          else
            parse-error("unexpected message element starting with %=",
                        token.token-text);
          end;
      end select;
    end while;
  end block;
  let dylan-class-name
    = concat("<", join(map(camel-to-kebob, reverse!(name-path)), "-"), ">");
  make(<descriptor-proto>,
       name: name,
       field: fields,
       nested-type: messages,   // This slot seems badly named in descriptor.proto?
       enum-type: enums
       // TODO: rest of the fields...
       )
end function;

define function parse-enum
    (parser :: <parser>, parent-names :: <list>) => (enum :: <enum-descriptor-proto>)
  let name-token = next-token(parser);
  let name = name-token.token-text;
  let name-path = pair(name, parent-names);
  expect-token(parser, "{");
  let fields  = make(<stretchy-vector>);
  let options = make(<stretchy-vector>);
  block (done)
    while (#t)
      let token = parser.next-token;
      select (token.token-value)
        #"option" =>
          discard-statement(parser);
        #"reserved" =>
          discard-statement(parser);
        '}' =>
          done();
        otherwise =>
          add!(fields, parse-enum-field(parser, token));
      end;
    end;
  end;
  fields.size > 0
    | parse-error("enum %= must have at least one enum value",
                  join(reverse!(name-path), "."));
  make(<enum-descriptor-proto>,
       name: name,
       value: fields,
       options: options,
       reserved-name: #f,       // TODO
       reserved-range: #f)      // TODO
end function;

define function parse-enum-field
    (parser :: <parser>, name :: <token>) => (field :: <enum-value-descriptor-proto>)
  if (~instance?(name, <reserved-word-token>)
        & ~instance?(name, <identifier-token>))
    parse-error("unexpected token type %=", name);
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
  make(<enum-value-descriptor-proto>,
       name: name.token-text,
       number: number.token-value,
       options: options)
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

// A QualifiedIdentifier (unlike a TypeName) may not have a leading dot.
// Returns a sequence of string, without the intervening dots.
// https://protobuf.com/docs/language-spec#package-declaration
define function parse-qualified-identifier
    (parser :: <parser>) => (name :: <seq>)
  iterate loop (token = expect-token(parser, <identifier-token>), names = #())
    let name = token.token-text;
    let tok = expect-token(parser, #(";", "."));
    if (tok.token-value == '.')
      loop(expect-token(parser, <identifier-token>), pair(name, names))
    else
      reverse!(names)
    end
  end
end function;

define function parse-message-field
    (parser :: <parser>, file :: <file-descriptor-proto>,
     #key label :: false-or(<token>), // if provided, parsing a proto2 field
          type :: false-or(<token>))  // if provided, parsing a proto3 field
 => (field :: <field-descriptor-proto>)
  let type = type | next-token(parser);
  // TODO: field types that are fully qualified names. skipping for now since
  // descriptor.proto doesn't use them.
  if (~instance?(type, <reserved-word-token>)
        & ~instance?(type, <identifier-token>))
    parse-error("unexpected token type %=", type);
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
  end;
  make(<field-descriptor-proto>,
       name: name.token-text,
       number: number.token-value,
       label: label & select (label.token-value)
                        #"repeated" => $field-descriptor-proto-label-label-repeated;
                        #"required" => $field-descriptor-proto-label-label-required;
                        #"optional" => $field-descriptor-proto-label-label-optional;
                      end,
       default-value: default,
       // TODO: for built-in types (bool, int32, etc) this is easy
       // but if `type` names a message, enum, or group then I
       // think we need a second pass to fill it in because it
       // could be a forward reference. Also... we don't have to set this.
       //type: enum-field-from-name(<field-descriptor-proto-type>,
       //                           concat("TYPE_", uppercase(type.token-text)))
       //        | ...?
       type-name: type.token-text,
       options: options,
       // TODO: what about syntax = editions?
       proto3-optional:
         label
         & label.token-text = "optional"
         & file-descriptor-proto-syntax(file) = "proto3")
end function parse-message-field;

// TODO: For now this is just enough to handle the set of options used in
// descriptor.proto: default, deprecated, and packed.
define function parse-field-options
    (parser :: <parser>) => (default, options :: <field-options>)
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
          default := token-text(value);
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
  values(default, options)
end function;

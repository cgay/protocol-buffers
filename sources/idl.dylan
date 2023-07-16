Module: protocol-buffers-impl
Synopsis: Ad-hoc, recursive descent parser for .proto Interface Definition Language


define class <token> (<object>)
  constant slot token-text   :: <string>, required-init-keyword: text:;
  constant slot token-value  :: <object>, required-init-keyword: value:;
  constant slot token-line   :: <int>,    required-init-keyword: line:;
  constant slot token-column :: <int>,    required-init-keyword: column:;
end class;
ignore(token-text, token-value, token-line, token-column);

define class <lexer> (<object>)
  slot lexer-line :: <int> = 0;
  slot lexer-column :: <int> = 0;
  constant slot lexer-stream :: <stream>, required-init-keyword: stream:;
  // This is optional and solely for use in error messages.
  // Using <string> instead of <pathname> to avoid dependency on System library.
  constant slot lexer-file :: <string> = "<stream>", init-keyword: file:;
end class;

define generic next-token
  (lex :: <lexer>) => (token :: false-or(<token>));

define generic peek-char
  (lex :: <lexer>) => (char :: false-or(<char>));

define generic consume-char
  (lex :: <lexer>) => (char :: false-or(<char>));

define generic make-token
    (lex :: <lexer>, text :: <string>, value :: <object>)
 => (token :: <token>);


define class <lexer-error> (<protocol-buffer-error>) end;

define function lex-error
    (lex :: <lexer>, format-string :: <string>, #rest args)
  let location-args = list(lex.lexer-file, lex.lexer-line, lex.lexer-column);
  signal(make(<lexer-error>,
              format-string: concat("%s:%d:%d ", format-string),
              format-arguments: concat(location-args, args)))
end function;


define method make-token
    (lex :: <lexer>, text :: <string>, value :: <object>)
 => (token :: <token>)
  make(<token>,
       text: text,
       value: value,
       line: lex.lexer-line,
       column: lex.lexer-column)
end method;

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

// TODO: the spec isn't clear about such things as whether there must be
// whitespace between an identifier and a string, so for example is `import
// public"a.b.c";` valid? We'll just have to do what protoc does in such cases.
define method next-token
    (lex :: <lexer>) => (token :: false-or(<token>))
  local method finish (chars) => (token :: <token>)
          let text = as(<string>, reverse!(chars));
          make-token(lex, text, text) // the text is the value for most tokens
        end;
  iterate loop (chars = #())
    let char = peek-char(lex);
    if (~char)
      chars.size > 0 & finish(chars)
    else
      case
        whitespace?(char)
          => if (empty?(chars))
               consume-char(lex);
               loop(chars)
             else
               finish(chars)
             end;
        char == '"' | char == '\''
          => read-string-literal(lex);
        char = '/'              // comment or AnyName
          => begin
               consume-char(lex);
               if (peek-char(lex) == '/') // comment
                 while (peek-char(lex) & peek-char(lex) ~== '\n')
                   consume-char(lex)
                 end;
                 peek-char(lex) & consume-char(lex);
                 loop(chars)
               else
                 finish(list(char))
               end
             end;
        member?(char, "={}[]()<>;.,")
          => if (empty?(chars))
               consume-char(lex);
               finish(list(char))
             else
               finish(chars)
             end;
        otherwise
          => begin
               consume-char(lex);
               loop(pair(char, chars))
             end;
      end case
    end if;
  end iterate
end method next-token;

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
      make-token(lex,
                 as(<string>, reverse!(token-chars)),
                 as(<string>, reverse!(string-chars)))
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
        lex-error(lex, "unrecognized escape character in string literal: %c", char);
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
            lex-error(lex, "invalid character in unicode escape: %c", ch);
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

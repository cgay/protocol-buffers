Module: protocol-buffers-test-suite


define method tokenize (input :: <string>) => (tokens :: <seq>)
  let tokens = make(<stretchy-vector>);
  with-input-from-string (stream = input)
    let lex = make(<lexer>, stream: stream);
    let tok = #t;
    while (tok)
      tok := next-token(lex);
      tok & add!(tokens, tok.token-value);
    end;
  end;
  tokens
end method;

// TODO: float, hex, dec, oct

define test test-next-token ()
  let cases
    = #(#("syntax line",
          """syntax = "proto3";\n""",
          #["syntax", "=", "proto3", ";"]),
        #("import line",
          """import public "other.proto";\n""",
          #["import", "public", "other.proto", ";"]),
        #("java package",
          """option java_package = "com.example.foo";""",
          #["option", "java_package", "=", "com.example.foo", ";"]),
        #("simple option",
          """  option allow_alias = true; // comment with space before """,
          #["option", "allow_alias", "=", "true", ";"]),
        #("complex option",
          "  option (my_option).a = true;",
          #["option", "(", "my_option", ")", ".", "a", "=", "true", ";"]),
        #("enum start line",
          """enum EnumAllowingAlias {""",
          #["enum", "EnumAllowingAlias", "{"]),
        #("enum constant line",
          "  EAA_UNSPECIFIED = 0;/" "/ comment without space before ",
          #["EAA_UNSPECIFIED", "=", "0", ";"]),
        #("custom option",
          "EAA_FINISHED = 2 [(custom_option) = 'hello world'];",
          #["EAA_FINISHED", "=", "2", "[", "(", "custom_option", ")", "=", "hello world", "]", ";"]),
        #("map field",
          "map<int32, string> my_map = 4;",
          #["map", "<", "int32", ",", "string", ">", "my_map", "=", "4", ";"]),
        #("no space around =",
          "  sfixed32 foo=1;",
          #["sfixed32", "foo", "=", "1", ";"]));
  for (test-case in cases)
    let (name, input, want) = apply(values, test-case);
    check-equal(name, want, tokenize(input));
  end;
end test;

define test test-next-token-string-escapes ()
  local method parse (text)
          with-input-from-string (stream = text)
            let lex = make(<lexer>, stream: stream);
            let token = next-token(lex);
            //format-out("token text: %=\n", token-text(token)); force-out();
            token-value(token)
          end
        end;
  // hex escapes
  check-equal("x, one upper char",  parse(#r"'a\xAG'"),  "a\nG");
  check-equal("x, one upper char",  parse(#r"'a\xAG'"),  "a\nG");
  check-equal("x, two upper chars", parse(#r"'a\xABC'"), "a\<ab>C");
  check-equal("X, one lower char",  parse(#r"'a\Xag'"),  "a\<a>g");
  check-equal("X, two lower chars", parse(#r"'a\XabC'"), "a\<ab>C");
  // invalid hex escapes (check all hex-adjacent chars)
  check-condition("invalid hex char G", <lexer-error>, parse(#r"'\xG'"));
  check-condition("invalid hex char g", <lexer-error>, parse(#r"'\xg'"));
  check-condition("invalid hex char /", <lexer-error>, parse(#r"'\x/'"));
  check-condition("invalid hex char :", <lexer-error>, parse(#r"'\x:'"));
  check-condition("invalid hex char `", <lexer-error>, parse(#r"'\x`'"));
  check-condition("invalid hex char @", <lexer-error>, parse(#r"'\x@'"));

  // octal
  check-equal("octal one char",     parse(#r"'a\18'"),   "a\<1>8");
  check-equal("octal three chars",  parse(#r"'a\1234'"), "a\<53>4");
  check-condition("invalid octal char 8", <lexer-error>, parse(#r"'\8'"));
  check-condition("invalid octal char /", <lexer-error>, parse(#r"'\/'"));

  // character
  check-equal("char escapes", parse(#r"'\a\b\f\n\r\t\v\\\'" "\"'"), "\a\b\f\n\r\t\<b>\\\'\"");
  check-condition("invalid char escape Z", <lexer-error>, parse(#r"'\Z'"));

  // unicode (we just want to see the correct bytes in our byte string)
  check-equal("unicode 4 chars",    parse(#r"'a\u23FAz'"),     "a\<23>\<FA>z");
  check-equal("unicode lead zero",  parse(#r"'a\u00FFz'"),     "a\<FF>z");
  check-equal("unicode trail zero", parse(#r"'a\uFF00z'"),     "a\<FF>\<00>z");
  check-equal("unicode mixed case", parse(#r"'a\U000fabcdz'"), "a\<0F>\<AB>\<CD>z");
  check-equal("unicode end string", parse(#r"'a\UAAaa'"),      "a\<aa>\<aa>");
  check-condition("invalid unicode one digit", <lexer-error>, parse(#r"'\uAGGG'"));
  check-condition("invalid unicode two digits", <lexer-error>, parse(#r"'\uA9'"));
  check-condition("invalid unicode three digits", <lexer-error>, parse(#r"'\uA99G'"));
  check-condition("invalid unicode 000G", <lexer-error>, parse(#r"'\u000G'"));
  check-condition("invalid unicode 000bbbbG", <lexer-error>, parse(#r"'\u000bbbbG'"));
  check-condition("invalid unicode 0010aaaG", <lexer-error>, parse(#r"'\u0010aaG'"));
end test;

Module: protocol-buffers-test-suite

define function parse-all (input :: <string>) => (tokens :: <seq>)
  let tokens = make(<stretchy-vector>);
  with-input-from-string (stream = input)
    let lex = make(<lexer>, stream: stream);
    let tok = #t;
    while (tok)
      tok := next-token(lex);
      tok & add!(tokens, tok);
    end;
  end;
  tokens
end function;

define function parse-values (input)
  map(token-value, parse-all(input))
end function;

define function parse-one (input)
  with-input-from-string (stream = input)
    let lex = make(<lexer>, stream: stream);
    next-token(lex)
  end
end function;

define function parse-value (input)
  token-value(parse-one(input))
end function;

define test test-next-token ()
  check-equal("syntax line",
              parse-values("""syntax = "proto3";\n"""),
              #["syntax", "=", "proto3", ";"]);
  check-equal("import line",
              parse-values("""import public "other.proto";\n"""),
              #["import", "public", "other.proto", ";"]);
  check-equal("java package",
              parse-values("""option java_package = "com.example.foo";"""),
              #["option", "java_package", "=", "com.example.foo", ";"]);
  check-equal("simple option",
              parse-values("""  option allow_alias = true; // comment with space before """),
              #["option", "allow_alias", "=", "true", ";"]);
  /* complex option crashed [<stream>:0:21 fully-qualified names not yet implemented]
  check-equal("complex option",
              parse-values("  option (my_option).a = true;"),
              #["option", "(", "my_option", ")", ".", "a", "=", "true", ";"]);
  */
  check-equal("enum start line",
              parse-values("""enum EnumAllowingAlias {"""),
              #["enum", "EnumAllowingAlias", "{"]);
  check-equal("enum constant line",
              parse-values("  EAA_UNSPECIFIED = 0;/" "/ comment without space before "),
              #["EAA_UNSPECIFIED", "=", 0, ";"]);
  check-equal("custom option",
              parse-values("EAA_FINISHED = 2 [(custom_option) = 'hello world'];"),
              #["EAA_FINISHED", "=", 2, "[", "(", "custom_option", ")", "=", "hello world", "]", ";"]);
  check-equal("map field",
              parse-values("map<int32, string> my_map = 4;"),
              #["map", "<", "int32", ",", "string", ">", "my_map", "=", 4, ";"]);
  check-equal("no space around =",
              parse-values("  sfixed32 foo=1;"),
              #["sfixed32", "foo", "=", 1, ";"]);
end test;

define test test-next-token-string-escapes ()
  // hex escapes
  check-equal("x, one upper char",  parse-value(#r"'a\xAG'"),  "a\nG");
  check-equal("x, one upper char",  parse-value(#r"'a\xAG'"),  "a\nG");
  check-equal("x, two upper chars", parse-value(#r"'a\xABC'"), "a\<ab>C");
  check-equal("X, one lower char",  parse-value(#r"'a\Xag'"),  "a\<a>g");
  check-equal("X, two lower chars", parse-value(#r"'a\XabC'"), "a\<ab>C");
  // invalid hex escapes (check all hex-adjacent chars)
  check-condition("invalid hex char G", <lexer-error>, parse-value(#r"'\xG'"));
  check-condition("invalid hex char g", <lexer-error>, parse-value(#r"'\xg'"));
  check-condition("invalid hex char /", <lexer-error>, parse-value(#r"'\x/'"));
  check-condition("invalid hex char :", <lexer-error>, parse-value(#r"'\x:'"));
  check-condition("invalid hex char `", <lexer-error>, parse-value(#r"'\x`'"));
  check-condition("invalid hex char @", <lexer-error>, parse-value(#r"'\x@'"));

  // octal
  check-equal("octal one char",     parse-value(#r"'a\18'"),   "a\<1>8");
  check-equal("octal three chars",  parse-value(#r"'a\1234'"), "a\<53>4");
  check-condition("invalid octal char 8", <lexer-error>, parse-value(#r"'\8'"));
  check-condition("invalid octal char /", <lexer-error>, parse-value(#r"'\/'"));

  // character
  check-equal("char escapes", parse-value(#r"'\a\b\f\n\r\t\v\\\'" "\"'"), "\a\b\f\n\r\t\<b>\\\'\"");
  check-condition("invalid char escape Z", <lexer-error>, parse-value(#r"'\Z'"));

  // unicode (we just want to see the correct bytes in our byte string)
  check-equal("unicode 4 chars",    parse-value(#r"'a\u23FAz'"),     "a\<23>\<FA>z");
  check-equal("unicode lead zero",  parse-value(#r"'a\u00FFz'"),     "a\<FF>z");
  check-equal("unicode trail zero", parse-value(#r"'a\uFF00z'"),     "a\<FF>\<00>z");
  check-equal("unicode mixed case", parse-value(#r"'a\U000fabcdz'"), "a\<0F>\<AB>\<CD>z");
  check-equal("unicode end string", parse-value(#r"'a\UAAaa'"),      "a\<aa>\<aa>");
  check-condition("invalid unicode one digit", <lexer-error>, parse-value(#r"'\uAGGG'"));
  check-condition("invalid unicode two digits", <lexer-error>, parse-value(#r"'\uA9'"));
  check-condition("invalid unicode three digits", <lexer-error>, parse-value(#r"'\uA99G'"));
  check-condition("invalid unicode 000G", <lexer-error>, parse-value(#r"'\u000G'"));
  check-condition("invalid unicode 000bbbbG", <lexer-error>, parse-value(#r"'\u000bbbbG'"));
  check-condition("invalid unicode 0010aaaG", <lexer-error>, parse-value(#r"'\u0010aaG'"));
end test;

define test test-next-token-numeric-literals ()
  check-equal("numeric 0", parse-value(" 0 "), 0); // with whitespace
  check-equal("numeric -0", parse-value("-0"), 0); // at end of stream
  check-equal("numeric +0", parse-value("+0{"), 0); // with terminating punctuation

  check-equal("numeric 1", parse-value("1"), 1);
  check-equal("numeric -1", parse-value("-1"), -1);
  check-equal("numeric +1", parse-value("+1"), 1);

  check-equal("decimal 19", parse-value("19"), 19);
  check-equal("decimal 1000", parse-value("1000"), 1000);
  //check-equal("decimal 19.", parse-value("19."), 19); // TODO: is "19." a valid decimal integer?

  check-equal("octal 07", parse-value("07"), 7);
  check-equal("octal 010", parse-value("010"), 8);
  check-equal("octal -021", parse-value("-021"), -#o21);
  check-condition("bad octal 08", <lexer-error>, parse-value("08"));

  check-equal("hex 0x0", parse-value("0x0"), 0);
  check-equal("hex 0x1F", parse-value("0x1f"), #x1f);
  check-equal("hex -0xfade/extra", parse-value("-0xfade"), -#xfade);
  check-condition("bad hex 0xG", <lexer-error>, parse-value("0xG"));

  check-equal("float leading dot",   parse-value(".2"), 0.2d0);
  check-equal("float leading zero",  parse-value("0.2"), 0.2d0);
  check-equal("float leading zeros", parse-value("00.2"), 0.2d0);
  check-equal("float no exponent",   parse-value("123.12"), 123.12d0);
  check-equal("float trailing zeros", parse-value("0.2000"), 0.2d0);
  check-equal("float simple exponent", parse-value("0.2e2"), 20.0d0);
  check-equal("float positive exponent", parse-value("0.2e+2"), 20.0d0);
  check-equal("float negative exponent", parse-value("0.2e-2"), 0.002d0);
  check-equal("float uppercase exponent", parse-value("0.2E+2"), 20.0d0);
  check-equal("float no fraction exponent", parse-value("1e6"), 1_000_000d0);
end test;

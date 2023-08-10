Module: protocol-buffers-test-suite

define function read-all (input :: <string>) => (tokens :: <seq>)
  let tokens = make(<stretchy-vector>);
  with-input-from-string (stream = input)
    let lex = make(<lexer>, stream: stream);
    let tok = #t;
    while (tok)
      tok := read-token(lex);
      tok & add!(tokens, tok);
    end;
  end;
  tokens
end function;

define function read-values (input :: <string>)
  map(token-value, read-all(input))
end function;

define function read-one (input)
  with-input-from-string (stream = input)
    let lex = make(<lexer>, stream: stream);
    read-token(lex)
  end
end function;

define function read-value (input)
  token-value(read-one(input))
end function;

define test test-read-token ()
  check-equal("syntax line",
              read-values("""syntax = "proto3";\n"""),
              #[#"syntax", " ", '=', " ", "proto3", ';', "\n"]);
  check-equal("import line",
              read-values("""import public "other.proto";\n"""),
              #[#"import", " ", #"public", " ", "other.proto", ';', "\n"]);
  check-equal("java package",
              read-values("""option java_package = "com.example.foo";"""),
              #[#"option", " ", "java_package", " ", '=', " ", "com.example.foo", ';']);
  check-equal("simple option",
              read-values("""  option allow_alias = true; // comment with space before """),
              #["  ", #"option", " ", "allow_alias", " ", '=', " ", #t, ';', " ",
                "// comment with space before "]);
  check-equal("complex option",
              read-values("  option (my_option).a = true;"),
              #["  ", #"option", " ", '(', "my_option", ')', '.', "a", " ", '=', " ", #t, ';']);
  check-equal("enum start line",
              read-values("""enum EnumAllowingAlias {"""),
              #[#"enum", " ", "EnumAllowingAlias", " ", '{']);
  check-equal("enum constant line",
              read-values("  EAA_UNSPECIFIED = 0;/" "/ comment without space before "),
              #["  ", "EAA_UNSPECIFIED", " ", '=', " ", 0, ';',
                "// comment without space before "]);
  check-equal("custom option",
              read-values("EAA_FINISHED = 2 [(custom_option) = 'hello world'];"),
              #["EAA_FINISHED", " ", '=', " ", 2, " ", '[', '(', "custom_option", ')',
                " ", '=', " ", "hello world", ']', ';']);
  check-equal("map field",
              read-values("map<int32, string> my_map = 4;"),
              #[#"map", '<', #"int32", ',', " ", #"string", '>', " ", "my_map", " ",
                '=', " ", 4, ';']);
  check-equal("no space around =",
              read-values("  sfixed32 foo=1;"),
              #["  ", #"sfixed32", " ", "foo", '=', 1, ';']);
end test;

define test test-read-token-string-escapes ()
  // hex escapes
  check-equal("x, one upper char",  read-value(#r"'a\xAG'"),  "a\nG");
  check-equal("x, one upper char",  read-value(#r"'a\xAG'"),  "a\nG");
  check-equal("x, two upper chars", read-value(#r"'a\xABC'"), "a\<ab>C");
  check-equal("X, one lower char",  read-value(#r"'a\Xag'"),  "a\<a>g");
  check-equal("X, two lower chars", read-value(#r"'a\XabC'"), "a\<ab>C");
  // invalid hex escapes (check all hex-adjacent chars)
  check-condition("invalid hex char G", <lexer-error>, read-value(#r"'\xG'"));
  check-condition("invalid hex char g", <lexer-error>, read-value(#r"'\xg'"));
  check-condition("invalid hex char /", <lexer-error>, read-value(#r"'\x/'"));
  check-condition("invalid hex char :", <lexer-error>, read-value(#r"'\x:'"));
  check-condition("invalid hex char `", <lexer-error>, read-value(#r"'\x`'"));
  check-condition("invalid hex char @", <lexer-error>, read-value(#r"'\x@'"));

  // octal
  check-equal("octal one char",     read-value(#r"'a\18'"),   "a\<1>8");
  check-equal("octal three chars",  read-value(#r"'a\1234'"), "a\<53>4");
  check-condition("invalid octal char 8", <lexer-error>, read-value(#r"'\8'"));
  check-condition("invalid octal char /", <lexer-error>, read-value(#r"'\/'"));

  // character
  check-equal("char escapes", read-value(#r"'\a\b\f\n\r\t\v\\\'" "\"'"), "\a\b\f\n\r\t\<b>\\\'\"");
  check-condition("invalid char escape Z", <lexer-error>, read-value(#r"'\Z'"));

  // unicode (we just want to see the correct bytes in our byte string)
  check-equal("unicode 4 chars",    read-value(#r"'a\u23FAz'"),     "a\<23>\<FA>z");
  check-equal("unicode lead zero",  read-value(#r"'a\u00FFz'"),     "a\<FF>z");
  check-equal("unicode trail zero", read-value(#r"'a\uFF00z'"),     "a\<FF>\<00>z");
  check-equal("unicode mixed case", read-value(#r"'a\U000fabcdz'"), "a\<0F>\<AB>\<CD>z");
  check-equal("unicode end string", read-value(#r"'a\UAAaa'"),      "a\<aa>\<aa>");
  check-condition("invalid unicode one digit", <lexer-error>, read-value(#r"'\uAGGG'"));
  check-condition("invalid unicode two digits", <lexer-error>, read-value(#r"'\uA9'"));
  check-condition("invalid unicode three digits", <lexer-error>, read-value(#r"'\uA99G'"));
  check-condition("invalid unicode 000G", <lexer-error>, read-value(#r"'\u000G'"));
  check-condition("invalid unicode 000bbbbG", <lexer-error>, read-value(#r"'\u000bbbbG'"));
  check-condition("invalid unicode 0010aaaG", <lexer-error>, read-value(#r"'\u0010aaG'"));
end test;

define test test-read-token-numeric-literals ()
  check-equal("numeric 0", read-value("0 "), 0);  // with whitespace
  check-equal("numeric -0", read-value("-0"), 0); // at end of stream
  check-equal("numeric +0", read-value("+0{"), 0); // with terminating punctuation

  check-equal("numeric 1", read-value("1"), 1);
  check-equal("numeric -1", read-value("-1"), -1);
  check-equal("numeric +1", read-value("+1"), 1);

  check-equal("decimal 19", read-value("19"), 19);
  check-equal("decimal 1000", read-value("1000"), 1000);
  //check-equal("decimal 19.", read-value("19."), 19); // TODO: is "19." a valid decimal integer?

  check-equal("octal 07", read-value("07"), 7);
  check-equal("octal 010", read-value("010"), 8);
  check-equal("octal -021", read-value("-021"), -#o21);
  check-condition("bad octal 08", <lexer-error>, read-value("08"));

  check-equal("hex 0x0", read-value("0x0"), 0);
  check-equal("hex 0x1F", read-value("0x1f"), #x1f);
  check-equal("hex -0xfade/extra", read-value("-0xfade"), -#xfade);
  check-condition("bad hex 0xG", <lexer-error>, read-value("0xG"));

  check-equal("float leading dot",   read-value(".2"), 0.2d0);
  check-equal("float leading zero",  read-value("0.2"), 0.2d0);
  check-equal("float leading zeros", read-value("00.2"), 0.2d0);
  check-equal("float no exponent",   read-value("123.12"), 123.12d0);
  check-equal("float trailing zeros", read-value("0.2000"), 0.2d0);
  check-equal("float simple exponent", read-value("0.2e2"), 20.0d0);
  check-equal("float positive exponent", read-value("0.2e+2"), 20.0d0);
  check-equal("float negative exponent", read-value("0.2e-2"), 0.002d0);
  check-equal("float uppercase exponent", read-value("0.2E+2"), 20.0d0);
  check-equal("float no fraction exponent", read-value("1e6"), 1_000_000d0);

  // https://github.com/dylan-lang/opendylan/issues/877
  //let nan = 0.0d0 / 0.0d0;
  //check-equal("nan?", nan, read-value("nan"));

  let inf+ = 1.0d0 / 0.0d0;
  let inf- = -1.0d0 / 0.0d0;
  check-equal("inf", inf+, read-value("inf"));
  check-equal("-inf", inf-, read-value("-inf"));
end test;

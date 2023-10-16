Module: protocol-buffers-test-suite
Synopsis: Tests for idl-parser.dylan


define function parser-for (input :: <string>) => (p :: <parser>)
  make(<parser>,
       lexer: make(<lexer>,
                   stream: make(<string-stream>,
                                contents: input)))
end function;

define test test-parse-option-name ()
  check-equal("simple name",
              parse-option-name(parser-for("foo =")),
              #("foo"));
  check-equal("dotted name",
              parse-option-name(parser-for("foo.bar =")),
              #("foo", '.', "bar"));
  check-equal("absolute name",
              parse-option-name(parser-for(".foo.bar =")),
              #('.', "foo", '.', "bar"));
  check-equal("name with extension",
              parse-option-name(parser-for(".foo.(.bar) =")),
              #('.', "foo", '.', '(', '.', "bar", ')'));
end test;

define test test-parse-reserved-spec/good ()
  let good = """
    message Good {
      reserved 10, 20 to 30, 40 to max;
      reserved "foo", "bar";
    }
    """;
  let file = make(<file-descriptor-proto>, name: "test", syntax: $syntax-proto2);
  let parser = parser-for(good);
  let msg = parse-message(parser, file, #(), next-token(parser));

  // Check the ranges
  let got-ranges = descriptor-proto-reserved-range(msg);
  let want-ranges
    = vector(make(<descriptor-proto-reserved-range>, start: 10, end: 11),
             make(<descriptor-proto-reserved-range>, start: 20, end: 31),
             make(<descriptor-proto-reserved-range>, start: 40, end: 536_870_912));
  assert-equal(want-ranges.size, got-ranges.size);
  assert-equal(11, got-ranges[0].descriptor-proto-reserved-range-end);
  for (got in got-ranges,
       want in want-ranges)
    assert-equal(want.descriptor-proto-reserved-range-start,
                 got.descriptor-proto-reserved-range-start);
    assert-equal(want.descriptor-proto-reserved-range-end,
                 got.descriptor-proto-reserved-range-end);
  end;

  // Check the names
  assert-equal(#["foo", "bar"], descriptor-proto-reserved-name(msg));
end test;

define test test-parse-reserved-spec/bad ()
  let file = make(<file-descriptor-proto>, name: "test", syntax: $syntax-proto2);
  // Format: #(message proto, text to appear in error message)
  for (item in #(#("message Bad { reserved 10.2; }", "field numbers in the range 1-"),
                 #("message Bad { reserved 0; }",    "field numbers in the range 1-"),
                 #("message Bad { reserved 1-10; }", "comma"),
                 #("message Bad { reserved 8 9; }",  "comma"),
                 #("message Bad { reserved abc; }",  "want field name or number"),
                 #("message Bad { reserved \"9a\"; }", "not a valid identifier"),
                 #("message Bad { reserved 10; optional string foo = 10; }", "marked as reserved"),
                 #("message Bad { reserved 10 to 20; reserved 15 to 25; }", "overlap"),
                 #("message Bad { reserved 10; reserved 10; }", "overlap")))
    let (message, text) = apply(values, item);
    let parser = parser-for(message);
    block ()
      parse-message(parser, file, #(), next-token(parser));
      assert-true(#f, "got no error for %=", message);
    exception (err :: <parse-error>)
      let err-text = sformat("%s", err);
      assert-true(find-substring(err-text, text),
                  "didn't find %= in error %=", text, err-text);
    end;
  end;
end test;

// TODO: test extension options
define test test-parse-extensions-spec/good ()
  let good = "message Good { extensions 10, 20 to 30, 40 to max; }";
  let file = make(<file-descriptor-proto>, name: "test", syntax: $syntax-proto2);
  let parser = parser-for(good);
  let msg = parse-message(parser, file, #(), next-token(parser));

  let got-ranges = descriptor-proto-extension-range(msg);
  let want-ranges
    = vector(make(<descriptor-proto-extension-range>, start: 10, end: 11),
             make(<descriptor-proto-extension-range>, start: 20, end: 31),
             make(<descriptor-proto-extension-range>, start: 40, end: 536_870_912));
  assert-equal(want-ranges.size, got-ranges.size);
  assert-equal(11, got-ranges[0].descriptor-proto-extension-range-end);
  for (got in got-ranges,
       want in want-ranges)
    assert-equal(want.descriptor-proto-extension-range-start,
                 got.descriptor-proto-extension-range-start);
    assert-equal(want.descriptor-proto-extension-range-end,
                 got.descriptor-proto-extension-range-end);
  end;
end test;

define test test-parse-extensions-spec/bad ()
  let file = make(<file-descriptor-proto>, name: "test", syntax: $syntax-proto2);
  // Format: #(message proto, text to appear in error message)
  for (item in #(#("message Bad { extensions 10.2; }", "must be in the range 1-"),
                 #("message Bad { extensions 0; }",    "must be in the range 1-"),
                 #("message Bad { extensions 1-10; }", "unexpected token"),
                 #("message Bad { extensions 8 9; }",  "unexpected token"),
                 #("message Bad { extensions abc; }",  "want field number"),
                 #("message Bad { extensions 10; optional string foo = 10; }",
                   "part of an extension range"),
                 #("message Bad { extensions 10 to 20; extensions 15 to 25; }",
                   "overlap"),
                 #("message Bad { extensions 10; extensions 10; }",
                   "overlap")))
    let (message, text) = apply(values, item);
    let parser = parser-for(message);
    block ()
      parse-message(parser, file, #(), next-token(parser));
      assert-true(#f, "got no error for %=", message);
    exception (err :: <parse-error>)
      let err-text = sformat("%s", err);
      assert-true(find-substring(err-text, text),
                  "didn't find %= in error %=", text, err-text);
    end;
  end;
end test;

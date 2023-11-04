Module: protocol-buffers-test-suite
Synopsis: Tests for idl-parser.dylan


define function parser-for (input :: <string>) => (p :: <parser>)
  make(<parser>,
       lexer: make(<lexer>,
                   stream: make(<string-stream>,
                                contents: input)))
end function;

define test test-parse-reserved-spec/good ()
  let good = """
    message GoodRes {
      reserved 10, 20 to 30, 40 to max;
      reserved "foo", "bar";
    }
    """;
  let file = make(<file-descriptor-proto>, name: "test", syntax: $syntax-proto2);
  let parser = parser-for(good);
  let msg = parse-message(parser, file, #(), consume-token(parser));

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
  for (item in #(#("message Bad1 { reserved 10.2; }", "field numbers in the range 1-"),
                 #("message Bad2 { reserved 0; }",    "field numbers in the range 1-"),
                 #("message Bad3 { reserved 1-10; }", "comma"),
                 #("message Bad4 { reserved 8 9; }",  "comma"),
                 #("message Bad5 { reserved abc; }",  "want field name or number"),
                 #("message Bad6 { reserved \"9a\"; }", "not a valid identifier"),
                 #("message Bad7 { reserved 10; optional string foo = 10; }", "marked as reserved"),
                 #("message Bad8 { reserved 10 to 20; reserved 15 to 25; }", "overlap"),
                 #("message Bad9 { reserved 10; reserved 10; }", "overlap")))
    let (message, text) = apply(values, item);
    let parser = parser-for(message);
    block ()
      parse-message(parser, file, #(), consume-token(parser));
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
  let good = "message GoodExt { extensions 10, 20 to 30, 40 to max; }";
  let file = make(<file-descriptor-proto>, name: "test", syntax: $syntax-proto2);
  let parser = parser-for(good);
  let msg = parse-message(parser, file, #(), consume-token(parser));

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
  for (item in #(#("message ExtBad1 { extensions 10.2; }", "must be in the range 1-"),
                 #("message ExtBad2 { extensions 0; }",    "must be in the range 1-"),
                 #("message ExtBad3 { extensions 1-10; }", "unexpected token"),
                 #("message ExtBad4 { extensions 8 9; }",  "unexpected token"),
                 #("message ExtBad5 { extensions abc; }",  "want field number"),
                 #("message ExtBad6 { extensions 10; optional string foo = 10; }",
                   "part of an extension range"),
                 #("message ExtBad7 { extensions 10 to 20; extensions 15 to 25; }",
                   "overlap"),
                 #("message ExtBad8 { extensions 10; extensions 10; }",
                   "overlap")))
    let (message, text) = apply(values, item);
    let parser = parser-for(message);
    block ()
      parse-message(parser, file, #(), consume-token(parser));
      assert-true(#f, "got no error for %=", message);
    exception (err :: <parse-error>)
      let err-text = sformat("%s", err);
      assert-true(find-substring(err-text, text),
                  "didn't find %= in error %=", text, err-text);
    end;
  end;
end test;

// TODO: test an absolute qualified name. Return absolute? as a second value?
define test test-parse-uninterpreted-option-name ()
  let parts = parse-uninterpreted-option-name(parser-for("abc ="));
  expect-equal(1, parts.size);
  assert-equal("abc", uninterpreted-option-name-part-name-part(parts[0]));
  assert-equal(#f, uninterpreted-option-name-part-is-extension(parts[0]));

  let parts = parse-uninterpreted-option-name(parser-for("foo.(bar.baz).moo ="));
  assert-equal(3, parts.size);

  assert-equal("foo", uninterpreted-option-name-part-name-part(parts[0]));
  assert-equal(#f, uninterpreted-option-name-part-is-extension(parts[0]));

  assert-equal("bar.baz", uninterpreted-option-name-part-name-part(parts[1]));
  assert-equal(#t, uninterpreted-option-name-part-is-extension(parts[1]));

  assert-equal("moo", uninterpreted-option-name-part-name-part(parts[2]));
  assert-equal(#f, uninterpreted-option-name-part-is-extension(parts[2]));
end test;

define test test-parse-field-options ()
  // The opening "[" has already been consumed.
  let parser = parser-for("""default = true, weak = true, unknown = 123 ]""");
  let (options, default, json-name) = parse-field-options(parser);
  assert-equal("true", default); // The token text is stored for default.
  assert-equal(#t, options.field-options-weak);
  assert-equal(1, options.field-options-uninterpreted-option.size);
  assert-equal(123,
               uninterpreted-option-positive-int-value
                 (field-options-uninterpreted-option(options)[0]));
end test;

define test test-parse-descriptor-dot-proto ()
  remove-all-keys!($descriptors); // other tests parse descriptor.proto too.
  assert-no-errors(parse-proto-file(test-data-file("descriptor.proto")));
end test;

// Verify that end-of-line comments attach to the appropriate descriptor.
define test test-parser-attached-eol-comments ()
  let parser = parser-for("""
    message Attached {
      // before
      optional int32 foo = 3; // eol
      // don't attach this
    }
    """);
  let file = make(<file-descriptor-proto>,
                  name: "test-attached-eol-comments.proto",
                  syntax: "proto2");
  let message-token = consume-token(parser);
  let message = parse-message(parser, file, #("no-namespace"), message-token);
  assert-true(message);
  assert-equal(1, size(descriptor-proto-field(message)));
  let field = descriptor-proto-field(message)[0];
  assert-equal(1, size(parser.attached-comments));
  assert-equal(#["// before", "// eol"],
               map(token-text, parser.attached-comments[field]));
end test;

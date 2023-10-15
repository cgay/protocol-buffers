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

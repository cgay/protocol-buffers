Module: protocol-buffers-test-suite

define test test-parse-text-format ()
  let text = """
    name: "Ginger"
    """;
  let person = parse-text-format(nesting/<person>, text);
  assert-equal("Ginger", nesting/person-name(person));
end test;


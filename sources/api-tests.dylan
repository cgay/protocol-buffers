Module: protocol-buffers-test-suite


// Verify that parsing a proto file creates a map from fully-qualified names to
// descriptor objects.
define test test-find-descriptor ()
  let path = file-locator(test-data-directory(), "nesting.proto");
  parse-proto-file(path);
  expect-instance?(<descriptor-proto>, find-descriptor("nesting.Person"));
  expect-instance?(<descriptor-proto>, find-descriptor("nesting.Person.PhoneNumber"));
  expect-instance?(<enum-descriptor-proto>, find-descriptor("nesting.Person.PhoneNumber.PhoneType"));
end test;

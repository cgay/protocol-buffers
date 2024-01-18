Module: protocol-buffers-test-suite
Synopsis: Tests for introspection.dylan


define test test-<file-descriptor-set>-introspection ()
  let msg = introspect(<file-descriptor-set>);
  assert-instance?(<descriptor-proto>, msg);
  expect-equal("FileDescriptorSet",
               msg.descriptor-proto-name);
  assert-equal(1, msg.descriptor-proto-field.size);
  assert-equal(msg, introspect("google.protobuf.FileDescriptorSet"));

  let field = introspect(file-descriptor-set-file);
  assert-instance?(<field-descriptor-proto>, field);
  expect-equal(field,
               introspect(file-descriptor-set-file-setter),
               "setter and getter map to same field descriptor proto?");
  expect-equal(field,
               introspect("google.protobuf.FileDescriptorSet.file"));
  expect-equal("file",
               field.field-descriptor-proto-name);
  expect-equal("FileDescriptorProto",
               field.field-descriptor-proto-type-name);
  expect-equal($field-descriptor-proto-label-label-repeated,
               field.field-descriptor-proto-label);
end test;

Module: protocol-buffers-test-suite
Synopsis: Tests for introspection.dylan


define test test-<file-descriptor-set>-introspection ()
  let idata = introspect(<file-descriptor-set>);
  assert-instance?(<introspection-data>, idata);
  let msg = idata.introspection-descriptor;
  assert-instance?(<descriptor-proto>, msg);
  expect-equal("FileDescriptorSet",
               msg.descriptor-proto-name);
  assert-equal(1,  msg.descriptor-proto-field.size);
  assert-equal(idata, introspect("google.protobuf.FileDescriptorSet"));

  let idata = introspect(file-descriptor-set-file);
  assert-instance?(<field-introspection-data>, idata);
  let field = idata.introspection-descriptor;
  assert-instance?(<field-descriptor-proto>, field);
  expect-equal(idata,
               introspect(file-descriptor-set-file-setter),
               "setter and getter map to same field descriptor proto?");
  expect-equal(idata,
               introspect("google.protobuf.FileDescriptorSet.file"));
  expect-equal("file",
               field.field-descriptor-proto-name);
  expect-equal("FileDescriptorProto",
               field.field-descriptor-proto-type-name);
  expect-equal($field-descriptor-proto-label-label-repeated,
               field.field-descriptor-proto-label);
end test;

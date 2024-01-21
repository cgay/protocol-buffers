Module: protocol-buffers-test-suite


define test test-camel-to-kebob ()
  check-equal("basic", "camel-case", camel-to-kebob("CamelCase"));
  check-equal("acronym1", "tcp-connection", camel-to-kebob("TCPConnection"));
  check-equal("acronym2", "new-tcp-connection", camel-to-kebob("NewTCPConnection"));
  check-equal("acronym underscore", "new-rpc-dylan-service", camel-to-kebob("new_RPC_DylanService"));
  check-equal("all the things", "rpc-dylan-service-get-request", camel-to-kebob("RPC_DylanService_get_request"));
  check-equal("digits", "tcp2-name3", camel-to-kebob("TCP2Name3"));
  check-equal("leading underscore", "_foo", camel-to-kebob("_foo"));
end test;

define test test-dylan-name ()
  check-equal("basic",
              "foo", dylan-name("foo"));
  check-equal("with parent",
              "bar-foo", dylan-name("Foo", parent: "bar"));
end test;

define test test-dylan-class-name ()
  check-equal("basic",
              "<foo>", dylan-class-name("foo"));
  check-equal("with parent",
              "<bar-foo>", dylan-class-name("Foo", parent: "bar"));
end test;

// Generate code for descriptor.proto and fail if there are differences
// compared to the current descriptor-pb.dylan. If the diffs are expected
// the changes should be committed to make this test pass.
define test test-codegen-descriptor-pb ()
  remove-all-keys!($descriptors); // other tests parse descriptor.proto too.
  let tempdir = test-temp-directory();
  let gen = make(<generator>,
                 input-files: list(test-data-file("descriptor.proto")),
                 output-directory: tempdir,
                 library-name: #f);
  // Prevent doing output to stdout in the test.
  dynamic-bind (*standard-output* = make(<string-stream>, direction: #"output"))
    generate-dylan-code(gen);
  end;

  local
    method read-lines (path)
      let lines = make(<stretchy-vector>);
      with-open-file (stream = path)
        let line = #f;
        while (line := read-line(stream, on-end-of-stream: #f))
          add!(lines, line);
        end;
      end;
      lines
    end,
    method comparable? (line)
      // Ignore the generated comments, which vary depending on who generated
      // the file and when.
      ~find-substring(line, "//     Date: ")
        & ~find-substring(line, "test-data/")
    end,
    method diff (old, new)
      let old-lines = choose(comparable?, read-lines(old));
      let new-lines = choose(comparable?, read-lines(new));
      expect-equal(old-lines.size, new-lines.size); // keep going to find first mismatch
      for (old-line in old-lines,
           new-line in new-lines,
           line-number from 1)
        assert-equal(old-line, new-line, """

           current: %s
           new:     %s
           Line %d differs from current version. Do a full diff of the files and
           if the differences are expected, copy the test file in place, run the
           test suite again, and then commit it.
           """,
                     old, new, line-number);
      end;
    end method;

  let new-descriptor-pb = file-locator(tempdir, "descriptor-pb.dylan");
  let new-module-pb = file-locator(tempdir, "google-protobuf-module-pb.dylan");
  let sources-dir
    = subdirectory-locator(locator-directory(test-data-directory()), "sources");
  let old-descriptor-pb = file-locator(sources-dir, "descriptor-pb.dylan");
  let old-module-pb = file-locator(sources-dir, "google-protobuf-module-pb.dylan");
  diff(old-descriptor-pb, new-descriptor-pb);
  diff(old-module-pb, new-module-pb);
end test;

Module: protocol-buffers-test-suite


// Just to verify that the print-object methods take effect.
define test test-print-object ()
  let file = make(<file-descriptor-proto>, name: "abc.proto");
  let string = with-output-to-string (stream)
                 print(file, stream)
               end;
  assert-true(find-substring(string, "abc.proto"));

  let range = make(<descriptor-proto-reserved-range>, start: 10, end: 20);
  let string = with-output-to-string (stream)
                 print(range, stream)
               end;
  assert-true(find-substring(string, "10 to 20"), "%= contains 10 to 20", string);
end test;

Module: pbgen
Synopsis: Generate Dylan code from protocol buffer IDL (.proto files)


// I kind of prefer ".pb.dylan", for unexplainable aesthetic reasons, but
// https://github.com/dylan-lang/opendylan/issues/1529 needs fixing first.
define constant $generated-file-suffix :: <string> = "-pb.dylan";

define function parse-file
    (path :: <pathname>) => (file :: <file-descriptor-proto>)
  let path = as(<file-locator>, path);
  let out-path = file-locator(path.locator-directory,
                              concat(path.locator-base, $generated-file-suffix));
  with-open-file (in-stream = path)
    with-open-file (out-stream = out-path, direction: #"output")
      let file-descriptor
        = make(<file-descriptor-proto>, name: as(<string>, path));
      let lexer
        = make(<lexer>, stream: in-stream);
      parse-file-stream(make(<parser>, lexer: lexer),
                        file-descriptor);
      file-descriptor
    end
  end
end function;

define function main
    (name :: <string>, arguments :: <vector>)
  if (empty?(arguments))
    format-out("Usage: %s <filename>\n", name);
    exit-application(2);
  end;
  let path = arguments[0];
  let file-descriptor = parse-file(path);
  // TODO: set up output streams in generator.
  // TODO: generate library name
  let generator = make(<generator>,
                       syntax: file-descriptor-proto-syntax(file-descriptor));
  generate-dylan-code(generator, file-descriptor);
  exit-application(0);
end function;

main(application-name(),
     application-arguments());

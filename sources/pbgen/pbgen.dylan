Module: pbgen
Synopsis: Generate Dylan code from protocol buffer IDL (.proto files)


/*
define command-line <pbgen-command-line> ()
  option output-directory :: false-or(<string>),
    help: "Directory in which to write files, one for each input file"
            " and one for each .proto package declaration found.",
    kind: <parameter-option>,
    default: #f;
  option library-name :: false-or(<string>),
    help: "Name of generated library. If not provided, no library file"
            " is generated.",
    kind: <parameter-option>,
    default: #f;
  option input-files :: <seq>,
    help: ".proto files to compile. All in the same package.",
    kind: <positional-option>,
    repeated?: #t,
    required?: #t;
end command-line;
*/

define function main
    ()
  block ()
    let parser = parse-arguments(application-arguments());
    let files
      = map(curry(as, <file-locator>), get-option-value(parser, "input-files"));
    let out-dir
      = if (get-option-value(parser, "output-directory"))
          as(<directory-locator>, get-option-value(parser, "output-directory"))
        else
          working-directory()
        end;
    let generator
      = make(<generator>,
             input-files: files,
             output-directory: out-dir,
             library-name: get-option-value(parser, "library-name"));
    generate-dylan-code(generator);
  exception (err :: <abort-command-error>)
    exit-application(1);
  end block;
  exit-application(0);
end function;

define function parse-arguments
    (arguments :: <vector>) => (p :: <command-line-parser>)
  let output-directory
    = make(<parameter-option>,
           names: #("o", "output-directory"),
           default: #f,
           help: "Directory in which to write files, one for each input file"
             " and one for each .proto package declaration found.");
  let library-name
    = make(<parameter-option>,
           names: #("library-name"),
           default: #f,
           help: "Name of generated library. If not provided, no library file"
             " is generated.");
  let input-files
    = make(<positional-option>,
           names: #("input-files"),
           required?: #t,
           repeated?: #t,
           help: ".proto files to compile. All in the same package.");
  let parser
    = make(<command-line-parser>,
           help: "Generate Dylan code from .proto files.",
           options: list(output-directory, library-name, input-files));
  parse-command-line(parser, application-arguments());
  parser
end function;

main();

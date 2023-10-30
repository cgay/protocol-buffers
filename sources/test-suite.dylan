Module: protocol-buffers-test-suite
Synopsis: Shared code for the test suites.


// Find the test-data directory, whether in a single- or multi-package workspace. Uses
// the fact that the _build directory is always in the workspace root.
define function test-data-directory
    () => (dir :: <directory-locator>)
  let app-file = as(<file-locator>, application-filename());
  let workspace-dir = app-file.locator-directory.locator-directory.locator-directory;
  let dir1 = subdirectory-locator(subdirectory-locator(workspace-dir, "protocol-buffers"),
                                  "test-data");
  if (file-exists?(dir1))
    dir1
  else
    let dir2 = subdirectory-locator(workspace-dir, "test-data");
    if (~file-exists?(dir2))
      error("test-data directory not found in %s or %s", dir1, dir2)
    end;
    dir2
  end
end function;

define function test-data-file
    (filename :: <string>) => (locator :: <file-locator>)
  file-locator(test-data-directory(), filename)
end function;

define function parse-proto-file
    (path :: <pathname>, #key library-name)
 => (file :: <file-descriptor-proto>, comments-map :: <table>)
  let gen = make(<generator>,
                 input-files: list(path),
                 output-directory: test-temp-directory(),
                 library-name: library-name | "my-library");
  parse-file(gen, path)
end function;

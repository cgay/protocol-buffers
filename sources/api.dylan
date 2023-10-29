Module: protocol-buffers-impl
Synopsis: Additional APIs for which there is no other obvious home.


////
//// Introspection -- Essentially, if you want introspection call the parser
//// in-process and then use find-descriptor on the fully-qualified name.
////

// Enables lookup by fully-qualified name. Note that for <file-descriptor> the
// name is the pathname passed to pbgen, so it could be relative or absolute.
define constant $descriptors = make(<string-table>);

// Exported
define function find-descriptor
    (fully-qualified-name :: <string>)
 => (descriptor :: false-or(<protocol-buffer-message>))
  element($descriptors, fully-qualified-name, default: #f)
end function;

define function register-descriptor
    (fully-qualified-name :: <string>, descriptor :: <protocol-buffer-message>)
  find-descriptor(fully-qualified-name)
    & pb-error("descriptor name %= already used for %=",
               fully-qualified-name, find-descriptor(fully-qualified-name));
  $descriptors[fully-qualified-name] := descriptor;
end function;

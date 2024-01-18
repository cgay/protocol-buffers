Module: protocol-buffers-impl
Synopsis: Additional APIs for which there is no other obvious home.


// TODO: unify this with introspect.dylan.

// TODO: I'm pretty sure I didn't make keys in $descriptors be actual
//       fully-qualified names with leading '.' and package prefix.
//       But just use a recursive descent lookup as in introspect.dylan
//       because we need it for relative lookups anyway.

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

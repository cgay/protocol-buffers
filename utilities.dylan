Module: protocol-buffers-internal

// The ever present small bits of code that may be used throughout the project
// but are not big enough to warrant their own file. These definitions are
// loaded first and shouldn't depend on anything else in the project.

// All explicitly signaled errors are (a subclass of) this type.
define class <protocol-buffer-error> (<error>) end;

define function pb-error
    (format-string :: <string>, #rest format-args) => ()
  error(make(<protocol-buffer-error>,
             format-string: format-string,
             format-arguments: format-args));
end function;

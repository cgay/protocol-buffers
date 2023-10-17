Module: protocol-buffers-impl

// The ever present small bits of code that may be used throughout the project
// but are not big enough or cohesive enough to warrant their own file. These
// definitions are loaded first and shouldn't depend on anything else in the
// project.

// All explicitly signaled errors are indirect instances of this type.
define class <protocol-buffer-error> (<format-string-condition>, <error>) end;

define function pb-error
    (format-string :: <string>, #rest format-args)
  error(make(<protocol-buffer-error>,
             format-string: format-string,
             format-arguments: format-args));
end function;

// https://github.com/dylan-lang/opendylan/issues/1158
define method condition-to-string
    (err :: <protocol-buffer-error>) => (s :: <string>)
  apply(sformat, err.condition-format-string, err.condition-format-arguments)
end method;


define variable *debug?* :: <bool> = #t;

define function debug (format-string, #rest format-args) => ()
  if (*debug?*)
    apply(format-err, concat("DEBUG: ", format-string), format-args);
    if (format-string.size > 0
          & format-string[format-string.size - 1] ~== '\n')
      format-err("\n");
    end;
    force-err();
  end;
end function;

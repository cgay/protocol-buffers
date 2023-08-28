Module: google-protobuf
Synopsis: Additional behavior for the generated descriptor classes.


//
// descriptor-name
//

define method descriptor-name
    (file :: <file-descriptor-proto>) => (name :: <string>)
  file-descriptor-proto-name(file)
end method;

define method descriptor-name
    (message :: <descriptor-proto>) => (name :: <string>)
  descriptor-proto-name(message)
end method;

define method descriptor-name
    (enum :: <enum-descriptor-proto>) => (name :: <string>)
  enum-descriptor-proto-name(enum)
end method;

define method descriptor-name
    (field :: <field-descriptor-proto>) => (name :: <string>)
  field-descriptor-proto-name(field)
end method;

define method descriptor-name
    (enum :: <protocol-buffer-enum>) => (name :: <string>)
  enum-value-name(enum)
end method;

//
// print-object
//

define method print-object
    (desc :: <file-descriptor-set>, stream :: <stream>) => ()
  printing-object (desc, stream)
    format(stream, "%d files", size(file-descriptor-set-file(desc) | #()))
  end;
end method;

define method print-object
    (desc :: <file-descriptor-proto>, stream :: <stream>) => ()
  printing-object (desc, stream)
    write(stream, file-descriptor-proto-name(desc));
  end;
end method;

define method print-object
    (desc :: <descriptor-proto>, stream :: <stream>) => ()
  printing-object (desc, stream)
    write(stream, descriptor-proto-name(desc));
  end;
end method;

define method print-object
    (desc :: <field-descriptor-proto>, stream :: <stream>) => ()
  let label = field-descriptor-proto-label(desc);
  let label
    = label & select (label)
                $field-descriptor-proto-label-label-optional => "optional ";
                $field-descriptor-proto-label-label-required => "required ";
                $field-descriptor-proto-label-label-repeated => "repeated ";
                otherwise =>
                  ""
              end;
  printing-object (desc, stream)
    format(stream, "%s%s = %d",
           label,
           field-descriptor-proto-name(desc),
           field-descriptor-proto-number(desc));
  end;
end method;

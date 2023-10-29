Module: google-protobuf
Synopsis: Additional behavior for classes generated from descriptor.proto.


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

// These are the methods I found I needed while debugging protobufs. I made no
// attempt to define them for all classes in descriptor-pb.dylan.

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

define method print-object
    (part :: <uninterpreted-option-name-part>, stream :: <stream>) => ()
  printing-object (part, stream)
    format(stream, "%= %=",
           part.uninterpreted-option-name-part-name-part,
           part.uninterpreted-option-name-part-is-extension);
  end;
end method;

////
//// Ranges - displayed in parser error messages
////

// Too bad these can't have a shared superclass. Could implement ``option
// dylan_superclass = "<proto-range>"`` but not clear it's of general use and
// it would mean maintaining a copy of descriptor.proto from which to generate
// our code.

define method print-object
    (desc :: <descriptor-proto-reserved-range>, stream :: <stream>) => ()
  print-range-object(desc, stream,
                     desc.descriptor-proto-reserved-range-start,
                     desc.descriptor-proto-reserved-range-end);
end method;

define method print-object
    (desc :: <descriptor-proto-extension-range>, stream :: <stream>) => ()
  print-range-object(desc, stream,
                     desc.descriptor-proto-extension-range-start,
                     desc.descriptor-proto-extension-range-end);
end method;

define function print-range-object (desc, stream, start, _end)
  printing-object (desc, stream)
    // Note that range end is exclusive.
    if (start == _end - 1)
      print(start, stream);
    else
      let fin = if (_end == $max-field-number - 1) "max" else _end end;
      format(stream, "%d to %s", start, fin);
    end;
  end;
end function;

define generic ranges-overlap? (range1, range2) => (_ :: <boolean>);

// reserved X reserved
define method ranges-overlap?
    (range1 :: <descriptor-proto-reserved-range>,
     range2 :: <descriptor-proto-reserved-range>) => (_ :: <boolean>)
  ~empty?(intersection(range(from: range1.descriptor-proto-reserved-range-start,
                             to: range1.descriptor-proto-reserved-range-end - 1),
                       range(from: range2.descriptor-proto-reserved-range-start,
                             to: range2.descriptor-proto-reserved-range-end - 1)))
end method;

// extension X extension
define method ranges-overlap?
    (range1 :: <descriptor-proto-extension-range>,
     range2 :: <descriptor-proto-extension-range>) => (_ :: <boolean>)
  ~empty?(intersection(range(from: range1.descriptor-proto-extension-range-start,
                             to: range1.descriptor-proto-extension-range-end - 1),
                       range(from: range2.descriptor-proto-extension-range-start,
                             to: range2.descriptor-proto-extension-range-end - 1)))
end method;

// reserved X extension
define method ranges-overlap?
    (range1 :: <descriptor-proto-reserved-range>,
     range2 :: <descriptor-proto-extension-range>) => (_ :: <boolean>)
  ~empty?(intersection(range(from: range1.descriptor-proto-reserved-range-start,
                             to: range1.descriptor-proto-reserved-range-end - 1),
                       range(from: range2.descriptor-proto-extension-range-start,
                             to: range2.descriptor-proto-extension-range-end - 1)))
end method;

// extension X reserved
define method ranges-overlap?
    (range1 :: <descriptor-proto-extension-range>,
     range2 :: <descriptor-proto-reserved-range>) => (_ :: <boolean>)
  ~empty?(intersection(range(from: range1.descriptor-proto-extension-range-start,
                             to: range1.descriptor-proto-extension-range-end - 1),
                       range(from: range2.descriptor-proto-reserved-range-start,
                             to: range2.descriptor-proto-reserved-range-end - 1)))
end method;

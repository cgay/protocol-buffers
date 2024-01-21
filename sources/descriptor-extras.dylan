Module: protocol-buffers-impl


// This file is a companion to descriptor-support.dylan but follows
// descriptor-pb.dylan in the LID file so that the code here may augment
// descriptor-pb.dylan.


define constant $bool     = singleton(#"bool");
define constant $bytes    = singleton(#"bytes");
define constant $string   = singleton(#"string");
define constant $float    = singleton(#"float");
define constant $double   = singleton(#"double");
define constant $int32    = singleton(#"int32");
define constant $int64    = singleton(#"int64");
define constant $sint32   = singleton(#"sint32");
define constant $sint64   = singleton(#"sint64");
define constant $uint32   = singleton(#"uint32");
define constant $uint64   = singleton(#"uint64");
define constant $fixed32  = singleton(#"fixed32");
define constant $fixed64  = singleton(#"fixed64");
define constant $sfixed32 = singleton(#"sfixed32");
define constant $sfixed64 = singleton(#"sfixed64");

// The IDL parser creates instances of this class instead of creating instances
// of <field-descriptor-proto> directly, so that when manipulating data for a
// field we can dispatch on the scalar type (for efficiency) instead of having
// to match the field-descriptor-proto-type-name (a string) each time.
define class <extended-field-descriptor-proto> (<field-descriptor-proto>)
  constant slot field-descriptor-proto-scalar-type :: <type>,
    required-init-keyword: scalar-type:;
end class;

define function enum-to-scalar-type
    (field :: <extended-field-descriptor-proto>)
 => (type :: <type>)
  select (field.field-descriptor-proto-type)
    $field-descriptor-proto-type-type-bool     => $bool;
    $field-descriptor-proto-type-type-bytes    => $bytes;
    $field-descriptor-proto-type-type-double   => $double;
    $field-descriptor-proto-type-type-fixed32  => $fixed32;
    $field-descriptor-proto-type-type-fixed64  => $fixed64;
    $field-descriptor-proto-type-type-float    => $float;
    $field-descriptor-proto-type-type-group    => pb-error("groups are not supported");
    $field-descriptor-proto-type-type-int32    => $int32;
    $field-descriptor-proto-type-type-int64    => $int64;
    $field-descriptor-proto-type-type-sfixed32 => $sfixed32;
    $field-descriptor-proto-type-type-sfixed64 => $sfixed64;
    $field-descriptor-proto-type-type-sint32   => $sint32;
    $field-descriptor-proto-type-type-sint64   => $sint64;
    $field-descriptor-proto-type-type-string   => $string;
    $field-descriptor-proto-type-type-uint32   => $uint32;
    $field-descriptor-proto-type-type-uint64   => $uint64;
    $field-descriptor-proto-type-type-message  => introspection-class(introspect(field));
    $field-descriptor-proto-type-type-enum     => introspection-class(introspect(field));
  end
end function;

// name is a type name as it appears in the field descriptor. Ex: "int64" or
// "Address". parent is the fully-qualified name of the parent message.
define function type-name-to-enum
    (name :: <string>, parent :: <string>)
 => (enum :: false-or(<field-descriptor-proto-type>))
  select (name by \=)
    "bool"     => $field-descriptor-proto-type-type-bool;
    "bytes"    => $field-descriptor-proto-type-type-bytes;
    "double"   => $field-descriptor-proto-type-type-double;
    "fixed32"  => $field-descriptor-proto-type-type-fixed32;
    "fixed64"  => $field-descriptor-proto-type-type-fixed64;
    "float"    => $field-descriptor-proto-type-type-float;
    "group"    => pb-error("groups are not supported");
    "int32"    => $field-descriptor-proto-type-type-int32;
    "int64"    => $field-descriptor-proto-type-type-int64;
    "sfixed32" => $field-descriptor-proto-type-type-sfixed32;
    "sfixed64" => $field-descriptor-proto-type-type-sfixed64;
    "sint32"   => $field-descriptor-proto-type-type-sint32;
    "sint64"   => $field-descriptor-proto-type-type-sint64;
    "string"   => $field-descriptor-proto-type-type-string;
    "uint32"   => $field-descriptor-proto-type-type-uint32;
    "uint64"   => $field-descriptor-proto-type-type-uint64;
    otherwise =>
      // Must be a message or enum type.
      let full-name = concat(parent, ".", name);
      let desc = introspect(full-name);
      select (desc by instance?)
        <protocol-buffer-enum>    => $field-descriptor-proto-type-type-enum;
        <protocol-buffer-message> => $field-descriptor-proto-type-type-message;
        otherwise => #f;        // caller should signal error
      end;
  end
end function;


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
  let label
    = select (field-descriptor-proto-label(desc))
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

define generic ranges-overlap? (range1, range2) => (_ :: <bool>);

// reserved X reserved
define method ranges-overlap?
    (range1 :: <descriptor-proto-reserved-range>,
     range2 :: <descriptor-proto-reserved-range>) => (_ :: <bool>)
  ~empty?(intersection(range(from: range1.descriptor-proto-reserved-range-start,
                             to: range1.descriptor-proto-reserved-range-end - 1),
                       range(from: range2.descriptor-proto-reserved-range-start,
                             to: range2.descriptor-proto-reserved-range-end - 1)))
end method;

// extension X extension
define method ranges-overlap?
    (range1 :: <descriptor-proto-extension-range>,
     range2 :: <descriptor-proto-extension-range>) => (_ :: <bool>)
  ~empty?(intersection(range(from: range1.descriptor-proto-extension-range-start,
                             to: range1.descriptor-proto-extension-range-end - 1),
                       range(from: range2.descriptor-proto-extension-range-start,
                             to: range2.descriptor-proto-extension-range-end - 1)))
end method;

// reserved X extension
define method ranges-overlap?
    (range1 :: <descriptor-proto-reserved-range>,
     range2 :: <descriptor-proto-extension-range>) => (_ :: <bool>)
  ~empty?(intersection(range(from: range1.descriptor-proto-reserved-range-start,
                             to: range1.descriptor-proto-reserved-range-end - 1),
                       range(from: range2.descriptor-proto-extension-range-start,
                             to: range2.descriptor-proto-extension-range-end - 1)))
end method;

// extension X reserved
define method ranges-overlap?
    (range1 :: <descriptor-proto-extension-range>,
     range2 :: <descriptor-proto-reserved-range>) => (_ :: <bool>)
  ~empty?(intersection(range(from: range1.descriptor-proto-extension-range-start,
                             to: range1.descriptor-proto-extension-range-end - 1),
                       range(from: range2.descriptor-proto-reserved-range-start,
                             to: range2.descriptor-proto-reserved-range-end - 1)))
end method;

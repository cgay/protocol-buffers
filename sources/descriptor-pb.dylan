Module: google-protobuf

define class <file-descriptor-set> (<protocol-buffer-message>)
  slot file-descriptor-set-file :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: file:;
end class <file-descriptor-set>;

define class <file-descriptor-proto> (<protocol-buffer-message>)
  slot file-descriptor-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  slot file-descriptor-proto-package :: false-or(<string>),
    init-value: #f,
    init-keyword: package:;
  slot file-descriptor-proto-dependency :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: dependency:;
  slot file-descriptor-proto-public-dependency :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: public-dependency:;
  slot file-descriptor-proto-weak-dependency :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: weak-dependency:;
  slot file-descriptor-proto-message-type :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: message-type:;
  slot file-descriptor-proto-enum-type :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: enum-type:;
  slot file-descriptor-proto-service :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: service:;
  slot file-descriptor-proto-extension :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: extension:;
  slot file-descriptor-proto-options :: false-or(<file-options>),
    init-value: #f,
    init-keyword: options:;
  slot file-descriptor-proto-source-code-info :: false-or(<source-code-info>),
    init-value: #f,
    init-keyword: source-code-info:;
  slot file-descriptor-proto-syntax :: false-or(<string>),
    init-value: #f,
    init-keyword: syntax:;
  slot file-descriptor-proto-edition :: false-or(<string>),
    init-value: #f,
    init-keyword: edition:;
end class <file-descriptor-proto>;

define class <descriptor-proto> (<protocol-buffer-message>)
  slot descriptor-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  slot descriptor-proto-field :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: field:;
  slot descriptor-proto-extension :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: extension:;
  slot descriptor-proto-nested-type :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: nested-type:;
  slot descriptor-proto-enum-type :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: enum-type:;
  slot descriptor-proto-extension-range :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: extension-range:;
  slot descriptor-proto-oneof-decl :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: oneof-decl:;
  slot descriptor-proto-options :: false-or(<message-options>),
    init-value: #f,
    init-keyword: options:;
  slot descriptor-proto-reserved-range :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: reserved-range:;
  slot descriptor-proto-reserved-name :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: reserved-name:;
end class <descriptor-proto>;

define class <descriptor-proto-extension-range> (<protocol-buffer-message>)
  slot descriptor-proto-extension-range-start :: false-or(<int32>),
    init-value: #f,
    init-keyword: start:;
  slot descriptor-proto-extension-range-end :: false-or(<int32>),
    init-value: #f,
    init-keyword: end:;
  slot descriptor-proto-extension-range-options :: false-or(<extension-range-options>),
    init-value: #f,
    init-keyword: options:;
end class <descriptor-proto-extension-range>;

define class <descriptor-proto-reserved-range> (<protocol-buffer-message>)
  slot descriptor-proto-reserved-range-start :: false-or(<int32>),
    init-value: #f,
    init-keyword: start:;
  slot descriptor-proto-reserved-range-end :: false-or(<int32>),
    init-value: #f,
    init-keyword: end:;
end class <descriptor-proto-reserved-range>;

define class <extension-range-options> (<protocol-buffer-message>)
  slot extension-range-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <extension-range-options>;

define class <field-descriptor-proto> (<protocol-buffer-message>)
  slot field-descriptor-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  slot field-descriptor-proto-number :: false-or(<int32>),
    init-value: #f,
    init-keyword: number:;
  slot field-descriptor-proto-label :: false-or(<field-descriptor-proto-label>),
    init-value: #f,
    init-keyword: label:;
  slot field-descriptor-proto-type :: false-or(<field-descriptor-proto-type>),
    init-value: #f,
    init-keyword: type:;
  slot field-descriptor-proto-type-name :: false-or(<string>),
    init-value: #f,
    init-keyword: type-name:;
  slot field-descriptor-proto-extendee :: false-or(<string>),
    init-value: #f,
    init-keyword: extendee:;
  slot field-descriptor-proto-default-value :: false-or(<string>),
    init-value: #f,
    init-keyword: default-value:;
  slot field-descriptor-proto-oneof-index :: false-or(<int32>),
    init-value: #f,
    init-keyword: oneof-index:;
  slot field-descriptor-proto-json-name :: false-or(<string>),
    init-value: #f,
    init-keyword: json-name:;
  slot field-descriptor-proto-options :: false-or(<field-options>),
    init-value: #f,
    init-keyword: options:;
  slot field-descriptor-proto-proto3-optional :: <boolean>,
    init-value: #f,
    init-keyword: proto3-optional:;
end class <field-descriptor-proto>;

define class <field-descriptor-proto-type> (<protocol-buffer-enum>) end;

define constant $field-descriptor-proto-type-type-double :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_DOUBLE",
         value: 1);
define constant $field-descriptor-proto-type-type-float :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_FLOAT",
         value: 2);
define constant $field-descriptor-proto-type-type-int64 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_INT64",
         value: 3);
define constant $field-descriptor-proto-type-type-uint64 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_UINT64",
         value: 4);
define constant $field-descriptor-proto-type-type-int32 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_INT32",
         value: 5);
define constant $field-descriptor-proto-type-type-fixed64 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_FIXED64",
         value: 6);
define constant $field-descriptor-proto-type-type-fixed32 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_FIXED32",
         value: 7);
define constant $field-descriptor-proto-type-type-bool :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_BOOL",
         value: 8);
define constant $field-descriptor-proto-type-type-string :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_STRING",
         value: 9);
define constant $field-descriptor-proto-type-type-group :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_GROUP",
         value: 10);
define constant $field-descriptor-proto-type-type-message :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_MESSAGE",
         value: 11);
define constant $field-descriptor-proto-type-type-bytes :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_BYTES",
         value: 12);
define constant $field-descriptor-proto-type-type-uint32 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_UINT32",
         value: 13);
define constant $field-descriptor-proto-type-type-enum :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_ENUM",
         value: 14);
define constant $field-descriptor-proto-type-type-sfixed32 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_SFIXED32",
         value: 15);
define constant $field-descriptor-proto-type-type-sfixed64 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_SFIXED64",
         value: 16);
define constant $field-descriptor-proto-type-type-sint32 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_SINT32",
         value: 17);
define constant $field-descriptor-proto-type-type-sint64 :: <field-descriptor-proto-type>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_SINT64",
         value: 18);

define class <field-descriptor-proto-label> (<protocol-buffer-enum>) end;

define constant $field-descriptor-proto-label-label-optional :: <field-descriptor-proto-label>
  = make(<field-descriptor-proto-label>,
         name: "LABEL_OPTIONAL",
         value: 1);
define constant $field-descriptor-proto-label-label-required :: <field-descriptor-proto-label>
  = make(<field-descriptor-proto-label>,
         name: "LABEL_REQUIRED",
         value: 2);
define constant $field-descriptor-proto-label-label-repeated :: <field-descriptor-proto-label>
  = make(<field-descriptor-proto-label>,
         name: "LABEL_REPEATED",
         value: 3);

define class <oneof-descriptor-proto> (<protocol-buffer-message>)
  slot oneof-descriptor-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  slot oneof-descriptor-proto-options :: false-or(<oneof-options>),
    init-value: #f,
    init-keyword: options:;
end class <oneof-descriptor-proto>;

define class <enum-descriptor-proto> (<protocol-buffer-message>)
  slot enum-descriptor-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  slot enum-descriptor-proto-value :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: value:;
  slot enum-descriptor-proto-options :: false-or(<enum-options>),
    init-value: #f,
    init-keyword: options:;
  slot enum-descriptor-proto-reserved-range :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: reserved-range:;
  slot enum-descriptor-proto-reserved-name :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: reserved-name:;
end class <enum-descriptor-proto>;

define class <enum-descriptor-proto-enum-reserved-range> (<protocol-buffer-message>)
  slot enum-descriptor-proto-enum-reserved-range-start :: false-or(<int32>),
    init-value: #f,
    init-keyword: start:;
  slot enum-descriptor-proto-enum-reserved-range-end :: false-or(<int32>),
    init-value: #f,
    init-keyword: end:;
end class <enum-descriptor-proto-enum-reserved-range>;

define class <enum-value-descriptor-proto> (<protocol-buffer-message>)
  slot enum-value-descriptor-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  slot enum-value-descriptor-proto-number :: false-or(<int32>),
    init-value: #f,
    init-keyword: number:;
  slot enum-value-descriptor-proto-options :: false-or(<enum-value-options>),
    init-value: #f,
    init-keyword: options:;
end class <enum-value-descriptor-proto>;

define class <service-descriptor-proto> (<protocol-buffer-message>)
  slot service-descriptor-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  slot service-descriptor-proto-method :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: method:;
  slot service-descriptor-proto-options :: false-or(<service-options>),
    init-value: #f,
    init-keyword: options:;
end class <service-descriptor-proto>;

define class <method-descriptor-proto> (<protocol-buffer-message>)
  slot method-descriptor-proto-name :: false-or(<string>),
    init-value: #f,
    init-keyword: name:;
  slot method-descriptor-proto-input-type :: false-or(<string>),
    init-value: #f,
    init-keyword: input-type:;
  slot method-descriptor-proto-output-type :: false-or(<string>),
    init-value: #f,
    init-keyword: output-type:;
  slot method-descriptor-proto-options :: false-or(<method-options>),
    init-value: #f,
    init-keyword: options:;
  slot method-descriptor-proto-client-streaming :: <boolean>,
    init-value: #f,
    init-keyword: client-streaming:;
  slot method-descriptor-proto-server-streaming :: <boolean>,
    init-value: #f,
    init-keyword: server-streaming:;
end class <method-descriptor-proto>;

define class <file-options> (<protocol-buffer-message>)
  slot file-options-java-package :: false-or(<string>),
    init-value: #f,
    init-keyword: java-package:;
  slot file-options-java-outer-classname :: false-or(<string>),
    init-value: #f,
    init-keyword: java-outer-classname:;
  slot file-options-java-multiple-files :: <boolean>,
    init-value: #f,
    init-keyword: java-multiple-files:;
  slot file-options-java-generate-equals-and-hash :: <boolean>,
    init-value: #f,
    init-keyword: java-generate-equals-and-hash:;
  slot file-options-java-string-check-utf8 :: <boolean>,
    init-value: #f,
    init-keyword: java-string-check-utf8:;
  slot file-options-optimize-for :: false-or(<file-options-optimize-mode>),
    init-value: #f,
    init-keyword: optimize-for:;
  slot file-options-go-package :: false-or(<string>),
    init-value: #f,
    init-keyword: go-package:;
  slot file-options-cc-generic-services :: <boolean>,
    init-value: #f,
    init-keyword: cc-generic-services:;
  slot file-options-java-generic-services :: <boolean>,
    init-value: #f,
    init-keyword: java-generic-services:;
  slot file-options-py-generic-services :: <boolean>,
    init-value: #f,
    init-keyword: py-generic-services:;
  slot file-options-php-generic-services :: <boolean>,
    init-value: #f,
    init-keyword: php-generic-services:;
  slot file-options-deprecated :: <boolean>,
    init-value: #f,
    init-keyword: deprecated:;
  slot file-options-cc-enable-arenas :: <boolean>,
    init-value: #f,
    init-keyword: cc-enable-arenas:;
  slot file-options-objc-class-prefix :: false-or(<string>),
    init-value: #f,
    init-keyword: objc-class-prefix:;
  slot file-options-csharp-namespace :: false-or(<string>),
    init-value: #f,
    init-keyword: csharp-namespace:;
  slot file-options-swift-prefix :: false-or(<string>),
    init-value: #f,
    init-keyword: swift-prefix:;
  slot file-options-php-class-prefix :: false-or(<string>),
    init-value: #f,
    init-keyword: php-class-prefix:;
  slot file-options-php-namespace :: false-or(<string>),
    init-value: #f,
    init-keyword: php-namespace:;
  slot file-options-php-metadata-namespace :: false-or(<string>),
    init-value: #f,
    init-keyword: php-metadata-namespace:;
  slot file-options-ruby-package :: false-or(<string>),
    init-value: #f,
    init-keyword: ruby-package:;
  slot file-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <file-options>;

define class <file-options-optimize-mode> (<protocol-buffer-enum>) end;

define constant $file-options-optimize-mode-speed :: <file-options-optimize-mode>
  = make(<file-options-optimize-mode>,
         name: "SPEED",
         value: 1);
define constant $file-options-optimize-mode-code-size :: <file-options-optimize-mode>
  = make(<file-options-optimize-mode>,
         name: "CODE_SIZE",
         value: 2);
define constant $file-options-optimize-mode-lite-runtime :: <file-options-optimize-mode>
  = make(<file-options-optimize-mode>,
         name: "LITE_RUNTIME",
         value: 3);

define class <message-options> (<protocol-buffer-message>)
  slot message-options-message-set-wire-format :: <boolean>,
    init-value: #f,
    init-keyword: message-set-wire-format:;
  slot message-options-no-standard-descriptor-accessor :: <boolean>,
    init-value: #f,
    init-keyword: no-standard-descriptor-accessor:;
  slot message-options-deprecated :: <boolean>,
    init-value: #f,
    init-keyword: deprecated:;
  slot message-options-map-entry :: <boolean>,
    init-value: #f,
    init-keyword: map-entry:;
  slot message-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <message-options>;

define class <field-options> (<protocol-buffer-message>)
  slot field-options-ctype :: false-or(<field-options-ctype>),
    init-value: #f,
    init-keyword: ctype:;
  slot field-options-packed :: <boolean>,
    init-value: #f,
    init-keyword: packed:;
  slot field-options-jstype :: false-or(<field-options-js-type>),
    init-value: #f,
    init-keyword: jstype:;
  slot field-options-lazy :: <boolean>,
    init-value: #f,
    init-keyword: lazy:;
  slot field-options-unverified-lazy :: <boolean>,
    init-value: #f,
    init-keyword: unverified-lazy:;
  slot field-options-deprecated :: <boolean>,
    init-value: #f,
    init-keyword: deprecated:;
  slot field-options-weak :: <boolean>,
    init-value: #f,
    init-keyword: weak:;
  slot field-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <field-options>;

define class <field-options-ctype> (<protocol-buffer-enum>) end;

define constant $field-options-ctype-string :: <field-options-ctype>
  = make(<field-options-ctype>,
         name: "STRING",
         value: 0);
define constant $field-options-ctype-cord :: <field-options-ctype>
  = make(<field-options-ctype>,
         name: "CORD",
         value: 1);
define constant $field-options-ctype-string-piece :: <field-options-ctype>
  = make(<field-options-ctype>,
         name: "STRING_PIECE",
         value: 2);

define class <field-options-js-type> (<protocol-buffer-enum>) end;

define constant $field-options-js-type-js-normal :: <field-options-js-type>
  = make(<field-options-js-type>,
         name: "JS_NORMAL",
         value: 0);
define constant $field-options-js-type-js-string :: <field-options-js-type>
  = make(<field-options-js-type>,
         name: "JS_STRING",
         value: 1);
define constant $field-options-js-type-js-number :: <field-options-js-type>
  = make(<field-options-js-type>,
         name: "JS_NUMBER",
         value: 2);

define class <oneof-options> (<protocol-buffer-message>)
  slot oneof-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <oneof-options>;

define class <enum-options> (<protocol-buffer-message>)
  slot enum-options-allow-alias :: <boolean>,
    init-value: #f,
    init-keyword: allow-alias:;
  slot enum-options-deprecated :: <boolean>,
    init-value: #f,
    init-keyword: deprecated:;
  slot enum-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <enum-options>;

define class <enum-value-options> (<protocol-buffer-message>)
  slot enum-value-options-deprecated :: <boolean>,
    init-value: #f,
    init-keyword: deprecated:;
  slot enum-value-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <enum-value-options>;

define class <service-options> (<protocol-buffer-message>)
  slot service-options-deprecated :: <boolean>,
    init-value: #f,
    init-keyword: deprecated:;
  slot service-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <service-options>;

define class <method-options> (<protocol-buffer-message>)
  slot method-options-deprecated :: <boolean>,
    init-value: #f,
    init-keyword: deprecated:;
  slot method-options-idempotency-level :: false-or(<method-options-idempotency-level>),
    init-value: #f,
    init-keyword: idempotency-level:;
  slot method-options-uninterpreted-option :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <method-options>;

define class <method-options-idempotency-level> (<protocol-buffer-enum>) end;

define constant $method-options-idempotency-level-idempotency-unknown :: <method-options-idempotency-level>
  = make(<method-options-idempotency-level>,
         name: "IDEMPOTENCY_UNKNOWN",
         value: 0);
define constant $method-options-idempotency-level-no-side-effects :: <method-options-idempotency-level>
  = make(<method-options-idempotency-level>,
         name: "NO_SIDE_EFFECTS",
         value: 1);
define constant $method-options-idempotency-level-idempotent :: <method-options-idempotency-level>
  = make(<method-options-idempotency-level>,
         name: "IDEMPOTENT",
         value: 2);

define class <uninterpreted-option> (<protocol-buffer-message>)
  slot uninterpreted-option-name :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: name:;
  slot uninterpreted-option-identifier-value :: false-or(<string>),
    init-value: #f,
    init-keyword: identifier-value:;
  slot uninterpreted-option-positive-int-value :: false-or(<uint64>),
    init-value: #f,
    init-keyword: positive-int-value:;
  slot uninterpreted-option-negative-int-value :: false-or(<int64>),
    init-value: #f,
    init-keyword: negative-int-value:;
  slot uninterpreted-option-double-value :: false-or(<double-float>),
    init-value: #f,
    init-keyword: double-value:;
  slot uninterpreted-option-string-value :: false-or(<byte-vector>),
    init-value: #f,
    init-keyword: string-value:;
  slot uninterpreted-option-aggregate-value :: false-or(<string>),
    init-value: #f,
    init-keyword: aggregate-value:;
end class <uninterpreted-option>;

define class <uninterpreted-option-name-part> (<protocol-buffer-message>)
  slot uninterpreted-option-name-part-name-part :: false-or(<string>),
    init-value: #f,
    init-keyword: name-part:;
  slot uninterpreted-option-name-part-is-extension :: <boolean>,
    init-value: #f,
    init-keyword: is-extension:;
end class <uninterpreted-option-name-part>;

define class <source-code-info> (<protocol-buffer-message>)
  slot source-code-info-location :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: location:;
end class <source-code-info>;

define class <source-code-info-location> (<protocol-buffer-message>)
  slot source-code-info-location-path :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: path:;
  slot source-code-info-location-span :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: span:;
  slot source-code-info-location-leading-comments :: false-or(<string>),
    init-value: #f,
    init-keyword: leading-comments:;
  slot source-code-info-location-trailing-comments :: false-or(<string>),
    init-value: #f,
    init-keyword: trailing-comments:;
  slot source-code-info-location-leading-detached-comments :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: leading-detached-comments:;
end class <source-code-info-location>;

define class <generated-code-info> (<protocol-buffer-message>)
  slot generated-code-info-annotation :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: annotation:;
end class <generated-code-info>;

define class <generated-code-info-annotation> (<protocol-buffer-message>)
  slot generated-code-info-annotation-path :: false-or(<stretchy-vector>),
    init-value: #f,
    init-keyword: path:;
  slot generated-code-info-annotation-source-file :: false-or(<string>),
    init-value: #f,
    init-keyword: source-file:;
  slot generated-code-info-annotation-begin :: false-or(<int32>),
    init-value: #f,
    init-keyword: begin:;
  slot generated-code-info-annotation-end :: false-or(<int32>),
    init-value: #f,
    init-keyword: end:;
  slot generated-code-info-annotation-semantic :: false-or(<generated-code-info-annotation-semantic>),
    init-value: #f,
    init-keyword: semantic:;
end class <generated-code-info-annotation>;

define class <generated-code-info-annotation-semantic> (<protocol-buffer-enum>) end;

define constant $generated-code-info-annotation-semantic-none :: <generated-code-info-annotation-semantic>
  = make(<generated-code-info-annotation-semantic>,
         name: "NONE",
         value: 0);
define constant $generated-code-info-annotation-semantic-set :: <generated-code-info-annotation-semantic>
  = make(<generated-code-info-annotation-semantic>,
         name: "SET",
         value: 1);
define constant $generated-code-info-annotation-semantic-alias :: <generated-code-info-annotation-semantic>
  = make(<generated-code-info-annotation-semantic>,
         name: "ALIAS",
         value: 2);

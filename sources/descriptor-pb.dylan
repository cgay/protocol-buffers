Module: google-protobuf

define class <file-descriptor-set> (<protocol-buffer-message>)
  slot file-descriptor-set-file :: <object>,
    init-value: #f,
    init-keyword: file:;
end class <file-descriptor-set>;

define class <file-descriptor-proto> (<protocol-buffer-message>)
  slot file-descriptor-proto-name :: <object>,
    init-value: #f,
    init-keyword: name:;
  slot file-descriptor-proto-package :: <object>,
    init-value: #f,
    init-keyword: package:;
  slot file-descriptor-proto-dependency :: <object>,
    init-value: #f,
    init-keyword: dependency:;
  slot file-descriptor-proto-public-dependency :: <object>,
    init-value: #f,
    init-keyword: public-dependency:;
  slot file-descriptor-proto-weak-dependency :: <object>,
    init-value: #f,
    init-keyword: weak-dependency:;
  slot file-descriptor-proto-message-type :: <object>,
    init-value: #f,
    init-keyword: message-type:;
  slot file-descriptor-proto-enum-type :: <object>,
    init-value: #f,
    init-keyword: enum-type:;
  slot file-descriptor-proto-service :: <object>,
    init-value: #f,
    init-keyword: service:;
  slot file-descriptor-proto-extension :: <object>,
    init-value: #f,
    init-keyword: extension:;
  slot file-descriptor-proto-options :: <object>,
    init-value: #f,
    init-keyword: options:;
  slot file-descriptor-proto-source-code-info :: <object>,
    init-value: #f,
    init-keyword: source-code-info:;
  slot file-descriptor-proto-syntax :: <object>,
    init-value: #f,
    init-keyword: syntax:;
  slot file-descriptor-proto-edition :: <object>,
    init-value: #f,
    init-keyword: edition:;
end class <file-descriptor-proto>;

define class <descriptor-proto> (<protocol-buffer-message>)
  slot descriptor-proto-name :: <object>,
    init-value: #f,
    init-keyword: name:;
  slot descriptor-proto-field :: <object>,
    init-value: #f,
    init-keyword: field:;
  slot descriptor-proto-extension :: <object>,
    init-value: #f,
    init-keyword: extension:;
  slot descriptor-proto-nested-type :: <object>,
    init-value: #f,
    init-keyword: nested-type:;
  slot descriptor-proto-enum-type :: <object>,
    init-value: #f,
    init-keyword: enum-type:;
  slot descriptor-proto-extension-range :: <object>,
    init-value: #f,
    init-keyword: extension-range:;
  slot descriptor-proto-oneof-decl :: <object>,
    init-value: #f,
    init-keyword: oneof-decl:;
  slot descriptor-proto-options :: <object>,
    init-value: #f,
    init-keyword: options:;
  slot descriptor-proto-reserved-range :: <object>,
    init-value: #f,
    init-keyword: reserved-range:;
  slot descriptor-proto-reserved-name :: <object>,
    init-value: #f,
    init-keyword: reserved-name:;
end class <descriptor-proto>;

define class <descriptor-proto-extension-range> (<protocol-buffer-message>)
  slot descriptor-proto-extension-range-start :: <object>,
    init-value: #f,
    init-keyword: start:;
  slot descriptor-proto-extension-range-end :: <object>,
    init-value: #f,
    init-keyword: end:;
  slot descriptor-proto-extension-range-options :: <object>,
    init-value: #f,
    init-keyword: options:;
end class <descriptor-proto-extension-range>;

define class <descriptor-proto-reserved-range> (<protocol-buffer-message>)
  slot descriptor-proto-reserved-range-start :: <object>,
    init-value: #f,
    init-keyword: start:;
  slot descriptor-proto-reserved-range-end :: <object>,
    init-value: #f,
    init-keyword: end:;
end class <descriptor-proto-reserved-range>;

define class <extension-range-options> (<protocol-buffer-message>)
  slot extension-range-options-uninterpreted-option :: <object>,
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <extension-range-options>;

define class <field-descriptor-proto> (<protocol-buffer-message>)
  slot field-descriptor-proto-name :: <object>,
    init-value: #f,
    init-keyword: name:;
  slot field-descriptor-proto-number :: <object>,
    init-value: #f,
    init-keyword: number:;
  slot field-descriptor-proto-label :: <object>,
    init-value: #f,
    init-keyword: label:;
  slot field-descriptor-proto-type :: <object>,
    init-value: #f,
    init-keyword: type:;
  slot field-descriptor-proto-type-name :: <object>,
    init-value: #f,
    init-keyword: type-name:;
  slot field-descriptor-proto-extendee :: <object>,
    init-value: #f,
    init-keyword: extendee:;
  slot field-descriptor-proto-default-value :: <object>,
    init-value: #f,
    init-keyword: default-value:;
  slot field-descriptor-proto-oneof-index :: <object>,
    init-value: #f,
    init-keyword: oneof-index:;
  slot field-descriptor-proto-json-name :: <object>,
    init-value: #f,
    init-keyword: json-name:;
  slot field-descriptor-proto-options :: <object>,
    init-value: #f,
    init-keyword: options:;
  slot field-descriptor-proto-proto3-optional :: <object>,
    init-value: #f,
    init-keyword: proto3-optional:;
end class <field-descriptor-proto>;

define class <field-descriptor-proto-type> (<protocol-buffer-enum>) end;

define constant $field-descriptor-proto-type-type-double :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_DOUBLE",
         value: 1);
define constant $field-descriptor-proto-type-type-float :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_FLOAT",
         value: 2);
define constant $field-descriptor-proto-type-type-int64 :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_INT64",
         value: 3);
define constant $field-descriptor-proto-type-type-uint64 :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_UINT64",
         value: 4);
define constant $field-descriptor-proto-type-type-int32 :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_INT32",
         value: 5);
define constant $field-descriptor-proto-type-type-fixed64 :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_FIXED64",
         value: 6);
define constant $field-descriptor-proto-type-type-fixed32 :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_FIXED32",
         value: 7);
define constant $field-descriptor-proto-type-type-bool :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_BOOL",
         value: 8);
define constant $field-descriptor-proto-type-type-string :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_STRING",
         value: 9);
define constant $field-descriptor-proto-type-type-group :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_GROUP",
         value: 10);
define constant $field-descriptor-proto-type-type-message :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_MESSAGE",
         value: 11);
define constant $field-descriptor-proto-type-type-bytes :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_BYTES",
         value: 12);
define constant $field-descriptor-proto-type-type-uint32 :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_UINT32",
         value: 13);
define constant $field-descriptor-proto-type-type-enum :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_ENUM",
         value: 14);
define constant $field-descriptor-proto-type-type-sfixed32 :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_SFIXED32",
         value: 15);
define constant $field-descriptor-proto-type-type-sfixed64 :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_SFIXED64",
         value: 16);
define constant $field-descriptor-proto-type-type-sint32 :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_SINT32",
         value: 17);
define constant $field-descriptor-proto-type-type-sint64 :: <object>
  = make(<field-descriptor-proto-type>,
         name: "TYPE_SINT64",
         value: 18);

define class <field-descriptor-proto-label> (<protocol-buffer-enum>) end;

define constant $field-descriptor-proto-label-label-optional :: <object>
  = make(<field-descriptor-proto-label>,
         name: "LABEL_OPTIONAL",
         value: 1);
define constant $field-descriptor-proto-label-label-required :: <object>
  = make(<field-descriptor-proto-label>,
         name: "LABEL_REQUIRED",
         value: 2);
define constant $field-descriptor-proto-label-label-repeated :: <object>
  = make(<field-descriptor-proto-label>,
         name: "LABEL_REPEATED",
         value: 3);

define class <oneof-descriptor-proto> (<protocol-buffer-message>)
  slot oneof-descriptor-proto-name :: <object>,
    init-value: #f,
    init-keyword: name:;
  slot oneof-descriptor-proto-options :: <object>,
    init-value: #f,
    init-keyword: options:;
end class <oneof-descriptor-proto>;

define class <enum-descriptor-proto> (<protocol-buffer-message>)
  slot enum-descriptor-proto-name :: <object>,
    init-value: #f,
    init-keyword: name:;
  slot enum-descriptor-proto-value :: <object>,
    init-value: #f,
    init-keyword: value:;
  slot enum-descriptor-proto-options :: <object>,
    init-value: #f,
    init-keyword: options:;
  slot enum-descriptor-proto-reserved-range :: <object>,
    init-value: #f,
    init-keyword: reserved-range:;
  slot enum-descriptor-proto-reserved-name :: <object>,
    init-value: #f,
    init-keyword: reserved-name:;
end class <enum-descriptor-proto>;

define class <enum-descriptor-proto-enum-reserved-range> (<protocol-buffer-message>)
  slot enum-descriptor-proto-enum-reserved-range-start :: <object>,
    init-value: #f,
    init-keyword: start:;
  slot enum-descriptor-proto-enum-reserved-range-end :: <object>,
    init-value: #f,
    init-keyword: end:;
end class <enum-descriptor-proto-enum-reserved-range>;

define class <enum-value-descriptor-proto> (<protocol-buffer-message>)
  slot enum-value-descriptor-proto-name :: <object>,
    init-value: #f,
    init-keyword: name:;
  slot enum-value-descriptor-proto-number :: <object>,
    init-value: #f,
    init-keyword: number:;
  slot enum-value-descriptor-proto-options :: <object>,
    init-value: #f,
    init-keyword: options:;
end class <enum-value-descriptor-proto>;

define class <service-descriptor-proto> (<protocol-buffer-message>)
  slot service-descriptor-proto-name :: <object>,
    init-value: #f,
    init-keyword: name:;
  slot service-descriptor-proto-method :: <object>,
    init-value: #f,
    init-keyword: method:;
  slot service-descriptor-proto-options :: <object>,
    init-value: #f,
    init-keyword: options:;
end class <service-descriptor-proto>;

define class <method-descriptor-proto> (<protocol-buffer-message>)
  slot method-descriptor-proto-name :: <object>,
    init-value: #f,
    init-keyword: name:;
  slot method-descriptor-proto-input-type :: <object>,
    init-value: #f,
    init-keyword: input-type:;
  slot method-descriptor-proto-output-type :: <object>,
    init-value: #f,
    init-keyword: output-type:;
  slot method-descriptor-proto-options :: <object>,
    init-value: #f,
    init-keyword: options:;
  slot method-descriptor-proto-client-streaming :: <object>,
    init-value: #f,
    init-keyword: client-streaming:;
  slot method-descriptor-proto-server-streaming :: <object>,
    init-value: #f,
    init-keyword: server-streaming:;
end class <method-descriptor-proto>;

define class <file-options> (<protocol-buffer-message>)
  slot file-options-java-package :: <object>,
    init-value: #f,
    init-keyword: java-package:;
  slot file-options-java-outer-classname :: <object>,
    init-value: #f,
    init-keyword: java-outer-classname:;
  slot file-options-java-multiple-files :: <object>,
    init-value: #f,
    init-keyword: java-multiple-files:;
  slot file-options-java-generate-equals-and-hash :: <object>,
    init-value: #f,
    init-keyword: java-generate-equals-and-hash:;
  slot file-options-java-string-check-utf8 :: <object>,
    init-value: #f,
    init-keyword: java-string-check-utf8:;
  slot file-options-optimize-for :: <object>,
    init-value: #f,
    init-keyword: optimize-for:;
  slot file-options-go-package :: <object>,
    init-value: #f,
    init-keyword: go-package:;
  slot file-options-cc-generic-services :: <object>,
    init-value: #f,
    init-keyword: cc-generic-services:;
  slot file-options-java-generic-services :: <object>,
    init-value: #f,
    init-keyword: java-generic-services:;
  slot file-options-py-generic-services :: <object>,
    init-value: #f,
    init-keyword: py-generic-services:;
  slot file-options-php-generic-services :: <object>,
    init-value: #f,
    init-keyword: php-generic-services:;
  slot file-options-deprecated :: <object>,
    init-value: #f,
    init-keyword: deprecated:;
  slot file-options-cc-enable-arenas :: <object>,
    init-value: #f,
    init-keyword: cc-enable-arenas:;
  slot file-options-objc-class-prefix :: <object>,
    init-value: #f,
    init-keyword: objc-class-prefix:;
  slot file-options-csharp-namespace :: <object>,
    init-value: #f,
    init-keyword: csharp-namespace:;
  slot file-options-swift-prefix :: <object>,
    init-value: #f,
    init-keyword: swift-prefix:;
  slot file-options-php-class-prefix :: <object>,
    init-value: #f,
    init-keyword: php-class-prefix:;
  slot file-options-php-namespace :: <object>,
    init-value: #f,
    init-keyword: php-namespace:;
  slot file-options-php-metadata-namespace :: <object>,
    init-value: #f,
    init-keyword: php-metadata-namespace:;
  slot file-options-ruby-package :: <object>,
    init-value: #f,
    init-keyword: ruby-package:;
  slot file-options-uninterpreted-option :: <object>,
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <file-options>;

define class <file-options-optimize-mode> (<protocol-buffer-enum>) end;

define constant $file-options-optimize-mode-speed :: <object>
  = make(<file-options-optimize-mode>,
         name: "SPEED",
         value: 1);
define constant $file-options-optimize-mode-code-size :: <object>
  = make(<file-options-optimize-mode>,
         name: "CODE_SIZE",
         value: 2);
define constant $file-options-optimize-mode-lite-runtime :: <object>
  = make(<file-options-optimize-mode>,
         name: "LITE_RUNTIME",
         value: 3);

define class <message-options> (<protocol-buffer-message>)
  slot message-options-message-set-wire-format :: <object>,
    init-value: #f,
    init-keyword: message-set-wire-format:;
  slot message-options-no-standard-descriptor-accessor :: <object>,
    init-value: #f,
    init-keyword: no-standard-descriptor-accessor:;
  slot message-options-deprecated :: <object>,
    init-value: #f,
    init-keyword: deprecated:;
  slot message-options-map-entry :: <object>,
    init-value: #f,
    init-keyword: map-entry:;
  slot message-options-uninterpreted-option :: <object>,
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <message-options>;

define class <field-options> (<protocol-buffer-message>)
  slot field-options-ctype :: <object>,
    init-value: #f,
    init-keyword: ctype:;
  slot field-options-packed :: <object>,
    init-value: #f,
    init-keyword: packed:;
  slot field-options-jstype :: <object>,
    init-value: #f,
    init-keyword: jstype:;
  slot field-options-lazy :: <object>,
    init-value: #f,
    init-keyword: lazy:;
  slot field-options-unverified-lazy :: <object>,
    init-value: #f,
    init-keyword: unverified-lazy:;
  slot field-options-deprecated :: <object>,
    init-value: #f,
    init-keyword: deprecated:;
  slot field-options-weak :: <object>,
    init-value: #f,
    init-keyword: weak:;
  slot field-options-uninterpreted-option :: <object>,
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <field-options>;

define class <field-options-ctype> (<protocol-buffer-enum>) end;

define constant $field-options-ctype-string :: <object>
  = make(<field-options-ctype>,
         name: "STRING",
         value: 0);
define constant $field-options-ctype-cord :: <object>
  = make(<field-options-ctype>,
         name: "CORD",
         value: 1);
define constant $field-options-ctype-string-piece :: <object>
  = make(<field-options-ctype>,
         name: "STRING_PIECE",
         value: 2);

define class <field-options-js-type> (<protocol-buffer-enum>) end;

define constant $field-options-js-type-js-normal :: <object>
  = make(<field-options-js-type>,
         name: "JS_NORMAL",
         value: 0);
define constant $field-options-js-type-js-string :: <object>
  = make(<field-options-js-type>,
         name: "JS_STRING",
         value: 1);
define constant $field-options-js-type-js-number :: <object>
  = make(<field-options-js-type>,
         name: "JS_NUMBER",
         value: 2);

define class <oneof-options> (<protocol-buffer-message>)
  slot oneof-options-uninterpreted-option :: <object>,
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <oneof-options>;

define class <enum-options> (<protocol-buffer-message>)
  slot enum-options-allow-alias :: <object>,
    init-value: #f,
    init-keyword: allow-alias:;
  slot enum-options-deprecated :: <object>,
    init-value: #f,
    init-keyword: deprecated:;
  slot enum-options-uninterpreted-option :: <object>,
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <enum-options>;

define class <enum-value-options> (<protocol-buffer-message>)
  slot enum-value-options-deprecated :: <object>,
    init-value: #f,
    init-keyword: deprecated:;
  slot enum-value-options-uninterpreted-option :: <object>,
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <enum-value-options>;

define class <service-options> (<protocol-buffer-message>)
  slot service-options-deprecated :: <object>,
    init-value: #f,
    init-keyword: deprecated:;
  slot service-options-uninterpreted-option :: <object>,
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <service-options>;

define class <method-options> (<protocol-buffer-message>)
  slot method-options-deprecated :: <object>,
    init-value: #f,
    init-keyword: deprecated:;
  slot method-options-idempotency-level :: <object>,
    init-value: #f,
    init-keyword: idempotency-level:;
  slot method-options-uninterpreted-option :: <object>,
    init-value: #f,
    init-keyword: uninterpreted-option:;
end class <method-options>;

define class <method-options-idempotency-level> (<protocol-buffer-enum>) end;

define constant $method-options-idempotency-level-idempotency-unknown :: <object>
  = make(<method-options-idempotency-level>,
         name: "IDEMPOTENCY_UNKNOWN",
         value: 0);
define constant $method-options-idempotency-level-no-side-effects :: <object>
  = make(<method-options-idempotency-level>,
         name: "NO_SIDE_EFFECTS",
         value: 1);
define constant $method-options-idempotency-level-idempotent :: <object>
  = make(<method-options-idempotency-level>,
         name: "IDEMPOTENT",
         value: 2);

define class <uninterpreted-option> (<protocol-buffer-message>)
  slot uninterpreted-option-name :: <object>,
    init-value: #f,
    init-keyword: name:;
  slot uninterpreted-option-identifier-value :: <object>,
    init-value: #f,
    init-keyword: identifier-value:;
  slot uninterpreted-option-positive-int-value :: <object>,
    init-value: #f,
    init-keyword: positive-int-value:;
  slot uninterpreted-option-negative-int-value :: <object>,
    init-value: #f,
    init-keyword: negative-int-value:;
  slot uninterpreted-option-double-value :: <object>,
    init-value: #f,
    init-keyword: double-value:;
  slot uninterpreted-option-string-value :: <object>,
    init-value: #f,
    init-keyword: string-value:;
  slot uninterpreted-option-aggregate-value :: <object>,
    init-value: #f,
    init-keyword: aggregate-value:;
end class <uninterpreted-option>;

define class <uninterpreted-option-name-part> (<protocol-buffer-message>)
  slot uninterpreted-option-name-part-name-part :: <object>,
    init-value: #f,
    init-keyword: name-part:;
  slot uninterpreted-option-name-part-is-extension :: <object>,
    init-value: #f,
    init-keyword: is-extension:;
end class <uninterpreted-option-name-part>;

define class <source-code-info> (<protocol-buffer-message>)
  slot source-code-info-location :: <object>,
    init-value: #f,
    init-keyword: location:;
end class <source-code-info>;

define class <source-code-info-location> (<protocol-buffer-message>)
  slot source-code-info-location-path :: <object>,
    init-value: #f,
    init-keyword: path:;
  slot source-code-info-location-span :: <object>,
    init-value: #f,
    init-keyword: span:;
  slot source-code-info-location-leading-comments :: <object>,
    init-value: #f,
    init-keyword: leading-comments:;
  slot source-code-info-location-trailing-comments :: <object>,
    init-value: #f,
    init-keyword: trailing-comments:;
  slot source-code-info-location-leading-detached-comments :: <object>,
    init-value: #f,
    init-keyword: leading-detached-comments:;
end class <source-code-info-location>;

define class <generated-code-info> (<protocol-buffer-message>)
  slot generated-code-info-annotation :: <object>,
    init-value: #f,
    init-keyword: annotation:;
end class <generated-code-info>;

define class <generated-code-info-annotation> (<protocol-buffer-message>)
  slot generated-code-info-annotation-path :: <object>,
    init-value: #f,
    init-keyword: path:;
  slot generated-code-info-annotation-source-file :: <object>,
    init-value: #f,
    init-keyword: source-file:;
  slot generated-code-info-annotation-begin :: <object>,
    init-value: #f,
    init-keyword: begin:;
  slot generated-code-info-annotation-end :: <object>,
    init-value: #f,
    init-keyword: end:;
  slot generated-code-info-annotation-semantic :: <object>,
    init-value: #f,
    init-keyword: semantic:;
end class <generated-code-info-annotation>;

define class <generated-code-info-annotation-semantic> (<protocol-buffer-enum>) end;

define constant $generated-code-info-annotation-semantic-none :: <object>
  = make(<generated-code-info-annotation-semantic>,
         name: "NONE",
         value: 0);
define constant $generated-code-info-annotation-semantic-set :: <object>
  = make(<generated-code-info-annotation-semantic>,
         name: "SET",
         value: 1);
define constant $generated-code-info-annotation-semantic-alias :: <object>
  = make(<generated-code-info-annotation-semantic>,
         name: "ALIAS",
         value: 2);

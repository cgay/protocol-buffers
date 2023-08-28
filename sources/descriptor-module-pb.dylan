Module: dylan-user

// *** This code was automatically generated by pbgen. ***

define module google-protobuf
  use common-dylan;
  use format;                   // added by hand
  use print;                    // added by hand
  use streams;                  // added by hand
  use protocol-buffers;

  export
    <file-descriptor-set>,
    file-descriptor-set-file,
    file-descriptor-set-file-setter,
    <file-descriptor-proto>,
    file-descriptor-proto-name,
    file-descriptor-proto-name-setter,
    file-descriptor-proto-package,
    file-descriptor-proto-package-setter,
    file-descriptor-proto-dependency,
    file-descriptor-proto-dependency-setter,
    file-descriptor-proto-public-dependency,
    file-descriptor-proto-public-dependency-setter,
    file-descriptor-proto-weak-dependency,
    file-descriptor-proto-weak-dependency-setter,
    file-descriptor-proto-message-type,
    file-descriptor-proto-message-type-setter,
    file-descriptor-proto-enum-type,
    file-descriptor-proto-enum-type-setter,
    file-descriptor-proto-service,
    file-descriptor-proto-service-setter,
    file-descriptor-proto-extension,
    file-descriptor-proto-extension-setter,
    file-descriptor-proto-options,
    file-descriptor-proto-options-setter,
    file-descriptor-proto-source-code-info,
    file-descriptor-proto-source-code-info-setter,
    file-descriptor-proto-syntax,
    file-descriptor-proto-syntax-setter,
    file-descriptor-proto-edition,
    file-descriptor-proto-edition-setter,
    <descriptor-proto>,
    descriptor-proto-name,
    descriptor-proto-name-setter,
    descriptor-proto-field,
    descriptor-proto-field-setter,
    descriptor-proto-extension,
    descriptor-proto-extension-setter,
    descriptor-proto-nested-type,
    descriptor-proto-nested-type-setter,
    descriptor-proto-enum-type,
    descriptor-proto-enum-type-setter,
    descriptor-proto-extension-range,
    descriptor-proto-extension-range-setter,
    descriptor-proto-oneof-decl,
    descriptor-proto-oneof-decl-setter,
    descriptor-proto-options,
    descriptor-proto-options-setter,
    descriptor-proto-reserved-range,
    descriptor-proto-reserved-range-setter,
    descriptor-proto-reserved-name,
    descriptor-proto-reserved-name-setter,
    <descriptor-proto-extension-range>,
    descriptor-proto-extension-range-start,
    descriptor-proto-extension-range-start-setter,
    descriptor-proto-extension-range-end,
    descriptor-proto-extension-range-end-setter,
    descriptor-proto-extension-range-options,
    descriptor-proto-extension-range-options-setter,
    <descriptor-proto-reserved-range>,
    descriptor-proto-reserved-range-start,
    descriptor-proto-reserved-range-start-setter,
    descriptor-proto-reserved-range-end,
    descriptor-proto-reserved-range-end-setter,
    <extension-range-options>,
    extension-range-options-uninterpreted-option,
    extension-range-options-uninterpreted-option-setter,
    <field-descriptor-proto>,
    field-descriptor-proto-name,
    field-descriptor-proto-name-setter,
    field-descriptor-proto-number,
    field-descriptor-proto-number-setter,
    field-descriptor-proto-label,
    field-descriptor-proto-label-setter,
    field-descriptor-proto-type,
    field-descriptor-proto-type-setter,
    field-descriptor-proto-type-name,
    field-descriptor-proto-type-name-setter,
    field-descriptor-proto-extendee,
    field-descriptor-proto-extendee-setter,
    field-descriptor-proto-default-value,
    field-descriptor-proto-default-value-setter,
    field-descriptor-proto-oneof-index,
    field-descriptor-proto-oneof-index-setter,
    field-descriptor-proto-json-name,
    field-descriptor-proto-json-name-setter,
    field-descriptor-proto-options,
    field-descriptor-proto-options-setter,
    field-descriptor-proto-proto3-optional,
    field-descriptor-proto-proto3-optional-setter,
    <field-descriptor-proto-type>,
    $field-descriptor-proto-type-type-double,
    $field-descriptor-proto-type-type-float,
    $field-descriptor-proto-type-type-int64,
    $field-descriptor-proto-type-type-uint64,
    $field-descriptor-proto-type-type-int32,
    $field-descriptor-proto-type-type-fixed64,
    $field-descriptor-proto-type-type-fixed32,
    $field-descriptor-proto-type-type-bool,
    $field-descriptor-proto-type-type-string,
    $field-descriptor-proto-type-type-group,
    $field-descriptor-proto-type-type-message,
    $field-descriptor-proto-type-type-bytes,
    $field-descriptor-proto-type-type-uint32,
    $field-descriptor-proto-type-type-enum,
    $field-descriptor-proto-type-type-sfixed32,
    $field-descriptor-proto-type-type-sfixed64,
    $field-descriptor-proto-type-type-sint32,
    $field-descriptor-proto-type-type-sint64,
    <field-descriptor-proto-label>,
    $field-descriptor-proto-label-label-optional,
    $field-descriptor-proto-label-label-required,
    $field-descriptor-proto-label-label-repeated,
    <oneof-descriptor-proto>,
    oneof-descriptor-proto-name,
    oneof-descriptor-proto-name-setter,
    oneof-descriptor-proto-options,
    oneof-descriptor-proto-options-setter,
    <enum-descriptor-proto>,
    enum-descriptor-proto-name,
    enum-descriptor-proto-name-setter,
    enum-descriptor-proto-value,
    enum-descriptor-proto-value-setter,
    enum-descriptor-proto-options,
    enum-descriptor-proto-options-setter,
    enum-descriptor-proto-reserved-range,
    enum-descriptor-proto-reserved-range-setter,
    enum-descriptor-proto-reserved-name,
    enum-descriptor-proto-reserved-name-setter,
    <enum-descriptor-proto-enum-reserved-range>,
    enum-descriptor-proto-enum-reserved-range-start,
    enum-descriptor-proto-enum-reserved-range-start-setter,
    enum-descriptor-proto-enum-reserved-range-end,
    enum-descriptor-proto-enum-reserved-range-end-setter,
    <enum-value-descriptor-proto>,
    enum-value-descriptor-proto-name,
    enum-value-descriptor-proto-name-setter,
    enum-value-descriptor-proto-number,
    enum-value-descriptor-proto-number-setter,
    enum-value-descriptor-proto-options,
    enum-value-descriptor-proto-options-setter,
    <service-descriptor-proto>,
    service-descriptor-proto-name,
    service-descriptor-proto-name-setter,
    service-descriptor-proto-method,
    service-descriptor-proto-method-setter,
    service-descriptor-proto-options,
    service-descriptor-proto-options-setter,
    <method-descriptor-proto>,
    method-descriptor-proto-name,
    method-descriptor-proto-name-setter,
    method-descriptor-proto-input-type,
    method-descriptor-proto-input-type-setter,
    method-descriptor-proto-output-type,
    method-descriptor-proto-output-type-setter,
    method-descriptor-proto-options,
    method-descriptor-proto-options-setter,
    method-descriptor-proto-client-streaming,
    method-descriptor-proto-client-streaming-setter,
    method-descriptor-proto-server-streaming,
    method-descriptor-proto-server-streaming-setter,
    <file-options>,
    file-options-java-package,
    file-options-java-package-setter,
    file-options-java-outer-classname,
    file-options-java-outer-classname-setter,
    file-options-java-multiple-files,
    file-options-java-multiple-files-setter,
    file-options-java-generate-equals-and-hash,
    file-options-java-generate-equals-and-hash-setter,
    file-options-java-string-check-utf8,
    file-options-java-string-check-utf8-setter,
    file-options-optimize-for,
    file-options-optimize-for-setter,
    file-options-go-package,
    file-options-go-package-setter,
    file-options-cc-generic-services,
    file-options-cc-generic-services-setter,
    file-options-java-generic-services,
    file-options-java-generic-services-setter,
    file-options-py-generic-services,
    file-options-py-generic-services-setter,
    file-options-php-generic-services,
    file-options-php-generic-services-setter,
    file-options-deprecated,
    file-options-deprecated-setter,
    file-options-cc-enable-arenas,
    file-options-cc-enable-arenas-setter,
    file-options-objc-class-prefix,
    file-options-objc-class-prefix-setter,
    file-options-csharp-namespace,
    file-options-csharp-namespace-setter,
    file-options-swift-prefix,
    file-options-swift-prefix-setter,
    file-options-php-class-prefix,
    file-options-php-class-prefix-setter,
    file-options-php-namespace,
    file-options-php-namespace-setter,
    file-options-php-metadata-namespace,
    file-options-php-metadata-namespace-setter,
    file-options-ruby-package,
    file-options-ruby-package-setter,
    file-options-uninterpreted-option,
    file-options-uninterpreted-option-setter,
    <file-options-optimize-mode>,
    $file-options-optimize-mode-speed,
    $file-options-optimize-mode-code-size,
    $file-options-optimize-mode-lite-runtime,
    <message-options>,
    message-options-message-set-wire-format,
    message-options-message-set-wire-format-setter,
    message-options-no-standard-descriptor-accessor,
    message-options-no-standard-descriptor-accessor-setter,
    message-options-deprecated,
    message-options-deprecated-setter,
    message-options-map-entry,
    message-options-map-entry-setter,
    message-options-uninterpreted-option,
    message-options-uninterpreted-option-setter,
    <field-options>,
    field-options-ctype,
    field-options-ctype-setter,
    field-options-packed,
    field-options-packed-setter,
    field-options-jstype,
    field-options-jstype-setter,
    field-options-lazy,
    field-options-lazy-setter,
    field-options-unverified-lazy,
    field-options-unverified-lazy-setter,
    field-options-deprecated,
    field-options-deprecated-setter,
    field-options-weak,
    field-options-weak-setter,
    field-options-uninterpreted-option,
    field-options-uninterpreted-option-setter,
    <field-options-ctype>,
    $field-options-ctype-string,
    $field-options-ctype-cord,
    $field-options-ctype-string-piece,
    <field-options-js-type>,
    $field-options-js-type-js-normal,
    $field-options-js-type-js-string,
    $field-options-js-type-js-number,
    <oneof-options>,
    oneof-options-uninterpreted-option,
    oneof-options-uninterpreted-option-setter,
    <enum-options>,
    enum-options-allow-alias,
    enum-options-allow-alias-setter,
    enum-options-deprecated,
    enum-options-deprecated-setter,
    enum-options-uninterpreted-option,
    enum-options-uninterpreted-option-setter,
    <enum-value-options>,
    enum-value-options-deprecated,
    enum-value-options-deprecated-setter,
    enum-value-options-uninterpreted-option,
    enum-value-options-uninterpreted-option-setter,
    <service-options>,
    service-options-deprecated,
    service-options-deprecated-setter,
    service-options-uninterpreted-option,
    service-options-uninterpreted-option-setter,
    <method-options>,
    method-options-deprecated,
    method-options-deprecated-setter,
    method-options-idempotency-level,
    method-options-idempotency-level-setter,
    method-options-uninterpreted-option,
    method-options-uninterpreted-option-setter,
    <method-options-idempotency-level>,
    $method-options-idempotency-level-idempotency-unknown,
    $method-options-idempotency-level-no-side-effects,
    $method-options-idempotency-level-idempotent,
    <uninterpreted-option>,
    uninterpreted-option-name,
    uninterpreted-option-name-setter,
    uninterpreted-option-identifier-value,
    uninterpreted-option-identifier-value-setter,
    uninterpreted-option-positive-int-value,
    uninterpreted-option-positive-int-value-setter,
    uninterpreted-option-negative-int-value,
    uninterpreted-option-negative-int-value-setter,
    uninterpreted-option-double-value,
    uninterpreted-option-double-value-setter,
    uninterpreted-option-string-value,
    uninterpreted-option-string-value-setter,
    uninterpreted-option-aggregate-value,
    uninterpreted-option-aggregate-value-setter,
    <uninterpreted-option-name-part>,
    uninterpreted-option-name-part-name-part,
    uninterpreted-option-name-part-name-part-setter,
    uninterpreted-option-name-part-is-extension,
    uninterpreted-option-name-part-is-extension-setter,
    <source-code-info>,
    source-code-info-location,
    source-code-info-location-setter,
    <source-code-info-location>,
    source-code-info-location-path,
    source-code-info-location-path-setter,
    source-code-info-location-span,
    source-code-info-location-span-setter,
    source-code-info-location-leading-comments,
    source-code-info-location-leading-comments-setter,
    source-code-info-location-trailing-comments,
    source-code-info-location-trailing-comments-setter,
    source-code-info-location-leading-detached-comments,
    source-code-info-location-leading-detached-comments-setter,
    <generated-code-info>,
    generated-code-info-annotation,
    generated-code-info-annotation-setter,
    <generated-code-info-annotation>,
    generated-code-info-annotation-path,
    generated-code-info-annotation-path-setter,
    generated-code-info-annotation-source-file,
    generated-code-info-annotation-source-file-setter,
    generated-code-info-annotation-begin,
    generated-code-info-annotation-begin-setter,
    generated-code-info-annotation-end,
    generated-code-info-annotation-end-setter,
    generated-code-info-annotation-semantic,
    generated-code-info-annotation-semantic-setter,
    <generated-code-info-annotation-semantic>,
    $generated-code-info-annotation-semantic-none,
    $generated-code-info-annotation-semantic-set,
    $generated-code-info-annotation-semantic-alias;
end module google-protobuf;

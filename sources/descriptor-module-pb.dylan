Module: dylan-user

// *** This code was automatically generated by pbgen. ***

define module google-protobuf
  use common-dylan;
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
    $field-descriptor-proto-label-label-repeated,
    $field-descriptor-proto-label-label-required,
    $field-descriptor-proto-label-label-optional,
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
    <enum-value-descriptor-proto>,
    enum-value-descriptor-proto-name,
    enum-value-descriptor-proto-name-setter,
    enum-value-descriptor-proto-number,
    enum-value-descriptor-proto-number-setter,
    enum-value-descriptor-proto-options,
    enum-value-descriptor-proto-options-setter,
    <oneof-descriptor-proto>,
    oneof-descriptor-proto-name,
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
    enum-value-options-uninterpreted-option-setter;
end module google-protobuf;

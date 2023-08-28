Module: dylan-user
Synopsis: The public interface to protocol buffers


define module protocol-buffers
  create
    <protocol-buffer-error>,
    <protocol-buffer-object>,
    <protocol-buffer-message>,
    <protocol-buffer-enum>,
    descriptor-name,
    enum-value,
    enum-value-name,

    // Types
    <int32>, <uint32>, <int64>, <uint64>;
end module;

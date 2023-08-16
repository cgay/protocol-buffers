Module: dylan-user
Synopsis: The public interface to protocol buffers


define module protocol-buffers
  create
    <protocol-buffer-error>,
    <protocol-buffer-object>,
    <protocol-buffer-message>,
    <protocol-buffer-enum>,

    // Types
    <int32>, <uint32>;
end module;

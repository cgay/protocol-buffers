Module: protocol-buffers-test-suite


// Example from the end of
// https://protobuf.dev/reference/protobuf/proto3-spec
define constant $example1
  = """
syntax = "proto3";
""";

/* Will move bits from here to $example1 over time...
import public "other.proto";
option java_package = "com.example.foo";
enum EnumAllowingAlias {
  option allow_alias = true;
  EAA_UNSPECIFIED = 0;
  EAA_STARTED = 1;
  EAA_RUNNING = 1;
  EAA_FINISHED = 2 [(custom_option) = "hello world"];
}
message Outer {
  option (my_option).a = true;
  message Inner {   // Level 2
    int64 ival = 1;
  }
  repeated Inner inner_message = 2;
  EnumAllowingAlias enum_field = 3;
  map<int32, string> my_map = 4;
}
*/

define method tokenize (input :: <string>) => (tokens :: <seq>)
  let tokens = make(<stretchy-vector>);
  with-input-from-string (stream = input)
    let (token, index) = read-token(stream);
    while (token)
      let (t, i) = read-token(stream, start: index);
      token := t;
      index := i;
      t & add!(tokens, t);
    end;
  end;
  tokens
end method;

define test test-read-token ()
  let tokens = tokenize($example1);
  assert-equal(#["syntax", "="], tokenize($example1));
end test;

Module: protocol-buffers-test-suite


define test test-camel-to-kebob ()
  check-equal("basic", "camel-case", camel-to-kebob("CamelCase"));
  check-equal("acronym1", "tcp-connection", camel-to-kebob("TCPConnection"));
  check-equal("acronym2", "new-tcp-connection", camel-to-kebob("NewTCPConnection"));
  check-equal("acronym underscore", "new-rpc-dylan-service", camel-to-kebob("new_RPC_DylanService"));
  check-equal("all the things", "rpc-dylan-service-get-request", camel-to-kebob("RPC_DylanService_get_request"));
  check-equal("digits", "tcp2-name3", camel-to-kebob("TCP2Name3"));
  check-equal("leading underscore", "_foo", camel-to-kebob("_foo"));
end test;

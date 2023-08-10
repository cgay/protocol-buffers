Module: pblex
Synopsis: Scan the given .proto file and print each token, for debugging the lexer.


define function main
    (name :: <string>, arguments :: <vector>)
  if (empty?(arguments))
    format-out("Usage: %s <filename>\n", name);
    exit-application(2);
  end;
  let path = arguments[0];
  block (exit)
    with-open-file (stream = path)
      let lexer = make(<lexer>, stream: stream);
      while (#t)
        let token = next-token(lexer);
        if (~token)
          exit()
        end;
        format-out("%s\n", token);
        force-out();
      end;
    end;
  end block;
  exit-application(0);
end function;

main(application-name(), application-arguments());

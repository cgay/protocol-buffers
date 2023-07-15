Module: protocol-buffers-impl
Synopsis: Interface Definition Language (IDL, a.k.a. .proto file) parser

/* overkill?
define class <token> (<object>)
  constant slot token-value :: <string>, required-init-keyword: value:;
  constant slot token-type :: <token-type>, required-init-keyword: type:;
end class;

define enum <token-type> ()
  $bool;
  $comma;
  $comment;
  $dot;
  $equal;
  $float;
  $int;
  $langle; $rangle;
  $lbrace; $rbrace;
  $lparen; $rpraen;
  $lsquare; $rsquare;
  $semicolon;
  $string;
  $word;
end enum;

define function make-token (value, type)
  make(<token>, value: value, type: type)
end function;

define constant $true = make-token("true", #"bool");
define constant $false = make-token("false", #"bool");

define function ident? (token :: <string>) => (_ :: <boolean>)
  token.size > 0
    & letter?(token[0])
    & every?(method (c)
               letter?(c) | decimal-digit?(c) | c == "_"
             end,
             token)
end function;
*/

define function read-token
    (stream :: <stream>, #key start) => (token, index :: <int>)
  local
    method token-delimiter?
        (ch :: <char>) => (_ :: <bool>)
      whitespace?(ch)
        | member?(ch, "{}[]()<>;.")
    end;
  let ch = peek(stream, on-end-of-stream: #f);
  iterate loop (index = start | 0, prev = #f, char = ch, chars = #())
    case
      ~char | token-delimiter?(char)
        => chars.size > 0 & values(as(<string>, reverse!(chars)),
                                   index);
      otherwise
        => begin
             read-element(stream);
             loop(index + 1, char, peek(stream, on-end-of-stream: #f),
                  pair(char, chars));
           end;
    end case
  end iterate
end function;

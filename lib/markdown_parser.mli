module type MarkdownParser = sig
  type ast

  type token

  val tokenize : in_channel -> token list

  val parse : token list -> ast

  val to_html : ast -> string
end

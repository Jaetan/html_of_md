module type MarkdownParser = sig
  type ast

  type token

  val tokenize : string -> token list

  val parse : token list -> ast

  val to_html : ast -> string
end

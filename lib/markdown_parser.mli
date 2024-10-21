(** The signature for a Markdown parser. Each module implementing this signature
    provides the ability to tokenize Markdown input, parse it into an abstract syntax tree (AST),
    and convert the AST to an HTML representation. *)

module type MarkdownParser = sig
  (** The type representing the abstract syntax tree (AST) produced after parsing. *)
  type ast

  (** The type representing a single token from the Markdown input. *)
  type token

  val tokenize : Uutf.decoder -> token list
  (** [tokenize decoder] takes a UTF-8 decoder and returns a list of tokens extracted
      from the Markdown input. Each token represents a meaningful unit for further parsing.

      @param decoder a UTF-8 decoder for reading the input stream
      @return a list of tokens representing the parsed Markdown content *)

  val parse : token list -> ast
  (** [parse tokens] takes a list of tokens and produces an abstract syntax tree (AST)
      representing the Markdown document structure.

      @param tokens a list of tokens obtained from the tokenizer
      @return the AST representing the parsed Markdown document *)

  val to_html : ast -> string
  (** [to_html ast] converts the abstract syntax tree (AST) into an HTML string.

      @param ast the AST produced from the parser
      @return the HTML representation of the parsed Markdown content *)
end

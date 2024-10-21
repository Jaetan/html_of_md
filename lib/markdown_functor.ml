(** A functor that creates a Markdown processor from any module that implements
    the {!MarkdownParser} signature. This processor is responsible for converting
    Markdown input into HTML. *)

open Markdown_parser

(** The signature for a Markdown processor. This module defines the interface for processing
    Markdown content from a UTF-8 decoder and producing an HTML string as output. *)
module type Processor = sig
  val process : Uutf.decoder -> string
  (** [process decoder] processes the Markdown input provided by the UTF-8 decoder,
      converting it into an HTML string.

      @param decoder a UTF-8 decoder for reading the input stream
      @return the HTML representation of the processed Markdown content *)
end

(** A functor that produces a module implementing the {!Processor} signature, given a
    module that implements the {!MarkdownParser} signature. The resulting processor will
    convert Markdown to HTML using the specified parser.

    @param Parser a module that implements the {!MarkdownParser} signature
    @return a {!Processor} module that processes Markdown input into HTML *)
module MakeMarkdownProcessor (Parser : MarkdownParser) : Processor = struct
  let process decoder =
    let tokens = Parser.tokenize decoder in
    let ast = Parser.parse tokens in
    Parser.to_html ast
end

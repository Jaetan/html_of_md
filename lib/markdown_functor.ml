open Markdown_parser

module type Processor = sig
  val process : Uutf.decoder -> string
end

module MakeMarkdownProcessor (Parser : MarkdownParser) : Processor = struct
  let process decoder =
    let tokens = Parser.tokenize decoder in
    let ast = Parser.parse tokens in
    Parser.to_html ast
end

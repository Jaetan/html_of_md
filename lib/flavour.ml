type flavour = GFM | CommonMark | Pandoc | Original | MultiMarkdown | MarkdownExtra | RMarkdown

(* Mapping strings to flavours *)
let flavour_of_string = function
  | "gfm" ->
      Ok GFM
  | "commonmark" ->
      Ok CommonMark
  | "pandoc" ->
      Ok Pandoc
  | "original" ->
      Ok Original
  | "multimarkdown" ->
      Ok MultiMarkdown
  | "markdownextra" ->
      Ok MarkdownExtra
  | "rmarkdown" ->
      Ok RMarkdown
  | _ ->
      Error (`Msg "Unknown markdown flavour")

(* Pretty-print flavours *)
let pp_flavour fmt = function
  | GFM ->
      Format.fprintf fmt "GitHub Flavored Markdown"
  | CommonMark ->
      Format.fprintf fmt "CommonMark"
  | Pandoc ->
      Format.fprintf fmt "Pandoc Markdown"
  | Original ->
      Format.fprintf fmt "Original Markdown"
  | MultiMarkdown ->
      Format.fprintf fmt "MultiMarkdown"
  | MarkdownExtra ->
      Format.fprintf fmt "Markdown Extra"
  | RMarkdown ->
      Format.fprintf fmt "RMarkdown"

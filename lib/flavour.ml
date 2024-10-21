(** A module defining different Markdown flavours and utility functions for converting
    between strings and flavour types, as well as pretty-printing flavours. *)

(** The type representing various Markdown flavours. *)
type flavour =
  | GFM  (** GitHub Flavored Markdown *)
  | CommonMark  (** CommonMark *)
  | Pandoc  (** Pandoc Markdown *)
  | Original  (** Original Markdown *)
  | MultiMarkdown  (** MultiMarkdown *)
  | MarkdownExtra  (** Markdown Extra *)
  | RMarkdown  (** RMarkdown *)

(** [flavour_of_string s] converts a string [s] to its corresponding {!flavour},
    or returns an error if the string does not match any known flavour.

    @param s the string representing the Markdown flavour
    @return [Ok flavour] if the string corresponds to a known flavour, or
            [Error (`Msg msg)] if the string is unknown *)
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

(** [pp_flavour fmt flavour] pretty-prints the given {!flavour} in a human-readable format.

    @param fmt the formatter to print to
    @param flavour the flavour to pretty-print *)
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

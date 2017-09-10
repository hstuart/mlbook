open Core.Std

type t = Mustache.t

let of_file template_dir =
  let template_file = Filename.concat template_dir "page.tmpl" in
  let template_data = In_channel.read_all template_file in
  Mustache.of_string template_data

let to_json page =
  let nest = Util.nest page.Page.page in
  let to_link p = match p with
  | None -> `Null
  | Some (href, _, _) -> `String ((Util.dot_dot_prefix nest) ^ (Filename.chop_extension href ^ ".html")) in
  let to_title p = match p with
  | None -> `Null
  | Some (_, c, _) -> `String c in
  `O [
    "title", `String page.Page.page_link_contents;
    "has_next", `Bool (Option.is_some page.Page.next);
    "next", to_link page.Page.next;
    "next_title", to_title page.Page.next;
    "has_prev", `Bool (Option.is_some page.Page.prev);
    "prev", to_link page.Page.prev;
    "prev_title", to_title page.Page.prev;
    "summary", `String (Summary.render page.Page.summary);
    "page", `String (Page.render page);
    "prefix", `String (Util.dot_dot_prefix nest);
  ]

let to_string template page =
  let prepare = to_json page in
  Mustache.render template prepare

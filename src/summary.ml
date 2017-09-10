open Core.Std

type t = {
  summary: Omd.t;
  root: string;
}

let summary_filename = "SUMMARY.md"

let read_summary book = In_channel.read_all (Filename.concat book summary_filename)

let of_directory root =
  let summary = Omd.of_string (read_summary root) in
  {summary; root}

let pages summary =
  let pred e =
    match e with
    | Omd.Url _ -> true
    | _ -> false in
  let matches = Util.extract_inorder pred summary.summary in
  let extract e =
    match e with
    | Omd.Url (href, c, t) -> (href, Omd.to_text c, t)
    | _ -> failwith "unknown Url type in match" in
  List.map matches extract

let renest summary nest =
  let dot_dot_prefix nest = Util.dot_dot_prefix nest in
  let url_renest e =
    match e with
    | Omd_representation.Url (href, c, t) -> Some [Omd_representation.Url ((dot_dot_prefix nest) ^ href, c, t)]
    | _ -> None
  in
  {
    summary = Omd_representation.visit url_renest summary.summary;
    root = summary.root
  }

let render summary =
  let html_summary = Util.change_md_url_to_html summary.summary in
  let open Omd_backend in
  let open Omd_utils in
  let rec custom_render e = match e with
  | [] -> ""
  | (Omd.Paragraph t) :: tl
  | (Omd.Emph t) :: tl
  | (Omd.Bold t) :: tl
  | (Omd.H6 t) :: tl
  | (Omd.H5 t) :: tl
  | (Omd.H4 t) :: tl
  | (Omd.H3 t) :: tl
  | (Omd.H2 t) :: tl
  | (Omd.H1 t) :: tl -> "<li class='header'>" ^ (custom_render t) ^ "</li>" ^ (custom_render tl)
  | (Omd.Ulp t) :: tl
  | (Omd.Olp t) :: tl
  | (Omd.Ol t) :: tl
  | (Omd.Ul t) :: tl -> "<ul class='articles'>" ^ (String.concat ~sep:"" (List.map t list_item_render)) ^ "</ul>" ^ (custom_render tl)
  | (Omd.Text t) :: tl -> t ^ custom_render tl
  | (Omd.Url (href, t, title)) :: tl -> "<a href='" ^ htmlentities ~md:true href ^ "' title='" ^ htmlentities ~md:true title ^ "'>" ^ custom_render t ^ "</a>" ^ custom_render tl
  | (Omd.Hr) :: tl -> "<hr />" ^ custom_render tl
  | (Omd.NL) :: tl -> "\n" ^ custom_render tl
  | (Omd.Br) :: tl -> "<br />" ^ custom_render tl
  | _ as e -> html_of_md e
  and list_item_render e = match e with
  | (Omd.Url (href, t, title)) :: tl -> "<li class='chapter' data-path='" ^ htmlentities ~md:true href ^ "'>" ^ custom_render e ^ "</li>"
  | _ -> "<li>" ^ custom_render e ^ "</li>"
  in
  (*Omd.to_html html_summary*)
  custom_render html_summary

let root summary = summary.root
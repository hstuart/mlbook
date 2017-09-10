open Core.Std

type t = {
  page: string;
  page_link_contents : string;
  page_link_title : string;
  contents: string;
  summary: Summary.t;
  prev: (string * string * string) option;
  next: (string * string * string) option;
}

let of_file summary (name, content, title) prev next =
  let filename = Filename.concat summary.Summary.root name in
  let nest = Util.nest name in
  {
    page = name;
    page_link_contents = content;
    page_link_title = title;
    contents = In_channel.read_all filename;
    summary = Summary.renest summary nest;
    prev;
    next;
  }

let get_images page =
  let md = Omd.of_string page.contents in
  let pred e =
    match e with
    | Omd.Img _ -> true
    | Omd.Html (name, attrs, _) -> name = "img" && List.exists attrs (fun (a, b) -> a = "src")
    | _ -> false in
  let matches = Util.extract_inorder pred md in
  let rec get_src attr =
    match attr with
    | [] -> failwith "unable to find src in HTML attribute list for img"
    | ("src", Some src) :: xs -> src
    | x :: xs -> get_src xs in
  let unwrap e =
    match e with
    | Omd.Img (_, src, _) -> src
    | Omd.Html (_, attr, _) -> get_src attr
    | _ -> failwith "unknown match type in get_images" in
  List.map matches unwrap

let render page =
  let md = Omd.of_string page.contents in
  let rmd = Util.change_md_url_to_html md in
  Omd.to_html rmd

let get_title (page : t) = page.page_link_contents

let get_url (page : t) = 
  match Filename.split_extension page.page with
  | (e, Some "md") -> String.concat ~sep:"" [e; ".html"]
  | _ -> page.page

let to_text page = Omd.to_text (Omd.of_string page.contents)

let root page = Summary.root page.summary
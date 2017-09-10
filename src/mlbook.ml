open Core.Std
open Util

let output_writer output page rendered =
  let output_file = Filename.concat output page.Page.page in
  let _ = ensure_subdirectory_exists output (Filename.dirname output_file) in
  let output_filename = change_extension output_file ~ext:".html" in
  Out_channel.write_all output_filename ~data:rendered

let copy_image output page img_src =
  let output_file = Filename.concat output page.Page.page in
  let output_directory = Filename.dirname output_file in
  let img_file = Filename.concat output_directory img_src in
  let root = Filename.realpath (Page.root page) in
  let input_file = Filename.concat root page.Page.page in
  let input_dir = Filename.dirname input_file in
  let img = Filename.concat input_dir img_src in
  let _ = ensure_below_root output img_file in
  let _ = ensure_dir (Filename.dirname img_file) in
  FileUtil.cp [img] img_file

let copy_styles style_dir output =
  let output_dir = ensure_absolute_dir (Filename.concat output "mlbook") in
  (*let style_files = FileUtil.ls style_dir in*)
  let _ = Sys.command (Printf.sprintf "cp -Lr %s/* %s/" style_dir output_dir) in
  ()
(*  FileUtil.cp ~follow:FileUtil.Follow ~recurse:true ~preserve:false style_files output_dir*)

type build_input = {
 src: string;
  dst: string;
  tmpl: string;
  stl: string;
}

let preprocess template_dir style_dir book output =
  let cwd = Sys.getcwd () in
  let default_template = Filename.concat cwd "templates" in
  let default_style = Filename.concat cwd "styles" in
  {
    src = ensure_exists book;
    dst = ensure_absolute_dir output;
    tmpl = ensure_exists (option_default default_template template_dir);
    stl = ensure_exists (option_default default_style style_dir);
  }

let build_command template_dir style_dir book output () =
  let input = preprocess template_dir style_dir book output in
  let summary = Summary.of_directory input.src in
    let pages = Summary.pages summary in
  let _ = List.iter pages (fun (href, _, _) -> Printf.printf "%s\n" href) in
  let page_template = Template.of_file input.tmpl in
  let prev_next_pages = list_prev_next pages in
  let render_page (prev, page, next) =
    let page = Page.of_file summary page prev next in
    let render = Template.to_string page_template page in
    let images = Page.get_images page in
    let local_images = List.filter images is_link_local in
    let _ = List.iter local_images (fun i -> copy_image output page i) in
    let _ = copy_styles input.stl input.dst in
    let _ = output_writer output page render in
    let title = Page.get_title page in
    let content = Page.to_text page in
    let url = Page.get_url page in
    `Assoc ([
      ("title", `String title);
      ("content", `String content);
      ("url", `String url);
    ]) in
  let search_data = `List (List.map prev_next_pages render_page) in
  Yojson.to_file (Filename.concat output "search.json") search_data

let build =
  Command.basic ~summary:"Build finished book"
    Command.Spec.(
      empty
      +> flag "-t" (optional string) ~doc:"string Template directory"
      +> flag "-s" (optional string) ~doc:"string Style directory"
      +> anon ("book" %: string)
      +> anon ("output" %: string)
    )
    (build_command)

let command =
  Command.group ~summary:"MLBook" ["build", build]

let () = Command.run ~version:"1.0" command

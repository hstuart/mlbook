let list_prev_next a =
  let makesome x = List.map (fun x -> Some x) x in
  let rec tricombine l1 l2 l3 =
    match (l1, l2, l3) with
    | ([],[],[]) -> []
    | (a1::l1, a2::l2, a3::l3) -> (a1, a2, a3) :: (tricombine l1 l2 l3)
    | (_, _, _) -> invalid_arg "tricombine" in
    match a with
  | [] -> []
  | xs ->
    let xsopt = makesome xs in
    let hd = None :: List.rev (List.tl (List.rev xsopt)) in
    let tl = List.tl xsopt @ [None] in
    tricombine hd xs tl

let dot_dot_prefix nest = 
  if nest = 0
  then "./"
  else String.init (nest*3) (fun idx -> if (idx + 1) mod 3 = 0 then '/' else '.')

let nest s =
  let open Core.Std in
  String.count s ~f:(fun c -> c = '/')

let option_may f o =
  match o with
  | None -> ()
  | Some x -> f x

let rec is_subdir base needle =
  match (base, needle) with
  | ([], []) -> true
  | (x::xs, []) -> false
  | ([], y::ys) -> true
  | (x::xs, y::ys) -> x = y && is_subdir xs ys

let ensure_dir dir =
  try
    let open FileUtil in
    let s = stat dir in
    if s.kind <> FileUtil.Dir then failwith "output is not a directory"
  with FileUtil.FileDoesntExist e -> FileUtil.mkdir dir

let ensure_absolute_dir dir =
  let open Core.Std in
  let _ = ensure_dir dir in
  Filename.realpath dir

let ensure_exists dir =
  let open FileUtil in
  let s = stat dir in
  let _ = if s.kind <> FileUtil.Dir then failwith (Printf.sprintf "%s is not a directory" dir) in
  let open Core.Std in
  Filename.realpath dir

let option_default default o =
  match o with
  | None -> default
  | Some x -> x

let is_link_local l =
  let open Core.Std in
  not (String.is_substring l ~substring:"://")

let ensure_below_root root dir =
  let open Core.Std in
  if not (is_subdir (Filename.parts root) (Filename.parts dir)) then
    failwith (Printf.sprintf "'%s' is not a subdirectory of '%s'" dir root)
  
let ensure_subdirectory_exists root dir =
  let _ = ensure_below_root root dir in
  ensure_absolute_dir dir

let change_extension ~ext filename = Filename.chop_extension filename ^ ext

let change_md_url_to_html md =
  let url_to_html e =
  match e with
  | Omd_representation.Url (href, c, t) -> Some [Omd_representation.Url ((Filename.chop_extension href ^ ".html"), c, t)]
  | _ -> None in
  Omd_representation.visit url_to_html md

let rec inorder_visit f e =
  match e with
  | [] -> ()
  | (Omd.H1 t) as e :: tl -> inorder_visit f t; f e; inorder_visit f tl
  | (Omd.H2 t) as e :: tl -> inorder_visit f t; f e; inorder_visit f tl
  | (Omd.H3 t) as e :: tl -> inorder_visit f t; f e; inorder_visit f tl
  | (Omd.H4 t) as e :: tl -> inorder_visit f t; f e; inorder_visit f tl
  | (Omd.H5 t) as e :: tl -> inorder_visit f t; f e; inorder_visit f tl
  | (Omd.H6 t) as e :: tl -> inorder_visit f t; f e; inorder_visit f tl
  | (Omd.Ul tt) as e :: tl -> List.iter (fun tte -> inorder_visit f tte) tt; f e; inorder_visit f tl
  | (Omd.Ol tt) as e :: tl -> List.iter (fun tte -> inorder_visit f tte) tt; f e; inorder_visit f tl
  | (Omd.Ulp tt) as e :: tl -> List.iter (fun tte -> inorder_visit f tte) tt; f e; inorder_visit f tl
  | (Omd.Olp tt) as e :: tl -> List.iter (fun tte -> inorder_visit f tte) tt; f e; inorder_visit f tl
  | (Omd.Paragraph t) as e :: tl -> inorder_visit f t; f e; inorder_visit f tl
  | (Omd.Br) as e :: tl -> f e; inorder_visit f tl
  | (Omd.NL) as e :: tl -> f e; inorder_visit f tl
  | (Omd.Emph t) as e :: tl -> inorder_visit f t; f e; inorder_visit f tl
  | (Omd.Bold t) as e :: tl -> inorder_visit f t; f e; inorder_visit f tl
  | (Omd.Url (_, t, _)) as e :: tl -> inorder_visit f t; f e; inorder_visit f tl
  | (Omd.Text _) as e :: tl -> f e; inorder_visit f tl
  | (Omd.Code _) as e :: tl -> f e; inorder_visit f tl
  | (Omd.Code_block _) as e :: tl -> f e; inorder_visit f tl
  | (Omd.Hr) as e :: tl -> f e; inorder_visit f tl
  | (Omd.Ref _) as e :: tl -> f e; inorder_visit f tl
  | (Omd.Raw _) as e :: tl -> f e; inorder_visit f tl
  | (Omd.Raw_block _) as e :: tl -> f e; inorder_visit f tl
  | (Omd.Img _) as e :: tl -> f e; inorder_visit f tl
  | (Omd.Img_ref _) as e :: tl -> f e; inorder_visit f tl
  | (Omd.Html _) as e :: tl -> f e; inorder_visit f tl
  | (Omd.Html_block _) as e :: tl -> f e; inorder_visit f tl
  | (Omd.Html_comment _) as e :: tl -> f e; inorder_visit f tl
  | (Omd.Blockquote t) as e :: tl -> inorder_visit f t; f e; inorder_visit f tl
  | (Omd.X _) as e :: tl -> f e; inorder_visit f tl


let rec extract_inorder pred e =
  let p = Array.create 1 [] in
  let f e = if pred e then p.(0) <- e :: p.(0) in
  let _ = inorder_visit f e in
  List.rev p.(0)
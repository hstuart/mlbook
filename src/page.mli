type t = {
  page: string;
  page_link_contents : string;
  page_link_title : string;
  contents: string;
  summary: Summary.t;
  prev: (string * string * string) option;
  next: (string * string * string) option;
}

val get_title : t -> string

val get_url : t -> string

val render : t -> string

val root : t -> string

val of_file : Summary.t ->
              string * string * string ->
              (string * string * string) option ->
              (string * string * string) option ->
              t

val to_text : t -> string

val get_images : t -> string list
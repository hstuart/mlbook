type t = {
  summary: Omd.t;
  root: string;
}

val of_directory : string -> t

val pages : t -> (string * string * string) list

val renest : t -> int -> t

val render : t -> string

val root : t -> string
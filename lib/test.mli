type packed = V : ([`Init] -> unit -> 'a) -> packed

module Elt : sig
  type t

  val unsafe_make : name:string -> (unit -> 'a) Staged.t -> t
  val key : t -> int
  val name : t -> string
  val fn : t -> packed
end

type t

type fmt_indexed =
  (string -> int -> string, Format.formatter, unit, string) format4

type fmt_grouped =
  (string -> string -> string, Format.formatter, unit, string) format4

val make : name:string -> (unit -> 'a) Staged.t -> t
(** [make ~name fn] is a naming benchmark measuring [fn]. [fn] can be
   constructed with {!Staged.stage}:

    {[
      let write = Test.make
        ~name:"unix-write"
        (Staged.stage @@ fun () -> Unix.write Unix.stdout "Hello World!")
    ]} *)

val make_indexed :
     name:string
  -> ?fmt:fmt_indexed
  -> args:int list
  -> (int -> (unit -> 'a) Staged.t)
  -> t
(** [make_indexed ~name ~fmt ~args fn] is naming benchmarks indexed by an
   argument (by [args]). Name of each benchmark is [Fmt.strf fmt name arg]
   (default to ["%s:%d"]).

    {[
      let make_list words =
        Staged.stage @@ fun () ->
        let rec go n acc = if n = 0 then acc else go (n - 1) (n :: acc) in
        go ((words / 3) + 1) []

      let test = make_indexed
        ~name:"make_list"
        ~args:[ 0; 10; 100; 100; ]
        make_list
    ]}
*)

val make_grouped : name:string -> ?fmt:fmt_grouped -> t list -> t

val name : t -> string
(** [name t] returns the name of the test. *)

val names : t -> string list
(** [names t] returns names of sub-tests of [t] (such as {i indexed} tests or {i
   grouped} tests). *)

val elements : t -> Elt.t list
(** [elements t] returns all measuring functions of [t]. *)

val expand : t list -> Elt.t list

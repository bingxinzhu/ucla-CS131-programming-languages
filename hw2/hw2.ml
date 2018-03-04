type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

let convert_grammar g =
  let rec pattern_seek start_symbol nt =
    match start_symbol with
    [] -> []
    | (lhs,rhs) :: t -> if nt = lhs then rhs :: pattern_seek t nt else pattern_seek t nt in
  match g with
  (lhs,rhs) -> (lhs, fun nt -> pattern_seek rhs nt);;

let parse_prefix grammar acceptor frag =
  let rec element_match start_symbol accept gram deri frag =
    match start_symbol with
    [] -> accept deri frag
    | h::t -> match h with
              T x -> (match frag with
                      | [] -> None
                      | head::tail -> if x = head
                                      then element_match t accept gram deri tail
                                      else None)
              | N x -> (match frag with
                       | [] -> None
                        | _ -> matcher x (gram x) (element_match t accept gram) gram deri frag)
  and matcher nt start_symbol accept gram deri frag =
    match start_symbol with
    | [] -> None
    | h::t -> match (element_match h accept gram (deri@[nt,h]) frag) with
              | Some (d,s) -> Some (d,s)
              | None -> matcher nt t accept gram deri frag in
  matcher (fst grammar) ((snd grammar) (fst grammar)) acceptor (snd grammar) [] frag;;


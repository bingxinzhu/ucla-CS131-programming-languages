

(**helper function for subet, set_union, set_intersection_helper, set_diff_helper**)
let rec contains a b =
	match b with
	| [] -> false
	| h :: t -> if h == a then true else contains a t;;

(**subset**)
let rec subset a b = 
	match a with
	| [] -> true
	| h :: t -> contains h b && subset t b;;

(***equal sets*)
let equal_sets a b =
	subset a b && subset b a;;

(**set_union**)
let rec set_union a b =
	match a with
	| [] -> b
	| h :: t -> if contains h b then set_union t b
				else set_union t (h :: b);;
(**helper function for set_intersection**)
let rec set_intersection_helper a b c =
	match a with 
	| [] -> c
	| h :: t -> if contains h b then set_intersection_helper t b (h :: c)
				else set_intersection_helper t b c;;
(**set_intersection**)
let set_intersection a b =
	set_intersection_helper a b [];;

(**helper function for set_diff**)
let rec set_diff_helper a b c = 
	match a with
	| [] -> c
	| h :: t -> if contains h b then set_diff_helper t b c
				else set_diff_helper t b (h :: c);;

(**set_diff**)
let set_diff a b =
	set_diff_helper a b [];;

(**computed_fixed_point**)
let rec computed_fixed_point eq f x = 
	if eq (f x) x then x 
	else computed_fixed_point eq f (f x);;

(**helper function for computed_period_point**)
let rec computed_period_point_helper eq f p x fx=
	match p with 0 -> if eq x fx then x else computed_period_point_helper eq f p (f x) (f fx)
	| _ -> computed_period_point_helper eq f (p - 1) x (f fx);;

(**computer_periodic_point**)
let rec computed_periodic_point eq f p x =
	computed_period_point_helper eq f p x x;;

(**while_away**) 
let rec while_away s p x = 
	if (p x) then x :: (while_away s p (s x)) else [];;

(**rle_decode**)
let rec rle_decode lp = 
	match lp with
    [] -> []
    | (a, b) :: t -> if a = 0 then rle_decode(t) else b :: rle_decode ((a-1,b) :: t);;

(**filter_blind_alleys**)
(**definition of symbol**)
type ('nonterminal, 'terminal) symbol =
    | N of 'nonterminal
    | T of 'terminal

(**helperfunctions of fliter_blind_alleys**)
let check symbol = fun x -> (fst x) = symbol;;
(**helper function to check if symbol is a nonterminal value in the terminal rules**)
let symbolExist symbol terminal_rhs = match symbol with
    | T symbol -> true
    | N symbol -> List.exists (check symbol) terminal_rhs ;;
(**check symbols in the rhs in teh terminal rhs**)
let rec checkExist rhs terminal_rhs = match rhs with
    | [] -> true
    | h::t -> (symbolExist h terminal_rhs)  && (checkExist t terminal_rhs);;  
(**create terminal rhs**)
let rec getTerminalRhs rule terminal_rhs = match rule with
    | [] -> terminal_rhs
    | r::t -> if (checkExist (snd r) terminal_rhs) && (not (subset [r] terminal_rhs)) 
    then getTerminalRhs t (r::terminal_rhs) 
 else (getTerminalRhs t terminal_rhs)
(**by the helper of the computed_fixed)point**)
(**fliter_blind_alleys**)
let filter_blind_alleys g =
    (fst g, List.filter (fun a -> List.exists (fun b -> b = a) (computed_fixed_point (=) (getTerminalRhs (snd g)) [])) (snd g));;


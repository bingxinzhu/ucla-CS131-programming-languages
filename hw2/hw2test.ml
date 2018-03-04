let accept_all derivation string = Some (derivation, string)

let accept_empty_suffix derivation = function
   | [] -> Some (derivation, [])
   | _ -> None
 
type menu_nonterminals =
   | Start | Appetizer | Drink | Dish | Dessert

let menu_grammar =
  (Start,
   function
     | Start ->
         [[N Appetizer; N Dish; N Dessert];  
          [N Dish; N Dessert]]
     | Appetizer ->
         [[N Drink; T"bread"];
    [N Drink]]
     | Drink ->
         [[T"water"]; [T"soda"]]
     | Dish ->
         [[T"rice"]; [T"noodle"]] 
     | Dessert ->
         [[T"coffee"];[T"coffee"; T"chocolate"]])

let test0 =
  ((parse_prefix menu_grammar accept_empty_suffix ["soda";"bread";"rice";"coffee";"chocolate"])
   = Some ([(Start, [N Appetizer; N Dish; N Dessert]); 
   (Appetizer, [N Drink; T"bread"]); 
   (Drink, [T"soda"]); 
   (Dish, [T"rice"]); 
   (Dessert, [T"coffee"; T"chocolate"])], []))
let test1 =
  ((parse_prefix menu_grammar accept_all ["noodle";"coffee";"coffee";"chocolate"]) 
    = Some ([(Start, [N Dish; N Dessert]);
     (Dish, [T"noodle"]);  
     (Dessert, [T"coffee"])], ["coffee";"chocolate"]))

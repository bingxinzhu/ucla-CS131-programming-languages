let my_subset_test0 = subset [] []
let my_subset_test1 = not (subset [1; 2] [6; 1; 2])
let my_subset_test2 = subset [1] [12; 13; 14]

let my_equal_sets_test0 = equal_sets [42; ] [55;]
let my_equal_sets_test1 = not (equal_sets [2;] [2;5;8])

let my_set_union_test0 = equal_sets (set_union [1;3;7] [2;6;8]) [5;6;7;8]
let my_set_union_test1 = equal_sets (set_union [1] [2]) [1;2]

let my_set_intersection_test0 = equal_sets (set_intersection [9] [10]) [] 
let my_set_intersection_test1 = equal_sets (set_intersection [1;2] [2;3]) [2;3]
let my_set_intersection_test2 = equal_sets (set_intersection [2] [6;1]) [1;2]

let my_set_diff_test0 = equal_sets (set_diff [1;5] [5;1]) []

let my_computed_fixed_point_test0 = computed_fixed_point (=) (fun x -> x *. 8.) 100. = infinity
let my_computed_fixed_point_test1 = computed_fixed_point (=) (fun x -> x mod 3) 9 = 0
let my_computed_fixed_point_test2 = computed_fixed_point (=) (fun x -> x) 20000000 = 20000000

let my_computed_periodic_point_test0 = computed_periodic_point (=) (fun x -> x mod 2) 1 80 = computed_fixed_point (=) (fun x -> x mod 2) 80
let my_computed_periodic_point_test1 = computed_periodic_point (fun x y -> x <= y) (fun x -> x + 8) 4 10 = 10

let my_while_away_test0 = while_away ((+) 3) ((>) 10) 0 = [0; 3; 6; 9]
let my_while_away_test1 = while_away ((-) 100) ((<) 80) 100 = [100]
let my_while_away_test2 = while_away ((/) 7) ((<=) 6) 4 = []

let my_rle_decode_test0 = rle_decode [2,0; 1,6] = [0; 0; 6]
let my_rle_decode_test1 = rle_decode [4,"w"; 0,"x"; 0,"y"; 2,"z"] = ["w"; "w"; "w"; "x"; "z"; "z"]
let my_rle_decode_test2 = rle_decode [1, "u"; 1, "f"; 1, "l"; 1, "a"] = ["u"; "f"; "l"; "a"]
let my_rle_decode_test3 = rle_decode [3, 9; 0, 80; 1, 10] = [9; 9; 9; 10]


type non_terminals =
  | Homework | Project | Due | Finals | Lab

let grammar = 
    [ 
      Due, [N Due; T "t"];
      Due, [T "a"; N Due];
      Homework, [N Finals];
      Homework, [N Lab; T "vee"];
      Project, [T "aaa"];
      Project, [T "uiui"; N Homework];
      Finals, [N Homework; T "ee"];
      Finals, [N Project; N Lab];
      Lab, [T "ee"; T "dd"];
      Lab, [N Homework; N Project; N Finals];
    ]
let grammar_test0 = Homework, List.tl (List.tl (grammar))
let my_filter_blind_alleys_test0 = filter_blind_alleys grammar_test0 = grammar_test0
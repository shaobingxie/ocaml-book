open Camlp4.PreCast
module MGram = MakeGram(Lexer)
 
type t =
  | Local of string * t * t
  | Binop of t * (int -> int -> int) * t
  | Int   of int
  | Var   of string
 
let expression = MGram.Entry.mk "expression"
let _ = begin  
 EXTEND MGram GLOBAL: expression;
   expression: 
   [ "top"
     [ "let"; `LIDENT s; "="; e1 = SELF; "in"; e2 = SELF -> Local(s,e1,e2) ]
   | "plus"
     [ e1 = SELF; "+"; e2 = SELF -> Binop(e1, ( + ), e2)
     | e1 = SELF; "-"; e2 = SELF -> Binop(e1, ( - ), e2) ]
   | "times"
     [ e1 = SELF; "*"; e2 = SELF -> Binop(e1, ( * ), e2)
     | e1 = SELF; "/"; e2 = SELF -> Binop(e1, ( / ), e2) ]
   | "simple"
     [ `INT(i, _)  -> Int(i)
     | `LIDENT s -> Var(s)
     | "("; e = expression; ")" -> e ]
   ];
   END;
end 
let parse_arith s =
   MGram.parse_string expression (Loc.mk "<string>") s;;
 
let rec eval env = function
     | Local(x, e1, e2) ->
       let v1 = eval env e1 in
        eval ((x, v1) :: env) e2
     | Binop(e1, op, e2) ->
        op (eval env e1) (eval env e2)
     | Int(i) -> i
     | Var(x) -> List.assoc x env


let calc s =
   Format.printf "%s ==> %d@." s (eval [] (parse_arith s))
let _ =
  calc "42 * let x = 21 in x + x"






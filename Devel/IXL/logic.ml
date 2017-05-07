open Ixl_t ;;

(* Print the header of the VHDL file *)
let print_header out_chan =
Printf.fprintf out_chan 
"-- type declaration in a package
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package my_type is

  type sensor is
    record
      addr : STD_LOGIC_VECTOR (7 downto 0) ;
      dir  : STD_LOGIC_VECTOR (1 downto 0) ;
    end record ;

  -- sensors state type
  type SE_state is array (31 downto 0) of sensor ;

  --track circuit type
  type TC_St is array (31 downto 0) of STD_LOGIC ;
  
end package my_type;

-- beggining of program
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.my_type.all;

entity Ixl is  

  Port (
         -- synchro   
         CLK        : in  STD_LOGIC;
         reset      : in  STD_LOGIC;

         -- input
         valid_in   : in  STD_LOGIC; 
         Sw_Cmd_Req : in  STD_LOGIC_VECTOR (7 downto 0);
         Sw_State   : in  STD_LOGIC_VECTOR (7 downto 0);
         Sensor     : in  SE_state;
         
         -- output
         valid_out  : out STD_LOGIC;
         Sw_Cmd_Aut : out STD_LOGIC_VECTOR (7 downto 0);

         --debug output
         TC_out     : out TC_St
         );

end Ixl;

--------------------------------------------------------------------------------

architecture Behavioral of Ixl is

  -- component declaration


--------------------------------------------------------------------------------
  
  -- signals declaration

  -- Track circuit state
  signal TC : TC_St;          


--------------------------------------------------------------------------------
  
begin

  -- component instantiation

  
--------------------------------------------------------------------------------

  
 process (CLK,reset)
 
   -- variable declaration

   
 begin

   
   -- RESET gestion
   if reset = '1' then

     -- clear TC
     for i in 0 to 31 loop
       TC(i) <= '1';
     end loop;
     -- reset the output value
     valid_out <= '0';
     
   -- end if reset
   end if;
   

   
   if rising_edge (CLK) then 

     -- for debug
     TC_out <= TC;

     -- reset the output value
     valid_out <= '0';
     
     -- process only if the inputs are ok
     if valid_in = '1' then
"
;;

(* Print the trailer of the VHDL file *)
let print_trailer out_channel =
Printf.fprintf out_channel
"    
       valid_out <= '1';    
     -- end valid = 1
     end if;
   --end if rising edge
   end if;    


 end process;
end Behavioral;
"       
;;

let print_sw_state st =
  ""
;;

let print_ident_out ident =
match ident with
| Ixl.P_SE(nb, _, dir) -> 
  begin
  match dir with
  | Ixl.Up -> "Sensor("^string_of_int(nb)^").dir = \"01\""
  | Ixl.Down -> "Sensor("^string_of_int(nb)^").dir = \"10\""
  | Ixl.Idle -> "Error Sensor Idle"
  end
| Ixl.P_TC(nb, _)      -> "TC("^string_of_int(nb)^")"
| Ixl.P_SW_CMD(nb, st) -> "P_SW_CMD_"^string_of_int(nb)^"_"^print_sw_state(st)
| Ixl.P_SW_ST(nb, st)  -> "P_SW_ST_"^string_of_int(nb)^"_"^print_sw_state(st)
| Ixl.P_SW_AUT(nb, st) -> "P_SW_AUT_"^string_of_int(nb)^"_"^print_sw_state(st)
;;


let print_ident_in ident =
match ident with
| Ixl.P_SE(nb, _, dir) -> 
  begin
  match dir with
  | Ixl.Up -> "Sensor("^string_of_int(nb)^").dir = \"01\""
  | Ixl.Down -> "Sensor("^string_of_int(nb)^").dir = \"10\""
  | Ixl.Idle -> "!@*&* Error Sensor Idle"
  end
| Ixl.P_TC(nb, _)      -> "TC("^string_of_int(nb)^")"
| Ixl.P_SW_CMD(nb, st) -> "P_SW_CMD_"^string_of_int(nb)^"_"^print_sw_state(st)
| Ixl.P_SW_ST(nb, st)  -> "P_SW_ST_"^string_of_int(nb)^"_"^print_sw_state(st)
| Ixl.P_SW_AUT(nb, st) -> "!@*&* Error SW_AUT never in"
;;

let rec print_bool_exp bool_exp =
match bool_exp with
| Ixl.P_IDENT(id)   -> print_ident_in id
| Ixl.P_NOT(id)     -> "NOT "^(print_ident_in id)
| Ixl.P_AND(e1, e2) -> "("^(print_bool_exp e1)^") AND ("^(print_bool_exp e2)^")"
| Ixl.P_OR(e1, e2)  -> "("^(print_bool_exp e1)^") OR ("^(print_bool_exp e2)^")"
;;

let print_equation out_channel equation =
  let id = print_ident_out equation.Ixl.exprname in
  let exp = print_bool_exp equation.Ixl.boolexpr
  in Printf.fprintf out_channel "        %s <= %s ;\n" id exp
;;

(* Generate each equation one per one *)
let rec print_equations out_channel equations =
match equations with
| [] -> ()
| t::q -> 
    print_equation out_channel t;
	print_equations out_channel q
;;


let generate out_channel equations =
  print_header out_channel;
  print_equations out_channel equations; 
  print_trailer out_channel
;;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use ieee.numeric_std.all;
package custom_types is
   constant inputs_1 : natural := 784;
   constant outputs_1 : natural := 50;
   constant inputs_2 : natural := 50;
   constant outputs_2 : natural := 10;
   constant inputs_3 : natural := 10;
   constant outputs_3 : natural := 10;	
   constant inputs_out : natural := 10;
   constant outputs_out : natural := 10;
	
   type integer_array is array(integer range <> ) of integer;
   type signed_array is array(integer range <> ) of signed(1 downto 0);
   type weight_matrix_integers is array(natural range <>) of integer_array(0 to inputs_1 - 1);
   type weight_matrix_signed is array(natural range <>) of signed_array(0 to inputs_1 - 1);
   type weight_matrix_2 is array( natural range <>) of std_logic_vector(0 to inputs_2 - 1);
   type weight_matrix_3 is array( natural range <>) of std_logic_vector(0 to inputs_3 - 1);
   type weight_matrix_out is array( natural range <>) of std_logic_vector(0 to inputs_out - 1);
   type integer_array_out is array(integer range <> )  of integer;
end package;
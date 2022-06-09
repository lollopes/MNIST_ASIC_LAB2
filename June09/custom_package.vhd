--Package containing weight matrix of LAYER 1
--Remember: this weight matrix must cointains values between -1 and 1 because it is first layer  
package weight_matrix_pkg_layer_1 is  
   constant inputs_1 : natural := 784;
   constant outputs_1 : natural := 100;
   type integer_array is array(integer range <> )  of integer;
   type weight_matrix_integers is array(natural range <>) of integer_array(0 to inputs_1 - 1);
end package;


--Package containing weight matrix of LAYER 2
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
package weight_matrix_pkg_layer_2 is 

	constant inputs_2 : natural := 100;
	constant outputs_2 : natural := 100;
	
    type  weight_matrix_2 is array( natural range <>) of std_logic_vector(0 to inputs_2 - 1);
end package;


--Package containing weight matrix of LAYER 3
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
package weight_matrix_pkg_layer_3 is 

	constant inputs_3 : natural := 100;
	constant outputs_3 : natural := 100;
	
    type  weight_matrix_3 is array( natural range <>) of std_logic_vector(0 to inputs_3 - 1);
end package;

--Package containing weight matrix of LAYER OUT
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
package weight_matrix_pkg_layer_out is 

	constant inputs_out : natural := 100;
	constant outputs_out : natural := 10;
	
    type  weight_matrix_out is array( natural range <>) of std_logic_vector(0 to inputs_out - 1);
    type integer_array_out is array(integer range <> )  of integer;

end package;
   

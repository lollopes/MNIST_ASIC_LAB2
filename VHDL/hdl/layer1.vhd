--------------------------------------------------------------------------------
--! @file
--! @brief Neural network instantiation
--! @author Karan Pathak
--------------------------------------------------------------------------------

--! Use standard library with logic elements
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.custom_types.all;

entity layer_1 is
	generic(
		inputs  : natural := 784;         --! Network inputs = number of neurons in the previous layer
		outputs : natural := 100        --! Network outputs = number of neurons in the present layer
	);
	port(
		clk      : in  std_logic;	
		rst      : in  std_logic;	
		start_i  : in  std_logic;	
		input_i  : in  integer_array(0 to inputs - 1);   
		weight_i : in  weight_matrix_integers (outputs - 1 downto 0);
		output_o : out std_logic_vector(outputs - 1 downto 0) := (others => '0'); 
		done_o   : out std_logic  := '0' 
		                                                              
	);
end entity layer_1;

architecture rtl of layer_1 is

    --SIGNALS
    signal output_o_internal : std_logic_vector(0 to outputs -1 );

    --COMPONENT
	component integer_neuron is
	generic(
		inputs : integer := 784            --! Number of inputs into the neuron
	);
	port(
		clk      : in  std_logic;        --! Clock input
		rst      : in  std_logic;        --! Reset input
		start_i  : in  std_logic;        --! Start input, indicates to start

		input_i  : in  integer_array(inputs - 1 downto 0); --! Neuron inputs
		weight_i : in  integer_array(inputs - 1 downto 0); --! Neuron weights 
		                                                  
		output_o : out std_logic;   --! Neuron output
		done_o   : out std_logic  := '0' --! Done output, indicates completion
	);
    end component;

begin
   GEN_LAYER_NEURONS: 
   for I in 0 to outputs-1 generate  
      NEURONS : integer_neuron generic map (
      inputs=>inputs)
      port map
        (clk=>clk, rst =>rst, start_i => start_i, input_i =>input_i, weight_i => weight_i(I), output_o => output_o_internal(I), done_o => done_o);
   end generate GEN_LAYER_NEURONS;
   
   
output_o <= output_o_internal;

end architecture rtl;

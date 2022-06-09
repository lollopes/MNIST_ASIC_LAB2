--------------------------------------------------------------------------------
--! @file
--! @brief Neural network instantiation
--! @author Karan Pathak
--------------------------------------------------------------------
library work;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.weight_matrix_pkg_layer_3.all;
entity layer_3 is
	generic(
		inputs  : natural := 100;         --! Network inputs = number of neurons in the previous layer
		outputs : natural := 100        --! Network outputs = number of neurons in the present layer
	);
	port(
		CLK      : in  std_logic;	--! Clock input
		rst      : in  std_logic;	--! Reset output
		start_i  : in  std_logic;	--! Start input, indicates to start the calculation
		input_i  : in  std_logic_vector(inputs - 1 downto 0);--! Network input = ouput of previous layer
		weight_i : in  weight_matrix_3 (outputs -1 downto 0);
		output_o : out std_logic_vector(outputs - 1 downto 0) := (others => '0'); --! Network output
		done_o   : out std_logic                              := '0' --! Done output, indicates completion -- signal to the next layer to begin the calculation
		                                                              -- done_o of previous layer is start_i of the next layer
	);
end entity layer_3;

architecture rtl of layer_3 is

signal output_o_internal : std_logic_vector(outputs -1 downto 0);
signal weight_i_internal : weight_matrix_3 (outputs -1 downto 0);
signal done_internal     : std_logic_vector(outputs -1 downto 0);
	component binary_neuron is
	generic(
		inputs : integer := 100            --! Number of inputs into the neuron
	);
	port(
		CLK      : in  std_logic;        --! Clock input
		rst      : in  std_logic;        --! Reset input
		start_i  : in  std_logic;        --! Start input, indicates to start
		                                 --! the calculation
		input_i  : in  std_logic_vector(inputs - 1 downto 0); --! Neuron inputs
		weight_i : in  std_logic_vector(inputs -1 downto 0); --! Neuron weights 
		                                                  
		output_o : out std_logic;   --! Neuron output
		done_o   : out std_logic  := '0' --! Done output, indicates completion
	);
end component;

begin
   GEN_LAYER_NEURONS: 
   for I in 0 to outputs-1 generate  
      NEURONS : binary_neuron generic map (
      inputs=>inputs)
      port map
        (CLK=>CLK, rst =>rst, start_i => start_i, input_i =>input_i, weight_i => weight_i_internal(I), output_o => output_o_internal(I), done_o => done_internal(I));
   end generate GEN_LAYER_NEURONS;
   process(done_internal) --Todo: use a more area and delay efficient way
        variable done_and_accumulate : std_logic_vector(outputs-1 downto 0);
   begin
        done_and_accumulate(0) := done_internal(0);
        
        for I in 1 to outputs-1 loop
            done_and_accumulate(I) := done_internal(I) and done_and_accumulate(I-1); 
        end loop;
      
        done_o <= done_and_accumulate(outputs - 1);
   end process;
   
weight_i_internal <= weight_i;
output_o <= output_o_internal;

end architecture rtl;

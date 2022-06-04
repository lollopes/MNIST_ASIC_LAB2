--------------------------------------------------------------------------------
--! @file
--! @brief Single neuron instance
--! @author Karan Pathak
--------------------------------------------------------------------------------

--! Use standard library with logic elements
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.weight_matrix_pkg.all;
--! A single neuron with generic "N" inputs

entity neuron is
	generic(
		inputs : integer := 3            --! Number of inputs into the neuron 
	);
	port(
		clk      : in  std_logic;        --! Clock input
		rst      : in  std_logic;        --! Reset input
		start_i  : in  std_logic;        --! Start input, indicates to start
		                                 --! the calculation
		input_i  : in  std_logic_vector(inputs - 1 downto 0); --! Neuron inputs
		weight_i :  weight_array_one_neuron; --! Neuron weights
		                                                  
		output_o : out std_logic;   --! Neuron output
		done_o   : out std_logic  := '0' --! Done output, indicates completion
	);
end entity neuron;


architecture behavioral of neuron is
    signal index : integer := inputs;
	type state is (idle, start, acum, act_func);
	signal output_s : std_logic;
	signal current_state, next_state : state ;
	signal input_s : std_logic_vector(inputs - 1 downto 0);
	signal weight_s: weight_array_one_neuron;
	signal done_s  : std_logic := '0'; 
	signal mul_value : std_logic_vector(inputs-1 downto 0):= (others => '0'); -- change this everytime you change the number of inputs     
	--signal popcount :std_logic_vector (inputs-1 downto 0) := (others => '0');
	 
begin

	fsm_lower : process(clk, rst) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				current_state <= idle;
			else
			    current_state <= next_state;
			end if;
		end if;
	end process fsm_lower;

	fsm_upper : process(current_state, start_i,input_s, weight_s) is
		variable popcount : std_logic_vector ( (inputs-1) downto 0) := (others => '0');
	begin
		case current_state is
			when idle =>
				done_s <= '0';
				output_s <= '0';
				if start_i = '1' then
					next_state <= start;
				else
					next_state <= current_state;
				end if;

			when start =>
				for i in 0 to (inputs-1) loop
                            mul_value(i) <= std_logic ( input_s(i) xnor weight_s(i));
                end loop;
                output_s <= '0';
                done_s <= '0';
				next_state <= acum;

			when acum =>
				
				    for j in 0 to (inputs-1) loop 
					popcount := popcount + mul_value(j);
					--index <= index -1;
				    end loop;
				    output_s <= '0';
				    next_state <= act_func;
                    done_s <= '0';
			when act_func =>
				done_s     <= '1';
				if popcount > (inputs-1)/2 then
				    
			        output_s <= '1';
			    else 
			        output_s <= '0';
				    next_state <= idle;
                end if;
		end case;

	end process fsm_upper;
    input_s <= input_i;
    weight_s <= weight_i;  
    done_o <= done_s;
    output_o <= output_s;
end architecture behavioral;

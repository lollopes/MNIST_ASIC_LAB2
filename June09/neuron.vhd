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
--! A single neuron with generic "N" inputs

entity binary_neuron is
	generic(
		inputs : integer := 3            --! Number of inputs into the neuron
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
end entity binary_neuron;


architecture behavioral of binary_neuron is
    signal index : integer := inputs;
	type state is (idle, start, acum, act_func, done_state);
	signal output_s : std_logic := '0';
	signal current_state, next_state : state ;
	signal input_s, weight_s : std_logic_vector(inputs - 1 downto 0);
	signal done_s  : std_logic := '0'; 
	signal mul_value : std_logic_vector(inputs-1 downto 0):= (others => '0'); -- change this everytime you change the number of inputs     
	--signal popcount :std_logic_vector (inputs-1 downto 0) := (others => '0');
	 
begin

	fsm_lower : process(CLK) is
	begin
		if rising_edge(CLK) then
			if rst = '1' then
				current_state <= idle;
			else
			    current_state <= next_state;
			end if;
		end if;
	end process fsm_lower;

	fsm_upper : process(current_state, start_i, input_s, weight_s,mul_value) is
	    type  popcount_array is array((inputs-1) downto 0) of std_logic_vector( (inputs-1) downto 0);
		variable popcount : popcount_array;
		variable temp_vector : std_logic_vector( (inputs-1) downto 0) := (others => '0'); 
	begin
		case current_state is
			when idle =>
			     for I in 0 to inputs -1 loop
			         mul_value(I) <= '0';
			         temp_vector(I):= '0';
			     end loop;
			     for I in 0 to inputs-1 loop
			     popcount(I) := temp_vector;
			     end loop;
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
                      temp_vector(i):= '0';
                end loop;
                for I in 0 to inputs-1 loop
			     popcount(I) := temp_vector;
			     end loop;
                output_s <= '0';
                done_s <= '0';
				next_state <= acum;

			when acum =>
                    for i in 1 to (inputs-1) loop
                       temp_vector(i):= '0';
                    end loop;
				    temp_vector(0) := mul_value(0);
				    popcount(0) := temp_vector;
				    for j in 1 to (inputs-1) loop 
					   popcount(j) := popcount(j-1) + mul_value(j);
					--index <= index -1;
				    end loop;
				    mul_value<=mul_value+1-1;
				    output_s <= '0';
				    next_state <= act_func;
                    done_s <= '0';
			when act_func =>
				done_s     <= '1';
				for I in 0 to inputs -1 loop
			         mul_value(I) <= '0';
			         temp_vector(I) := '0';
			     end loop;
				if popcount(inputs - 1) >= inputs/2 then
				    
			        output_s <= '1';
			    else 
			        output_s <= '0';
				    
                end if;
			     next_state <= done_state;
--			     for I in 0 to inputs-1 loop
--			     popcount(I):=popcount(I) + temp_vector;
--			     end loop;
             when done_state => 
                    for I in 0 to inputs -1 loop
			         mul_value(I) <= '0';
			         temp_vector(I) := '0';
			     end loop;
			     for I in 0 to inputs-1 loop
			     popcount(I) := temp_vector;
			     end loop;
			     done_s <= '0';
                 output_s <= '0';
                 next_state <= idle;
             when others =>
             done_s <= '0';
             output_s <= '0';
             for I in 0 to inputs -1 loop
			         mul_value(I) <= '0';
			         temp_vector(I) := '0';
			 end loop;
             for I in 0 to inputs -1 loop
			         popcount(I) := temp_vector;
			 end loop;
             next_state <= idle;
		end case;

	end process fsm_upper;
	
    input_s <= input_i;
    weight_s <= weight_i;  
    done_o <= done_s;
    output_o <= output_s;
end architecture behavioral;

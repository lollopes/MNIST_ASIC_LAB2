library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.weight_matrix_pkg_layer_1.all;

entity integer_neuron is
    generic(
		inputs : integer := 3            --! Number of inputs into the neuron
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
end integer_neuron;

architecture logic of integer_neuron is
    --types
    type state is (idle, start, acum, act_func, done_state);
    
    --signals
    signal current_state, next_state : state ; 
    signal index : integer := inputs;
	signal output_s : std_logic;
	--signal input_s, weight_s : std_logic_vector(inputs - 1 downto 0);
	signal done_s  : std_logic := '0'; 
	signal mul_value : integer_array(inputs-1 downto 0):= (others => 0);
	
begin
    
	fsm_lower : process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				current_state <= idle;
			else
			    current_state <= next_state;
			end if;
		end if;
	end process fsm_lower;

	fsm_upper : process(current_state, start_i, input_i, weight_i) is
	
		variable integer_sum : integer := 0; 
		
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
                      mul_value(i) <= input_i(i) * weight_i(i);
                end loop;
                output_s <= '0';
                done_s <= '0';
				next_state <= acum;

			when acum =>
				    for j in 0 to (inputs-1) loop 
					   integer_sum := integer_sum + mul_value(j);
					--index <= index -1;
				    end loop;
				    output_s <= '0';
				    next_state <= act_func;
                    done_s <= '0';
                    
			when act_func =>
				done_s     <= '1';
				if integer_sum >= 0 then
				    next_state <= done_state;
			        output_s <= '1';
			    else 
			        output_s <= '0';
				    next_state <= done_state;
                end if;
             when done_state => 
                done_s <= '0';
             when others =>
		end case;

	end process fsm_upper;
	
	--signal mapping
    done_o <= done_s;
    output_o <= output_s;

end logic;

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
		clk      : in  std_logic;        --! Clock input
		rst      : in  std_logic;        --! Reset input
		start_i  : in  std_logic;        --! Start input, indicates to start
		last_i   : in  std_logic;

		input_i  : in  std_logic_vector(inputs - 1 downto 0); --! Neuron inputs
		weight_i : in  std_logic_vector(inputs -1 downto 0); --! Neuron weights 
		                                                  
		output_o : out std_logic;   --! Neuron output
		done_o   : out std_logic  := '0' --! Done output, indicates completion
	);
end entity binary_neuron;


architecture behavioral of binary_neuron is
	type state is (idle, start, acum, act_func, done_state);
	--signal output_s : std_logic;
	signal current_state, next_state : state ;
	signal input_s, weight_s : std_logic_vector(inputs - 1 downto 0);
	signal done_s  : std_logic := '0'; 
	signal mul_value : std_logic_vector(inputs-1 downto 0):= (others => '0'); -- change this everytime you change the number of inputs     
	--signal popcount :std_logic_vector (inputs-1 downto 0) := (others => '0');
	--signal popcount_v2: std_logic_vector(inputs - 1 downto 0);
	 
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

	fsm_upper : process(current_state, start_i, input_s, weight_s) is
	    type  popcount_array is array((inputs-1) downto 0) of std_logic_vector(7 downto 0);
		variable popcount : popcount_array;
	begin
		case current_state is
			when idle =>
				done_s <= '0';
				output_o <= '0';
				mul_value <= (others => '0');
				popcount := (others => (others => '0'));
				--popcount_v2 <= (others => '0');
				if start_i = '1' then
					next_state <= start;
				else
					next_state <= current_state;
				end if;

			when start =>
				for i in 0 to (inputs-1) loop
                      mul_value(i) <= std_logic ( input_s(i) xnor weight_s(i));
                end loop;
                output_o <= '0';
                done_s <= '0';
				next_state <= acum;
				popcount := (others => (others => '0'));

			when acum =>
				    popcount(0) := popcount(0) + mul_value(0);
				    for j in 1 to (inputs-1) loop 
					   popcount(j) := popcount(j-1) + mul_value(j);
				    end loop;
				    
--				    for j in 0 to (inputs-1) loop 
--					   popcount_v2 <= popcount_v2 + mul_value(j);
--				    end loop;
				    
				    output_o <= '0';
				    next_state <= act_func;
                    done_s <= '0';
                    mul_value <= (others => '0');
                    
			when act_func =>
				done_s     <= '1';
				if popcount(inputs - 1) >= inputs/2 then
				--if popcount_v2 >= inputs/2 then
			        output_o <= '1';
			    else 
			        output_o <= '0';
                end if;

				if last_i = '0' then
					next_state <= idle;
				else
					next_state <= done_state;
				end if;

                mul_value <= (others => '0');
                popcount := (others => (others => '0'));
				
			when done_state =>
				done_s <= '0';
				mul_value <= (others => '0');
				popcount := (others => (others => '0'));
				next_state <= done_state;
                
             when others =>
             done_s <= '0';
             next_state <= idle;
             mul_value <= (others => '0');
             popcount := (others => (others => '0'));
		end case;

	end process fsm_upper;
	
    input_s <= input_i;
    weight_s <= weight_i;  
    done_o <= done_s;
    --output_o <= output_s;
end architecture behavioral;
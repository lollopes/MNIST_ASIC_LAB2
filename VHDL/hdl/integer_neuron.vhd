library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.custom_types.all;

entity integer_neuron is
    generic(
		inputs : integer := 3            --! Number of inputs into the neuron
	);
	port(
		CLK      : in  std_logic;        --! Clock input
		rst      : in  std_logic;        --! Reset input
		start_i  : in  std_logic;        --! Start input, indicates to start
		last_i   : in  std_logic;

		input_i  : in  signed_array(inputs - 1 downto 0); --! Neuron inputs
		weight_i : in  signed_array(inputs - 1 downto 0); --! Neuron weights 
		                                                  
		output_o : out std_logic;   --! Neuron output
		done_o   : out std_logic  := '0' --! Done output, indicates completion
	);
end integer_neuron;

architecture logic of integer_neuron is
    --types
    type state is (idle, start, acum, act_func, done_state);
    type mult_value_array is array(integer range <> ) of signed(3 downto 0);
    --signals
    signal current_state, next_state : state := idle; 
	signal output_s : std_logic := '0';
	signal done_s  : std_logic := '0'; 
	signal mul_value : mult_value_array(inputs - 1 downto 0);
	
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

	fsm_upper : process(current_state, start_i, input_i, weight_i, mul_value, last_i) is
	
		variable integer_sum : signed(10 downto 0) := (others => '0');
		--variable mult_value_element:  signed(3 downto 0) := (others => '0');
		
	begin
        
		case current_state is
			when idle =>
			    done_s <= '0';
				output_s <= '0';
				mul_value <= (others => (others => '0'));
				--mult_value_element := (others => '0');
				integer_sum := (others => '0');
				if start_i = '1' then
					next_state <= start;
				else
					next_state <= current_state;
				end if;

			when start =>
				for i in 0 to (inputs-1) loop
                      mul_value(i) <= input_i(i) * weight_i(i);
--                      mult_value_element := input_i(i) * weight_i(i);
--                      if mult_value_element = 1 then    --internal conversion to binary encoding
--                         mul_value(i) <= "01";
--                      elsif mult_value_element = -1 then
--                         mul_value(i) <= "10";
--					  elsif mult_value_element = 0 then
--                         mul_value(i) <= "00";
--					  else
--						mul_value(i) <= "11";	--prohibited state
--                      end if;
                end loop;
                output_s <= '0';
                done_s <= '0';
				next_state <= acum;
				integer_sum := (others => '0');

			when acum =>
				    for j in 0 to (inputs-1) loop 
					   integer_sum := integer_sum + mul_value(j);
--					   if mul_value(j) = "01" then 
--					       integer_sum := integer_sum + 1;
--					   elsif mul_value(j) = "10" then
--                           integer_sum := integer_sum - 1;
--                       elsif mul_value(j) = "00" then
--						   integer_sum := integer_sum;
--					   elsif mul_value(j) = "11" then
--						   integer_sum := integer_sum;
--                      end if;
				    end loop;
				    output_s <= '0';
				    next_state <= act_func;
                    done_s <= '0';
					mul_value <= (others => (others => '0'));
                    
			when act_func =>
				done_s     <= '1';
				if integer_sum >= 0 then
			        output_s <= '1';
			    else 
			        output_s <= '0';
                end if;

				if last_i = '0' then
					next_state <= idle;
				else
					next_state <= done_state;
				end if;
				--mult_value_element := (others => '0');
				mul_value <= (others => (others => '0'));
				integer_sum := (others => '0');

			when done_state =>
				done_s <= '0';
				mul_value <= (others => (others => '0'));
				--mult_value_element := (others => '0');
				integer_sum := (others => '0');
				next_state <= done_state;					
				

             when others =>
			 	done_s <= '0';
				output_s <= '0';
				mul_value <= (others => (others => '0'));
				--mult_value_element := (others => '0');
				integer_sum := (others => '0');
                next_state <= idle;

		end case;

	end process fsm_upper;
	
	--signal mapping
    done_o <= done_s;
    output_o <= output_s;

end logic;

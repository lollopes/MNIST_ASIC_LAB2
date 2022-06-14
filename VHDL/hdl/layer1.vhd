library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.custom_types.all;

entity layer_1 is
	generic(
		inputs  : natural := 784;         --! Network inputs = number of neurons in the previous layer
		outputs : natural := 100        --! Network outputs = number of neurons in the present layer
	);
	port(
		CLK      : in  std_logic;	
		rst      : in  std_logic;	
		start_i  : in  std_logic;	
		input_i  : in  signed_array(0 to inputs - 1);   
		weight_i : in  weight_matrix_signed (outputs - 1 downto 0);
		output_o : out std_logic_vector(outputs - 1 downto 0) := (others => '0'); 
		done_o   : out std_logic  := '0' 
		                                                              
	);
end entity layer_1;

architecture rtl of layer_1 is

    --SIGNALS
    signal output_o_internal : std_logic_vector(0 to outputs -1 );

	--Intermediate register to hold the values
	signal register_value      : std_logic_vector(0 to outputs - 1);
	signal register_write_en   : std_logic_vector(0 to outputs - 1);
	signal register_write_data : std_logic_vector(0 to outputs - 1);

	--interface to the neuron
	signal start_neuron, output_neuron, done_neuron	: std_logic;
	signal weight_neuron: signed_array(inputs - 1 downto 0);

	--Control signals
	type state_type is (idle_state, start_neuron_state, wait_for_neuron_state, done_state);	
	signal control_state, control_state_next : state_type;
	signal control_count, control_count_next : integer range 0 to outputs-1;


    --COMPONENT
	component integer_neuron is
        generic(
            inputs : integer := 784            --! Number of inputs into the neuron
        );
        port(
            CLK      : in  std_logic;        --! Clock input
            rst      : in  std_logic;        --! Reset input
            start_i  : in  std_logic;        --! Start input, indicates to start
    
            input_i  : in  signed_array(inputs - 1 downto 0); --! Neuron inputs
            weight_i : in  signed_array(inputs - 1 downto 0); --! Neuron weights 
                                                              
            output_o : out std_logic;   --! Neuron output
            done_o   : out std_logic  := '0' --! Done output, indicates completion
        );
    end component;

begin

	output_o <= register_value;

    neuron_label: integer_neuron generic map (
    inputs=>inputs)
    port map
    (clk=>clk, rst =>rst, start_i => start_neuron, input_i =>input_i, weight_i => weight_neuron, output_o => output_neuron, done_o => done_neuron);
      
	--Mux from weight_i to weight_neuron
	weight_neuron <= weight_i(control_count);

	--demux from output_neuron and done_neuron to register_write_data and register_write_en
	process(control_count, output_neuron, done_neuron) is
	begin
		register_write_data <= (others => '0');
		register_write_en	<= (others => '0');

		register_write_data(control_count) <= output_neuron;
		register_write_en(control_count) <= done_neuron;
		
	end process;

   

	process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				control_state <= idle_state;
				control_count <= 0;
			else 
				control_state <= control_state_next;
				control_count <= control_count_next;
			end if;
		end if;
	end process;

	process(control_state, control_count, start_i, done_neuron) is
	begin
		control_count_next <= control_count;
		start_neuron <= '0';
		done_o <= '0';

		case control_state is

			when idle_state =>
				if start_i = '1' then
					control_state_next <= start_neuron_state;
				else
					control_state_next <= idle_state;
				end if;

			when start_neuron_state =>
				start_neuron 		<= '1';
				control_state_next 	<= wait_for_neuron_state; 

			when wait_for_neuron_state =>
				if done_neuron = '1' then
					if control_count = outputs - 1 then
						control_state_next <= done_state;
					else
						control_state_next <= start_neuron_state;
						control_count_next <= control_count + 1;
					end if;
				else
					control_state_next <= wait_for_neuron_state;
				end if;

			when done_state =>
				control_state_next <= done_state;
				done_o <= '1';

		end case;
	end process;


	--This is the process to generate the buffers
	GENERATE_BUFFER:
	for I in 0 to outputs - 1 generate
		process(clk) is
		begin
			--Instance of D FLip Flop
			if rising_edge(clk) then
				if rst = '1' then
					register_value(I) <= '0';
				elsif register_write_en(I) = '1' then
					register_value(I) <= register_write_data(I);
				end if;
			end if;
		end process;
	end generate GENERATE_BUFFER;


end architecture rtl;

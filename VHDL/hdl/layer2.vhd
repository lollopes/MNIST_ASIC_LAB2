library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.custom_types.all;

entity layer_2 is
	generic(
		inputs  : natural := 100;         --! Network inputs = number of neurons in the previous layer
		outputs : natural := 100        --! Network outputs = number of neurons in the present layer
	);
	port(
		CLK      : in  std_logic;	--! Clock input
		rst      : in  std_logic;	--! Reset output
		start_i  : in  std_logic;	--! Start input, indicates to start the calculation
		input_i  : in  std_logic_vector(inputs - 1 downto 0);--! Network input = ouput of previous layer
		weight_i : in  weight_matrix_2(outputs -1 downto 0);
		output_o : out std_logic_vector(outputs - 1 downto 0) := (others => '0'); --! Network output
		done_o   : out std_logic  := '0' --! Done output, indicates completion -- signal to the next layer to begin the calculation
		                                                              -- done_o of previous layer is start_i of the next layer
	);
end entity layer_2;

architecture rtl of layer_2 is
	constant divisor 				: integer := divisor_2;
	constant num_physical_neurons 	: integer := outputs/divisor;
	constant num_registers			: integer := outputs - num_physical_neurons;

	--Intermediate register to hold the values
	signal register_value      : std_logic_vector(num_registers - 1 downto 0);
	signal register_write_en   : std_logic_vector(num_registers - 1 downto 0);
	signal register_write_data : std_logic_vector(num_registers - 1 downto 0);

	--interface to the neuron
	signal start_neuron, output_neuron, done_neuron, last_neuron : std_logic_vector(num_physical_neurons - 1 downto 0);
    signal weight_neuron: weight_matrix_2(num_physical_neurons - 1 downto 0);

	--Control signals
	type state_type is (idle_state, start_neuron_state, wait_for_neuron_state, wait_for_final_neuron_state);	
	signal control_state, control_state_next : state_type;
	signal control_count, control_count_next : integer range 0 to divisor-1;

	--COMPONENT
	component binary_neuron is
		generic(
			inputs : integer := 5            --! Number of inputs into the neuron
		);
		port(
			CLK      : in  std_logic;        --! Clock input
			rst      : in  std_logic;        --! Reset input
			start_i  : in  std_logic;        --! Start input, indicates to start
			last_i   : in  std_logic;

			input_i  : in  std_logic_vector(inputs - 1 downto 0); --! Neuron inputs
			weight_i : in  std_logic_vector(inputs -1 downto 0); --! Neuron weights 
															
			output_o : out std_logic;   --! Neuron output
			done_o   : out std_logic  := '0' --! Done output, indicates completion
		);
	end component;

begin

    neuron_gen_label: for I in 0 to num_physical_neurons - 1 generate
		neuron_label : binary_neuron generic map (
		inputs=>inputs)
		port map
		(clk=>clk, rst =>rst, start_i => start_neuron(I), last_i => last_neuron(I), input_i =>input_i, weight_i => weight_neuron(I), output_o => output_neuron(I), done_o => done_neuron(I));

		--Mux from weight_i to weight_neuron
		weight_neuron(I) <= weight_i(num_physical_neurons*control_count + I);
	end generate neuron_gen_label;

	FFs_gen: if num_registers > 0 generate
		output_o <= output_neuron & register_value ;
		--demux from output_neuron and done_neuron to register_write_data and register_write_en
		process(control_count, output_neuron, done_neuron) is
			begin
				register_write_data <= (others => '0');
				register_write_en	<= (others => '0');
		
				for I in 0 to num_physical_neurons - 1 loop
					if control_count /= divisor-1 then
						register_write_data(num_physical_neurons*control_count + I) 		<= output_neuron(I);
						register_write_en(num_physical_neurons*control_count + I) 			<= done_neuron(I);
					end if;
				end loop;
				
			end process;
		
			--This is the process to generate the buffers
			GENERATE_BUFFER: for I in 0 to num_registers - 1 generate
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
	end generate FFs_gen;

	no_FFs_gen: if num_registers = 0 generate
		output_o <= output_neuron ;
	end generate no_FFs_gen;


   

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
		control_count_next 	<= control_count;
		start_neuron 	   	<= (others => '0');
		done_o 				<= '0';
		last_neuron 		<= (others => '0');

		case control_state is

			when idle_state =>
				if start_i = '1' then
					control_state_next <= start_neuron_state;
				else
					control_state_next <= idle_state;
				end if;

			when start_neuron_state =>
			start_neuron 		<= (others => '1');
			if control_count = divisor - 1 then
				control_state_next 	<= wait_for_final_neuron_state; 
			else
				control_state_next 	<= wait_for_neuron_state; 
			end if;

			when wait_for_neuron_state =>
				if done_neuron(0) = '1' then
					control_state_next <= start_neuron_state;
					control_count_next <= control_count + 1;
				else
					control_state_next <= wait_for_neuron_state;
				end if;

			when wait_for_final_neuron_state =>
				control_state_next <= wait_for_final_neuron_state;
				done_o <= done_neuron(0);
				last_neuron <= (others => '1');

		end case;
	end process;




end architecture rtl;

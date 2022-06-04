library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.weight_matrix_pkg.all;

entity BNN_tb is
    --empty
end entity BNN_tb;

architecture behavioural of BNN_tb is
	


	
	constant half_period : time := 10 ns;
	
	signal clk      : std_logic := '0';
	signal rst      : std_logic := '0';
	signal input_i  : std_logic_vector(inputs - 1 downto 0);--! Network input = ouput of previous layer
    signal weight_i : weight_matrix_one_layer;
	signal start_i  : std_logic := '0';
	signal done_o   : std_logic;
	signal output_o :std_logic_vector (outputs-1 downto 0);
	
	
	--dut
	component layer is
	generic(
		inputs   : natural := 784;         --! Network inputs = number of neurons in the previous layer
		outputs  : natural := 100        --! Network outputs = number of neurons in the present layer
	);
	port(
		clk      : in  std_logic;	--! Clock input
		rst      : in  std_logic;	--! Reset output
		start_i  : in  std_logic;	--! Start input, indicates to start the calculation
		input_i  : in  std_logic_vector(inputs - 1 downto 0);--! Network input = ouput of previous layer
		weight_i : in weight_matrix_one_layer;
		output_o : out std_logic_vector(outputs - 1 downto 0) := (others => '0'); --! Network output
		done_o   : out std_logic                              := '0' --! Done output, indicates completion -- signal to the next layer to begin the calculation
		                                                              -- done_o of previous layer is start_i of the next layer
	);
end component;

begin
    --DUT instatiation
    layer_inst : layer
		generic map(inputs  => inputs,	outputs => outputs)
		port map(
			clk      => clk,
			rst      => rst,
			start_i  => start_i,
			input_i  => input_i,
			weight_i => weight_i,
			output_o => output_o,
			done_o   => done_o
	);
	
	--Stimuli generation	
    clk <= not clk after half_period;

    start_stimuli : process is
    begin
        start_i <= '0', '1' after 15 ns;--'0' after 30 ns;
        rst <= '1' after 20 ns;
        wait until done_o = '1';
    end process start_stimuli;

--	--Reading from the .csv file-- weight1---f
--	file_open(my_csv_file, "W_fc1.txt", READ_MODE);
--	csv: process (rst) is
--	   begin
--      while not endfile(my_csv_file) loop
--            readline(my_csv_file, current_line);    -- Read line from file
--            report  to_string(read_integer);
--            for index in 0 to 100 loop   --THE RANGE NEEDS TO BE MODIFIED: loop for the numbers of elements in oen row
--                weight_i(index) <= std_logic_vector(TO_UNSIGNED(read_integer,1));   -- Read value from line
--            end loop;
--        end loop;  
--   end process;
--	file_close(my_csv_file);


	process_read_input: process
		file input_file       : text open read_mode is "W_fc1.txt";
		variable text_line    : line;
		variable input_index  : integer:=0;
		variable string_index : integer:=1;
		variable neuron_index : integer:=0;
		variable read_string  : string(1 to 4); --Four characters max (-1.0) or (1.0)
		variable weight_neuron_temp : weight_array_one_neuron;
	begin
		for neuron_index in 0 to outputs-1 loop
			readline(input_file, text_line);

			weight_neuron_temp := (others => '0');

			string_index := 1;
			input_index  := 0;

			for j in text_line'range loop
				if text_line(j) = ',' then	--If we encounter a comma, check the value of the read string, and assign to the weights matrix accordingly
					if string_index = 4 then
						read_string(4) := ' '; --Padding "1.0" to "1.0 "
					end if;

					if read_string = "1.0 " then
						weight_neuron_temp(input_index) := '1';
					elsif read_string = "-1.0" then
						weight_neuron_temp(input_index) := '0';
					else
						--Error
						report "Unrecognized string" & read_string & integer'image(input_index);
					end if;
					input_index := input_index + 1;
					string_index := 1;

				else --Reading the character and storing it into the read string
					read_string(string_index) := text_line(j);
					string_index := string_index + 1;	
				end if;

			end loop;

			--Assign the last value in the matrix (because there isn't a comma at the end of the line, this is done outside the loop)
			if string_index = 4 then
				read_string(4) := ' '; --Padding "1.0" to "1.0 "
			end if;

			if read_string = "1.0 " then
				weight_neuron_temp(input_index) := '1';
			elsif read_string = "-1.0" then
				weight_neuron_temp(input_index) := '0';
			else
				--Error
				report "Unrecognized string" & read_string & integer'image(input_index);
			end if;


			report integer'image(neuron_index);

			weight_i(neuron_index) <= weight_neuron_temp;

		end loop;
		wait;
	end process;
    

end behavioural;
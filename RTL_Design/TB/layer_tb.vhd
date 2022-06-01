library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.weight_matrix_pkg.all;

entity layer_tb is
    --empty
end entity layer_tb;

architecture behavioural of layer_tb is
	
	constant inputs : natural := 5;
	constant outputs : natural := 4;
	constant LINE_LENGTH_MAX: integer := 256;
	
	constant half_period : time := 10 ns;
	
	signal clk      : std_logic := '0';
	signal rst      : std_logic := '0';
	signal input_i  : std_logic_vector(inputs - 1 downto 0);--! Network input = ouput of previous layer
    signal weight_i : weight_matrix (outputs -1 downto 0);
	signal start_i  : std_logic := '0';
	signal done_o   : std_logic;
	signal output_o :std_logic_vector (outputs-1 downto 0);
	
	--signals for reading the file
	file my_csv_file: text;                         -- file
    shared variable current_line: line;	            -- cache one line at a time for read operations
    
	--functions to read the file
	function read_string return string is
            variable return_string: string(1 to LINE_LENGTH_MAX);
            variable read_char: character;
            variable read_ok: boolean := true;
            variable index: integer := 1;
        begin
            read(current_line, read_char, read_ok);
            while read_ok loop
                if read_char = ',' then
                    return return_string;
                else
                    return_string(index) := read_char;
                    index := index + 1;
                end if;
                read(current_line, read_char, read_ok);
            end loop;
	end function;  
	
	impure function read_integer return integer is
            variable read_value: integer;
            variable dummy_string: string(1 to LINE_LENGTH_MAX);
        begin
            read(current_line, read_value);
            dummy_string := read_string;
            return read_value;
    end;
	
	--dut
	component layer is
	generic(
		inputs  : natural := 5;         --! Network inputs = number of neurons in the previous layer
		outputs : natural := 4        --! Network outputs = number of neurons in the present layer
	);
	port(
		clk      : in  std_logic;	--! Clock input
		rst      : in  std_logic;	--! Reset output
		start_i  : in  std_logic;	--! Start input, indicates to start the calculation
		input_i  : in  std_logic_vector(inputs - 1 downto 0);--! Network input = ouput of previous layer
		weight_i : in  weight_matrix (outputs -1 downto 0);
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
        start_i <= '0', '1' after 15 ns, '0' after 30 ns;
        wait until done_o = '1';
    end process start_stimuli;
    input_stimuli : process is
    begin
        input_i <= "10101";
        weight_i <= ("11111","10101","01011","10111");
        wait ;
    end process;
		
	--Reading from the .csv file
	file_open(my_csv_file, "/test_file_path", READ_MODE);
	csv: process (rst) is
	   begin
        while not endfile(my_csv_file) loop
            readline(my_csv_file, current_line);    -- Read line from file
            for index in 0 to 10 loop   --THE RANGE NEEDS TO BE MODIFIED: loop for the numbers of elements in oen row
                weight_i(index) <= std_logic_vector(TO_UNSIGNED(read_integer,1));   -- Read value from line
            end loop;
        end loop;
   end process;
    
end behavioural;

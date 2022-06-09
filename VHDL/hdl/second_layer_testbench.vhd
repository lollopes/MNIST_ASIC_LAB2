library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;
use work.weight_matrix_pkg_layer_2.all;

entity second_layer_testbench is
--  Port ( );
end second_layer_testbench;

architecture tb of second_layer_testbench is
    --constants
    constant BIT_BUFF_WIDTH : natural := 1; -- lenght of buffer 
    constant ROW_BUFF_WIDTH_HIDDEN : natural := inputs_2; -- this buffer contains input and weight of layer 2 for 1 neuron (100)
    constant half_period : time := 10 ns;
    
    --signals
    file file_VECTORS : text; -- holds the vector of file
    file file_INPUTS  : text; -- holds the vector of file
    signal clk      : std_logic := '0';
	signal rst      : std_logic := '0';
	    
	-- Signals LAYER 2
    signal start_2  : std_logic := '0';
	signal done_2   : std_logic;
	signal input_2  : std_logic_vector(0 to inputs_2-1);--! Network input = ouput of previous layer
    signal weight_2 : weight_matrix_2 (outputs_2 -1 downto 0);
    signal output_2 :std_logic_vector (outputs_2-1 downto  0);
    signal expected_output_2  : std_logic_vector (outputs_2-1 downto  0);--! Network input = ouput of previous layer

    
    --component declaration
    component layer_2 is
	generic(
		inputs  : natural := 100;         --! Network inputs = number of neurons in the previous layer
		outputs : natural := 100        --! Network outputs = number of neurons in the present layer
	);
	port(
		clk      : in  std_logic;	--! Clock input
		rst      : in  std_logic;	--! Reset output
		start_i  : in  std_logic;	--! Start input, indicates to start the calculation
		input_i  : in  std_logic_vector(inputs_2 - 1 downto 0);--! Network input = ouput of previous layer
		weight_i : in  weight_matrix_2(outputs_2 -1 downto 0);
		output_o : out std_logic_vector(outputs_2 - 1 downto 0) := (others => '0'); --! Network output
		done_o   : out std_logic                              := '0' --! Done output, indicates completion -- signal to the next layer to begin the calculation
		                                                              -- done_o of previous layer is start_i of the next layer
	);
    end component;

begin
    --signals mapping
    
    --component portmap
    dut: layer_2 generic map (
            inputs  => inputs_2,         --! Network inputs = number of neurons in the previous layer
            outputs => outputs_2        --! Network outputs = number of neurons in the present layer
    )
    port map(
            clk      => clk,	        --! Clock input
            rst      => rst,	        --! Reset output
            start_i  => start_2,        --! Start input, indicates to start the calculation
            input_i  => input_2,        --! Network input = ouput of previous layer
            weight_i => weight_2,
            output_o => output_2,
            done_o   => done_2          --Done output, indicates completion -- signal to the next layer to begin the calculation
                                        -- done_o of previous layer is start_i of the next layer
    );
    
    --Stimuli generation	
    clk <= not clk after half_period;
    
    start_stimuli : process is
    begin
        start_2 <= '0', '1' after 15 ns, '0' after 35 ns;--'0' after 30 ns;
        rst <= '1', '0' after 11 ns;
        wait;
    end process start_stimuli;
    
    result_checks: process
    begin
        wait until (done_2 = '1');
        assert (output_2 /= expected_output_2) report "test FAILED" severity warning;
        assert (output_2 = expected_output_2) report "test PASSED" severity note;
    end process;
    
    -----------------------------------------------------
    --  PROCESSES FOR READING FROM FILES 
    -----------------------------------------------------
    
    -- 1. INPUTS OF LAYER 2
    process
        variable v_ILINE        : line;
        variable BIT_BUFFER     : std_logic_vector(BIT_BUFF_WIDTH-1 downto 0);
        variable ROW_BUFF_INPUT_2  : unsigned(ROW_BUFF_WIDTH_HIDDEN-1 downto 0) := (others => '0');
        variable TMP            : unsigned(ROW_BUFF_WIDTH_HIDDEN downto 0) := (others => '0');
        variable v_COMMA        : character;
        variable counter        : integer := 0;
    
    begin
 
    file_open(file_VECTORS, "/data/home/bnn-prj-15/data_sources/layer_1_out.txt",  read_mode);
    while not endfile(file_VECTORS) loop

            readline(file_VECTORS, v_ILINE);
                      
            for I in 0 to ROW_BUFF_WIDTH_HIDDEN-1 loop   
                    read(v_ILINE, BIT_BUFFER);
                    read(v_ILINE, v_COMMA);        
                    TMP:= (ROW_BUFF_INPUT_2 & unsigned(BIT_BUFFER));
                    ROW_BUFF_INPUT_2 := resize(unsigned(TMP),inputs_2);

             end loop;
             input_2  <= std_logic_vector(ROW_BUFF_INPUT_2);
     end loop;
    
    -- close the file at the end 
    file_close(file_VECTORS);    
    wait;
    end process;
    
    -- 2. WEIGHTS OF LAYER 2
    process
        variable v_ILINE        : line;
        variable BIT_BUFFER     : std_logic_vector(BIT_BUFF_WIDTH-1 downto 0);
        variable ROW_BUFFER_W2  : unsigned(ROW_BUFF_WIDTH_HIDDEN-1 downto 0) := (others => '0');
        variable TMP            : unsigned(ROW_BUFF_WIDTH_HIDDEN downto 0) := (others => '0');
        variable v_COMMA        : character;
        variable counter        : integer := 0;
    
    begin
 
    file_open(file_VECTORS, "/data/home/bnn-prj-15/data_sources/W_fc2.txt",  read_mode);
    while not endfile(file_VECTORS) loop
    
            readline(file_VECTORS, v_ILINE);
                      
            for I in 0 to ROW_BUFF_WIDTH_HIDDEN-1 loop   
                    read(v_ILINE, BIT_BUFFER);
                    read(v_ILINE, v_COMMA);        
                    TMP:= (ROW_BUFFER_W2 & unsigned(BIT_BUFFER));
                    ROW_BUFFER_W2 := resize(unsigned(TMP),inputs_2);

             end loop;
             -- Fill on row of the weight matrix with the row buffer read from file 
             weight_2(counter) <= std_logic_vector(ROW_BUFFER_W2);
             counter := counter +1;
     end loop;

    -- close the file at the end 
    file_close(file_VECTORS);    
    wait;
    end process;  
    
    -- 3. Outputs of layer 2
    process
        variable v_ILINE        : line;
        variable BIT_BUFFER     : std_logic_vector(BIT_BUFF_WIDTH-1 downto 0);
        variable ROW_BUFF_INPUT_2  : unsigned(ROW_BUFF_WIDTH_HIDDEN-1 downto 0) := (others => '0');
        variable TMP            : unsigned(ROW_BUFF_WIDTH_HIDDEN downto 0) := (others => '0');
        variable v_COMMA        : character;
        variable counter        : integer := 0;
    
    begin
 
    file_open(file_VECTORS, "/data/home/bnn-prj-15/data_sources/W_fc2.txt",  read_mode);
 
    while not endfile(file_VECTORS) loop
    
            readline(file_VECTORS, v_ILINE);
                      
            for I in 0 to ROW_BUFF_WIDTH_HIDDEN-1 loop   
                    read(v_ILINE, BIT_BUFFER);
                    read(v_ILINE, v_COMMA);        
                    TMP:= (ROW_BUFF_INPUT_2 & unsigned(BIT_BUFFER));
                    ROW_BUFF_INPUT_2 := resize(unsigned(TMP),inputs_2);

             end loop;
             expected_output_2  <= std_logic_vector(ROW_BUFF_INPUT_2);
     end loop;
    
    -- close the file at the end 
    file_close(file_VECTORS);    
    
    wait;
    end process;

end tb;

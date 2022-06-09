library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;
use work.weight_matrix_pkg_layer_1.all;
use work.weight_matrix_pkg_layer_2.all;
use work.weight_matrix_pkg_layer_3.all;
use work.weight_matrix_pkg_layer_out.all;


entity four_layers_testbench is
--  Port ( );
end four_layers_testbench;

architecture Behavioral of four_layers_testbench is

    --files
    file file_VECTORS : text; -- holds the vector of file
    file file_INPUTS  : text; -- holds the vector of file
    --constants
    constant BIT_BUFF_WIDTH : natural := 1; -- lenght of buffer 
    constant ROW_BUFF_WIDTH_INPUT : natural := inputs_1; -- this buffer contains input and weight of layer 1 for 1 neuron (784)
    constant ROW_BUFF_WIDTH_HIDDEN : natural := inputs_2; -- this buffer contains input and weight of layer 2 for 1 neuron (100)
    constant half_period : time := 10 ns;
	--signals
    signal clk      : std_logic := '0';
	signal rst      : std_logic := '0';
	signal expected_output_1 :std_logic_vector (0 to outputs_1-1);
	signal expected_output_2 :std_logic_vector (0 to outputs_2-1);
	signal expected_output_3 :std_logic_vector (0 to outputs_3-1);
    signal expected_output_out :integer_array_out (0 to outputs_out-1);

    -- Signals LAYER 1
    signal start_1  : std_logic := '0';
	signal done_1   : std_logic;
	signal input_1  : integer_array(inputs_1 - 1 downto 0);--! Network input = ouput of previous layer
    signal weight_1 : weight_matrix_integers (outputs_1 -1 downto 0);
    signal output_1 :std_logic_vector ( 0 to outputs_1-1);
    
	-- Signals LAYER 2
    signal start_2  : std_logic := '0';
	signal done_2   : std_logic;
	signal input_2  : std_logic_vector(0 to inputs_2 - 1);--! Network input = ouput of previous layer
    signal weight_2 : weight_matrix_2 (0 to outputs_2 -1);
    signal output_2 :std_logic_vector ( 0 to outputs_2-1);
    
    -- Signals LAYER 3
    signal start_3  : std_logic := '0';
	signal done_3   : std_logic;
	signal input_3  : std_logic_vector(0 to inputs_3 - 1);--! Network input = ouput of previous layer
    signal weight_3 : weight_matrix_3 (0 to outputs_3 -1);
    signal output_3 :std_logic_vector ( 0 to outputs_3-1);
    
    -- Signals LAYER OUT
    signal start_out  : std_logic := '0';
	signal done_out   : std_logic;
	signal input_out  : std_logic_vector(0 to inputs_out - 1);--! Network input = ouput of previous layer
    signal weight_out : weight_matrix_out (0 to outputs_out -1);
    signal output_out :integer_array_out ( 0 to outputs_out-1);
    
    signal BNN_out    : integer;
    
    
    component layer_1 is
        generic(
            inputs  : natural := 784;       --! Network inputs = number of neurons in the previous layer
            outputs : natural := 100        --! Network outputs = number of neurons in the present layer
        );
        port(
            clk      : in  std_logic;	--! Clock input
            rst      : in  std_logic;	--! Reset output
            start_i  : in  std_logic;	--! Start input, indicates to start the calculation
            input_i  : in  integer_array(0 to inputs-1) ;--! Network input = ouput of previous layer
            weight_i : in  weight_matrix_integers (outputs -1 downto 0);
            output_o : out std_logic_vector(outputs - 1 downto 0) := (others => '0'); --! Network output
            done_o   : out std_logic                              := '0' --! Done output, indicates completion -- signal to the next layer to begin the calculation
                                                                          -- done_o of previous layer is start_i of the next layer
        );
    end component layer_1;
    
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
    
   component layer_3 is
        generic(
            inputs  : natural := 100;         --! Network inputs = number of neurons in the previous layer
            outputs : natural := 100        --! Network outputs = number of neurons in the present layer
        );
        port(
            clk      : in  std_logic;	--! Clock input
            rst      : in  std_logic;	--! Reset output
            start_i  : in  std_logic;	--! Start input, indicates to start the calculation
            input_i  : in  std_logic_vector(inputs_3 - 1 downto 0);--! Network input = ouput of previous layer
            weight_i : in  weight_matrix_3(outputs_3 -1 downto 0);
            output_o : out std_logic_vector(outputs_3 - 1 downto 0) := (others => '0'); --! Network output
            done_o   : out std_logic                              := '0' --! Done output, indicates completion -- signal to the next layer to begin the calculation
                                                                          -- done_o of previous layer is start_i of the next layer
        );
    end component;

   component layer_out is
        generic(
            inputs  : natural := 100;         --! Network inputs = number of neurons in the previous layer
            outputs : natural := 100        --! Network outputs = number of neurons in the present layer
        );
        port(
            clk      : in  std_logic;	--! Clock input
            rst      : in  std_logic;	--! Reset output
            start_i  : in  std_logic;	--! Start input, indicates to start the calculation
            input_i  : in  std_logic_vector(inputs_out - 1 downto 0);--! Network input = ouput of previous layer
            weight_i : in  weight_matrix_out(outputs_out -1 downto 0);
            output_o : out integer_array_out(outputs_out - 1 downto 0) := (others => 0); --! Network output
            done_o   : out std_logic                              := '0' --! Done output, indicates completion -- signal to the next layer to begin the calculation
                                                                          -- done_o of previous layer is start_i of the next layer
        );
    end component;
    
    --count function
     function find_max_index (vector: integer_array_out; dim: integer) return integer is
        variable index, index_max: integer := 0;
        variable max_value: integer := 0;
    begin
        for index in 0 to dim-1 loop
            if vector(index) > max_value then
                index_max := index;
                max_value := vector(index);
            end if;
        end loop;
        return index_max;
    end function;
    
begin

    --Instantiation
    layer_inst_1: layer_1 generic map (
            inputs  => inputs_1,         --! Network inputs = number of neurons in the previous layer
            outputs => outputs_1        --! Network outputs = number of neurons in the present layer
    )
    port map(
            clk      => clk,	        --! Clock input
            rst      => rst,	        --! Reset output
            start_i  => start_1,        --! Start input, indicates to start the calculation
            input_i  => input_1,        --! Network input = ouput of previous layer
            weight_i => weight_1,
            output_o => output_1,
            done_o   => done_1          --Done output, indicates completion -- signal to the next layer to begin the calculation
                                        -- done_o of previous layer is start_i of the next layer
    );
    
    layer_inst_2: layer_2 generic map (
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
    
    layer_inst_3: layer_3 generic map (
            inputs  => inputs_3,         --! Network inputs = number of neurons in the previous layer
            outputs => outputs_3        --! Network outputs = number of neurons in the present layer
    )
    port map(
            clk      => clk,	        --! Clock input
            rst      => rst,	        --! Reset output
            start_i  => start_3,        --! Start input, indicates to start the calculation
            input_i  => input_3,        --! Network input = ouput of previous layer
            weight_i => weight_3,
            output_o => output_3,
            done_o   => done_3          --Done output, indicates completion -- signal to the next layer to begin the calculation
                                        -- done_o of previous layer is start_i of the next layer
    );
    
    layer_inst_out: layer_out generic map (
            inputs  => inputs_out,         --! Network inputs = number of neurons in the previous layer
            outputs => outputs_out        --! Network outputs = number of neurons in the present layer
    )
    port map(
            clk      => clk,	        --! Clock input
            rst      => rst,	        --! Reset output
            start_i  => start_out,        --! Start input, indicates to start the calculation
            input_i  => input_out,        --! Network input = ouput of previous layer
            weight_i => weight_out,
            output_o => output_out,
            done_o   => done_out          --Done output, indicates completion -- signal to the next layer to begin the calculation
                                        -- done_o of previous layer is start_i of the next layer
    );

    --Stimuli generation	
    clk <= not clk after half_period;

    start_stimuli : process is
    begin
        start_1 <= '0', '1' after 15 ns, '0' after 35 ns;--'0' after 30 ns;
        rst <= '1', '0' after 11 ns;
        wait;
    end process start_stimuli;
    
    ---------------------------PORT MAP----------------------------------
        
    start_2 <= done_1;
    input_2 <= output_1;
    start_3 <= done_2;
    input_3 <= output_2;
    start_out <= done_3;
    input_out <= output_3;
    BNN_out <= find_max_index(output_out, 10);
     
    ----------------------------------------------------------------------
   -- 1. PROCESS FOR READING THE INPUT VECTOR FROM THE FILE
    process
    variable v_ILINE                : line;
    variable BIT_BUFFER             : std_logic_vector(BIT_BUFF_WIDTH-1 downto 0);
    variable ROW_BUFF_INPUT         : integer_array(ROW_BUFF_WIDTH_INPUT-1 downto 0) := (others => 0);
    variable TMP                    : integer_array(ROW_BUFF_WIDTH_INPUT downto 0) := (others => 0);
    variable v_COMMA                : character;
    variable counter                : integer := 0;
    variable integer_bit_buffer     : integer;
    
    begin
 
    file_open(file_INPUTS, "/data/home/bnn-prj-15/data_sources/input_number_1_output_8.txt",  read_mode);
 
    while not endfile(file_INPUTS) loop
  
            readline(file_INPUTS, v_ILINE);
                      
            for I in 0 to ROW_BUFF_WIDTH_INPUT-1 loop   
                    read(v_ILINE, BIT_BUFFER);
                    read(v_ILINE, v_COMMA);
                    integer_bit_buffer := to_integer(unsigned(BIT_BUFFER));            
                    TMP:= (ROW_BUFF_INPUT & integer_bit_buffer);
                    ROW_BUFF_INPUT := TMP(ROW_BUFF_WIDTH_INPUT-1 downto 0);
           end loop;
            input_1  <= (ROW_BUFF_INPUT);
    end loop;
    
    -- close the file at the end 
    file_close(file_INPUTS);    
    
    wait;
    end process;
  
    -- 2. PROCESS FOR READING THE WEIGHTS OF LAYER 1
    process
        variable v_ILINE        : line;
        variable BIT_BUFFER     : std_logic_vector(BIT_BUFF_WIDTH-1 downto 0);
        variable ROW_BUFFER_W1  : integer_array(ROW_BUFF_WIDTH_INPUT-1 downto 0) := (others => 0);
        variable TMP            : integer_array(ROW_BUFF_WIDTH_INPUT downto 0) := (others => 0);
        variable v_COMMA        : character;
        variable counter        : integer := 0;
        variable integer_bit_buffer: integer;
    
    begin
 
    file_open(file_VECTORS, "/data/home/bnn-prj-15/data_sources/W_fc1.txt",  read_mode);
 
    while not endfile(file_VECTORS) loop
    
            readline(file_VECTORS, v_ILINE);
                      
            for I in 0 to ROW_BUFF_WIDTH_INPUT-1 loop   
                    read(v_ILINE, BIT_BUFFER);
                    read(v_ILINE, v_COMMA);
                    
                    if(unsigned(BIT_BUFFER) = 0) then
                        integer_bit_buffer := -1;
                    else
                        integer_bit_buffer := to_integer(unsigned(BIT_BUFFER)); 
                    end if;   
                            
                    TMP:= (ROW_BUFFER_W1 & integer_bit_buffer);
                    ROW_BUFFER_W1 := TMP(ROW_BUFF_WIDTH_INPUT-1 downto 0);

             end loop;
             -- Fill on row of the weight matrix with the row buffer read from file 
             weight_1(counter) <= (ROW_BUFFER_W1);
             counter := counter +1;
     end loop;
    
    -- close the file at the end 
    file_close(file_VECTORS);    
    
    wait;
    end process;
    
    -- 3. PROCESS FOR READING THE WEIGHTS OF LAYER 2
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

    -- 4. PROCESS FOR READING THE WEIGHTS OF LAYER 3
    process
        variable v_ILINE        : line;
        variable BIT_BUFFER     : std_logic_vector(BIT_BUFF_WIDTH-1 downto 0);
        variable ROW_BUFFER_W2  : unsigned(ROW_BUFF_WIDTH_HIDDEN-1 downto 0) := (others => '0');
        variable TMP            : unsigned(ROW_BUFF_WIDTH_HIDDEN downto 0) := (others => '0');
        variable v_COMMA        : character;
        variable counter        : integer := 0;
    
    begin
 
    file_open(file_VECTORS, "/data/home/bnn-prj-15/data_sources/W_fc3.txt",  read_mode);
 
    while not endfile(file_VECTORS) loop
    
            readline(file_VECTORS, v_ILINE);
                      
            for I in 0 to ROW_BUFF_WIDTH_HIDDEN-1 loop   
                    read(v_ILINE, BIT_BUFFER);
                    read(v_ILINE, v_COMMA);        
                    TMP:= (ROW_BUFFER_W2 & unsigned(BIT_BUFFER));
                    ROW_BUFFER_W2 := resize(unsigned(TMP),inputs_2);

             end loop;
             -- Fill on row of the weight matrix with the row buffer read from file 
             weight_3(counter) <= std_logic_vector(ROW_BUFFER_W2);
             counter := counter +1;
     end loop;
    
    -- close the file at the end 
    file_close(file_VECTORS);    
    
    wait;
    end process;    

    -- 5. PROCESS FOR READING THE WEIGHTS OF LAYER OUt
    process
        variable v_ILINE        : line;
        variable BIT_BUFFER     : std_logic_vector(BIT_BUFF_WIDTH-1 downto 0);
        variable ROW_BUFFER_W2  : unsigned(ROW_BUFF_WIDTH_HIDDEN-1 downto 0) := (others => '0');
        variable TMP            : unsigned(ROW_BUFF_WIDTH_HIDDEN downto 0) := (others => '0');
        variable v_COMMA        : character;
        variable counter        : integer := 0;
    
    begin
 
    file_open(file_VECTORS, "/data/home/bnn-prj-15/data_sources/W_fc4.txt",  read_mode);
 
    while not endfile(file_VECTORS) loop
    
            readline(file_VECTORS, v_ILINE);
                      
            for I in 0 to ROW_BUFF_WIDTH_HIDDEN-1 loop   
                    read(v_ILINE, BIT_BUFFER);
                    read(v_ILINE, v_COMMA);        
                    TMP:= (ROW_BUFFER_W2 & unsigned(BIT_BUFFER));
                    ROW_BUFFER_W2 := resize(unsigned(TMP),inputs_2);

             end loop;
             -- Fill on row of the weight matrix with the row buffer read from file 
             weight_out(counter) <= std_logic_vector(ROW_BUFFER_W2);
             counter := counter +1;
     end loop;
    
    -- close the file at the end 
    file_close(file_VECTORS);    
    
    wait;
    end process;        
    
 ---------------------------------------------------------------------------------------------------------
 -- These are for asserting the results 
 
    -- 4. Outputs of layer 1
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
             expected_output_1  <= std_logic_vector(ROW_BUFF_INPUT_2);
     end loop;
    
    -- close the file at the end 
    file_close(file_VECTORS);    
    
    wait;
    end process;
    
    -- 5. Outputs of layer 2
    process
        variable v_ILINE        : line;
        variable BIT_BUFFER     : std_logic_vector(BIT_BUFF_WIDTH-1 downto 0);
        variable ROW_BUFF_INPUT_2  : unsigned(ROW_BUFF_WIDTH_HIDDEN-1 downto 0) := (others => '0');
        variable TMP            : unsigned(ROW_BUFF_WIDTH_HIDDEN downto 0) := (others => '0');
        variable v_COMMA        : character;
        variable counter        : integer := 0;
    
    begin
 
    file_open(file_VECTORS, "/data/home/bnn-prj-15/data_sources/layer_2_out.txt",  read_mode);
 
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
    
  -- 5. Outputs of layer 3
    process
        variable v_ILINE        : line;
        variable BIT_BUFFER     : std_logic_vector(BIT_BUFF_WIDTH-1 downto 0);
        variable ROW_BUFF_INPUT_2  : unsigned(ROW_BUFF_WIDTH_HIDDEN-1 downto 0) := (others => '0');
        variable TMP            : unsigned(ROW_BUFF_WIDTH_HIDDEN downto 0) := (others => '0');
        variable v_COMMA        : character;
        variable counter        : integer := 0;
    
    begin
 
    file_open(file_VECTORS, "/data/home/bnn-prj-15/data_sources/layer_3_out.txt",  read_mode);
 
    while not endfile(file_VECTORS) loop
    
            readline(file_VECTORS, v_ILINE);
                      
            for I in 0 to ROW_BUFF_WIDTH_HIDDEN-1 loop   
                    read(v_ILINE, BIT_BUFFER);
                    read(v_ILINE, v_COMMA);        
                    TMP:= (ROW_BUFF_INPUT_2 & unsigned(BIT_BUFFER));
                    ROW_BUFF_INPUT_2 := resize(unsigned(TMP),inputs_2);

             end loop;
             expected_output_3  <= std_logic_vector(ROW_BUFF_INPUT_2);
     end loop;
    
    -- close the file at the end 
    file_close(file_VECTORS);    
    
    wait;
    end process;

    result_checks: process
    begin
        wait until (done_1 = '1');
        assert (output_1 /= expected_output_1) report "layer 1 FAILED" severity warning;
        assert (output_1 = expected_output_1) report "layer 1  PASSED" severity note;
        wait until (done_2 = '1');
        assert (output_2 /= expected_output_2) report "layer 2 FAILED" severity warning;
        assert (output_2 = expected_output_2) report "layer 2 PASSED" severity note;
        wait until (done_3 = '1');
        assert (output_3 /= expected_output_3) report "layer 3 FAILED" severity warning;
        assert (output_3 = expected_output_3) report "layer 3 PASSED" severity note;
    end process;



end Behavioral;

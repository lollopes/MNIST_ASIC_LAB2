-------------------------------------------------------------------------------
-- File Downloaded from http://www.nandland.com
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;
use work.custom_types.all;

-- Declare entity of test bench 
entity first_layer_testbench is
 
end first_layer_testbench;
 
-- Architecture definition of the testbench
architecture tb of first_layer_testbench is
  
  -----------------------------------------------------------------------------
  -- Testbench Internal Signals
  -----------------------------------------------------------------------------
    file file_VECTORS : text; -- holds the vector of file
    file file_INPUTS  : text; -- holds the vector of file
    constant BIT_BUFF_WIDTH : natural := 1; -- lenght of buffer 
    constant ROW_BUFF_WIDTH : natural := inputs_1; -- 4 is size of row(# of cols)
    constant half_period : time := 10 ns;
	
	signal input_vector : integer_array(0 to inputs_1 - 1);
    signal clk      : std_logic := '0';
	signal rst      : std_logic := '0';
	signal input_i  : integer_array(inputs_1 - 1 downto 0);--! Network input = ouput of previous layer
    signal weight_i : weight_matrix_integers (outputs_1 -1 downto 0);
	signal start_i  : std_logic := '0';
	signal done_o   : std_logic;
	signal output_o :std_logic_vector ( 0 to outputs_1-1);

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
     
    begin

    --Instantiation
    layer_lbl: layer_1 generic map (
            inputs  => inputs_1,         --! Network inputs = number of neurons in the previous layer
            outputs => outputs_1        --! Network outputs = number of neurons in the present layer
    )
    port map(
            clk      => clk,	        --! Clock input
            rst      => rst,	        --! Reset output
            start_i  => start_i,        --! Start input, indicates to start the calculation
            input_i  => input_i,        --! Network input = ouput of previous layer
            weight_i => weight_i,
            output_o => output_o,
            done_o   => done_o          --Done output, indicates completion -- signal to the next layer to begin the calculation
                                        -- done_o of previous layer is start_i of the next layer
    );
    

    --Stimuli generation
	--Stimuli generation	
    clk <= not clk after half_period;

    start_stimuli : process is
    begin
        start_i <= '0', '1' after 15 ns, '0' after 35 ns;--'0' after 30 ns;
        rst <= '1', '0' after 11 ns;
        wait;
    end process start_stimuli;

    -- PROCESS FOR READING THE WEIGHTS FROM THE FILE
    process
        variable v_ILINE        : line;
        variable BIT_BUFFER     : std_logic_vector(BIT_BUFF_WIDTH-1 downto 0);
        variable ROW_BUFFER     : integer_array(ROW_BUFF_WIDTH-1 downto 0) := (others => 0);
        variable TMP            : integer_array(ROW_BUFF_WIDTH downto 0) := (others => 0);
        variable v_COMMA        : character;
        variable counter        : integer := 0;
        variable integer_bit_buffer: integer;
    
    begin
 
    --file_open(file_VECTORS, "/data/home/bnn-prj-15/data_sources/W_fc1.txt",  read_mode);
    file_open(file_VECTORS, "E:\Users\jccx1\Documents\TUDelft_projects_root\AI\Lab-2\data_sources\W_fc1.txt",  read_mode);
 
    while not endfile(file_VECTORS) loop
    
            readline(file_VECTORS, v_ILINE);
                      
            for I in 0 to ROW_BUFF_WIDTH-1 loop   
                    read(v_ILINE, BIT_BUFFER);
                    read(v_ILINE, v_COMMA);
                    
                    if(unsigned(BIT_BUFFER) = 0) then
                        integer_bit_buffer := -1;
                    else
                        integer_bit_buffer := to_integer(unsigned(BIT_BUFFER)); 
                    end if;   
                            
                    TMP:= (ROW_BUFFER & integer_bit_buffer);
                    ROW_BUFFER := TMP(ROW_BUFF_WIDTH-1 downto 0);

             end loop;
             
             -- Fill on row of the weight matrix with the row buffer read from file 
             weight_i(counter) <= (ROW_BUFFER);
             counter := counter +1;
     end loop;
    
    -- close the file at the end 
    file_close(file_VECTORS);    
    
    wait;
    end process;
    
    
    -- PROCESS FOR READING THE INPUT VECTOR FROM THE FILE
    process
    variable v_ILINE        : line;
    variable BIT_BUFFER     : std_logic_vector(BIT_BUFF_WIDTH-1 downto 0);
    variable ROW_BUFFER     : integer_array(ROW_BUFF_WIDTH-1 downto 0) := (others => 0);
    variable TMP            : integer_array(ROW_BUFF_WIDTH downto 0) := (others => 0);
    variable v_COMMA        : character;
    variable counter        : integer := 0;
    variable integer_bit_buffer: integer;
    
    begin
 
    --file_open(file_INPUTS, "/data/home/bnn-prj-15/data_sources/input_image_flatten.txt",  read_mode);
    file_open(file_INPUTS, "E:\Users\jccx1\Documents\TUDelft_projects_root\AI\Lab-2\data_sources\input_image_flatten.txt",  read_mode);
 
    while not endfile(file_INPUTS) loop
    
            readline(file_INPUTS, v_ILINE);
                      
            for I in 0 to ROW_BUFF_WIDTH-1 loop   
                    read(v_ILINE, BIT_BUFFER);
                    read(v_ILINE, v_COMMA);
                    integer_bit_buffer := to_integer(unsigned(BIT_BUFFER));            
                    TMP:= (ROW_BUFFER & integer_bit_buffer);
                    ROW_BUFFER := TMP(ROW_BUFF_WIDTH-1 downto 0);
           end loop;
            input_i  <= (ROW_BUFFER);
    end loop;
    
    -- close the file at the end 
    file_close(file_INPUTS);    
    
    wait;
  end process;
  
 
end tb;
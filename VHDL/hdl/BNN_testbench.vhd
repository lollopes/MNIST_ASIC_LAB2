library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;
use work.custom_types.all;


entity BNN_testbench is
--  Port ( );
end BNN_testbench;

architecture tb of BNN_testbench is

    --dut
    component BNN is
        generic(layer_1_in_dim : integer:= inputs_1;
                layer_2_in_dim : integer:= inputs_2;
                layer_3_in_dim : integer:= inputs_3;
                layer_out_in_dim: integer:= inputs_out;
                layer_1_out_dim : integer:= outputs_1;
                layer_2_out_dim : integer:= outputs_2;
                layer_3_out_dim : integer:= outputs_3;
                layer_out_out_dim: integer:= outputs_out
        );
        port(
            CLK         : in std_logic;
            rst         : in std_logic;
            start       : in std_logic;
            input_vector : in signed_array(layer_1_in_dim-1 downto 0);
            weight_matrix_1_port : in weight_matrix_signed(layer_1_out_dim-1 downto 0);
            weight_matrix_2_port : in weight_matrix_2(layer_2_out_dim -1 downto 0);
            weight_matrix_3_port : in weight_matrix_3(layer_3_out_dim -1 downto 0);
            weight_matrix_out_port : in weight_matrix_out(layer_out_out_dim -1 downto 0);
            BNN_output: out integer range 0 to 9;
            BNN_done : out std_logic
        );
    end component BNN;

    
    --simulation signals
    signal clk      : std_logic := '0';
	signal rst      : std_logic := '0';
	signal start_signal    : std_logic := '0';
	signal input_buffer  : integer_array(inputs_1 - 1 downto 0);--! Network input = ouput of previous layer
    signal weight_1_buffer : weight_matrix_integers (outputs_1 -1 downto 0);
	signal weight_2_buffer : weight_matrix_2 (0 to outputs_2 -1);
	signal weight_3_buffer : weight_matrix_3 (0 to outputs_3 -1);
    signal weight_out_buffer : weight_matrix_out (0 to outputs_out -1);
    
    --pretty nasty conversion sorry!
    signal input_buffer_signed    : signed_array(inputs_1 - 1 downto 0);
    signal weight_1_buffer_signed : weight_matrix_signed (outputs_1 -1 downto 0);
        
    signal out_buffer   : integer range -inputs_out to inputs_out - 1:= 0;
    
    --source files signals
    file file_VECTORS : text; -- holds the vector of file
    file file_INPUTS  : text; -- holds the vector of file
    constant BIT_BUFF_WIDTH : natural := 1; -- lenght of buffer 
    constant ROW_BUFF_WIDTH_INPUT : natural := inputs_1; -- this buffer contains input and weight of layer 1 for 1 neuron (784)
    constant ROW_BUFF_WIDTH_HIDDEN : natural := inputs_2; -- this buffer contains input and weight of layer 2 for 1 neuron (100)
    constant half_period : time := 10 ns;

begin
    
    --portmap
    dut: BNN
         port map(
             clk         => clk,
             rst         => rst,
             start       => start_signal,
             input_vector => input_buffer_signed,
             weight_matrix_1_port => weight_1_buffer_signed,
             weight_matrix_2_port => weight_2_buffer,
             weight_matrix_3_port => weight_3_buffer,
             weight_matrix_out_port => weight_out_buffer,
             BNN_output => out_buffer
         );

    ---- TESTBENCH ----
    
    --Stimuli generation	
    clk <= not clk after half_period;
    start_stimuli : process is
    begin
        start_signal <= '0', '1' after 15 ns, '0' after 35 ns;
        rst <= '1', '0' after 11 ns;
        wait;
    end process start_stimuli;
    
    ---- NASTY CONVERSION ----
    input_vector: process(input_buffer)
    begin
        for index in 0 to input_buffer'length-1 loop
            if input_buffer(index) = 0 then
                input_buffer_signed(index) <= "00";
            else
                input_buffer_signed(index) <= "01";
            end if;
        end loop;
    end process;
    
    w1_matrix: process(weight_1_buffer)
    begin
        for i in 0 to weight_1_buffer'length-1 loop
            for j in 0 to inputs_1 - 1 loop
                if weight_1_buffer(i)(j) = -1 then
                    weight_1_buffer_signed(i)(j) <= "11";
                else
                    weight_1_buffer_signed(i)(j) <= "01";
                end if;
            end loop;
        end loop;
    end process;
    
    
    ---- PROCESSES ----
    
    -- 1. PROCESS FOR READING THE INPUT VECTOR (IMAGE) FROM THE FILE
    input_file: process
        variable v_ILINE                : line;
        variable BIT_BUFFER             : std_logic_vector(BIT_BUFF_WIDTH-1 downto 0);
        variable ROW_BUFF_INPUT         : integer_array(ROW_BUFF_WIDTH_INPUT-1 downto 0) := (others => 0);
        variable TMP                    : integer_array(ROW_BUFF_WIDTH_INPUT downto 0) := (others => 0);
        variable v_COMMA                : character;
        variable counter                : integer := 0;
        variable integer_bit_buffer     : integer;
        
    begin
     
        --file_open(file_INPUTS, "/data/home/bnn-prj-15/data_sources/input_number_2_output_2.txt",  read_mode);
        file_open(file_INPUTS, "data_sources\input_number_7_output_7.txt",  read_mode);
        while not endfile(file_INPUTS) loop
                readline(file_INPUTS, v_ILINE);    
                for I in 0 to ROW_BUFF_WIDTH_INPUT-1 loop   
                        read(v_ILINE, BIT_BUFFER);
                        read(v_ILINE, v_COMMA);
                        integer_bit_buffer := to_integer(unsigned(BIT_BUFFER));            
                        TMP:= (ROW_BUFF_INPUT & integer_bit_buffer);
                        ROW_BUFF_INPUT := TMP(ROW_BUFF_WIDTH_INPUT-1 downto 0);
               end loop;
                input_buffer  <= (ROW_BUFF_INPUT);
        end loop;
        -- close the file at the end 
        file_close(file_INPUTS);    
        wait;
    end process;
  
    -- 2. PROCESS FOR READING THE WEIGHTS OF LAYER 1
    w1: process
        variable v_ILINE        : line;
        variable BIT_BUFFER     : std_logic_vector(BIT_BUFF_WIDTH-1 downto 0);
        variable ROW_BUFFER_W1  : integer_array(ROW_BUFF_WIDTH_INPUT-1 downto 0) := (others => 0);
        variable TMP            : integer_array(ROW_BUFF_WIDTH_INPUT downto 0) := (others => 0);
        variable v_COMMA        : character;
        variable counter        : integer := 0;
        variable integer_bit_buffer: integer;
    
    begin
 
        --file_open(file_VECTORS, "/data/home/bnn-prj-15/data_sources/W_fc1.txt",  read_mode);
        file_open(file_VECTORS, "C:\Users\Ismail\Documents\AI\data_sources\W_fc1.txt",  read_mode);
        
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
                 weight_1_buffer(counter) <= (ROW_BUFFER_W1);
                 counter := counter +1;
         end loop;
        -- close the file at the end 
        file_close(file_VECTORS);    
        wait;
    end process;
    
    -- 3. PROCESS FOR READING THE WEIGHTS OF LAYER 2
    w2: process
        variable v_ILINE        : line;
        variable BIT_BUFFER     : std_logic_vector(BIT_BUFF_WIDTH-1 downto 0);
        variable ROW_BUFFER_W2  : unsigned(ROW_BUFF_WIDTH_HIDDEN-1 downto 0) := (others => '0');
        variable TMP            : unsigned(ROW_BUFF_WIDTH_HIDDEN downto 0) := (others => '0');
        variable v_COMMA        : character;
        variable counter        : integer := 0;
    
    begin
 
        --file_open(file_VECTORS, "/data/home/bnn-prj-15/data_sources/W_fc2.txt",  read_mode);
        file_open(file_VECTORS, "data_sources\W_fc2.txt",  read_mode);

        while not endfile(file_VECTORS) loop
                readline(file_VECTORS, v_ILINE);    
                for I in 0 to ROW_BUFF_WIDTH_HIDDEN-1 loop   
                        read(v_ILINE, BIT_BUFFER);
                        read(v_ILINE, v_COMMA);        
                        TMP:= (ROW_BUFFER_W2 & unsigned(BIT_BUFFER));
                        ROW_BUFFER_W2 := resize(unsigned(TMP),inputs_2);
                 end loop;
                 -- Fill on row of the weight matrix with the row buffer read from file 
                 weight_2_buffer(counter) <= std_logic_vector(ROW_BUFFER_W2);
                 counter := counter +1;
         end loop;
        -- close the file at the end 
        file_close(file_VECTORS);    
        wait;
    end process;  

    -- 4. PROCESS FOR READING THE WEIGHTS OF LAYER 3
    w3: process
        variable v_ILINE        : line;
        variable BIT_BUFFER     : std_logic_vector(BIT_BUFF_WIDTH-1 downto 0);
        variable ROW_BUFFER_W2  : unsigned(ROW_BUFF_WIDTH_HIDDEN-1 downto 0) := (others => '0');
        variable TMP            : unsigned(ROW_BUFF_WIDTH_HIDDEN downto 0) := (others => '0');
        variable v_COMMA        : character;
        variable counter        : integer := 0;
    
    begin
 
        --file_open(file_VECTORS, "/data/home/bnn-prj-15/data_sources/W_fc3.txt",  read_mode);
        file_open(file_VECTORS, "data_sources\W_fc3.txt",  read_mode);
        while not endfile(file_VECTORS) loop
                readline(file_VECTORS, v_ILINE);
                for I in 0 to ROW_BUFF_WIDTH_HIDDEN-1 loop   
                        read(v_ILINE, BIT_BUFFER);
                        read(v_ILINE, v_COMMA);        
                        TMP:= (ROW_BUFFER_W2 & unsigned(BIT_BUFFER));
                        ROW_BUFFER_W2 := resize(unsigned(TMP),inputs_2);
                 end loop;
                 -- Fill on row of the weight matrix with the row buffer read from file 
                 weight_3_buffer(counter) <= std_logic_vector(ROW_BUFFER_W2);
                 counter := counter +1;
         end loop;
        -- close the file at the end 
        file_close(file_VECTORS);
        wait;
    end process;    

    -- 5. PROCESS FOR READING THE WEIGHTS OF LAYER OUt
    w4: process
        variable v_ILINE        : line;
        variable BIT_BUFFER     : std_logic_vector(BIT_BUFF_WIDTH-1 downto 0);
        variable ROW_BUFFER_W2  : unsigned(ROW_BUFF_WIDTH_HIDDEN-1 downto 0) := (others => '0');
        variable TMP            : unsigned(ROW_BUFF_WIDTH_HIDDEN downto 0) := (others => '0');
        variable v_COMMA        : character;
        variable counter        : integer := 0;
    
    begin
 
        --file_open(file_VECTORS, "/data/home/bnn-prj-15/data_sources/W_fc4.txt",  read_mode);
        file_open(file_VECTORS, "data_sources\W_fc4.txt",  read_mode);        
        while not endfile(file_VECTORS) loop
                readline(file_VECTORS, v_ILINE);
                for I in 0 to ROW_BUFF_WIDTH_HIDDEN-1 loop   
                        read(v_ILINE, BIT_BUFFER);
                        read(v_ILINE, v_COMMA);        
                        TMP:= (ROW_BUFFER_W2 & unsigned(BIT_BUFFER));
                        ROW_BUFFER_W2 := resize(unsigned(TMP),inputs_2);
                 end loop;
                 -- Fill on row of the weight matrix with the row buffer read from file 
                 weight_out_buffer(counter) <= std_logic_vector(ROW_BUFFER_W2);
                 counter := counter +1;
         end loop;
        -- close the file at the end 
        file_close(file_VECTORS);   
        wait;
    end process;

end tb;

library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.weight_matrix_pkg_layer_1.all;
use work.weight_matrix_pkg_layer_2.all;
use work.weight_matrix_pkg_layer_3.all;
use work.weight_matrix_pkg_layer_out.all;


entity BNN is
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
        clk         : in std_logic;
        rst         : in std_logic;
        start       : in std_logic;
        input_vector : in integer_array(layer_1_in_dim-1 downto 0);
        weight_matrix_1_port : in weight_matrix_integers(layer_1_out_dim-1 downto 0);
        weight_matrix_2_port : in weight_matrix_2(layer_2_out_dim -1 downto 0);
        weight_matrix_3_port : in weight_matrix_3(layer_3_out_dim -1 downto 0);
        weight_matrix_out_port : in weight_matrix_out(layer_out_out_dim -1 downto 0);
        BNN_output: out integer;
        BNN_done : out std_logic
    );
end entity BNN;

architecture structure of BNN is

    ---- SIGNALS ----
    
    -- Signals LAYER 1
    --signal start_1  : std_logic := '0';
	signal done_1   : std_logic;
	--signal input_1  : integer_array(inputs_1 - 1 downto 0);--! Network input = ouput of previous layer
    --signal weight_1 : weight_matrix_integers (outputs_1 -1 downto 0);
    signal output_1 :std_logic_vector ( 0 to outputs_1-1);
    
	-- Signals LAYER 2
    signal start_2  : std_logic := '0';
	signal done_2   : std_logic;
	signal input_2  : std_logic_vector(0 to inputs_2 - 1);--! Network input = ouput of previous layer
    --signal weight_2 : weight_matrix_2 (0 to outputs_2 -1);
    signal output_2 :std_logic_vector ( 0 to outputs_2-1);
    
    -- Signals LAYER 3
    signal start_3  : std_logic := '0';
	signal done_3   : std_logic;
	signal input_3  : std_logic_vector(0 to inputs_3 - 1);--! Network input = ouput of previous layer
    --signal weight_3 : weight_matrix_3 (0 to outputs_3 -1);
    signal output_3 :std_logic_vector ( 0 to outputs_3-1);
    
    -- Signals LAYER OUT
    signal start_out  : std_logic := '0';
	--signal done_out   : std_logic;
	signal input_out  : std_logic_vector(0 to inputs_out - 1);--! Network input = ouput of previous layer
    --signal weight_out : weight_matrix_out (0 to outputs_out -1);
    signal output_out :integer_array_out ( 0 to outputs_out-1);
    
    ---- COMPONENTS ----
    
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
            input_i  : in  std_logic_vector(inputs - 1 downto 0);--! Network input = ouput of previous layer
            weight_i : in  weight_matrix_2(outputs -1 downto 0);
            output_o : out std_logic_vector(outputs - 1 downto 0) := (others => '0'); --! Network output
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
            input_i  : in  std_logic_vector(inputs - 1 downto 0);--! Network input = ouput of previous layer
            weight_i : in  weight_matrix_3(outputs -1 downto 0);
            output_o : out std_logic_vector(outputs - 1 downto 0) := (others => '0'); --! Network output
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
            input_i  : in  std_logic_vector(inputs - 1 downto 0);--! Network input = ouput of previous layer
            weight_i : in  weight_matrix_out(outputs -1 downto 0);
            output_o : out integer_array_out(outputs - 1 downto 0) := (others => 0); --! Network output
            done_o   : out std_logic                              := '0' --! Done output, indicates completion -- signal to the next layer to begin the calculation
                                                                          -- done_o of previous layer is start_i of the next layer
        );
    end component;

    ---- FUNCTION ----
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

    ---- COMPONENTS PORTMAPS ----
    layer_inst_1: layer_1 generic map (
            inputs  => inputs_1,         --! Network inputs = number of neurons in the previous layer
            outputs => outputs_1        --! Network outputs = number of neurons in the present layer
    )
    port map(
            clk      => clk,	        --! Clock input
            rst      => rst,	        --! Reset output
            start_i  => start,        --! Start input, indicates to start the calculation
            input_i  => input_vector,        --! Network input = ouput of previous layer
            weight_i => weight_matrix_1_port,
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
            weight_i => weight_matrix_2_port,
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
            weight_i => weight_matrix_3_port,
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
            weight_i => weight_matrix_out_port,
            output_o => output_out,
            done_o   => BNN_done          --Done output, indicates completion -- signal to the next layer to begin the calculation
                                        -- done_o of previous layer is start_i of the next layer
    );

    ---- SIGNALS MAPPING ----   
    start_2 <= done_1;
    input_2 <= output_1;
    start_3 <= done_2;
    input_3 <= output_2;
    start_out <= done_3;
    input_out <= output_3;
    BNN_output <= find_max_index(output_out, 10);

end architecture;

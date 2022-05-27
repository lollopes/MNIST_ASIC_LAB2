library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.types.all;
use work.weight_matrix_pkg.all;
entity layer_tb is
end entity layer_tb;

architecture behavioural of layer_tb is
	
	constant inputs : natural := 5;
	constant outputs : natural := 4;
	
	constant half_period : time := 10 ns;
	
	signal clk      : std_logic := '0';
	signal rst      : std_logic := '0';
	signal input_i  : std_logic_vector(inputs - 1 downto 0);--! Network input = ouput of previous layer
    signal weight_i : weight_matrix (outputs -1 downto 0);
	signal start_i  : std_logic := '0';
	signal done_o   : std_logic;
	signal output_o :std_logic_vector (outputs-1 downto 0);
	
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

    layer_inst : layer
		generic map(
			inputs  => inputs,
			outputs => outputs
		)
		port map(
			clk      => clk,
			rst      => rst,
			start_i  => start_i,
			input_i  => input_i,
			weight_i => weight_i,
			output_o => output_o,
			done_o   => done_o
		);
		
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
		
		
end behavioural;

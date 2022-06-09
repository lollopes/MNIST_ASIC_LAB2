

-- Author @ Karan Pathak

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.custom_types.all;


entity integer_neuron_testbench is
end entity integer_neuron_testbench;

architecture tb of integer_neuron_testbench is

component integer_neuron is
	generic(
		inputs : integer := 7            --! Number of inputs into the neuron
	);
	port(
		clk      : in  std_logic;        --! Clock input
		rst      : in  std_logic;        --! Reset input
		start_i  : in  std_logic;        --! Start input, indicates to start

		input_i  : in  integer_array(inputs - 1 downto 0); --! Neuron inputs
		weight_i : in  integer_array(inputs - 1 downto 0); --! Neuron weights 
		                                                  
		output_o : out std_logic;   --! Neuron output
		done_o   : out std_logic  := '0' --! Done output, indicates completion
	);
end component;

	constant half_period : time := 10 ns;

	constant inputs : integer := 4;

	signal clk      : std_logic                         := '0';
	signal rst      : std_logic                         := '0';
	signal start_i  : std_logic                         := '0';
	signal input_i  : integer_array(inputs - 1 downto 0); --! Neuron inputs
	signal weight_i : integer_array(inputs - 1 downto 0); --! Neuron weights 
	signal output_o : std_logic;
	signal done_o   : std_logic;

begin

	UUT : integer_neuron 
		generic map(
			inputs => inputs
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
	clock_process:	process 
    
        begin
        for i in 0 to 50 loop
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        end loop;
        wait;
       --clk <= not clk after half_period;
	   end process;
	reset_process : process
	   begin
	      rst <= '1';
	      wait for 10 ns;
	      rst <='0';
	      wait for 100ns;
	      wait;
	   end process;
    stimuli: process 

        begin
        
        wait for 20 ns;
        input_i <= (0,1,1,0);
        weight_i <= (-1,-1,-1,-1);
        start_i<='1';
        
            wait;
--           start_i <= '0', '1' after 15 ns, '0' after 30 ns;
     end process;         
end architecture tb;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/23/2022 05:09:15 PM
-- Design Name: 
-- Module Name: custom_package - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
package weight_matrix_pkg is 
	constant inputs : natural := 784;
	constant outputs : natural := 100;

    type  weight_array_one_neuron is array(0 to inputs-1) of std_logic;
    type  weight_matrix_one_layer is array(0 to outputs-1) of weight_array_one_neuron;
    end package;
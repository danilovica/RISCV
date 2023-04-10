----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/21/2023 02:08:57 PM
-- Design Name: 
-- Module Name: immediate - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity immediate is
port (instruction_i : in std_logic_vector (31 downto 0);
      immediate_extended_o : out std_logic_vector (31 downto 0));
end immediate;

architecture Behavioral of immediate is

begin

immediate:process(instruction_i)
begin

if(instruction_i(31)='0') then
 immediate_extended_o(31 downto 12) <= (others => '0');
else
 immediate_extended_o(31 downto 12) <= "11111111111111111111";
end if;

if(instruction_i(6 downto 0) = "0100011") then  --sw
 immediate_extended_o(11 downto 0) <= instruction_i(31 downto 25)&instruction_i(11 downto 7);
elsif(instruction_i(6 downto 0) = "0000011") then  --lw
 immediate_extended_o(11 downto 0) <= instruction_i(31 downto 20);
elsif(instruction_i(6 downto 0) = "1100011") then  --branch
 immediate_extended_o(11 downto 0) <= instruction_i(31)&instruction_i(7)&instruction_i(30 downto 25)&instruction_i(11 downto 8); 
elsif(instruction_i(6 downto 0) = "0010011") then --addi
 immediate_extended_o(11 downto 0) <= instruction_i(31 downto 20);
else
 immediate_extended_o(11 downto 0) <= (others => '0'); 
end if;

end process;

end Behavioral;

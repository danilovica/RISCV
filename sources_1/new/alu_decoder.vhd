----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.03.2023 19:46:55
-- Design Name: 
-- Module Name: alu_decoder - Behavioral
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

entity alu_decoder is
  Port ( 
         --******** Controlpath ulazi *********
         alu_2bit_op_i : in std_logic_vector(1 downto 0);
         --******** Polja instrukcije *******
         funct3_i : in std_logic_vector (2 downto 0);
         funct7_i : in std_logic_vector (6 downto 0);
         --******** Datapath izlazi ********
         alu_op_o : out std_logic_vector(4 downto 0));
end alu_decoder;

architecture Behavioral of alu_decoder is

begin

mux: process(alu_2bit_op_i,funct3_i,funct7_i)
begin
if(alu_2bit_op_i = "00") then     --lw,sw
    alu_op_o <= "00010";          --sabiranje
elsif(alu_2bit_op_i = "10") then
    if(funct7_i = "0000000" and funct3_i = "000") then    --add 
        alu_op_o <= "00010";                              --sabiranje
    elsif(funct7_i = "0100000" and funct3_i = "000") then --sub
        alu_op_o <= "00110";                              --oduzimanje
    elsif(funct7_i = "0000000" and funct3_i = "111") then --and
        alu_op_o <= "00000";                              --logicko i
    else                                                 --or
        alu_op_o <= "00001";                             --logicko ili
    end if;
elsif(alu_2bit_op_i = "01") then
    alu_op_o <= "00110";                               --oduzimanje
else
    alu_op_o <= "00010";                               --sabiranje za addi
end if;

end process;
end Behavioral;

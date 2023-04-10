----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.04.2023 12:10:08
-- Design Name: 
-- Module Name: TOP_RISCV - Behavioral
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

entity TOP_RISCV is
  Port ( -- Globalna sinhronizacija
         clk : in std_logic;
         reset : in std_logic;
         -- Interfejs ka memoriji za podatke
         instr_mem_address_o : out std_logic_vector(31 downto 0);
         instr_mem_read_i : in std_logic_vector(31 downto 0);
         -- Interfejs ka memoriji za instrukcije 
         data_mem_address_o : out std_logic_vector(31 downto 0);
         data_mem_read_i : in std_logic_vector(31 downto 0);
         data_mem_write_o : out std_logic_vector(31 downto 0);
         data_mem_we_o : out std_logic_vector(3 downto 0));
end TOP_RISCV;

architecture Behavioral of TOP_RISCV is

signal instruction_s: std_logic_vector(31 downto 0);
signal branch_condition_s: std_logic;
signal mem_to_reg_s: std_logic;
signal alu_op_s: std_logic_vector(4 downto 0);
signal alu_src_b_s: std_logic;
signal pc_next_sel_s: std_logic;
signal rd_we_s: std_logic;
signal alu_forward_a_s: std_logic_vector(1 downto 0);
signal alu_forward_b_s: std_logic_vector(1 downto 0);
signal branch_forward_a_s: std_logic;
signal branch_forward_b_s: std_logic;
signal if_id_flush_s: std_logic;
signal pc_en_s: std_logic;
signal if_id_en_s: std_logic;

begin

data_path: entity work.DATA_PATH
Port map(
         clk => clk,
         reset => reset,
-- interfejs ka memoriji za instrukcije
         instr_mem_address_o => instr_mem_address_o,
         instr_mem_read_i => instr_mem_read_i,
         instruction_o => instruction_s,
-- interfejs ka memoriji za podatke
         data_mem_address_o => data_mem_address_o,
         data_mem_write_o => data_mem_write_o,
         data_mem_read_i => data_mem_read_i,
-- kontrolni signali
         mem_to_reg_i => mem_to_reg_s,
         alu_op_i => alu_op_s,
         alu_src_b_i => alu_src_b_s,
         pc_next_sel_i => pc_next_sel_s,
         rd_we_i => rd_we_s,
         branch_condition_o => branch_condition_s,
-- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
         alu_forward_a_i => alu_forward_a_s,
         alu_forward_b_i => alu_forward_b_s,
         branch_forward_a_i => branch_forward_a_s,
         branch_forward_b_i => branch_forward_b_s,
-- kontrolni signal za resetovanje if/id registra
         if_id_flush_i => if_id_flush_s,
-- kontrolni signali za zaustavljanje protocne obrade
         pc_en_i => pc_en_s,
         if_id_en_i => if_id_en_s);                    

control_path: entity work.CONTROL_PATH
Port map(
         clk => clk,
         reset => reset, 
         -- instrukcija dolazi iz datapah-a
         instruction_i => instruction_s,
         -- Statusni signaln iz datapath celine
         branch_condition_i => branch_condition_s,
         -- kontrolni signali koji se prosledjiuju u datapath
         mem_to_reg_o => mem_to_reg_s,       
         alu_op_o => alu_op_s,     
         alu_src_b_o =>alu_src_b_s,
         rd_we_o => rd_we_s,                            
         pc_next_sel_o => pc_next_sel_s,                         
         data_mem_we_o => data_mem_we_o,
         -- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
         alu_forward_a_o => alu_forward_a_s,
         alu_forward_b_o => alu_forward_b_s,
         branch_forward_a_o => branch_forward_a_s,
         branch_forward_b_o => branch_forward_b_s,
         -- kontrolni signal za resetovanje if/id registra
         if_id_flush_o => if_id_flush_s,
         -- kontrolni signali za zaustavljanje protocne obrade
         pc_en_o => pc_en_s,
         if_id_en_o => if_id_en_s);                        




end Behavioral;

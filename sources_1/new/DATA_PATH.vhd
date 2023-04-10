----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.03.2023 19:03:15
-- Design Name: 
-- Module Name: DATA_PATH - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DATA_PATH is
  Port ( -- sinhronizacioni signali
         clk : in std_logic;
         reset : in std_logic;
-- interfejs ka memoriji za instrukcije
         instr_mem_address_o : out std_logic_vector (31 downto 0); --to je valjda pc_out
         instr_mem_read_i : in std_logic_vector(31 downto 0); --iskoristeno
         instruction_o : out std_logic_vector(31 downto 0); --iskoristeno
-- interfejs ka memoriji za podatke
         data_mem_address_o : out std_logic_vector(31 downto 0);
         data_mem_write_o : out std_logic_vector(31 downto 0);
         data_mem_read_i : in std_logic_vector (31 downto 0);
-- kontrolni signali
         mem_to_reg_i : in std_logic;                         --iskoristeno
         alu_op_i : in std_logic_vector (4 downto 0);         --iskoristen 
         alu_src_b_i : in std_logic;                          --iskoristeno
         pc_next_sel_i : in std_logic;                        --iskoristeno
         rd_we_i : in std_logic;                              --iskoristeno
         branch_condition_o : out std_logic;                  --iskoristeno
-- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
         alu_forward_a_i : in std_logic_vector (1 downto 0); --iskoristeno
         alu_forward_b_i : in std_logic_vector (1 downto 0); --iskoristeno
         branch_forward_a_i : in std_logic;                  --iskoristeno
         branch_forward_b_i : in std_logic;                  --iskoristeno
-- kontrolni signal za resetovanje if/id registra
         if_id_flush_i : in std_logic;                       --iskoristeno
-- kontrolni signali za zaustavljanje protocne obrade
         pc_en_i : in std_logic;                             --iskoristeno
         if_id_en_i : in std_logic);                         --iskoristeno
end DATA_PATH;

architecture Behavioral of DATA_PATH is


signal a: STD_LOGIC_VECTOR(31 DOWNTO 0); 
signal b: STD_LOGIC_VECTOR(31 DOWNTO 0); 

signal res_o: STD_LOGIC_VECTOR(31 DOWNTO 0); 

signal id_ex_reg_o1: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal id_ex_reg_o2: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal id_ex_reg_o3: STD_LOGIC_VECTOR(31 DOWNTO 0); 
signal id_ex_reg_o4: STD_LOGIC_VECTOR(31 DOWNTO 0); 
signal id_ex_reg_o5: STD_LOGIC_VECTOR(4 DOWNTO 0);

signal ex_mem_reg_o1: STD_LOGIC_VECTOR(31 DOWNTO 0);
--signal ex_mem_reg_o2: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal ex_mem_reg_o3: STD_LOGIC_VECTOR(4 DOWNTO 0);

signal m_alu_forward_b: STD_LOGIC_VECTOR(31 DOWNTO 0);
 
signal rs1_data_o: STD_LOGIC_VECTOR(31 DOWNTO 0); 
signal rs2_data_o: STD_LOGIC_VECTOR(31 DOWNTO 0); 
signal rd_data_i: STD_LOGIC_VECTOR(31 DOWNTO 0); 
signal rd_address_i: STD_LOGIC_VECTOR(4 DOWNTO 0); 

signal immediate_extended_o_s: STD_LOGIC_VECTOR(31 DOWNTO 0);

signal comparator1: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal comparator2: STD_LOGIC_VECTOR(31 DOWNTO 0);

signal if_id_reg_o1: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal if_id_reg_o2: STD_LOGIC_VECTOR(31 DOWNTO 0);

signal adder1o: STD_LOGIC_VECTOR(31 DOWNTO 0);

signal adder2o: STD_LOGIC_VECTOR(31 DOWNTO 0);

signal pc_in:STD_LOGIC_VECTOR(31 DOWNTO 0);
signal pc_out:STD_LOGIC_VECTOR(31 DOWNTO 0);

signal mem_wb_reg_o1: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal mem_wb_reg_o2: STD_LOGIC_VECTOR(31 DOWNTO 0);

signal branch_condition_o1: std_logic;
signal branch_condition_o2: std_logic;
signal branch_condition_o3: std_logic;
signal branch_condition_o4: std_logic;
signal branch_condition_o5: std_logic;
signal branch_condition_o6: std_logic;
begin


mux_pc_next_sel:process(adder1o,pc_next_sel_i,adder2o)
begin
if(pc_next_sel_i = '0') then
 pc_in <= adder2o;
else
  pc_in <= adder1o;
end if;
end process;

pc:process(clk)
begin
if(rising_edge(clk)) then
if(reset = '0') then
  pc_out <= (others => '0');
else
 if(pc_en_i = '1') then
   pc_out <= pc_in;
 end if;
end if;
end if;
end process;

instr_mem_address_o <= pc_out; 

--sabirac za racunanje adrese naredne instrukcije
adder2o <= std_logic_vector(unsigned(pc_out) + to_unsigned(4,32)); --provjeri

immediate: entity work.immediate
port map(
         instruction_i => if_id_reg_o1, 
         immediate_extended_o => immediate_extended_o_s);


--sabirac za branch
adder1o <= std_logic_vector(shift_left(unsigned(immediate_extended_o_s),1) + unsigned(if_id_reg_o2)); --vidi ovdje signed ili unsigned

IF_ID_reg: process(clk)
begin
if(rising_edge(clk)) then
 if(reset = '0') then
   if_id_reg_o1 <= (others => '0');
   if_id_reg_o2 <= (others => '0');
   instruction_o <= (others => '0');
 else
  if(if_id_en_i = '1') then
     if(if_id_flush_i = '1') then
       if_id_reg_o1 <= (others => '0');
       if_id_reg_o2 <= (others => '0');
       instruction_o <= (others => '0');
     else
       if_id_reg_o1 <= instr_mem_read_i;  
       if_id_reg_o2 <= pc_out;
       instruction_o <= instr_mem_read_i; 
     end if;     
  end if;
 end if;
end if;
end process;


reg_bank: entity work.register_bank
port map(
         clk => clk,
         reset => reset,
         rs1_address_i => if_id_reg_o1(19 downto 15), 
         rs1_data_o => rs1_data_o,
         rs2_address_i => if_id_reg_o1(24 downto 20), 
         rs2_data_o => rs2_data_o,
         rd_we_i => rd_we_i,
         rd_address_i => rd_address_i, 
         rd_data_i => rd_data_i);


mux_branch_forward_a:process(branch_forward_a_i,rs1_data_o,ex_mem_reg_o1)
begin

if(branch_forward_a_i = '0') then
  comparator1 <= rs1_data_o;
else
  comparator1 <= ex_mem_reg_o1;
end if;
end process;

mux_branch_forward_b:process(branch_forward_b_i,rs2_data_o,ex_mem_reg_o1)
begin

if(branch_forward_b_i = '0') then
  comparator2 <= rs2_data_o;
else
  comparator2 <= ex_mem_reg_o1; 
end if;
end process;

comparator:process(comparator1,comparator2)
begin

if(to_integer(signed(comparator1)) = to_integer(signed(comparator2))) then  --beq
  branch_condition_o1 <= '1';
else
 branch_condition_o1 <= '0'; 
end if;
 
 if(to_integer(signed(comparator1)) /= to_integer(signed(comparator2))) then  --bne
  branch_condition_o2 <= '1';
else
 branch_condition_o2 <= '0'; 
end if;
 
if(to_integer(signed(comparator1)) >= to_integer(signed(comparator2))) then --bgeq
  branch_condition_o3 <= '1';
else
 branch_condition_o3 <= '0'; 
end if;
 
if(to_integer(signed(comparator1)) < to_integer(signed(comparator2))) then --blt
  branch_condition_o4 <= '1';
else
 branch_condition_o4 <= '0'; 
end if;

if(to_integer(unsigned(comparator1)) < to_integer(unsigned(comparator2))) then --bltu
  branch_condition_o5 <= '1';
else
 branch_condition_o5 <= '0'; 
end if;

if(to_integer(unsigned(comparator1)) >= to_integer(unsigned(comparator2))) then  --bgqu
  branch_condition_o6 <= '1';
else
 branch_condition_o6 <= '0'; 
end if;
end process;


mux: process(if_id_reg_o1,branch_condition_o1,branch_condition_o2,branch_condition_o3,
             branch_condition_o4,branch_condition_o5,branch_condition_o6) ---proces koji bira branch
begin
if (if_id_reg_o1(14 downto 12) = "000") then --beq
  branch_condition_o <= branch_condition_o1;
elsif(if_id_reg_o1(14 downto 12) = "001") then  --bnq
  branch_condition_o <= branch_condition_o2;
elsif(if_id_reg_o1(14 downto 12) = "101") then --bge
  branch_condition_o <= branch_condition_o3;
elsif(if_id_reg_o1(14 downto 12) = "100") then  --blt
  branch_condition_o <= branch_condition_o4;
elsif(if_id_reg_o1(14 downto 12) = "110") then  --bltu
  branch_condition_o <= branch_condition_o5;
elsif(if_id_reg_o1(14 downto 12) = "111") then --bgeu
  branch_condition_o <= branch_condition_o6;
end if;
end process; 
 

ID_EX_REG:process(clk)
begin
 if(rising_edge(clk)) then
  if(reset = '0') then 
    id_ex_reg_o1 <= (others=>'0');
    id_ex_reg_o2 <= (others=>'0'); 
    id_ex_reg_o3 <= (others=>'0');
    id_ex_reg_o4 <= (others=>'0'); 
    id_ex_reg_o5 <= (others=>'0');
  else
    id_ex_reg_o1 <= rs1_data_o;
    id_ex_reg_o2 <= rs2_data_o; 
    id_ex_reg_o3 <= immediate_extended_o_s;
    id_ex_reg_o4 <= rs2_data_o; 
    id_ex_reg_o5 <= if_id_reg_o1(11 downto 7); 
  end if;
 end if;
end process;


mux_alu_forward_a: process(alu_forward_a_i,id_ex_reg_o1,rd_data_i,ex_mem_reg_o1)
begin

if(alu_forward_a_i = "00") then
  a <= id_ex_reg_o1;
elsif(alu_forward_a_i = "01") then
  a <= rd_data_i;
elsif(alu_forward_a_i = "10") then
  a <= ex_mem_reg_o1;
end if;
end process;

mux_alu_forward_b: process(alu_forward_b_i,id_ex_reg_o2,rd_data_i,ex_mem_reg_o1)
begin

if(alu_forward_b_i = "00") then
  m_alu_forward_b <= id_ex_reg_o2;
elsif(alu_forward_b_i = "01") then
  m_alu_forward_b <= rd_data_i;
elsif(alu_forward_b_i = "10") then
  m_alu_forward_b <= ex_mem_reg_o1;
end if;
end process;

mux_alu_src_b_i: process(alu_src_b_i,id_ex_reg_o3,m_alu_forward_b)
begin

if(alu_src_b_i = '1') then
b <= id_ex_reg_o3;
else
b <= m_alu_forward_b;
end if;
end process;

alu: entity work.ALU
Port map(
         a_i => a,
         b_i => b,
         op_i => alu_op_i,
         res_o => res_o);
EX_MEM_REG: process(clk)
begin

if (rising_edge(clk)) then
 if(reset = '0') then
   ex_mem_reg_o1 <= (others => '0');
   data_mem_address_o <= (others => '0');
   data_mem_write_o <= (others => '0');
   ex_mem_reg_o3 <=  (others => '0');
 else
   ex_mem_reg_o1 <= res_o;
   data_mem_address_o <= res_o; 
   data_mem_write_o <= id_ex_reg_o4; 
   ex_mem_reg_o3 <=  id_ex_reg_o5;

 end if;
end if;
end process;


MEM_WB_REG:process(clk)
begin

if(rising_edge(clk)) then
  if(reset = '0') then
     mem_wb_reg_o1 <= (others => '0');
     mem_wb_reg_o2 <= (others => '0');
     rd_address_i <= (others => '0');
   else
     mem_wb_reg_o1 <= ex_mem_reg_o1;
     mem_wb_reg_o2 <= data_mem_read_i;
     rd_address_i <= ex_mem_reg_o3;   
  end if;
end if;
end process;

mux_mem_to_reg_i: process( mem_wb_reg_o1, mem_wb_reg_o2,mem_to_reg_i)
begin

if(mem_to_reg_i = '0') then
  rd_data_i <= mem_wb_reg_o1;
else
  rd_data_i <= mem_wb_reg_o2;
end if;
end process;


end Behavioral;

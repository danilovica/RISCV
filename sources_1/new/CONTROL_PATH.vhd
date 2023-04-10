----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.03.2023 20:33:09
-- Design Name: 
-- Module Name: CONTROL_PATH - Behavioral
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

entity CONTROL_PATH is
  Port ( -- sinhronizacija
         clk : in std_logic;
         reset : in std_logic;
         -- instrukcija dolazi iz datapah-a
         instruction_i : in std_logic_vector (31 downto 0);
         -- Statusni signaln iz datapath celine
         branch_condition_i : in std_logic;                       --iskoristeno
         -- kontrolni signali koji se prosledjiuju u datapath
         mem_to_reg_o : out std_logic;                            --iskoristeno        
         alu_op_o : out std_logic_vector(4 downto 0);             --iskoristeno         
         alu_src_b_o : out std_logic;                             --iskoristeno
         rd_we_o : out std_logic;                                 --iskoristeno                                 
         pc_next_sel_o : out std_logic;                           
         data_mem_we_o : out std_logic_vector(3 downto 0);        --iskoristeno
         -- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
         alu_forward_a_o : out std_logic_vector (1 downto 0);     --iskoristeno
         alu_forward_b_o : out std_logic_vector (1 downto 0);     --iskoristeno
         branch_forward_a_o : out std_logic;                      --iskoristeno
         branch_forward_b_o : out std_logic;                      --iskoristeno
         -- kontrolni signal za resetovanje if/id registra
         if_id_flush_o : out std_logic;
         -- kontrolni signali za zaustavljanje protocne obrade
         pc_en_o : out std_logic;                                 --iskoristeno
         if_id_en_o : out std_logic);                             --iskoristeno
end CONTROL_PATH;

architecture Behavioral of CONTROL_PATH is

signal data_mem_we_o_s: std_logic;
signal alu_src_b_o_s: std_logic;
signal rd_we_o_s: std_logic;
signal alu_2op_o_s: std_logic_vector(1 downto 0);
signal rs1_in_use_o: std_logic;
signal rs2_in_use_o: std_logic;
signal branch_o: std_logic;

signal control_pass_o: std_logic;

signal ex1_reg: std_logic;
signal ex2_reg: std_logic;
signal ex3_reg: std_logic;
--signal ex4_reg: std_logic;
signal ex5_reg: std_logic_vector(1 downto 0);
signal ex6_reg: std_logic_vector(6 downto 0);
signal ex7_reg: std_logic_vector(2 downto 0);
signal ex8_reg: std_logic_vector(4 downto 0);
signal ex9_reg: std_logic_vector(4 downto 0);
signal ex10_reg: std_logic_vector(4 downto 0);

signal mem_to_reg_o_s: std_logic;

signal mem1_reg: std_logic;
signal mem2_reg: std_logic;
signal mem3_reg: std_logic;
signal mem4_reg: std_logic_vector(4 downto 0);

signal wb2_reg: std_logic;
signal wb3_reg: std_logic_vector(4 downto 0);

begin

haz_unit: entity work.hazard_unit
Port map(rs1_address_id_i => instruction_i(19 downto 15),
         rs2_address_id_i => instruction_i(24 downto 20), 
         rs1_in_use_i => rs1_in_use_o,
         rs2_in_use_i => rs2_in_use_o,
         branch_id_i => branch_o,
         rd_address_ex_i => ex8_reg,
         mem_to_reg_ex_i => ex1_reg,
         rd_we_ex_i => ex3_reg,
         rd_address_mem_i => mem4_reg,
         mem_to_reg_mem_i => mem1_reg,
         pc_en_o => pc_en_o,
         if_id_en_o => if_id_en_o,
         control_pass_o => control_pass_o);

contro_decoder:entity work.ctrl_decoder
Port map(
        -- opcode instrukcije
        opcode_i => instruction_i(6 downto 0),
        --kontrolni signali
        branch_o => branch_o,          
        mem_to_reg_o => mem_to_reg_o_s,
        data_mem_we_o => data_mem_we_o_s, 
        alu_src_b_o => alu_src_b_o_s,
        rd_we_o => rd_we_o_s,
        rs1_in_use_o =>  rs1_in_use_o, 
        rs2_in_use_o =>  rs2_in_use_o, 
        alu_2bit_op_o => alu_2op_o_s);  
 
 and_gate1: pc_next_sel_o <= branch_o and branch_condition_i;
 and_gate2: if_id_flush_o <= branch_o and branch_condition_i;

 ex_reg: process(clk)
 begin
 if(rising_edge(clk)) then
   if(reset = '0') then 
     ex1_reg <= '0';
     ex2_reg <= '0';
     ex3_reg <= '0';
     alu_src_b_o <= '0';
     ex5_reg <= (others => '0');
     ex6_reg <= (others => '0');
     ex7_reg <= (others => '0');
     ex8_reg <= (others => '0');
     ex9_reg <= (others => '0');
     ex10_reg <= (others => '0');
   else
   if(control_pass_o = '0') then
     ex1_reg <= '0';
     ex2_reg <= '0';
     ex3_reg <= '0';
     alu_src_b_o <= '0';
     ex5_reg <= (others => '0');
     ex6_reg <= (others => '0');
     ex7_reg <= (others => '0');
     ex8_reg <= (others => '0');
     ex9_reg <= (others => '0');
     ex10_reg <= (others => '0');
   else
     ex1_reg <= mem_to_reg_o_s;
     ex2_reg <= data_mem_we_o_s;
     ex3_reg <= rd_we_o_s;
     alu_src_b_o <= alu_src_b_o_s;
     ex5_reg <= alu_2op_o_s;
     ex6_reg <= instruction_i(31 downto 25);
     ex7_reg <= instruction_i(14 downto 12);
     ex8_reg <= instruction_i(11 downto 7);
     ex9_reg <= instruction_i(19 downto 15);
     ex10_reg <= instruction_i(24 downto 20);
   end if;
  end if;
 end if;
 end process;
 

forw_unit: entity work.forwarding_unit
Port map(
         rs1_address_id_i => instruction_i(19 downto 15),
         rs2_address_id_i => instruction_i(24 downto 20),
         -- ulazi iz EX faze
         rs1_address_ex_i => ex9_reg,
         rs2_address_ex_i => ex10_reg,
         -- ulazi iz MEM faze
         rd_we_mem_i => mem3_reg,
         rd_address_mem_i => mem4_reg,
         -- ulazi iz WB faze
         rd_we_wb_i => wb2_reg,
         rd_address_wb_i => wb3_reg,
         -- izlazi za prosledjivanje operanada ALU jedinici
         alu_forward_a_o => alu_forward_a_o,
         alu_forward_b_o => alu_forward_b_o,
         -- izlazi za prosledjivanje operanada komparatoru za odredjivanje uslova skoka
         branch_forward_a_o => branch_forward_a_o,
         branch_forward_b_o => branch_forward_b_o);
         
alu_dec: entity work.alu_decoder
Port map( alu_2bit_op_i => ex5_reg,
         funct3_i => ex7_reg,
         funct7_i => ex6_reg,
         alu_op_o => alu_op_o);
         
mem_reg: process(clk)
 begin
 if(rising_edge(clk)) then
   if(reset = '0') then
     mem1_reg <= '0';
     mem2_reg <= '0';
     mem3_reg <= '0';
     mem4_reg <= (others => '0');
   else
     mem1_reg <= ex1_reg;
     mem2_reg <= ex2_reg;
     mem3_reg <= ex3_reg;
     mem4_reg <= ex8_reg;
   end if;
 end if;
 end process;
 
 mux: process(mem2_reg)
 begin
 if(mem2_reg = '0') then
   data_mem_we_o <= (others => '0');
 elsif(mem2_reg = '1') then
   data_mem_we_o <= "1111";
 end if; 
 end process;
 
 
 wb_reg: process(clk)
 begin
 if(rising_edge(clk)) then
   if(reset = '0') then
     mem_to_reg_o <= '0';
     rd_we_o <= '0';
     wb2_reg <= '0';
     wb3_reg <= (others => '0');
   else
     mem_to_reg_o <= mem1_reg;
     wb2_reg <= mem3_reg;
     rd_we_o <= mem3_reg;
     wb3_reg <= mem4_reg;
   end if;
 end if;
 end process;

end Behavioral;

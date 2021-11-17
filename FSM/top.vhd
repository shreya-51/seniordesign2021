----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/16/2021 05:38:28 PM
-- Design Name: 
-- Module Name: top - Behavioral
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


entity top is
 Port (
 clk    :      in      std_logic;
 data   :      in      std_logic;
 reset  :      in      std_logic;
 done   :      out     std_logic;
 Chan1  :      out     std_logic_Vector(11 downto 0);
 Chan2  :      out     std_logic_Vector(11 downto 0);
 Chan3  :      out     std_logic_Vector(11 downto 0)  );
end top;

architecture Behavioral of top is


component counter_32 is
    port (
        cout   :out std_logic_vector (4 downto 0); 
        enable :in  std_logic;                     
        clk    :in  std_logic;                     
        reset  :in  std_logic                      
     );
 end component;
 
 component counter_62 is
    port (
        cout   :out std_logic_vector (5 downto 0); 
        enable :in  std_logic;                     
        clk    :in  std_logic;                     
        reset  :in  std_logic                      
     );
 end component;
 
component FSm is
	port(
		CLK		 : in	std_logic;
		DATA     : in   std_logic;
		RESET    : in   std_logic;
		COUNTER   : in   std_logic_vector(4 downto 0);
		COUNTERSWE:in  std_logic_vector(5 downto 0);
		enableD   :   out std_logic;
		enableR   :   out std_logic;
		enableS   :  out std_logic;
		resetSWE : out  std_logic;
		rstreg : out  std_logic;
		DONE     : out  std_logic      
	);
end component;

component reg is
  Port (
  clk       :   in      std_logic;
  data      :   in      std_logic;
  enable    :   in      std_logic;
  output    :   out     std_logic_vector(31 downto 0));
end component;

component regFile is
  Port (
    clk         :   in std_logic;
    Channel     :   in  std_logic_vector(2 downto 0);
    dataIn     :     in std_logic_vector(11 downto 0); 
    reset       :   in  std_logic;
    enable      :   in  std_logic;
    dataOut1     :   out std_logic_vector(11 downto 0); 
    dataOut2     :   out std_logic_vector(11 downto 0);
    dataOut3     :   out std_logic_vector(11 downto 0)
  );
end component;

--counter signal 
signal  count_sig: std_logic_vector(4 downto 0);
signal  count_sigSweep: std_logic_vector(5 downto 0);
signal output_data: std_logic_vector(31 downto 0);
signal output_data_SWE: std_logic_vector(31 downto 0);
signal data1_sig, data2_sig, data3_sig: std_logic_vector(11 downto 0);
signal enableD,enableR,resetSWE,enableS,resetReg      : std_logic;
--TODO: map enableS to FSM 
begin

count       : counter_32 PORT MAP (enable => '1', clk => clk, reset => reset, cout => count_sig);
count_swe   : counter_62 PORT MAP (enable => '1', clk => clk, reset => reset, cout => count_sigSweep);
-- add enableS 
fsm_t       : fsm PORT MAP (clk =>clk, data =>data, reset => '0', counter => count_sig, counterSWE => count_sigSweep,done => done, enableD => enableD, enableR => enableR,enableS => enableS,resetSWE=>resetSWE, rstReg => resetReg);
datainput   : reg PORT MAP (clk => clk, data => data,enable => enableD, output => output_data);
swedatainput: reg PORT MAP (clk => clk, data => data,enable => enableS, output => output_data_SWE);
channels    : regFile PORT MAP(clk => clk, Channel => output_data(2 downto 0), dataIn => output_data(16 downto 5), reset => resetReg, enable => enableR, dataOut1 => data1_sig, dataOut2 => data2_sig, dataOut3 => data3_sig) ;

end Behavioral;

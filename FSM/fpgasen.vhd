library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter_32 is
    port (
        cout   :out std_logic_vector (4 downto 0); 
        enable :in  std_logic;                     
        clk    :in  std_logic;                     
        reset  :in  std_logic                      
     );
 end entity;
 
 architecture rtl of counter_32 is
     signal count :std_logic_vector (4 downto 0) := "00000";
 begin
     process (clk, reset) begin
         if (reset = '1') then
             count <= (others=>'0');
        elsif (rising_edge(clk)) then
            if (enable = '1') then
                  count <= count + 1;
             end if;
          end if;
      end process;
     cout <= count;
end architecture;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
--
--simply creating hex display of numbers onto FPGA 
ENTITY bcd7seg IS
 PORT ( B: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
 display: OUT STD_LOGIC_VECTOR(0 TO 6));
END bcd7seg;
--
ARCHITECTURE Behavior OF bcd7seg IS
BEGIN
process(B)
BEGIN
CASE B IS 
	When "0000" => display <= "0000001";
	When "0001" => display <= "1001111";
	When "0010" => display <= "0010010";
	When "0011" => display <= "0000110";
	When "0100" => display <= "1001100";
	When "0101" => display <= "0100100";
	When "0110" => display <= "1100000";
	When "0111" => display <= "0001111";
	When "1000" => display <= "0000000";
	When "1001" => display <= "0001100";
	When "1010" => display <= "0001000";
	When "1011" => display <= "1100000";
	When "1100" => display <= "0110001";
	When "1101" => display <= "1000010";
	When "1110" => display <= "0110000";
	When OTHERS => display <= "0111000"; -- 15
End Case;
End Process;

End Behavior;
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


entity fpgasen is
 Port (
 clk    :      in      std_logic;
 data   :      in      std_logic;
 reset  :      in      std_logic;
 done   :      out     std_logic;
 H	  :		   out	  std_logic_vector(0 to 6);
 H1	  :		out	  std_logic_vector(0 to 6);
 H2	  :		out	  std_logic_vector(0 to 6);
 H3	  :		out	  std_logic_vector(0 to 6);
 H4	  :		out	  std_logic_vector(0 to 6);
 H5	  :		out	  std_logic_vector(0 to 6);
 H6	  :		out	  std_logic_vector(0 to 6);
 Chan1  :      out     std_logic_Vector(11 downto 0);
 Chan2  :      out     std_logic_Vector(11 downto 0);
 Chan3  :      out     std_logic_Vector(11 downto 0);
 LED0		:		out	  std_logic;
 LED1   :		out	  std_logic);
end fpgasen;

architecture Behavioral of fpgasen is

component bcd7seg IS
 PORT ( B: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
 display: OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END component;

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
		enableSWE :   out std_logic;
		resetD    :   out std_logic;
		enableR   :   out std_logic;
		resetSWE : out  std_logic;
		rstReg	: out  std_logic;
		enableF  : out  std_logic;
		DONE     : out  std_logic      
	);
end component;

component reg64 is
  Port (
  clk       :   in      std_logic;
  data      :   in      std_logic;
  enable    :   in      std_logic;
  output    :   out     std_logic_vector(63 downto 0));
end component;

component reg is
  Port (
  clk       :   in      std_logic;
  data      :   in      std_logic;
  enable    :   in      std_logic;
  reset		:	 in		std_logic;
  output    :   out     std_logic_vector(31 downto 0));
end component;

component reg12 is
  Port (
  clk       :   in      std_logic;
  data      :   in      std_logic_vector(11 downto 0);
  enable    :   in      std_logic;
  reset 		:	 in 		std_logic;
  output    :   out     std_logic_vector(11 downto 0));
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

component adder is
    Port ( NUM1 	: in  STD_LOGIC_VECTOR (11 downto 0) := "000000000000";
           NUM2 	: in  STD_LOGIC_VECTOR (11 downto 0) := "000000000000";
			  VOLT1   : in STD_LOGIC_VECTOR (11 downto 0) := "000000000000";
			  enable	: in std_logic;
			  start  : in std_logic;
			  clock  : in  std_logic;
           SUM 	:	 out  STD_LOGIC_VECTOR (11 downto 0));
end component;

component comparator is
    Port ( NUM1 	: in  STD_LOGIC_VECTOR (11 downto 0) := "000000000000";
           NUM2 	: in  STD_LOGIC_VECTOR (11 downto 0) := "000000000000";
			  clock  : in  std_logic;
			  enable	: in  std_logic;
           DONE	: out std_logic);
end component;


--counter signal 
signal  count_sig: std_logic_vector(4 downto 0);
signal  freqsig, stepsig,volt1sig,volt2sig: std_logic_vector(11 downto 0);
signal  count_sigSweep: std_logic_vector(5 downto 0);
signal output_data: std_logic_vector(31 downto 0);
signal outSWE: std_logic_vector(63 downto 0);
signal data1_sig, data2_sig, data3_sig, temp_SWE: std_logic_vector(11 downto 0);
signal enableD,enableR,resetSWE,resetReg,resetD,enableSWE,enableF, doneSWE, enableComp    : std_logic;

begin

count       : counter_32 PORT MAP (enable => '1', clk => clk, reset => reset, cout => count_sig);
count_swe   : counter_62 PORT MAP (enable => '1', clk => clk, reset => reset, cout => count_sigSweep);
fsm_t       : fsm PORT MAP (clk =>clk, data =>data, reset => '0', counter => count_sig, counterSWE => count_sigSweep,done => done, enableD => enableD, enableF => enableF, enableR => enableR,resetSWE=>resetSWE, rstReg => resetReg, resetD => resetD, enableSWE => enableSWE);
datainput   : reg PORT MAP (clk => clk, data => data,enable => enableD, reset => '0' ,output => output_data);
testSWE 		:reg64 PORT MAP(clk => clk, data => data, enable => enableSWE, output => outSWE);
channels    : regFile PORT MAP(clk => clk, Channel => output_data(2 downto 0), dataIn => output_data(14 downto 3), reset => output_data(15), enable => enableR, dataOut1 => data1_sig, dataOut2 => data2_sig, dataOut3 => data3_sig) ;
frequency	: reg12 PORT MAP(clk => clk, data => outSWE(59 downto 48), enable => enableF, reset => '0', output => freqsig);
step			: reg12 PORT MAP(clk => clk, data => outSWE(47 downto 36), enable => enableF, reset => '0', output => stepsig);
volt2			: reg12 PORT MAP(clk => clk, data => outSWE(35 downto 24), enable => enableF, reset => '0', output => volt2sig);
volt1			: reg12 PORT MAP(clk => clk, data => outSWE(23 downto 12), enable => enableF, reset => '0', output => volt1sig);
add   		: adder PORT MAP (NUM1 => stepsig, NUM2 => temp_SWE, VOLT1 => volt1sig, enable => '1', start => '1', clock => clk, sum => temp_SWE);
compare		: comparator PORT MAP( NUM1 => temp_SWE, NUM2 => volt2sig, DONE => doneSWE, clock => clk, enable => enableComp);

--bcd segments 
--bcd0			: bcd7seg PORT MAP (B => output_data(3 downto 0), display => H);
--bcd2:bcd7seg PORT MAP (B => output_data(7 downto 4), display => H1);
--bcd3:bcd7seg PORT MAP (B => output_data(11 downto 8), display => H2);
--bcd4:bcd7seg PORT MAP (B => output_data(15 downto 12), display => H3);
--bcd5:bcd7seg PORT MAP (B => outSWE(19 downto 16), display => H4);
--bcd6:bcd7seg PORT MAP (B => outSWE(23 downto 20), display => H5);
--these are the                         
bcd1	: bcd7seg PORT MAP (B => data1_sig(3 downto 0), display => H);
bcd2:bcd7seg PORT MAP (B => data1_sig(7 downto 4), display => H1);
bcd3:bcd7seg PORT MAP (B => data2_sig(3 downto 0), display => H2);
bcd4:bcd7seg PORT MAP (B => data2_sig(7 downto 4), display => H3);
bcd5:bcd7seg PORT MAP (B => data3_sig(3 downto 0), display => H4);
bcd6:bcd7seg PORT MAP (B => data3_sig(7 downto 4), display => H5);
-- here are the testing sweep register
--bcdt1	: bcd7seg PORT MAP (B => volt1sig(3 downto 0), display => H);
--bcdt2:bcd7seg PORT MAP (B => volt1sig(7 downto 4), display => H1);
--bcdt3:bcd7seg PORT MAP (B => volt1sig(11 downto 8), display => H2);
--bcd4:bcd7seg PORT MAP (B => data2_sig(7 downto 4), display => H3);
--bcd5:bcd7seg PORT MAP (B => data3_sig(3 downto 0), display => H4);
--bcd6:bcd7seg PORT MAP (B => data3_sig(7 downto 4), display => H5);
led0 <= resetReg;
led1 <= enableR;
end Behavioral;

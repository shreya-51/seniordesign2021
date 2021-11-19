library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adder is
    Port ( NUM1 	: in  STD_LOGIC_VECTOR (11 downto 0) := "000000000000";
           NUM2 	: in  STD_LOGIC_VECTOR (11 downto 0) := "000000000000";
			  VOLT1   : in STD_LOGIC_VECTOR (11 downto 0) := "000000000000";
			  enable	: in std_logic;
			  start  : in std_logic;
			  clock  : in  std_logic;
           SUM 	:	 out  STD_LOGIC_VECTOR (11 downto 0));
end adder;

architecture Behavioral of adder is
begin
    process(clock)
	 begin
    if(enable = '1' and rising_edge(clock)) then
		SUM <= NUM1 + NUM2;
	 elsif(enable = '1' and rising_edge(clock) and start = '1') then
		SUM <= NUM1 + VOLT1;
	 end if;
	 end process;	
end Behavioral;

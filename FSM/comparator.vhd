library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity comparator is
    Port ( NUM1 	: in  STD_LOGIC_VECTOR (11 downto 0) := "000000000000";
           NUM2 	: in  STD_LOGIC_VECTOR (11 downto 0) := "000000000000";
			  enable : in std_logic;
			  clock  : in  std_logic;
           DONE	: out std_logic);
end comparator;

architecture Behavioral of comparator is
begin
    process(clock)
	 begin
    if NUM1 >= NUM2 and enable = '1' then
		DONE <= '1';
	elsif enable = '1' then
		DONE <= '0';
end if;
end process;	
end Behavioral;




library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg12 is
  Port (
  clk       :   in      std_logic;
  data      :   in      std_logic_vector(11 downto 0);
  enable    :   in      std_logic;
  reset 		:	 in 		std_logic;
  output    :   out     std_logic_vector(11 downto 0));
end reg12;

architecture Behavioral of reg12 is
 signal out_sig : std_logic_vector(11 downto 0) := (others => '0');
begin
process(clk)
  begin
    if(reset = '1') then
		out_sig <= (others => '0');
	 elsif (rising_edge(clk) and enable = '1') then
      out_sig <= data;
    end if;
  end process;
  output <= out_sig;
end Behavioral;

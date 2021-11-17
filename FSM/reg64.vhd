---------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg64 is
  Port (
  clk       :   in      std_logic;
  data      :   in      std_logic;
  enable    :   in      std_logic;
  output    :   out     std_logic_vector(63 downto 0));
end reg64;

architecture Behavioral of reg64 is
 signal out_sig : std_logic_vector(63 downto 0) := (others => '0');
begin
process(clk)
  begin
    if (rising_edge(clk) and enable = '1') then
      out_sig <=out_sig(62 downto 0) & data;
    end if;
  end process;
  output <= out_sig;
end Behavioral;

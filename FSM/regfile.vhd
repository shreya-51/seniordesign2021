----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/16/2021 06:34:46 PM
-- Design Name: 
-- Module Name: regFile - Behavioral
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
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity regFile is
  Port (
    clk         :   in std_logic;
    Channel     :   in  std_logic_vector(2 downto 0);
    dataIn     :    in std_logic_vector(11 downto 0); 
    reset       :   in  std_logic;
    enable      :   in  std_logic;
    dataOut1     :   out std_logic_vector(11 downto 0); 
    dataOut2     :   out std_logic_vector(11 downto 0);
    dataOut3     :   out std_logic_vector(11 downto 0)
  );
end regFile;

architecture Behavioral of regFile is
  type t_regF is array(0 to 7) of std_logic_vector(11 downto 0);
  signal regFArray : t_regF;
begin
    process(clk) is
    begin
    if (rising_edge(clk)) then
            if(reset = '1') then -- have to check if reset to clear to make it all equal 0
                regFArray <= (others =>(others =>'0')); -- make all registers = 0
               --Check if ELSEIF ENABLE W = 1 you WRITE REGISTER
             elsif(enable = '1') then
                regFArray(to_integer(unsigned(Channel))) <=  dataIn;
            end if;
    end if;
    end process;
    
    dataOut1 <= regFArray(0);
    dataOut2 <= regFArray(1);
    dataOut3 <= regFArray(2);
end Behavioral;

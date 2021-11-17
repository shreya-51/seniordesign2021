library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

    --Testing Logical Unit (Sim 3)
    --Testing the Shift (Inserting his Table) (Sim4)
    --Testing the Comparator (Tested in Sim 2)

entity fsm_tb is
end fsm_tb;


architecture sim of fsm_tb is

--component of ALU
component top is
		port (
        clk    :      in      std_logic;
        data   :      in      std_logic;
        reset  :      in      std_logic; 
        done   :      out     std_logic;
        Chan1  :      out     std_logic_Vector(11 downto 0);
        Chan2  :      out     std_logic_Vector(11 downto 0);
        Chan3  :      out     std_logic_Vector(11 downto 0) 
		);
	end component;

--Here where you add your signals
    signal counter     : std_logic_vector(5 downto 0);
    signal Chan1,Chan2,Chan3     : std_logic_vector(11 downto 0);
	signal clk, data,reset,done: std_logic;

begin

    DUT: top

    port map(
       CLK => CLK,
       DATA => DATA,
       RESET => RESET,
       DONE => DONE,
     
       Chan1 => Chan1,
       Chan2 => Chan2,
       Chan3 => Chan3
    );

    process
    begin

      clk <= '0';
	  wait for 10 ns;
	  clk <= '1';
	  wait for 10 ns;
      clk <= '0';
	  wait for 10 ns;
	  clk <= '1';
	  wait for 10 ns;

    wait;
    end process;

    end architecture;


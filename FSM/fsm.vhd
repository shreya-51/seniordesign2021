-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)

library ieee;
use ieee.std_logic_1164.all;

entity FSm is

	port(
		CLK		  : in	std_logic;
		DATA        : in   std_logic;
		RESET         : in   std_logic;
		COUNTER    : in   std_logic_vector(4 downto 0);
		COUNTERSWE:in  std_logic_vector(5 downto 0);
		enableD  : out  std_logic;
		enableR  : out  std_logic;
		enableS  : out  std_logic;
		enableSWER: out std_logic;
		resetSWE : out  std_logic;
		rstReg : out std_logic;
		DONE     : out  std_logic      
	);

end entity;

architecture rtl of FSm is

	-- Build an enumerated type for the state machine
	type state_type is (s0, s1, s2, s3,s4,s5,s6);

	-- Register to hold the current state
	signal state   : state_type;
	signal resetReg: std_logic := '0';


begin
	-- Logic to advance to the next state
	process (CLK)
	begin
		if RESET = '1' then 
		      state <= s0;
		elsif (rising_edge(clk)) then
			case state is
				when s0=> --reset stage (32nd Clock Cycle) 
					 if(counter = "00000" and DATA = '1')then
					  state <= s4;
					 end if;
					state <= s1;
					resetReg <= '0';
				when s1=> -- 1st to 31st clock cycle // read in the data 
					 if(counter = "11101") then -- 31st clock cycle stop and add done signal 
					   state <= s2;
					 elsif(counter = "00001" and DATA = '1')then
					  state <= s4;
					 elsif(counter = "11010" and DATA = '1')then
					  resetReg <= '1';
					 end if;
				when s2=> -- loading up data 
					   state <= s3;
			    when s3 => 
			         resetReg <= '0';
			         state <= s1;
			    when s4 => -- here getting data for the SWEEP FUNCTION!!! 111110
			          if(counterSWE = "111101") then -- 63rd clock cycle stop and add done signal 
			             state <= s5;
			          end if;
			   when s5 => -- here getting data for the SWEEP FUNCTION!!! 111110
			         state <= s6;
			   when s6 =>
			         state <= s1;
			     when others => 
                    state <= s0;
			end case;
		end if;
	end process;

	-- Output depends solely on the current state
	process (state)
	begin

		case state is
			when s0 =>
			   DONE <= '0';
			   enableD <= '1';
			   enableS <= '1';
			   enableR <= '0';
			   enableSWER <= '0';
			   Rstreg <= resetReg;
			when s1 =>      
			   DONE <= '0';
			   enableD <= '1';
			   enableS <= '1';
			   enableR <= '0';
			   resetSWE <= '0';
			   enableSWER <= '0';
			   Rstreg <= resetReg;
			when s2 =>
                DONE <= '0';
                enableD <= '1';
                enableR <= '1';
                Rstreg <= resetReg;
            when s3 =>
                DONE <= '1';
                enableR <= '0';
                resetSWE <= '1';
                Rstreg <= resetReg;
            when s4 =>
                DONE <= '1';
                enableR <= '0';
                resetSWE <= '0';
                enableS <= '1';
                Rstreg <= resetReg;
                enableSWER <= '1';
             when s5 =>
              enableSWER <= '0';
             when s6 =>
              enableSWER <= '0';
            when others =>
                DONE <= '0';
		end case;
	end process;

end rtl;

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
		resetSWE : out  std_logic;
		DONE     : out  std_logic      
	);

end entity;

architecture rtl of FSm is

	-- Build an enumerated type for the state machine
	type state_type is (s0, s1, s2, s3,s4);

	-- Register to hold the current state
	signal state   : state_type;


begin
	-- Logic to advance to the next state
	process (CLK)
	begin
		if RESET = '1' then 
		      state <= s0;
		elsif (rising_edge(clk)) then
			case state is
				when s0=> --reset stage (32nd Clock Cycle) 
					state <= s1;
				when s1=> -- 1st to 31st clock cycle // read in the data 
					 if(counter = "11101") then -- 31st clock cycle stop and add done signal 
					   state <= s2;
					 elsif(counter = "00001" and DATA = '1')then
					  state <= s4;
					 end if;
				when s2=> -- loading up data 
					   state <= s3;
			    when s3 => 
			         state <= s1;
			    when s4 => -- here getting data for the SWEEP FUNCTION!!! 
			          if(counterSWE = "111110") then -- 31st clock cycle stop and add done signal 
			             state <= s1;
			          end if;
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
			   enableR <= '0';
			when s1 =>      
			   DONE <= '0';
			   enableD <= '1';
			   enableR <= '0';
			   resetSWE <= '0';
			when s2 =>
                DONE <= '0';
                enableD <= '1';
                enableR <= '1';
            when s3 =>
                DONE <= '1';
                enableR <= '0';
                resetSWE <= '1';
            when s4 =>
                DONE <= '1';
                enableR <= '0';
                resetSWE <= '0';
            when others =>
                DONE <= '0';
		end case;
	end process;

end rtl;

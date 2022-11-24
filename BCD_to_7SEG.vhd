library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Author: Steve Weddell
-- Date: June 25, 2004
-- Purpose: VHDL Module for BCD to 7-segment Decoder
-- Usage: Laboratory 1; Example VHDL file for ENEL353


entity BCD_to_7SEG is
		   Port ( bcd_in: in std_logic_vector (3 downto 0);	-- Input BCD vector
		          zero_Error: in std_logic;
    			leds_out: out	std_logic_vector (1 to 7));		-- Output 7-Seg vector 
end BCD_to_7SEG;

architecture Behavioral of BCD_to_7SEG is

begin
	my_seg_proc: process (bcd_in, zero_Error)		-- Enter this process whenever BCD input changes state
		begin
		
		  if (zero_Error = '0') then
			case bcd_in is					 -- abcdefg segments
				when "0000"	=> leds_out <= "0000001";	  -- if BCD is "0000" write a zero to display
				when "0001"	=> leds_out <= "1001111";	  -- etc...
				when "0010"	=> leds_out <= "0010010";
				when "0011"	=> leds_out <= "0000110";
				when "0100"	=> leds_out <= "1001100";
				when "0101"	=> leds_out <= "0100100";
				when "0110"	=> leds_out <= "1100000";
				when "0111"	=> leds_out <= "0001111";
				when "1000"	=> leds_out <= "0000000";
				when "1001"	=> leds_out <= "0001100";
                when "1110"	=> leds_out <= "1111110";  --- negative sign
				when others => leds_out <= "1111111";
			end case;
			
			else 
			     case bcd_in is
			         when "0000" => leds_out <= "0110000";   -- E
			         when "0001" => leds_out <= "1111010";   -- r
			 		 when "0010" => leds_out <= "1100010";   -- o
--			 		 when "0000" => leds_out <= "0110000";
			 		 when others => leds_out <= "1111111";
			     end case;
			end if;

	end process my_seg_proc;

end Behavioral;

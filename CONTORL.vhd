----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 2022/04/22
-- Design Name:
-- Module Name: CONTORL - Behavioral
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
use IEEE.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CONTORL is
  Port (
        Flash_Timer: in std_logic;
        IN_BCD : in std_logic_vector( 27 downto 0);
        is_Neg: in std_logic ;
        zero_Error: in std_logic;                        --- zero erro signal
        NUM_value : out std_logic_vector(3 downto 0);
        -- connect with BCD_to_7SEG, tell 7_seg display infor
        ENABLE_value: out std_logic_vector(7 downto 0) );
        -- Cycle the 7-Segs in sequence
end CONTORL;

architecture Behavioral of CONTORL is
signal  sel: std_logic_vector(3 downto 0);
signal BCD:  std_logic_vector( 27 downto 0);

begin

choose_bcd: process (zero_Error, IN_BCD)
  begin
    if (zero_Error = '1') then
      BCD <= "1111111100000001000100100001";
-- display "Error" on 7 LED

    else
      BCD <= IN_BCD;
    end if;
end process;

Cycle_7_Segs: process (Flash_Timer,sel)
    begin
        if sel ="1000" then
            sel <= (others => '0');
        elsif rising_edge(Flash_Timer ) then
            sel <= sel +'1';
        end if;
    end process;

Represent_value: process (BCD, sel,is_Neg )
    begin

        case sel is
            when "0000" => NUM_value <= BCD(3 downto 0);
                        ENABLE_value<= "11111110";
            when "0001" => NUM_value <= BCD(7 downto 4);
                        ENABLE_value<= "11111101";
            when "0010" => NUM_value <= BCD(11 downto 8);
                        ENABLE_value<= "11111011";
            when "0011" => NUM_value <= BCD(15 downto 12);
                        ENABLE_value<= "11110111";
            when "0100" => NUM_value <= BCD(19 downto 16);
                        ENABLE_value<= "11101111";
            when "0101" => NUM_value <= BCD(23 downto 20);
                        ENABLE_value<= "11011111";
            when "0110" => NUM_value <= BCD(27 downto 24);
                        ENABLE_value<= "10111111";

            when "0111" =>
-- sign bit,
                if (is_Neg = '1') then
                    NUM_value <= "1110";
                else
                    NUM_value <= "1111";         -- turn off/ display null
                 end if;
                        ENABLE_value <= "01111111";

            when others => NUM_value <= "1111";  -- turn off/ display null
                         ENABLE_value <= "01111111";
        end case;

    end process ;

end Behavioral;

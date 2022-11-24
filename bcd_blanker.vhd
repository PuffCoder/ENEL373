--! @brief Blanks out leading zeros  
--! @details Combinatorial logic to replace leading zeros with "1111".  
--! See [DigiKey article](https://forum.digikey.com/t/7-segment-display-driver-for-multiple-digits-vhdl/12526) for more details.

library IEEE;
use IEEE.std_logic_1164.all;

entity bcd_blanker is
    generic (
        BCD_SIZE : integer := 28; --! Size of BCD input
        NUM_SEGS : integer := 8;  --! Number of seven-segment displays
        SEG_SIZE : integer := 4   --! Vector size for each segment
    );
    port (
        bcd_input : in std_logic_vector(BCD_SIZE - 1 downto 0); --! Input BCD number
        bcd_blank : out std_logic_vector(BCD_SIZE - 1 downto 0) --! Blanked BCD number
    );
end bcd_blanker;

architecture behavioural of bcd_blanker is
    -- OR all bits in input vector
    function or_reduce (input : std_logic_vector) return std_logic is
        variable result : std_logic;
    begin
        result := '0';
        for i in input'range loop
            result := result or input(i);
        end loop;
        return result;
    end function;

    --! Blanking vector
    constant OFF  : std_logic_vector(SEG_SIZE - 1 downto 0) := "1111"; 
    
    --! Enable segments
    signal enable : std_logic_vector(NUM_SEGS downto 0);
begin
    -- Always display first digit
    bcd_blank(SEG_SIZE - 1 downto 0) <= bcd_input(SEG_SIZE - 1 downto 0);

    -- Blank out leading zeros
    enable(NUM_SEGS) <= '0';
    blanker : for i in NUM_SEGS - 1 downto 1 generate
        -- Check if segment is zero or already enabled
        enable(i) <= enable(i + 1) or or_reduce(bcd_input(i * SEG_SIZE + 3 downto i * SEG_SIZE));

        -- Turn off segment if not enabled
        with enable(i) select bcd_blank(i * SEG_SIZE + 3 downto i * SEG_SIZE) <=
            bcd_input(i * SEG_SIZE + 3 downto i * SEG_SIZE) when '1',
            OFF when others;
    end generate;
end behavioural;

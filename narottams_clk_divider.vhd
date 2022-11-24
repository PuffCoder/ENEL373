library IEEE;
use IEEE.std_logic_1164.all;

entity clk_divider is
    generic (
        FREQ_IN  : integer := 100000000; -- Input clock frequency (100 MHz)
        FREQ_OUT : integer := 2);        -- Desired output frequency in Hz
    port (
        clk_in  : in std_logic;
        clk_out : out std_logic);
end clk_divider;

architecture Behavioral of clk_divider is
    -- Maximum counter value is determined by the ratio of the input and output frequencies
    constant RATIO : integer := FREQ_IN / FREQ_OUT;
begin
    process (clk_in)
        variable count : integer range 0 to (RATIO - 1) := 0;
    begin
        if rising_edge(clk_in) then
            if count = (RATIO - 1) then
                -- Reached end of period, reset counter and clock output
                count := 0;
                clk_out <= '0';
            else
                if count = (RATIO / 2 - 1) then
                    -- Reached halfway through period, assert clock output
                    clk_out <= '1';
                end if;

                -- Increment counter
                count := count + 1;
            end if;
        end if;
    end process;
end Behavioral;
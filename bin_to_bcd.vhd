--! @brief Binary to binary-coded decimal (BCD) converter  
--! @details Double dabble algorithm for converting binary to BCD.  
--! Implementation inspired by [this Wikipedia article](https://wikipedia.org/w/index.php?title=Double_dabble&oldid=997863872#VHDL_implementation).  
--! A combinatorial blanker is also used to remove leading zeros.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bin_to_bcd is
    generic (
        BCD_SIZE : integer := 28; --! Length of BCD signal
        NUM_SIZE : integer := 24; --! Length of binary input
        NUM_SEGS : integer := 7;  --! Number of segments
        SEG_SIZE : integer := 4   --! Vector size for each segment
    );
    port (
        reset : in std_logic;                                --! Asynchronous reset
        clock : in std_logic;                                --! System clock
        start : in std_logic;                                --! Assert to start conversion
        bin   : in std_logic_vector(NUM_SIZE - 1 downto 0);  --! Binary input
        bcd   : out std_logic_vector(BCD_SIZE - 1 downto 0); --! Binary coded decimal output
        ready : out std_logic                                --! Asserted once conversion is finished
    );
end bin_to_bcd;

architecture behavioural of bin_to_bcd is
    constant bits   : integer := NUM_SIZE; --! Number of input bits
    constant digits : integer := NUM_SEGS; --! Number decimal digits
    
    type state_t is (IDLE, CONVERT, DONE); --! Main state machine
    signal state : state_t := IDLE;        --! Current state
    
    --! BCD input buffer for blanker
    signal bcd_buf : std_logic_vector(BCD_SIZE - 1 downto 0);
begin
    -- Instantiate BCD blanker (removes leading zeros)
    blanker : entity work.bcd_blanker
        generic map (
            BCD_SIZE => BCD_SIZE,
            NUM_SEGS => NUM_SEGS,
            SEG_SIZE => SEG_SIZE)
        port map (
            bcd_input => bcd_buf,
            bcd_blank => bcd);
    
    process (clock, reset)
        variable bin_reg : std_logic_vector (bits - 1 downto 0);
        variable bcd_reg : unsigned (digits * SEG_SIZE - 1 downto 0);
        variable count   : integer;
    begin
        -- Asynchronous reset
        if reset = '1' then
            bin_reg := (others => '0');
            bcd_reg := (others => '0');
            count   := 0;
            
            bcd_buf <= (others => '1');
            ready   <= '0';
            state   <= IDLE;
        elsif rising_edge(clock) then
            -- Main state machine
            case state is
                -- Wait until start is asserted
                when IDLE =>
                    if start = '1' then
                        state   <= CONVERT;
                        ready   <= '0';
                        bcd_buf <= (others => '1');

                        -- Initialise variables
                        bin_reg := bin;
                        bcd_reg := (others => '0');
                        count   := 0;
                    end if;
                
                -- Perform double dabble algorithm
                when CONVERT =>
                    if count < bits then
                        -- Loop through all BCD digits
                        for i in 0 to digits - 1 loop
                            -- Add 3 to a place values (digits) if they are greater than 4
                            if bcd_reg(i * 4 + 3 downto i * 4) > 4 then
                                bcd_reg(i * 4 + 3 downto i * 4) := bcd_reg(i * 4 + 3 downto i * 4) + 3;
                            end if;
                        end loop;

                        -- Shift registers right
                        bcd_reg := bcd_reg(digits * 4 - 2 downto 0) & bin_reg(bits - 1);
                        bin_reg := bin_reg(bits - 2 downto 0) & '0';

                        count := count + 1;
                    else
                        state <= DONE;
                    end if;
                
                -- Conversion complete
                when DONE =>
                    state <= IDLE;
                    ready <= '1';
                    
                    -- Assign BCD to buffer
                    bcd_buf <= std_logic_vector(bcd_reg);
            end case;
        end if;
    end process;
end behavioural;

----------------------------------------------------------------------------------
-- Company: Unversity of Canterbury
-- Engineer: Heng Yin
--
-- Create Date: 2022/03/15 16:53:09
-- Design Name:
-- Module Name: main - Behavioral
-- Project Name: Calculator Milestone 1
-- Target Devices: NEXYS 4 DDR
-- Tool Versions:
-- Description:
--      display 3 decimal number on the 7 seg led controlled  by 12 SW.
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
  Port (SW : in std_logic_vector(15 downto 0);              -- input 12
        LED: out std_logic_vector(15 downto 0);
        CLED: out std_logic_vector(0 to 6);                -- output 7-seg led
        AN : out std_logic_vector( 7 downto 0);             -- control the which 7-seg led light up or turn it off.
        CLK100MHZ: in std_logic;                             -- it is internal clock signal
        BTNC: in std_logic;                                  -- save value button.
        BTNL: in std_logic;
        BTNR: in std_logic;
        BTNU: in std_logic;
        BTND: in std_logic
        );


end main;

architecture Behavioral of main is

signal Total: std_logic_vector(23 downto 0);

signal Display_Sig: std_logic;
signal flash_Sig: std_logic;                                                        -- the 7 seg led flash frequency
signal DIS_BCD: std_logic_vector(3 downto 0);                                       -- the display bcd number it will be looped from number of ONE , TEN and  HUNDER

signal RESULT : std_logic_vector(27 downto 0);
signal Opcode: std_logic_vector(4 downto 0);
signal over_FF: std_logic;
signal is_Neg: std_logic ;
signal zero_Error: std_logic ;

-- Finite State Machine 
component FSM_OP
Port (
    Left_Button : in STD_LOGIC;
    Right_Button : in STD_LOGIC;
    Up_Button : in STD_LOGIC;
    Down_Button : in STD_LOGIC;
    Middle_Button : in STD_LOGIC;
    B_Pressed : in STD_LOGIC;
    Reset : in STD_LOGIC;
    Clk : in STD_LOGIC;
    MathReady : in STD_LOGIC;
    con : in std_logic;
    Opcode : out STD_LOGIC_VECTOR (4 downto 0)

);
end component;

-- transfer binary number to BCD code
component bin_to_bcd
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
end component ;

-- calculation component
component ALU_Cal
generic  (N: integer := 12;
            res_size: integer  := 24);
            port (
    SW :in std_logic_vector( N - 1 downto 0);                    --input
    OP_code: in std_logic_vector (4 downto 0);                   -- op code
    res: out std_logic_vector (res_size -1 downto 0);            -- after calculation result
    LED: out std_logic_vector(15 downto 0);                   -- display last input on LED
    is_Neg: out std_logic;                                    -- display '-' sign on screen
    zero_Error: out std_logic;                                -- display "Error" on screen
    reset: in std_logic ;                                     -- reset button
    clk: in std_logic);

end component ;


begin
CLOCK_DIVIDER:                                                                       -- generate the flash frequency
entity work.clk_divider
    generic map ( FREQ_OUT => 10000)
    port map(
    clk_in => CLK100MHZ ,
    clk_out => Display_Sig);

Flash :                                                                       -- generate the flash frequency
entity work.clk_divider
    generic map ( FREQ_OUT => 100)
    port map(
    clk_in => CLK100MHZ ,
    clk_out => flash_Sig);

FSM_code: FSM_OP port map (BTNL,BTNR,BTNU,BTND,BTNC,SW(15),SW(14), flash_Sig,SW(13),SW(12),Opcode);
--                                              B_pressed, RESET, clk,    mathready, coninut, OPcode

ALU_Op: ALU_Cal generic map ( N => 12, res_size => 24) port map( SW(11 downto 0), Opcode, Total, LED, is_Neg, zero_Error, SW(14), flash_Sig);

bin_BCD: bin_to_bcd generic map (BCD_SIZE => 28, NUM_SIZE => 24, NUM_SEGS => 7,SEG_SIZE => 4)
    port map(BTNU,Display_Sig ,flash_Sig ,Total, RESULT, over_FF);

CONTROL_UNIT:                                                                           -- LOOPING  only light up one position others off.
entity work.CONTORL port map(
    Flash_Timer => Display_Sig,
    IN_BCD => RESULT,
    is_Neg =>is_Neg,
    zero_Error => zero_Error,
    NUM_value => DIS_BCD,
    ENABLE_value => AN);

Show_BCD:                                                                                     -- display bcd number on decimal LED
 entity work.BCD_to_7SEG port map(
    bcd_in => DIS_BCD,
    zero_Error => zero_Error,
    leds_out => CLED);

end Behavioral;

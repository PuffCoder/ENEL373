----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/05/20 13:20:26
-- Design Name: 
-- Module Name: ALU_OP_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;
use IEEE.NUMERIC_STD.ALL;

entity ALU_OP_tb is
--  Port ( );
end ALU_OP_tb;

architecture Behavioral of ALU_OP_tb is

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

signal test_SW: std_logic_vector(11 downto 0);
signal test_OP_code: std_logic_vector ( 4 downto 0);
signal test_res, EXPECTED_res: std_logic_vector( 23 downto 0);
signal test_LED: std_logic_vector(15 downto 0);
signal test_is_Neg, test_zero_Error, test_reset, test_clk: std_logic;
signal EXPECT_is_Neg: std_logic;

-------------------- check result match -------------------
signal  ERROR_is_Neg: std_logic;
signal ERROR_res: std_logic_vector( 23 downto 0);

constant period : time := 10 ms;

begin
    UUT: ALU_Cal generic map ( N =>12, res_size => 24) 
    port map(test_SW, test_OP_code, test_res,test_LED, test_is_Neg, test_zero_Error, test_reset,test_clk);
    
M_clk: process 
    begin 
        test_clk <= '1';
        wait for period/2;
        test_clk <= '0';
        wait for period/2;
     end process ;
    
M_RESET: process 
     begin
        test_reset <= '1';
        wait for 4.3 * period;
        test_reset <= '0';
        wait;
     end process;
     
--Input_SW_P_M_M: process [+,-,*]
--    begin 
--      test_SW <= "000000001000";  -- 8
--          wait for 13 * period;
--      test_SW <= "000100010001";    -- 273 
--          wait;
--  end process;
  
Input_SW_D: process --[/]
    begin 
--      test_SW <= "000100010001";    -- 273 
--          wait for 13 * period;
      test_SW <= "000000001000";    -- 8
--      test_SW <= "000000000000";    -- 0
          wait;
  end process;
        
-----------------------------------------  + ------------------------------------
--     OP_add: process 
--        begin 
--        test_OP_code <= "00000";
--            wait for 1 * period;
----        while test_reset = '0' loop 
--            test_OP_code <= "00000";
--            wait for 8 * period;      -- REG 1
            
--               test_OP_code <= "01000";
--            wait for 8 * period;      -- REG 2
            
--                test_OP_code <= "10000";    -- result
--            wait for 2 * period;
--            wait;
----         end loop;
    
-- end process;
                
                
 -----------------------------------------  -  ------------------------------------
-- OP_min: process 
--        begin 
--        test_OP_code <= "00001";
--            wait for 1 * period;
----        while test_reset = '0' loop 
--            test_OP_code <= "00001";
--            wait for 12 * period;      -- REG 1
            
--               test_OP_code <= "01001";
--            wait for 12 * period;      -- REG 2
            
--                test_OP_code <= "10001";    -- result
--            wait for 2 * period;
--            wait;
----         end loop;
    
--         end process;
 
 
 -----------------------------------------  x  ------------------------------------
-- OP_mul: process 
--        begin 
--        test_OP_code <= "00010";
--            wait for 1 * period;
----        while test_reset = '0' loop 
--            test_OP_code <= "00010";
--            wait for 12 * period;      -- REG 1
            
--               test_OP_code <= "01010";
--            wait for 12 * period;      -- REG 2
            
--                test_OP_code <= "10010";    -- result
--            wait for 2 * period;
--            wait;
----         end loop;
    
--         end process;
     
-- -----------------------------------------  [/]  ------------------------------------
-- OP_div: process 
--        begin 
--        test_OP_code <= "00011";
--            wait for 1 * period;
----        while test_reset = '0' loop 
--            test_OP_code <= "00011";
--            wait for 12 * period;      -- REG 1
            
--               test_OP_code <= "01011";
--            wait for 12 * period;      -- REG 2
        
--                test_OP_code <= "10011";    -- result
----            wait for 2 * period;
--            wait;
--    end process;

 -----------------------------------------  [/]  ------------------------------------
 OP_div: process 
        begin 
        test_OP_code <= "00100";
            wait for 1 * period;
--        while test_reset = '0' loop 
            test_OP_code <= "00100";
            wait for 12 * period;      -- REG 1
            
               test_OP_code <= "01100";
            wait for 12 * period;      -- REG 2
        
                test_OP_code <= "10100";    -- result
--            wait for 2 * period;
            wait;
    end process;
    
         
STIMULUS:process 
     begin 
------------------------------for test [+] ----------------
--        EXPECTED_res<= "000000000000000100011001";  -- result for     281  [+] 

------------------------------for test [-] ----------------
--        EXPECTED_res <= "000000000000000100001001";  -- result for  265   [-]
--        EXPECT_is_Neg <= '1';     -- [-]

------------------------------for test [x] ----------------
--        EXPECTED_res <= "000000000000100010001000";  -- result for   8 * 273 = 2184   [x]


--------------------------------for test [/] ----------------
--        EXPECTED_res <= "000000000000000000100010";  -- result for    273 / 8 =  34   [/]
----          EXPECTED_zero <= '1';

------------------------------for test [^2] ----------------
        EXPECTED_res <= "000000000000000001000000";  -- result for    64 [^2]
--          EXPECTED_zero <= '1';
    wait;        
end process ;
        
sim: process
    begin 
        wait for 26 * period;        -- waiting for the operation to complete
            ERROR_res <= test_res xor EXPECTED_res;    
            wait;
--            ERROR_is_Neg <= EXPECT_is_Neg xor test_is_Neg;   -- [-]
    end process;
    
end Behavioral;

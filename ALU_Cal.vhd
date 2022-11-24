----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 10.05.2022 14:18:19
-- Design Name:
-- Module Name: TIMES - Behavioral
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
--use IEEE.std_logic_arith.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;



-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU_Cal is
 generic  (N: integer := 12;
            res_size: integer := 24);

  Port (
          SW: in std_logic_vector( N - 1 downto 0);                    --input
          OP_code: in std_logic_vector (4 downto 0);                   -- op code
          res: out std_logic_vector (res_size -1 downto 0);            -- after calculation result
          LED: out std_logic_vector(15 downto 0);                   -- display last input on LED
          is_Neg: out std_logic;                                    -- display '-' sign on screen
          zero_Error: out std_logic;                                -- display "Error" on screen
          reset: in std_logic ;                                     -- reset button
          clk: in std_logic);                                       -- clk signal => save data speed

end ALU_Cal;

architecture Behavioral of ALU_Cal is

signal Int_num1 : integer;                -- convert binary to integer [num1]
signal Int_num2 : integer;                -- convert binary to integer [num2]
signal enable_1: std_logic;
signal enable_2: std_logic;
signal Int_res : integer;

signal TEMP : integer;                    -- tempory save data
signal operation: std_logic_vector( 2 downto 0);   -- operation code [+,-,*,/,^2]
signal state: std_logic_vector(1 downto 0);        -- state [input num1, input num2, result]

signal REG_1: std_logic_vector(11 downto 0);       -- save the num1 binary form;
signal REG_2: std_logic_vector(11 downto 0);       -- save the num2 binary form;
signal Output_REG: std_logic_vector( 11 downto 0);  -- represent last input num to LEDs

signal led_state: std_logic_vector(3 downto 0);    -- use LED to represent current State

-- REGESTER
 component my_n_reg
        generic (
            N: in integer := 12);
        port (

        reset: in std_logic ;
        Din : in std_logic_vector ( N -1 downto  0);
        Enable : in std_logic;
        clk: in std_logic;
        Qout: out std_logic_vector ( N -1 downto 0)
        );
end component ;

begin

operation <= OP_code(2 downto 0);                    -- From the FSM get operation code & apply it
state <= OP_code (4 downto 3);                       -- From the FSM get current state
LED(15 downto 12) <= led_state;                      -- represent current state by LEDs

 REG1: my_n_reg generic map (N => 12) port map (reset, SW(11 downto 0), enable_1, clk, REG_1);
 REG2: my_n_reg generic map (N => 12) port map (reset, SW(11 downto 0), enable_2, clk, REG_2);


sel_Operation: process(operation, state,REG_1,REG_2,Int_num1,Int_num2,Int_res,TEMP,Output_REG )
     begin

     if (state = "00" ) then                                                -- Input num1 state:
            zero_Error <= '0';
            enable_1 <= '1';                                                -- save the num1 [SW(11 downto 0)] to REG1;
            enable_2 <= '0';
            led_state <= "1000";                                             -- tell user now state 1
            Int_num1 <= to_integer(signed(REG_1));                          -- transfer num1 to integer;
            Int_num2 <= to_integer(signed(REG_2));                          -- transfer num2 to integer;
            Output_REG <= "000000000000";
            Int_res <= 0; 

            if (Int_num1 < 0) then                                        -- if input negative num1, keep it's magnitude.
                TEMP <= Int_num1 * (-1);
                is_Neg <= '1';
            else
                TEMP <= Int_num1; 
                is_Neg <= '0';
            end if;

      elsif (state = "01") then                                                 -- Input num2 state:
            zero_Error <= '0';
            enable_1 <= '0';                                                    -- num1 could not be changed;
            enable_2 <= '1';                                                    -- save the num2 [SW(11 downto 0)] to REG2 ;
            led_state <= "0100";         -- now input second number
            Output_REG <= REG_1;                                                -- LED display REG1 (last input)
            LED(11 downto 0) <= Output_REG;
            
            Int_num1 <= to_integer(signed(REG_1));                          -- transfer num1 to integer;
            Int_num2 <= to_integer(signed(REG_2));                          -- transfer num2 to integer;
            Int_res <= 0; 

            if (Int_num2 < 0) then
                TEMP <= Int_num2 * (-1);
                is_Neg <= '1';
            else
                 TEMP <= Int_num2 ;
                is_Neg <= '0';
            end if;

       else             
            enable_1 <= '0';                                                                     
            enable_2 <= '0';
            led_state <= "0010";
            Int_num1 <= to_integer(signed(REG_1));                          -- transfer num1 to integer;
            Int_num2 <= to_integer(signed(REG_2));                          -- transfer num2 to integer;
            case operation is
                when "000" => Int_res <= Int_num1 + Int_num2;                   -- [+]: display REG2 to LED
                                Output_REG <= REG_2;
                                zero_Error <= '0';
                when "001" => Int_res <= Int_num1 - Int_num2;                   -- [-]:
                                Output_REG <= REG_2;
                                zero_Error <= '0';
                when "010" => Int_res <= Int_num1 * Int_num2;                   -- [*]:
                                Output_REG <= REG_2;
                                zero_Error <= '0';
                when "011" => Int_res <= Int_num1 / Int_num2;                   -- [/]:
                                Output_REG <= REG_2;
                           if (Int_num2 = 0) then                               -- if divide 0 => 7_seg display "Error"
                                zero_Error <= '1';
                           else
                                zero_Error <= '0';
                           end if;
                when "100" =>                                                   -- [^2]: display REG1 to LED
                      Int_res <= Int_num1 * Int_num1;
                                Output_REG <= REG_1;
                                zero_Error <= '0';

                when others => Int_res <= 0;                                    -- other operations LED display zero!
                                Output_REG <= "000000000000";
                                zero_Error <= '0';
           
            end case;

            if (Int_res < 0) then                                               -- display result & with sign correctly
                TEMP <= Int_res * (-1);
                is_Neg <= '1';
             else
                TEMP <= Int_res ;
                is_Neg <= '0';
             end if;
    end if;
    res <= std_logic_vector(to_signed(TEMP, res_size));
    LED(11 downto 0) <= Output_REG;                                        -- LED display (last input)
end process ;

end Behavioral;

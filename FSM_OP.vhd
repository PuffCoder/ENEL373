----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 2022/04/22
-- Design Name:
-- Module Name: FSM_OP - Behavioral
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


entity FSM_OP is
Port (
    Left_Button : in STD_LOGIC;
    Right_Button : in STD_LOGIC;
    Up_Button : in STD_LOGIC;
    Down_Button : in STD_LOGIC;
    Middle_Button : in STD_LOGIC;
    B_Pressed : in STD_LOGIC;     -- enable input operation SW[15]
    Reset : in STD_LOGIC;         -- SW[12]
    Clk : in STD_LOGIC;
    MathReady : in STD_LOGIC;   -- SW[14]
    con : in std_logic;         -- SW[13]
    Opcode : out STD_LOGIC_VECTOR (4 downto 0)

);





end FSM_OP;

architecture Behavioral of FSM_OP is
  type State is (Mem1, Mem2, Result);
  type Operation is (Add, Subtract, Multiply, Divide, Extra);

  signal Current_State : State;
  signal Next_State : State := Mem1;
  signal Oper : Operation;

signal op1: std_logic_vector (1 downto 0) := (others => '0');
signal op2 : std_logic_vector (2 downto 0) := (others => '0') ;


begin

Data_to_vector: process (Oper, Current_State, Clk)
-- Will enter this state if the oper (operation) or the current state has changed
    begin
    if (rising_edge(Clk)) then

    case Oper is


    when Add => op2 <="000";
    when Subtract => op2 <= "001";
    when Multiply => op2 <= "010";
    when Divide => op2 <= "011";
    when Extra => op2 <= "100";
    when others => op2 <= "---";
end case;


case Current_State is

when Mem1 => op1 <= "00";
when Mem2 => op1 <= "01";
when Result => op1 <= "10";
when others => op1 <= "00";


end case;

Opcode(4 downto 3) <= op1;
Opcode(2 downto 0) <= op2;

end if;
end process Data_to_vector;

State_Clock: process(Clk, Reset)
begin
  if (Reset = '1') then
    Current_State <= Mem1;
  elsif (rising_edge(clk)) then
    Current_State <= Next_State;
  end if;
end process State_Clock;

State_Process : process(Clk)
begin
    if (rising_edge(Clk)) then

    case Current_State is
    when Mem1 =>
    if (Left_Button ='1' and B_Pressed = '1') then
        Next_State <= Mem2;
        Oper <= Add;

    elsif (Down_Button = '1' and B_Pressed = '1') then
        Next_State <= Mem2;
        Oper <= Subtract;

    elsif (Up_Button = '1' and B_Pressed = '1') then
        Next_State <= Mem2;
        Oper <= Multiply;

    elsif (Right_Button = '1' and B_Pressed = '1') then
        Next_State <= Mem2;
        Oper <= Divide;

    elsif (Middle_Button = '1' and B_Pressed = '1') then
    --IF square it, jumpt to result state
        Next_State <= Result;
        Oper <= Extra;

    end if;

    when Mem2 =>
    if (MathReady= '1') then
        Next_State <= Result;
    end if;

    when Result=>
        if con = '1' then
            Next_State <= Mem1;
        end if;

    end case;
    end if;
end process State_Process;

end Behavioral;

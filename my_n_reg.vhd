----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/04/22 20:45:46
-- Design Name: 
-- Module Name: my_n_reg - Behavioral
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity my_n_reg is
    generic (N : integer := 4);
  Port ( 
        reset: in std_logic ;
        Din : in std_logic_vector ( N -1 downto  0);
        Enable : in std_logic;
        clk: in std_logic;
        Qout: out std_logic_vector ( N -1 downto 0)
  );

end my_n_reg;

architecture Behavioral of my_n_reg is
    component Test_D_FF_with_R port (
        R : in STD_LOGIC;    
        D : in STD_LOGIC;
        EN : in STD_LOGIC;
        clk : in STD_LOGIC;
        Q : out STD_LOGIC );
end component;

begin
    ULOOP: for counter in 0 to N - 1 generate 
        REG: Test_D_FF_with_R port map (
        R => reset,
        D => Din(counter),
        EN => Enable,
        clk => clk,
        Q => Qout(counter )
        );
    end generate ULOOP ;
end Behavioral;

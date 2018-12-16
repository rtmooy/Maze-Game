library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LED_REG is
    Port ( EN : in STD_LOGIC;
           D : in STD_LOGIC_VECTOR (7 downto 0);
           CLK : in STD_LOGIC;
           Q : out STD_LOGIC_VECTOR (7 downto 0));
end LED_REG;

architecture Behavioral of LED_REG is
begin
process(EN, D, CLK) begin
   if rising_edge(CLK) then
     if EN = '1' then
        Q <= D;
     else NULL;
     end if;
   else NULL;
   end if;     
end process;
end Behavioral;

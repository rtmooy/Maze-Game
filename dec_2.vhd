library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity dec_2 is
    Port (D_in : in STD_LOGIC_VECTOR (7 downto 0);
          SEL  : in STD_LOGIC_VECTOR (7 downto 0);
          LEDs : out STD_LOGIC_VECTOR (7 downto 0);
          PMODs : out STD_LOGIC_VECTOR (7 downto 0));
end dec_2;

architecture behavioral of dec_2 is begin
PICKnCHOOSE : process (D_in, SEL) is begin
   LEDs  <= "00000000";
   PMODs <= "00000000";
   case SEL is
   when "01000000" => LEDs <= D_in;
   when others => NULL;
   end case;
end process PICKnCHOOSE;
end behavioral;
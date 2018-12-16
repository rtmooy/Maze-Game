library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_IN is
    Port (SWITCHES : in STD_LOGIC_VECTOR (7 downto 0);
          BTNs : in STD_LOGIC_VECTOR (7 downto 0);
          SEL : in STD_LOGIC_VECTOR (7 downto 0);
          D_OUT : out STD_LOGIC_VECTOR (7 downto 0)
    );
end MUX_IN;

architecture behavioral of MUX_IN is begin
PICKnCHOOSE : process(SWITCHES,BTNs,SEL) is begin
   case SEL is 
      when "00100000" => D_OUT <= SWITCHES;
      when "11111111" => D_OUT <= BTNs;
   end case;
end process PICKnCHOOSE;
end behavioral;
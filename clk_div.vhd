library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity clk_div is
    Port (in_clk : in STD_LOGIC;
          out_clk : out STD_LOGIC);
end clk_div;

architecture BREAKITUP of clk_div is
signal tmp_clk : STD_LOGIC := '0';

begin
HOLDYOURHORSES : process(in_clk) begin
   if in_clk'event and in_clk = '1' then
      tmp_clk <= NOT tmp_clk;
   end if;
end process HOLDYOURHORSES;

out_clk <= tmp_clk;
end BREAKITUP;
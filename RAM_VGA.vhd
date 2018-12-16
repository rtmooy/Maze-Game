 
-- An array of 7631 bytes that works as a framebuffer for the vgaDriverBuffer
-- module. Holds the RGB pixel data for each location.
-- Note: The memory is much larger than the required 4300 locations to store
--       an 80x60 grid. This is due to the addressing scheme of Y concat X
--       creating a 13-bit number maxing out at 7631 when X=79 Y=59
--
-- Authors: Daniel Leon-Gijon, Brett Glidden 
-- CPE 233, Winter 2017, Cal Poly


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity ramVGA is
  port(clk:           in  STD_LOGIC;
       we:            in  STD_LOGIC;
       ra: 			  in  STD_LOGIC_VECTOR(12 downto 0);
	   wa:            in  STD_LOGIC_VECTOR(12 downto 0);
       wd:            in  STD_LOGIC_VECTOR(7 downto 0);
       rd:            out STD_LOGIC_VECTOR(7 downto 0);
       pixelVal:      out STD_LOGIC_VECTOR(7 downto 0)
       );
end ramVGA;

architecture Behavioral of ramVGA is
type ramtype is array (7631 downto 0) of STD_LOGIC_VECTOR(7 downto 0);
  signal mem: ramtype;
begin
  
  -- three-ported register file
  -- read two ports combinationally
  -- write third port on rising edge of clock
  -- Block Computation: (x,y) 104*y + x = address number

  default_update: process(clk)
  begin
    if (clk'event and clk = '1') then
       if we = '1' then 
          mem(to_integer(unsigned(wa))) <= wd;
       end if;
    end if;
  end process;

  rd <= mem(to_integer(unsigned(ra)));
  pixelVal <= mem(to_integer(unsigned(wa)));  

end Behavioral;


-- 
-- Sends the given RGB data to a VGA interface.
--
-- Author: Rob Chapman  Feb 22, 1998
-- 
-- Modified to read RGB data from frame buffer
-- By: Peter Heatwole, Aaron Barton
-- CPE233, Winter 2012, CalPoly
--




library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity VGAdrive is

     port( clock       : in  std_logic;                    -- 25.175 Mhz clock
           red, green  : in  std_logic_vector(2 downto 0);
           blue        : in  std_logic_vector(1 downto 0);
           row, column : out std_logic_vector(9 downto 0); -- for current pixel
           Rout, Gout  : out std_logic_vector(2 downto 0);
           Bout        : out std_logic_vector(1 downto 0);
           H, V        : out std_logic);                   -- VGA drive signals
        
  -- The signals Rout, Gout, Bout, H and V are output to the monitor.
  -- The row and column outputs are used to know when to assert red,
  -- green and blue to color the current pixel.  For VGA, the column
  -- values that are valid are from 0 to 639, all other values should
  -- be ignored.  The row values that are valid are from 0 to 479 and
  -- again, all other values are ignored.  To turn on a pixel on the
  -- VGA monitor, some combination of red, green and blue should be
  -- asserted before the rising edge of the clock.  Objects which are
  -- displayed on the monitor, assert their combination of red, green and
  -- blue when they detect the row and column values are within their
  -- range.  For multiple objects sharing a screen, they must be combined
  -- using logic to create single red, green, and blue signals.

end VGAdrive;

architecture Behavioral of VGAdrive is

subtype counter is std_logic_vector(9 downto 0);
  constant B : natural := 93;             -- horizontal blank: 3.77 us
  constant C : natural := 45;             -- front guard: 1.89 us
  constant D : natural := 640;            -- horizontal columns: 25.17 us
  constant E : natural := 22;             -- rear guard: 0.94 us
  constant A : natural := B + C + D + E;  -- one horizontal sync cycle: 31.77 us
  constant P : natural := 2;              -- vertical blank: 64 us
  constant Q : natural := 32;             -- front guard: 1.02 ms
  constant R : natural := 480;            -- vertical rows: 15.25 ms
  constant S : natural := 11;             -- rear guard: 0.35 ms
  constant O : natural := P + Q + R + S;  -- one vertical sync cycle: 16.6 ms
   
begin

  process
    variable vertical, horizontal : counter;  -- define counters
  begin
    wait until clock = '1';

  -- increment counters
      if  horizontal < A - 1  then
        horizontal := horizontal + 1;
      else
        horizontal := (others => '0');

        if  vertical < O - 1  then -- less than oh
          vertical := vertical + 1;
        else
          vertical := (others => '0');       -- is set to zero
        end if;
      end if;

  -- define H pulse
      if  horizontal >= (D + E)  and  horizontal < (D + E + B)  then
        H <= '0';
      else
        H <= '1';
      end if;

  -- define V pulse
      if  vertical >= (R + S)  and  vertical < (R + S + P)  then
        V <= '0';
      else
        V <= '1';
      end if;

    -- mapping of the variable to the signals
    -- negative signs are because the conversion bits are reversed

   if vertical <= 479 and horizontal <= 639 then
      Rout <= red;
      Gout <= green;
      Bout <= blue;
   else
      Rout <= "000";
      Gout <= "000";
      Bout <= "00";
   end if;
   --ROW & COLUMN ASSIGNED IN PROCESS ORIGINALLY
    row <= vertical;
    column <= horizontal;

  end process;
end Behavioral;


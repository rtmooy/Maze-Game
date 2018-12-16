-- 
-- The interface to the VGA driver module. Extended to both read and write
-- to the framebuffer (to check the color values of a particular pixel).
-- This module expects a 50MHz clock input to function. 
-- Color codes are of format : RRRGGGBB
--
-- Original author: unknown
-- 
-- Modified to support VGA buffer reads
-- By: Peter Heatwole, Aaron Barton
-- CPE233, Winter 2012, CalPoly
--
-- Modified to support 80x60 resolution
-- By: Daniel Leon-Gijon, Brett Glidden
-- CPE233, Winter 2017, CalPoly


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity vgaDriverBuffer is
    Port ( CLK       : in std_logic; 
    	   we        : in std_logic;
           wa        : in std_logic_vector (12 downto 0);
           wd        : in std_logic_vector (7 downto 0);
           Rout      : out std_logic_vector(2 downto 0);
           Gout      : out std_logic_vector(2 downto 0);
           Bout      : out std_logic_vector(1 downto 0);
           HS        : out std_logic;
           VS        : out std_logic;
           pixelData : out std_logic_vector(7 downto 0)
              );
end vgaDriverBuffer;

architecture Behavioral of vgaDriverBuffer is

-- vga driver signals
signal ra            : std_logic_vector(12 downto 0);   -- Read Address line
signal vgaData       : std_logic_vector(7 downto 0);    -- VGA 8-bit color code
signal fb_wr         : std_logic;                       -- Frame Buffer write enable
signal vgaclk        : std_logic;                       -- 25.175 MHz VGA clock     
signal red, green    : std_logic_vector(2 downto 0);    -- 3-bit red and green color codes
signal blue          : std_logic_vector(1 downto 0);    -- 3-bit blue color code
signal row, column   : std_logic_vector(9 downto 0);    -- 10-bit row and column 

-- Added to read the pixel data at address 'wa' -- pfh, 3/1/2012
signal pixelVal : std_logic_vector(7 downto 0);         -- Color data from frame buffer read

-- Declare VGA driver components
component VGAdrive is
  port( clock       : in std_logic;  -- 25.175 Mhz clock
        red, green  : in std_logic_vector(2 downto 0);
        blue        : in std_logic_vector(1 downto 0);
        row, column : out std_logic_vector(9 downto 0); -- for current pixel
        Rout, Gout  : out std_logic_vector(2 downto 0);
        Bout        : out std_logic_vector(1 downto 0);
        H, V        : out std_logic); -- VGA drive signals
end component;

component ramVGA is
  port(clk      : in  STD_LOGIC;
       we       : in  STD_LOGIC;
       ra, wa   : in  STD_LOGIC_VECTOR(12 downto 0);
       wd       : in  STD_LOGIC_VECTOR(7 downto 0);
       rd       : out STD_LOGIC_VECTOR(7 downto 0);
       pixelVal : out STD_LOGIC_VECTOR(7 downto 0));
end component; 

component vga_clk_div is
  port(clk     : in std_logic;
       clkout  : out std_logic);
end component;


begin

-- Instantiate VGA driver components
vga_clk  : vga_clk_div  
    port map (clk    => CLK, 
              clkout => vgaclk);

frameBuffer : ramVGA      
    port map ( clk => clk,       
               we  => we,
               ra  => ra,
               wa  => wa,
               wd  => wd,
               rd  => vgaData,
               pixelVal => pixelVal);
                                       
vga_out : VGAdrive         
    port map ( clock  => vgaclk,
               red    => red,
               green  => green,
               blue   => blue,
               row    => row,
               column => column,
               Rout   => Rout,
               Gout   => Gout,
               Bout   => Bout,
               H      => HS,
               V      => VS);                                     
                                       
 
 -- read signals from fb
   ra <= row (8 downto 3) & column(9 downto 3); 
   red <= vgaData(7 downto 5);      
   green <= vgaData(4) & vgaData(1 downto 0);
   blue <= vgaData(3 downto 2);
   pixelData <= pixelVal; -- returns the pixel data in the framebuffer at address 'wa'

end Behavioral;


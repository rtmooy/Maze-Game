library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity RAT_WRAPPER is
    Port (BTNR : in STD_LOGIC; --rst, connected to a btn
          CLK  : in STD_LOGIC;
          
          VGA_RGB : out STD_LOGIC_VECTOR (7 downto 0); --VGA outs
          VGA_VS  : out STD_LOGIC;
          VGA_HS  : out STD_LOGIC;
          
          PS2D		: in  	STD_LOGIC; 						-- PS/2 data signal
          PS2C      : in    STD_LOGIC;                         -- PS/2 clock signal
          
          SWITCHES : in STD_LOGIC_VECTOR (7 downto 0); 
          INT : in STD_LOGIC;
          BTNs : in STD_LOGIC_VECTOR (3 downto 0); --Will be added later
          LEDs : out STD_LOGIC_VECTOR (7 downto 0);
          SSEG_EN : out STD_LOGIC_VECTOR (3 downto 0);
          SSEG_SEGMENTS : out STD_LOGIC_VECTOR (7 downto 0));
end RAT_WRAPPER;

architecture Behavioral of RAT_WRAPPER is

component RandGen is
    Port ( Clk : in STD_LOGIC;     -- Clock to change random value, should be fast (100 MHz)
           Reset : in STD_LOGIC;   -- Reset to preset Seed value when high
           Random : out STD_LOGIC_VECTOR (7 downto 0)); -- 8 bit random binary output
end component RandGen;

component KeyboardDriver is
	Port (	clk		: in  STD_LOGIC;
			keyclk	: in  STD_LOGIC;
			keydata	: in  STD_LOGIC;
			keycode	: out STD_LOGIC_VECTOR (7 downto 0);
			intrpt	: out STD_LOGIC);
end component KeyboardDriver;

component vgaDriverBuffer is
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
end component vgaDriverBuffer;

component db_1shot_fsm is
    Port (     A : in std_logic;
               CLK : in std_logic;
               A_DB : out std_logic);
end component;               

component sseg_dec is
    Port (     ALU_VAL : in std_logic_vector(7 downto 0); 
               CLK : in std_logic;
               DISP_EN : out std_logic_vector(3 downto 0);
               SEGMENTS : out std_logic_vector(7 downto 0));
end component;

component RAT_MCU is
       Port ( IN_PORT  : in  STD_LOGIC_VECTOR (7 downto 0);
              OUT_PORT : out STD_LOGIC_VECTOR (7 downto 0);
              PORT_ID  : out STD_LOGIC_VECTOR (7 downto 0);
              IO_STRB  : out STD_LOGIC;
              RESET    : in  STD_LOGIC;
              INT      : in  STD_LOGIC;
              CLK      : in  STD_LOGIC);
end component RAT_MCU;


--INPUT Port ID Definitions-----------------------------------------
constant SWITCHES_PORT : STD_LOGIC_VECTOR (7 downto 0) := x"20";
constant RAND_PORT : STD_LOGIC_VECTOR (7 downto 0) := x"0F";
constant BUTTONS_PORT : STD_LOGIC_VECTOR (7 downto 0) := x"FF";
constant VGA_READ_ID  : STD_LOGIC_VECTOR (7 downto 0) := x"93"; --read pixel value at some address
constant KEYBOARD_ID  : STD_LOGIC_VECTOR (7 downto 0) := x"44";

--OUTPUT Port ID Definitions----------------------------------------
constant LEDs_PORT : STD_LOGIC_VECTOR (7 downto 0) := x"40";
constant SSEG_PORT : STD_LOGIC_VECTOR (7 downto 0) := x"81";
constant VGA_WRITE_ID : STD_LOGIC_VECTOR (7 downto 0) := x"92"; --color code to store in frame buffer
constant VGA_HADDR_ID : STD_LOGIC_VECTOR (7 downto 0) := x"90"; --Address in Fr. Bffr. is 13 bits wide; divided
constant VGA_LADDR_ID : STD_LOGIC_VECTOR (7 downto 0) := x"91"; --into high & low parts (y and x)

--inner signal definitions
signal s_INPUT     : STD_LOGIC_VECTOR (7 downto 0);
signal s_TRUE_CLK  : STD_LOGIC := '0';
signal s_PORTID    : STD_LOGIC_VECTOR (7 downto 0);
signal s_OUT_MCU   : STD_LOGIC_VECTOR (7 downto 0);

signal r_LEDS      : STD_LOGIC_VECTOR (7 downto 0);
signal r_SSEG      : STD_LOGIC_VECTOR (7 downto 0);

signal r_vga_we    : STD_LOGIC;
signal r_vga_wa    : STD_LOGIC_VECTOR (12 downto 0);
signal r_vga_wd    : STD_LOGIC_VECTOR (7 downto 0);
signal s_PixelData : STD_LOGIC_VECTOR (7 downto 0);

signal s_ENABLE    : STD_LOGIC;
signal s_db1s_out  : STD_LOGIC;

signal s_RANDOM : STD_LOGIC_VECTOR (7 downto 0);
signal s_BTNs   : STD_LOGIC_VECTOR (3 downto 0);

signal s_keyboard_int : std_logic;
signal s_keycode : std_logic_vector (7 downto 0);

begin

   KEYBOARD: KeyboardDriver
   port map ( clk 		=> s_true_clk,
	    	  keyclk 	=> PS2C,
	    	  keydata 	=> PS2D,
	    	  keycode 	=> s_keycode,
	    	  intrpt 	=> s_keyboard_int);

myRANDOM : RandGen Port map(
  CLK => CLK,
  RESET => BTNR,
  RANDOM => s_RANDOM);

myVGA  : vgaDriverBuffer Port map(
  CLK => s_TRUE_CLK,
  we  => r_vga_we,
  wa  => r_vga_wa,
  wd  => r_vga_wd,
  hs  => vga_hs,
  vs  => vga_vs,
  PixelData => s_PixelData,
  Rout => VGA_RGB(7 downto 5), 
  Gout => VGA_RGB(4 downto 2),
  Bout => VGA_RGB(1 downto 0));

my_MCU : RAT_MCU Port map(
  IN_PORT => s_INPUT,
  CLK => s_TRUE_CLK,
  RESET => BTNR,
  INT => s_keyboard_int,
  OUT_PORT => s_OUT_MCU,
  PORT_ID => s_PORTID,
  IO_STRB => s_ENABLE);

db_1shotint : db_1shot_fsm Port map(
  A => INT,
  CLK => S_TRUE_CLK,
  A_DB => s_db1s_out); 

db_1shotBTN0 : db_1shot_fsm Port map(
  A => BTNs(0),
  CLK => S_TRUE_CLK,
  A_DB => s_BTNs(0)); 

db_1shotBTN1 : db_1shot_fsm Port map(
  A => BTNs(1),
  CLK => S_TRUE_CLK,
  A_DB => s_BTNs(1));

db_1shotBTN2 : db_1shot_fsm Port map(
  A => BTNs(2),
  CLK => S_TRUE_CLK,
  A_DB => s_BTNs(2));
  
db_1shotBTN3 : db_1shot_fsm Port map(
    A => BTNs(3),
    CLK => S_TRUE_CLK,
    A_DB => s_BTNs(3));  
  
sseg_disp : sseg_dec Port map(
     ALU_VAL => r_SSEG,    
     CLK => s_TRUE_CLK,
     DISP_EN => SSEG_EN,
     SEGMENTS => SSEG_SEGMENTS); 
  
  --CLK_PROCESS-------------------------------------------------------
  clk_div : process(clk) begin
    if rising_edge(clk) then 
      s_TRUE_CLK <= NOT s_TRUE_CLK;
    else NULL;
    end if;   
  end process clk_div;   
  --------------------------------------------------------------------
  
  --INPUT_PROCESS-----------------------------------------------------
  choose_input : process(SWITCHES, s_keycode, s_PORTID, s_PixelData, s_BTNs, s_RANDOM) begin
    if s_PORTID = SWITCHES_PORT then
       s_INPUT <= SWITCHES;
    
    elsif s_PORTID = BUTTONS_PORT then
       s_INPUT <= ("0000" & s_BTNs);   
    
    elsif s_PORTID = KEYBOARD_ID then
       s_INPUT <= s_keycode;
    
    elsif s_PORTID = RAND_PORT then
       s_INPUT <= s_RANDOM;
    --Read pixel data from VGA Buffer
    elsif s_PORTID = VGA_READ_ID then
       s_INPUT <= s_PixelData; --Need two outputs for address before you read PixelData
    
    else s_INPUT <= X"00";
    end if;
  end process;
  
  
  
  --OUTPUT_PROCESS: Add all output registers and interfaces here.-----
  --s_ENABLE is IO_STRB output from MCU, all registers are synch.-----  
  choose_output : process(CLK, s_PORTID, s_TRUE_CLK, s_ENABLE) begin
    if rising_edge(s_TRUE_CLK) then
       --SET VGA Enable to 0 on each clock pulse
       r_vga_we <= '0';
       
       if s_ENABLE = '1' then
       
       --This creates a reg for LEDs. All output reg will also be created here as separate if statements
         if s_PORTID = LEDs_PORT then
           r_LEDs <= s_OUT_MCU;
       --VGA  
         elsif s_PORTID = VGA_HADDR_ID then
           r_vga_wa(12 downto 8) <= s_OUT_MCU(4 downto 0);
           
         elsif s_PORTID = VGA_LADDR_ID then
           r_vga_wa(7 downto 0)  <= s_OUT_MCU;
           
         elsif s_PORTID = VGA_WRITE_ID then
           r_vga_we <= '1';
           r_vga_wd <= s_OUT_MCU;
               
        --SEVEN SEG DISPLAY 
         elsif s_PORTID = SSEG_PORT then
           r_SSEG <= s_OUT_MCU;
           
         end if;  
         
         else NULL;
       end if;    
    end if;   
  end process;
  
  --Assign all outputs to their register interfaces
  LEDs <= r_LEDs;
  
  
end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity REG_FILE is
    Port ( DIN : in STD_LOGIC_VECTOR (7 downto 0);
           ADRX : in STD_LOGIC_VECTOR (4 downto 0);
           ADRY : in STD_LOGIC_VECTOR (4 downto 0);
           RF_WR : in STD_LOGIC;
           CLK : in STD_LOGIC;
           DX_OUT : out STD_LOGIC_VECTOR (7 downto 0);
           DY_OUT : out STD_LOGIC_VECTOR (7 downto 0));
end REG_FILE;

architecture Behavioral of REG_FILE is
TYPE memory is ARRAY (0 to 31) of STD_LOGIC_VECTOR(7 downto 0); -- Create TYPE "memory" as an array with 32 indexes each being 8 bits 
SIGNAL reg_bank : memory := (others => (others => '0')); -- Create module of TYPE "memory" and initialize to all 0s

begin
    DX : process( DIN, CLK, RF_WR)
    begin
        if (RF_WR = '1') and rising_edge(CLK) then 
            reg_bank(to_integer(unsigned(ADRX) )) <= DIN; -- Saves the input data (DIN) to register ADRX from the "ram" module, when RF_WR = '1' and on the rising edge of the clock
        end if;
    end process DX;
    
DX_OUT <= reg_bank( to_integer(unsigned(ADRX) )); -- DX_OUT is assigned the data in register ADRX               
DY_OUT <= reg_bank( to_integer(unsigned(ADRY) )); 
end Behavioral;

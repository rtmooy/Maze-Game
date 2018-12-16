library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SCRATCH_RAM is
    Port ( DATA_IN : in STD_LOGIC_VECTOR (9 downto 0);
           SCR_ADDR : in STD_LOGIC_VECTOR (7 downto 0);
           SCR_WE : in STD_LOGIC;
           CLK : in STD_LOGIC;
           DATA_OUT : out STD_LOGIC_VECTOR (9 downto 0));
end SCRATCH_RAM;

architecture Behavioral of SCRATCH_RAM is

TYPE memory is ARRAY(0 to 255) of STD_LOGIC_VECTOR(9 downto 0); -- Create TYPE "memory" as an array with 256 indexes each being 10 bits 

SIGNAL ram : memory := (others => (others => '0')); -- Create module of TYPE "memory" and initialize to all 0s

begin
    process(DATA_IN, SCR_WE, SCR_ADDR, CLK)
    begin
        if (SCR_WE = '1') and rising_edge(clk) then
            ram(to_integer(unsigned(SCR_ADDR))) <= DATA_IN; -- Saves the input data (DATA_IN) to register SCR_ADDER from the "ram" module, when SCR_WE = '1'
        end if;
    end process;    
DATA_OUT <= ram(to_integer(unsigned(SCR_ADDR)));
end Behavioral;

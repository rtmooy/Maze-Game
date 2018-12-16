library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity ProgramCounter is
    Port ( DIN : in STD_LOGIC_VECTOR (9 downto 0);
           PC_LD : in STD_LOGIC;
           PC_INC : in STD_LOGIC;
           RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           PC_COUNT : out STD_LOGIC_VECTOR (9 downto 0));
end ProgramCounter;

architecture Behavioral of ProgramCounter is
    signal cnt : std_logic_vector(9 downto 0);
begin
    process (CLK, RST)
    begin
        if (rising_edge(CLK)) then
            if (RST = '1') then
                cnt <= "0000000000";
            else 
                if (PC_LD = '1') then 
                    cnt <= DIN;
                else 
                    if (PC_INC = '1') then
                        cnt <= std_logic_vector(unsigned(cnt) + 1);
                    end if;
                end if;
            end if;
        end if;
    end process;
    PC_COUNT <= cnt;            
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Stack_Pointer is
    Port ( DATA_IN : in STD_LOGIC_VECTOR (7 downto 0);
           RST : in STD_LOGIC;
           LD : in STD_LOGIC;
           INCR : in STD_LOGIC;
           DECR : in STD_LOGIC;
           CLK : in STD_LOGIC;
           DATA_OUT : out STD_LOGIC_VECTOR (7 downto 0));
end Stack_Pointer;

architecture Behavioral of Stack_Pointer is
    signal cnt : std_logic_vector(7 downto 0):= x"00";
begin
    process (CLK, RST)
    begin
        if (rising_edge(CLK)) then
            if (RST = '1') then
                cnt <= "00000000";
            else 
                if (LD = '1') then 
                    cnt <= DATA_IN;
                else 
                    if (INCR = '1') then
                        cnt <= std_logic_vector(unsigned(cnt) + 1);
                    elsif (DECR = '1') then
                        cnt <= std_logic_vector(unsigned(cnt) - 1);
                    end if;
                end if;
            end if;
        end if;
    end process;
DATA_OUT <= cnt;   

end Behavioral;


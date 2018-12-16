library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC_MUX is
  port (
        FROM_IMMED : in std_logic_vector (9 downto 0);
        FROM_STACK : in std_logic_vector (9 downto 0);
        LAST_ADDR : in std_logic_vector (9 downto 0) := "1111111111";
        PC_MUX_SEL : in std_logic_vector (1 downto 0);
        Din_MUX : out std_logic_vector (9 downto 0));
end PC_MUX;

architecture MUX_logic of PC_MUX is
begin
    process
    begin
        case PC_MUX_SEL is
            when "00" => Din_MUX <= FROM_IMMED;
            when "01" => Din_MUX <= FROM_STACK;
            when "10" => Din_MUX <= LAST_ADDR;
            when others => Din_MUX <= "0000000000";
        end case;
        wait for 10 ns;
    end process;

end MUX_logic;
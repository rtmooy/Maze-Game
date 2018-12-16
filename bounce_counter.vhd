--------------------------------------------------------------------------
--
-- Engineer: Jeff Gerfen
-- Create Date: 2016.02.26 
-- Design Name: counter
-- Module Name: counter
--
-- DESCRIPTION:
-- Simple up counter with synchronous load and synchronous reset controls.
--------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter is
    Port ( RST    : in  STD_LOGIC;
           CLK    : in  STD_LOGIC;
           INC    : in  STD_LOGIC;
           COUNT  : out STD_LOGIC_VECTOR (7 downto 0));
end counter;

architecture Behavioral of counter is

   signal s_count : std_logic_vector (7 downto 0) := "00000000";
   
begin

    proc: process(CLK, RST, INC, s_count)
    begin
       if(rising_edge(CLK)) then
          if(RST = '1') then             -- synchronous reset
             s_count <= "00000000";
          elsif(INC = '1') then
             s_count <= s_count + '1';
          end if;       
        end if;
    end process proc;
    
    COUNT <= s_count;

end Behavioral;

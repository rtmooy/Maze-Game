library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity ALU is
    Port ( SEL : in STD_LOGIC_VECTOR (3 downto 0);
           A : in STD_LOGIC_VECTOR (8 downto 0);
           B : in STD_LOGIC_VECTOR (8 downto 0);
           Cin : in STD_LOGIC;
           RESULT : out STD_LOGIC_VECTOR (7 downto 0);
           C : out STD_LOGIC;
           Z : out STD_LOGIC);
end ALU;

architecture Behavioral of ALU is
signal overflow_res : std_logic_vector(8 downto 0) := "000000000";
begin
sel_proc : process(SEL, A, B, Cin, overflow_res) is begin

case SEL is
when "0000" =>       --ADD operation
overflow_res <= std_logic_vector(unsigned(A) + unsigned(B));
C <= overflow_res(8);
if overflow_res = "000000000" then
   Z <= '1';
else
   Z <= '0';
end if;
RESULT <= overflow_res(7 downto 0);

when "0001" =>       --AddC
overflow_res <=  (Cin + std_logic_vector(unsigned(A) + unsigned(B)));
C <= overflow_res(8);
if overflow_res = "000000000" then
   Z <= '1';
else
   Z <= '0';
end if;
RESULT <= overflow_res(7 downto 0);

when "0010" =>            --SUB
overflow_res <= std_logic_vector(unsigned(A) - unsigned(B));
C <= overflow_res(8);
if overflow_res = "00000000" then
    Z <= '1';
else
    Z <= '0';
end if;
RESULT <= overflow_res(7 downto 0);


when "0011" =>            --SUBC
overflow_res <= (std_logic_vector(unsigned(A) - unsigned(B)) - Cin);
C <= overflow_res(8);
if overflow_res = "00000000" then
    Z <= '1';
else
    Z <= '0';
end if;
RESULT <= overflow_res(7 downto 0);


when "0100" =>            --CMP
overflow_res <= std_logic_vector(unsigned(A) - unsigned(B));
C <= overflow_res(8);
if overflow_res = "00000000" then
    Z <= '1';
else
    Z <= '0';
end if;
RESULT <= "00000000";

when "0101" =>            --AND
overflow_res(8) <= '0';
overflow_res <= (A and B);
C <= '0';
if overflow_res = "000000000" then
   Z <= '1';
else
   Z <= '0';
end if;
RESULT <= overflow_res(7 downto 0);

when "0110" =>            --OR
C <= '0';
overflow_res(8) <= '0';
overflow_res <= (A or B);
if overflow_res = "000000000" then
   Z <= '1';
else
   Z <= '0';
end if;
RESULT <= overflow_res(7 downto 0);

when "0111" =>          --EXOR 
overflow_res(8) <= '0'; 
overflow_res <= (A xor B);
C <= '0';
if overflow_res = "000000000" then
   Z <= '1';
else
   Z <= '0';
end if;
RESULT <= overflow_res(7 downto 0);

when "1000" =>            --TEST
overflow_res(8) <= '0';
overflow_res <= (A and B);
C <= '0';
if overflow_res = "000000000" then
   Z <= '1';
else
   Z <= '0';
end if;
RESULT <= "00000000";

when "1001" =>            --LSL
C <= A(7);
overflow_res(8) <= '0';
overflow_res(7) <= A(6);
overflow_res(6) <= A(5);
overflow_res(5) <= A(4);
overflow_res(4) <= A(3);
overflow_res(3) <= A(2);
overflow_res(2) <= A(1);
overflow_res(1) <= A(0);
overflow_res(0) <= Cin;
if overflow_res = "000000000" then
   Z <= '1';
else
   Z <= '0';
end if;
RESULT <= overflow_res(7 downto 0);

when "1010" =>            --LSR
C <= A(0);
overflow_res(8) <= '0';
overflow_res(7) <= Cin;
overflow_res(6) <= A(7);
overflow_res(5) <= A(6);
overflow_res(4) <= A(5);
overflow_res(3) <= A(4);
overflow_res(2) <= A(3);
overflow_res(1) <= A(2);
overflow_res(0) <= A(1);

if overflow_res = "000000000" then
   Z <= '1';
else
   Z <= '0';
end if;
RESULT <= overflow_res(7 downto 0);

when "1011" =>            --ROL
C <= A(7);
overflow_res(8) <= '0';
overflow_res(7) <= A(6);
overflow_res(6) <= A(5);
overflow_res(5) <= A(4);
overflow_res(4) <= A(3);
overflow_res(3) <= A(2);
overflow_res(2) <= A(1);
overflow_res(1) <= A(0);
overflow_res(0) <= A(7);
if overflow_res = "000000000" then
   Z <= '1';
else
   Z <= '0';
end if;
RESULT <= overflow_res(7 downto 0);

when "1100" =>            --ROR
C <= A(0);
overflow_res(8) <= '0';
overflow_res(7) <= A(0);
overflow_res(6) <= A(7);
overflow_res(5) <= A(6);
overflow_res(4) <= A(5);
overflow_res(3) <= A(4);
overflow_res(2) <= A(3);
overflow_res(1) <= A(2);
overflow_res(0) <= A(1);

if overflow_res = "000000000" then
   Z <= '1';
else
   Z <= '0';
end if;
RESULT <= overflow_res(7 downto 0);

when "1101" =>            --ASR
C <= A(0);
overflow_res(8) <= '0';
overflow_res(7) <= A(7);
overflow_res(6) <= A(7);
overflow_res(5) <= A(6);
overflow_res(4) <= A(5);
overflow_res(3) <= A(4);
overflow_res(2) <= A(3);
overflow_res(1) <= A(2);
overflow_res(0) <= A(1);

if overflow_res = "000000000" then
   Z <= '1';
else
   Z <= '0';
end if;
RESULT <= overflow_res(7 downto 0);

when "1110" =>            --MOV
RESULT <= B(7 downto 0);
C <= '0';                  --Don't care! C_LD should be low
Z  <= '0';                --Don't care! Z_LD should be low
overflow_res <= "000000000";

when "1111" =>            --unused
C <= '0';
Z <= '0';
overflow_res <= "000000000";
RESULT <= "00000000";
when others =>
C <= '0';
Z <= '0';
overflow_res <= "000000000";
RESULT <= "00000000";

end case;

end process sel_proc;
end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FLAGS is
    Port ( FLG_C_SET : in STD_LOGIC;
           FLG_C_CLR : in STD_LOGIC;
           FLG_C_LD : in STD_LOGIC;
           FLG_Z_LD : in STD_LOGIC;
           FLG_SHAD_LD : in STD_LOGIC;
           FLG_LD_SEL : in STD_LOGIC;
           CLK : in STD_LOGIC;
           C : in STD_LOGIC;
           Z : in STD_LOGIC;
           C_FLG : out STD_LOGIC := '0';
           Z_FLG : out STD_LOGIC := '0');
end FLAGS;

architecture Logic of FLAGS is
signal shadZ, shadC, Z_mux_result, C_mux_result : std_logic := '0';

begin
   C_mux : process (FLG_LD_SEL, C, shadC) begin
      case FLG_LD_SEL is
         when '0' => C_mux_result <= C;
         when others => C_mux_result <= shadC;
      end case;
   end process;

   Z_MUX : process (FLG_LD_SEL, Z, shadZ) begin
      case FLG_LD_SEL is
         when '0' => Z_mux_result <= Z;
         when others => Z_mux_result <= shadZ;
      end case;
   end process;

   C_FLG_PROC : process(CLK, FLG_C_SET, FLG_C_CLR, FLG_C_LD) begin
      if rising_edge(CLK) then
         if FLG_C_SET = '1' then
            C_FLG <= '1';
         elsif FLG_C_CLR = '1' then
            C_FLG <= '0';
         elsif FLG_C_LD = '1' then
            C_FLG <= C_mux_result;
         else
            NULL; 
         end if;   
      end if;         
   end process C_FLG_PROC;

   Z_FLG_PROC : process(CLK, FLG_Z_LD) begin
      if rising_edge(CLK) then
         if FLG_Z_LD = '1' then
           Z_FLG <= Z_mux_result;  
         else
            NULL; 
         end if;   
      end if;         
   end process Z_FLG_PROC;

   Z_SHAD_FLAG_PROC : process(CLK, FLG_SHAD_LD) begin   
      if rising_edge(CLK) then
         if FLG_SHAD_LD = '1' then
            shadZ <= Z;
         else
            NULL;
         end if;
      end if;
   end process Z_SHAD_FLAG_PROC;

   C_SHAD_FLAG_PROC : process(CLK, FLG_SHAD_LD) begin   
      if rising_edge(CLK) then
         if FLG_SHAD_LD = '1' then
            shadC <= C;
         else
            NULL;
         end if;
      end if;
   end process C_SHAD_FLAG_PROC;
end Logic;
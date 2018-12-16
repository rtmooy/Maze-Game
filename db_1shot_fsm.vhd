--------------------------------------------------------------------------
--
-- Engineer: Jeff Gerfen
-- Create Date: 2016.02.26 
-- Design Name: db_1shot_fsm
-- Module Name: db_1shot_fsm
--
-- DESCRIPTION:
-- FSM-based debouncer with integrated one-shot output.  
-- One-shot output directly follows successfull completion of debouncing 
-- the rising edge and then the falling edged of the input signal.
--
-- CONFIGURABLE PARAMETERS:
-- c_LOW_GOING_HIGH_CLOCKS = minimum # clocks for stable high input
-- c_HIGH_GOING_LOW_CLOCKS = minimum # clocks for stable low input
-- c_ONE_SHOT_CLOCKS = length of one shot output pulse in clk cycles
--
--------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity db_1shot_FSM is
    Port ( A    : in STD_LOGIC;
           CLK  : in STD_LOGIC;
           A_DB : out STD_LOGIC);
end db_1shot_FSM;

architecture Behavioral of db_1shot_FSM is
   
   --constant c_LOW_GOING_HIGH_CLOCKS : std_logic_vector := x"19"; -- 25 clks
   --constant c_HIGH_GOING_LOW_CLOCKS : std_logic_vector := x"33"; -- 50 clks
   --constant c_ONE_SHOT_CLOCKS       : std_logic_vector := x"03"; -- 3 clks7
   
   constant c_LOW_GOING_HIGH_CLOCKS : std_logic_vector := x"46"; -- 70 clks
   constant c_HIGH_GOING_LOW_CLOCKS : std_logic_vector := x"50"; -- 80 clks
   constant c_ONE_SHOT_CLOCKS       : std_logic_vector := x"0A"; -- 10 clks

   
   component Counter is
    Port ( RST    : in  STD_LOGIC;
           CLK    : in  STD_LOGIC;
           INC    : in  STD_LOGIC;
           COUNT  : out STD_LOGIC_VECTOR (7 downto 0));
   end component;

   type state_type is (ST_init,
                       ST_A_low, 
                       ST_A_low_to_high, 
                       ST_A_high, 
                       ST_A_high_to_low, 
                       ST_one_shot);
                       
   signal PS,NS : state_type;
   signal s_db_count: std_logic_vector (7 downto 0) := x"00";
   
   signal s_count_rst : std_logic := '0';
   signal s_count_inc : std_logic := '0';

begin

bounce_counter: counter
port map (RST   => s_count_rst,
          CLK   => CLK,
          INC   => s_count_inc,
          COUNT => s_db_count); 

sync_p: process (CLK, PS, NS)
 begin
    if (rising_edge(CLK)) then 
       PS <= NS;
     end if;
 end process sync_p;

comb_p: process (PS, A, s_db_count)
begin
   
   -- default values for signals
   --s_db_count <= x"00";
   NS         <= ST_init;
   A_DB       <= '0';
   s_count_rst <= '0';
   s_count_inc <= '0';
   
   case PS is
      -- INITIALIZATION
      when ST_init =>
      
         NS <= ST_A_low;
         A_DB <= '0';
         s_count_rst <= '1';                 -- reset the bounce counter
   
      -- input is low, waiting for a one
      when ST_A_low =>
      
         if (A = '1') then
            NS <= ST_A_low_to_high;
            s_count_inc <= '1';
         else
            NS <= ST_A_low;
            s_count_rst <= '1';
         end if;
           
      -- waiting for a sufficient number of 1s for bouncing to be complete           
      when ST_A_low_to_high =>
      
         if (A = '1') then
            if (s_db_count = c_LOW_GOING_HIGH_CLOCKS) then   
               NS <= ST_A_high;
               s_count_rst <= '1';
            else
               NS <= ST_A_low_to_high;
               s_count_inc <= '1';
            end if;
         else
            NS <= ST_A_low;
            s_count_rst <= '1';
         end if;

      -- input has gone high    
      when ST_A_high =>
      
         if (A = '1') then
            NS <= ST_A_high;
         else
            NS <= ST_A_high_to_low;
            s_count_rst <= '1';
         end if;
      

      -- waiting for a sufficient number of 0s for bouncing to be complete
      when ST_A_high_to_low =>    

         if (A = '0') then
            if (s_db_count = c_HIGH_GOING_LOW_CLOCKS) then   
               NS <= ST_one_shot;
               s_count_rst <= '1';
            else
               NS <= ST_A_high_to_low;
               s_count_inc <= '1';
            end if;
         else
            NS <= ST_A_high;
            s_count_rst <= '1';
         end if;

      -- first clock of one shot 
      when ST_one_shot =>
         if(s_db_count = c_ONE_SHOT_CLOCKS) then     -- done generating the one shot pulse out
            NS <= ST_init;
            s_count_rst <= '1';
            A_DB <= '0';
         else
            NS <= ST_one_shot;
            s_count_inc <= '1';
            A_DB <= '1';
         end if;
           
      when others =>
         s_count_rst <= '0';
         s_count_rst <= '0';
         NS         <= ST_init;
         A_DB       <= '0';
      
   end case;  
end process comb_p;
 
end Behavioral;
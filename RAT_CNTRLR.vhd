library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RAT_CNTRLR is
    Port ( C   : in STD_LOGIC;
           Z   : in STD_LOGIC;
           RST : in STD_LOGIC;
           INT : in STD_LOGIC;
           OPCODE_HI_5 : in STD_LOGIC_VECTOR(4 downto 0);
           OPCODE_LO_2 : in STD_LOGIC_VECTOR(1 downto 0); 
           CLK : in STD_LOGIC;
           --Interrupts-------------
           I_SET : out STD_LOGIC;
           I_CLR : out STD_LOGIC;
           --Program Counter--------
           PC_LD : out STD_LOGIC;
           PC_INC : out STD_LOGIC;
           PC_MUX_SEL : out STD_LOGIC_VECTOR(1 downto 0);
           --ALU-------------------
           ALU_OPY_SEL : out STD_LOGIC;
           ALU_SEL : out STD_LOGIC_VECTOR(3 downto 0);
           --Reg file--------------
           RF_WR : out STD_LOGIC;
           RF_WR_SEL : out STD_LOGIC_VECTOR(1 downto 0);
           --Flags-----------------
           FLG_C_SET  : out STD_LOGIC;
           FLG_C_CLR  : out STD_LOGIC;
           FLG_C_LD   : out STD_LOGIC;
           FLG_Z_LD   : out STD_LOGIC;
           FLG_LD_SEL : out STD_LOGIC;
           FLG_SHDW_LD: out STD_LOGIC;
           --Scratch RAM-----------
           SCR_WE : out STD_LOGIC;
           SCR_DATA_SEL : out STD_LOGIC;
           SCR_ADDR_SEL : out STD_LOGIC_VECTOR (1 downto 0);
           --Stack Pointer---------
           SP_LD : out STD_LOGIC;
           SP_INCR : out STD_LOGIC;
           SP_DECR : out STD_LOGIC;
           --System----------------
           SYS_RST : out STD_LOGIC;
           IO_STRB : out STD_LOGIC );
end RAT_CNTRLR;

architecture Operation of RAT_CNTRLR is
TYPE state IS (st_exec, st_fetch, st_init, st_interrupt);
signal PS, NS : state := st_init;
signal OPCODE_7 : STD_LOGIC_VECTOR (6 downto 0);
begin  --Let's do this! >:)

OPCODE_7 <= (OPCODE_HI_5 & OPCODE_LO_2);

state_shift : process(CLK, NS, RST) begin
   if RST = '1' then PS <= st_init;
   elsif (rising_edge(CLK)) then PS <= NS;
   end if;
end process state_shift;

state_logic : process(C, Z, OPCODE_7, PS, INT) begin    
--Initialize EVERYTHING TO 0!!!
PC_INC <= '0';
PC_LD <= '0';         
PC_MUX_SEL <= "00";

ALU_OPY_SEL <= '0';
ALU_SEL <= "0000";

I_SET <= '0';
I_CLR <= '0';

RF_WR <= '0';
RF_WR_SEL <= "00";

SCR_WE <= '0';
SCR_DATA_SEL <= '0';
SCR_ADDR_SEL <= "00";

SP_LD <= '0';
SP_INCR <= '0';
SP_DECR <= '0';

FLG_C_SET <= '0';
FLG_C_CLR <= '0';
FLG_C_LD <= '0';
FLG_Z_LD <= '0';
FLG_LD_SEL <= '0';
FLG_SHDW_LD <= '0';

SYS_RST <= '0';
IO_STRB <= '0';        
   CASE PS IS                                                    --THIS is where the magic happens 
      when st_init =>
         SYS_RST <= '1';
         NS <= st_fetch;
                  
      when st_fetch =>                                           --Need IN, MOV, OUT, EXOR, BRN
         NS <= st_exec;
         PC_INC <= '1';         
         
      when st_exec =>
         if INT = '1' then NS <= st_interrupt;
         else NS <= st_fetch;
         end if;
         
         CASE OPCODE_7 is
            when "1100100" | "1100101" | "1100110" | "1100111" =>   --IN
            RF_WR <= '1';          --Enable write reg_file
            RF_WR_SEL <= "11";     --Select value from in port

            when "1101000" | "1101001" | "1101010" | "1101011" =>  --OUT  
            IO_STRB <= '1';    --Need to set io strobe to 1. Why? Don't know yet, just do it! Ignorant teenagers...
                               --Reg File takes care of output to (DX_OUT --> OUT_PORT)
                               
            when "0001001" => --MOV R/R
            RF_WR <= '1';     --Enable reg_file write
            RF_WR_SEL <= "00";--Take value from ALU (passed in from REG_file)
            ALU_SEL <= "1110";--Give ALU MOV command
            ALU_OPY_SEL <= '0'; --AddrY comes from Reg_file

            when "1101100" | "1101101" | "1101110" | "1101111" => --MOV R/I
            RF_WR <= '1';     --Enable reg_file write
            RF_WR_SEL <= "00";--Take value from ALU (passed in from REG_file)
            ALU_SEL <= "1110";--Give ALU MOV command
            ALU_OPY_SEL <= '1'; --AddrY comes from Imm_Val (PRG_ROM)

            when "0000001" => --OR R/R
            RF_WR <= '1';     --Enable reg_file write
            RF_WR_SEL <= "00";--Take value from ALU (passed in from REG_file)
            ALU_SEL <= "0110";--Give ALU OR command
            ALU_OPY_SEL <= '0';--AddrY comes from Reg_file
            FLG_C_CLR <= '1';
            FLG_Z_LD <= '1';
            
            when "1000100" | "1000101" | "1000110" | "1000111" => --OR R/I
            RF_WR <= '1';     --Enable reg_file write
            RF_WR_SEL <= "00";--Take value from ALU (passed in from REG_file)
            ALU_SEL <= "0110";--Give ALU OR command
            ALU_OPY_SEL <= '1';--AddrY comes from Imm_Val (PRG_ROM)
            FLG_C_CLR <= '1';
            FLG_Z_LD <= '1';
            
            when "0000010" => --EXOR R/R
            RF_WR <= '1';     --Enable reg_file write
            RF_WR_SEL <= "00";--Take value from ALU (passed in from REG_file)
            ALU_SEL <= "0111";--Give ALU EXOR command
            ALU_OPY_SEL <= '0';--AddrY comes from Reg_file
            FLG_C_CLR <= '1';
            FLG_Z_LD <= '1';
            
            when "1001000" | "1001001" | "1001010" | "1001011" => --EXOR R/I
            RF_WR <= '1';     --Enable reg_file write
            RF_WR_SEL <= "00";--Take value from ALU (passed in from REG_file)
            ALU_SEL <= "0111";--Give ALU EXOR command
            ALU_OPY_SEL <= '1';--AddrY comes from Imm_Val (PRG_ROM)
            FLG_C_CLR <= '1';
            FLG_Z_LD <= '1';
      
            when "0010000" => --BRN
            PC_LD <= '1';
            PC_MUX_SEL <= "00";
            
            when "0100000" => --LSL
            RF_WR <= '1';     --Enable reg_file write
            RF_WR_SEL <= "00";--Take value from ALU (passed in from REG_file)
            ALU_SEL <= "1001";--Give ALU LSL command
            FLG_C_LD <= '1';
            FLG_Z_LD <= '1';              

            when "0100001" => --LSR
            RF_WR <= '1';     --Enable reg_file write
            RF_WR_SEL <= "00";--Take value from ALU (passed in from REG_file)
            ALU_SEL <= "1010";--Give ALU LSR command
            FLG_C_LD <= '1';
            FLG_Z_LD <= '1';
            
            when "0100010" => --ROL
            RF_WR <= '1';     --Enable reg_file write
            RF_WR_SEL <= "00";--Take value from ALU (passed in from REG_file)
            ALU_SEL <= "1011";--Give ALU ROL command
            FLG_C_LD <= '1';
            FLG_Z_LD <= '1';            
            
            when "0100011" => --ROR
            RF_WR <= '1';     --Enable reg_file write
            RF_WR_SEL <= "00";--Take value from ALU (passed in from REG_file)
            ALU_SEL <= "1100";--Give ALU ROR command
            FLG_C_LD <= '1';
            FLG_Z_LD <= '1';  
            
            when "0001011" => --ST R/R
            SCR_DATA_SEL <= '0';
            SCR_WE <= '1';
            SCR_ADDR_SEL <= "00";
            
            when "1110100" | "1110101" | "1110110" | "1110111" => --ST R/I
            SCR_DATA_SEL <= '0';
            SCR_WE <= '1';
            SCR_ADDR_SEL <= "01";
            
            when "0110001" => -- SEC
            FLG_C_SET <= '1';
            FLG_C_LD <= '1';
            
            when "0000110" => --SUB R/R
            RF_WR <= '1';     --Enable reg_file write
            RF_WR_SEL <= "00";--Take value from ALU (passed in from REG_file)
            ALU_SEL <= "0010";--Give ALU SUB command
            ALU_OPY_SEL <= '0';--AddrY comes from Reg_file
            FLG_C_LD <= '1';
            FLG_Z_LD <= '1';
            
            when "1011000" | "1011001" | "1011010" | "1011011" => --SUB R/I
            RF_WR <= '1';     --Enable reg_file write
            RF_WR_SEL <= "00";--Take value from ALU (passed in from REG_file)
            ALU_SEL <= "0010";--Give ALU SUB command
            ALU_OPY_SEL <= '1';--AddrY comes from Imm_Val (PRG_ROM)
            FLG_C_LD <= '1';
            FLG_Z_LD <= '1';
          
            when "0000111" => --SUBC R/R
            RF_WR <= '1';     --Enable reg_file write
            RF_WR_SEL <= "00";--Take value from ALU (passed in from REG_file)
            ALU_SEL <= "0011";--Give ALU SUBC command
            ALU_OPY_SEL <= '0';--AddrY comes from Reg_file
            FLG_C_LD <= '1';
            FLG_Z_LD <= '1';
            
            when "1011100" | "1011101" | "1011110" | "1011111" => --SUBC R/I
            RF_WR <= '1';     --Enable reg_file write
            RF_WR_SEL <= "00";--Take value from ALU (passed in from REG_file)
            ALU_SEL <= "0011";--Give ALU SUBC command
            ALU_OPY_SEL <= '1';--AddrY comes from Imm_Val (PRG_ROM)
            FLG_C_LD <= '1';
            FLG_Z_LD <= '1';
         
            when "0000011" => --TEST R/R
            ALU_SEL <= "1000";--Give ALU TEST command
            ALU_OPY_SEL <= '0';--AddrY comes from Reg_file
            FLG_C_CLR <= '1';
            FLG_Z_LD <= '1';
            
            when "1001100" | "1001101" | "1001110" | "1001111" => --TEST R/I
            ALU_SEL <= "1000";--Give ALU TEST command
            ALU_OPY_SEL <= '1';--AddrY comes from Imm_Val (PRG_ROM)
            FLG_C_CLR <= '1';
            FLG_Z_LD <= '1';         

           when "0000100" => --ADD R/R
            RF_WR <= '1';      
            RF_WR_SEL <= "00";
            ALU_SEL <= "0000";
            ALU_OPY_SEL <= '0';
            FLG_C_LD <= '1';
            FLG_Z_LD <= '1';
            
            when "1010000" | "1010001" | "1010010" | "1010011" => --ADD R/I
            RF_WR <= '1';
            RF_WR_SEL <= "00";
            ALU_SEL <= "0000";
            ALU_OPY_SEL <= '1';
            FLG_C_LD <= '1';
            FLG_Z_LD <= '1';
            
            when "0000101" => --ADDC R/R
            RF_WR <= '1';
            RF_WR_SEL <= "00";
            ALU_SEL <= "0001";
            ALU_OPY_SEL <= '0';
            FLG_C_LD <= '1';
            FLG_Z_LD <= '1';
            
            when "1010100" | "1010101" | "1010110" | "1010111" => --ADDC R/I
            RF_WR <= '1';
            RF_WR_SEL <= "00";
            ALU_SEL <= "0001";
            ALU_OPY_SEL <= '1';
            FLG_C_LD <= '1';
            FLG_Z_LD <= '1';
            
            when "0000000" => --AND R/R
            RF_WR <= '1';
            RF_WR_SEL <= "00";
            ALU_SEL <= "0101";
            ALU_OPY_SEL <= '0';
            FLG_C_CLR <= '1';
            FLG_Z_LD <= '1';
            
            when "1000000" | "1000001" | "1000010" | "1000011" => --AND R/I
            RF_WR <= '1';
            RF_WR_SEL <= "00";
            ALU_SEL <= "0101";
            ALU_OPY_SEL <= '1';
            FLG_C_CLR <= '1';
            FLG_Z_LD <= '1';
                        
            when "0100100" => --ASR
            RF_WR <= '1';
            RF_WR_SEL <= "00";
            ALU_SEL <= "1101";
            ALU_OPY_SEL <= '0';
            FLG_C_LD <= '1';
            FLG_Z_LD <= '1';            
            
            when "0010101" => --BRCC
            if C = '0' then
               PC_LD <= '1';
               PC_MUX_SEL <= "00";
            else NULL;
            end if;   
            
            when "0010100" => --BRCS
            if C = '1' then
               PC_LD <= '1';
               PC_MUX_SEL <= "00";
            else NULL;
            end if;
            
            when "0010010" => --BREQ
            if Z = '1' then
               PC_LD <= '1';
               PC_MUX_SEL <= "00";
            else NULL;   
            end if;
            
            when "0010011" => --BRNE
            if Z = '0' then
               PC_LD <= '1';
               PC_MUX_SEL <= "00";
            else NULL;
            end if;
            
            when "0110000" =>  --CLC
            FLG_C_CLR <= '1';
            
            when "0001000" => --CMP R/R
            RF_WR <= '0';
            RF_WR_SEL <= "00";
            ALU_SEL <= "0100";
            ALU_OPY_SEL <= '0';
            FLG_C_LD <= '1';
            FLG_Z_LD <= '1';            
            
            when "1100000" | "1100001" | "1100010" | "1100011" => --CMP R/I
            RF_WR <= '0';
            RF_WR_SEL <= "00";
            ALU_SEL <= "0100";
            ALU_OPY_SEL <= '1';
            FLG_C_LD <= '1';
            FLG_Z_LD <= '1';
                        
            when "0001010" => --LD R/R
            RF_WR <= '1';
            RF_WR_SEL <= "01";
            SCR_ADDR_SEL <= "00";            
            
            when "1110000" | "1110001" | "1110010" | "1110011" => --LD R/I
            RF_WR <= '1';
            RF_WR_SEL <= "01";
            SCR_ADDR_SEL <= "01";

            when "0110100" => --SEI
            I_SET <= '1';
            
            when "0110101" => --CLI
            I_CLR <= '1';
            
            when "0101000" => --WSP
            SP_LD <= '1';
            
            when "0100110" => --POP
            SP_INCR <= '1';
            SCR_ADDR_SEL <= "10";
            RF_WR <= '1';
            RF_WR_SEL <= "01";
            
            when "0100101" => --PUSH
            SP_DECR <= '1';
            SCR_DATA_SEL <= '0';
            SCR_ADDR_SEL <= "11";
            SCR_WE <= '1';
            
            when "0010001" => --CALL
            PC_MUX_SEL <= "00";
            PC_LD <= '1';
            SP_DECR <= '1';
            SCR_WE <= '1';
            SCR_DATA_SEL <= '1';
            SCR_ADDR_SEL <= "11";
            
            when "0110010" => --RET
            PC_MUX_SEL <= "01";
            SP_INCR <= '1';
            SCR_ADDR_SEL <= "10";
            PC_LD <= '1';
            
            when "0110110" => --RETID
            PC_MUX_SEL <= "01";
            SP_INCR <= '1';
            SCR_ADDR_SEL <= "10";
            PC_LD <= '1';
            FLG_Z_LD <= '1';
            FLG_C_LD <= '1';
            FLG_LD_SEL <= '1';
            I_CLR <= '1';
            
            when "0110111" => --RETIE
            PC_LD <= '1';
            PC_MUX_SEL <= "01";
            
            SP_INCR <= '1';
            SCR_ADDR_SEL <= "10";
            
            FLG_Z_LD <= '1';
            FLG_C_LD <= '1';
            FLG_LD_SEL <= '1';
            I_SET <= '1';
            
            when others =>
            PC_MUX_SEL <= "10";
         end case;
      when st_interrupt =>
         FLG_SHDW_LD <= '1';
         PC_MUX_SEL <= "10";
         PC_LD <= '1';
         SP_DECR <= '1';
         SCR_WE <= '1';
         SCR_DATA_SEL <= '1';
         SCR_ADDR_SEL <= "11";
         I_CLR <= '1';
         I_SET <= '0';   
         
         NS <= st_fetch;
      when others => --if state other than st_fetch or st_exec or st_init, restart
         NS <= st_init;
   end case;   
end process state_logic;    
end Operation;

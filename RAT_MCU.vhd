library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity RAT_MCU is
    Port ( IN_PORT : in STD_LOGIC_VECTOR (7 downto 0);
           RESET : in STD_LOGIC;
           INT : in STD_LOGIC;
           CLK : in STD_LOGIC;
           OUT_PORT : out STD_LOGIC_VECTOR (7 downto 0);
           PORT_ID : out STD_LOGIC_VECTOR (7 downto 0);
           IO_STRB : out STD_LOGIC);
end RAT_MCU;


architecture Behavioral of RAT_MCU is
    component STACK_POINTER is
       Port ( DATA_IN : in STD_LOGIC_VECTOR (7 downto 0);
              LD : in STD_LOGIC;
              INCR : in STD_LOGIC;
              DECR : in STD_LOGIC;
              RST : in STD_LOGIC;
              CLK : in STD_LOGIC;
              DATA_OUT : out STD_LOGIC_VECTOR (7 downto 0));
    end component;
              
    component SCRATCH_RAM is
        Port ( DATA_IN : in STD_LOGIC_VECTOR (9 downto 0);
               SCR_ADDR : in STD_LOGIC_VECTOR (7 downto 0);
               SCR_WE : in STD_LOGIC;
               CLK : in STD_LOGIC;
               DATA_OUT : out STD_LOGIC_VECTOR (9 downto 0));
    end component;

    component ALU is
        Port ( SEL : in STD_LOGIC_VECTOR (3 downto 0);
               A : in STD_LOGIC_VECTOR (8 downto 0);
               B : in STD_LOGIC_VECTOR (8 downto 0);
               Cin : in STD_LOGIC;
               RESULT : out STD_LOGIC_VECTOR (7 downto 0);
               C : out STD_LOGIC;
               Z : out STD_LOGIC);
    end component;
    
    component FLAGS is
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
    end component;
    
    component PC_MUX is
    Port (FROM_IMMED : in std_logic_vector (9 downto 0);
          FROM_STACK : in std_logic_vector (9 downto 0);
          LAST_ADDR : in std_logic_vector (9 downto 0);
          PC_MUX_SEL : in std_logic_vector (1 downto 0);
          Din_MUX : out std_logic_vector (9 downto 0));
    end component;
    
    component ProgramCounter is
        Port ( DIN : in STD_LOGIC_VECTOR (9 downto 0);
               PC_LD : in STD_LOGIC;
               PC_INC : in STD_LOGIC;
               RST : in STD_LOGIC;
               CLK : in STD_LOGIC;
               PC_COUNT : out STD_LOGIC_VECTOR (9 downto 0));
    end component;
    
    component RAT_CNTRLR is
        Port ( C   : in STD_LOGIC;
               Z   : in STD_LOGIC;
               RST : in STD_LOGIC;
               --Interrupts are handled later
               INT : in STD_LOGIC;
               OPCODE_HI_5 : in STD_LOGIC_VECTOR(4 downto 0);
               OPCODE_LO_2 : in STD_LOGIC_VECTOR(1 downto 0); 
               CLK : in STD_LOGIC;
               --Interrupts are handled later
               I_SET : out STD_LOGIC;
               I_CLR : out STD_LOGIC;
               
               PC_LD : out STD_LOGIC;
               PC_INC : out STD_LOGIC;
               PC_MUX_SEL : out STD_LOGIC_VECTOR(1 downto 0);
               ALU_OPY_SEL : out STD_LOGIC;
               ALU_SEL : out STD_LOGIC_VECTOR(3 downto 0);
               RF_WR : out STD_LOGIC;
               RF_WR_SEL : out STD_LOGIC_VECTOR(1 downto 0);
               --Stack pointer is handled later
               SP_LD : out STD_LOGIC;
               SP_INCR : out STD_LOGIC;
               SP_DECR : out STD_LOGIC;
               SCR_WE : out STD_LOGIC;
               SCR_ADDR_SEL : out STD_LOGIC_VECTOR(1 downto 0);
               SCR_DATA_SEL : out STD_LOGIC;
               FLG_C_SET : out STD_LOGIC;
               FLG_C_CLR : out STD_LOGIC;
               FLG_C_LD : out STD_LOGIC;
               FLG_Z_LD : out STD_LOGIC;
               --Only dealing with simple flag module for now
               FLG_LD_SEL : out STD_LOGIC;
               FLG_SHDW_LD : out STD_LOGIC;
               SYS_RST : out STD_LOGIC;
               IO_STRB : out STD_LOGIC );
    end component;
    
    component REG_FILE is
        Port ( DIN : in STD_LOGIC_VECTOR (7 downto 0);
               ADRX : in STD_LOGIC_VECTOR (4 downto 0);
               ADRY : in STD_LOGIC_VECTOR (4 downto 0);
               RF_WR : in STD_LOGIC;
               CLK : in STD_LOGIC;
               DX_OUT : out STD_LOGIC_VECTOR (7 downto 0);
               DY_OUT : out STD_LOGIC_VECTOR (7 downto 0));
    end component;
    
    component prog_rom is
        Port ( ADDRESS : in std_logic_vector(9 downto 0); 
               INSTRUCTION : out std_logic_vector(17 downto 0); 
               CLK : in std_logic);  
    end component;
    
    signal romoutput : std_logic_vector(17 downto 0);
    signal pc_out, pcinput, scr_data_in, scr_out : std_logic_vector(9 downto 0);
    signal a_in, b_in : std_logic_vector(8 downto 0);
    signal regxout, regyout, aluresult, b_input, din_input, scr_addr_in, sp_out, sp_out_dec : std_logic_vector(7 downto 0);
    signal alusel : std_logic_vector(3 downto 0);
    signal pc_muxsel, rf_muxsel, scr_muxsel_addr : std_logic_vector(1 downto 0);
    signal c_out, z_out, cflg, zflg, pcld, pcinc, restart, alu_muxsel,s_shdw_ld, s_flg_ld_sel, rfset, cflg_set, cflg_clr, cflg_ld, zflg_ld, scr_muxsel_data, scr_set: std_logic;
    signal s_sp_ld, s_sp_incr, s_sp_decr : std_logic;
    signal s_int_cntrlr_in, s_i_clr, s_i_set : std_logic;
    signal r_int : std_logic := '0';
    
begin

    a_in <= '0' & regxout;
    b_in <= '0' & b_input;
    sp_out_dec <= sp_out - '1';
    
    s_int_cntrlr_in <= r_int AND INT; --AND gate with int_enable reg and external interrupt signal
--INTERRUPT REGISTER----------------------------------------
    int_reg : process(r_int, s_i_clr, s_i_set, clk) begin --Interrupt enable register set with signals from control unit
       if rising_edge(clk) then
          if s_i_set = '1' then r_int <= '1';
          elsif s_i_clr = '1' then r_int <= '0';
          else NULL;
          end if;
       else NULL;   
       end if;   
    end process int_reg;
--INTERNAL MUXES--------------------------------------------    

    alu_mux : process(alu_muxsel, regyout, romoutput)
    begin
        case alu_muxsel is
            when '0' => b_input <= regyout;
            when others => b_input <= romoutput(7 downto 0);
        end case;
    end process;
    
    --SCRATCH MUXES-----------------------------------------
    scr_data_mux : process(regxout, pc_out, scr_muxsel_data)
    begin
        case scr_muxsel_data is
            when '0' => scr_data_in <= ("00" & regxout);
            when others => scr_data_in <= pc_out;
        end case;
    end process;
    
    scr_addr_mux : process(regyout, romoutput,sp_out_dec, sp_out, scr_muxsel_addr)
    begin
        case scr_muxsel_addr is
            when "00" => scr_addr_in <= regyout;
            when "01" => scr_addr_in <= romoutput(7 downto 0);
            when "10" => scr_addr_in <= sp_out;
            when others => scr_addr_in <= sp_out_dec;
        end case;
    end process; 
    --REG_FILE MUX--------------------------------------------------------
    rf_mux : process(IN_PORT, aluresult, rf_muxsel, scr_out)
    begin
        case rf_muxsel is
            when "00" => din_input <= aluresult;
            when "01" => din_input <= scr_out(7 downto 0);
            when "10" => din_input <= "00000000";
            when others => din_input <= IN_PORT;
        end case;
    end process;    
    
-----COMPONENT INSTANTIATIONS--------------------------------------------
    SP : STACK_POINTER
    port map (DATA_IN   => regxout,
              LD => s_sp_ld,
              INCR => s_sp_incr,
              DECR => s_sp_decr,
              RST => RESET,
              CLK => CLK,
              DATA_OUT => sp_out);
             
              
    Scram : SCRATCH_RAM
    port map (DATA_IN => scr_data_in,
              SCR_ADDR => scr_addr_in,
              SCR_WE => scr_set,
              CLK => CLK,
              DATA_OUT => scr_out);
    
    ControlUnit : RAT_CNTRLR
    port map (C => cflg,
              Z => zflg,
              INT => s_int_cntrlr_in,
              RST => RESET,
              OPCODE_HI_5 => romoutput(17 downto 13),
              OPCODE_LO_2 => romoutput(1 downto 0),
              CLK => CLK,
              PC_LD => pcld,
              PC_INC => pcinc,
              PC_MUX_SEL => pc_muxsel,
              ALU_OPY_SEL => alu_muxsel,
              ALU_SEL => alusel,
              RF_WR => rfset,
              RF_WR_SEL => rf_muxsel,
              SCR_WE => scr_set,
              SCR_ADDR_SEL => scr_muxsel_addr,
              SCR_DATA_SEL => scr_muxsel_data,
              FLG_C_SET => cflg_set,
              FLG_C_CLR => cflg_clr,
              FLG_C_LD => cflg_ld,
              FLG_Z_LD => zflg_ld,
              FLG_SHDW_LD => s_shdw_ld,
              FLG_LD_SEL => s_flg_ld_sel,
              SYS_RST => restart,
              I_SET => s_i_set,
              I_CLR => s_i_clr,
              SP_LD   => s_sp_ld,
              SP_INCR => s_sp_incr,
              SP_DECR => s_sp_decr,
              IO_STRB => IO_STRB);

    ProgRom : prog_rom
    port map (ADDRESS => pc_out,
              INSTRUCTION => romoutput,
              CLK => CLK);
              
    REGFILE : REG_FILE
    port map (DIN => din_input,
              ADRX => romoutput(12 downto 8),
              ADRY => romoutput(7 downto 3),
              RF_WR => rfset,
              CLK => CLK,
              DX_OUT => regxout,
              DY_OUT => regyout);      

    PCMUX : PC_MUX
    port map (FROM_IMMED => romoutput(12 downto 3),
              FROM_STACK => scr_out,
              LAST_ADDR => "1111111111",
              PC_MUX_SEL => pc_muxsel,
              Din_MUX => pcinput);

    PC : ProgramCounter
    port map (DIN => pcinput,
              PC_INC => pcinc,
              PC_LD => pcld,
              RST => restart,
              CLK => CLK,
              PC_COUNT => pc_out);

    alu1 : ALU
    port map (SEL => alusel,
             A => a_in,
             B => b_in,
             Cin => cflg,
             RESULT => aluresult,
             C => c_out,
             Z => z_out);
             
    flagging : FLAGS
    port map (FLG_C_SET => cflg_set,
              FLG_C_CLR => cflg_clr,
              FLG_C_LD => cflg_ld,
              FLG_Z_LD => zflg_ld,
              CLK => CLK,
              FLG_SHAD_LD => s_shdw_ld,
              FLG_LD_SEL =>  s_flg_ld_sel,
              C => c_out,
              Z => z_out,
              C_FLG => cflg,
              Z_FLG => zflg);          
             
    OUT_PORT <= regxout;         
    PORT_ID <= romoutput(7 downto 0);
             
end Behavioral;

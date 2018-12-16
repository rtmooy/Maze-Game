-----------------------------------------------------------------------------
-- Definition of a single port ROM for RATASM defined by prog_rom.psm 
--  
-- Generated by RATASM Assembler 
--  
-- Standard IEEE libraries  
--  
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library unisim;
use unisim.vcomponents.all;
-----------------------------------------------------------------------------


entity prog_rom is 
   port (     ADDRESS : in std_logic_vector(9 downto 0); 
          INSTRUCTION : out std_logic_vector(17 downto 0); 
                  CLK : in std_logic);  
end prog_rom;



architecture low_level_definition of prog_rom is

   -----------------------------------------------------------------------------
   -- Attributes to define ROM contents during implementation synthesis. 
   -- The information is repeated in the generic map for functional simulation. 
   -----------------------------------------------------------------------------

   attribute INIT_00 : string; 
   attribute INIT_01 : string; 
   attribute INIT_02 : string; 
   attribute INIT_03 : string; 
   attribute INIT_04 : string; 
   attribute INIT_05 : string; 
   attribute INIT_06 : string; 
   attribute INIT_07 : string; 
   attribute INIT_08 : string; 
   attribute INIT_09 : string; 
   attribute INIT_0A : string; 
   attribute INIT_0B : string; 
   attribute INIT_0C : string; 
   attribute INIT_0D : string; 
   attribute INIT_0E : string; 
   attribute INIT_0F : string; 
   attribute INIT_10 : string; 
   attribute INIT_11 : string; 
   attribute INIT_12 : string; 
   attribute INIT_13 : string; 
   attribute INIT_14 : string; 
   attribute INIT_15 : string; 
   attribute INIT_16 : string; 
   attribute INIT_17 : string; 
   attribute INIT_18 : string; 
   attribute INIT_19 : string; 
   attribute INIT_1A : string; 
   attribute INIT_1B : string; 
   attribute INIT_1C : string; 
   attribute INIT_1D : string; 
   attribute INIT_1E : string; 
   attribute INIT_1F : string; 
   attribute INIT_20 : string; 
   attribute INIT_21 : string; 
   attribute INIT_22 : string; 
   attribute INIT_23 : string; 
   attribute INIT_24 : string; 
   attribute INIT_25 : string; 
   attribute INIT_26 : string; 
   attribute INIT_27 : string; 
   attribute INIT_28 : string; 
   attribute INIT_29 : string; 
   attribute INIT_2A : string; 
   attribute INIT_2B : string; 
   attribute INIT_2C : string; 
   attribute INIT_2D : string; 
   attribute INIT_2E : string; 
   attribute INIT_2F : string; 
   attribute INIT_30 : string; 
   attribute INIT_31 : string; 
   attribute INIT_32 : string; 
   attribute INIT_33 : string; 
   attribute INIT_34 : string; 
   attribute INIT_35 : string; 
   attribute INIT_36 : string; 
   attribute INIT_37 : string; 
   attribute INIT_38 : string; 
   attribute INIT_39 : string; 
   attribute INIT_3A : string; 
   attribute INIT_3B : string; 
   attribute INIT_3C : string; 
   attribute INIT_3D : string; 
   attribute INIT_3E : string; 
   attribute INIT_3F : string; 
   attribute INITP_00 : string; 
   attribute INITP_01 : string; 
   attribute INITP_02 : string; 
   attribute INITP_03 : string; 
   attribute INITP_04 : string; 
   attribute INITP_05 : string; 
   attribute INITP_06 : string; 
   attribute INITP_07 : string; 


   ----------------------------------------------------------------------
   -- Attributes to define ROM contents during implementation synthesis.
   ----------------------------------------------------------------------

   attribute INIT_00 of ram_1024_x_18 : label is "66E04141403989518DD9661E680167018D898C096604800A00002020A0010000";  
   attribute INIT_01 of ram_1024_x_18 : label is "8801811B1E02807887018DD9870180EB1E0166E0807A1601817A1C0485C98DD9";  
   attribute INIT_02 of ram_1024_x_18 : label is "66008078C7018DD9C701826B1E048078C8018DD9C801814B1E03807888018DD9";  
   attribute INIT_03 of ram_1024_x_18 : label is "8E3988018801807A0BE08E39C8018701807A0BE08E39C70182821D0189198DD9";  
   attribute INIT_04 of ram_1024_x_18 : label is "8D418278661F82786603827866E08280C701807A0BE08E398701C801807A0BE0";  
   attribute INIT_05 of ram_1024_x_18 : label is "832182A21702802A1701A0007B0077008DD9661E680167018DD94809470166F8";  
   attribute INIT_06 of ram_1024_x_18 : label is "88018DD96600A003845A1B1D83E21B1C836A1B2384D21B1BA0033B4482D8A000";  
   attribute INIT_07 of ram_1024_x_18 : label is "9001C8018DD96600A0037B0077008DD983E20850661E855A1702854A17019001";  
   attribute INIT_08 of ram_1024_x_18 : label is "17019001C7018DD96600A0037B0077008DD9836A08FF661E855A1702854A1701";  
   attribute INIT_09 of ram_1024_x_18 : label is "170190018701661E8DD96600A0037B0077008DD984D207FF661E855A1702854A";  
   attribute INIT_0A of ram_1024_x_18 : label is "A0028DD9C701A0027702A0027701A0037B0077008DD9845A073C855A1702854A";  
   attribute INIT_0B of ram_1024_x_18 : label is "8B01554154397E0076006A007C00A0028DD98701A0028DD98801A0028DD9C801";  
   attribute INIT_0C of ram_1024_x_18 : label is "88720BE088720B008E398702824887EA1F0387621F0286DA1F0186521F004AF9";  
   attribute INIT_0D of ram_1024_x_18 : label is "0BE088720B008E398802800248A947A17E01887216018EF986A00BFF88720B04";  
   attribute INIT_0E of ram_1024_x_18 : label is "88720B008E39C802800248A947A17E02887216018EF987280BFF88720B048872";  
   attribute INIT_0F of ram_1024_x_18 : label is "0B008E39C702800248A947A17E03887216018EF987B00BFF88720B0488720BE0";  
   attribute INIT_10 of ram_1024_x_18 : label is "47A19C01800248A947A17E04887216018EF988380BFF88720B0488720BE08872";  
   attribute INIT_11 of ram_1024_x_18 : label is "826887EA0A0387620A0286DA0A0186520A006A0088BB0A048A0189021C0448A9";  
   attribute INIT_12 of ram_1024_x_18 : label is "6804673989CB1F0066FF8B0180027D01894B4808894B47007D00800248A947A1";  
   attribute INIT_13 of ram_1024_x_18 : label is "67038EC9694B680467398A331F018002671E68288E996938683C67038EC9694B";  
   attribute INIT_14 of ram_1024_x_18 : label is "8E996937683C67038EC9694B680467038A9B1F028002671E68298E9969376803";  
   attribute INIT_15 of ram_1024_x_18 : label is "8002671F68298E996937680367038EC9694B68046703824B1F038002671F6828";  
   attribute INIT_16 of ram_1024_x_18 : label is "80027F0082488BA2ABA01FFF8B92AB901FC08B82AB801F808B72AB701F403F0F";  
   attribute INIT_17 of ram_1024_x_18 : label is "8DD9C8018DD987018DD988018DD966F8671E682880027F0380027F0280027F01";  
   attribute INIT_18 of ram_1024_x_18 : label is "68008C4B073C87018EC9694F680067388C13070487018EC9694F680067008002";  
   attribute INIT_19 of ram_1024_x_18 : label is "6D0066FF80028CBB085088018E99693B6700684C8C83080488018E99693B6700";  
   attribute INIT_1A of ram_1024_x_18 : label is "8D4B0D3B8D018EC9694F680047696D0080028D030D3B8D018EC9694F68004769";  
   attribute INIT_1B of ram_1024_x_18 : label is "0401043F057F4541443980028D9B0D388D018EC9694B680447696D0466FF8002";  
   attribute INIT_1C of ram_1024_x_18 : label is "2B9344904591AE880401043F057F454144398E0825808002469244904591AE28";  
   attribute INIT_1D of ram_1024_x_18 : label is "760080028ED3484888018DD9890180028EA3474887018DD989018E6825808002";  
   attribute INIT_1E of ram_1024_x_18 : label is "8E39880188018FEA0B008FEA0BE08E39C80187018FEA0B008FEA0BE08E39C701";  
   attribute INIT_1F of ram_1024_x_18 : label is "8002800276018FF8C7018FEA0B008FEA0BE08E398701C8018FEA0B008FEA0BE0";  
   attribute INIT_20 of ram_1024_x_18 : label is "25808002855A0BFF854A1D0189192B9344904591B0780401043F057F45414439";  
   attribute INIT_21 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000009030";  
   attribute INIT_22 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_23 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_24 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_25 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_26 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_27 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_28 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_29 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_2A of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_2B of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_2C of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_2D of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_2E of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_2F of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_30 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_31 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_32 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_33 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_34 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_35 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_36 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_37 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_38 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_39 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_3A of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_3B of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_3C of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_3D of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_3E of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INIT_3F of ram_1024_x_18 : label is "8310000000000000000000000000000000000000000000000000000000000000";  
   attribute INITP_00 of ram_1024_x_18 : label is "237C3CCC8D3333710CDF3F030CCC8CA328CA3230C88C88C88C88F330C03F0CF4";  
   attribute INITP_01 of ram_1024_x_18 : label is "C90CC333324330CCCC90CC333320CCCC03FD249249DDF0CCCB37C3CCC8DF0F33";  
   attribute INITP_02 of ram_1024_x_18 : label is "2223F7777030C30F7CFCFCDF3F3F37CFCFCDF3F3F3C700D00CCCF38C24330CCC";  
   attribute INITP_03 of ram_1024_x_18 : label is "5C8CCA3328CCA332D0890889FC6809FC68138F3D38F34E3CF4E3F38FCE3F38FD";  
   attribute INITP_04 of ram_1024_x_18 : label is "000000000000000000000000000000000000000000000000000000009333F1A0";  
   attribute INITP_05 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INITP_06 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  
   attribute INITP_07 of ram_1024_x_18 : label is "0000000000000000000000000000000000000000000000000000000000000000";  


begin

   ----------------------------------------------------------------------
   --Instantiate the Xilinx primitive for a block RAM 
   --INIT values repeated to define contents for functional simulation 
   ----------------------------------------------------------------------
   ram_1024_x_18: RAMB16_S18 
   --synthesitranslate_off
   --INIT values repeated to define contents for functional simulation
   generic map ( 
          INIT_00 => X"66E04141403989518DD9661E680167018D898C096604800A00002020A0010000",  
          INIT_01 => X"8801811B1E02807887018DD9870180EB1E0166E0807A1601817A1C0485C98DD9",  
          INIT_02 => X"66008078C7018DD9C701826B1E048078C8018DD9C801814B1E03807888018DD9",  
          INIT_03 => X"8E3988018801807A0BE08E39C8018701807A0BE08E39C70182821D0189198DD9",  
          INIT_04 => X"8D418278661F82786603827866E08280C701807A0BE08E398701C801807A0BE0",  
          INIT_05 => X"832182A21702802A1701A0007B0077008DD9661E680167018DD94809470166F8",  
          INIT_06 => X"88018DD96600A003845A1B1D83E21B1C836A1B2384D21B1BA0033B4482D8A000",  
          INIT_07 => X"9001C8018DD96600A0037B0077008DD983E20850661E855A1702854A17019001",  
          INIT_08 => X"17019001C7018DD96600A0037B0077008DD9836A08FF661E855A1702854A1701",  
          INIT_09 => X"170190018701661E8DD96600A0037B0077008DD984D207FF661E855A1702854A",  
          INIT_0A => X"A0028DD9C701A0027702A0027701A0037B0077008DD9845A073C855A1702854A",  
          INIT_0B => X"8B01554154397E0076006A007C00A0028DD98701A0028DD98801A0028DD9C801",  
          INIT_0C => X"88720BE088720B008E398702824887EA1F0387621F0286DA1F0186521F004AF9",  
          INIT_0D => X"0BE088720B008E398802800248A947A17E01887216018EF986A00BFF88720B04",  
          INIT_0E => X"88720B008E39C802800248A947A17E02887216018EF987280BFF88720B048872",  
          INIT_0F => X"0B008E39C702800248A947A17E03887216018EF987B00BFF88720B0488720BE0",  
          INIT_10 => X"47A19C01800248A947A17E04887216018EF988380BFF88720B0488720BE08872",  
          INIT_11 => X"826887EA0A0387620A0286DA0A0186520A006A0088BB0A048A0189021C0448A9",  
          INIT_12 => X"6804673989CB1F0066FF8B0180027D01894B4808894B47007D00800248A947A1",  
          INIT_13 => X"67038EC9694B680467398A331F018002671E68288E996938683C67038EC9694B",  
          INIT_14 => X"8E996937683C67038EC9694B680467038A9B1F028002671E68298E9969376803",  
          INIT_15 => X"8002671F68298E996937680367038EC9694B68046703824B1F038002671F6828",  
          INIT_16 => X"80027F0082488BA2ABA01FFF8B92AB901FC08B82AB801F808B72AB701F403F0F",  
          INIT_17 => X"8DD9C8018DD987018DD988018DD966F8671E682880027F0380027F0280027F01",  
          INIT_18 => X"68008C4B073C87018EC9694F680067388C13070487018EC9694F680067008002",  
          INIT_19 => X"6D0066FF80028CBB085088018E99693B6700684C8C83080488018E99693B6700",  
          INIT_1A => X"8D4B0D3B8D018EC9694F680047696D0080028D030D3B8D018EC9694F68004769",  
          INIT_1B => X"0401043F057F4541443980028D9B0D388D018EC9694B680447696D0466FF8002",  
          INIT_1C => X"2B9344904591AE880401043F057F454144398E0825808002469244904591AE28",  
          INIT_1D => X"760080028ED3484888018DD9890180028EA3474887018DD989018E6825808002",  
          INIT_1E => X"8E39880188018FEA0B008FEA0BE08E39C80187018FEA0B008FEA0BE08E39C701",  
          INIT_1F => X"8002800276018FF8C7018FEA0B008FEA0BE08E398701C8018FEA0B008FEA0BE0",  
          INIT_20 => X"25808002855A0BFF854A1D0189192B9344904591B0780401043F057F45414439",  
          INIT_21 => X"0000000000000000000000000000000000000000000000000000000000009030",  
          INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INIT_3F => X"8310000000000000000000000000000000000000000000000000000000000000",  
          INITP_00 => X"237C3CCC8D3333710CDF3F030CCC8CA328CA3230C88C88C88C88F330C03F0CF4",  
          INITP_01 => X"C90CC333324330CCCC90CC333320CCCC03FD249249DDF0CCCB37C3CCC8DF0F33",  
          INITP_02 => X"2223F7777030C30F7CFCFCDF3F3F37CFCFCDF3F3F3C700D00CCCF38C24330CCC",  
          INITP_03 => X"5C8CCA3328CCA332D0890889FC6809FC68138F3D38F34E3CF4E3F38FCE3F38FD",  
          INITP_04 => X"000000000000000000000000000000000000000000000000000000009333F1A0",  
          INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",  
          INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")  


   --synthesis translate_on
   port map(  DI => "0000000000000000",
             DIP => "00",
              EN => '1',
              WE => '0',
             SSR => '0',
             CLK => clk,
            ADDR => address,
              DO => INSTRUCTION(15 downto 0),
             DOP => INSTRUCTION(17 downto 16)); 

--
end low_level_definition;
--
----------------------------------------------------------------------
-- END OF FILE prog_rom.vhd
----------------------------------------------------------------------
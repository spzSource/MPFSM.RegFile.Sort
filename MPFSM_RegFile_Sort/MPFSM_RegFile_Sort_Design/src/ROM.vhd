library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use commands.all;

entity MicroROM is
	port(
		read_enable : in  std_logic;
		address     : in  std_logic_vector(7 downto 0);
		data_output : out std_logic_vector(27 downto 0)
		);
end MicroROM;

architecture MicroROM_Behaviour of MicroROM is
	subtype ram_address is std_logic_vector(7 downto 0);
	subtype op_code is std_logic_vector(3 downto 0);
	
	--
	-- type and sub-types declarations
	-- 
	subtype instruction is std_logic_vector(27 downto 0);
	type ROM_type is array (0 to 255) of instruction;
	
	constant I_ADDR_MAX      : ram_address := "00000101";
	constant J_ADDR_MAX      : ram_address := "00000110";
	constant I_ADDR          : ram_address := "00000111";
	constant J_ADDR          : ram_address := "00001000";

	constant ONE_ADDR        : ram_address := "00001001";
	constant ZERO_ADDR       : ram_address := "00001010";

	constant TEMP_1_ADDR     : ram_address := "00001011";
	constant TEMP_2_ADDR     : ram_address := "00001100";
	constant TEMP_3_ADDR     : ram_address := "00001101";

	constant Z_ADDR          : ram_address := "11111111";

	--
	-- Represents the set of instructions as read only (constant) memory.
	--
	constant ROM : ROM_type := (
		ADD_OP      & ZERO_ADDR   & ZERO_ADDR   & I_ADDR,			-- 00000000
		ADD_OP      & ZERO_ADDR   & ONE_ADDR    & J_ADDR,			-- 00000001
		
		SUB_OP      & I_ADDR_MAX  & I_ADDR      & TEMP_1_ADDR,		-- 00000010
		JZ_OP       & "00010011"  & Z_ADDR      & Z_ADDR,	    	-- 00000011

		ADD_OP      & ONE_ADDR    & I_ADDR      & J_ADDR,			-- 00000100
		SUB_OP      & J_ADDR_MAX  & J_ADDR      & TEMP_1_ADDR,		-- 00000101
		JZ_OP       & "00010000"  & Z_ADDR      & Z_ADDR,	     	-- 00000110

		COPYINTO_OP & I_ADDR      & Z_ADDR      & TEMP_1_ADDR,		-- 00000111
		COPYINTO_OP & J_ADDR      & Z_ADDR      & TEMP_2_ADDR,		-- 00001000
		SUB_OP      & TEMP_2_ADDR & TEMP_1_ADDR & TEMP_3_ADDR,		-- 00001001
		JNSB_OP     & "00001101"  & Z_ADDR      & Z_ADDR,		    -- 00001010

		COPYTOIN_OP & TEMP_1_ADDR & J_ADDR      & Z_ADDR,	    	-- 00001011
		COPYTOIN_OP & TEMP_2_ADDR & I_ADDR      & Z_ADDR,		    -- 00001100

		ADD_OP      & J_ADDR      & ONE_ADDR    & J_ADDR,			-- 00001101
		ADD_OP      & ZERO_ADDR   & ZERO_ADDR   & ZERO_ADDR,		-- 00001110
		JZ_OP       & "00000101"  & Z_ADDR      & Z_ADDR,	    	-- 00001111

		ADD_OP      & I_ADDR      & ONE_ADDR    & I_ADDR,			-- 00010000
		ADD_OP      & ZERO_ADDR   & ZERO_ADDR   & ZERO_ADDR,		-- 00010001
		JZ_OP       & "00000010"  & Z_ADDR      & Z_ADDR,    		-- 00010010

		others => HALT_OP    & "00000000" & "00000000" & "00000000"
	);
	
	signal data : instruction;
begin
	--
	-- Move instruction to the output by specified address
	-- 
	data <= ROM(CONV_INTEGER(address));
	
	TRISTATE_BUFFERS : process(read_enable, data)
	begin
		if (read_enable = '1') then
			data_output <= data;
		else
			data_output <= (others => 'Z');
		end if;
	end process;
	
end MicroROM_Behaviour;


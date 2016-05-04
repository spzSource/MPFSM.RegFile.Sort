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

	--
	-- Represents the set of instructions as read only (constant) memory.
	--
	constant ROM : ROM_type := (
		ADD_OP & "00000000" & "00000001" & "11111111",
		others => (instruction'range => '0')
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

		
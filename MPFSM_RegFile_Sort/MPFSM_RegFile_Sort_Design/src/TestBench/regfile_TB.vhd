library ieee;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity regfile_tb is
	-- Generic declarations of the tested unit
		generic(
		INITREG_T : STD_LOGIC_VECTOR := "00000000";
		ADDRESS_BIT_SIZE_T : INTEGER := 8 );
end regfile_tb;

architecture TB_ARCHITECTURE of regfile_tb is
	-- Component declaration of the tested unit
	component regfile
		generic(
		INITREG_T : STD_LOGIC_VECTOR := "00000000";
		ADDRESS_BIT_SIZE_T : INTEGER := 8 );
	port(
		init : in STD_LOGIC;
		write_data_port : in STD_LOGIC_VECTOR(INITREG_T'range);
		write_address : in STD_LOGIC_VECTOR(ADDRESS_BIT_SIZE_T-1 downto 0);
		read_data_port_1 : out STD_LOGIC_VECTOR(INITREG_T'range);
		read_data_port_2 : out STD_LOGIC_VECTOR(INITREG_T'range);
		read_address_1 : in STD_LOGIC_VECTOR(ADDRESS_BIT_SIZE_T-1 downto 0);
		read_address_2 : in STD_LOGIC_VECTOR(ADDRESS_BIT_SIZE_T-1 downto 0);
		write_enabled : in STD_LOGIC );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal init : STD_LOGIC;
	signal write_data_port : STD_LOGIC_VECTOR(INITREG_T'range);
	signal write_address : STD_LOGIC_VECTOR(ADDRESS_BIT_SIZE_T-1 downto 0);
	signal read_address_1 : STD_LOGIC_VECTOR(ADDRESS_BIT_SIZE_T-1 downto 0);
	signal read_address_2 : STD_LOGIC_VECTOR(ADDRESS_BIT_SIZE_T-1 downto 0);
	signal write_enabled : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal read_data_port_1 : STD_LOGIC_VECTOR(INITREG_T'range);
	signal read_data_port_2 : STD_LOGIC_VECTOR(INITREG_T'range);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : regfile
		generic map (
			INITREG_T => INITREG_T,
			ADDRESS_BIT_SIZE_T => ADDRESS_BIT_SIZE_T
		)

		port map (
			init => init,
			write_data_port => write_data_port,
			write_address => write_address,
			read_data_port_1 => read_data_port_1,
			read_data_port_2 => read_data_port_2,
			read_address_1 => read_address_1,
			read_address_2 => read_address_2,
			write_enabled => write_enabled
		);	
		
	MAIN : process
	begin
		init <= '1';
		wait for 10ns;
		init <= '0';
		wait for 10ns;
		
		write_data_port <= "00000111";
		write_address <= "00000010";
		write_enabled <= '1';
		
		wait for 10ns;
		
		write_enabled <= '0';
		wait;
		
	end process;

	-- Add your stimulus here ...

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_regfile of regfile_tb is
	for TB_ARCHITECTURE
		for UUT : regfile
			use entity work.regfile(beh_regfile);
		end for;
	end for;
end TESTBENCH_FOR_regfile;


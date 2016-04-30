library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity REGFile is
	generic(INITREG_T          : std_logic_vector := "00000000";
		    ADDRESS_BIT_SIZE_T : integer          := 4);
	port(
		init             : in  std_logic;
		write_data_port  : in  std_logic_vector(INITREG_T'range);
		write_address    : in  std_logic_vector(ADDRESS_BIT_SIZE_T - 1 downto 0);
		read_data_port_1 : out std_logic_vector(INITREG_T'range);
		read_data_port_2 : out std_logic_vector(INITREG_T'range);
		read_address_1   : in  std_logic_vector(ADDRESS_BIT_SIZE_T - 1 downto 0);
		read_address_2   : in  std_logic_vector(ADDRESS_BIT_SIZE_T - 1 downto 0);
		write_enabled    : in  std_logic);
end REGFile;

architecture beh_regfile of REGFile is
	component REGn is
		generic(INITIAL : std_logic_vector := "00000000");

		port(data_input     : in  std_logic_vector(INITIAL'range);
			 enabled        : in  std_logic;
			 init           : in  std_logic;
			 clk            : in  std_logic;
			 output_enabled : in  std_logic;
			 data_output    : out std_logic_vector(INITIAL'range));
	end component;

	signal write_enabled_flags : std_logic_vector(2 ** ADDRESS_BIT_SIZE_T - 1 downto 0);
	signal read_enabled_flags  : std_logic_vector(2 ** ADDRESS_BIT_SIZE_T - 1 downto 0);
	signal read_data_1         : std_logic_vector(INITREG_T'range);
	signal read_data_2         : std_logic_vector(INITREG_T'range);

begin
	WRITE_ADDRESS_DECODER : process(write_address)
	begin
		for i in 0 to 2 ** ADDRESS_BIT_SIZE_T - 1 loop
			if i = CONV_INTEGER(write_address) then
				write_enabled_flags(i) <= '1';
			else
				write_enabled_flags(i) <= '0';
			end if;
		end loop;
	end process;

	READ_ADDRESS_DECODER : process(read_address_1, read_address_2)
	begin
		for i in 0 to 2 ** ADDRESS_BIT_SIZE_T - 1 loop
			if i = CONV_INTEGER(read_address_1) or i = CONV_INTEGER(read_address_2) then
				read_enabled_flags(i) <= '1';
			else
				read_enabled_flags(i) <= '0';
			end if;
		end loop;
	end process;

	REGi : for i in 2 ** ADDRESS_BIT_SIZE_T - 1 downto 0 generate
		REGii : REGn generic map(INITIAL => INITREG_T)
			port map(
				write_data_port,
				write_enabled_flags(i),
				init,
				write_enabled,
				read_enabled_flags(i),
				read_data_1
			);
		REGij :	REGn generic map(INITIAL => INITREG_T)
			port map(
				write_data_port,
				write_enabled_flags(i),
				init,
				write_enabled,
				read_enabled_flags(i),
				read_data_2
			); 
	end generate;

	read_data_port_1 <= read_data_1;
	read_data_port_2 <= read_data_2;

end beh_regfile;
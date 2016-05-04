library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity MicroProcessor is
	generic(INITREG_T          : std_logic_vector := "00000000";
		    ADDRESS_BIT_SIZE_T : integer          := 8);
	port(
		clk   : in  std_logic;
		rst   : in  std_logic;
		start : in  std_logic;
		stop  : out std_logic
	);
end MicroProcessor;

architecture MicroProcessor_Behavioural of MicroProcessor is
	component MicroROM is
		port(
			read_enable : in  std_logic;
			address     : in  std_logic_vector(5 downto 0);
			data_output : out std_logic_vector(27 downto 0)
		);
	end component;

	component REGFile is
		generic(INITREG_T          : std_logic_vector := "00000000";
			    ADDRESS_BIT_SIZE_T : integer          := 6);
		port(
			init             : in  std_logic;
			write_data_port  : in  std_logic_vector(INITREG_T'range);
			write_address    : in  std_logic_vector(ADDRESS_BIT_SIZE_T - 1 downto 0);
			read_data_port_1 : out std_logic_vector(INITREG_T'range);
			read_data_port_2 : out std_logic_vector(INITREG_T'range);
			read_address_1   : in  std_logic_vector(ADDRESS_BIT_SIZE_T - 1 downto 0);
			read_address_2   : in  std_logic_vector(ADDRESS_BIT_SIZE_T - 1 downto 0);
			write_enabled    : in  std_logic);
	end component;

	component Datapath is
		port(
			enabled              : in  std_logic;
			operation_code       : in  std_logic_vector(3 downto 0);
			operand_1            : in  std_logic_vector(7 downto 0);
			operand_2            : in  std_logic_vector(7 downto 0);
			result               : out std_logic_vector(7 downto 0);
			zero_flag            : out std_logic;
			significant_bit_flag : out std_logic
		);
	end component;

	component Controller is
		port(
			clk                           : in  std_logic;
			rst                           : in  std_logic;
			start                         : in  std_logic;
			stop                          : out std_logic;

			rom_enabled                   : out std_logic;
			rom_address                   : out std_logic_vector(5 downto 0);
			rom_data_output               : in  std_logic_vector(27 downto 0);

			ram_init                      : out std_logic;
			ram_write_enabled             : out std_logic;
			ram_write_data_port           : out std_logic_vector(7 downto 0);
			ram_write_address             : out std_logic_vector(7 downto 0);
			ram_read_data_port_1          : in  std_logic_vector(7 downto 0);
			ram_read_data_port_2          : in  std_logic_vector(7 downto 0);
			ram_read_address_1            : out std_logic_vector(7 downto 0);
			ram_read_address_2            : out std_logic_vector(7 downto 0);

			datapath_enabled              : out std_logic;
			datapath_operation_code       : out std_logic_vector(3 downto 0);
			datapath_operand_1            : out std_logic_vector(7 downto 0);
			datapath_operand_2            : out std_logic_vector(7 downto 0);
			datapath_result               : in  std_logic_vector(7 downto 0);
			datapath_zero_flag            : in  std_logic;
			datapath_significant_bit_flag : in  std_logic
		);
	end component;

	signal mp_ram_init             : std_logic;
	signal mp_ram_write_data_port  : std_logic_vector(INITREG_T'range);
	signal mp_ram_write_address    : std_logic_vector(ADDRESS_BIT_SIZE_T - 1 downto 0);
	signal mp_ram_read_data_port_1 : std_logic_vector(INITREG_T'range);
	signal mp_ram_read_data_port_2 : std_logic_vector(INITREG_T'range);
	signal mp_ram_read_address_1   : std_logic_vector(ADDRESS_BIT_SIZE_T - 1 downto 0);
	signal mp_ram_read_address_2   : std_logic_vector(ADDRESS_BIT_SIZE_T - 1 downto 0);
	signal mp_ram_write_enabled    : std_logic;

	signal mp_rom_read_enable : std_logic;
	signal mp_rom_address     : std_logic_vector(5 downto 0);
	signal mp_rom_data_output : std_logic_vector(27 downto 0);

	signal mp_datapath_enabled              : std_logic;
	signal mp_datapath_operation_code       : std_logic_vector(3 downto 0);
	signal mp_datapath_operand_1            : std_logic_vector(7 downto 0);
	signal mp_datapath_operand_2            : std_logic_vector(7 downto 0);
	signal mp_datapath_result               : std_logic_vector(7 downto 0);
	signal mp_datapath_zero_flag            : std_logic;
	signal mp_datapath_significant_bit_flag : std_logic;

begin
	U_RAM : entity REGFile port map(
			init             => mp_ram_init,
			write_data_port  => mp_ram_write_data_port,
			write_address    => mp_ram_write_address,
			read_data_port_1 => mp_ram_read_data_port_1,
			read_data_port_2 => mp_ram_read_data_port_2,
			read_address_1   => mp_ram_read_address_1,
			read_address_2   => mp_ram_read_address_2,
			write_enabled    => mp_ram_write_enabled
		);

	U_ROM : entity MicroROM port map(
			read_enable => mp_rom_read_enable,
			address     => mp_rom_address,
			data_output => mp_rom_data_output
		);
	U_DATAPATH : Datapath port map(
			enabled              => mp_datapath_enabled,
			operation_code       => mp_datapath_operation_code,
			operand_1            => mp_datapath_operand_1,
			operand_2            => mp_datapath_operand_2,
			result               => mp_datapath_result,
			zero_flag            => mp_datapath_zero_flag,
			significant_bit_flag => mp_datapath_significant_bit_flag
		);
	U_CONTROLLER : Controller port map(
			clk                           => clk,
			rst                           => rst,
			start                         => start,
			stop                          => stop,
			rom_enabled                   => mp_rom_read_enable,
			rom_address                   => mp_rom_address,
			rom_data_output               => mp_rom_data_output,
			ram_init                      => mp_ram_init,
			ram_write_enabled             => mp_ram_write_enabled,
			ram_write_data_port           => mp_ram_write_data_port,
			ram_write_address             => mp_ram_write_address,
			ram_read_data_port_1          => mp_ram_read_data_port_1,
			ram_read_data_port_2          => mp_ram_read_data_port_2,
			ram_read_address_1            => mp_ram_read_address_1,
			ram_read_address_2            => mp_ram_read_address_2,
			datapath_enabled              => mp_datapath_enabled,
			datapath_operation_code       => mp_datapath_operation_code,
			datapath_operand_1            => mp_datapath_operand_1,
			datapath_operand_2            => mp_datapath_operand_2,
			datapath_result               => mp_datapath_result,
			datapath_zero_flag            => mp_datapath_zero_flag,
			datapath_significant_bit_flag => mp_datapath_significant_bit_flag
		);

end MicroProcessor_Behavioural;

		
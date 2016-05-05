library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity MRAM is
	port(
		read_write       : in  std_logic;
		clk              : in  std_logic;
		read_address_1   : in  std_logic_vector(7 downto 0);
		read_address_2   : in  std_logic_vector(7 downto 0);
		write_address    : in  std_logic_vector(7 downto 0);
		read_data_port_1 : out std_logic_vector(7 downto 0);
		read_data_port_2 : out std_logic_vector(7 downto 0);
		write_data_port  : in  std_logic_vector(7 downto 0)
	);
end MRAM;

architecture Beh_GPR of MRAM is
	subtype byte is std_logic_vector(7 downto 0);
	type RAM_t is array (0 to 255) of byte;

	--
	-- Initial state for memory
	--
	signal RAM : RAM_t := (
		"00000101",                     -- 5	a[0]  
		"00000011",                     -- 3	a[1]
		"00000001",                     -- 1	a[2]
		"00000100",                     -- 4	a[3]

		"00000000",                     -- 0	a[4]  [-]
		"00000011",                     -- 3    a[5]  outer loop: max index value
		"00000100",                     -- 4	a[6]  inner loop: max index value

		"00000000",                     -- 0	a[7]  outer loop: current index
		"00000000",                     -- 0	a[8]  inner loop: current index    

		"00000001",                     -- 1	a[9]  constant one = 1	  
		"00000000",                     -- 0    a[10] constant zero = 0

		"00000000",                     -- 0    a[11] reserved cell (temp 1)
		"00000000",                     -- 0   	a[12] reserved cell (temp 2) 

		others => "00000000"
	);

	signal data_win  : byte;
	signal data_1out : byte;
	signal data_2out : byte;
Begin
	data_win <= write_data_port;

	WRITE : process(clk)
	begin
		if (rising_edge(clk)) then
			if (read_write = '0') then
				RAM(conv_integer(write_address)) <= data_win;
			end if;
		end if;
	end process;

	data_1out <= RAM(conv_integer(read_address_1));
	data_2out <= RAM(conv_integer(read_address_2));

	READ : process(clk)
	begin
		if (rising_edge(clk)) then
			if (read_write = '1') then
				read_data_port_1 <= data_1out;
				read_data_port_2 <= data_2out;
			else
				read_data_port_1 <= (others => 'Z');
				read_data_port_2 <= (others => 'Z');
			end if;
		end if;
	end process;
End Beh_GPR;
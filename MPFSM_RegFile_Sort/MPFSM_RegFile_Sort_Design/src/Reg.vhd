library ieee;
use ieee.std_logic_1164.all;

entity REGn is
	generic(INITIAL : std_logic_vector := "00000000");

	port(
		data_input     : in  std_logic_vector(INITIAL'range);
		enabled        : in  std_logic;
		init           : in  std_logic;
		clk            : in  std_logic;
		output_enabled : in  std_logic;
		data_output    : out std_logic_vector(INITIAL'range));
end REGn;

architecture beh_regn of REGn is
	signal reg : std_logic_vector(INITIAL'range);
begin
	MAIN : process(data_input, enabled, init, clk)
	begin
		if init = '1' then
			reg <= INITIAL;
		elsif enabled = '1' then
			if rising_edge(clk) then
				reg <= data_input;
			end if;
		end if;
	end process;

	data_output <= reg when output_enabled = '0' else (others => 'Z');
end beh_regn;
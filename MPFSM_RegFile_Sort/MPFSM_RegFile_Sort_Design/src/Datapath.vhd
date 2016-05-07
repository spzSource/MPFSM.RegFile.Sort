library ieee;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use commands.all;

entity Datapath is
	port(
		enabled              : in  std_logic;
		operation_code       : in  std_logic_vector(3 downto 0);
		operand_1            : in  std_logic_vector(7 downto 0);
		operand_2            : in  std_logic_vector(7 downto 0);
		result               : out std_logic_vector(7 downto 0);
		zero_flag            : out std_logic;
		significant_bit_flag : out std_logic
	);
end entity Datapath;

architecture Datapath_Behavioural of Datapath is
	signal op_result                   : std_logic_vector(7 downto 0);
	signal add_result                  : std_logic_vector(7 downto 0);
	signal sub_result                  : std_logic_vector(7 downto 0);
	signal mov_result                  : std_logic_vector(7 downto 0);
	signal result_zero_flag            : std_logic;
	signal result_significant_bit_flag : std_logic;

begin
	--
	-- represents 8-bit adder
	--
	add_result <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(operand_1) + CONV_INTEGER(operand_2), 8);

	--
	-- represents 8-bit subtraction
	--
	sub_result <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(operand_1) - CONV_INTEGER(operand_2), 8);

	mov_result <= operand_1;
	--
	-- synchronous register-accumulator
	--
	ALU_REG : process(enabled, operation_code, operand_1, operand_2, add_result, sub_result, mov_result)
	begin
		if (rising_edge(enabled)) then
			case operation_code is
				when ADD_OP => op_result <= add_result;
				when SUB_OP => op_result <= sub_result;
				when COPYINTO_OP | COPYTOIN_OP => op_result <= mov_result;
				when others => null;
			end case;
		end if;
	end process;

	FLAGS_PROCESS : process(op_result)
	begin
		if op_result = (op_result'range => '0') then
			result_zero_flag <= '1';
		else
			result_zero_flag <= '0';
		end if;

		if op_result(7) = '1' then
			result_significant_bit_flag <= '1';
		else
			result_significant_bit_flag <= '0';
		end if;
	end process;

	result               <= op_result;
	zero_flag            <= result_zero_flag;
	significant_bit_flag <= result_significant_bit_flag;

end architecture Datapath_Behavioural;


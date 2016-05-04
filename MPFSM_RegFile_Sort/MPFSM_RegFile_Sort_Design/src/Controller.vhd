library ieee;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use commands.all;

--
-- Holds interaction among ROM, RAM and datapath.
--
entity Controller is
	port(
		clk                           : in    std_logic;
		rst                           : in    std_logic;
		start                         : in    std_logic;
		stop                          : out   std_logic;

		rom_enabled                   : out   std_logic;
		rom_address                   : out   std_logic_vector(7 downto 0);
		rom_data_output               : in    std_logic_vector(27 downto 0);

		ram_read_write                : out   std_logic;
		ram_write_data_port           : out   std_logic_vector(7 downto 0);
		ram_write_address             : out   std_logic_vector(7 downto 0);
		ram_read_data_port_1          : in    std_logic_vector(7 downto 0);
		ram_read_data_port_2          : in    std_logic_vector(7 downto 0);
		ram_read_address_1            : out std_logic_vector(7 downto 0);
		ram_read_address_2            : out std_logic_vector(7 downto 0);

		datapath_enabled              : out   std_logic;
		datapath_operation_code       : out   std_logic_vector(3 downto 0);
		datapath_operand_1            : out   std_logic_vector(7 downto 0);
		datapath_operand_2            : out   std_logic_vector(7 downto 0);
		datapath_result               : in    std_logic_vector(7 downto 0);
		datapath_zero_flag            : in    std_logic;
		datapath_significant_bit_flag : in    std_logic
	);
end entity Controller;

architecture Controller_Behavioural of Controller is
	type states is (
		IDLE,
		FETCH,
		DECODE,
		READ,
		WRITE,
		ADD,
		SUB,
		HALT,
		JUMP_IF_ZERO,
		JUMP_IF_NOT_SIGN_BIT_SET
	);

	signal next_state          : states;
	signal current_state       : states;
	signal instruction         : std_logic_vector(27 downto 0);
	signal instruction_counter : std_logic_vector(7 downto 0);
	signal operation           : std_logic_vector(3 downto 0);
	signal operand_address_1   : std_logic_vector(7 downto 0);
	signal operand_address_2   : std_logic_vector(7 downto 0);
	signal result_address      : std_logic_vector(7 downto 0);
	signal data_1              : std_logic_vector(7 downto 0);
	signal data_2              : std_logic_vector(7 downto 0);
	signal data_w              : std_logic_vector(7 downto 0);

	constant DEFAULT_COUNTER_VALUE     : std_logic_vector(7 downto 0)  := (instruction_counter'range => '0');
	constant DEFAULT_INSTRUCTION_VALUE : std_logic_vector(27 downto 0) := (instruction'range => '0');
	constant DEFAULT_OPERATION_VALUE   : std_logic_vector(3 downto 0)  := (operation'range => '0');
	constant DEFAULT_ADDRESS_VALUE     : std_logic_vector(7 downto 0)  := (operand_address_1'range => '0');

begin
	FSM : process(clk, rst, next_state)
	begin
		if (rst = '1') then
			current_state <= IDLE;
		elsif rising_edge(clk) then
			current_state <= next_state;
		end if;
	end process;

	FSM_COMB : process(current_state, start, operation)
	begin
		case current_state is
			when IDLE =>
				if (start = '1') then
					next_state <= FETCH;
				else
					next_state <= IDLE;
				end if;	   
			when FETCH => next_state <= DECODE;

			when DECODE =>
				if (operation = HALT_OP) then
					next_state <= HALT;
				elsif (operation = JZ_OP) then
					next_state <= JUMP_IF_ZERO;
				elsif (operation = JNSB_OP) then
					next_state <= JUMP_IF_NOT_SIGN_BIT_SET;
				else
					next_state <= READ;
				end if;
			when READ =>
				if (operation = ADD_OP) then
					next_state <= ADD;
				elsif (operation = SUB_OP) then
					next_state <= SUB;
				else
					next_state <= IDLE;
				end if;
			when ADD | SUB =>
				next_state <= WRITE;
			when WRITE | JUMP_IF_ZERO | JUMP_IF_NOT_SIGN_BIT_SET =>
				next_state <= FETCH;
			when HALT =>
				next_state <= HALT;
			when others =>
				next_state <= IDLE;
		end case;
	end process;

	--
	-- multiplexer to handle stop signal;
	--
	STOP_PROCESS : process(current_state)
	begin
		if (current_state = HALT) then
			stop <= '1';
		else
			stop <= '0';
		end if;
	end process;

	--
	-- synchronous instruction counter
	--
	INSTR_COUNTER : process(clk, rst, current_state)
	begin
		if (rst = '1') then
			instruction_counter <= DEFAULT_COUNTER_VALUE;
		elsif falling_edge(clk) then
			if (current_state = DECODE) then
				instruction_counter <= instruction_counter + 1;
			elsif (current_state = JUMP_IF_ZERO and datapath_zero_flag = '1') then
				instruction_counter <= operand_address_1;
			elsif (current_state = JUMP_IF_NOT_SIGN_BIT_SET and datapath_significant_bit_flag = '0') then
				instruction_counter <= operand_address_1;
			end if;
		end if;
	end process;

	rom_address <= instruction_counter;

	ROM_READ_SET : process(next_state, current_state)
	begin
		if (next_state = FETCH or current_state = FETCH) then
			rom_enabled <= '1';
		else
			rom_enabled <= '0';
		end if;
	end process;

	--
	-- reads instructions from the ROM
	--
	ROM_READ : process(rst, current_state, rom_data_output)
	begin
		if (rst = '1') then
			instruction <= DEFAULT_INSTRUCTION_VALUE;
		elsif (current_state = FETCH) then
			instruction <= rom_data_output;
		end if;
	end process;

	--
	-- determines the states of registers (address and instruction),
	-- based on current state of FSM
	--
	REGS_CONTROL : process(rst, next_state, instruction)
	begin
		if (rst = '1') then
			operation         <= DEFAULT_OPERATION_VALUE;
			operand_address_1 <= DEFAULT_ADDRESS_VALUE;
			operand_address_2 <= DEFAULT_ADDRESS_VALUE;
		elsif (next_state = DECODE) then
			operation         <= instruction(27 downto 24);
			operand_address_1 <= instruction(23 downto 16);
			operand_address_2 <= instruction(15 downto 8);
			result_address    <= instruction(7 downto 0);
		end if;
	end process;

	RAM_ADDR_SET : process(operand_address_1, operand_address_2, result_address)
	begin
		if (current_state /= JUMP_IF_NOT_SIGN_BIT_SET and current_state /= JUMP_IF_ZERO) then
			ram_read_address_1 <= operand_address_1;
			ram_read_address_2 <= operand_address_2;
			ram_write_address  <= result_address;
		end if;
	end process;

	RAM_MODE_SET : process(current_state)
	begin
		if (current_state = WRITE) then
			ram_read_write <= '0';
		else
			ram_read_write <= '1';
		end if;
	end process;

	RAM_DATA_OUT : process(current_state)
	begin
		if (current_state = READ) then
			data_1 <= ram_read_data_port_1;
			data_2 <= ram_read_data_port_2;
		end if;
	end process;

	ram_write_data_port     <= datapath_result;
	datapath_operand_1      <= data_1;
	datapath_operand_2      <= data_2;
	datapath_operation_code <= operation;

	DATAPATH_SET : process(current_state)
	begin
		if (current_state = ADD or current_state = SUB) then
			datapath_enabled <= '1';
		else
			datapath_enabled <= '0';
		end if;
	end process;

end architecture Controller_Behavioural;

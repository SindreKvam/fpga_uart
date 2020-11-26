library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
	port(
		clk   : in  std_logic;
		rst_n : in  std_logic;
		start : in  std_logic;
		data  : in  std_logic_vector(7 downto 0);
		busy  : out std_logic;
		tx    : out std_logic
	);
end entity uart_tx;

architecture RTL of uart_tx is

	constant clock_frequency : real    := 50.0e6;
	constant baud_rate       : natural := 115200;

	-- For counting clock period
	constant clock_cycles_per_bit : integer := integer(clock_frequency / real(baud_rate));
	subtype clk_counter_type is integer range 0 to clock_cycles_per_bit - 1;
	signal clk_counter            : clk_counter_type;

	type state_type is (
		IDLE,
		START_BIT,
		DATA_BITS,
		STOP_BIT);
	signal state : state_type;

	-- For sampling the data input
	signal data_sampled : std_logic_vector(data'range);

	-- For counting the number of transmitted bits
	signal bit_counter : integer range data'range;

begin
	-- https://upload.wikimedia.org/wikipedia/commons/2/24/UART_timing_diagram.svg
	FSM_PROC : process(clk) is
		-- Increment clk_counter
		-- Return true if the counter wrapped
		impure function clk_counter_wrapped return boolean is
		begin
			if clk_counter = clk_counter_type'high then
				clk_counter <= 0;
				return true;
			else
				clk_counter <= clk_counter + 1;
				return false;
			end if;
		end function;

	begin
		if rising_edge(clk) then
			if rst_n = '0' then
				state        <= IDLE;
				busy         <= '0';
				tx           <= '1';
				data_sampled <= (others => '0');
				bit_counter  <= 0;

			else
				tx   <= '1';
				busy <= '1';

				case state is

					-- Wait for the start signal
					when IDLE =>
						busy <= '0';

						if start = '1' then
							state        <= START_BIT;
							data_sampled <= data;
							busy         <= '1';
						end if;

					-- Transmit the start bit
					when START_BIT =>
						tx <= '0';

						if clk_counter_wrapped then
							state <= DATA_BITS;
						end if;

					-- Transmit the data bits
					when DATA_BITS =>

						tx <= data_sampled(bit_counter);

						if clk_counter_wrapped then
							if bit_counter = data'high then
								state       <= STOP_BIT;
								bit_counter <= 0;
							else
								bit_counter <= bit_counter + 1;
							end if;
						end if;

					-- Transmit the stop bit
					when STOP_BIT =>
						-- set tx to '1', but it's already declared at the start of the state
						if clk_counter_wrapped then
							state <= IDLE;
							busy  <= '0'; -- Adding this here so that it is already set to 0 before it enters the IDLE state
						end if;

				end case;

			end if;
		end if;
	end process FSM_PROC;

end architecture RTL;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tb is
end entity uart_tb;

architecture tb of uart_tb is

	signal clk            : std_logic := '1';
	signal rst_n          : std_logic := '1';
	signal rx             : std_logic := '1';
	signal data           : std_logic_vector(7 downto 0);
	signal valid          : std_logic;
	signal stop_bit_error : std_logic;

begin

	uart_rx_inst : entity work.uart_rx
		port map(
			clk            => clk,
			rst_n          => rst_n,
			rx             => rx,
			data           => data,
			valid          => valid,
			stop_bit_error => stop_bit_error
		);

	PROC_SEQUENCER : process is
	begin
		clk <= not clk;

		-- Reset strobe
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;

		rst_n <= '0';

		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;

		-- Start condition
		rx <= '0';

		wait until rising_edge(clk);
		rx <= '1';

		wait for 120 us;

	end process PROC_SEQUENCER;

end architecture tb;

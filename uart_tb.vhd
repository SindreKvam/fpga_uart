library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tb is
end entity uart_tb;

architecture tb of uart_tb is

	constant clock_frequency : real := 50.0e6;
	constant clock_period    : time := 1 sec / clock_frequency;

	-- Common signals
	signal clk   : std_logic := '1';
	signal rst_n : std_logic := '0';
	signal tx_rx : std_logic := '1';

	-- TX signals
	signal tx_start : std_logic                    := '1';
	signal tx_data  : std_logic_vector(7 downto 0) := (others => '0');
	signal tx_busy  : std_logic;

	-- RX signals
	signal rx_data           : std_logic_vector(7 downto 0) := (others => '0');
	signal rx_valid          : std_logic;
	signal rx_stop_bit_error : std_logic;

begin

	UART_TX : entity work.uart_tx
		port map(
			clk   => clk,
			rst_n => rst_n,
			start => tx_start,
			data  => tx_data,
			busy  => tx_busy,
			tx    => tx_rx
		);

	UART_RX : entity work.uart_rx
		port map(
			clk            => clk,
			rst_n          => rst_n,
			rx             => tx_rx,
			data           => rx_data,
			valid          => rx_valid,
			stop_bit_error => rx_stop_bit_error
		);

	PROC_SEQUENCER : process is
	begin
		
		clk <= not clk after clock_period / 2;

		-- Reset
		rst_n <= '1' after clock_period * 10;

		tx_data <= X"35" after clock_period * 20;
		
		-- Start condition
		tx_start <= '0' after clock_period * 30;
		

	end process PROC_SEQUENCER;

end architecture tb;

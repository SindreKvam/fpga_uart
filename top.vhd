library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
	port(
		MAX10_CLK1_50 : in  std_logic;
		KEY           : in  std_logic_vector(1 downto 0);
		ARDUINO_IO0   : in  std_logic;
		ARDUINO_IO1   : out std_logic;
		SW            : in  std_logic_vector(7 downto 0);
		LEDR          : out std_logic_vector(7 downto 0)
	);
end entity top;

architecture RTL of top is

	signal internal_clock : std_logic;

	-- 0 if in IDLE state, 1 if working
	signal busy : std_logic;

	-- Sends a pulse after it has reached the CHECK_STOP state and if the state is 1 at that point.
	signal valid          : std_logic;
	signal stop_bit_error : std_logic;

begin
	system_clock : entity work.clock
		PORT MAP(
			areset => '0',
			inclk0 => MAX10_CLK1_50,
			c0     => internal_clock,
			locked => open
		);

	uart_rx : entity work.uart_rx
		port map(
			clk            => internal_clock,
			rst_n          => KEY(0),
			rx             => ARDUINO_IO0,
			data           => LEDR,
			valid          => valid,
			stop_bit_error => stop_bit_error
		);
	uart_tx : entity work.uart_tx
		port map(
			clk   => internal_clock,
			rst_n => KEY(0),
			start => KEY(1),
			data  => SW,
			busy  => busy,
			tx    => ARDUINO_IO1
		);

end architecture RTL;

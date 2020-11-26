library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
	port(
		MAX10_CLK1_50 : in    std_logic;
		KEY           : in    std_logic_vector(1 downto 0);
		Arduino_IO    : inout std_logic_vector(15 downto 0);
		SW            : in    std_logic_vector(7 downto 0) := (others => '0');
		LEDR          : out   std_logic_vector(7 downto 0)
	);
end entity top;

architecture RTL of top is

	signal internal_clock : std_logic;
	
	signal busy : std_logic;
	signal valid : std_logic;

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
			clk => internal_clock,
			rst_n => KEY(0),
			rx => Arduino_IO(0),
			data => LEDR,
			valid => valid
		);
	uart_tx : entity work.uart_tx
		port map(
			clk => internal_clock,
			rst_n => KEY(0),
			start => KEY(1),
			data => SW,
			busy => busy,
			tx => Arduino_IO(1)
		);

end architecture RTL;

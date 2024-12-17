library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use	IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity port_interrupt_detector_unit is -- rising edge detector
	port(
		clk								: in std_logic;
		rst								: in std_logic;
		pins_i 						: in std_logic_vector(7 downto 0);
		interrupt_info_o	: out std_logic_vector(7 downto 0);
		interrupt_flag_o 	: out std_logic
	);
end port_interrupt_detector_unit;

architecture Behavioral of port_interrupt_detector_unit is

component edge_detector is
	port(
		clk                     	: in  std_logic;
		rst                     	: in  std_logic;
		i_input                  	: in  std_logic;
		o_pulse                 	: out std_logic
	);
end component;

signal interrupt_flag				: std_logic;

signal pin0_rising_edge_flag        : std_logic;
signal pin1_rising_edge_flag        : std_logic;
signal pin2_rising_edge_flag        : std_logic;
signal pin3_rising_edge_flag        : std_logic;
signal pin4_rising_edge_flag        : std_logic;
signal pin5_rising_edge_flag        : std_logic;
signal pin6_rising_edge_flag        : std_logic;
signal pin7_rising_edge_flag        : std_logic;

signal rst_pin_0        			: std_logic;
signal rst_pin_1        			: std_logic;
signal rst_pin_2        			: std_logic;
signal rst_pin_3        			: std_logic;
signal rst_pin_4        			: std_logic;
signal rst_pin_5        			: std_logic;
signal rst_pin_6        			: std_logic;
signal rst_pin_7       				: std_logic;

signal interrupt_info_buf           : std_logic_vector(7 downto 0);
begin

process(clk, rst) begin
	if(rst = '1') then
		interrupt_flag <= '0';
		
		rst_pin_0 <= '1';
		rst_pin_1 <= '1';
		rst_pin_2 <= '1';
		rst_pin_3 <= '1';
		rst_pin_4 <= '1';
		rst_pin_5 <= '1';
		rst_pin_6 <= '1';
		rst_pin_7 <= '1';
		
    elsif(rising_edge(clk)) then -- rising_edge sadece clock'da kullanılır.
		rst_pin_0 <= '0';
		rst_pin_1 <= '0';
		rst_pin_2 <= '0';
		rst_pin_3 <= '0';
		rst_pin_4 <= '0';
		rst_pin_5 <= '0';
		rst_pin_6 <= '0';
		rst_pin_7 <= '0';
		
		if((pin0_rising_edge_flag = '1') or (pin1_rising_edge_flag = '1') or
		(pin2_rising_edge_flag = '1') or (pin3_rising_edge_flag = '1') or
		(pin4_rising_edge_flag = '1') or (pin5_rising_edge_flag = '1') or
		(pin6_rising_edge_flag = '1') or (pin7_rising_edge_flag = '1')) then
		
		  interrupt_info_buf(0) <= pin0_rising_edge_flag;
		  interrupt_info_buf(1) <= pin1_rising_edge_flag;
		  interrupt_info_buf(2) <= pin2_rising_edge_flag;
		  interrupt_info_buf(3) <= pin3_rising_edge_flag;
		  interrupt_info_buf(4) <= pin4_rising_edge_flag;
		  interrupt_info_buf(5) <= pin5_rising_edge_flag;
		  interrupt_info_buf(6) <= pin6_rising_edge_flag;
		  interrupt_info_buf(7) <= pin7_rising_edge_flag;
		  
		
			interrupt_flag <= '1';
			
			rst_pin_0 <= '0';
			rst_pin_1 <= '0';
			rst_pin_2 <= '0';
			rst_pin_3 <= '0';
			rst_pin_4 <= '0';
			rst_pin_5 <= '0';
			rst_pin_6 <= '0';
			rst_pin_7 <= '0';
		end if;
	end if;
end process;

edge_detector_0: edge_detector port map(
	clk    		=> clk,
    rst    		=> rst_pin_0,
    i_input		=> pins_i(0),
    o_pulse		=> pin0_rising_edge_flag
);

edge_detector_1: edge_detector port map(
	clk    		=> clk,
    rst    		=> rst_pin_1,
    i_input		=> pins_i(1),
    o_pulse		=> pin1_rising_edge_flag
);

edge_detector_2: edge_detector port map(
	clk    		=> clk,
    rst    		=> rst_pin_2,
    i_input		=> pins_i(2),
    o_pulse		=> pin2_rising_edge_flag
);

edge_detector_3: edge_detector port map(
	clk    		=> clk,
    rst    		=> rst_pin_3,
    i_input		=> pins_i(3),
    o_pulse		=> pin3_rising_edge_flag
);

edge_detector_4: edge_detector port map(
	clk    		=> clk,
    rst    		=> rst_pin_4,
    i_input		=> pins_i(4),
    o_pulse		=> pin4_rising_edge_flag
);

edge_detector_5: edge_detector port map(
	clk    		=> clk,
    rst    		=> rst_pin_5,
    i_input		=> pins_i(5),
    o_pulse		=> pin5_rising_edge_flag
);

edge_detector_6: edge_detector port map(
	clk    		=> clk,
    rst    		=> rst_pin_6,
    i_input		=> pins_i(6),
    o_pulse		=> pin6_rising_edge_flag
);

edge_detector_7: edge_detector port map(
	clk    		=> clk,
    rst    		=> rst_pin_7,
    i_input		=> pins_i(7),
    o_pulse		=> pin7_rising_edge_flag
);

interrupt_flag_o <= interrupt_flag;
interrupt_info_o <= interrupt_info_buf;
end Behavioral;

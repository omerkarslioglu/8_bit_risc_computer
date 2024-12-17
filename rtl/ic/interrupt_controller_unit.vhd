library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity interrupt_controller_unit is
port (
	clk							: in std_logic;
	interrupt_control_reg1_i	: in std_logic_vector(7 downto 0); 
	-- [0] : enable io port-a interrupt
	-- [1] : enable io port-b interrupt
	-- [2] : enable tim1 interrupt
	-- [3] : enable tim2 interrupt
	-- [4] : enable uart interrupt
	-- [7 downto 5] : reserved
	interrupt_control_reg2_i	: in std_logic_vector(7 downto 0); 
	-- [0] : enable interrupt io port-a pin 0
	-- [1] : enable interrupt io port-a pin 1
	-- [2] : enable interrupt io port-a pin 2
	-- ...
	interrupt_control_reg3_i	: in std_logic_vector(7 downto 0); 
	-- [0] : enable interrupt io port-b pin 0
	-- [1] : enable interrupt io port-b pin 1
	-- [2] : enable interrupt io port-b pin 2
	-- ...
	IC_Signal_i					: in std_logic_vector(7 downto 0); -- tick signals from peripherals
	-- [0] : reserved
	-- [1] : reserved
	-- [2] : tim1 interrupt flag
	-- [3] : tim2 interrupt flag
	-- [4] : uart interrupt flag
	-- [7 downto 5] : reserved
	IC_PortA_Signal_i			: in std_logic_vector(7 downto 0);
	-- [0] : io port-a pin 0
	-- [1] : io port-a pin 1
	-- [2] : io port-a pin 2
	-- ...
	IC_PortB_Signal_i			: in std_logic_vector(7 downto 0);
	-- [0] : io port-b pin 0
	-- [1] : io port-b pin 1
	-- [2] : io port-b pin 2
	-- ...
	IC_Reset_i					: in std_logic; -- clear IC flag
	
	IC_Signal_o					: out std_logic_vector(7 downto 0);
	-- [0] : io port-a interrupt flag
	-- [1] : io port-b interrupt flag
	-- [2] : tim1 interrupt flag
	-- [3] : tim2 interrupt flag
	-- [4] : uart interrupt flag
	-- [7 downto 5] :
	--		000: io pin 0
	--		001: io pin 1
	--		010: io pin 2
	--		...
	IC_Flag_o 					: out std_logic
	);
end interrupt_controller_unit;

architecture Behavioral of interrupt_controller_unit is

component port_interrupt_detector_unit is 
port(
	clk					: in std_logic;
	rst					: in std_logic;
	pins_i 				: in std_logic_vector(7 downto 0);
	interrupt_info_o    : out std_logic_vector(7 downto 0);
	interrupt_flag_o 	: out std_logic
);
end component;

signal interrupt_control_reg1		: std_logic_vector(7 downto 0);
signal interrupt_control_reg2		: std_logic_vector(7 downto 0);
signal interrupt_control_reg3		: std_logic_vector(7 downto 0); 
signal IC_Signal_i_reg				: std_logic_vector(7 downto 0);
signal IC_PortA_Signal_reg			: std_logic_vector(7 downto 0);
signal IC_PortB_Signal_reg			: std_logic_vector(7 downto 0);

signal IC_Signal_o_reg				: std_logic_vector(7 downto 0);
signal IC_Flag_o_reg				: std_logic;

-- signal rst_porta_interrupt_detector : std_logic;
-- signal rst_portb_interrupt_detector : std_logic;

signal flag_porta_interrupt_detector : std_logic;
signal flag_portb_interrupt_detector : std_logic;

signal interrupt_info_a_signal : std_logic_vector(7 downto 0);
signal interrupt_info_b_signal : std_logic_vector(7 downto 0);

begin

-- PORT A Interrupt Detector
porta_interrupt_detector_unit:	port_interrupt_detector_unit port map(
	clk					=> clk,
	rst					=> IC_Reset_i,
	pins_i 				=> IC_PortA_Signal_i,
	interrupt_info_o 	=> interrupt_info_a_signal,
	interrupt_flag_o 	=> flag_porta_interrupt_detector
);

-- PORT B Interrupt Detector
portb_interrupt_detector_unit:	port_interrupt_detector_unit port map(
	clk					=> clk,
	rst					=> IC_Reset_i,
	pins_i 				=> IC_PortB_Signal_i,
	interrupt_info_o 	=> interrupt_info_b_signal,
	interrupt_flag_o 	=> flag_portb_interrupt_detector
);

interrupt_control_reg1 	<= interrupt_control_reg1_i;
interrupt_control_reg2 	<= interrupt_control_reg2_i;
interrupt_control_reg3 	<= interrupt_control_reg3_i;
IC_Signal_i_reg			<= IC_Signal_i;
IC_PortA_Signal_reg		<= IC_PortA_Signal_i;
IC_PortB_Signal_reg		<= IC_PortB_Signal_i;

--rst_porta_interrupt_detector	<= IC_Reset_i;
--rst_porta_interrupt_detector	<= IC_Reset_i;


process(clk, IC_Signal_i, IC_Reset_i, flag_porta_interrupt_detector, flag_portb_interrupt_detector)
begin
if(rising_edge(clk)) then
	case IC_Reset_i is
	when '1' =>
	   IC_Flag_o_reg <= '0';
	   IC_Signal_o_reg <= "00000000";
	when others =>
		if(flag_porta_interrupt_detector = '1') then -- port a interrupt
			case interrupt_info_a_signal is
				when "00000001" =>
					if(interrupt_control_reg1_i(0) = '1' and interrupt_control_reg2_i(0) = '1') then
						IC_Signal_o_reg(7 downto 5) <= 	"000";
						IC_Flag_o_reg <= '1';
					end if;
				when "00000010" =>
					if(interrupt_control_reg1_i(0) = '1' and interrupt_control_reg2_i(1) = '1' and flag_porta_interrupt_detector = '1') then
						IC_Signal_o_reg(7 downto 5) <= 	"001";
						IC_Flag_o_reg <= '1';
					end if;
				when "00000100" =>
					if(interrupt_control_reg1_i(0) = '1' and interrupt_control_reg2_i(2) = '1' and flag_porta_interrupt_detector = '1') then
						IC_Signal_o_reg(7 downto 5) <= 	"010";
						IC_Flag_o_reg <= '1';
					end if;
				when "00001000" =>
					if(interrupt_control_reg1_i(0) = '1' and interrupt_control_reg2_i(3) = '1' and flag_porta_interrupt_detector = '1') then
						IC_Signal_o_reg(7 downto 5) <= 	"011";
						IC_Flag_o_reg <= '1';
					end if;
				when "00010000" =>
					if(interrupt_control_reg1_i(0) = '1' and interrupt_control_reg2_i(4) = '1' and flag_porta_interrupt_detector = '1') then
						IC_Signal_o_reg(7 downto 5) <= 	"100";
						IC_Flag_o_reg <= '1';
					end if;
				when "00100000" =>
					if(interrupt_control_reg1_i(0) = '1' and interrupt_control_reg2_i(5) = '1' and flag_porta_interrupt_detector = '1') then
						IC_Signal_o_reg(7 downto 5) <= 	"101";
						IC_Flag_o_reg <= '1';
					end if;
				when "01000000" =>
					if(interrupt_control_reg1_i(0) = '1' and interrupt_control_reg2_i(6) = '1' and flag_porta_interrupt_detector = '1') then
						IC_Signal_o_reg(7 downto 5) <= 	"110";
						IC_Flag_o_reg <= '1';
					end if;
				when "10000000" =>
					if(interrupt_control_reg1_i(0) = '1' and interrupt_control_reg2_i(7) = '1' and flag_porta_interrupt_detector = '1') then
						IC_Signal_o_reg(7 downto 5) <= 	"111";
						IC_Flag_o_reg <= '1';
					end if;
				when others =>
					IC_Signal_o_reg(7 downto 5) <= 	"000";
					--IC_Flag_o_reg <= '0';
			end case;
		end if;
		if(flag_portb_interrupt_detector = '1') then -- port b interrupt
			case interrupt_info_b_signal is
				when "00000001" =>
					if(interrupt_control_reg1_i(1) = '1' and interrupt_control_reg3_i(0) = '1') then
						IC_Signal_o_reg(7 downto 5) <= 	"000";
						IC_Flag_o_reg <= '1';
					end if;
				when "00000010" =>
					if(interrupt_control_reg1_i(1) = '1' and interrupt_control_reg3_i(1) = '1' and flag_portb_interrupt_detector = '1') then
						IC_Signal_o_reg(7 downto 5) <= 	"001";
						IC_Flag_o_reg <= '1';
					end if;
				when "00000100" =>
					if(interrupt_control_reg1_i(1) = '1' and interrupt_control_reg3_i(2) = '1' and flag_portb_interrupt_detector = '1') then
						IC_Signal_o_reg(7 downto 5) <= 	"010";
						IC_Flag_o_reg <= '1';
					end if;
				when "00001000" =>
					if(interrupt_control_reg1_i(1) = '1' and interrupt_control_reg3_i(3) = '1' and flag_portb_interrupt_detector = '1') then
						IC_Signal_o_reg(7 downto 5) <= 	"011";
						IC_Flag_o_reg <= '1';
					end if;
				when "00010000" =>
					if(interrupt_control_reg1_i(1) = '1' and interrupt_control_reg3_i(4) = '1' and flag_portb_interrupt_detector = '1') then
						IC_Signal_o_reg(7 downto 5) <= 	"100";
						IC_Flag_o_reg <= '1';
					end if;
				when "00100000" =>
					if(interrupt_control_reg1_i(1) = '1' and interrupt_control_reg3_i(5) = '1' and flag_portb_interrupt_detector = '1') then
						IC_Signal_o_reg(7 downto 5) <= 	"101";
						IC_Flag_o_reg <= '1';
					end if;
				when "01000000" =>
					if(interrupt_control_reg1_i(1) = '1' and interrupt_control_reg3_i(6) = '1' and flag_portb_interrupt_detector = '1') then
						IC_Signal_o_reg(7 downto 5) <= 	"110";
						IC_Flag_o_reg <= '1';
					end if;
				when "10000000" =>
					if(interrupt_control_reg1_i(1) = '1' and interrupt_control_reg3_i(7) = '1' and flag_portb_interrupt_detector = '1') then
						IC_Signal_o_reg(7 downto 5) <= 	"111";
						IC_Flag_o_reg <= '1';
					end if;
				when others =>
					IC_Signal_o_reg(7 downto 5) <= 	"000";
					--IC_Flag_o_reg <= '0';
			end case;	
		end if;
		
		-- Peripheral Interrupt Flag Assign
		if(interrupt_control_reg1_i(0) = '1' and flag_porta_interrupt_detector = '1') then
			IC_Signal_o_reg(0) <= IC_Signal_i(0);
			--IC_Flag_o_reg <= '1';
		end if;
		if(interrupt_control_reg1_i(1) = '1' and flag_portb_interrupt_detector = '1') then
			IC_Signal_o_reg(1) <= IC_Signal_i(1);
			--IC_Flag_o_reg <= '1';
		end if;
		if(interrupt_control_reg1_i(2) = '1' and IC_Signal_i(2) = '1') then
			IC_Signal_o_reg(2) <= IC_Signal_i(2);
			IC_Flag_o_reg <= '1';
		end if;
		if(interrupt_control_reg1_i(3) = '1' and IC_Signal_i(3) = '1') then
			IC_Signal_o_reg(3) <= IC_Signal_i(3);
			IC_Flag_o_reg <= '1';
		end if;
		if(interrupt_control_reg1_i(4) = '1' and IC_Signal_i(4) = '1') then
			IC_Signal_o_reg(4) <= IC_Signal_i(4);
			IC_Flag_o_reg <= '1';
		end if;
	end case;
end if;						
end process;

IC_Signal_o <= IC_Signal_o_reg;
IC_Flag_o	<= IC_Flag_o_reg;

end Behavioral;

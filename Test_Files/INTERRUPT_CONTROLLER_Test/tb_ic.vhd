library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_ic is

end tb_ic;

architecture Behavioral of tb_ic is

component interrupt_controller_unit is
port(
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
	-- [0] : io port-a interrupt flag
	-- [1] : io port-b interrupt flag
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
end component;

constant clock_period : time := 20 ns;

signal clk			                : std_logic;
signal interrupt_control_reg1_i		: std_logic_vector(7 downto 0); 
signal interrupt_control_reg2_i		: std_logic_vector(7 downto 0); 
signal interrupt_control_reg3_i		: std_logic_vector(7 downto 0); 
signal IC_Signal_i					: std_logic_vector(7 downto 0); -- tick signals from peripherals
signal IC_PortA_Signal_i			: std_logic_vector(7 downto 0);
signal IC_PortB_Signal_i			: std_logic_vector(7 downto 0);
signal IC_Reset_i					: std_logic; -- clear IC flag
signal IC_Signal_o					: std_logic_vector(7 downto 0);
signal IC_Flag_o 					: std_logic;

begin

clock_process: process
               begin
                    clk <= '0';
                    wait for clock_period/2;
                    clk <= '1';
                    wait for clock_period/2;
               end process;

uut: interrupt_controller_unit port map(
	clk						 => clk,
	interrupt_control_reg1_i =>	interrupt_control_reg1_i,
	interrupt_control_reg2_i =>	interrupt_control_reg2_i,
	interrupt_control_reg3_i =>	interrupt_control_reg3_i,
	IC_Signal_i				 => IC_Signal_i,
	IC_PortA_Signal_i		 => IC_PortA_Signal_i,
	IC_PortB_Signal_i		 => IC_PortB_Signal_i,
	IC_Reset_i				 => IC_Reset_i,
	IC_Signal_o				 => IC_Signal_o,
	IC_Flag_o 				 => IC_Flag_o 				
);

stim_process: process
begin
    IC_Reset_i 					<= '1';
	wait for 100ns;
	IC_Reset_i 					<= '0';
	wait for 100ns;
	
	interrupt_control_reg1_i 	<= "00011111"; -- all interrupts of the peripherals are enable
	interrupt_control_reg2_i 	<= "11111111"; -- all interrupts of port-a pins are enable
	interrupt_control_reg3_i 	<= "11111111"; -- all interrupts of port-b pins are enable
	IC_PortA_Signal_i 			<= "00000000";
	IC_PortB_Signal_i 			<= "00000000";
	
	-- timer1 interrupt
	IC_Signal_i 			 	<= "00000100";
	wait for 40ns;
	IC_Signal_i                 <= "00000000";
	wait for 120ns;
	
	-- Reset
	IC_Reset_i 					<= '1';
	wait for 80ns;
	IC_Reset_i 					<= '0';
    wait for 40ns;
	
	-- timer2 interrupt
	IC_Signal_i 			 	<= "00001000";
    wait for 40ns;
    IC_Signal_i                 <= "00000000";
    wait for 120ns;
    
	-- Reset
    IC_Reset_i                     <= '1';
    wait for 80ns;
	IC_Reset_i 					<= '0';
    wait for 40ns;
    
    -- optional peripheral interrupt
    IC_Signal_i 			 	<= "00010000";
    wait for 40ns;
    IC_Signal_i                 <= "00000000";
	IC_Reset_i 					<= '0';
    wait for 40ns;
      
	-- Reset
    IC_Reset_i                  <= '1';
    wait for 80ns;
	IC_Reset_i 					<= '0';
    wait for 40ns;
    
    -- porta interrupt
	IC_PortA_Signal_i 			<= "00000001";
	wait for 80ns;
	IC_PortA_Signal_i 			<= "00000000";
	wait for 120ns;

	-- Reset
	IC_Reset_i 					<= '1';
	wait for 80ns;
	IC_Reset_i 					<= '0';
    wait for 40ns;
    
	-- portb interrupt
	IC_PortB_Signal_i 			<= "00000001";
    wait for 80ns;
    IC_PortB_Signal_i           <= "00000000";
    wait for 120ns;
 
 	-- Reset
    IC_Reset_i                  <= '1';
    wait for 80ns;
    IC_Reset_i 					<= '0';
    wait for 40ns;
	
	wait;
end process;

end Behavioral;

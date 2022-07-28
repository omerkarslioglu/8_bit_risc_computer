library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_timer_module is

end tb_timer_module;

architecture Behavioral of tb_timer_module is

component timer_top is
port(
        clk                         : in std_logic;
        rst                         : in std_logic;
        control_reg_1               : in std_logic_vector(7 downto 0); 
        -- [0] timer enable+
        -- [1] ch1 enable+
        -- [2] ch2 enable+
        -- [3] counter mode bit1+
        -- [4] counter mode bit2+
        -- -- 00: up-default
        -- -- 01: down
        -- -- 10: center-aligned
        -- [7 downto 5] reserved
        control_reg_2               : in std_logic_vector(7 downto 0);--+
        -- [0] ch1 mode selection (0:default mode 1:pwm mode)+
        -- [1] ch1 pwm output generation enable+
        -- [2] ch1 pwm channel polarity+
        -- -- 0: gives high for duty cycle
        -- -- 1: gives low for duty cycle
        -- [3] ch2 mode selection (0:default mode 1:pwm mode)
        -- [4] ch2 pwm output generation enable
        -- [5] ch2 pwm channel polarity
        -- [7 downto 6] reserved     
        prescaler_reg               : in std_logic_vector(7 downto 0); -- for clock divider
        auto_reload_reg             : in std_logic_vector(7 downto 0); -- for pwm
        ccr_reg_ch1                 : in std_logic_vector(7 downto 0); -- ccr reg for pwm duty=ccr/arr
        ccr_reg_ch2                 : in std_logic_vector(7 downto 0); -- ccr reg for pwm duty=ccr/arr

        pwm_out                     : out std_logic_vector(1 downto 0); -- pwm out for two channel (to external i/o)
        -- [0] ch1 pwm output pin
        -- [1] ch2 pwm output pin
        timer_out_reg               : inout std_logic_vector(7 downto 0) 
        -- r/w register (it is connected to three modules:
        -- 1-[Core]Input Mem.)
        -- 2-[Core]Output Mem.)
        -- 3-Interrupt Controller Unit
        -- [0] ch1 system_tick flag+
        -- [1] ch2 system_tick flag

    );
end component;

signal clk                         : std_logic;
signal rst                         : std_logic;
signal control_reg_1               : std_logic_vector(7 downto 0); 
signal control_reg_2               : std_logic_vector(7 downto 0);--+
signal prescaler_reg               : std_logic_vector(7 downto 0); -- for clock divider
signal auto_reload_reg             : std_logic_vector(7 downto 0); -- for pwm
signal ccr_reg_ch1                 : std_logic_vector(7 downto 0); -- ccr reg for pwm duty=ccr/arr
signal ccr_reg_ch2                 : std_logic_vector(7 downto 0); -- ccr reg for pwm duty=ccr/arr
signal pwm_out                     : std_logic_vector(1 downto 0); -- pwm out for two channel (to external i/o)
signal timer_out_reg               : std_logic_vector(7 downto 0); 

constant clock_period : time := 50ns; -- 20 MHz

begin

uut: timer_top port map(
    clk            => clk            ,
    rst            => rst            ,
    control_reg_1  => control_reg_1  ,
    control_reg_2  => control_reg_2  ,
    prescaler_reg  => prescaler_reg  ,
    auto_reload_reg=> auto_reload_reg,
    ccr_reg_ch1    => ccr_reg_ch1    ,
    ccr_reg_ch2    => ccr_reg_ch2    ,
    pwm_out        => pwm_out        ,
    timer_out_reg  => timer_out_reg  
);

clock_process: process
begin
    clk<='0';
    wait for clock_period/2;
    clk<='1';
    wait for clock_period/2;
end process;

stim_process: process
begin

rst <= '1';
wait for 100ns;
rst <= '0';
wait for 100ns;

control_reg_1 	<= "00000111";  	-- up
control_reg_2 	<= "00111111";  	-- pwm mode for ch1 and ch2

prescaler_reg 	<= x"64";		-- 100 in decimal
auto_reload_reg 	<= x"64";		-- 100 in decimal

ccr_reg_ch1   	<= x"0A";		-- 10 in decimal
ccr_reg_ch2   	<= x"0A";     		-- 10 in decimal


wait;

end process;

end Behavioral;

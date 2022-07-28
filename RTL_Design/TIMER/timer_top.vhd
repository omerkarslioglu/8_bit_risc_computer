library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_lOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity timer_top is
port(
        clk                         : in std_logic;
        rst                         : in std_logic;
        control_reg_1               : in std_logic_vector(7 downto 0); 
        -- [0] timer enable+
        -- [1] ch1 enable+
        -- [2] ch2 enable
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
        prescaler_reg              : in std_logic_vector(7 downto 0); -- for clock divider
       
        auto_reload_reg             : in std_logic_vector(7 downto 0); -- for pwm
        ccr_reg_ch1                 : in std_logic_vector(7 downto 0); -- ccr reg for pwm duty=ccr/arr
        ccr_reg_ch2                 : in std_logic_vector(7 downto 0); -- ccr reg for pwm duty=ccr/arr

        pwm_out                     : out std_logic_vector(1 downto 0); -- pwm out for two channel (to external i/o)
        -- [0] ch1 pwm output pin
        -- [1] ch2 pwm output pin
        timer_out_reg               : out std_logic_vector(7 downto 0) 
        -- r/w register (it is connected to three modules:
        -- 1-[Core]Input Mem.)
        -- 2-[Core]Output Mem.)
        -- 3-Interrupt Controller Unit
        -- [0] ch1 system_tick flag+
        -- [1] ch2 system_tick flag+

    );
end timer_top;

architecture Behavioral of timer_top is

    component counter is
        port(
            clk                         : in std_logic;
            divided_clock               : in std_logic;
            rst                         : in std_logic;
            counter_mode                : in std_logic_vector(1 downto 0);
            arr_value                   : in std_logic_vector(7 downto 0);
            counter_tick                : out std_logic;
            counter_out                 : out std_logic_vector(7 downto 0)
            );
    end component;
    
    component clock_divider is -- clock source and divider
        port ( 
            clk                     : in std_logic;
            rst                     : in std_logic;
            timer_enable            : in std_logic;
            channel_enable          : in std_logic;
            divider_value           : in std_logic_vector(7 downto 0);
            clk_out                 : out std_logic
            );
    end component;

    component pwm_module is
        port ( 
             clk                     : in std_logic;
             divided_clock           : in std_logic;
             rst                     : in std_logic;
             pwm_mode_enable         : in std_logic;
             pwm_polarity            : in std_logic;
             pwm_output_enable       : in std_logic;
             counter_value           : in std_logic_vector(7 downto 0);
             ccr_value               : in std_logic_vector(7 downto 0);
             pwm_out_o               : out std_logic
             );
    end component;
    
signal  counter_result_ch1              : std_logic_vector(7 downto 0);
signal  divided_clock_ch1               : std_logic;

signal  counter_result_ch2              : std_logic_vector(7 downto 0);
signal  divided_clock_ch2               : std_logic;

begin

counter_ch1: counter port map(
    clk                 => clk, -- divided clock is connected to main counter
    divided_clock       => divided_clock_ch1,
    rst                 => rst,
    counter_mode        => control_reg_1(4 downto 3),
    arr_value           => auto_reload_reg,
    counter_tick        => timer_out_reg(0), -- associated with channel output
    counter_out         => counter_result_ch1 
);

clock_divider_ch1: clock_divider port map(
    clk                 => clk,
    rst                 => rst,
    timer_enable        => control_reg_1(0),
    channel_enable      => control_reg_1(1),
    divider_value       => prescaler_reg,
    clk_out             => divided_clock_ch1      
);

pwm_module_ch1: pwm_module port map (
    clk                     => clk,
    divided_clock           => divided_clock_ch1,
    rst                     => rst,
    pwm_mode_enable         => control_reg_2(0),
    pwm_polarity            => control_reg_2(2),
    pwm_output_enable       => control_reg_2(1),
    counter_value           => counter_result_ch1,
    ccr_value               => ccr_reg_ch1,
    pwm_out_o               => pwm_out(0)
);

counter_ch2: counter port map(
    clk                 => clk, -- divided clock is connected to main counter
    divided_clock       => divided_clock_ch2,
    rst                 => rst,
    counter_mode        => control_reg_1(4 downto 3),
    arr_value           => auto_reload_reg,
    counter_tick        => timer_out_reg(1), -- associated with channel output
    counter_out         => counter_result_ch2 
);

clock_divider_ch2: clock_divider port map(
    clk                 => clk,
    rst                 => rst,
    timer_enable        => control_reg_1(0),
    channel_enable      => control_reg_1(2),
    divider_value       => prescaler_reg,
    clk_out             => divided_clock_ch2      
);

pwm_module_ch2: pwm_module port map (
    clk                     => clk,
    divided_clock           => divided_clock_ch2,
    rst                     => rst,
    pwm_mode_enable         => control_reg_2(3),
    pwm_polarity            => control_reg_2(5),
    pwm_output_enable       => control_reg_2(4),
    counter_value           => counter_result_ch2,
    ccr_value               => ccr_reg_ch1,
    pwm_out_o               => pwm_out(1)
);

timer_out_reg(7 downto 2)   <=  "000000";
  
end Behavioral;

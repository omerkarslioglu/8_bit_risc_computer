library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity pwm_module is
    port(
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

end pwm_module;

architecture Behavioral of pwm_module is

    signal pwm_out_signal       : std_logic :='0';
    signal clk_div_state        : std_logic :='1';

begin

    pwm_out_o     <=   pwm_out_signal;
    
process(clk) begin
    if(rising_edge(clk)) then
        if(divided_clock = '1' and clk_div_state='1') then
            clk_div_state<='0';
            if(rst='1') then
                pwm_out_signal<='0';
            elsif(pwm_output_enable = '1') then
                if(pwm_mode_enable='1') then
                    if(pwm_polarity='1') then
                        if(ccr_value<=counter_value) then
                            pwm_out_signal<='1';
                        else
                            pwm_out_signal<='0';
                        end if;
                    elsif(pwm_polarity='0') then
                        if(ccr_value<=counter_value) then
                            pwm_out_signal<='0';
                        else
                            pwm_out_signal<='1';
                        end if;
                    end if;
                end if;
            else
                pwm_out_signal<='0'; -- pwm enable 0 oldugunda, pwm out 0 olur.
            end if;
        elsif(divided_clock = '0' and clk_div_state='0') then
            clk_div_state<='1';
        end if;
    end if;
end process;

    

end Behavioral;

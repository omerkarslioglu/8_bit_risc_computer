library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity counter is
port(
        clk                     : in std_logic;
        divided_clock           : in std_logic;
        rst                     : in std_logic;
        counter_mode            : in std_logic_vector(1 downto 0);
        arr_value               : in std_logic_vector(7 downto 0); -- Auto reload value
        counter_tick            : out std_logic;
        counter_out             : out std_logic_vector(7 downto 0)
    );
end counter;

architecture Behavioral of counter is

    signal cnt                      : std_logic_vector(7 downto 0) := "00000000";
    signal center_aligned_flag      : std_logic := '0';
    signal counter_tick_signal      : std_logic := '0';
    signal clk_div_state            : std_logic := '1';
    
    -- for edge detector
--    signal r0_input                           : std_logic;
--    signal r1_input                           : std_logic;
--    signal o_pulse_reg                        : std_logic;

begin
    
process(clk) begin -- async. reset
    if(rising_edge(clk)) then
    if(divided_clock = '1' and clk_div_state = '1') then
        --if(divided_clock = '1' and clk_div_state='1') then
            clk_div_state<='0';
            if(rst='1') then
                cnt<="00000000";
                counter_tick_signal <= '0';
            end if;
            counter_tick_signal <= '0';
             case counter_mode is
                 when "00" => -- up
                     if(arr_value>cnt) then
                         cnt <= cnt + 1;
                     else
                         cnt <= "00000000";
                         counter_tick_signal <= '1'; -- counter is completed
                     end if;
                 when "01" => -- down
                     if(0<cnt) then
                         cnt <= cnt - 1;
                     else
                         cnt <= arr_value;
                         counter_tick_signal <= '1';  -- counter is completed
                     end if;
                 when "10" => -- center aligned
                     if((arr_value>=cnt) and (center_aligned_flag='0')) then
                         if(cnt=arr_value) then     -- center aligned control
                             center_aligned_flag <= '1';
                         else
                            cnt <= cnt + 1;
                         end if;
                     elsif((0<=cnt) and (center_aligned_flag='1')) then
                         if(cnt="0") then             -- center aligned control
                             center_aligned_flag <= '0';
                             counter_tick_signal <= '1';  -- counter is completed
                         else
                            cnt <= cnt - 1;
                         end if;
                    end if;
                 when others =>
                     --null;
                     cnt<="00000000";
             end case;
        --elsif(divided_clock = '0' and clk_div_state='1') then
             --clk_div_state<='1';
       -- end if;
    else
        clk_div_state<='1';
    end if;
    end if;
end process;

-- rising edge detect
--p_rising_edge_detector : process(clk, rst)
--begin
--  if(rst='1') then
--    r0_input           <= '0';
--    r1_input           <= '0';
--    o_pulse_reg        <= '0';
--  elsif(rising_edge(clk)) then
--    r1_input           <= r0_input;
--    r0_input           <= divided_clock;
--    if(o_pulse_reg = '1' and divided_clock = '1') then
--       o_pulse_reg <='1'; 
--    else
--       o_pulse_reg        <= not r1_input and r0_input;
--    end if;
--  end if;
--end process p_rising_edge_detector;
    
counter_tick    <= counter_tick_signal;
counter_out     <= cnt;
     
end Behavioral;
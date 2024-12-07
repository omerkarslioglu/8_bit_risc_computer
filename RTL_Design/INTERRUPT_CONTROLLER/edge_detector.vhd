library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity edge_detector is
port (
  clk                     	              : in  std_logic;
  rst                     	              : in  std_logic;
  i_input                  	              : in  std_logic;
  o_pulse                 	              : out std_logic
  );
end edge_detector;

architecture rtl of edge_detector is
signal r0_input                           : std_logic;
signal r1_input                           : std_logic;
signal o_pulse_reg                        : std_logic:='0';
signal int_hold_flag                      : std_logic:='1';
begin

--process(clk) begin
--    if(rst='1') then
--        out_buff <= '0';
--    elsif(rising_edge(clk)) then
--        out_buff <= o_pulse_reg;
--   end if;
--end process;

p_rising_edge_detector : process(clk, rst)
begin
  if(rst='1') then
    r0_input           <= '0';
    r1_input           <= '0';
    o_pulse_reg        <= '0';
  elsif(rising_edge(clk)) then
    --if(o_pulse_reg = '1' and i_input = '1') then
        --r1_input           <= '0';
    --else
    r1_input           <= r0_input;
    --end if;
    r0_input           <= i_input;
    --if(int_hold_flag = '1') then
        --int_hold_flag <= '0';
     if(o_pulse_reg = '1' and i_input = '1') then
        o_pulse_reg <='1'; 
     else
        o_pulse_reg        <= not r1_input and r0_input;
     end if;
    --elsif(i_input = '0' and int_hold_flag = '0') then
        --int_hold_flag <= '1';
    --end if;
  end if;
end process p_rising_edge_detector;

o_pulse            <= o_pulse_reg;

end rtl;


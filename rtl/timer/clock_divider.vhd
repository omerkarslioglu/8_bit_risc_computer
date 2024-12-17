library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- clock source and clock divider

entity clock_divider is
    port ( 
        clk                     : in std_logic;
        rst                     : in std_logic;
        timer_enable            : in std_logic;
        channel_enable          : in std_logic;
        divider_value           : in std_logic_vector(7 downto 0);
        clk_out                 : out std_logic
        );
end clock_divider;

architecture Behavioral of clock_divider is

    signal cnt                  : std_logic_vector(7 downto 0)  := "00000000";
    signal tmp                  : std_logic                     := '0';
    signal reg_divider_val      : std_logic_vector(7 downto 0)  := "00000000";

begin

reg_divider_val <= divider_value+"00000001";

    process(clk) begin
        --if(rst='1') then
            --cnt<="00000000";
            --tmp<='0';
            
        if(rising_edge(clk)) then
            if((timer_enable='1') and (channel_enable='1')) then
                cnt <= cnt + 1;
                if(cnt=reg_divider_val) then    -- reg_divider_val must be written extra one addition
                                                -- ex: if division 0, must be written 1
                    tmp <= not tmp;
                    cnt <="00000000";
                end if;
            elsif(rst = '1') then
                cnt<="00000000"; 
                tmp<='0';        
            end if;
        end if;
    end process;

clk_out <= tmp;
            
end Behavioral;

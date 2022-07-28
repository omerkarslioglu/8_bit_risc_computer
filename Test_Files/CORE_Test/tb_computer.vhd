library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_computer is
--  Port ( );
end tb_computer;

architecture Behavioral of tb_computer is
component computer is
	port(	
			clk			: in std_logic;
			--clk_int	    : in std_logic;
			rst			: in std_logic;
			port_in_00	: in std_logic_vector(7 downto 0);
			port_in_01	: in std_logic_vector(7 downto 0);
--			port_in_02	: in std_logic_vector(7 downto 0);
--			port_in_03	: in std_logic_vector(7 downto 0);
--			port_in_04	: in std_logic_vector(7 downto 0);
--			port_in_05	: in std_logic_vector(7 downto 0);
--			port_in_06	: in std_logic_vector(7 downto 0);
--			port_in_07	: in std_logic_vector(7 downto 0);
--			port_in_08	: in std_logic_vector(7 downto 0);
--			port_in_09	: in std_logic_vector(7 downto 0);
--			port_in_10	: in std_logic_vector(7 downto 0);
--			port_in_11	: in std_logic_vector(7 downto 0);
--			port_in_12	: in std_logic_vector(7 downto 0);
--			port_in_13	: in std_logic_vector(7 downto 0);
--			port_in_14	: in std_logic_vector(7 downto 0);
--			port_in_15	: in std_logic_vector(7 downto 0);
			-- IC_Signal_i	: in std_logic_vector(7 downto 0); 	-- Interrupt controller signal shows which peripheral
            -- IC_Flag_i   : in std_logic;                    -- interrupt flag
			-- Output:			
			port_out_00	: out std_logic_vector(7 downto 0);
			port_out_01	: out std_logic_vector(7 downto 0);
--			port_out_02	: out std_logic_vector(7 downto 0);
--			port_out_03	: out std_logic_vector(7 downto 0);
--			port_out_04	: out std_logic_vector(7 downto 0);
--			port_out_05	: out std_logic_vector(7 downto 0);
--			port_out_06	: out std_logic_vector(7 downto 0);
--			port_out_07	: out std_logic_vector(7 downto 0);
--			port_out_08	: out std_logic_vector(7 downto 0);
--			port_out_09	: out std_logic_vector(7 downto 0);
--			port_out_10	: out std_logic_vector(7 downto 0);
--			port_out_11	: out std_logic_vector(7 downto 0);
--			port_out_12	: out std_logic_vector(7 downto 0);
--			port_out_13	: out std_logic_vector(7 downto 0);
--			port_out_14	: out std_logic_vector(7 downto 0);
--			port_out_15	: out std_logic_vector(7 downto 0);
		    pwm_out_1_1	   : out std_logic;
            pwm_out_1_2    : out std_logic;
            pwm_out_2_1    : out std_logic;
            pwm_out_2_2    : out std_logic
	
	);
end component;

--
constant clock_period : time := 125 ns; -- 8mhz
constant clock_period_int: time :=5ns;
--
signal clk			: std_logic;
signal clk_int		: std_logic;
signal rst			: std_logic;
signal port_in_00	: std_logic_vector(7 downto 0);
signal port_in_01	: std_logic_vector(7 downto 0);
--signal port_in_02	: std_logic_vector(7 downto 0);
--signal port_in_03	: std_logic_vector(7 downto 0);
--signal port_in_04	: std_logic_vector(7 downto 0);
--signal port_in_05	: std_logic_vector(7 downto 0);
--signal port_in_06	: std_logic_vector(7 downto 0);
--signal port_in_07	: std_logic_vector(7 downto 0);
--signal port_in_08	: std_logic_vector(7 downto 0);
--signal port_in_09	: std_logic_vector(7 downto 0);
--signal port_in_10	: std_logic_vector(7 downto 0);
--signal port_in_11	: std_logic_vector(7 downto 0);
--signal port_in_12	: std_logic_vector(7 downto 0);
--signal port_in_13	: std_logic_vector(7 downto 0);
--signal port_in_14	: std_logic_vector(7 downto 0);
--signal port_in_15	: std_logic_vector(7 downto 0);
--signal IC_Signal_i	:  std_logic_vector(7 downto 0); 	-- Interrupt controller signal shows which peripheral
--signal IC_Flag_i    :  std_logic;                       -- interrupt flag
			
signal port_out_00	: std_logic_vector(7 downto 0);
signal port_out_01	: std_logic_vector(7 downto 0);
signal pwm_out_1_1	: std_logic;
signal pwm_out_1_2	: std_logic;
signal pwm_out_2_1	: std_logic;
signal pwm_out_2_2	: std_logic;


begin

clock_process: process
               begin
                    clk <= '0';
                    wait for clock_period/2;
                    clk <= '1';
                    wait for clock_period/2;
               end process;

clock_process_int: process
               begin
                    clk_int <= '0';
                    wait for clock_period_int/2;
                    clk_int <= '1';
                    wait for clock_period_int/2;
               end process;

uut: computer port map
(
    clk			=> clk			,
    --clk_int		=> clk_int		,
    rst			=> rst			,
    port_in_00	=> port_in_00	,
    port_in_01	=> port_in_01	,
--    port_in_02	=> port_in_02	,
--    port_in_03	=> port_in_03	,
--    port_in_04	=> port_in_04	,
--    port_in_05	=> port_in_05	,
--    port_in_06	=> port_in_06	,
--    port_in_07	=> port_in_07	,
--    port_in_08	=> port_in_08	,
    
--    port_in_12	=> port_in_12	,
--    port_in_13	=> port_in_13	,
--    port_in_14	=> port_in_14	,
    --port_in_15	=> port_in_15	,
                                
    port_out_00 => port_out_00  ,
    port_out_01 => port_out_01  ,
--    port_out_02 => port_out_02  ,
--    port_out_03 => port_out_03  ,
--    port_out_04 => port_out_04  ,
--    port_out_05 => port_out_05  ,
--    port_out_06	=> port_out_06  ,
--    port_out_07	=> port_out_07  ,
--    port_out_08	=> port_out_08  ,
--    port_out_09	=> port_out_09  ,
--    port_out_10	=> port_out_10  ,
--    port_out_11	=> port_out_11  ,
--    port_out_12	=> port_out_12  ,
--    port_out_13	=> port_out_13  ,
--    port_out_14	=> port_out_14  ,
--    port_out_15	=> port_out_15 
    pwm_out_1_1 => pwm_out_1_1,
    pwm_out_1_2 => pwm_out_1_2,
    pwm_out_2_1 => pwm_out_2_1,
    pwm_out_2_2 => pwm_out_2_2
);

process
begin
rst <= '1';
port_in_01 <= "00000000";
wait for 1000ns;
rst <= '0';
wait for clock_period*70;

--port_in_00 <= "11110011";  -- 13 in decimal
--port_in_01 <= x"0D";
--port_in_02 <= x"0F";

wait for 500us;

 --interrupt test for motor controller
 for i in 1 to 30 loop
port_in_01 <= "00000001";
wait for clock_period*2;
port_in_01 <= "00000000";

wait for 500us;

port_in_01 <= "00000001";
wait for clock_period*2;
port_in_01 <= "00000000";

wait for 500us;

port_in_01 <= "00000001";
wait for clock_period*2;
port_in_01 <= "00000000";
end loop;

 -- mode test for motor controller
--port_in_00 <= "00000001"; 
--wait for 500us; 

--port_in_00 <= "00000010"; 
--wait for 500us;  

--wait for clock_period*200;

--port_in_00 <= "00000001";
--wait for 200ns;
--port_in_00 <= "00000000";

wait;

end process;

end Behavioral;

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity computer is
    port (  
        clk			: in std_logic;
        --clk_int     : in std_logic;
        rst			: in std_logic;
        port_in_00	: in std_logic_vector(7 downto 0);
        port_in_01	: in std_logic_vector(7 downto 0);
--        port_in_02	: in std_logic_vector(7 downto 0);
--        port_in_03	: in std_logic_vector(7 downto 0);
--        port_in_04	: in std_logic_vector(7 downto 0);
--        port_in_05	: in std_logic_vector(7 downto 0);
--        port_in_06	: in std_logic_vector(7 downto 0);
--        port_in_07	: in std_logic_vector(7 downto 0);
--        port_in_08	: in std_logic_vector(7 downto 0);
--        port_in_09	: in std_logic_vector(7 downto 0);
--        port_in_10	: in std_logic_vector(7 downto 0);
--        port_in_11	: in std_logic_vector(7 downto 0);
--        port_in_12	: in std_logic_vector(7 downto 0);
--        port_in_13	: in std_logic_vector(7 downto 0);
--        port_in_14	: in std_logic_vector(7 downto 0);
--        port_in_15	: in std_logic_vector(7 downto 0);
        -- IC_Signal_i	: in std_logic_vector(7 downto 0); 	-- Interrupt controller signal shows which peripheral
        -- IC_Flag_i    : in std_logic;                    -- interrupt flag
        -- Output:			
        port_out_00	: out std_logic_vector(7 downto 0);
        port_out_01	: out std_logic_vector(7 downto 0);
--        port_out_02	: out std_logic_vector(7 downto 0);
--        port_out_03	: out std_logic_vector(7 downto 0);
--        port_out_04	: out std_logic_vector(7 downto 0);
--        port_out_05	: out std_logic_vector(7 downto 0);
--        port_out_06	: out std_logic_vector(7 downto 0);
--        port_out_07	: out std_logic_vector(7 downto 0);
--        port_out_08	: out std_logic_vector(7 downto 0);
--        port_out_09	: out std_logic_vector(7 downto 0);
--        port_out_10	: out std_logic_vector(7 downto 0);
--        port_out_11	: out std_logic_vector(7 downto 0);
--        port_out_12	: out std_logic_vector(7 downto 0);
--        port_out_13	: out std_logic_vector(7 downto 0);
--        port_out_14	: out std_logic_vector(7 downto 0);
--        port_out_15	: out std_logic_vector(7 downto 0);
		pwm_out_1_1	: out std_logic;
		pwm_out_1_2	: out std_logic;
		pwm_out_2_1	: out std_logic;
		pwm_out_2_2	: out std_logic
    );
end entity;

architecture arch of computer is

-- CPU:
component CPU is
	port(
		clk			: in std_logic;
		rst			: in std_logic;
		from_memory	: in std_logic_vector(7 downto 0);
		IC_Signal_i	: in std_logic_vector(7 downto 0); 	-- Interrupt controller signal shows which peripheral
		IC_Flag_i	: in std_logic; 					-- interrupt flag
		-- Outputs:
		to_memory	: out std_logic_vector(7 downto 0);
		write_en	: out std_logic;
		address		: out std_logic_vector(7 downto 0);
		IC_reset_o	: out std_logic			
	);
end component;

-- memory:
component memory is
	port(
		clk			                : in std_logic;
		rst			                : in std_logic;
		address		                : in std_logic_vector(7 downto 0);
		data_in		                : in std_logic_vector(7 downto 0);
		write_en 	                : in std_logic;						-- CPU tarafindan gonderilen kontrol sinyali / yaz emri
		port_in_00	                : in std_logic_vector(7 downto 0); -- I/O (Inputs) Port-A (just set at constraint)
		port_in_01	                : in std_logic_vector(7 downto 0); -- I/O (Inputs) Port-B (just set at constraint)
        --    Those are commented for implementation
--		port_in_02	                : in std_logic_vector(7 downto 0); 
--		port_in_03	                : in std_logic_vector(7 downto 0); 
--		port_in_04	                : in std_logic_vector(7 downto 0); 
--		port_in_05	                : in std_logic_vector(7 downto 0); 
--		port_in_06	                : in std_logic_vector(7 downto 0); 
--		port_in_07	                : in std_logic_vector(7 downto 0); 
--		port_in_08	                : in std_logic_vector(7 downto 0);
		port_in_09	                : in std_logic_vector(7 downto 0); -- tim1 out reg
		port_in_10	                : in std_logic_vector(7 downto 0); -- tim2 out reg
		port_in_11	                : in std_logic_vector(7 downto 0); -- IC_Signal_o from ICU
        --    Those are commented for implementation
--		port_in_12	                : in std_logic_vector(7 downto 0);
--		port_in_13	                : in std_logic_vector(7 downto 0);
--		port_in_14	                : in std_logic_vector(7 downto 0);
--		port_in_15	                : in std_logic_vector(7 downto 0);
		
        -- Output:
		data_out	                : out std_logic_vector(7 downto 0);
		--
		port_out_00	                : out std_logic_vector(7 downto 0); -- I/O (Outputs) Port-A
		port_out_01	                : out std_logic_vector(7 downto 0); -- I/O (Outputs) Port-B
		port_out_02	                : out std_logic_vector(7 downto 0); -- tim1 control_reg_1 
		port_out_03	                : out std_logic_vector(7 downto 0); -- tim1 control_reg_2
		port_out_04	                : out std_logic_vector(7 downto 0); -- tim1 prescaler_reg  
		port_out_05	                : out std_logic_vector(7 downto 0); -- tim1 auto_reload_reg
		port_out_06	                : out std_logic_vector(7 downto 0); -- tim1 ccr_reg_ch1    
		port_out_07	                : out std_logic_vector(7 downto 0); -- tim1 ccr_reg_ch2    
		port_out_08	                : out std_logic_vector(7 downto 0); -- tim2 control_reg_1 
		port_out_09	                : out std_logic_vector(7 downto 0); -- tim2 control_reg_2
		port_out_10	                : out std_logic_vector(7 downto 0); -- tim2 prescaler_reg  
		port_out_11	                : out std_logic_vector(7 downto 0); -- tim2 auto_reload_reg
		port_out_12	                : out std_logic_vector(7 downto 0); -- tim2 ccr_reg_ch1  (not ch2 ccr (pwm))  
		port_out_13	                : out std_logic_vector(7 downto 0); -- ICU interrupt_control_reg1_i
		port_out_14	                : out std_logic_vector(7 downto 0); -- ICU interrupt_control_reg2_i
		port_out_15	                : out std_logic_vector(7 downto 0)  -- ICU interrupt_control_reg3_i
	);
end component;

component timer_top is
	port(
	    clk                         : in std_logic;
        rst                         : in std_logic;
        control_reg_1               : in std_logic_vector(7 downto 0); 
        control_reg_2               : in std_logic_vector(7 downto 0);
        prescaler_reg               : in std_logic_vector(7 downto 0); 	-- for clock divider
        auto_reload_reg             : in std_logic_vector(7 downto 0); 	-- for pwm
        ccr_reg_ch1                 : in std_logic_vector(7 downto 0); 	-- ccr reg for pwm duty=ccr/arr
        ccr_reg_ch2                 : in std_logic_vector(7 downto 0); 	-- ccr reg for pwm duty=ccr/arr
		
        pwm_out                     : out std_logic_vector(1 downto 0);	-- pwm out for two channel (to external i/o)
        timer_out_reg               : out std_logic_vector(7 downto 0) 
	);
end component;

component interrupt_controller_unit is
	port(
	    clk                         : in std_logic;
		interrupt_control_reg1_i	: in std_logic_vector(7 downto 0); 
		interrupt_control_reg2_i	: in std_logic_vector(7 downto 0); 
		interrupt_control_reg3_i	: in std_logic_vector(7 downto 0); 
		IC_Signal_i					: in std_logic_vector(7 downto 0); -- tick signals from peripherals
		IC_PortA_Signal_i			: in std_logic_vector(7 downto 0);
		IC_PortB_Signal_i			: in std_logic_vector(7 downto 0);
		IC_Reset_i					: in std_logic; -- clear IC flag
		
		IC_Signal_o					: out std_logic_vector(7 downto 0);
		IC_Flag_o 					: out std_logic
	);
end component;

signal address  		            : std_logic_vector(7 downto 0);
signal data_in  		            : std_logic_vector(7 downto 0);
signal data_out 		            : std_logic_vector(7 downto 0);
signal write_en 		            : std_logic;
signal IC_reset_cpu_o	            : std_logic;
signal IC_Flag_cpu_i	            : std_logic;

signal portout02		            : std_logic_vector(7 downto 0);
signal portout03		            : std_logic_vector(7 downto 0);
signal portout04		            : std_logic_vector(7 downto 0);
signal portout05		            : std_logic_vector(7 downto 0);
signal portout06		            : std_logic_vector(7 downto 0);
signal portout07		            : std_logic_vector(7 downto 0);
signal portout08		            : std_logic_vector(7 downto 0);
signal portout09		            : std_logic_vector(7 downto 0);
signal portout10		            : std_logic_vector(7 downto 0);
signal portout11		            : std_logic_vector(7 downto 0);
signal portout12		            : std_logic_vector(7 downto 0);
signal portout13		            : std_logic_vector(7 downto 0);
signal portout14		            : std_logic_vector(7 downto 0);
signal portout15		            : std_logic_vector(7 downto 0);

signal portin09			            : std_logic_vector(7 downto 0);
signal portin10			            : std_logic_vector(7 downto 0);
signal portin11			            : std_logic_vector(7 downto 0); -- ICU output register

-- for input porta and portb
signal portin00			            : std_logic_vector(7 downto 0);
signal portin01			            : std_logic_vector(7 downto 0);
begin



-- CPU port map
cpu_module: CPU port map
    (
        clk				    => clk,
        rst			        => rst,
        from_memory	        => data_out,
        IC_Signal_i	        => portin11, 	-- Interrupt controller signal shows which peripheral
        IC_Flag_i           => IC_Flag_cpu_i,
        -- Outputs
        to_memory	        => data_in,
        write_en	        => write_en,
        address		        => address,
        IC_reset_o          => IC_reset_cpu_o
    );

-- Memory port map:
memory_module: memory port map
(
    clk				            =>	clk,		
    rst			                =>  rst,
    address		                =>  address,
    data_in		                =>  data_in,
    write_en 	                =>  write_en,
    port_in_00	                =>  port_in_00,   
    port_in_01	                =>  port_in_01,
--    Those are commented for implementation
--    port_in_02	    =>  port_in_02,
--    port_in_03	    =>  port_in_03,
--    port_in_04	    =>  port_in_04,
--    port_in_05	    =>  port_in_05,
--    port_in_06	    =>  port_in_06,
--    port_in_07	    =>  port_in_07,
--    port_in_08	    =>  port_in_08,
    
    port_in_09	                =>  portin09,
    port_in_10	                =>  portin10,
    port_in_11	                =>  portin11,

--    Those are commented for implementation
--    port_in_12	    =>  port_in_12,
--    port_in_13	    =>  port_in_13,
--    port_in_14	    =>  port_in_14,
--    port_in_15	    =>  x"00",
   
    -- Output:        
    data_out	                =>  data_out,
    --                 
    port_out_00	                =>  port_out_00,
    port_out_01	                =>  port_out_01,
    port_out_02	                =>  portout02,
    port_out_03	                =>  portout03,
    port_out_04	                =>  portout04,
    port_out_05	                =>  portout05,
    port_out_06	                =>  portout06,
    port_out_07	                =>  portout07,
    port_out_08	                =>  portout08,
    port_out_09	                =>  portout09,
    port_out_10	                =>  portout10,
    port_out_11	                =>  portout11,
    port_out_12	                =>  portout12,
    port_out_13	                =>  portout13,
    port_out_14	                =>  portout14,
    port_out_15	                =>  portout15	
);

timer1: timer_top port map(
	clk            				=> clk,
    rst                 		=> rst,
    control_reg_1       		=> portout02,
    control_reg_2       		=> portout03,
    prescaler_reg       		=> portout04,
    auto_reload_reg     		=> portout05,
    ccr_reg_ch1         		=> portout06,
    ccr_reg_ch2         		=> portout07,
							
    pwm_out(0)             		=> pwm_out_1_1,
	pwm_out(1)             		=> pwm_out_1_2,
    timer_out_reg       		=> portin09
);

timer2: timer_top port map(
	clk            				=> clk,
    rst                 		=> rst,
    control_reg_1       		=> portout08,
    control_reg_2       		=> portout09,
    prescaler_reg       		=> portout10,
    auto_reload_reg     		=> portout11,
    ccr_reg_ch1         		=> portout12,
    ccr_reg_ch2         		=> x"00",
							
    pwm_out(0)             		=> pwm_out_2_1,
	pwm_out(1)             		=> pwm_out_2_2,
    timer_out_reg       		=> portin10
);


ICU: interrupt_controller_unit port map(
    clk                         => clk,
	interrupt_control_reg1_i	=> portout13,
	interrupt_control_reg2_i    => portout14,
	interrupt_control_reg3_i    => portout15,
	IC_Signal_i(1 downto 0)		=> "00",
	IC_Signal_i(2)				=> portin09(0), -- interrupt works just for ch1 of timers
	IC_Signal_i(3)				=> portin10(0),
	IC_Signal_i(7 downto 4)		=> "0000",
	IC_PortA_Signal_i		    => port_in_00,
	IC_PortB_Signal_i		    => port_in_01,
    IC_Reset_i				    => IC_reset_cpu_o,
					
    IC_Signal_o				    => portin11,
    IC_Flag_o 				    => IC_Flag_cpu_i
);

end architecture;
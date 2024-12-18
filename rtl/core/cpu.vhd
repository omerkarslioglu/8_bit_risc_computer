library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity cpu is
    port (
        clk           : in std_logic;
        rst           : in std_logic;
        from_memory   : in std_logic_vector(7 downto 0);
		    IC_Signal_i   : in std_logic_vector(7 downto 0); -- Interrupt controller signal shows which peripheral
		    IC_Flag_i     : in std_logic; -- interrupt flag
        -- Outputs :
        to_memory     : out std_logic_vector(7 downto 0);
        write_en      : out std_logic;
        address       : out std_logic_vector(7 downto 0);
		    IC_reset_o    : out std_logic
    );
end entity;

architecture arch of cpu is
-- Control Unit:
    component control_unit is
        port(
            clk				    : in std_logic;
            rst				    :	in std_logic;
            CCR_Result	  :	in std_logic_vector(3 downto 0);
            IR				    :	in std_logic_vector(7 downto 0);
			      IC_Signal_i	  : in std_logic_vector(7 downto 0); -- Interrupt controller signal shows which peripheral
			      IC_Flag_i		  : in std_logic; -- interrupt flag
			      pc_in_scr_i   : in std_logic;
            -- Outputs :
            IR_Load 		  : out std_logic; -- Instruction Register Load
            MAR_Load 		  : out std_logic; -- Memory Access Register Load
            PC_Load 		  : out std_logic; -- Program Counter Register Load
            SP1_Load 	    : out std_logic;
            SP2_Load      : out std_logic;           
            PC_Inc			  : out std_logic;	-- Program Counter Register Incrementer
            A_Load			  : out std_logic;
            B_Load 			  : out std_logic;
            ALU_Sel			  : out std_logic_vector(4 downto 0);
            CCR_Load		  : out std_logic; -- Condition code register
            BUS1_Sel		  : out std_logic_vector(2 downto 0);
            BUS2_Sel		  : out std_logic_vector(1 downto 0);
            write_en		  : out std_logic		
        );
    end component;

   component data_path is 
        port(
            clk 		      : in std_logic;
            rst 		      : in std_logic;
            IR_Load 	    : in std_logic; -- Instruction Register Load
            MAR_Load 	    : in std_logic; -- Memory Access Register Load
            PC_Load 	    : in std_logic; -- Program Counter Register Load
            SP1_Load 	    : in std_logic;
            SP2_Load      : in std_logic;
            PC_Inc		    : in std_logic;	-- Program Counter Register Incrementer
            A_Load		    : in std_logic;
            B_Load 		    : in std_logic;
            ALU_Sel		    : in std_logic_vector(4 downto 0);
            CCR_Load	    : in std_logic; -- Condition code register
            BUS1_Sel	    : in std_logic_vector(2 downto 0);
            BUS2_Sel	    : in std_logic_vector(1 downto 0);
            from_memory	  : in std_logic_vector(7 downto 0);
            
            -- Outputs :
            IR			      : out std_logic_vector(7 downto 0);
            address 	    : out std_logic_vector(7 downto 0); -- address to memory
            CCR_Result	  : out std_logic_vector(3 downto 0); -- NZVC
            to_memory	    : out std_logic_vector(7 downto 0);  -- data to memery
            IC_reset_o	  : out std_logic;
            pc_in_scr_o   : out std_logic
            
        );	
    end component;

    signal IR_Load          : std_logic;
    signal IR               : std_logic_vector(7 downto 0);
    signal MAR_Load         : std_logic;
    signal PC_Load          : std_logic;
    signal SP1_Load 	      : std_logic;
    signal SP2_Load         : std_logic;
    signal PC_Inc           : std_logic;
    signal A_Load           : std_logic;
    signal B_Load           : std_logic;
    signal ALU_Sel          : std_logic_vector(4 downto 0);
    signal CCR_Result       : std_logic_vector(3 downto 0);
    signal CCR_Load         : std_logic;
    signal Bus2_Sel         : std_logic_vector(1 downto 0);
    signal BUS1_Sel         : std_logic_vector(2 downto 0); 
    signal pc_in_scr_signal : std_logic;

begin

-- Control Unit :
control_unit_module : control_unit port map
    (
		clk => clk,		
    rst => rst,		
	  CCR_Result => CCR_Result,	
	  IR => IR,
		IC_Signal_i => IC_Signal_i,
		IC_Flag_i => IC_Flag_i,
		pc_in_scr_i => pc_in_scr_signal,
	    -- Outputs :	   -- Outputs :
	  IR_Load => IR_Load, 	
	  MAR_Load => MAR_Load,	
	  PC_Load => PC_Load,
	  SP1_Load => SP1_Load,
    SP2_Load => SP2_Load,	
	  PC_Inc => PC_Inc,	
	  A_Load => A_Load,	
	  B_Load => B_Load,	
	  ALU_Sel => ALU_Sel,	
	  CCR_Load => CCR_Load,	
	  BUS1_Sel => BUS1_Sel,	
	  BUS2_Sel => BUS2_Sel,	
	  write_en => write_en
		--IC_reset_o		=> IC_reset_o
    );
	
-- Data Path : 
data_path_module : data_path port map
	(
		clk =>	 clk,	
		rst => rst,		 
		IR_Load => IR_Load, 	 
		MAR_Load => MAR_Load,	 
		PC_Load => PC_Load,
		SP1_Load => SP1_Load,
    SP2_Load => SP2_Load,
		PC_Inc => PC_Inc,	 
		A_Load => A_Load,	 
		B_Load => B_Load,	
		ALU_Sel => ALU_Sel,	
		CCR_Load => CCR_Load,	 
		BUS1_Sel => BUS1_Sel, 
		BUS2_Sel => BUS2_Sel, 
		from_memory	=> from_memory, 			
		-- Outputs :
		IR => IR,			 
		address=> address, 	 
		CCR_Result => CCR_Result,	 
		to_memory => to_memory,
		IC_reset_o => IC_reset_o,
		pc_in_scr_o => pc_in_scr_signal	
	);
    

end architecture;
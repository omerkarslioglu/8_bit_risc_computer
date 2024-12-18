library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity data_path is 
	port(
		clk 						: in std_logic;
		rst 						: in std_logic;
		IR_Load 				: in std_logic; -- Instruction Register Load
		MAR_Load 				: in std_logic; -- Memory Access Register Load
		PC_Load 				: in std_logic; -- Program Counter Register Load
		SP1_Load 				: in std_logic;
		SP2_Load 				: in std_logic;
		PC_Inc					: in std_logic;	-- Program Counter Register Incrementer
		A_Load					: in std_logic;
		B_Load 					: in std_logic;
		ALU_Sel					: in std_logic_vector(4 downto 0);
		CCR_Load				: in std_logic; -- Condition code register
		BUS1_Sel				: in std_logic_vector(2 downto 0);
		BUS2_Sel				: in std_logic_vector(1 downto 0);
		from_memory			: in std_logic_vector(7 downto 0);
		
		-- Outputs :
		IR							: out std_logic_vector(7 downto 0);
		address 				: out std_logic_vector(7 downto 0); -- address to memory
		CCR_Result			: out std_logic_vector(3 downto 0); -- NZVC
		to_memory				: out std_logic_vector(7 downto 0);  -- data to memery
		IC_reset_o  		: out std_logic;
		pc_in_scr_o 		: out std_logic
	);	
end data_path;

architecture arch of data_path is


-- Arithmatic Logic Unit
component ALU is
	port(
		A 			    : in std_logic_vector(7 downto 0);
		B 			    : in std_logic_vector(7 downto 0);
		ALU_Sel	    : in std_logic_vector(4 downto 0);
		
		-- Outputs
		NZVC   		  : out std_logic_vector(3 downto 0);
		ALU_result 	: out std_logic_vector(7 downto 0)
	);
end component;

-- Data Path Internal Signals
signal BUS1 		: std_logic_vector(7 downto 0); -- BUS1 Data
signal BUS2 		: std_logic_vector(7 downto 0); -- BUS2 Data
signal ALU_result 	: std_logic_vector(7 downto 0); 
signal IR_reg	 	: std_logic_vector(7 downto 0);
signal MAR			: std_logic_vector(7 downto 0); -- Address
signal PC			  : std_logic_vector(7 downto 0);
signal SP1			: std_logic_vector(7 downto 0);
signal SP2			: std_logic_vector(7 downto 0);
signal A_reg		: std_logic_vector(7 downto 0);
signal B_reg		: std_logic_vector(7 downto 0);
signal CCR_in		: std_logic_vector(3 downto 0);
signal CCR			: std_logic_vector(3 downto 0); -- Condition Info.
signal PC_IN_ISR: std_logic;

--signal IC_reset_o_reg : std_logic;

-- rom address for interrupt handler
constant interrupt_handle_address_in_rom :std_logic_vector(7 downto 0) :=x"5a"; -- 90 in decimal

begin
	-- BUS1 Mux :
	BUS1 <= PC			when BUS1_Sel <= "000" else
			A_reg		when BUS1_Sel <= "001" else
			B_reg		when BUS1_Sel <= "010" else 
			SP1         when BUS1_Sel <= "011" else
			SP2         when BUS1_Sel <= "100" else (others => '0');
	-- BUS2 Mux :
	BUS2 <= ALU_result 	when BUS2_Sel <= "00" else
			BUS1		when BUS2_Sel <= "01" else
			from_memory	when BUS2_Sel <= "10" else 
			interrupt_handle_address_in_rom when BUS2_Sel <= "11" else (others => '0');

	-- Instruction Register 
	process(clk,rst)
	begin
		if(rst = '1') then
			IR_reg <= (others => '0');
		elsif(rising_edge(clk)) then
			if(IR_Load = '1') then
				IR_reg <= BUS2;
			end if;
		end if;
	end process;
	IR<=IR_reg;
	
	-- Memory Access Register
	process(clk,rst)
	begin
		if(rst = '1') then
			MAR <= (others => '0');
		elsif(rising_edge(clk)) then
			if(MAR_Load = '1') then
				MAR <= BUS2;
			end if;
		end if;
	end process;
	address <= MAR;
	
	-- Program Counter Register
	process(clk,rst)
	begin
		if(rst = '1') then
			PC <= (others => '0');
		elsif(rising_edge(clk)) then
			if(PC_Load = '1') then
				PC <= BUS2;
			elsif(PC_Inc = '1') then
				PC <= PC + X"01";
			end if;
			if(PC >= x"59") then
			    PC_IN_ISR <= '1';
			else
			    PC_IN_ISR <= '0';
			end if;
		end if;
	end process;
	
	pc_in_scr_o <= PC_IN_ISR;
	
	-- Stack Pointer Register 1
	process(clk,rst)
	begin
	   if(rst='1') then
	       SP1 <= (others=>'0');
	   elsif(rising_edge(clk)) then
	       if(SP1_Load = '1') then
	           SP1 <= BUS2;
	       end if;
	   end if;
	end process;
	
	-- Stack Pointer Register 2 (for interrupt)
        process(clk,rst)
        begin
           
           if(rst='1') then
               SP2 <= (others=>'0');
           elsif(rising_edge(clk)) then
               if(SP2_Load = '1') then
                   --IC_reset_o_reg <='1';
                   SP2 <= BUS2;
               --else
                   --IC_reset_o_reg <='0';
               end if;
           end if;
        end process;          
	
	IC_reset_o	 <= '1' when(rst = '1' or BUS2_Sel = "11") else '0';
	
	-- A Register
	process(clk,rst)
	begin
		if(rst = '1') then
			A_reg <= (others => '0');
		elsif(rising_edge(clk)) then
			if(A_Load = '1') then
				A_reg <= BUS2;
			end if;
		end if;
	end process;
	
	-- B Register
	process(clk,rst)
	begin
		if(rst = '1') then
			B_reg <= (others => '0');
		elsif(rising_edge(clk)) then
			if(B_Load = '1') then
				B_reg <= BUS2;
			end if;
		end if;
	end process;
	
	-- ALU port map :
	ALU_U : ALU port map
	(
		A 			=> B_reg,			
		B 			=> BUS1,
		ALU_Sel 	=> ALU_Sel,
		
		-- Outputs
		NZVC  		=> CCR_in, 		
		ALU_result	=> ALU_result
	);
	
	-- CCR Register
	process(clk,rst)
	begin
		if(rst = '1') then
			CCR <= (others => '0');
		elsif(rising_edge(clk)) then
			if(CCR_Load = '1') then
				CCR <= CCR_in;
			end if;
		end if;
	end process;
	CCR_Result <= CCR;
	
	-- Data Path to Memory
	to_memory <= BUS1 ;

end architecture;
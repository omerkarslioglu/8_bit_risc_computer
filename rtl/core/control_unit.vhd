library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity control_unit is
 port(
		clk						: in std_logic;
		rst						: in std_logic;
		CCR_Result		: in std_logic_vector(3 downto 0);
		IR						: in std_logic_vector(7 downto 0);
		IC_Signal_i		: in std_logic_vector(7 downto 0); -- Interrupt controller signal shows which peripheral
		IC_Flag_i			: in std_logic; -- interrupt flag
		pc_in_scr_i		: in std_logic;
		-- Outputs :      
		IR_Load 			: out std_logic; -- Instruction Register Load
		MAR_Load 			: out std_logic; -- Memory Access Register Load
		PC_Load 			: out std_logic; -- Program Counter Register Load
		SP1_Load 	    : out std_logic;
    SP2_Load      : out std_logic;
		PC_Inc				: out std_logic; -- Program Counter Register Incrementer
		A_Load				: out std_logic;
		B_Load 				: out std_logic;
		ALU_Sel				: out std_logic_vector(4 downto 0);
		CCR_Load			: out std_logic; -- Condition code register
		BUS1_Sel			: out std_logic_vector(2 downto 0);
		BUS2_Sel			: out std_logic_vector(1 downto 0);
		write_en			: out std_logic
		--IC_reset_o		: out std_logic
	);
end control_unit;

architecture arch of control_unit is

type state_type is	(
	STATE_FETCH_0, 
	STATE_FETCH_1, 
	STATE_FETCH_2, 
	STATE_DECODE_3,
	STATE_LDA_IMM_4, 
	STATE_LDA_IMM_5, 
	STATE_LDA_IMM_6, -- YUKLE A SABIT
	STATE_LDA_DIR_4, 
	STATE_LDA_DIR_5, 
	STATE_LDA_DIR_6, STATE_LDA_DIR_7, STATE_LDA_DIR_8, -- YUKLE A DIRECT
	STATE_LDB_IMM_4, 
	STATE_LDB_IMM_5, 
	STATE_LDB_IMM_6, -- YUKLE B SABIT
	STATE_LDB_DIR_4, 
	STATE_LDB_DIR_5, 
	STATE_LDB_DIR_6, 
	STATE_LDB_DIR_7, 
	STATE_LDB_DIR_8, -- YUKLE B DIRECT
	STATE_LOAD_PC_TO_SP1_4,
  STATE_LOAD_SP1_TO_PC_4,
  STATE_JUMP_AND_LINK_SP1_4,
	STATE_JUMP_AND_LINK_SP1_5,
	STATE_JUMP_AND_LINK_SP1_6,
  STATE_LOAD_SP1_IMM_4,
	STATE_LOAD_SP1_IMM_5,
	STATE_LOAD_SP1_IMM_6,
  STATE_LOAD_SP1_DIR_4,
	STATE_LOAD_SP1_DIR_5,
	STATE_LOAD_SP1_DIR_6,
	STATE_LOAD_SP1_DIR_7,
	STATE_LOAD_SP1_DIR_8,
	STATE_STA_DIR_4,
	STATE_STA_DIR_5,
	STATE_STA_DIR_6,
	STATE_STA_DIR_7,
	STATE_STB_DIR_4,
	STATE_STB_DIR_5,
	STATE_STB_DIR_6,
	STATE_STB_DIR_7,
	STATE_ADD_AB_4,
	STATE_SUB_AB_4,
	STATE_AND_AB_4,
	STATE_OR_AB_4,
	STATE_INC_A_4,
	STATE_INC_B_4,
	STATE_DEC_A_4,
	STATE_DEC_B_4,
	STATE_SRL_A_4,
	STATE_SLL_A_4,
	STATE_SRA_A_4,
	STATE_SLA_A_4,
	STATE_ROR_A_4,
	STATE_ROL_A_4,
	STATE_RESET_ALU_4,
	STATE_NOT_A_4,
	STATE_XOR_AB_4,
	STATE_BRA_4, 
	STATE_BRA_5, 
	STATE_BRA_6,
	STATE_BEQ_4, 
	STATE_BEQ_5, 
	STATE_BEQ_6, 
	STATE_BEQ_7,
	STATE_INTERRUPT_0, 
	STATE_INTERRUPT_1, 
	STATE_INTERRUPT_2,
	STATE_LOAD_SP2_TO_PC_4 -- just used for interrupt
);



signal current_state , next_state 	: state_type ;

-- Loads and Stores Commands
constant YUKLE_A_SBT					:std_logic_vector(7 downto 0) := x"86"; -- Immediade
constant YUKLE_A							:std_logic_vector(7 downto 0) := x"87"; -- Direct ADDRESS
constant YUKLE_B_SBT					:std_logic_vector(7 downto 0) := x"88";
constant YUKLE_B							:std_logic_vector(7 downto 0) := x"89";

constant LOAD_PC_TO_SP1				:std_logic_vector(7 downto 0) := x"90";
constant LOAD_SP1_TO_PC				:std_logic_vector(7 downto 0) := x"91";
constant JUMP_AND_LINK_SP1		:std_logic_vector(7 downto 0) := x"92";
constant LOAD_SP1_IMM   			:std_logic_vector(7 downto 0) := x"93"; -- Immediate Value
constant LOAD_SP1_DIR   			:std_logic_vector(7 downto 0) := x"94"; -- Direct Address

constant KAYDET_A							:std_logic_vector(7 downto 0) := x"96";
constant KAYDET_B							:std_logic_vector(7 downto 0) := x"97";

-- Data Manipulations
constant TOPLA_AB							:std_logic_vector(7 downto 0) :=x"42";
constant CIKAR_AB							:std_logic_vector(7 downto 0) :=x"43";
constant AND_AB								:std_logic_vector(7 downto 0) :=x"44";
constant OR_AB								:std_logic_vector(7 downto 0) :=x"45";
constant ARTTIR_A							:std_logic_vector(7 downto 0) :=x"46";
constant ARTTIR_B							:std_logic_vector(7 downto 0) :=x"47";
constant DUSUR_A							:std_logic_vector(7 downto 0) :=x"48";
constant DUSUR_B							:std_logic_vector(7 downto 0) :=x"49";
constant SRL_A								:std_logic_vector(7 downto 0) :=x"4A";
constant SLL_A								:std_logic_vector(7 downto 0) :=x"4B";
constant SRA_A								:std_logic_vector(7 downto 0) :=x"4C";
constant SLA_A								:std_logic_vector(7 downto 0) :=x"4D";
constant ROR_A								:std_logic_vector(7 downto 0) :=x"4E";
constant ROL_A								:std_logic_vector(7 downto 0) :=x"4F";
constant RESET_ALU						:std_logic_vector(7 downto 0) :=x"50";
constant NOT_A								:std_logic_vector(7 downto 0) :=x"51";
constant XOR_AB								:std_logic_vector(7 downto 0) :=x"52";

-- Branches
constant ATLA									:std_logic_vector(7 downto 0) :=x"20";
constant ATLA_NEGATIFSE				:std_logic_vector(7 downto 0) :=x"21";
constant ATLA_POZITIFSE				:std_logic_vector(7 downto 0) :=x"22";
constant ATLA_ESITSE_SIFIR		:std_logic_vector(7 downto 0) :=x"23";
constant ATLA_DEGILSE_SIFIR		:std_logic_vector(7 downto 0) :=x"24";
constant ATLA_OVERFLOW_VARSA	:std_logic_vector(7 downto 0) :=x"25";
constant ATLA_OVERFLOW_YOKSA	:std_logic_vector(7 downto 0) :=x"26";
constant ATLA_ELDE_VARSA			:std_logic_vector(7 downto 0) :=x"27";
constant ATLA_ELDE_YOKSA			:std_logic_vector(7 downto 0) :=x"28";

-- General Purpose Instruction
constant NOP									:std_logic_vector(7 downto 0) :=x"01";
constant FIR									:std_logic_vector(7 downto 0) :=x"11"; -- finish interrupt routine

begin

-- Current Logic State
process(clk,rst) 
begin
	if(rst = '1') then
		current_state <= STATE_FETCH_0;
		--IC_reset_o_reg	  <= '1';
	elsif(rising_edge(clk)) then
	    --IC_reset_o_reg	  <= '0';
		current_state <= next_state;
	end if;	
end process;

--IC_reset_o	 <= '1' when(rst='1') else '0';
--IC_reset_o	 <= '1' when(rst = '1' or IC_reset_o_reg = '1') else '0';

-- Next State Logic
process(current_state , IR, CCR_Result)
begin
	case current_state is
		when STATE_FETCH_0  =>
			next_state <= STATE_FETCH_1;
		when STATE_FETCH_1  =>
			next_state <= STATE_FETCH_2;
		when STATE_FETCH_2  =>
			next_state <= STATE_DECODE_3;
		when STATE_DECODE_3  =>
			if(IR = YUKLE_A_SBT) then
				next_state <= STATE_LDA_IMM_4;
			elsif(IR = YUKLE_A) then
				next_state <= STATE_LDA_DIR_4;
			elsif(IR = YUKLE_B_SBT) then
				next_state <= STATE_LDB_IMM_4;
			elsif(IR = YUKLE_B) then
				next_state <= STATE_LDB_DIR_4;

			elsif(IR = FIR) then
				next_state <= STATE_LOAD_SP2_TO_PC_4;
			
			elsif(IR = LOAD_PC_TO_SP1) then
        next_state <= STATE_LOAD_PC_TO_SP1_4;
			elsif(IR = LOAD_SP1_TO_PC) then
        next_state <= STATE_LOAD_SP1_TO_PC_4;
			elsif(IR = JUMP_AND_LINK_SP1) then
        next_state <= STATE_JUMP_AND_LINK_SP1_4;
			elsif(IR = LOAD_SP1_IMM) then
        next_state <= STATE_LOAD_SP1_IMM_4;
			elsif(IR = LOAD_SP1_DIR) then
        next_state <= STATE_LOAD_SP1_DIR_4;                       
                                    
			elsif(IR = KAYDET_A) then
				next_state <= STATE_STA_DIR_4;
			elsif(IR = KAYDET_B) then
				next_state <= STATE_STB_DIR_4;
			elsif(IR = TOPLA_AB) then
				next_state <= STATE_ADD_AB_4;
			elsif(IR = CIKAR_AB) then
				next_state <= STATE_SUB_AB_4;
			elsif(IR = AND_AB) then
				next_state <= STATE_AND_AB_4;
			elsif(IR = OR_AB) then
				next_state <= STATE_OR_AB_4;
			elsif(IR = ARTTIR_A) then
				next_state <= STATE_INC_A_4;
			elsif(IR = ARTTIR_B) then
				next_state <= STATE_INC_B_4;
			elsif(IR = DUSUR_A) then
				next_state <= STATE_DEC_A_4;
			elsif(IR = DUSUR_B) then
				next_state <= STATE_DEC_B_4;
			--*********************************
			
			elsif(IR = SRL_A) then
                 next_state <= STATE_SRL_A_4;
 			elsif(IR = SLL_A) then
                 next_state <= STATE_SLL_A_4;
      elsif(IR = SRA_A) then
           next_state <= STATE_SRA_A_4;
 			elsif(IR = SLA_A) then
                 next_state <= STATE_SLA_A_4;
 			elsif(IR = ROR_A) then
                 next_state <= STATE_ROR_A_4;
      elsif(IR = ROL_A) then
           next_state <= STATE_ROL_A_4;                 
                 
			elsif(IR = RESET_ALU) then
				next_state <= STATE_RESET_ALU_4;
			elsif(IR = NOT_A) then
				next_state <= STATE_NOT_A_4;
			elsif(IR = XOR_AB) then
				next_state <= STATE_XOR_AB_4;
			
			elsif(IR = ATLA) then
				next_state <= STATE_BRA_4;
				
				
			elsif(IR = ATLA_NEGATIFSE) then 
				if(CCR_Result(3) = '1') then	--NZVC , Overflow 3th bit
					next_state <= STATE_BEQ_4;
				else	-- N = '0'
					next_state <= STATE_BEQ_7;
				end if;
			
            elsif(IR = ATLA_POZITIFSE) then
				if(CCR_Result(3) = '0') then	--NZVC , Overflow 3th bit
					next_state <= STATE_BEQ_4;
				else	-- N = '1'
					next_state <= STATE_BEQ_7;
				end if;
            
                
			elsif(IR = ATLA_ESITSE_SIFIR) then -- beq
				if(CCR_Result(2) = '1') then	--NZVC , Zero 2nd bit
					next_state <= STATE_BEQ_4;
				else	-- Z = '0'
					next_state <= STATE_BEQ_7;
				end if;
			
			elsif(IR = ATLA_DEGILSE_SIFIR) then
				if(CCR_Result(2) = '0') then	--NZVC , Zero 2nd bit
					next_state <= STATE_BEQ_4;
				else	-- Z = '1'
					next_state <= STATE_BEQ_7;
				end if;
				
            elsif(IR = ATLA_OVERFLOW_VARSA) then
				if(CCR_Result(1) = '1') then	--NZVC , Overflow 1st bit
					next_state <= STATE_BEQ_4;
				else	-- O = '0'
					next_state <= STATE_BEQ_7;
				end if;

		    elsif(IR = ATLA_OVERFLOW_YOKSA) then
				if(CCR_Result(1) = '0') then	--NZVC , Overflow 1st bit
					next_state <= STATE_BEQ_4;
				else	-- O = '1'
					next_state <= STATE_BEQ_7;
				end if;

            elsif(IR = ATLA_ELDE_VARSA) then
				if(CCR_Result(0) = '1') then	--NZVC , Overflow 0st bit
					next_state <= STATE_BEQ_4;
				else	-- C = '0'
					next_state <= STATE_BEQ_7;
				end if;

            elsif(IR = ATLA_ELDE_YOKSA) then
				if(CCR_Result(0) = '0') then	--NZVC , Overflow 0st bit
					next_state <= STATE_BEQ_4;
				else	-- C = '1'
					next_state <= STATE_BEQ_7;
				end if;
                                
			else	
		        if(IC_Flag_i = '1') then
		          next_state <= STATE_INTERRUPT_0;
		        else
		          next_state <= STATE_FETCH_0;  
			end if;
		end if;
-----------------------------------------------------------

		when STATE_LDA_IMM_4 =>
			next_state <= STATE_LDA_IMM_5;
		when STATE_LDA_IMM_5 =>
			next_state <= STATE_LDA_IMM_6;
		when STATE_LDA_IMM_6 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;
		    end if;  
			
-----------------------------------------------------------		
	
		when STATE_LDA_DIR_4 =>
			next_state <= STATE_LDA_DIR_5;
		when STATE_LDA_DIR_5 =>
			next_state <= STATE_LDA_DIR_6;
		when STATE_LDA_DIR_6 =>
			next_state <= STATE_LDA_DIR_7;
		when STATE_LDA_DIR_7 =>	
			next_state <= STATE_LDA_DIR_8;
		when STATE_LDA_DIR_8 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
            end if;
-----------------------------------------------------------

		when STATE_LDB_IMM_4 =>
			next_state <= STATE_LDB_IMM_5;
		when STATE_LDB_IMM_5 =>
			next_state <= STATE_LDB_IMM_6;
		when STATE_LDB_IMM_6 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
			end if;
			
-----------------------------------------------------------		
	
		when STATE_LDB_DIR_4 =>
			next_state <= STATE_LDB_DIR_5;
		when STATE_LDB_DIR_5 =>
			next_state <= STATE_LDB_DIR_6;
		when STATE_LDB_DIR_6 =>
			next_state <= STATE_LDB_DIR_7;
		when STATE_LDB_DIR_7 =>	
			next_state <= STATE_LDB_DIR_8;
		when STATE_LDB_DIR_8 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
			end if;
--_________________________________________________________			
-----------------------------------------------------------
        when STATE_LOAD_PC_TO_SP1_4 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
            end if;
            
        when STATE_LOAD_SP1_TO_PC_4 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
            end if;
		
		when STATE_LOAD_SP2_TO_PC_4 => -- just used for interrupt
		        next_state <= STATE_FETCH_0;  
            
        when STATE_JUMP_AND_LINK_SP1_4 =>
            next_state <= STATE_JUMP_AND_LINK_SP1_5;
        when STATE_JUMP_AND_LINK_SP1_5 =>
            next_state <= STATE_JUMP_AND_LINK_SP1_6;
        when STATE_JUMP_AND_LINK_SP1_6 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
            end if;
            
        when STATE_LOAD_SP1_IMM_4 =>
            next_state <= STATE_LOAD_SP1_IMM_5;
        when STATE_LOAD_SP1_IMM_5 =>
            next_state <= STATE_LOAD_SP1_IMM_6;
        when STATE_LOAD_SP1_IMM_6 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
            end if;
            
        when STATE_LOAD_SP1_DIR_4 =>
            next_state <= STATE_LOAD_SP1_DIR_5;
        when STATE_LOAD_SP1_DIR_5 =>
            next_state <= STATE_LOAD_SP1_DIR_6;
        when STATE_LOAD_SP1_DIR_6 =>
            next_state <= STATE_LOAD_SP1_DIR_7;
        when STATE_LOAD_SP1_DIR_7 =>
            next_state <= STATE_LOAD_SP1_DIR_8;
        when STATE_LOAD_SP1_DIR_8 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;
		    end if;  
--_________________________________________________________	
-----------------------------------------------------------
			
		when STATE_STA_DIR_4 =>
			next_state <= STATE_STA_DIR_5;
		when STATE_STA_DIR_5 =>
			next_state <= STATE_STA_DIR_6;
		when STATE_STA_DIR_6 =>
			next_state <= STATE_STA_DIR_7;
		when STATE_STA_DIR_7 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
            end if;
-----------------------------------------------------------
			
		when STATE_STB_DIR_4 =>
			next_state <= STATE_STB_DIR_5;
		when STATE_STB_DIR_5 =>
			next_state <= STATE_STB_DIR_6;
		when STATE_STB_DIR_6 =>
			next_state <= STATE_STB_DIR_7;
		when STATE_STB_DIR_7 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
            end if;
-----------------------------------------------------------

		when STATE_ADD_AB_4 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
            end if;
-----------------------------------------------------------

		when STATE_SUB_AB_4 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
            end if;
-----------------------------------------------------------

		when STATE_AND_AB_4 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
            end if;
-----------------------------------------------------------

		when STATE_OR_AB_4 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
            end if;
-----------------------------------------------------------

		when STATE_INC_A_4 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
            end if;
            
        when STATE_INC_B_4 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
            end if;
            
-----------------------------------------------------------

		when STATE_DEC_A_4 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
		    end if;
		    
		when STATE_DEC_B_4 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
            end if;
-----------------------------------------------------------

		when STATE_BRA_4 =>
			next_state <= STATE_BRA_5;
		when STATE_BRA_5 =>
			next_state <= STATE_BRA_6;
		when STATE_BRA_6 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
			end if;
				
-----------------------------------------------------------

		when STATE_BEQ_4 =>
			next_state <= STATE_BEQ_5;
		when STATE_BEQ_5 =>
			next_state <= STATE_BEQ_6;
		when STATE_BEQ_6 =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
			end if;
			
		when STATE_BEQ_7 =>	-- Z = '0' or others state condition , command bypass
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
			end if;
	    --when branch komutlari yazilacak --  degisecek
			
-----------------------------------------------------------
		when STATE_INTERRUPT_0 =>
			next_state <= STATE_INTERRUPT_1;
		when STATE_INTERRUPT_1 =>
--			if(IC_Flag_i = '1') then
--		        next_state <= STATE_INTERRUPT_0;
--		    else
--		        next_state <= STATE_FETCH_0;  
--		    end if;
            next_state <= STATE_INTERRUPT_2;
		when STATE_INTERRUPT_2 =>
		     next_state <= STATE_FETCH_0;
		     
		when others =>
			if(IC_Flag_i = '1') then
		        next_state <= STATE_INTERRUPT_0;
		    else
		        next_state <= STATE_FETCH_0;  
			end if;
	end case;
end process;

-- Output Logic --
process (current_state)
begin

	-- reset all signals
	IR_Load <= '0';
	MAR_Load <= '0';
	PC_Load <= '0';
	SP1_Load <= '0';
	SP2_Load <= '0';
	PC_Inc <= '0';
	A_Load <= '0';
	B_Load <= '0';
	ALU_Sel <= (others => '0');
	CCR_Load <= '0';
	BUS1_Sel <= (others => '0');
	BUS2_Sel <= (others => '0');
	write_en <= '0';

	case current_state is
		when STATE_FETCH_0  => -- operand oku
			BUS1_Sel <= "000"; -- PC
			BUS2_Sel <= "01"; -- BUS1
			MAR_Load <= '1' ; -- BUS2'deki program sayaci degeri MAR'a alindi
		when STATE_FETCH_1  =>
			PC_Inc <= '1';
		when STATE_FETCH_2  =>
			BUS2_Sel <= "10"; -- memory'den 
			IR_Load  <= '1';
		when STATE_DECODE_3  =>
			-- next state güncellenmisti ve ilgili dallanmalarda gerçekleştirilmişti
-----------------------------------------------------------
		-- YUKLE_SBT_A
		when STATE_LDA_IMM_4 =>
			BUS1_Sel <= "000"; -- PC
			BUS2_Sel <= "01"; -- BUS1
			MAR_Load <= '1' ; -- BUS2'deki program sayaci degeri MAR'a alindi
		when STATE_LDA_IMM_5 =>
			PC_Inc   <= '1'; -- bir sonraki instruction icin arttirildi(bununla ilgisi yok)
		when STATE_LDA_IMM_6 =>
			BUS2_Sel <= "10"; -- memory'den 
			A_Load   <= '1';
-----------------------------------------------------------		
		-- YUKLE_A
		when STATE_LDA_DIR_4 =>
			BUS1_Sel <= "000"; -- PC
			BUS2_Sel <= "01"; -- BUS1
			MAR_Load <= '1' ; -- BUS2'deki program sayaci degeri MAR'a alindi	
		when STATE_LDA_DIR_5 =>
			PC_Inc   <= '1';
		when STATE_LDA_DIR_6 =>
			BUS2_Sel <= "10"; -- memory'den
			MAR_Load <= '1' ; -- BUS2'deki program sayaci degeri MAR'a alindi 
		when STATE_LDA_DIR_7 =>	
			-- Adress verildikten 1 clk sonra okuma yapilacak (o yüzden bos)
		when STATE_LDA_DIR_8 =>
			BUS2_Sel <= "10";
			A_Load   <= '1';

-----------------------------------------------------------

		when STATE_LDB_IMM_4 =>
			BUS1_Sel <= "000"; -- PC
			BUS2_Sel <= "01"; -- BUS1
			MAR_Load <= '1' ; -- BUS2'deki program sayaci degeri MAR'a alindi
		when STATE_LDB_IMM_5 =>
			PC_Inc   <= '1';
		when STATE_LDB_IMM_6 =>
			BUS2_Sel <= "10"; -- memory'den 
			B_Load   <= '1';

-----------------------------------------------------------		
	
		when STATE_LDB_DIR_4 =>
			BUS1_Sel <= "000"; -- PC
			BUS2_Sel <= "01"; -- BUS1
			MAR_Load <= '1' ; -- BUS2'deki program sayaci degeri MAR'a alindi
		when STATE_LDB_DIR_5 =>
			PC_Inc <= '1';
		when STATE_LDB_DIR_6 =>
			BUS2_Sel <= "10"; -- memory'den
			MAR_Load <= '1' ; -- BUS2'deki program sayaci degeri MAR'a alindi 
		when STATE_LDB_DIR_7 =>	
			-- Adress verildikten 1 clk sonra okuma yapilacak (o yüzden bos)
		when STATE_LDB_DIR_8 =>
			BUS2_Sel <= "10";
			B_Load   <= '1';
			
-----------------------------------------------------------
    -- LOAD_PC_TO_SP1
    when STATE_LOAD_PC_TO_SP1_4 =>
        BUS1_Sel <= "000"; -- PC
        BUS2_Sel <= "01";  -- BUS1
        SP1_Load <= '1';
      
    -- LOAD_SP1_TO_PC_4
    when STATE_LOAD_SP1_TO_PC_4 =>
        BUS1_Sel <= "011"; -- SP1
        BUS2_Sel <= "01";  -- BUS1
        PC_Load  <= '1';

		-- LOAD_SP2_TO_PC_4
    when STATE_LOAD_SP2_TO_PC_4 =>
        --if(pc_in_scr_i /= '1') then
            BUS1_Sel <= "100"; -- SP2
            BUS2_Sel <= "01";  -- BUS1
            PC_Load  <= '1';
        --end if;
    
    -- JUMP_AND_LINK_SP1
    when STATE_JUMP_AND_LINK_SP1_4 =>
        BUS1_Sel <= "000"; -- PC
        BUS2_Sel <= "01";  -- BUS1
        SP1_Load <= '1';
        MAR_Load <= '1' ; -- BUS2'deki program sayaci degeri MAR'a alindi
    when STATE_JUMP_AND_LINK_SP1_5 =>
        -- WAIT ONE CLOCK CYCLE
    when STATE_JUMP_AND_LINK_SP1_6 =>
        BUS2_Sel <= "10"; -- from memory
        PC_Load  <= '1';  -- Program sayaci register BUS2 verisini al
    
    -- LOAD_SP1_IMM
    when STATE_LOAD_SP1_IMM_4 =>
        BUS1_Sel <= "000"; -- PC
        BUS2_Sel <= "01";  -- BUS1
        MAR_Load <= '1' ;  -- BUS2'deki program sayaci degeri MAR'a alindi
    when STATE_LOAD_SP1_IMM_5 =>
        PC_Inc   <= '1';
    when STATE_LOAD_SP1_IMM_6 =>
        BUS2_Sel <= "10"; -- memory'den 
        SP1_Load <= '1';
        
    -- LOAD_SP1_DIR
    when STATE_LOAD_SP1_DIR_4 =>
        BUS1_Sel <= "000"; -- PC
        BUS2_Sel <= "01";  -- BUS1
        MAR_Load <= '1' ;  -- BUS2'deki program sayaci degeri MAR'a alindi    
    when STATE_LOAD_SP1_DIR_5 =>
        PC_Inc   <= '1';
    when STATE_LOAD_SP1_DIR_6 =>
        BUS2_Sel <= "10";  -- memory'den
        MAR_Load <= '1' ;  -- BUS2'deki program sayaci degeri MAR'a alindi 
    when STATE_LOAD_SP1_DIR_7 =>    
        -- Adress verildikten 1 clk sonra okuma yapilacak
    when STATE_LOAD_SP1_DIR_8 =>
        BUS2_Sel <= "10";
        SP1_Load <= '1';
        
-----------------------------------------------------------
			
		when STATE_STA_DIR_4 =>
			BUS1_Sel <= "000"; -- PC
			BUS2_Sel <= "01"; -- BUS1
			MAR_Load <= '1' ; -- BUS2'deki program sayaci degeri MAR'a alindi
		when STATE_STA_DIR_5 =>
			PC_Inc <= '1';
		when STATE_STA_DIR_6 =>
			BUS2_Sel <= "10";
			MAR_Load <= '1';  -- Kayıt adresini tekrar bellege ilettik
		when STATE_STA_DIR_7 =>
			BUS1_Sel <= "001"; -- A_reg'i BUS1'e sürdüm
			write_en <= '1';

-----------------------------------------------------------
			
		when STATE_STB_DIR_4 =>
			BUS1_Sel <= "000"; -- PC
			BUS2_Sel <= "01"; -- BUS1
			MAR_Load <= '1' ; -- BUS2'deki program sayaci degeri MAR'a alindi
		when STATE_STB_DIR_5 =>
			PC_Inc <= '1';
		when STATE_STB_DIR_6 =>
			BUS2_Sel <= "10";
			MAR_Load <= '1';  -- Kayıt adresini tekrar belleğe ilettik
		when STATE_STB_DIR_7 =>
			BUS1_Sel <= "010"; -- B_reg'i BUS1'e sürdüm
			write_en <= '1';

-----------------------------------------------------------

		when STATE_ADD_AB_4 =>
			BUS1_Sel <= "001";  -- A_reg
			BUS2_Sel <= "00";  -- ALU Result
			ALU_Sel	 <= "00000"; -- Toplama kodu ALU'daki
			A_Load   <= '1';   
			CCR_Load <= '1';

-----------------------------------------------------------

		when STATE_SUB_AB_4 =>
			BUS1_Sel <= "001";  -- A_reg
			BUS2_Sel <= "00";  -- ALU Result
			ALU_Sel	 <= "00001"; -- Cikarma kodu ALU'daki
			A_Load   <= '1';   
			CCR_Load <= '1';

-----------------------------------------------------------

		when STATE_AND_AB_4 =>
			BUS1_Sel <= "001";  -- A_reg
			BUS2_Sel <= "00";  -- ALU Result
			ALU_Sel	 <= "00010"; -- AND kodu ALU'daki
			A_Load   <= '1';   
			CCR_Load <= '1';

-----------------------------------------------------------

		when STATE_OR_AB_4 =>
			BUS1_Sel <= "001";  -- A_reg
			BUS2_Sel <= "00";  -- ALU Result
			ALU_Sel	 <= "00011"; -- OR kodu ALU'daki
			A_Load   <= '1';   
			CCR_Load <= '1';

-----------------------------------------------------------

		when STATE_INC_A_4 =>
			BUS1_Sel <= "001";  -- A_reg
			BUS2_Sel <= "00";  -- ALU Result
			ALU_Sel	 <= "00100"; -- A'yi 1 arttir kodu ALU'daki
			A_Load   <= '1';   
			CCR_Load <= '1';

-----------------------------------------------------------

    when STATE_INC_B_4 =>
			BUS1_Sel <= "001"; -- A_reg
			BUS2_Sel <= "00";  -- ALU Result
			ALU_Sel	 <= "10000"; -- B'yi 1 arttir kodu ALU'daki
			A_Load   <= '1';   
			CCR_Load <= '1';


-----------------------------------------------------------

		when STATE_DEC_A_4 =>
			BUS1_Sel <= "001";  -- A_reg
			BUS2_Sel <= "00";  -- ALU Result
			ALU_Sel	 <= "00101"; -- A'yi 1 azalt kodu ALU'daki
			A_Load   <= '1';   
			CCR_Load <= '1';

-----------------------------------------------------------
        
    when STATE_DEC_B_4 =>
      BUS1_Sel <= "001";  -- A_reg
      BUS2_Sel <= "00";  -- ALU Result
      ALU_Sel     <= "10001"; -- b dec
      A_Load   <= '1';   
      CCR_Load <= '1';

-----------------------------------------------------------

		when STATE_SRL_A_4 =>
			BUS1_Sel <= "001";  -- A_reg
			BUS2_Sel <= "00";  -- ALU Result
			ALU_Sel	 <= "00110"; 
			A_Load   <= '1';   
			CCR_Load <= '1';

-----------------------------------------------------------

		when STATE_SLL_A_4 =>
			BUS1_Sel <= "001";  -- A_reg
			BUS2_Sel <= "00";  -- ALU Result
			ALU_Sel	 <= "00111"; 
			A_Load   <= '1';   
			CCR_Load <= '1';

-----------------------------------------------------------

		when STATE_SRA_A_4 =>
			BUS1_Sel <= "001";  -- A_reg
			BUS2_Sel <= "00";  -- ALU Result
			ALU_Sel	 <= "01000"; 
			A_Load   <= '1';   
			CCR_Load <= '1';

-----------------------------------------------------------

		when STATE_SLA_A_4 =>
			BUS1_Sel <= "001";  -- A_reg
			BUS2_Sel <= "00";  -- ALU Result
			ALU_Sel	 <= "01001"; 
			A_Load   <= '1';   
			CCR_Load <= '1';

-----------------------------------------------------------

		when STATE_ROR_A_4 =>
			BUS1_Sel <= "001";  -- A_reg
			BUS2_Sel <= "00";  -- ALU Result
			ALU_Sel	 <= "01010"; 
			A_Load   <= '1';   
			CCR_Load <= '1';

-----------------------------------------------------------

		when STATE_ROL_A_4 =>
			BUS1_Sel <= "001";  -- A_reg
			BUS2_Sel <= "00";  -- ALU Result
			ALU_Sel	 <= "01011"; 
			A_Load   <= '1';   
			CCR_Load <= '1';

-----------------------------------------------------------

		when STATE_RESET_ALU_4 =>
			BUS1_Sel <= "001";  -- A_reg
			BUS2_Sel <= "00";  -- ALU Result
			ALU_Sel	 <= "01100"; 
			A_Load   <= '1';   
			CCR_Load <= '1';

-----------------------------------------------------------

		when STATE_NOT_A_4 =>
			BUS1_Sel <= "001";  -- A_reg
			BUS2_Sel <= "00";  -- ALU Result
			ALU_Sel	 <= "01101"; 
			A_Load   <= '1';   
			CCR_Load <= '1';

-----------------------------------------------------------

		when STATE_XOR_AB_4 =>
			BUS1_Sel <= "001";  -- A_reg
			BUS2_Sel <= "00";  -- ALU Result
			ALU_Sel	 <= "01111"; 
			A_Load   <= '1';   
			CCR_Load <= '1';

-----------------------------------------------------------

		when STATE_BRA_4 =>
			BUS1_Sel <= "000"; -- PC
			BUS2_Sel <= "01"; -- BUS1
			MAR_Load <= '1' ; -- BUS2'deki program sayaci degeri MAR'a alindi

		when STATE_BRA_5 =>
			-- BOS

		when STATE_BRA_6 =>
			BUS2_Sel <= "10"; -- from memory
			PC_Load  <= '1';  -- Program sayaci register BUS2 verisini al
			
-----------------------------------------------------------

		when STATE_BEQ_4 =>
			BUS1_Sel <= "000"; -- PC
			BUS2_Sel <= "01"; -- BUS1
			MAR_Load <= '1' ; -- BUS2'deki program sayaci degeri MAR'a alindi
		when STATE_BEQ_5 =>
			-- empty for one clock cycle
			
		when STATE_BEQ_6 =>
			BUS2_Sel <= "10"; -- from memory
			PC_Load  <= '1';  -- Program sayaci register BUS2 verisini al

		when STATE_BEQ_7 =>	  -- Z = '0' state condition , command bypass
			PC_Inc <= '1';    -- Hic birsey olmamis gibi PC articak
			
----------------------- ınterrupt -------------------------
	    when STATE_INTERRUPT_0 => 
	    -- empty
		when STATE_INTERRUPT_1 => -- PC -> SP2'ye atandi
		    --IC_reset_o_reg	  <= '1';
			BUS1_Sel 	<= "000"; -- PC
            BUS2_Sel 	<= "01";  -- BUS1
            if(pc_in_scr_i /= '1') then
                SP2_Load 	<= '1';
            end if;
			--IC_reset_o 	<= '1';	  -- böylelikle IC_Flag_i IC'de temizlenecek
	    when STATE_INTERRUPT_2 => -- x"5a" -> PC'ye atandi
	       BUS2_Sel 	<= "11";  -- x"5a"
           PC_Load         <= '1';   -- pc'ye interrupt handle adresi atandi
           --IC_reset_o_reg      <= '0';
			
		when others =>
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			SP1_Load <= '0';
            SP2_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= (others => '0');
			CCR_Load <= '0';
			BUS1_Sel <= (others => '0');
			BUS2_Sel <= (others => '0');
			write_en <= '0';
			
	end case;
end process;


end architecture;
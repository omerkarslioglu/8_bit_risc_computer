library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity program_memory is 
	port (
		clk    		: in std_logic;
		address 	: in std_logic_vector(7 downto 0);
		-- Output
		data_out 	: out std_logic_vector(7 downto 0)
	);
end program_memory;

architecture arch of program_memory is

-- All Commands :

-- Loads and Stores Commands
constant YUKLE_A_SBT		:std_logic_vector(7 downto 0) := x"86"; -- Load register A using immediate value
constant YUKLE_A			:std_logic_vector(7 downto 0) := x"87"; -- Load register A using direct addressing
constant YUKLE_B_SBT		:std_logic_vector(7 downto 0) := x"88"; -- Load register B using Immediate value
constant YUKLE_B			:std_logic_vector(7 downto 0) := x"89"; -- Load register B using direct addressing

constant LOAD_PC_TO_SP1		:std_logic_vector(7 downto 0) := x"90"; -- Load PC value to SP1 Register
constant LOAD_SP1_TO_PC		:std_logic_vector(7 downto 0) := x"91"; -- Load SP1 value to PC Register
constant JUMP_AND_LINK_SP1	:std_logic_vector(7 downto 0) := x"92"; -- PC takes value of SP1, and previous PC value is saved in SP1 
constant LOAD_SP1_IMM   	:std_logic_vector(7 downto 0) := x"93"; -- Load immediate value Stack Pointer-1 register 
constant LOAD_SP1_DIR   	:std_logic_vector(7 downto 0) := x"94"; -- Load value to Stack Pointer-1 register from Direct Address

constant KAYDET_A			:std_logic_vector(7 downto 0) := x"96"; -- Store Register A to Memory using Direct Addr.
constant KAYDET_B			:std_logic_vector(7 downto 0) := x"97"; -- Store Register B to Memory using Direct Addr.

-- Data Manipulations
constant TOPLA_AB			:std_logic_vector(7 downto 0) :=x"42"; -- A=A+B
constant CIKAR_AB			:std_logic_vector(7 downto 0) :=x"43"; -- A=A-B
constant AND_AB				:std_logic_vector(7 downto 0) :=x"44"; -- A=A&B
constant OR_AB				:std_logic_vector(7 downto 0) :=x"45"; -- A=A+B
constant ARTTIR_A			:std_logic_vector(7 downto 0) :=x"46"; -- A=A+1
constant ARTTIR_B			:std_logic_vector(7 downto 0) :=x"47"; -- B=B+1
constant DUSUR_A			:std_logic_vector(7 downto 0) :=x"48"; -- A=A-1
constant DUSUR_B			:std_logic_vector(7 downto 0) :=x"49"; -- B=B-1
constant SRL_A				:std_logic_vector(7 downto 0) :=x"4A"; -- Logical shift right 
constant SLL_A				:std_logic_vector(7 downto 0) :=x"4B"; -- Logical shift left 
constant SRA_A				:std_logic_vector(7 downto 0) :=x"4C"; -- Arithmatic shift right 
constant SLA_A				:std_logic_vector(7 downto 0) :=x"4D"; -- Arithmatic shift left 
constant ROR_A				:std_logic_vector(7 downto 0) :=x"4E"; -- Rotate right logical
constant ROL_A				:std_logic_vector(7 downto 0) :=x"4F"; -- Rotate left logical
constant RESET_ALU			:std_logic_vector(7 downto 0) :=x"50"; -- Reset ALU, clear all signals
constant NOT_A				:std_logic_vector(7 downto 0) :=x"51"; -- A=~A
constant XOR_AB				:std_logic_vector(7 downto 0) :=x"52"; -- A = A xor B

-- Branches
constant ATLA				:std_logic_vector(7 downto 0) :=x"20";  -- Branch always to address provided
constant ATLA_NEGATIFSE		:std_logic_vector(7 downto 0) :=x"21";  -- Branch to Address Provided if N=1
constant ATLA_POZITIFSE		:std_logic_vector(7 downto 0) :=x"22";  -- Branch to Address Provided if N=0
constant ATLA_ESITSE_SIFIR	:std_logic_vector(7 downto 0) :=x"23";  -- Branch to Address Provided if Z=1
constant ATLA_DEGILSE_SIFIR	:std_logic_vector(7 downto 0) :=x"24";  -- Branch to Address Provided if Z=0
constant ATLA_OVERFLOW_VARSA:std_logic_vector(7 downto 0) :=x"25";  -- Branch to Address Provided if V=1
constant ATLA_OVERFLOW_YOKSA:std_logic_vector(7 downto 0) :=x"26";  -- Branch to Address Provided if V=0
constant ATLA_ELDE_VARSA	:std_logic_vector(7 downto 0) :=x"27";  -- Branch to Address Provided if C=1
constant ATLA_ELDE_YOKSA	:std_logic_vector(7 downto 0) :=x"28";  -- Branch to Address Provided if C=0

-- General Purpose Instruction
constant NOP				:std_logic_vector(7 downto 0) :=x"01";
constant FIR				:std_logic_vector(7 downto 0) :=x"11";	-- finish interrupt routine

type rom_type is array (0 to 127) of std_logic_vector(7 downto 0);
constant ROM : rom_type := (
        -- port a pin 0 interrupt is activate
        
         0  => YUKLE_A_SBT, 
         1  => x"00",      
         2  => KAYDET_A,
         3  => x"96",         -- to RAM (150th address)
        
		 4	 => YUKLE_A_SBT,
		 5   => x"02",        -- ICU control reg1 value
		 6   => KAYDET_A,
		 7   => x"ED",        -- ICU control reg1 address
		 
		 8	 => YUKLE_A_SBT,
         9   => x"01",        -- ICU control reg3 value
         10   => KAYDET_A,
         11   => x"EF",       -- ICU control reg3 address

         -- Timer1 CH1 PWM 
         12	 => YUKLE_A_SBT,
         13   => x"03",       -- TIM1 enable, CH1 enable, counter mode is up   
         14  => KAYDET_A,
         15  => x"E2",        -- TIM1 control reg1
        
         16	 => YUKLE_A_SBT,
         17  => x"03",        -- TIM1 pwm enable, output generation is enable, ch polarity is high
         18  => KAYDET_A,
         19  => x"E3",        -- TIM1 control reg2
         
         20  => YUKLE_A_SBT,
         21  => x"04",        -- 04 in decimal (4+1 prescaler)
         22  => KAYDET_A,
         23  => x"E4",        -- Prescaler register
         
         24  => YUKLE_A_SBT,
         25  => x"64",        -- 100 in decimal (Auto R. Reg.) -- For 4 MHz, 8khz pwm signal.
         26  => KAYDET_A,
         27  => x"E5",        -- ARR
        
         28  => YUKLE_A_SBT,
         29  => x"32",        -- 50
         30  => KAYDET_A,
         31  => x"E6",        -- ccr_ch1
         
         
         -- MAIN LOOP
         --============
         -- MOTOR OUTPUT
         32  => YUKLE_A_SBT,
         33  => "00000100", -- IN1 bit1 (not bit0) - LOW, IN2 bit2 - HIGH
         34  => KAYDET_A,
         35  => x"E0",      -- OUTPUT PORT A
            
         -- EXTERNAL WORLD
         -----------------
         -- Compare for max speed:
         36  => YUKLE_B,      -- port'a'yı oku
         37  => x"F0",        -- port_in_00 (port a inputs)
         
         38  => YUKLE_A_SBT,  -- 00'a esitse
         39  => x"00", 
          
         40  => CIKAR_AB,
         -- sil bunu:
         41  => NOP,        -- port_in_00 (port a inputs)
         42  => ATLA_ESITSE_SIFIR,
         43  => x"38",        -- (56) son hiz 50% pwm
         -- ~~
         
         -- Compare for mid speed:
         44  => YUKLE_A_SBT,  -- 01'e esitse
         45  => x"01", 
                   
         46  => CIKAR_AB,
         47  => NOP,       -- port_in_00 (port a inputs)
         48  => ATLA_ESITSE_SIFIR,
         49  => x"42",        -- (66) orta hiz 30% pwm
         -- ~~
         
         -- Compare for min speed:
         50  => YUKLE_A_SBT,  -- 10'a esitse
         51  => x"02", 
                   
         52  => CIKAR_AB,
         53  => NOP,         -- port_in_00 (port a inputs)
         54  => ATLA_ESITSE_SIFIR,
         55  => x"4C",        -- (76) yavas hiz 15% pwm
         -- ~~
         
         -- ~~ main loop end ~~
         
         -- son hiz
         --=============
         -- seven segment will be 3 --
         56  => YUKLE_A_SBT,
         57  => "00110000", -- 3 and dot     
         58  => KAYDET_A,
         59  => x"E1",   -- seven segment output port            
         
         60  => YUKLE_A_SBT,
         61  => x"50",        --* 80
         62  => KAYDET_A,
         63  => x"E6",        -- ccr_ch1
         
         64  => ATLA,
         65  => x"20",        -- 32 main loop address
         -- ~~ max speed func. end ~~
         
         
         -- orta hiz
         --=============
         -- seven segment will be 2 --
         66  => YUKLE_A_SBT,
         67  => "10100100", -- 2      
         68  => KAYDET_A,
         69  => x"E1",   -- seven segment output port   
         
         70  => YUKLE_A_SBT,
         71  => x"32",        --* 50
         72  => KAYDET_A,
         73  => x"E6",        -- ccr_ch1
         
         74  => ATLA,
         75  => x"20",        -- 32 main loop address
         -- ~~ mid speed func. end ~~
         
         -- yavas hiz
         --=============
         -- seven segment will be 1 --
         76  => YUKLE_A_SBT,
         77  => "11111001", -- 1      
         78  => KAYDET_A,
         79  => x"E1",   -- seven segment output port   
         
         80  => YUKLE_A_SBT,
         81  => x"0f",        -- 15
         82  => KAYDET_A,
         83  => x"E6",        -- ccr_ch1         
                         
		 84  => ATLA,
		 85  => x"20",        -- 32 main loop address
		 -- ~~ min speed func. end ~~
		 
		 
		 --Interrupt Serial Routine
		 --=============
         
         90  => YUKLE_B,      -- a=0
         91  => x"96",        -- to RAM (150th address) 
         
         92  => YUKLE_A_SBT,  -- FOR AND OPperation
         93  => x"FF",
         
         94  => AND_AB, 
                         
         --if a==0
         95  => ATLA_DEGILSE_SIFIR,
         96  => x"73",        -- else address
         
         97  => YUKLE_A_SBT,  -- a=0
         98  => x"01",     
         99  => KAYDET_A,
         100  => x"96",        -- to RAM (150th address)  
         
         -- pwm not enable   
--         98  => YUKLE_A_SBT,
--         99  => x"0F",        -- stop motor
--         100 => KAYDET_A,
--         101 => x"E6",        -- ccr_ch1
           101	 => YUKLE_A_SBT,
           102   => x"01",           -- pwm not out not enable
           103   => KAYDET_A,
           104   => x"E3",          -- TIM2 control reg-2
         -- ~~
         
         105 => YUKLE_A_SBT,
         106 => "00000101",     -- IN1 bit1 (not bit0) - LOW, IN2 bit2 - HIGH - led bit0 HIGH
         107 => KAYDET_A,
         108 => x"E0",          -- OUTPUT PORT A

         109 => YUKLE_A_SBT,
         110 => "01000000", -- 0      
         111 => KAYDET_A,
         112 => x"E1",   -- seven segment output port
         
         113 => ATLA,    -- infinite LOOP
		 114 => x"6E",
		 
		 -- else
         115 => YUKLE_A_SBT,
         116 => x"03", 
         117 => KAYDET_A,
         118 => x"E3",
         
         119 => YUKLE_A_SBT,
         120 => x"00",      
         121 => KAYDET_A,
         122 => x"96",        -- to RAM (150th address)
         123 => FIR,          -- finish interrupt routine
		 -- ~~ interrupt serial routin end ~~   
		 
          
        others => x"00"	
        
        -- ~~ program end ~~ 
        
        -- Seven segment not
        -- dp g f e d c b a
        -- 7  6 5 4 3 2 1 0															
);

-- Signals :
signal enable : std_logic; -- to control interval of address
begin

process(address) begin
	if(address >=x"00" and address <= x"7F") then
		enable <= '1';
	else 
		enable <= '0';
	end if;
end process;

process(clk) begin
	if(rising_edge(clk)) then
		if(enable = '1') then
			data_out <= ROM(to_integer(unsigned(address)));
		end if;
	end if;
end process;	

end architecture;





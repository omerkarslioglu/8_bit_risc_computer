library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- combinational system 
-- 8 bit A and B inputs
-- 3 bit selection input
--  NZVC flags (Negative , Zero , Overflow , Carry)
-- 4 bit outputs
entity ALU is
	port(
		A 								: in std_logic_vector(7 downto 0); -- 8 bit data to be processed
		B 								: in std_logic_vector(7 downto 0); -- 8 bit data to be processed
		ALU_Sel 					: in std_logic_vector(4 downto 0);
		
		-- Outputs
		NZVC   						: out std_logic_vector(3 downto 0);
		ALU_RESULT 				: out std_logic_vector(7 downto 0)
	);
end ALU;

architecture arch of ALU is

signal sum_unsigned 	: std_logic_vector(8 downto 0); -- 9 bit olmas�n�n sebebi carry var m� yok mu onu anlamak
signal alu_signal  		: std_logic_vector(7 downto 0); -- Output'u i�emlerde kullanmak sentezde problem ��kart�yor (ALU_RESULT yerine)
signal add_overflow 	: std_logic;
signal sub_overflow 	: std_logic;

begin 

	process(ALU_Sel,A,B) begin
		sum_unsigned <= (others => '0'); -- reset parameter
		case ALU_Sel is
			when "00000" => -- Addition
				alu_signal <= A+B;
				sum_unsigned 	<= ('0' & A) + ('0' & B); -- basa 0 koyarak 9 bit yapt�m (padding)
			when "00001" => -- Subtraction
				alu_signal <= A-B;
				sum_unsigned 	<= ('0' & A) - ('0' & B); -- basa 0 koyarak 9 bit yapt�m (padding)
			when "00010" => -- And
				alu_signal <= A and B;
			when "00011" => -- 0R
				alu_signal <= A or B;
			when "00100" => -- INC 1 (+1)
				alu_signal <= A+x"01";
			when "00101" => -- DEC 1 (-1)
				alu_signal <= A-x"01";
			when "00110" => -- Logical Shift Right One 
				alu_signal <= (to_stdlogicvector(to_bitvector(std_logic_vector(A)) srl to_integer(unsigned(B))));
			when "00111" => -- Logical Shift Left One
				alu_signal <= (to_stdlogicvector(to_bitvector(std_logic_vector(A)) sll to_integer(unsigned(B))));
			when "01000" => -- Arithmatic Shift Right One
				alu_signal <= (to_stdlogicvector(to_bitvector(std_logic_vector(A)) sra to_integer(unsigned(B))));
			when "01001" => -- Arithmatic Shift Left One
				alu_signal <= (to_stdlogicvector(to_bitvector(std_logic_vector(A)) sla to_integer(unsigned(B))));
			when "01010" => -- Rotate Right
				alu_signal <= (to_stdlogicvector(to_bitvector(std_logic_vector(A)) ror to_integer(unsigned(B))));
			when "01011" => -- Rotate Left
				alu_signal <= (to_stdlogicvector(to_bitvector(std_logic_vector(A)) rol to_integer(unsigned(B))));
			when "01100" => -- Reset ALU
				alu_signal <= x"00";
			when "01101" => -- Not
				alu_signal <= not A;
			when "01111" => -- XOR
				alu_signal <= A xor B;
			when "10000" => -- B INC
                alu_signal <= B+x"01";
            when "10001" => -- B DEC
                alu_signal <= B-x"01";
			when others =>
				alu_signal <= (others => '0');
				sum_unsigned 	<= (others => '0');
		end case;
		
	end process;

ALU_RESULT <= alu_signal;

-- NZVC

NZVC(3) <= alu_signal(7); -- N
NZVC(2) <= '1' when alu_signal = x"00" else '0'; -- Z

-- V :
add_overflow <= (not(A(7)) and not(B(7)) and alu_signal(7)) or (A(7) and B(7) and not(alu_signal(7)));
sub_overflow <= (not(A(7)) and B(7) and alu_signal(7)) or (A(7) and not(B(7)) and not(alu_signal(7)));

NZVC(1)  <= add_overflow	when (ALU_Sel = "00000") else
			sub_overflow 	when (ALU_Sel = "00001") else '0';
			
NZVC(0)  <= sum_unsigned(8) when (ALU_Sel = "00000") else
			sum_unsigned(8) when (ALU_Sel = "00001") else '0';
			


end architecture;
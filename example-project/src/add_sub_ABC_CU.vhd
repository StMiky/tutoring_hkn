library IEEE;
use ieee.std_logic_1164.all;

---------------------------------- INFO ---------------------------------------
-- File: add_sub_ABC_CU
-- This file contains the Control Unit of the example project realized for
-- the HKN - VHDL tutoring (2018).
-------------------------------------------------------------------------------

entity add_sub_ABC_CU is
	port (
	-- INPUTS
		-- main signals
		clk,
		rst_n : in std_logic;
		
		-- from outside
		start,
		sign : in std_logic;
		
	-- OUTPUTS
		-- to DP
		sub,
		en_regA,
		en_regB,
		en_regC,
		en_regSum,
		clr_regs,
		clr_regSum,
		sel : out std_logic; 
		
		-- to outside
		done : out std_logic
	);
end add_sub_ABC_CU;

architecture behaviour of add_sub_ABC_CU is
	-- Better to cap STATES
	type state_type is (RESET, IDLE, ABCSV, CSV_ACPR_SUM, CSV_ACPR_SUB, OUT0_BCPR_SUM, OUT0_BCPR_SUB, OUT1);

	signal pres_state, next_state : state_type;
		 
begin

	----------------------------- STATE EVOLUTION -----------------------------
	-- This process models the combinational NEXT STATE genration network, that
	-- generates the next state code based on the PRESENT state AND the INPUT
	-- SIGNALS (that's why we need both of them in the sensitivity list).

	ns_process : process(pres_state, start, sign)
	begin
		case pres_state is
		
			when RESET => next_state <= IDLE;
			
			when IDLE => 	if (start = '1') then
								next_state <= ABCSV;
							else
								next_state <= IDLE;
							end if;
							 
			when ABCSV => 	if (sign = '0') then
								next_state <= CSV_ACPR_SUM;
						    else
								next_state <= CSV_ACPR_SUB;
							end if;
							 
			when CSV_ACPR_SUM => 	if (sign = '0') then
										next_state <= OUT0_BCPR_SUM;
						            else
										next_state <= OUT0_BCPR_SUB;
							        end if;
			
			when CSV_ACPR_SUB => 	if (sign = '0') then
										next_state <= OUT0_BCPR_SUM;
						            else
										next_state <= OUT0_BCPR_SUB;
							        end if;
			
			when OUT0_BCPR_SUM => next_state <= OUT1;
			
			when OUT0_BCPR_SUB => next_state <= OUT1;
			
			when OUT1 => next_state <= IDLE;
			
			when others => next_state <= RESET; -- IMPORTANT!!!: avoid unknown states
			
		end case;
	end process;
	---------------------------------------------------------------------------

	--------------------------- STATE UPDATE ----------------------------------
	-- Here the FFs where the PRESENT state is coded are updated with the 
	-- NEXT state (will be at the first positive edge of the clock).

	ps_process : process(clk, rst_n)
	begin
		if (rst_n = '0') then
			pres_state <= RESET;
		else
			if (clk'event and clk = '1') then
				pres_state <= next_state;
			end if;
		end if;
	end process;
	---------------------------------------------------------------------------

	------------------------- CONTROL SIGNAL GENERATION -----------------------
	-- This models the combinational output network that generates control 
	-- signals based on the current PRESENT state. Note how a process is used
	-- to model a combinational network.

	out_process : process(pres_state)
	begin
	
		-- std assignments
		clr_regSum <= '0';
		clr_regs <= '0';
		en_regA <= '0';
		en_regB <= '0';
		en_regC <= '0';
		en_regSum <= '0';
		sub <= '0';
		sel <= '0';
		done <= '0';
	
		-- specific assignments
		case pres_state is
			when RESET => clr_regs <= '1';
							  clr_regSum <= '1';
		
			when IDLE => clr_regSum <= '1';
			
			when ABCSV => en_regA <= '1';
			              en_regB <= '1';
			              en_regC <= '1';
						  
			when CSV_ACPR_SUM => 	en_regC <= '1';
									en_regSum <= '1';
									sub <= '0';
										 
			when CSV_ACPR_SUB => 	en_regC <= '1';
									en_regSum <= '1';
									sub <= '1';
										  
			when OUT0_BCPR_SUM => 	en_regSum <= '1';
											sub <= '0';
											done <= '1';
										 
			when OUT0_BCPR_SUB => 	en_regSum <= '1';
											sub <= '1';
											done <= '1';
										  
			when OUT1 => 
			
		end case;
	end process;
	---------------------------------------------------------------------------

	end architecture;
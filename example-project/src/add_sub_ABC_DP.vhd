library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

---------------------------------- INFO ---------------------------------------
-- File: add_sub_ABC_DP
-- This file contains the Datapath of the example project realized for
-- the HKN - VHDL tutoring (2018).
-------------------------------------------------------------------------------

entity add_sub_ABC_DP is
	generic ( n : integer := 3 );
	port (
		    -- INPUTS
			   -- control signals
				clk,
				rst_n,
				clr_regs,
				clr_regSum,
			   en_regA,
			   en_regB,
			   en_regC,
			   en_regSum,
			   sel,
			   sub : in std_logic;
			 
			   -- data signals
				A,
				B,
				C : in std_logic_vector(n-1 downto 0);
				
			-- OUTPUTS
			   data_out : out std_logic_vector(n downto 0)
	      );
end add_sub_ABC_DP;

architecture behaviour of add_sub_ABC_DP is

	-- COMPONENTS

	component reg_n is
		generic ( n : integer := 3 );
		port ( 
					clk,
					en,
					rst_n,
					clr : in std_logic;

					D : in std_logic_vector(n-1 downto 0);
				
					Q : out std_logic_vector(n-1 downto 0)
				);
	end component;

	component mux2 is
		generic (n : integer := 3);
		port ( 
					sel : in std_logic;
			
					in0,
					in1	: in std_logic_vector(n-1 downto 0);
					
					out0 : out std_logic_vector(n-1 downto 0)
				);
	end component;

	component adder_sub_beh is
		generic ( n : integer := 3 );
		port (
					sub : in std_logic;
			
					in0,
					in1 : in std_logic_vector(n-1 downto 0);
					
					out0 : out std_logic_vector(n downto 0)
				);
	end component;

	-- SIGNALS

	signal 
	A_Q,
	B_Q,
   add0,
   add1 : std_logic_vector(n-1 downto 0);
	
	signal
	out_D : std_logic_vector(n downto 0);

begin

	-- INPUT REGISTERS
	-- If nothing is known about who generates/receives the input signals, it's always a good choice to insert input/output registers
	reg_A : reg_n 
		GENERIC MAP 
			( n => n )  
  		PORT MAP
			( 
				clk => clk,
				en => en_regA,
				rst_n => rst_n,
				clr => clr_regs,
				D => A,
				Q => A_Q
			);

	reg_B : reg_n 
		GENERIC MAP 
			( n => n )
   	PORT MAP
		( 
			clk => clk,
			en => en_regB,
			rst_n => rst_n,
			clr => clr_regs,
			D => B,
			Q => B_Q
			);
			
	reg_C : reg_n 
		GENERIC MAP 
			( n => n )  
		PORT MAP
		( 
			clk => clk,
			en => en_regC,
			rst_n => rst_n,
			clr => clr_regs,
			D => C,
			Q => add1
		);

	-- NOTICE: sign is already "sampled" by the control unit, so an input FF is not necessary. This helps synchronization too
		
	-- INPUT MUX
	mux_AB : mux2 
		GENERIC MAP 
			( n => n )
   	PORT MAP
		( 
			sel => sel,
			in0 => A_Q,
			in1 => B_Q,
			out0 => add0
		);
	
	-- ADDER
	adder_sub : adder_sub_beh 
		GENERIC MAP 
			( n => n )  
   	PORT MAP
		(
			sub => sub,
			in0 => add0, 
			in1 => add1,
			out0 => out_D
		);
	
	-- OUTPUT REGISTER
	reg_out : reg_n 
		GENERIC MAP 
			( n => n+1 )     
   	PORT MAP
		( 
			clk => clk,
			en => en_regSum,
			rst_n => rst_n,
			clr => clr_regSum,
			D => out_D,
			Q => data_out
		);
	
end architecture;
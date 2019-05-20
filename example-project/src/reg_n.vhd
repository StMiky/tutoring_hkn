library IEEE;
use ieee.std_logic_1164.all;

entity reg_n is
	generic ( n : integer := 3 );
	port ( 
	      clk,
			en,
			rst_n,
			clr: in std_logic;   
			 
	       	D : in std_logic_vector(n-1 downto 0);
			 
          	Q : out std_logic_vector(n-1 downto 0)
			);
end reg_n;

architecture behaviour of reg_n is
begin

	process(clk, rst_n)
	begin
		if (rst_n = '0') then
			Q <= (OTHERS => '0');
		elsif (clk'event and clk = '1') then
			if (clr = '1') then 
				Q <= (OTHERS => '0');
			elsif (en = '1') then
				Q <= D;
			end if;
		end if;
	end process;

end architecture;
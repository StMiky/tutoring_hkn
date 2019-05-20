library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder_sub_beh is
	generic ( n : integer := 3 );
	port (
	      sub : in std_logic;
	
	      in0,
			in1 : in std_logic_vector(n-1 downto 0);
			 
			out0 : out std_logic_vector(n downto 0)
	      );
end adder_sub_beh;

architecture behaviour of adder_sub_beh is

SIGNAL add0, add1 : INTEGER;

begin

  process(in0, in1, sub, add0, add1)
  BEGIN
    add0 <= to_integer(signed(in0));
    add1 <= to_integer(signed(in1));
		if (sub = '0') then
			out0 <= std_logic_vector( to_signed( add0+add1 , out0'LENGTH ) );
		else
			out0 <= std_logic_vector( to_signed( add0-add1 , out0'LENGTH ) );
		end if;
        end process;

  end architecture;
                  

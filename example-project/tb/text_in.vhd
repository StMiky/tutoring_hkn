library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

------------------------------- INFO --------------------------------------------
-- This component is intended to be used whenever data has to be read from a file.
-- A clock, enable and done signals are provided so the user can make use of
-- this component in a familiar way, just as an hardware component.
-- Read data are provided in std_logic_vector type.
---------------------------------------------------------------------------------

entity text_in is
    generic(bit_n: integer:=16);
    port(
    -- INPUT SIGNALS
        clock: in std_logic; -- clock signal
        enable: in std_logic; -- enable signal
        file_name: in string; -- name of the file to read the files from
    -- OUTPUT SIGNALS
        data: out std_logic_vector(bit_n-1 downto 0);
        done: out std_logic
    );
end text_in;

architecture behaviour of text_in is

begin
    reading_process: process(clock, enable)
    file input_file: text open read_mode is file_name; -- the file
    variable file_status: File_open_status; -- to check wether the file is already open
    variable line_buffer: line; -- read buffer
    variable EOF: std_logic:='0'; -- End Of File variable

    variable read_data: bit_vector(bit_n-1 downto 0); -- The line read from the file

    begin
        if(enable='1') then
            if(clock'event and clock='1') then
                if(not endfile(input_file)) then
                    readline(input_file, line_buffer); -- Reads the next full line from the file
                    read(line_buffer, read_data); -- Stores the first bit_n bits from the buffer into the output signal
                else
                    EOF:='1';
                end if;
            end if;
        end if;

        done <= EOF;
        data <= to_stdlogicvector(read_data);

    end process;

end behaviour;

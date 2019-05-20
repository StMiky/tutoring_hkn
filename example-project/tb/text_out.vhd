library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

------------------------------- INFO --------------------------------------------
-- This component is intended to be used whenever data has to be wrote to a file.
-- A clock and enable signals are provided so the user can make use of
-- this component in a familiar way, just as an hardware component.
---------------------------------------------------------------------------------

entity text_out is
    generic(bit_n: integer:=16);
    port(
    -- INPUT SIGNALS
        clock: in std_logic; -- clock signal
        enable: in std_logic; -- enable signal
        file_name: in string; -- name of the output file
        data_in: in std_logic_vector(bit_n-1 downto 0) -- Data to be written on the file
    );
end text_out;

architecture behaviour of text_out is

begin
    writing_process: process(clock, enable, data_in)
    file output_file: text open write_mode is file_name; -- the file
    variable file_status: File_open_status; -- to check wether the file is already open
    variable line_buffer: line; -- read buffer

    variable write_data: bit_vector(bit_n-1 downto 0); -- The line to write to the file

    begin
        write_data := to_bitvector(data_in);

        if(enable='1') then
            if(clock'event and clock='1') then
                    write(line_buffer, write_data, left, bit_n-1); -- writes the input data to the buffer
                    writeline(output_file, line_buffer); -- writes the buffer content to the file
            end if;
        end if;

    end process;

end architecture behaviour;

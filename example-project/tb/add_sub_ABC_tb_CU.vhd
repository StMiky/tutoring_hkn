library ieee;
use ieee.std_logic_1164.all;

----------------------------------- INFO ---------------------------------------
-- This is the testbench Control Unit. It provides the proper control signal to
-- the different components according to the required timing.
--------------------------------------------------------------------------------

entity add_sub_ABC_tb_CU is
    port(
    -- INPUT SIGNALS
        clock: in std_logic; -- clock (generated in testbench DP)
        reset_n: in std_logic; -- reset signal
        start: in std_logic; -- testbench start signal
        add_sub_ABC_done: in std_logic; -- DUT done signal
        freader_done: in std_logic; -- file reader done signal
    -- OUTPUT SIGNALS
        -- DUT:
        add_sub_ABC_start: out std_logic; -- DUT start signal
        add_sub_ABC_rst_n: out std_logic; -- DUT reset signal (active low)

        -- FILE reader/writer:
        AB_freader_enable: out std_logic; -- input file reader enable
        C_freader_enable: out std_logic; -- input file reader enable
        sign_freader_enable: out std_logic; -- input sign file reader enable
        fwriter_enable: out std_logic -- output file writer enable
    );
end add_sub_ABC_tb_CU;

architecture behaviour of add_sub_ABC_tb_CU is
    -- STATE SIGNALS
    type state_type is (RST, IDLE, READ_INPUT, CHECK_EOF, START_STATE, SEND_ABC0, SEND_ABC1, SAVE_OUT0, SAVE_OUT1);
    signal pres_state, next_state: state_type; -- Present state and next state

begin
    -- State update ns_process
    state_update: process(clock, reset_n)
    begin
        if(reset_n = '0') then 
            pres_state <= RST;
        elsif(clock'event and clock = '1') then
            pres_state <= next_state;
        end if;
    end process;

    -- State evolution process
    state_evolution: process(pres_state, add_sub_ABC_done, freader_done, start)
    begin
        case pres_state is
            when RST => next_state <= IDLE;

            when IDLE => if(start = '1') then
                            next_state <= READ_INPUT;
                        else
                            next_state <= IDLE;
                        end if;

            when READ_INPUT =>  next_state <= CHECK_EOF;

            when CHECK_EOF =>   if(freader_done = '0') then
                                    next_state <= START_STATE;
                                else
                                    next_state <= IDLE;
                                end if;

            when START_STATE => next_state <= SEND_ABC0;

            when SEND_ABC0 => next_state <= SEND_ABC1;

            when SEND_ABC1 =>   if(add_sub_ABC_done = '1') then
                                    next_state <= SAVE_OUT0;
                                else
                                    next_state <= SEND_ABC1;
                                end if;

            when SAVE_OUT0 => next_state <= SAVE_OUT1;

            when SAVE_OUT1 =>   next_state <= READ_INPUT;

            when others => next_state <= RST;
        end case;
    end process;

    -- Control signals generation process
    control_process: process(pres_state)
    begin
        -- Default values
        add_sub_ABC_start <= '0';
        add_sub_ABC_rst_n <= '0';
        AB_freader_enable <= '0';
        C_freader_enable <= '0';
        sign_freader_enable <= '0';
        fwriter_enable <= '0';

        case pres_state is
            when RST =>

            when IDLE =>    add_sub_ABC_rst_n <= '1'; 

            when READ_INPUT =>  add_sub_ABC_rst_n <= '1';
                                AB_freader_enable <= '1';
                                C_freader_enable <= '1';
                                sign_freader_enable <= '1';

            when CHECK_EOF =>   add_sub_ABC_rst_n <= '1';

            when START_STATE => add_sub_ABC_start <= '1';
                                add_sub_ABC_rst_n <= '1';

            when SEND_ABC0 =>   add_sub_ABC_rst_n <= '1';
                                C_freader_enable <= '1';
                                sign_freader_enable <= '1';

            when SEND_ABC1 =>   add_sub_ABC_rst_n <= '1';

            when SAVE_OUT0 =>   add_sub_ABC_rst_n <= '1';
                                fwriter_enable <= '1';

            when SAVE_OUT1 =>   add_sub_ABC_rst_n <= '1';
                                fwriter_enable <= '1';
        end case;
    end process;

end architecture behaviour;

-- Copyright 2023, Norbert Takacs (norberttak@gmail.com)
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.homecockpit_pck.all;

entity status is
    port(
        address     : in std_Logic_vector(7 downto 0);
        data_to_cpu : out std_logic_vector(7 downto 0);
        rd          : in std_logic;
        wr          : in std_logic;
        cs_status   : in std_logic;

        port_changed0     : in std_logic;
        port_changed1     : in std_logic;
        port_changed2     : in std_logic;
        port_changed3     : in std_logic;
        port_changed4     : in std_logic;
        port_changed5     : in std_logic;
        port_changed6     : in std_logic;

        irq         : out std_logic;

        clk         : in std_logic;
        n_reset     : in std_logic
    );
end status;

architecture status_beh of status is
    constant VERSION : std_logic_vector(2 downto 0) := "001";

    type state_type is (IDLE, WAIT_FOR_READ, IN_READ, READ_DONE);
    signal s_state : state_type;
    signal s_irq_multi   : std_logic;

begin
    detect_irq : process (clk, n_reset)
    begin
        if (n_reset = '0') then
            s_irq_multi <= '0';
            s_state     <= IDLE;
        elsif (clk'event and clk='1') then
            case s_state is
                when IDLE =>
                    if (port_changed0 = '1' or
                        port_changed1 = '1' or
                        port_changed2 = '1' or
                        port_changed3 = '1' or
                        port_changed4 = '1' or
                        port_changed5 = '1' or
                        port_changed6 = '1') then
                            s_irq_multi <= '1';
                            s_state <= WAIT_FOR_READ;
                    end if;

                when WAIT_FOR_READ =>
                    if (rd = '1' and cs_status = '1') then
                        s_state <= IN_READ;
                    end if;

                when IN_READ =>
                    if (rd = '0' or cs_status = '0') then
                        s_state <= READ_DONE;
                    end if;

                when READ_DONE =>
                    s_state <= IDLE;
                    s_irq_multi <= '0';

                when others =>
                    s_state <= IDLE;

            end case;
        end if;
    end process;

    data_to_cpu <= (s_irq_multi & VERSION & "0000") when n_reset = '1' else (others => '0');
    irq <= s_irq_multi when n_reset = '1' else '0';

end status_beh;

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

entity output is
    port(
        address     : in std_Logic_vector(7 downto 0);
        data_to_cpu : out std_logic_vector(7 downto 0);
        data_from_cpu: in std_logic_vector(7 downto 0);

        rd          : in std_logic;
        wr          : in std_logic;
        cs_output   : in std_logic;

        out_port    : out std_logic_vector(7 downto 0);
        
        clk         : in std_logic;
        n_reset     : in std_logic
    );
end output;

architecture output_beh of output is

    type state_type is (IDLE, WAIT_FOR_READ, IN_READ, READ_DONE);
    signal s_state : state_type;
    signal s_out_port : std_logic_vector(7 downto 0);

begin
    port_change : process (clk, n_reset)
    begin
        if (n_reset = '0') then
            s_out_port <= (others => '0');
        elsif (clk'event and clk='1') then
            if (cs_output = '1' and wr = '1' and rd = '0') then
                s_out_port <= data_from_cpu;
            end if;
        end if;
    end process;

    data_to_cpu <= s_out_port when (n_reset = '1') else (others => '0');
    out_port    <= s_out_port when (n_reset = '1') else (others => '0');

end output_beh;

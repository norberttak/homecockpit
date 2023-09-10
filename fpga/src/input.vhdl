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

entity input is
    port(
        address     : in std_Logic_vector(7 downto 0);
        data_to_cpu : out std_logic_vector(7 downto 0);
        rd          : in std_logic;
        wr          : in std_logic;
        cs_input    : in std_logic;

        port_changed : out std_logic;
       
        switch_port  : in std_logic_vector(7 downto 0);
        
        clk         : in std_logic;
        n_reset     : in std_logic
    );
end input;

architecture input_beh of input is

    signal s_port_changed : std_logic;
    signal s_switch_port     : std_logic_vector(7 downto 0);
begin
    detect_port_change : process (clk, n_reset)
        variable v_port_state : std_logic_vector(7 downto 0);
        variable v_port_state_prev : std_logic_vector(7 downto 0);
    begin
        if (n_reset = '0') then
            s_port_changed <= '0';
            s_switch_port <= switch_port;
            v_port_state := switch_port;
            v_port_state_prev := v_port_state;    
        elsif (clk'event and clk='1') then
            s_switch_port <= switch_port;
            v_port_state := switch_port;

            if (v_port_state /= v_port_state_prev) then
                s_port_changed <= '1';
            else
                s_port_changed <= '0';
            end if;
            
            v_port_state_prev := v_port_state;

        end if;
    end process;

    data_to_cpu  <= s_switch_port when (n_reset = '1' and rd = '1' and cs_input = '1') else (others => '0');
    port_changed <= s_port_changed when (n_reset = '1') else '0';

end input_beh;

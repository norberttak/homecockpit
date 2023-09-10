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

entity control is
    port(
        address     : in std_Logic_vector(7 downto 0);
        data_from_cpu   : in std_logic_vector(7 downto 0);
        data_to_cpu : out std_logic_vector(7 downto 0);
        rd          : in std_logic;
        wr          : in std_logic;
        cs_control  : in std_logic;

        enable_irq  : out std_logic;
        auto_address_inc : out std_logic;        
        
        clk         : in std_logic;
        n_reset     : in std_logic        
    );
end control;

architecture control_beh of control is
    signal s_enable_irq : std_logic;
    signal s_auto_addr_inc : std_logic;
    signal s_data_to_cpu : std_logic_vector(7 downto 0);
begin
    update_reg : process (clk, n_reset)
    begin
        if (n_reset = '0') then
            s_enable_irq     <= '1';
            s_auto_addr_inc  <= '1';
            s_data_to_cpu    <= (others => '0');
        elsif (clk'event and clk='1') then
            if (wr = '1' and cs_control = '1') then
                s_enable_irq <= data_from_cpu(7);
                s_auto_addr_inc <= data_from_cpu(5);
                s_data_to_cpu <= data_from_cpu;
            end if;
        end if;       
        
    end process;

    enable_irq <= s_enable_irq when n_reset = '1' else '0';
    auto_address_inc <= s_auto_addr_inc when n_reset = '1' else '0';
    data_to_cpu <= s_data_to_cpu when n_reset = '1' else (others => '0');

end control_beh;

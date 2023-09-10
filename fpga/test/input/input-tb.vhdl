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
use work.utest.all; 

library std;
use std.env.finish;

-- -----------------------------
entity input_tb is
end input_tb;

-- -----------------------------
architecture behavior of input_tb is
    signal s_address        : std_logic_vector(7 downto 0);
    signal s_data_from_cpu  : std_logic_vector(7 downto 0);
    signal s_data_to_cpu    : std_logic_vector(7 downto 0);
    signal s_rd             : std_logic;
    signal s_wr             : std_logic;
    signal s_cs_input       : std_logic;
    
    signal s_switch_port    : std_logic_vector(7 downto 0);    
    signal s_port_changed   : std_logic;

    signal s_clk            : std_logic;
    signal s_n_reset        : std_logic;
begin
    input_inst: entity work.input(input_beh) port map (
        address             => s_address,
        data_to_cpu         => s_data_to_cpu,
        rd                  => s_rd,
        wr                  => s_wr,
        switch_port         => s_switch_port,
        cs_input            => s_cs_input,
        port_changed        => s_port_changed,
        clk                 => s_clk,
        n_reset             => s_n_reset
    );

    clock_gen_inst: entity work.clock_gen(behaviour) port map (
        clock   => s_clk
    );

    CREATE_TEST_REPORT("Tests for input ports", "input-ports.html");

    main : process
    begin
   
    -- do a reset cycle at the begining
    s_rd <= '0';
    s_wr <= '0';
    s_cs_input <= '0';
    s_address <= x"00";
    s_switch_port <= (others => '0');
    s_data_from_cpu <= (others => '0');

    s_n_reset <= '0';
    wait for 10.0 us;
    s_n_reset <= '1';
    wait for 10.0 us;

    TEST("Set one input line to 1");
    s_switch_port(0) <= '1';
    wait for 10 us;
    s_cs_input <= '1';
    s_rd <= '1';
    wait for 20 us;
    EXPECT_EQ("check received data", x"01", s_data_to_cpu);
    s_cs_input <= '0';
    s_rd <= '0';
    -- ======================================================================

    CLOSE_TEST_REPORT;
    finish;
    end process;

end;

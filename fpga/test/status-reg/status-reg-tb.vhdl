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
entity status_reg_tb is
end status_reg_tb;

-- -----------------------------
architecture behavior of status_reg_tb is
    signal s_address        : std_logic_vector(7 downto 0);
    signal s_data_from_cpu  : std_logic_vector(7 downto 0);
    signal s_data_to_cpu    : std_logic_vector(7 downto 0);
    signal s_rd             : std_logic;
    signal s_wr             : std_logic;
    signal s_cs_Status      : std_logic;
    
    signal s_port_changed0  : std_logic;
    signal s_port_changed1  : std_logic;
    signal s_port_changed2  : std_logic;
    signal s_port_changed3  : std_logic;
    signal s_port_changed4  : std_logic;
    signal s_port_changed5  : std_logic;
    signal s_port_changed6  : std_logic;

    signal s_irq            : std_logic;

    signal s_clk            : std_logic;
    signal s_n_reset        : std_logic;
begin
    status_inst: entity work.status(status_beh) port map (
        address             => s_address,
        data_to_cpu         => s_data_to_cpu,
        rd                  => s_rd,
        wr                  => s_wr,
        cs_status           => s_cs_status,
        port_changed0       => s_port_changed0,
        port_changed1       => s_port_changed1,
        port_changed2       => s_port_changed2,
        port_changed3       => s_port_changed3,
        port_changed4       => s_port_changed4,
        port_changed5       => s_port_changed5,
        port_changed6       => s_port_changed6,
        irq                 => s_irq,

        clk                 => s_clk,
        n_reset             => s_n_reset
    );

    clock_gen_inst: entity work.clock_gen(behaviour) port map (
        clock   => s_clk
    );

    CREATE_TEST_REPORT("Tests for status register", "status-register.html");

    main : process
    begin
    
    -- do a reset cycle at the begining
    s_rd <= '0';
    s_wr <= '0';
    s_cs_status <= '0';
    s_port_changed0 <= '0';
    s_port_changed1 <= '0';
    s_port_changed2 <= '0';
    s_port_changed3 <= '0';
    s_port_changed4 <= '0';
    s_port_changed5 <= '0';
    s_port_changed6 <= '0';
    s_address <= x"00";
    s_data_from_cpu <= (others => '0');

    s_n_reset <= '0';
    wait for 10.0 us;
    s_n_reset <= '1';
    wait for 10.0 us;

    TEST("CPU reads FPGA status register");
    s_cs_status <= '1';
    s_rd <= '1';
    wait for 20 us;
    EXPECT_EQ("check received data", x"10", s_data_to_cpu);
    s_cs_status <= '0';
    s_rd <= '0';
    -- ======================================================================


    TEST("One input port is changed. Status register shall set the IRQ bit");
    s_port_changed0 <= '1';
    wait for 5 us;
    s_port_changed0 <= '0';

    s_cs_status <= '1';
    s_rd <= '1';
    wait for 20 us;
    EXPECT_EQ("check irq bit", x"90", s_data_to_cpu);
    s_cs_status <= '0';
    s_rd <= '0';
    wait for 5 us;

    s_cs_status <= '1';
    s_rd <= '1';
    wait for 20 us;
    EXPECT_EQ("the previous read shall clear the IRQ bit", x"10", s_data_to_cpu);
    s_cs_status <= '0';
    s_rd <= '0';

    -- ======================================================================

    CLOSE_TEST_REPORT;
    finish;
    end process;

end;

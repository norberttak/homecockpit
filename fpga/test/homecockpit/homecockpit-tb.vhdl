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
use work.homecockpit_pck.all;

library std;
use std.env.finish;

-- -----------------------------
entity homecockpit_tb is
end homecockpit_tb;

-- -----------------------------
architecture behavior of homecockpit_tb is
    signal s_miso           : std_logic;
    signal s_mosi           : std_logic;
    signal s_sclk           : std_logic;
    signal s_n_cs           : std_logic;
    signal s_cpu_irq        : std_logic;

    signal s_input_0        : std_logic_vector(7 downto 0);
    signal s_input_1        : std_logic_vector(7 downto 0);
    signal s_input_2        : std_logic_vector(7 downto 0);
    signal s_input_3        : std_logic_vector(7 downto 0);
    signal s_input_4        : std_logic_vector(7 downto 0);
    signal s_input_5        : std_logic_vector(7 downto 0);
    signal s_input_6        : std_logic_vector(7 downto 0);

    signal s_output_0       : std_logic_vector(7 downto 0);
    signal s_output_1       : std_logic_vector(7 downto 0);
    signal s_output_2       : std_logic_vector(7 downto 0);
    signal s_output_3       : std_logic_vector(7 downto 0);
    signal s_output_4       : std_logic_vector(7 downto 0);

    signal s_clk            : std_logic;
    signal s_n_reset        : std_logic;
begin

    homecockpit_inst: entity work.homecockpit(behaviour) port map (
        miso             => s_miso,
        mosi             => s_mosi,
        sclk             => s_sclk,
        n_cs             => s_n_cs,
        cpu_irq          => s_cpu_irq,

        input_0          => s_input_0,
        input_1          => s_input_1,
        input_2          => s_input_2,
        input_3          => s_input_3,
        input_4          => s_input_4,
        input_5          => s_input_5,
        input_6          => s_input_6,

        output_0         => s_output_0,
        output_1         => s_output_1,
        output_2         => s_output_2,
        output_3         => s_output_3,
        output_4         => s_output_4,

        clk              => s_clk,
        n_reset          => s_n_reset
    );

    clock_gen_inst: entity work.clock_gen(behaviour) port map (
        clock   => s_clk
    );

    CREATE_TEST_REPORT("Tests for homecockpit", "homecockpit.html");

    main : process
        variable v_test_data  : std_logic_vector(7 downto 0);
        variable v_read_data  : std_logic_vector(7 downto 0);
        variable v_test_address : std_logic_vector(7 downto 0);
        variable v_output_0   : std_logic_vector(7 downto 0);
        variable v_output_1   : std_logic_vector(7 downto 0);
        variable v_output_2   : std_logic_vector(7 downto 0);
        variable v_output_3   : std_logic_vector(7 downto 0);
        variable v_output_4   : std_logic_vector(7 downto 0);

        procedure spi_write_one_byte(data : std_logic_vector(7 downto 0)) is
        begin
            for bit_count in 7 downto 0 loop 
                s_mosi <= data(bit_count);
                s_sclk <= '1';
                wait for (5 us);
                s_sclk <= '0';
                wait for (5 us);
            end loop;
        end spi_write_one_byte;

        procedure spi_read_one_byte is
        begin
            v_read_data := x"00";    
            for bit_count in 7 downto 0 loop 
                s_sclk <= '1';
                wait for (5 us);
                v_read_data(bit_count) := s_miso;                
                s_sclk <= '0';
                wait for (5 us);
            end loop;
        end spi_read_one_byte;

        procedure cpu_writes_fpga(addr : std_logic_vector(7 downto 0); data : std_logic_vector(7 downto 0)) is 
        begin
            s_n_cs <= '0';
            wait for (5 us);
            spi_write_one_byte(x"00");
            wait for (5 us);
            spi_write_one_byte(addr);
            s_n_cs <= '1';
            wait for (5 us);

            s_n_cs <= '0';
            wait for (5 us);
            spi_write_one_byte(x"10");
            wait for (5 us);
            spi_write_one_byte(data);
            s_n_cs <= '1';
            wait for (5 us);
        end cpu_writes_fpga;

        procedure cpu_writes_fpga(data : std_logic_vector(7 downto 0)) is 
        begin
            s_n_cs <= '0';
            wait for (5 us);
            spi_write_one_byte(x"10");
            wait for (5 us);
            spi_write_one_byte(data);
            s_n_cs <= '1';
            wait for (5 us);
        end cpu_writes_fpga;

        procedure cpu_reads_fpga(addr : in std_logic_vector(7 downto 0)) is
        begin
            s_n_cs <= '0';
            wait for (5 us);
            spi_write_one_byte(x"00");
            wait for (5 us);
            spi_write_one_byte(addr);
            s_n_cs <= '1';
            wait for (5 us);

            s_n_cs <= '0';
            wait for (5 us);
            spi_write_one_byte(x"20");
            wait for (5 us);
            spi_read_one_byte;
            s_n_cs <= '1';
            wait for (5 us);
        end cpu_reads_fpga;

    begin

    s_n_cs <= '1';
    s_sclk <= '0';
    s_mosi <= '0';
    s_input_0 <= (others => '0');
    s_input_1 <= (others => '0');
    s_input_2 <= (others => '0');
    s_input_3 <= (others => '0');
    s_input_4 <= (others => '0');
    s_input_5 <= (others => '0');
    s_input_6 <= (others => '0');

    s_n_reset <= '0';
    wait for 10.0 us;
    s_n_reset <= '1';
    wait for 10.0 us;

    TEST("Set output");
    v_test_data := x"55";
    cpu_writes_fpga(x"0C",v_test_data);
    wait for 20 us;    
    EXPECT_EQ("check output port 2", v_test_data, s_output_2);

--    v_test_data := x"22";
--    cpu_writes_fpga(x"0a",v_test_data);
--    wait for 20 us;
--    EXPECT_EQ("check output port 1", v_test_data, s_output_1);

--    v_test_data := x"AB";
--    cpu_writes_fpga(x"0b",v_test_data);
--    wait for 20 us;
--    EXPECT_EQ("check output port 2",v_test_data, s_output_2);
    -- ======================================================================

--    TEST("Check all output registers. Use auto address increment");
--    v_output_0 := x"20";
--    v_output_1 := x"21";
--    v_output_2 := x"22";
--    v_output_3 := x"23";
--    v_output_4 := x"24";

--    s_n_cs <= '0';
--    wait for (5 us);
--    spi_write_one_byte(x"30"); -- burst write command
--    wait for (5 us);
--    spi_write_one_byte(x"09");
--    wait for (5 us);

--    spi_write_one_byte(v_output_0);
--    wait for (5 us);
--    EXPECT_EQ("check output port", v_output_0, s_output_0);

--    spi_write_one_byte(v_output_1);
--    wait for (5 us);
--    EXPECT_EQ("check output port", v_output_1, s_output_1);

--    spi_write_one_byte(v_output_2);
--    wait for (5 us);
--    EXPECT_EQ("check output port", v_output_2, s_output_2);

--    spi_write_one_byte(v_output_3);
--    wait for (5 us);
--    EXPECT_EQ("check output port", v_output_3, s_output_3);

--    spi_write_one_byte(v_output_4);
--    wait for (5 us);
--    EXPECT_EQ("check output port", v_output_4, s_output_4);
--    s_n_cs <= '1';
    -- ======================================================================

    TEST("Check input register 0");
    s_input_0 <= x"22";
    wait for 20 us;
    cpu_reads_fpga(x"03");
    wait for 20 us;
    EXPECT_EQ("check input register 0", s_input_0, v_read_data);

--    TEST("Check input register 1");
--    s_input_1 <= x"ff";
--    wait for 20 us;
--    cpu_reads_fpga(x"03");
--    wait for 20 us;
--    EXPECT_EQ("check input register 1", s_input_1, v_read_data);
    -- ======================================================================

    v_test_data := x"FF";
    cpu_writes_fpga(x"0C",v_test_data);
    wait for 20 us;
    EXPECT_EQ("check output port 2 again",v_test_data, s_output_2);

--    TEST("Read all input registers. Use auto address increment");
--    s_input_0 <= x"10";
--    s_input_1 <= x"11";
--    s_input_2 <= x"12";
--    s_input_3 <= x"13";
--    s_input_4 <= x"14";
--    s_input_5 <= x"15";
--    s_input_6 <= x"16";
--    wait for (5 us);

--    s_n_cs <= '0';
--    wait for (5 us);

--    spi_write_one_byte(x"40"); -- burst read command
--    wait for (5 us);
    
--    spi_write_one_byte(x"02"); -- input 0 address
--    wait for (5 us);

--    spi_read_one_byte;
--    wait for 5 us;
--    EXPECT_EQ("check input register 0", s_input_0, v_read_data);

--    spi_read_one_byte;
--    wait for 5 us;
--    EXPECT_EQ("check input register 1", s_input_1, v_read_data);

--    spi_read_one_byte;
--    wait for 5 us;
--    EXPECT_EQ("check input register 2", s_input_2, v_read_data);

--    spi_read_one_byte;
--    wait for 5 us;
--    EXPECT_EQ("check input register 3", s_input_3, v_read_data);

--    spi_read_one_byte;
--    wait for 5 us;
--    EXPECT_EQ("check input register 4", s_input_4, v_read_data);

--    spi_read_one_byte;
--    wait for 5 us;
--    EXPECT_EQ("check input register 5", s_input_5, v_read_data);

--    spi_read_one_byte;
--    wait for 5 us;
--    EXPECT_EQ("check input register 6", s_input_6, v_read_data);

--    s_n_cs <= '1';
    -- ======================================================================

    CLOSE_TEST_REPORT;
    finish;
    end process;
end;

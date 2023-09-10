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
use ieee.numeric_std.all;

library work;
use work.utest.all; 

library std;
use std.env.finish;

-- -----------------------------
entity spi_cpu_interface_tb is
end spi_cpu_interface_tb;

-- -----------------------------
architecture behavior of spi_cpu_interface_tb is

    signal s_clk            : std_logic;
    signal s_miso           : std_logic;
    signal s_mosi           : std_logic;
    signal s_sclk           : std_logic;
    signal s_n_cs           : std_logic;

    signal s_address        : std_logic_vector(7 downto 0);
    signal s_data_from_cpu  : std_logic_vector(7 downto 0);
    signal s_data_to_cpu    : std_logic_vector(7 downto 0);
    signal s_rd             : std_logic;
    signal s_wr             : std_logic;
    signal s_auto_addr_inc  : std_logic;

    signal s_n_reset        : std_logic;
begin
    spi_cpu_interface_inst: entity work.spi_cpu_interface(behaviour) port map (
        miso                => s_miso,
        mosi                => s_mosi,
        sclk                => s_sclk,
        n_cs                => s_n_cs,
        
        address             => s_address,
        data_from_cpu       => s_data_from_cpu,
        data_to_cpu         => s_data_to_cpu,
        rd                  => s_rd,
        wr                  => s_wr,
        auto_addr_inc       => s_auto_addr_inc,
        
        clk                 => s_clk,
        n_reset             => s_n_reset
    );

    clock_gen_inst: entity work.clock_gen(behaviour) port map (
        clock   => s_clk
    );
    
    CREATE_TEST_REPORT("Tests for SPI CPU interace", "spi-cpu-interface.html");

    main : process
        variable v_test_data  : std_logic_vector(7 downto 0);
        variable v_read_data  : std_logic_vector(7 downto 0);
        variable v_test_address : std_logic_vector(7 downto 0);

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
    
    -- do a reset cycle at the begining

    s_mosi <= '0';
    s_n_cs <= '1';
    s_sclk <= '0';
    s_data_to_cpu <= (others => '0');

    s_n_reset <= '0';
    wait for 10.0 us;
    s_n_reset <= '1';
    wait for 10.0 us;

    TEST("CPU writes FPGA register.");
    v_test_data := x"55";
    v_test_address := x"11";
    cpu_writes_fpga(v_test_address,v_test_data);
    wait for 20 us;
    EXPECT_EQ("check received address",v_test_address, s_address); 
    EXPECT_EQ("check received data", v_test_data, s_data_from_cpu);

--    v_test_data := x"ff";
--    cpu_writes_fpga(v_test_data);
--    wait for 20 us;
--    EXPECT_EQ("check received address. it shall be the same as previous",v_test_address, s_address); 
--    EXPECT_EQ("check received data", v_test_data, s_data_from_cpu);    
    -- ======================================================================
    
--    TEST("CPU writes FPGA registers on burst mode");
--    v_test_data := x"10";
--    v_test_address := x"22";

--    s_n_cs <= '0';
--    wait for (5 us);
--    spi_write_one_byte(x"30"); -- burst write command
--    wait for (5 us);
--    spi_write_one_byte(v_test_address);
--    wait for (5 us);

--    for data_inc in 0 to 10 loop 
--        spi_write_one_byte(std_logic_vector(unsigned(v_test_data) + data_inc));
--        wait for (5 us);
--        EXPECT_EQ("check address", std_logic_vector(unsigned(v_test_address) + data_inc), s_address);
--        EXPECT_EQ("check data", std_logic_vector(unsigned(v_test_data) + data_inc), s_data_from_cpu);
--    end loop;

--    s_n_cs <= '1';
--    wait for (5 us);
    -- ======================================================================

    TEST("CPU reads FPGA register. Address 0x02, data 0xAB");
    s_data_to_cpu <= x"0F";
    v_test_address := x"02";
    cpu_reads_fpga(v_test_address);
    wait for 20 us;
    EXPECT_EQ("check received address",v_test_address, s_address); 
    EXPECT_EQ("check received data", s_data_to_cpu, v_read_data);
    -- ======================================================================


    TEST("CPU writes FPGA register 2.");
    v_test_data := x"AA";
    v_test_address := x"33";
    cpu_writes_fpga(v_test_address,v_test_data);
    wait for 20 us;
    EXPECT_EQ("check received address",v_test_address, s_address); 
    EXPECT_EQ("check received data", v_test_data, s_data_from_cpu);

--    TEST("CPU reads FPGA registers on burst mode");
--    v_test_data := x"11";
--    v_test_address := x"55";
--    s_data_to_cpu <= std_logic_vector(unsigned(v_test_data));

--    s_n_cs <= '0';
--    wait for (5 us);
--    spi_write_one_byte(x"40"); -- burst read command
--    wait for (5 us);
--    spi_write_one_byte(v_test_address);
--    wait for (5 us);

--    for data_inc in 0 to 10 loop 
--        s_data_to_cpu <= std_logic_vector(unsigned(v_test_data) + data_inc);
--        wait for (5 us);
--        spi_read_one_byte;
--        wait for (5 us);
--        EXPECT_EQ("check address", std_logic_vector(unsigned(v_test_address) + data_inc), s_address);
--        EXPECT_EQ("check data", std_logic_vector(unsigned(v_test_data) + data_inc), v_read_data);
--    end loop;

--    s_n_cs <= '1';
--    wait for (5 us);

    CLOSE_TEST_REPORT;
    finish;
    end process;

end;

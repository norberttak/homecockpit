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

package homecockpit_pck is

    component homecockpit is
    port(
        miso        : out std_logic;
        mosi        : in std_logic;
        sclk        : in std_logic;
        n_cs        : in std_logic;
        cpu_irq     : out std_logic;

        input_0     : in std_logic_vector(7 downto 0);
        input_1     : in std_logic_vector(7 downto 0);
        input_2     : in std_logic_vector(7 downto 0);
        input_3     : in std_logic_vector(7 downto 0);
        input_4     : in std_logic_vector(7 downto 0);
        input_5     : in std_logic_vector(7 downto 0);
        input_6     : in std_logic_vector(7 downto 0);

        output_0    : out std_logic_vector(7 downto 0);
        output_1    : out std_logic_vector(7 downto 0);
        output_2    : out std_logic_vector(7 downto 0);
        output_3    : out std_logic_vector(7 downto 0);
        output_4    : out std_logic_vector(7 downto 0);
        output_5    : out std_logic_vector(7 downto 0);

  		  hex_0		  : out std_logic_vector(6 downto 0);
		  hex_1		  : out std_logic_vector(6 downto 0);

        clk         : in std_logic;
        n_reset     : in std_logic
    );
    end component homecockpit;

    component spi_slave is
    generic (
        WORD_SIZE : natural := 8 -- size of transfer word in bits, must be power of two
    );
    port (
        CLK      : in  std_logic; -- system clock
        RST      : in  std_logic; -- high active synchronous reset
        -- SPI SLAVE INTERFACE
        SCLK     : in  std_logic; -- SPI clock
        CS_N     : in  std_logic; -- SPI chip select, active in low
        MOSI     : in  std_logic; -- SPI serial data from master to slave
        MISO     : out std_logic; -- SPI serial data from slave to master
        -- USER INTERFACE
        DIN      : in  std_logic_vector(WORD_SIZE-1 downto 0); -- data for transmission to SPI master
        DIN_VLD  : in  std_logic; -- when DIN_VLD = 1, data for transmission are valid
        DIN_RDY  : out std_logic; -- when DIN_RDY = 1, SPI slave is ready to accept valid data for transmission
        DOUT     : out std_logic_vector(WORD_SIZE-1 downto 0); -- received data from SPI master
        DOUT_VLD : out std_logic  -- when DOUT_VLD = 1, received data are valid
    );
    end component;

    component spi_cpu_interface is
    port(
        miso        : out std_logic;
        mosi        : in std_logic;
        sclk        : in std_logic;
        n_cs         : in std_logic;

        address     : out std_logic_vector(7 downto 0);
        data_from_cpu : out std_logic_vector(7 downto 0);
        data_to_cpu : in std_logic_vector(7 downto 0);
        rd          : out std_logic;
        wr          : out std_logic;
        auto_addr_inc : in std_logic;

        clk         : in std_logic;
        n_reset     : in std_logic
    );
    end component spi_cpu_interface;

    component control is
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
    end component control;
    
    component status is
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
    end component status;
    
    component input is
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
    end component input;

    
    component output is
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
    end component output;
    
    component decoder is
    port(
        address     : in std_Logic_vector(7 downto 0);
        rd          : in std_logic;
        wr          : in std_logic;

        cs_status   : out std_logic;
        cs_control  : out std_logic;
        cs_in0      : out std_logic;
        cs_in1      : out std_logic;
        cs_in2      : out std_logic;
        cs_in3      : out std_logic;
        cs_in4      : out std_logic;
        cs_in5      : out std_logic;
        cs_in6      : out std_logic;
        cs_out0     : out std_logic;
        cs_out1     : out std_logic;
        cs_out2     : out std_logic;
        cs_out3     : out std_logic;
        cs_out4     : out std_logic;
        cs_lcd      : out std_logic
    );
    end component decoder;
    
end;

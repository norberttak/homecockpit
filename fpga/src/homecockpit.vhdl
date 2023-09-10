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
use work.homecockpit_pck.all;

entity homecockpit is
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

		  hex_0		  : out std_logic_vector(6 downto 0);
		  hex_1		  : out std_logic_vector(6 downto 0);
		  
        clk         : in std_logic;
        n_reset     : in std_logic
    );
end homecockpit;

architecture behaviour of homecockpit is
    signal s_output_0 : std_logic_vector(7 downto 0);
    signal s_output_1 : std_logic_vector(7 downto 0);
    signal s_output_2 : std_logic_vector(7 downto 0);
    signal s_output_3 : std_logic_vector(7 downto 0);
    signal s_output_4 : std_logic_vector(7 downto 0);
    signal s_data_from_cpu : std_logic_vector(7 downto 0);
    
    signal s_data_to_cpu   : std_logic_vector(7 downto 0);
    signal s_data_to_cpu_status    : std_logic_vector(7 downto 0);
    signal s_data_to_cpu_control   : std_logic_vector(7 downto 0);
    signal s_data_to_cpu_out0   : std_logic_vector(7 downto 0);
    signal s_data_to_cpu_out1   : std_logic_vector(7 downto 0);
    signal s_data_to_cpu_out2   : std_logic_vector(7 downto 0);
    signal s_data_to_cpu_out3   : std_logic_vector(7 downto 0);
    signal s_data_to_cpu_out4   : std_logic_vector(7 downto 0);
    signal s_data_to_cpu_in0    : std_logic_vector(7 downto 0);
    signal s_data_to_cpu_in1    : std_logic_vector(7 downto 0);
    signal s_data_to_cpu_in2    : std_logic_vector(7 downto 0);
    signal s_data_to_cpu_in3    : std_logic_vector(7 downto 0);
    signal s_data_to_cpu_in4    : std_logic_vector(7 downto 0);
    signal s_data_to_cpu_in5    : std_logic_vector(7 downto 0);
    signal s_data_to_cpu_in6    : std_logic_vector(7 downto 0);
    signal s_data_to_cpu_lcd    : std_logic_vector(7 downto 0);

    signal s_address       : std_logic_vector(7 downto 0);
    signal s_rd            : std_logic;
    signal s_wr            : std_logic;
    signal s_irq           : std_logic;
    signal s_auto_addr_inc : std_logic;
	 signal s_enable_irq		: std_logic;
	 
    signal s_port_changed0 : std_logic;
    signal s_port_changed1 : std_logic;
    signal s_port_changed2 : std_logic;
    signal s_port_changed3 : std_logic;
    signal s_port_changed4 : std_logic;
    signal s_port_changed5 : std_logic;
    signal s_port_changed6 : std_logic;

    signal s_cs_out        : std_logic_vector(4 downto 0);
    signal s_cs_in         : std_logic_vector(6 downto 0);
    signal s_cs_status     : std_logic;
    signal s_cs_control    : std_logic;
    signal s_cs_lcd        : std_logic;
    signal s_internal_cs_vector : std_logic_vector(14 downto 0);

    signal s_miso          : std_logic;	 

begin

    spi_cpu_interface_inst: entity work.spi_cpu_interface(behaviour) port map (
        miso                => s_miso,
        mosi                => mosi,
        sclk                => sclk,
        n_cs                => n_cs,    

        address             => s_address,
        data_from_cpu       => s_data_from_cpu,
        data_to_cpu         => s_data_to_cpu,
        rd                  => s_rd,
        wr                  => s_wr,
        auto_addr_inc       => s_auto_addr_inc,
        
        clk                 => clk,
        n_reset             => n_reset
    );
    
    -- address decoder
    decoder_inst: entity work.decoder(decoder_beh) port map (
        address     => s_address,
        rd          => s_rd,
        wr          => s_wr,

        cs_status   => s_cs_status,
        cs_control  => s_cs_control,
        cs_in0      => s_cs_in(0),
        cs_in1      => s_cs_in(1),
        cs_in2      => s_cs_in(2),
        cs_in3      => s_cs_in(3),
        cs_in4      => s_cs_in(4),
        cs_in5      => s_cs_in(5),
        cs_in6      => s_cs_in(6),
        cs_out0     => s_cs_out(0),
        cs_out1     => s_cs_out(1),
        cs_out2     => s_cs_out(2),
        cs_out3     => s_cs_out(3),
        cs_out4     => s_cs_out(4),
        cs_lcd      => s_cs_lcd
    );

    status_inst: entity work.status(status_beh) port map (
        address             => s_address,
        data_to_cpu         => s_data_to_cpu_status,
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
        clk                 => clk,
        n_reset             => n_reset
    );
    
    control_inst: entity work.control(control_beh) port map (
        address             => s_address,
        data_to_cpu         => s_data_to_cpu_control,
        data_from_cpu       => s_data_from_cpu,
        rd                  => s_rd,
        wr                  => s_wr,
        cs_control          => s_cs_control,
        enable_irq          => s_enable_irq,
        auto_address_inc    => s_auto_addr_inc,
        clk                 => clk,
        n_reset             => n_reset
    );
    

    output_inst_0: entity work.output(output_beh) port map (
        address             => s_address,
        data_to_cpu         => s_data_to_cpu_out0,
        data_from_cpu       => s_data_from_cpu,
        rd                  => s_rd,
        wr                  => s_wr,
        out_port            => s_output_0,
        cs_output           => s_cs_out(0),
        clk                 => clk,
        n_reset             => n_reset
    );
    
    output_inst_1: entity work.output(output_beh) port map (
        address             => s_address,
        data_to_cpu         => s_data_to_cpu_out1,
        data_from_cpu       => s_data_from_cpu,
        rd                  => s_rd,
        wr                  => s_wr,
        out_port            => s_output_1,
        cs_output           => s_cs_out(1),
        clk                 => clk,
        n_reset             => n_reset
    );

    output_inst_2: entity work.output(output_beh) port map (
        address             => s_address,
        data_to_cpu         => s_data_to_cpu_out2,
        data_from_cpu       => s_data_from_cpu,
        rd                  => s_rd,
        wr                  => s_wr,
        out_port            => s_output_2,
        cs_output           => s_cs_out(2),
        clk                 => clk,
        n_reset             => n_reset
    );

    output_inst_3: entity work.output(output_beh) port map (
        address             => s_address,
        data_to_cpu         => s_data_to_cpu_out3,
        data_from_cpu       => s_data_from_cpu,
        rd                  => s_rd,
        wr                  => s_wr,
        out_port            => s_output_3,
        cs_output           => s_cs_out(3),
        clk                 => clk,
        n_reset             => n_reset
    );

    output_inst_4: entity work.output(output_beh) port map (
        address             => s_address,
        data_to_cpu         => s_data_to_cpu_out4,
        data_from_cpu       => s_data_from_cpu,
        rd                  => s_rd,
        wr                  => s_wr,
        out_port            => s_output_4,
        cs_output           => s_cs_out(4),
        clk                 => clk,
        n_reset             => n_reset
    );
	 
    input_inst_0: entity work.input(input_beh) port map (
        address             => s_address,
        data_to_cpu         => s_data_to_cpu_in0,
        rd                  => s_rd,
        wr                  => s_wr,
        switch_port         => input_0,
        cs_input            => s_cs_in(0),
        port_changed        => s_port_changed0,
        clk                 => clk,
        n_reset             => n_reset
    );
    
    input_inst_1: entity work.input(input_beh) port map (
        address             => s_address,
        data_to_cpu         => s_data_to_cpu_in1,
        rd                  => s_rd,
        wr                  => s_wr,
        switch_port         => input_1,
        cs_input            => s_cs_in(1),
        port_changed        => s_port_changed1,
        clk                 => clk,
        n_reset             => n_reset
    );

    input_inst_2: entity work.input(input_beh) port map (
        address             => s_address,
        data_to_cpu         => s_data_to_cpu_in2,
        rd                  => s_rd,
        wr                  => s_wr,
        switch_port         => input_2,
        cs_input            => s_cs_in(2),
        port_changed        => s_port_changed2,
        clk                 => clk,
        n_reset             => n_reset
    );

    input_inst_3: entity work.input(input_beh) port map (
        address             => s_address,
        data_to_cpu         => s_data_to_cpu_in3,
        rd                  => s_rd,
        wr                  => s_wr,
        switch_port         => input_3,
        cs_input            => s_cs_in(3),
        port_changed        => s_port_changed3,
        clk                 => clk,
        n_reset             => n_reset
    );

    input_inst_4: entity work.input(input_beh) port map (
        address             => s_address,
        data_to_cpu         => s_data_to_cpu_in4,
        rd                  => s_rd,
        wr                  => s_wr,
        switch_port         => input_4,
        cs_input            => s_cs_in(4),
        port_changed        => s_port_changed4,
        clk                 => clk,
        n_reset             => n_reset
    );

    input_inst_5: entity work.input(input_beh) port map (
        address             => s_address,
        data_to_cpu         => s_data_to_cpu_in5,
        rd                  => s_rd,
        wr                  => s_wr,
        switch_port         => input_5,
        cs_input            => s_cs_in(5),
        port_changed        => s_port_changed5,
        clk                 => clk,
        n_reset             => n_reset
    );

    input_inst_6: entity work.input(input_beh) port map (
        address             => s_address,
        data_to_cpu         => s_data_to_cpu_in6,
        rd                  => s_rd,
        wr                  => s_wr,
        switch_port         => input_6,
        cs_input            => s_cs_in(6),
        port_changed        => s_port_changed6,
        clk                 => clk,
        n_reset             => n_reset
    );


    s_data_to_cpu_lcd <= (others => '0');

    s_internal_cs_vector <= s_cs_out(4) & s_cs_out(3) & s_cs_out(2) & s_cs_out(1) & s_cs_out(0) &
                            s_cs_in(6) & s_cs_in(5) & s_cs_in(4) & s_cs_in(3) & s_cs_in(2) & s_cs_in(1) & s_cs_in(0) &
                            s_cs_lcd & s_cs_control & s_cs_status;
									 
    with s_internal_cs_vector select 
        s_data_to_cpu <= s_data_to_cpu_out4     when "100000000000000",
                         s_data_to_cpu_out3     when "010000000000000",
                         s_data_to_cpu_out2     when "001000000000000",
                         s_data_to_cpu_out1     when "000100000000000",
                         s_data_to_cpu_out0     when "000010000000000",
                         s_data_to_cpu_in6      when "000001000000000",
                         s_data_to_cpu_in5      when "000000100000000",
                         s_data_to_cpu_in4      when "000000010000000",
                         s_data_to_cpu_in3      when "000000001000000",
                         s_data_to_cpu_in2      when "000000000100000",
                         s_data_to_cpu_in1      when "000000000010000",
                         s_data_to_cpu_in0      when "000000000001000",
                         s_data_to_cpu_lcd      when "000000000000100",
                         s_data_to_cpu_control  when "000000000000010",
                         s_data_to_cpu_status   when "000000000000001",        
                         x"AA"                  when others;

  	 output_0 <= s_output_0 when n_reset = '1' else (others => '0');	 
    output_1 <= s_output_1 when n_reset = '1' else (others => '0');
    output_2 <= s_output_2 when n_reset = '1' else (others => '0');
    output_3 <= s_output_3 when n_reset = '1' else (others => '0');
    output_4 <= s_output_4 when n_reset = '1' else (others => '0');

    miso     <= s_miso when (n_reset = '1') else '0';
    cpu_irq  <= (s_irq and s_enable_irq) when (n_reset = '1') else '0';
	 
	 with s_address(3 downto 0) select
		hex_0 <= "1000000" when x"0",
					"1111001" when x"1",
					"0100100" when x"2",
					"0110000" when x"3",
					"0011001" when x"4",
					"0010010" when x"5",
					"0000010" when x"6",
					"1111000" when x"7",
					"0000000" when x"8",
					"0010000" when x"9",
					"0001000" when x"A",
					"0000011" when x"B",
					"0100001" when x"C",
					"1000010" when x"D",
					"0000110" when x"E",
					"0001110" when x"F",
					"1111111" when others;
	
	with s_address(7 downto 4) select
		hex_1 <= "1000000" when x"0",
					"1111001" when x"1",
					"0100100" when x"2",
					"0110000" when x"3",
					"0011001" when x"4",
					"0010010" when x"5",
					"0000010" when x"6",
					"1111000" when x"7",
					"0000000" when x"8",
					"0010000" when x"9",
					"0001000" when x"A",
					"0000011" when x"B",
					"0100001" when x"C",
					"1000010" when x"D",
					"0000110" when x"E",
					"0001110" when x"F",
					"1111111" when others;
end;

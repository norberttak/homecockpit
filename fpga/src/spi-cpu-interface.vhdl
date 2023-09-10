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

entity spi_cpu_interface is
    port(
        miso        : out std_logic;
        mosi        : in std_logic;
        sclk        : in std_logic;
        n_cs        : in std_logic;

        address     : out std_logic_vector(7 downto 0);
        data_from_cpu : out std_logic_vector(7 downto 0);
        data_to_cpu : in std_logic_vector(7 downto 0);
        rd          : out std_logic;
        wr          : out std_logic;
        auto_addr_inc : in std_logic;

        clk         : in std_logic;
        n_reset     : in std_logic
    );
end spi_cpu_interface;

architecture behaviour of spi_cpu_interface is
    constant CMD_SET_ADDRESS : std_logic_vector(7 downto 0) := x"00";
    constant CMD_WRITE_DATA  : std_logic_vector(7 downto 0) := x"10";
    constant CMD_READ_DATA   : std_logic_vector(7 downto 0) := x"20";
    constant CMD_BURST_WRITE : std_logic_vector(7 downto 0) := x"30";
    constant CMD_BURST_READ  : std_logic_vector(7 downto 0) := x"40";
    constant CMD_UNKNOWN     : std_logic_vector(7 downto 0) := x"ff";

    type state_type is (COMMAND, ADDR, WRITE_DATA, READ_DATA, BURST_READ_ADR_INC, BURST_WRITE_ADR_INC);
    signal s_state : state_type;

    --signal s_data_slave_in  : std_logic_vector(7 downto 0);
    signal s_data_slave_out : std_logic_vector(7 downto 0);
    signal s_data_in_valid  : std_logic;
    signal s_miso       : std_logic;
    signal s_address    : std_logic_vector(7 downto 0);
    signal s_data_from_cpu : std_logic_vector(7 downto 0);
    signal s_rd         : std_logic;
    signal s_wr         : std_logic;
    signal s_data_to_cpu_valid : std_logic; -- data for transmission are valid
    signal s_slave_ready    : std_logic; -- SPI slave is ready to accept valid data
    signal s_data_received : std_logic; -- when DOUT_VLD = 1, received data are valid
begin

    spi_slave_inst : entity work.spi_slave(rtl) port map (
        CLK => clk,
        RST => not n_reset,
        -- SPI SLAVE INTERFACE
        SCLK => sclk,
        CS_N => n_cs,
        MOSI => mosi,
        MISO => s_miso,
        -- USER INTERFACE
        DIN  => data_to_cpu,
        DIN_VLD  => s_data_in_valid,
        DIN_RDY  => s_slave_ready,
        DOUT => s_data_slave_out,
        DOUT_VLD => s_data_received
    );

    state_machine : process(n_cs, s_data_received, n_reset)
        variable v_command : std_logic_vector(7 downto 0);
    begin
        if (n_reset = '0') then
            s_state     <= COMMAND;
            s_address   <= (others => '0');
            s_data_from_cpu <= (others => '0');            
            s_rd        <= '0';
            s_wr        <= '0';
            v_command := CMD_UNKNOWN;
            --s_data_to_cpu_valid <= '0';
            s_data_in_valid     <= '0';
        elsif (n_cs = '1') then
            s_state <= COMMAND;
            v_command := CMD_UNKNOWN;
        elsif (s_data_received'event and s_data_received = '1') then
            case s_state is
                when COMMAND =>
                    v_command := s_data_slave_out;
                    case v_command is
                        when CMD_SET_ADDRESS =>
									 s_data_in_valid <= '0';
                            s_state <= ADDR;
									 s_wr <= '0';
									 s_rd	<= '0';
                        when CMD_WRITE_DATA =>									 
									 s_data_in_valid <= '0';
                            s_state <= WRITE_DATA;
                        when CMD_READ_DATA =>
                            s_rd <= '1';
                            s_data_in_valid <= '1';
                            s_state <= READ_DATA;
                        when CMD_BURST_WRITE =>
									 s_data_in_valid <= '0';
                            s_state <= ADDR;
                        when CMD_BURST_READ =>
									 s_data_in_valid <= '0';
                            s_state <= ADDR;
                        when others =>
                            s_state <= COMMAND;
                    end case;

                when ADDR =>
                    s_address <= s_data_slave_out;
                    case v_command is
                        when CMD_BURST_WRITE =>
                            s_state <= WRITE_DATA;
                        when CMD_BURST_READ =>
                            s_rd <= '1';
                            s_data_in_valid <= '1';
  									 s_state <= READ_DATA;
                        when others =>
                            s_state <= COMMAND;
                    end case;                    

                when WRITE_DATA =>
                    s_data_from_cpu <= s_data_slave_out;
                    s_wr <= '1';
                    
                    if (v_command = CMD_BURST_WRITE) then
                        s_wr <= '0';
                        s_address <= std_logic_vector(unsigned(s_address)  + 1);
                        s_state <= WRITE_DATA;
                    else
                        s_state <= COMMAND;
                    end if;

                when READ_DATA =>                     
                    if (v_command = CMD_BURST_READ) then
                        s_address <= std_logic_vector(unsigned(s_address)  + 1);
                        s_state <= READ_DATA;
                    else
								s_data_in_valid <= '0';
                        s_state <= COMMAND;
                    end if;

                when others =>
                    s_state <= COMMAND;
            end case;
        end if; -- clk edge detected
    end process;

    address         <= s_address when n_reset = '1' else (others => '0');
    data_from_cpu   <= s_data_from_cpu when n_reset = '1' else (others => '0');
    rd              <= s_rd when n_reset = '1' else '0';
    wr              <= s_wr when n_reset = '1' else '0';
    miso            <= s_miso when n_reset = '1' else '0';    
end behaviour;

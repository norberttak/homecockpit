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

entity decoder is
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
end decoder;

architecture decoder_beh of decoder is

constant ADDR_STATUS    : std_logic_vector := x"01";
constant ADDR_CONTROL   : std_logic_vector := x"02";
constant ADDR_IN0       : std_logic_vector := x"03";
constant ADDR_IN1       : std_logic_vector := x"04";
constant ADDR_IN2       : std_logic_vector := x"05";
constant ADDR_IN3       : std_logic_vector := x"06";
constant ADDR_IN4       : std_logic_vector := x"07";
constant ADDR_IN5       : std_logic_vector := x"08";
constant ADDR_IN6       : std_logic_vector := x"09";
constant ADDR_OUT0      : std_logic_vector := x"0A";
constant ADDR_OUT1      : std_logic_vector := x"0B";
constant ADDR_OUT2      : std_logic_vector := x"0C";
constant ADDR_OUT3      : std_logic_vector := x"0D";
constant ADDR_OUT4      : std_logic_vector := x"0E";
constant ADDR_LCD       : std_logic_vector := x"0F";
constant ADDR_FREE      : std_logic_vector := x"10"; -- next free address (not used)

begin

cs_status  <= '1' when address = ADDR_STATUS else '0';
cs_control <= '1' when address = ADDR_CONTROL else '0';
cs_in0     <= '1' when address = ADDR_IN0 else '0';
cs_in1     <= '1' when address = ADDR_IN1 else '0';
cs_in2     <= '1' when address = ADDR_IN2 else '0';
cs_in3     <= '1' when address = ADDR_IN3 else '0';
cs_in4     <= '1' when address = ADDR_IN4 else '0';
cs_in5     <= '1' when address = ADDR_IN5 else '0';
cs_in6     <= '1' when address = ADDR_IN6 else '0';
cs_out0    <= '1' when address = ADDR_OUT0 else '0'; 
cs_out1    <= '1' when address = ADDR_OUT1 else '0';
cs_out2    <= '1' when address = ADDR_OUT2 else '0';
cs_out3    <= '1' when address = ADDR_OUT3 else '0';
cs_out4    <= '1' when address = ADDR_OUT4 else '0';
cs_lcd     <= '1' when address = ADDR_LCD  else '0';

end;

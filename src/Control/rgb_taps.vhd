-------------------------------------------------------------------------------
--
-- Filename    : rgb_taps.vhd
-- Create Date : 01062019 [01-06-2019]
-- Author      : Zakinder
--
-- Description:
-- This file instantiation axi4 components.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants_package.all;
use work.vpf_records.all;
use work.ports_package.all;

entity rgb_taps is
generic (
    img_width     : integer := 4096;
    tpDataWidth   : integer := 8);
port (
    clk         : in std_logic;
    rst_l       : in std_logic;
    iRgb        : in channel;
    tpValid     : out std_logic;
    tp0         : out std_logic_vector(tpDataWidth - 1 downto 0);
    tp1         : out std_logic_vector(tpDataWidth - 1 downto 0);
    tp2         : out std_logic_vector(tpDataWidth - 1 downto 0));
end entity;
architecture arch of rgb_taps is
    signal tap0_data   : std_logic_vector(tpDataWidth - 1 downto 0) := (others => '0');
    signal tap1_data   : std_logic_vector(tpDataWidth - 1 downto 0) := (others => '0');
    signal d2RGB       : std_logic_vector(tpDataWidth - 1 downto 0) := (others => '0');
    signal rgbPixel    : std_logic_vector(tpDataWidth - 1 downto 0) := (others => '0');
begin
process (clk,rst_l) begin
    if (rst_l = lo) then
        tp0      <= (others => '0');
        tp1      <= (others => '0');
        tp2      <= (others => '0');
        tpValid  <= lo;
    elsif rising_edge(clk) then
        tp0      <= d2RGB;
        tp1      <= tap0_data;
        tp2      <= tap1_data;
        tpValid  <= iRgb.valid;
    end if;
end process;
TPDATAWIDTH1_ENABLED: if (tpDataWidth = 8) generate
begin
process (clk,rst_l) begin
    if (rst_l = lo) then
        rgbPixel <= (others => '0');
        d2RGB    <= (others => '0');
    elsif rising_edge(clk) then
        if (iRgb.valid = hi) then
            rgbPixel      <= iRgb.green;
        end if;
        d2RGB <= rgbPixel;
    end if;
end process;
end generate TPDATAWIDTH1_ENABLED;
TPDATAWIDTH3_ENABLED: if (tpDataWidth = 24) generate
begin
process (clk,rst_l) begin
    if (rst_l = lo) then
        rgbPixel <= (others => '0');
        d2RGB    <= (others => '0');
    elsif rising_edge(clk) then
        if (iRgb.valid = hi) then
            rgbPixel     <= iRgb.red & iRgb.green & iRgb.blue;
        end if;
        d2RGB <= rgbPixel;
    end if;
end process;
end generate TPDATAWIDTH3_ENABLED;
tap_line1_inst: tap_line 
generic map(
    img_width   => img_width,
    tpDataWidth => tpDataWidth)
port map(
    clk         => clk,
    rst_l       => rst_l,
    valid       => iRgb.valid,
    idata       => d2RGB,
    odata       => tap0_data);
tap_line2_inst: tap_line
generic map(
    img_width   => img_width,
    tpDataWidth => tpDataWidth)
port map(
    clk         => clk,
    rst_l       => rst_l,
    valid       => iRgb.valid,
    idata       => tap0_data,
    odata       => tap1_data);
end architecture;

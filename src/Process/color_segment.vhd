-------------------------------------------------------------------------------
--
-- Filename    : segment_colors.vhd
-- Create Date : 01162019 [01-16-2019]
-- Author      : Zakinder
--
-- Description:
-- This file instantiation
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants_package.all;
use work.vpf_records.all;
use work.ports_package.all;

entity segment_colors is
port (
    clk            : in  std_logic;
    reset          : in  std_logic;
    iLumTh         : in  integer;
    iRgb           : in channel;
    oRgb           : out channel);
end segment_colors;

architecture behavioral of segment_colors is

    signal rgbLgt         : channel;
    signal rgbDrk         : channel;
    signal rgbLum         : channel;
    signal thresh         : std_logic_vector(7 downto 0);

begin

thresh      <= std_logic_vector(to_unsigned(iLumTh,thresh'length));

rgbLgtInst: lum_values
generic map(
    F_LGT              => true,
    F_DRK              => false,
    F_LUM              => false,
    i_data_width       => i_data_width)
port map(
    clk                => clk,
    reset              => reset,
    iRgb               => iRgb,
    oRgb               => rgbLgt);
rgbDrkInst: lum_values
generic map(
    F_LGT              => false,
    F_DRK              => true,
    F_LUM              => false,
    i_data_width       => i_data_width)
port map(
    clk                => clk,
    reset              => reset,
    iRgb               => iRgb,
    oRgb               => rgbDrk);
rgbLumInst: lum_values
generic map(
    F_LGT              => false,
    F_DRK              => false,
    F_LUM              => true,
    i_data_width       => i_data_width)
port map(
    clk                => clk,
    reset              => reset,
    iRgb               => iRgb,
    oRgb               => rgbLum);
process (clk) begin
    if rising_edge(clk) then
        if (rgbLum.red > thresh) and (rgbLum.green > thresh) and (rgbLum.blue > thresh)  then
            oRgb       <= rgbLgt;
        else
            oRgb       <= rgbDrk;
        end if;
    end if;
end process;
end behavioral;
-------------------------------------------------------------------------------
--
-- Filename    : frame_mask.vhd
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

entity frame_mask is
generic (
    eBlack         : boolean := false);
port (
    clk            : in std_logic;
    reset          : in  std_logic;
    iEdgeValid     : in std_logic;
    i1Rgb          : in channel;
    i2Rgb          : in channel;
    oRgb           : out channel);
end frame_mask;
architecture behavioral of frame_mask is
    signal d1Rgb           : channel;
    signal rgbSyncValid    : std_logic_vector(15 downto 0)  := x"0000";
begin
process (clk) begin
    if rising_edge(clk) then
        rgbSyncValid(0)  <= iEdgeValid;
        rgbSyncValid(1)  <= rgbSyncValid(0);
        rgbSyncValid(2)  <= rgbSyncValid(1);
        rgbSyncValid(3)  <= rgbSyncValid(2);
        rgbSyncValid(4)  <= rgbSyncValid(3);
        rgbSyncValid(5)  <= rgbSyncValid(4);
        rgbSyncValid(6)  <= rgbSyncValid(5);
        rgbSyncValid(7)  <= rgbSyncValid(6);
        rgbSyncValid(8)  <= rgbSyncValid(7);
        rgbSyncValid(9)  <= rgbSyncValid(8);
        rgbSyncValid(10) <= rgbSyncValid(9);
        rgbSyncValid(11) <= rgbSyncValid(10);
        rgbSyncValid(12) <= rgbSyncValid(11);
        rgbSyncValid(13) <= rgbSyncValid(12);
        rgbSyncValid(14) <= rgbSyncValid(13);
        rgbSyncValid(15) <= rgbSyncValid(14);
    end if;
end process;

SyncFrames32Inst: sync_frames
generic map(
    pixelDelay => 6) --LATENCY 32
port map(
    clk        => clk,
    reset      => reset,
    iRgb       => i2Rgb,
    oRgb       => d1Rgb);
EBLACK_ENABLED: if (eBlack = true) generate
    process (clk) begin
        if rising_edge(clk) then
            if (rgbSyncValid(4) = hi) then
                oRgb.red   <= black;
                oRgb.green <= black;
                oRgb.blue  <= black;
            else
                oRgb.red   <= i1Rgb.red;
                oRgb.green <= i1Rgb.green;
                oRgb.blue  <= i1Rgb.blue;
            end if;
                oRgb.valid <= i1Rgb.valid;
        end if;
    end process;
end generate EBLACK_ENABLED;
EBLACK_DISABLED: if (eBlack = false) generate
    process (clk) begin
        if rising_edge(clk) then
            if (iEdgeValid = hi) then
                oRgb.red   <= black;
                oRgb.green <= black;
                oRgb.blue  <= black;
            else
                oRgb.red   <= d1Rgb.red;
                oRgb.green <= d1Rgb.green;
                oRgb.blue  <= d1Rgb.blue;
            end if;
                oRgb.valid <= d1Rgb.valid;
        end if;
    end process;
end generate EBLACK_DISABLED;
end behavioral;
-------------------------------------------------------------------------------
--
-- Filename    : video_select.vhd
-- Create Date : 02092019 [02-17-2019]
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

entity video_select is
generic (
    bmp_width         : integer := 1920;
    bmp_height        : integer := 1080;
    i_data_width      : integer := 8;
    b_data_width      : integer := 32;
    s_data_width      : integer := 16);
port (
    clk               : in std_logic;
    rst_l             : in std_logic;
    videoChannel      : in std_logic_vector(b_data_width-1 downto 0);
    dChannel          : in std_logic_vector(b_data_width-1 downto 0);
    cChannel          : in std_logic_vector(b_data_width-1 downto 0);
    cRgbOsharp        : in std_logic_vector(b_data_width-1 downto 0);
    iFrameData        : in fcolors;
    oEof              : out std_logic;
    oSof              : out std_logic;
    oCord             : out coord;
    oRgb              : out channel);
end video_select;
architecture Behavioral of video_select is
    signal vChannelSelect     : integer;
    signal eChannelSelect     : integer;
    signal ycbcr              : channel;
    signal channels           : channel;
    signal location           : cord := (x => 512, y => 512);
    signal rgbText            : channel;
begin
    vChannelSelect    <= to_integer(unsigned(videoChannel));
    eChannelSelect    <= to_integer(unsigned(dChannel));
    oEof              <= iFrameData.pEof;
    oSof              <= iFrameData.pSof;
---------------------------------------------------------------------------------
-- oRgb.valid must be 2nd condition else valid value
---------------------------------------------------------------------------------
videoOutP: process (clk) begin
    if rising_edge(clk) then
        if (vChannelSelect = FILTER_CGA) then
            channels           <= iFrameData.cgain;
        elsif(vChannelSelect = FILTER_SHP)then
            channels           <= iFrameData.sharp;
        elsif(vChannelSelect = FILTER_BLU)then
            channels           <= iFrameData.blur;
        elsif(vChannelSelect = FILTER_HSL)then
            channels           <= iFrameData.hsl;
        elsif(vChannelSelect = FILTER_HSV)then
            channels           <= iFrameData.hsv;
        elsif(vChannelSelect = FILTER_RGB)then
            channels           <= iFrameData.inrgb;
        elsif(vChannelSelect = FILTER_SOB)then
            channels           <= iFrameData.sobel;
        elsif(vChannelSelect = FILTER_EMB)then
            channels           <= iFrameData.embos;
        elsif(vChannelSelect = FILTER_MSK_SOB_LUM)then
            channels           <= iFrameData.maskSobelLum;
        elsif(vChannelSelect = FILTER_MSK_SOB_TRM)then
            channels           <= iFrameData.maskSobelTrm;
        elsif(vChannelSelect = FILTER_MSK_SOB_RGB)then
            channels           <= iFrameData.maskSobelRgb;
        elsif(vChannelSelect = FILTER_MSK_SOB_SHP)then
            channels           <= iFrameData.maskSobelShp;
        elsif(vChannelSelect = FILTER_MSK_SOB_SHP)then
            channels           <= iFrameData.maskSobelShp;
        elsif(vChannelSelect = FILTER_MSK_SOB_BLU)then
            channels           <= iFrameData.maskSobelBlu;
        elsif(vChannelSelect = FILTER_MSK_SOB_YCC)then
            channels           <= iFrameData.maskSobelYcc;
        elsif(vChannelSelect = FILTER_MSK_SOB_HSV)then
            channels           <= iFrameData.maskSobelHsv;
        elsif(vChannelSelect = FILTER_MSK_SOB_HSL)then
            channels           <= iFrameData.maskSobelHsl;
        elsif(vChannelSelect = FILTER_MSK_SOB_CGA)then
            channels           <= iFrameData.maskSobelCga;
        elsif(vChannelSelect = FILTER_COR_TRM)then
            channels           <= iFrameData.colorTrm;
        elsif(vChannelSelect = FILTER_COR_LMP)then
            channels           <= iFrameData.colorLmp;
        elsif(vChannelSelect = FILTER_TST_PAT)then
            channels           <= iFrameData.tPattern;
        elsif(vChannelSelect = FILTER_CGA_TO_CGA)then
            channels           <= iFrameData.cgainToCgain;
        elsif(vChannelSelect = FILTER_CGA_TO_HSL)then
            channels           <= iFrameData.cgainToHsl;
        elsif(vChannelSelect = FILTER_CGA_TO_HSV)then
            channels           <= iFrameData.cgainToHsv;
        elsif(vChannelSelect = FILTER_CGA_TO_YCC)then
            channels           <= iFrameData.cgainToYcbcr;
        elsif(vChannelSelect = FILTER_CGA_TO_SHP)then
            channels           <= iFrameData.cgainToShp;
        elsif(vChannelSelect = FILTER_CGA_TO_BLU)then
            channels           <= iFrameData.cgainToBlu;
        elsif(vChannelSelect = FILTER_SHP_TO_CGA)then
            channels           <= iFrameData.shpToCgain;
        elsif(vChannelSelect = FILTER_SHP_TO_HSL)then
            channels           <= iFrameData.shpToHsl;
        elsif(vChannelSelect = FILTER_SHP_TO_HSV)then
            channels           <= iFrameData.shpToHsv;
        elsif(vChannelSelect = FILTER_SHP_TO_YCC)then
            channels           <= iFrameData.shpToYcbcr;
        elsif(vChannelSelect = FILTER_SHP_TO_SHP)then
            channels           <= iFrameData.shpToShp;
        elsif(vChannelSelect = FILTER_SHP_TO_BLU)then
            channels           <= iFrameData.shpToBlu;
        elsif(vChannelSelect = FILTER_BLU_TO_BLU)then
            channels           <= iFrameData.bluToBlu;
        elsif(vChannelSelect = FILTER_BLU_TO_CGA)then
            channels           <= iFrameData.bluToCga;
        elsif(vChannelSelect = FILTER_BLU_TO_SHP)then
            channels           <= iFrameData.bluToShp;
        elsif(vChannelSelect = FILTER_BLU_TO_YCC)then
            channels           <= iFrameData.bluToYcc;
        elsif(vChannelSelect = FILTER_BLU_TO_HSV)then
            channels           <= iFrameData.bluToHsv;
        elsif(vChannelSelect = FILTER_BLU_TO_HSL)then
            channels           <= iFrameData.bluToHsl;
        elsif(vChannelSelect = FILTER_BLU_TO_CGA_TO_SHP)then
            channels           <= iFrameData.bluToCgaShp;
        elsif(vChannelSelect = FILTER_BLU_TO_CGA_TO_SHP_TO_YCC)then
            channels           <= iFrameData.bluToCgaShpYcc;
        elsif(vChannelSelect = FILTER_BLU_TO_CGA_TO_SHP_TO_HSV)then
            channels           <= iFrameData.bluToCgaShpHsv;
        elsif(vChannelSelect = FILTER_BLU_TO_SHP_TO_CGA)then
            channels           <= iFrameData.bluToShpCga;
        elsif(vChannelSelect = FILTER_BLU_TO_SHP_TO_CGA_TO_YCC)then
            channels           <= iFrameData.bluToShpCgaYcc;
        elsif(vChannelSelect = FILTER_BLU_TO_SHP_TO_CGA_TO_HSV)then
            channels           <= iFrameData.bluToShpCgaHsv;
        elsif(vChannelSelect = FILTER_RGB_CORRECT)then
            channels           <= iFrameData.rgbCorrect;
        elsif(vChannelSelect = FILTER_RGB_REMIX)then
            channels           <= iFrameData.rgbRemix;
        elsif(vChannelSelect = FILTER_RGB_DETECT)then
            channels           <= iFrameData.rgbDetect;
        elsif(vChannelSelect = FILTER_RGB_POI)then
            channels           <= iFrameData.rgbPoi;
        elsif(vChannelSelect = FILTER_YCC)then
            channels           <= iFrameData.ycbcr;
        else
            channels           <= iFrameData.rgbCorrect;
        end if;
    end if;
end process videoOutP;
ycbcrInst: rgb_ycbcr
generic map(
    i_data_width         => i_data_width,
    i_precision          => 12,
    i_full_range         => TRUE)
port map(
    clk                  => clk,
    rst_l                => rst_l,
    iRgb                 => channels,
    y                    => ycbcr.red,
    cb                   => ycbcr.green,
    cr                   => ycbcr.blue,
    oValid               => ycbcr.valid);
process (clk) begin
    if rising_edge(clk) then
        oCord <= iFrameData.cod;
    end if;
end process;
TextGenYcbcrInst: text_gen
generic map (
    img_width_bmp   => 1980,
    img_height_bmp  => 1080,
    b_data_width    => b_data_width)
port map(
    clk             => clk,
    rst_l           => rst_l,
    videoChannel    => videoChannel,
    txCord          => iFrameData.cod,
    location        => location,
    iRgb            => ycbcr,
    oRgb            => rgbText);
channelOutP: process (clk) begin
    if rising_edge(clk) then
        if (eChannelSelect = 0) then
            oRgb   <= ycbcr;
        elsif(eChannelSelect = 1)then
            oRgb   <= channels;
        elsif(eChannelSelect = 2)then
            oRgb   <= rgbText;
        elsif(eChannelSelect = 3)then
            oRgb.valid   <= ycbcr.valid;
            oRgb.red     <= ycbcr.red;
            oRgb.green   <= ycbcr.red;
            oRgb.blue    <= ycbcr.red;
        elsif(eChannelSelect = 4)then
            oRgb.valid   <= ycbcr.valid;
            oRgb.red     <= ycbcr.green;
            oRgb.green   <= ycbcr.green;
            oRgb.blue    <= ycbcr.green;
        elsif(eChannelSelect = 5)then
            oRgb.valid   <= ycbcr.valid;
            oRgb.red     <= ycbcr.blue;
            oRgb.green   <= ycbcr.blue;
            oRgb.blue    <= ycbcr.blue;
        elsif(eChannelSelect = 6)then
            oRgb.valid   <= ycbcr.valid;
            oRgb.red     <= ycbcr.red;
            oRgb.green   <= x"00";
            oRgb.blue    <= x"00";
        elsif(eChannelSelect = 7)then
            oRgb.valid   <= ycbcr.valid;
            oRgb.red     <= x"00";
            oRgb.green   <= ycbcr.green;
            oRgb.blue    <= x"00";
        elsif(eChannelSelect = 8)then
            oRgb.valid   <= ycbcr.valid;
            oRgb.red     <= x"00";
            oRgb.green   <= x"00";
            oRgb.blue    <= ycbcr.blue;
        elsif(eChannelSelect = 9)then
            oRgb.valid   <= ycbcr.valid;
            oRgb.red     <= ycbcr.red;
            oRgb.green   <= ycbcr.green;
            oRgb.blue    <= ycbcr.red;
        elsif(eChannelSelect = 10)then
            oRgb.valid   <= ycbcr.valid;
            oRgb.red     <= ycbcr.green;
            oRgb.green   <= ycbcr.green;
            oRgb.blue    <= ycbcr.blue;
        elsif(eChannelSelect = 11)then
            oRgb.valid   <= ycbcr.valid;
            oRgb.red     <= ycbcr.blue;
            oRgb.green   <= ycbcr.green;
            oRgb.blue    <= ycbcr.blue;
        else
            oRgb         <= ycbcr;
        end if;
    end if;
end process channelOutP;
end Behavioral;
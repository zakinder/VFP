-------------------------------------------------------------------------------
--
-- Filename    : video_stream.vhd
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

entity video_stream is
generic (
    revision_number      : std_logic_vector(31 downto 0) := x"00000000";
    i_data_width         : integer := 8;
    s_data_width         : integer := 16;
    b_data_width         : integer := 32;
    img_width            : integer := 256;
    adwrWidth            : integer := 16;
    addrWidth            : integer := 12;
    bmp_width            : integer := 1920;
    bmp_height           : integer := 1080;
    F_TES                : boolean := false;
    F_LUM                : boolean := false;
    F_TRM                : boolean := false;
    F_RGB                : boolean := false;
    F_SHP                : boolean := false;
    F_BLU                : boolean := false;
    F_EMB                : boolean := false;
    F_YCC                : boolean := false;
    F_SOB                : boolean := false;
    F_CGA                : boolean := false;
    F_HSV                : boolean := false;
    F_HSL                : boolean := false);
port (
    m_axis_mm2s_aclk     : in std_logic;
    m_axis_mm2s_aresetn  : in std_logic;
    iWrRegs              : in mRegs;
    oRdRegs              : out mRegs;
    iRgbSet              : in rRgb;
    oStreamData          : out vStreamData;
    oBusSelect           : out std_logic_vector(b_data_width-1 downto 0));
end video_stream;
architecture arch_imp of video_stream is
    signal seconds       : std_logic_vector(i_data_width-3 downto 0);
    signal minutes       : std_logic_vector(i_data_width-3 downto 0);
    signal hours         : std_logic_vector(i_data_width/2 downto 0);
    signal threshold     : std_logic_vector(s_data_width-1 downto 0);
    signal videoChannel  : std_logic_vector(b_data_width-1 downto 0):= (others => '0');
    signal edgeType      : std_logic_vector(b_data_width-1 downto 0):= (others => '0');
    signal cRgbOsharp    : std_logic_vector(b_data_width-1 downto 0):= (others => '0');
    signal dChannel      : std_logic_vector(b_data_width-1 downto 0):= (others => '0');
    signal cChannel      : std_logic_vector(b_data_width-1 downto 0):= (others => '0');
    signal fifoStatus    : std_logic_vector(b_data_width-1 downto 0);
    signal gridLockDatao : std_logic_vector(b_data_width-1 downto 0);
    signal rgbCoord      : region;
    signal pRegion       : poi;
    signal frameData     : fcolors;
    signal kls           : coefficient;
    signal als           : coefficient;
    signal oLumTh        : integer;
    signal oHsvPerCh     : integer;
    signal oYccPerCh     : integer;
begin
frameProcessInst: frame_process
generic map(
    i_data_width         => i_data_width,
    s_data_width         => s_data_width,
    b_data_width         => b_data_width,
    img_width            => img_width,
    adwrWidth            => adwrWidth,
    addrWidth            => addrWidth,
    bmp_width            => bmp_width,
    bmp_height           => bmp_height,
    F_TES                => F_TES,
    F_LUM                => F_LUM,
    F_TRM                => F_TRM,
    F_RGB                => F_RGB,
    F_SHP                => F_SHP,
    F_BLU                => F_BLU,
    F_EMB                => F_EMB,
    F_YCC                => F_YCC,
    F_SOB                => F_SOB,
    F_CGA                => F_CGA,
    F_HSV                => F_HSV,
    F_HSL                => F_HSL)
port map(
    clk                  => m_axis_mm2s_aclk,
    rst_l                => m_axis_mm2s_aresetn,
    iRgbSet              => iRgbSet,
    iVideoChannel        => videoChannel,
    iEdgeType            => edgeType,
    iPoiRegion           => pRegion,
    iThreshold           => threshold,
    iKls                 => kls,
    iAls                 => als,
    iLumTh               => oLumTh,
    iHsvPerCh            => oHsvPerCh,
    iYccPerCh            => oYccPerCh,
    iRgbCoord            => rgbCoord,
    oFifoStatus          => fifoStatus,
    oGridLockData        => gridLockDatao,
    oFrameData           => frameData);
digiClkInst: digital_clock
port map(
    clk1                 => m_axis_mm2s_aclk,
    seconds              => seconds,
    minutes              => minutes,
    hours                => hours);
mWrRdInst: mWrRd
generic map(
    revision_number      => revision_number,
    s_data_width         => s_data_width,
    b_data_width         => b_data_width)
port map(
    seconds              => seconds,
    minutes              => minutes,
    hours                => hours,
    rgbCoord             => rgbCoord,
    aBusSelect           => oBusSelect,
    threshold            => threshold,
    videoChannel         => videoChannel,
    dChannel             => dChannel,
    cChannel             => cChannel,
    oRgbOsharp           => cRgbOsharp,
    oEdgeType            => edgeType,
    pRegion              => pRegion,
    als                  => als,
    kls                  => kls,
    oLumTh               => oLumTh,
    oHsvPerCh            => oHsvPerCh,
    oYccPerCh            => oYccPerCh,
    fifoStatus           => fifoStatus,
    gridLockDatao        => gridLockDatao,
    wrRegsIn             => iWrRegs,
    rdRegsOut            => oRdRegs);
videoSelectInst: video_select
generic map (
    bmp_width            => bmp_width,
    bmp_height           => bmp_height,
    i_data_width         => i_data_width,
    b_data_width         => b_data_width,
    s_data_width         => s_data_width)
port map (
    clk                  => m_axis_mm2s_aclk,              
    rst_l                => m_axis_mm2s_aresetn,
    videoChannel         => videoChannel,
    cRgbOsharp           => cRgbOsharp,
    dChannel             => dChannel,
    cChannel             => cChannel,
    iFrameData           => frameData,
    oRgb                 => oStreamData.ycbcr,
    oEof                 => oStreamData.eof,
    oSof                 => oStreamData.sof,
    oCord                => oStreamData.cord);
end arch_imp;
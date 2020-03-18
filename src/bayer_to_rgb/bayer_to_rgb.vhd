-------------------------------------------------------------------------------
--
-- Filename    : bayer_to_rgb.vhd
-- Create Date : 05022019 [05-02-2019]
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

entity bayer_to_rgb is
generic (
    img_width           : integer := 8;
    dataWidth           : integer := 12);
port (
    clk                 : in std_logic;
    rst_l               : in std_logic;
    pixclk              : in std_logic;
    ifval               : in std_logic;
    ilval               : in std_logic;
    idata               : in std_logic_vector(dataWidth-1 downto 0);
    oRgbSet             : out rRgb);
end bayer_to_rgb;

architecture arch_imp of bayer_to_rgb is

    signal rawTp            : rTp;
    signal rawData          : rData;

begin

bayer_data_inst: bayer_data
generic map(
    img_width            => img_width)
port map(
    m_axis_aclk          => clk,
    m_axis_aresetn       => rst_l,
    pixclk               => pixclk,
    ifval                => ifval,
    ilval                => ilval,
    idata                => idata,
    oRawData             => rawData);

data_taps_inst: data_taps
generic map(
    img_width            => img_width,
    dataWidth            => dataWidth,
    addrWidth            => dataWidth)
port map(
    aclk                 => clk,
    iRawData             => rawData,
    oTpData              => rawTp);

raw_to_rgb_inst: raw_to_rgb
port map(
    clk                  => clk,
    rst_l                => rst_l,
    iTpData              => rawTp,
    oRgbSet              => oRgbSet);

end arch_imp;
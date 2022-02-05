--------------------------------------------------------------------------------
--
-- Filename      : recolor_rgb.vhd
-- Create Date   : 05022019 [05-02-2019]
-- Modified Date : 12302021 [12-30-2021]
-- Author        : Zakinder
--
-- Description:
-- This file instantiation
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants_package.all;
use work.vpf_records.all;
use work.ports_package.all;
entity recolor_rgb is
  generic (
    img_width          : integer := 8;
    i_k_config_number  : integer := 8);
  port (
    clk       : in std_logic;
    rst_l     : in std_logic;
    iRgb      : in channel;
    oRgb      : out channel);
end recolor_rgb;
architecture Behavioral of recolor_rgb is
    signal ccm0rgb_range   : channel;
    signal ccm1rgb_range   : channel;
    signal ccm2rgb_range   : channel;
    signal ccm3rgb_range   : channel;
    signal ccm4rgb_range   : channel;
    signal ccm5rgb_range   : channel;
    signal ccm6rgb_range   : channel;
    signal ccm7rgb_range   : channel;
    signal ccm8rgb_range   : channel;
begin

--------------------------------------------------------------------------
-- RGB_RANGE
--------------------------------------------------------------------------
rgb0range_inst: rgb_range
generic map (
    i_data_width       => i_data_width)
port map (                  
    clk                => clk,
    reset              => rst_l,
    iRgb               => iRgb,
    oRgb               => ccm0rgb_range);

--------------------------------------------------------------------------
-- DARK_CCM
--------------------------------------------------------------------------
dark_ccm_inst  : ccm
generic map(
    i_k_config_number   => 101)
port map(
    clk                 => clk,
    rst_l               => rst_l,
    iRgb                => ccm0rgb_range,
    oRgb                => ccm1rgb_range);
--------------------------------------------------------------------------
-- RGB_RANGE
--------------------------------------------------------------------------
rgb1range_inst: rgb_range
generic map (
    i_data_width       => i_data_width)
port map (                  
    clk                => clk,
    reset              => rst_l,
    iRgb               => ccm1rgb_range,
    oRgb               => ccm2rgb_range);
--------------------------------------------------------------------------
-- LIGHT_CCM
--------------------------------------------------------------------------
light_ccm_inst  : ccm
generic map(
    i_k_config_number   => 102)
port map(
    clk                 => clk,
    rst_l               => rst_l,
    iRgb                => ccm2rgb_range,
    oRgb                => ccm3rgb_range);
    
    
--------------------------------------------------------------------------
-- RGB_RANGE
--------------------------------------------------------------------------
rgb2range_inst: rgb_range
generic map (
    i_data_width       => i_data_width)
port map (                  
    clk                => clk,
    reset              => rst_l,
    iRgb               => ccm3rgb_range,
    oRgb               => ccm4rgb_range);
--------------------------------------------------------------------------
-- BALANCE_CCM
--------------------------------------------------------------------------
balance_ccm_inst  : ccm
generic map(
    i_k_config_number   => 103)
port map(
    clk                 => clk,
    rst_l               => rst_l,
    iRgb                => ccm4rgb_range,
    oRgb                => ccm5rgb_range);
--------------------------------------------------------------------------
-- RGB_RANGE
--------------------------------------------------------------------------
rgb3range_inst: rgb_range
generic map (
    i_data_width       => i_data_width)
port map (                  
    clk                => clk,
    reset              => rst_l,
    iRgb               => ccm5rgb_range,
    oRgb               => ccm6rgb_range);
    
recolor_space_2_inst: recolor_space
generic map(
    neighboring_pixel_threshold => 255,
    img_width         => img_width,
    i_data_width      => i_data_width)
port map(
    clk                => clk,
    reset              => rst_l,
    iRgb               => ccm6rgb_range,
    oRgb               => ccm7rgb_range);
    
sharp_valid_inst: d_valid
generic map (
    pixelDelay   => 1)
port map(
    clk      => clk,
    iRgb     => ccm6rgb_range,
    oRgb     => ccm8rgb_range);
    
    
ccm_syncr_inst  : sync_frames
generic map(
    pixelDelay          => 58)
port map(
    clk                 => clk,
    reset               => rst_l,
    iRgb                => ccm8rgb_range,
    oRgb                => oRgb);
end Behavioral;
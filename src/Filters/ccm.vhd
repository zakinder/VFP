-------------------------------------------------------------------------------
--
-- Filename    : ccm.vhd
-- Create Date : 05022019 [05-02-2019]
-- Author      : Zakinder
--
-- Description:
-- This file instantiation
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fixed_pkg.all;
use work.float_pkg.all;
use work.constants_package.all;
use work.vpf_records.all;
use work.ports_package.all;
entity ccm is
  generic (
    i_k_config_number  : integer := 8);
  port (
    clk       : in std_logic;
    rst_l     : in std_logic;
    iRgb      : in channel;
    oRgb      : out channel);
end ccm;
architecture Behavioral of ccm is
  signal ccRgb                : ccRgbRecord;
  signal rgbSyncValid         : std_logic_vector(11 downto 0) := x"000";
  signal rgb_ccm              : channel;
begin
rgbToSf_P: process (clk,rst_l)begin
    if rst_l = '0' then
        ccRgb.rgbToSf.red    <= (others => '0');
        ccRgb.rgbToSf.green  <= (others => '0');
        ccRgb.rgbToSf.blue   <= (others => '0');
    elsif rising_edge(clk) then
        ccRgb.rgbToSf.red    <= to_sfixed("00" & iRgb.red,ccRgb.rgbToSf.red);
        ccRgb.rgbToSf.green  <= to_sfixed("00" & iRgb.green,ccRgb.rgbToSf.green);
        ccRgb.rgbToSf.blue   <= to_sfixed("00" & iRgb.blue,ccRgb.rgbToSf.blue);
    end if;
end process rgbToSf_P;
syncValid_P: process (clk,rst_l)begin
    if rising_edge(clk) then
      rgbSyncValid(0)  <= iRgb.valid;
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
    end if;
end process syncValid_P;
ccSfConfig_P: process (clk,rst_l)begin
    if rst_l = '0' then
        ccRgb.ccSf.k1           <= to_sfixed(1.500,16,-3);
        ccRgb.ccSf.k2           <= to_sfixed(-0.125,16,-3); 
        ccRgb.ccSf.k3           <= to_sfixed(-0.125,16,-3); 
        ccRgb.ccSf.k4           <= to_sfixed(-0.125,16,-3); 
        ccRgb.ccSf.k5           <= to_sfixed(1.500,16,-3);  
        ccRgb.ccSf.k6           <= to_sfixed(-0.250,16,-3); 
        ccRgb.ccSf.k7           <= to_sfixed(-0.125,16,-3); 
        ccRgb.ccSf.k8           <= to_sfixed(-0.250,16,-3); 
        ccRgb.ccSf.k9           <= to_sfixed(1.500,16,-3);  
    elsif rising_edge(clk) then
    if(i_k_config_number = 0) then
    oRgb.valid <= rgbSyncValid(7);
        ccRgb.ccSf.k1           <= to_sfixed(1.900,16,-3);  
        ccRgb.ccSf.k2           <= to_sfixed(-0.250,16,-3); 
        ccRgb.ccSf.k3           <= to_sfixed(-0.125,16,-3); 
        ccRgb.ccSf.k4           <= to_sfixed(-0.125,16,-3); 
        ccRgb.ccSf.k5           <= to_sfixed(1.900,16,-3);  
        ccRgb.ccSf.k6           <= to_sfixed(-0.250,16,-3); 
        ccRgb.ccSf.k7           <= to_sfixed(-0.250,16,-3); 
        ccRgb.ccSf.k8           <= to_sfixed(-0.125,16,-3); 
        ccRgb.ccSf.k9           <= to_sfixed(1.900,16,-3);  
    elsif(i_k_config_number = 1)then
    oRgb.valid <= rgbSyncValid(7);
    

        --ccRgb.ccSf.k1           <= to_sfixed(3000.000,16,-3); 
        --ccRgb.ccSf.k2           <= to_sfixed(-1000.000,16,-3);
        --ccRgb.ccSf.k3           <= to_sfixed(-1000.000,16,-3); 
        --
        --ccRgb.ccSf.k4           <= to_sfixed(-1000.000,16,-3); 
        --ccRgb.ccSf.k5           <= to_sfixed(3000.000,16,-3);
        --ccRgb.ccSf.k6           <= to_sfixed(-1000.000,16,-3); 
        --
        --ccRgb.ccSf.k7           <= to_sfixed(-1000.000,16,-3); 
        --ccRgb.ccSf.k8           <= to_sfixed(-1000.000,16,-3);
        --ccRgb.ccSf.k9           <= to_sfixed(3000.000,16,-3);

        ccRgb.ccSf.k1           <= to_sfixed(1900.000,16,-3); 
        ccRgb.ccSf.k2           <= to_sfixed(-400.000,16,-3);
        ccRgb.ccSf.k3           <= to_sfixed(-500.000,16,-3); 
        ccRgb.ccSf.k4           <= to_sfixed(-500.000,16,-3); 
        ccRgb.ccSf.k5           <= to_sfixed(1900.000,16,-3);
        ccRgb.ccSf.k6           <= to_sfixed(-400.000,16,-3); 
        ccRgb.ccSf.k7           <= to_sfixed(-400.000,16,-3); 
        ccRgb.ccSf.k8           <= to_sfixed(-500.000,16,-3);
        ccRgb.ccSf.k9           <= to_sfixed(1900.000,16,-3);
        
    elsif(i_k_config_number = 2)then
    oRgb.valid <= rgbSyncValid(7);
        ----image base matrix
        --ccRgb.ccSf.k1           <= to_sfixed(3000.000,16,-3); 
        --ccRgb.ccSf.k2           <= to_sfixed(-1000.000,16,-3);
        --ccRgb.ccSf.k3           <= to_sfixed(-1000.000,16,-3); 
        ---- Green Get Extra Gain
        --ccRgb.ccSf.k4           <= to_sfixed(-700.000,16,-3); 
        --ccRgb.ccSf.k5           <= to_sfixed(3000.000,16,-3);
        --ccRgb.ccSf.k6           <= to_sfixed(-800.000,16,-3); 
        --
        --ccRgb.ccSf.k7           <= to_sfixed(-1000.000,16,-3); 
        --ccRgb.ccSf.k8           <= to_sfixed(-1000.000,16,-3);
        --ccRgb.ccSf.k9           <= to_sfixed(3000.000,16,-3);
        
        -- This color-space select unique per rgb color range.
       ccRgb.ccSf.k1           <= to_sfixed(300.000,16,-3); 
       ccRgb.ccSf.k2           <= to_sfixed(600.000,16,-3);
       ccRgb.ccSf.k3           <= to_sfixed(100.000,16,-3); 
       ccRgb.ccSf.k4           <= to_sfixed(-1687.000,16,-3); 
       ccRgb.ccSf.k5           <= to_sfixed(-3313.000,16,-3);
       ccRgb.ccSf.k6           <= to_sfixed(5000.000,16,-3); 
       ccRgb.ccSf.k7           <= to_sfixed(5000.000,16,-3); 
       ccRgb.ccSf.k8           <= to_sfixed(-4187.000,16,-3);
       ccRgb.ccSf.k9           <= to_sfixed(-0813.000,16,-3); 
    elsif(i_k_config_number = 3)then
    oRgb.valid <= rgbSyncValid(7);
        -- Contrast = 76,69,60 Exposer = 5
        --ccRgb.ccSf.k1           <= to_sfixed(0400.000,16,-3); 
        --ccRgb.ccSf.k2           <= to_sfixed(0350.000,16,-3);
        --ccRgb.ccSf.k3           <= to_sfixed(0100.000,16,-3); 
        --ccRgb.ccSf.k4           <= to_sfixed(0200.000,16,-3); 
        --ccRgb.ccSf.k5           <= to_sfixed(0750.000,16,-3);
        --ccRgb.ccSf.k6           <= to_sfixed(0100.000,16,-3); 
        --ccRgb.ccSf.k7           <= to_sfixed(0050.000,16,-3); 
        --ccRgb.ccSf.k8           <= to_sfixed(0100.000,16,-3);
        --ccRgb.ccSf.k9           <= to_sfixed(0950.000,16,-3);
      ----------------------------------------------------------
        -- This color-space select seperate red, green and blue channels.
        ccRgb.ccSf.k1           <= to_sfixed(-4851.000,16,-3); 
        ccRgb.ccSf.k2           <= to_sfixed(396.000,16,-3);
        ccRgb.ccSf.k3           <= to_sfixed(4455.000,16,-3); 
        ccRgb.ccSf.k4           <= to_sfixed(4455.000,16,-3); 
        ccRgb.ccSf.k5           <= to_sfixed(-4851.000,16,-3);
        ccRgb.ccSf.k6           <= to_sfixed(396.000,16,-3); 
        ccRgb.ccSf.k7           <= to_sfixed(396.000,16,-3); 
        ccRgb.ccSf.k8           <= to_sfixed(4455.000,16,-3);
        ccRgb.ccSf.k9           <= to_sfixed(-4851.000,16,-3); 
    elsif(i_k_config_number = 4)then
    oRgb.valid <= rgbSyncValid(7);
        -- This color-space convert rgb to near gray scale.
        -- Contrast = 76,65,60 Exposer = 5
        ccRgb.ccSf.k1           <= to_sfixed(0400.000,16,-3); 
        ccRgb.ccSf.k2           <= to_sfixed(0350.000,16,-3);
        ccRgb.ccSf.k3           <= to_sfixed(0100.000,16,-3); 
        ccRgb.ccSf.k4           <= to_sfixed(0200.000,16,-3); 
        ccRgb.ccSf.k5           <= to_sfixed(0700.000,16,-3);
        ccRgb.ccSf.k6           <= to_sfixed(0100.000,16,-3); 
        ccRgb.ccSf.k7           <= to_sfixed(0050.000,16,-3); 
        ccRgb.ccSf.k8           <= to_sfixed(0100.000,16,-3);
        ccRgb.ccSf.k9           <= to_sfixed(0900.000,16,-3);
    elsif(i_k_config_number = 5)then
    oRgb.valid <= rgbSyncValid(7);
    -- Balance Colors
        -- Contrast = 160,31,38 Exposer = 5
        ccRgb.ccSf.k1           <= to_sfixed(1500.000,16,-3); 
        ccRgb.ccSf.k2           <= to_sfixed(-250.000,16,-3);
        ccRgb.ccSf.k3           <= to_sfixed(-250.000,16,-3);
        
        ccRgb.ccSf.k4           <= to_sfixed(-500.000,16,-3); 
        ccRgb.ccSf.k5           <= to_sfixed(2500.000,16,-3);
        ccRgb.ccSf.k6           <= to_sfixed(-500.000,16,-3); 
        
        ccRgb.ccSf.k7           <= to_sfixed(-500.000,16,-3); 
        ccRgb.ccSf.k8           <= to_sfixed(-500.000,16,-3);
        ccRgb.ccSf.k9           <= to_sfixed(2500.000,16,-3);
      ----------------------------------------------------------
        --Contrast = 160,31,38 Exposer = 5
        --ccRgb.ccSf.k1           <= to_sfixed(1500.000,16,-3); 
        --ccRgb.ccSf.k2           <= to_sfixed(-250.000,16,-3);
        --ccRgb.ccSf.k3           <= to_sfixed(-250.000,16,-3); 
        --ccRgb.ccSf.k4           <= to_sfixed(-250.000,16,-3); 
        --ccRgb.ccSf.k5           <= to_sfixed(1500.000,16,-3);
        --ccRgb.ccSf.k6           <= to_sfixed(-250.000,16,-3); 
        --ccRgb.ccSf.k7           <= to_sfixed(-250.000,16,-3); 
        --ccRgb.ccSf.k8           <= to_sfixed(-250.000,16,-3);
        --ccRgb.ccSf.k9           <= to_sfixed(1500.000,16,-3);
    elsif(i_k_config_number = 6)then
    oRgb.valid <= rgbSyncValid(7);
        -- Contrast = 202,0,0 Exposer = 4
        ccRgb.ccSf.k1           <= to_sfixed(3000.000,16,-3); 
        ccRgb.ccSf.k2           <= to_sfixed(-1000.000,16,-3);
        ccRgb.ccSf.k3           <= to_sfixed(-1000.000,16,-3);

        ccRgb.ccSf.k4           <= to_sfixed(-1500.000,16,-3); 
        ccRgb.ccSf.k5           <= to_sfixed(3000.000,16,-3);
        ccRgb.ccSf.k6           <= to_sfixed(-0500.000,16,-3);

        ccRgb.ccSf.k7           <= to_sfixed(-0500.000,16,-3); 
        ccRgb.ccSf.k8           <= to_sfixed(-1500.000,16,-3);
        ccRgb.ccSf.k9           <= to_sfixed(3000.000,16,-3);
      ----------------------------------------------------------
        --Contrast = 202,0,0 Exposer = 4
        --ccRgb.ccSf.k1           <= to_sfixed(2500.000,16,-3); 
        --ccRgb.ccSf.k2           <= to_sfixed(-1000.000,16,-3);
        --ccRgb.ccSf.k3           <= to_sfixed(-1000.000,16,-3); 
        --ccRgb.ccSf.k4           <= to_sfixed(-1000.000,16,-3); 
        --ccRgb.ccSf.k5           <= to_sfixed(2500.000,16,-3);
        --ccRgb.ccSf.k6           <= to_sfixed(-1000.000,16,-3); 
        --ccRgb.ccSf.k7           <= to_sfixed(-1000.000,16,-3); 
        --ccRgb.ccSf.k8           <= to_sfixed(-1000.000,16,-3);
        --ccRgb.ccSf.k9           <= to_sfixed(2500.000,16,-3);
    elsif(i_k_config_number = 7)then
    oRgb.valid <= rgbSyncValid(7);
      -- Contrast = 230,0,0 Exposer = 6
        ccRgb.ccSf.k1           <= to_sfixed(2700.000,16,-3); 
        ccRgb.ccSf.k2           <= to_sfixed(-1000.000,16,-3);
        ccRgb.ccSf.k3           <= to_sfixed(-1000.000,16,-3); 
        
        ccRgb.ccSf.k4           <= to_sfixed(-1200.000,16,-3); 
        ccRgb.ccSf.k5           <= to_sfixed(2700.000,16,-3);
        ccRgb.ccSf.k6           <= to_sfixed(-1000.000,16,-3);
        
        ccRgb.ccSf.k7           <= to_sfixed(-1000.000,16,-3); 
        ccRgb.ccSf.k8           <= to_sfixed(-1200.000,16,-3);
        ccRgb.ccSf.k9           <= to_sfixed(2700.000,16,-3);
      ----------------------------------------------------------
      --Contrast = 230,0,0 Exposer = 6
      --ccRgb.ccSf.k1           <= to_sfixed(2700.000,16,-3); 
      --ccRgb.ccSf.k2           <= to_sfixed(-1000.000,16,-3);
      --ccRgb.ccSf.k3           <= to_sfixed(-1000.000,16,-3); 
      --ccRgb.ccSf.k4           <= to_sfixed(-1000.000,16,-3); 
      --ccRgb.ccSf.k5           <= to_sfixed(2700.000,16,-3);
      --ccRgb.ccSf.k6           <= to_sfixed(-1000.000,16,-3); 
      --ccRgb.ccSf.k7           <= to_sfixed(-1000.000,16,-3); 
      --ccRgb.ccSf.k8           <= to_sfixed(-1000.000,16,-3);
      --ccRgb.ccSf.k9           <= to_sfixed(2700.000,16,-3);
    elsif(i_k_config_number = 8)then
    oRgb.valid <= rgbSyncValid(7);
      -- Contrast = 240,0,0 Exposer = 6
        ccRgb.ccSf.k1           <= to_sfixed(3000.000,16,-3); 
        ccRgb.ccSf.k2           <= to_sfixed(-750.000,16,-3);
        ccRgb.ccSf.k3           <= to_sfixed(-750.000,16,-3); 

        ccRgb.ccSf.k4           <= to_sfixed(-750.000,16,-3);
        ccRgb.ccSf.k5           <= to_sfixed(3000.000,16,-3);
        ccRgb.ccSf.k6           <= to_sfixed(-750.000,16,-3);

        ccRgb.ccSf.k7           <= to_sfixed(-750.000,16,-3); 
        ccRgb.ccSf.k8           <= to_sfixed(-750.000,16,-3);
        ccRgb.ccSf.k9           <= to_sfixed(3000.000,16,-3);
      ----------------------------------------------------------
      --Contrast = 240,0,0 Exposer = 6
      --ccRgb.ccSf.k1           <= to_sfixed(2800.000,16,-3); 
      --ccRgb.ccSf.k2           <= to_sfixed(-1000.000,16,-3);
      --ccRgb.ccSf.k3           <= to_sfixed(-1000.000,16,-3); 
      --ccRgb.ccSf.k4           <= to_sfixed(-1000.000,16,-3); 
      --ccRgb.ccSf.k5           <= to_sfixed(2800.000,16,-3);
      --ccRgb.ccSf.k6           <= to_sfixed(-1000.000,16,-3); 
      --ccRgb.ccSf.k7           <= to_sfixed(-1000.000,16,-3); 
      --ccRgb.ccSf.k8           <= to_sfixed(-1000.000,16,-3);
      --ccRgb.ccSf.k9           <= to_sfixed(2800.000,16,-3);
      ----------------------------------------------------------
      --assign red channel green values
      --ccRgb.ccSf.k1           <= to_sfixed(0000.000,16,-3); 
      --ccRgb.ccSf.k2           <= to_sfixed(1000.000,16,-3);
      --ccRgb.ccSf.k3           <= to_sfixed(-1000.000,16,-3); 
      --assign green channel blue values
      --ccRgb.ccSf.k4           <= to_sfixed(-1000.000,16,-3); 
      --ccRgb.ccSf.k5           <= to_sfixed(0000.000,16,-3);
      --ccRgb.ccSf.k6           <= to_sfixed(1000.000,16,-3); 
      --assign blue channel green values
      --ccRgb.ccSf.k7           <= to_sfixed(1000.000,16,-3); 
      --ccRgb.ccSf.k8           <= to_sfixed(-1000.000,16,-3);
      --ccRgb.ccSf.k9           <= to_sfixed(0000.000,16,-3);
      ----------------------------------------------------------
    elsif(i_k_config_number = 9) then
    oRgb.valid <= rgbSyncValid(7);
        ccRgb.ccSf.k1           <= to_sfixed(1.500,16,-3);  
        ccRgb.ccSf.k2           <= to_sfixed(-0.250,16,-3); 
        ccRgb.ccSf.k3           <= to_sfixed(-0.125,16,-3); 
        ccRgb.ccSf.k4           <= to_sfixed(-0.125,16,-3); 
        ccRgb.ccSf.k5           <= to_sfixed(1.500,16,-3);  
        ccRgb.ccSf.k6           <= to_sfixed(-0.250,16,-3); 
        ccRgb.ccSf.k7           <= to_sfixed(-0.250,16,-3); 
        ccRgb.ccSf.k8           <= to_sfixed(-0.125,16,-3); 
        ccRgb.ccSf.k9           <= to_sfixed(1.500,16,-3);  
    elsif(i_k_config_number = 10)then
    oRgb.valid <= rgbSyncValid(7);
        --F_XYZ_FRAME
        ccRgb.ccSf.k1           <= to_sfixed(0412.000,16,-3); 
        ccRgb.ccSf.k2           <= to_sfixed(0357.000,16,-3);
        ccRgb.ccSf.k3           <= to_sfixed(0180.000,16,-3); 
        ccRgb.ccSf.k4           <= to_sfixed(0212.000,16,-3); 
        ccRgb.ccSf.k5           <= to_sfixed(0715.000,16,-3);
        ccRgb.ccSf.k6           <= to_sfixed(0072.000,16,-3); 
        ccRgb.ccSf.k7           <= to_sfixed(0019.000,16,-3); 
        ccRgb.ccSf.k8           <= to_sfixed(0119.000,16,-3);
        ccRgb.ccSf.k9           <= to_sfixed(0950.000,16,-3);
    elsif(i_k_config_number = 11)then
    oRgb.valid <= rgbSyncValid(7);
        --F_LMS_FRAME
        ccRgb.ccSf.k1           <= to_sfixed(0400.000,16,-3); 
        ccRgb.ccSf.k2           <= to_sfixed(0707.000,16,-3);
        ccRgb.ccSf.k3           <= to_sfixed(-0080.000,16,-3); 
        ccRgb.ccSf.k4           <= to_sfixed(-0228.000,16,-3); 
        ccRgb.ccSf.k5           <= to_sfixed(1150.000,16,-3);
        ccRgb.ccSf.k6           <= to_sfixed(0061.000,16,-3); 
        ccRgb.ccSf.k7           <= to_sfixed(0000.000,16,-3); 
        ccRgb.ccSf.k8           <= to_sfixed(0000.000,16,-3);
        ccRgb.ccSf.k9           <= to_sfixed(0918.000,16,-3); 
    elsif(i_k_config_number = 12)then
    oRgb.valid <= rgbSyncValid(7);
        --YPBPR_FRAME
        ccRgb.ccSf.k1           <= to_sfixed(0400.000,16,-3); 
        ccRgb.ccSf.k2           <= to_sfixed(0400.000,16,-3);
        ccRgb.ccSf.k3           <= to_sfixed(0200.000,16,-3); 
        ccRgb.ccSf.k4           <= to_sfixed(44550.000,16,-3); 
        ccRgb.ccSf.k5           <= to_sfixed(-48510.000,16,-3);
        ccRgb.ccSf.k6           <= to_sfixed(3960.000,16,-3); 
        ccRgb.ccSf.k7           <= to_sfixed(8056.000,16,-3); 
        ccRgb.ccSf.k8           <= to_sfixed(3570.000,16,-3);
        ccRgb.ccSf.k9           <= to_sfixed(-11162.000,16,-3); 
    elsif(i_k_config_number = 13)then
    oRgb.valid <= rgbSyncValid(7);
        --F_YUV_FRAME
        ccRgb.ccSf.k1           <= to_sfixed(0299.000,16,-3); 
        ccRgb.ccSf.k2           <= to_sfixed(0587.000,16,-3);
        ccRgb.ccSf.k3           <= to_sfixed(0114.000,16,-3); 
        ccRgb.ccSf.k4           <= to_sfixed(-0147.000,16,-3); 
        ccRgb.ccSf.k5           <= to_sfixed(-0289.000,16,-3);
        ccRgb.ccSf.k6           <= to_sfixed(0436.000,16,-3); 
        ccRgb.ccSf.k7           <= to_sfixed(0615.000,16,-3); 
        ccRgb.ccSf.k8           <= to_sfixed(-0515.000,16,-3);
        ccRgb.ccSf.k9           <= to_sfixed(-00100.000,16,-3);
    elsif(i_k_config_number = 101)then
        --dark_ccm
        --|--------|--------|--------|
        --| +1.000 | -0.500 | -0.500 |
        --|--------|--------|--------|
        --| -0.500 | +1.000 | -0.500 |
        --|--------|--------|--------|
        --| -0.500 | -0.500 | +1.000 |
        --|--------|--------|--------|
        ccRgb.ccSf.k1           <= to_sfixed(400.000,16,-3); 
        ccRgb.ccSf.k2           <= to_sfixed(-100.000,16,-3);
        ccRgb.ccSf.k3           <= to_sfixed(-100.000,16,-3); 
        ccRgb.ccSf.k4           <= to_sfixed(-100.000,16,-3); 
        ccRgb.ccSf.k5           <= to_sfixed(400.000,16,-3);
        ccRgb.ccSf.k6           <= to_sfixed(-100.000,16,-3); 
        ccRgb.ccSf.k7           <= to_sfixed(-100.000,16,-3); 
        ccRgb.ccSf.k8           <= to_sfixed(-100.000,16,-3);
        ccRgb.ccSf.k9           <= to_sfixed(400.000,16,-3);
    oRgb.valid <= rgbSyncValid(7);
    elsif(i_k_config_number = 102)then
        --light_ccm
        --|--------|--------|--------|
        --| +5.000 | -3.000 | -1.000 |
        --|--------|--------|--------|
        --| -1.000 | +5.000 | -3.000 |
        --|--------|--------|--------|
        --| -3.000 | -1.000 | +5.000 | 
        --|--------|--------|--------|
        ccRgb.ccSf.k1           <= to_sfixed(3500.000,16,-3); 
        ccRgb.ccSf.k2           <= to_sfixed(-500.000,16,-3);
        ccRgb.ccSf.k3           <= to_sfixed(-500.000,16,-3);
        
        ccRgb.ccSf.k4           <= to_sfixed(-500.000,16,-3); 
        ccRgb.ccSf.k5           <= to_sfixed(3500.000,16,-3);
        ccRgb.ccSf.k6           <= to_sfixed(-500.000,16,-3); 
        
        ccRgb.ccSf.k7           <= to_sfixed(-500.000,16,-3); 
        ccRgb.ccSf.k8           <= to_sfixed(-500.000,16,-3);
        ccRgb.ccSf.k9           <= to_sfixed(3500.000,16,-3);
    oRgb.valid <= rgbSyncValid(7);
    elsif(i_k_config_number = 103)then
        --balance_ccm
        --|--------|--------|--------|
        --| +0.500 | +0.375 | +0.125 |
        --|--------|--------|--------|
        --| +0.250 | +0.500 | +0.125 |
        --|--------|--------|--------|
        --| +0.125 | +0.125 | +0.500 |
        --|--------|--------|--------|
        --ccRgb.ccSf.k1           <= to_sfixed(800.000,16,-3); 
        --ccRgb.ccSf.k2           <= to_sfixed(400.000,16,-3);
        --ccRgb.ccSf.k3           <= to_sfixed(400.000,16,-3); 
        --
        --ccRgb.ccSf.k4           <= to_sfixed(400.000,16,-3); 
        --ccRgb.ccSf.k5           <= to_sfixed(800.000,16,-3);
        --ccRgb.ccSf.k6           <= to_sfixed(400.000,16,-3); 
        --
        --ccRgb.ccSf.k7           <= to_sfixed(400.000,16,-3); 
        --ccRgb.ccSf.k8           <= to_sfixed(400.000,16,-3);
        --ccRgb.ccSf.k9           <= to_sfixed(800.000,16,-3);
        
        ccRgb.ccSf.k1           <= to_sfixed(800.000,16,-3); 
        ccRgb.ccSf.k2           <= to_sfixed(350.000,16,-3);
        ccRgb.ccSf.k3           <= to_sfixed(400.000,16,-3); 
        ccRgb.ccSf.k4           <= to_sfixed(400.000,16,-3); 
        ccRgb.ccSf.k5           <= to_sfixed(800.000,16,-3);
        ccRgb.ccSf.k6           <= to_sfixed(350.000,16,-3); 
        ccRgb.ccSf.k7           <= to_sfixed(350.000,16,-3); 
        ccRgb.ccSf.k8           <= to_sfixed(400.000,16,-3);
        ccRgb.ccSf.k9           <= to_sfixed(800.000,16,-3);
        
    oRgb.valid <= rgbSyncValid(7);
    end if;
    end if;
end process ccSfConfig_P;
ccProdSf_P: process (clk,rst_l)begin
    if rising_edge(clk) then
        ccRgb.ccProdSf.k1       <= ccRgb.ccSf.k1  * ccRgb.rgbToSf.red;
        ccRgb.ccProdSf.k2       <= ccRgb.ccSf.k2  * ccRgb.rgbToSf.green;
        ccRgb.ccProdSf.k3       <= ccRgb.ccSf.k3  * ccRgb.rgbToSf.blue;
        ccRgb.ccProdSf.k4       <= ccRgb.ccSf.k4  * ccRgb.rgbToSf.red;
        ccRgb.ccProdSf.k5       <= ccRgb.ccSf.k5  * ccRgb.rgbToSf.green;
        ccRgb.ccProdSf.k6       <= ccRgb.ccSf.k6  * ccRgb.rgbToSf.blue;
        ccRgb.ccProdSf.k7       <= ccRgb.ccSf.k7  * ccRgb.rgbToSf.red;
        ccRgb.ccProdSf.k8       <= ccRgb.ccSf.k8  * ccRgb.rgbToSf.green;
        ccRgb.ccProdSf.k9       <= ccRgb.ccSf.k9  * ccRgb.rgbToSf.blue;
    end if;
end process ccProdSf_P;
ccProdToSn_P: process (clk,rst_l)begin
    if rising_edge(clk) then
        ccRgb.ccProdToSn.k1     <= to_signed(ccRgb.ccProdSf.k1(21 downto 0), 22);
        ccRgb.ccProdToSn.k2     <= to_signed(ccRgb.ccProdSf.k2(21 downto 0), 22);
        ccRgb.ccProdToSn.k3     <= to_signed(ccRgb.ccProdSf.k3(21 downto 0), 22);
        ccRgb.ccProdToSn.k4     <= to_signed(ccRgb.ccProdSf.k4(21 downto 0), 22);
        ccRgb.ccProdToSn.k5     <= to_signed(ccRgb.ccProdSf.k5(21 downto 0), 22);
        ccRgb.ccProdToSn.k6     <= to_signed(ccRgb.ccProdSf.k6(21 downto 0), 22);
        ccRgb.ccProdToSn.k7     <= to_signed(ccRgb.ccProdSf.k7(21 downto 0), 22);
        ccRgb.ccProdToSn.k8     <= to_signed(ccRgb.ccProdSf.k8(21 downto 0), 22);
        ccRgb.ccProdToSn.k9     <= to_signed(ccRgb.ccProdSf.k9(21 downto 0), 22);
    end if;
end process ccProdToSn_P;
ccRgbSum_P: process (clk,rst_l)begin
    if rst_l = '0' then
      ccRgb.ccProdTrSn.k1     <= (others => '0');
      ccRgb.ccProdTrSn.k2     <= (others => '0');
      ccRgb.ccProdTrSn.k3     <= (others => '0');
      ccRgb.ccProdTrSn.k4     <= (others => '0');
      ccRgb.ccProdTrSn.k5     <= (others => '0');
      ccRgb.ccProdTrSn.k6     <= (others => '0');
      ccRgb.ccProdTrSn.k7     <= (others => '0');
      ccRgb.ccProdTrSn.k8     <= (others => '0');
      ccRgb.ccProdTrSn.k9     <= (others => '0');
      ccRgb.rgbSnSum.red      <= (others => '0');
      ccRgb.rgbSnSum.green    <= (others => '0');
      ccRgb.rgbSnSum.blue     <= (others => '0');
      ccRgb.rgbSnSumTr.red    <= (others => '0');
      ccRgb.rgbSnSumTr.green  <= (others => '0');
      ccRgb.rgbSnSumTr.blue   <= (others => '0');
    elsif rising_edge(clk) then
      ccRgb.ccProdTrSn.k1        <= ccRgb.ccProdToSn.k1(21 downto 7);
      ccRgb.ccProdTrSn.k2        <= ccRgb.ccProdToSn.k2(21 downto 7);
      ccRgb.ccProdTrSn.k3        <= ccRgb.ccProdToSn.k3(21 downto 7);
      ccRgb.ccProdTrSn.k4        <= ccRgb.ccProdToSn.k4(21 downto 7);
      ccRgb.ccProdTrSn.k5        <= ccRgb.ccProdToSn.k5(21 downto 7);
      ccRgb.ccProdTrSn.k6        <= ccRgb.ccProdToSn.k6(21 downto 7);
      ccRgb.ccProdTrSn.k7        <= ccRgb.ccProdToSn.k7(21 downto 7);
      ccRgb.ccProdTrSn.k8        <= ccRgb.ccProdToSn.k8(21 downto 7);
      ccRgb.ccProdTrSn.k9        <= ccRgb.ccProdToSn.k9(21 downto 7);
      ccRgb.rgbSnSum.red      <= resize(ccRgb.ccProdTrSn.k1, ADD_RESULT_WIDTH) +
                                 resize(ccRgb.ccProdTrSn.k2, ADD_RESULT_WIDTH) +
                                 resize(ccRgb.ccProdTrSn.k3, ADD_RESULT_WIDTH) + ROUND;
      ccRgb.rgbSnSum.green    <= resize(ccRgb.ccProdTrSn.k4, ADD_RESULT_WIDTH) +
                                 resize(ccRgb.ccProdTrSn.k5, ADD_RESULT_WIDTH) +
                                 resize(ccRgb.ccProdTrSn.k6, ADD_RESULT_WIDTH) + ROUND;
      ccRgb.rgbSnSum.blue     <= resize(ccRgb.ccProdTrSn.k7, ADD_RESULT_WIDTH) +
                                 resize(ccRgb.ccProdTrSn.k8, ADD_RESULT_WIDTH) +
                                 resize(ccRgb.ccProdTrSn.k9, ADD_RESULT_WIDTH) + ROUND;
      ccRgb.rgbSnSumTr.red    <= ccRgb.rgbSnSum.red(ccRgb.rgbSnSum.red'left downto FRAC_BITS_TO_KEEP);
      ccRgb.rgbSnSumTr.green  <= ccRgb.rgbSnSum.green(ccRgb.rgbSnSum.green'left downto FRAC_BITS_TO_KEEP);
      ccRgb.rgbSnSumTr.blue   <= ccRgb.rgbSnSum.blue(ccRgb.rgbSnSum.blue'left downto FRAC_BITS_TO_KEEP);
    end if;
end process ccRgbSum_P;
rgbSnSumTr_P : process (clk, rst_l)
  begin
    if rst_l = '0' then
      rgb_ccm.red    <= (others => '0');
      rgb_ccm.green  <= (others => '0');
      rgb_ccm.blue   <= (others => '0');
    elsif clk'event and clk = '1' then
      if ccRgb.rgbSnSumTr.red(ROUND_RESULT_WIDTH-1) = '1' then
        rgb_ccm.red <= (others => '0');
      elsif unsigned(ccRgb.rgbSnSumTr.red(ROUND_RESULT_WIDTH-2 downto i_data_width)) /= 0 then
        rgb_ccm.red <= (others => '1');
      else
        rgb_ccm.red <= std_logic_vector(ccRgb.rgbSnSumTr.red(i_data_width-1 downto 0));
      end if;
      if ccRgb.rgbSnSumTr.green(ROUND_RESULT_WIDTH-1) = '1' then
        rgb_ccm.green <= (others => '0');
      elsif unsigned(ccRgb.rgbSnSumTr.green(ROUND_RESULT_WIDTH-2 downto i_data_width)) /= 0 then
        rgb_ccm.green <= (others => '1');
      else
        rgb_ccm.green <= std_logic_vector(ccRgb.rgbSnSumTr.green(i_data_width-1 downto 0));
      end if;
      if ccRgb.rgbSnSumTr.blue(ROUND_RESULT_WIDTH-1) = '1' then
        rgb_ccm.blue <= (others => '0');
      elsif unsigned(ccRgb.rgbSnSumTr.blue(ROUND_RESULT_WIDTH-2 downto i_data_width)) /= 0 then
        rgb_ccm.blue <= (others => '1');
      else
        rgb_ccm.blue <= std_logic_vector(ccRgb.rgbSnSumTr.blue(i_data_width-1 downto 0));
      end if;
    end if;
end process rgbSnSumTr_P;
process (clk,rst_l)begin
    if rising_edge(clk) then
        oRgb.red   <= rgb_ccm.red;
        oRgb.green <= rgb_ccm.green;
        oRgb.blue  <= rgb_ccm.blue;
    end if;
end process;
end Behavioral;
-------------------------------------------------------------------------------
--
-- Filename    : frame_remake.vhd
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
use work.tbPackage.all;
use work.dutPortsPackage.all;
entity frame_remake is
generic (
    eBlack         : boolean := false);
port (
    clk            : in std_logic;
    reset          : in  std_logic;
    iEdgeValid     : in std_logic;
    iRgb           : in frameColors;
    oRgb           : out channel);
end frame_remake;
architecture behavioral of frame_remake is
    signal ycbcr            : channel;
    signal synYcbcr         : channel;
    signal iRgb_hsl1_range  : channel;
    signal iRgb_hsll1range  : channel;
    signal d1Rgb            : channel;
    signal d2Rgb            : channel;
    signal d3Rgb            : channel;
    signal d4Rgb            : channel;
    signal d5Rgb            : channel;
    signal d6Rgb            : channel;
    signal d7Rgb            : channel;
    signal d8Rgb            : channel;
    signal d21Rgb           : channel;
    signal d22Rgb           : channel;
    signal d23Rgb           : channel;
    signal d24Rgb           : channel;
    signal d25Rgb           : channel;
    signal d26Rgb           : channel;
    signal d27Rgb           : channel;
    signal d28Rgb           : channel;
begin
--sobel             : channel;
--embos             : channel;
--blur              : channel;
--sharp             : channel;
--cgain             : channel;
--ycbcr             : channel;
--hsv               : channel;
--hsv               : channel;
--inrgb             : channel;
--d1t               : channel;
--b1t               : channel;
--maskSobelLum      : channel;
--maskSobelTrm      : channel;
--maskSobelRgb      : channel;
--maskSobelShp      : channel;
--maskSobelBlu      : channel;
--maskSobelYcc      : channel;
--maskSobelHsv      : channel;
--maskSobelhsv      : channel;
--maskSobelCga      : channel;
--colorTrm          : channel;
--colorLmp          : channel;
--tPattern          : channel;
--cgainToCgain      : channel;
--cgainTohsv        : channel;
--cgainToHsv        : channel;
--cgainToYcbcr      : channel;
--cgainToShp        : channel;
--cgainToBlu        : channel;
--shpToCgain        : channel;
--shpTohsv          : channel;
--shpToHsv          : channel;
--shpToYcbcr        : channel;
--shpToShp          : channel;
--shpToBlu          : channel;
--bluToBlu          : channel;
--bluToCga          : channel;
--bluToShp          : channel;
--bluToYcc          : channel;
--bluToHsv          : channel;
--bluTohsv          : channel;
--bluToCgaShp       : channel;
--bluToCgaShpYcc    : channel;
--bluToCgaShpHsv    : channel;
--bluToShpCga       : channel;
--bluToShpCgaYcc    : channel;
--bluToShpCgaHsv    : channel;
--cgaBright         : channel;
--cgaDark           : channel;
--cgaBalance        : channel;
--cgaGainRed        : channel;
--cgaGainGre        : channel;
--cgaGainBlu        : channel;
--synBlur           : channel;
--synSharp          : channel;
--iRgb_hsl1_range          : channel;
--synYcbcr          : channel;
--synLcobj          : channel;
--synRgbag          : channel;
oRgb <= d1Rgb;
-- frame_remake_h_cb_cr    [hu_cb_cr ]
-- frame_remake_s_cb_cr    [sa_cb_cr ]
-- frame_remake_l_cb_cr    [lu_cb_cr ]
-- frame_remake_h_cb_l     [hu_cb_lu ]
-- frame_remake_h_s_cr     [hu_sa_cr ]
-- frame_remake_ccr_h_cb   [ccr_hu_cb]
-- frame_remake_ccr_h_cr   [ccr_hu_cr]
-- frame_remake_ccr_h_s    [ccr_hu_sa]

l_ycc_inst  : rgb_ycbcr
generic map(
    i_data_width         => i_data_width,
    i_precision          => 12,
    i_full_range         => TRUE)
port map(
    clk                  => clk,
    rst_l                => reset,
    iRgb                 => iRgb.inrgb,
    y                    => ycbcr.red,
    cb                   => ycbcr.green,
    cr                   => ycbcr.blue,
    oValid               => ycbcr.valid);
    
    
yccSyncr_inst  : sync_frames
generic map(
    pixelDelay           => 10)
port map(
    clk                  => clk,
    reset                => reset,
    iRgb                 => ycbcr,
    oRgb                 => synYcbcr);

iRgb_hsl1_range_inst  : sync_frames
generic map(
    pixelDelay           => 1)
port map(
    clk                  => clk,
    reset                => reset,
    iRgb                 => iRgb.hsl1_range,
    oRgb                 => iRgb_hsl1_range);
iRgb_hsll1range_inst  : sync_frames
generic map(
    pixelDelay           => 0)
port map(
    clk                  => clk,
    reset                => reset,
    iRgb                 => iRgb.hsll1range,
    oRgb                 => iRgb_hsll1range);
    
process (clk) begin  --frame_remake_h_cb_cr
    if rising_edge(clk) then
        d1Rgb.red    <= iRgb_hsl1_range.red;
        d1Rgb.green  <= synYcbcr.green;
        d1Rgb.blue   <= synYcbcr.blue;
        d1Rgb.valid  <= iRgb_hsl1_range.valid;
    end if;
end process;
process (clk) begin  --frame_remake_s_cb_cr
    if rising_edge(clk) then 
        d2Rgb.red    <= iRgb_hsl1_range.green;
        d2Rgb.green  <= synYcbcr.green;
        d2Rgb.blue   <= synYcbcr.blue;
        d2Rgb.valid  <= iRgb_hsl1_range.valid;
    end if;
end process;
process (clk) begin  --frame_remake_l_cb_cr
    if rising_edge(clk) then 
        d3Rgb.red    <= iRgb_hsl1_range.blue;
        d3Rgb.green  <= synYcbcr.green;
        d3Rgb.blue   <= synYcbcr.blue;
        d3Rgb.valid  <= iRgb_hsl1_range.valid;
    end if;
end process;
process (clk) begin  --frame_remake_h_cb_l
    if rising_edge(clk) then 
        d4Rgb.red    <= iRgb_hsl1_range.red;
        d4Rgb.green  <= synYcbcr.green;
        d4Rgb.blue   <= iRgb.hsv.blue;
        d4Rgb.valid  <= iRgb_hsl1_range.valid;
    end if;
end process;
process (clk) begin  --frame_remake_h_s_cr
    if rising_edge(clk) then 
        d5Rgb.red    <= iRgb_hsl1_range.red;
        d5Rgb.green  <= iRgb_hsl1_range.green;
        d5Rgb.blue   <= synYcbcr.blue;
        d5Rgb.valid  <= iRgb_hsl1_range.valid;
    end if;
end process;
process (clk) begin --frame_remake_ccr_h_cb
    if rising_edge(clk) then 
        d6Rgb.red    <= iRgb.cgain.red;
        d6Rgb.green  <= iRgb_hsl1_range.red;
        d6Rgb.blue   <= synYcbcr.blue;
        d6Rgb.valid  <= iRgb_hsl1_range.valid;
    end if;
end process;
process (clk) begin --frame_remake_ccr_h_cr
    if rising_edge(clk) then 
        d7Rgb.red    <= iRgb.cgain.red;
        d7Rgb.green  <= iRgb_hsl1_range.red;
        d7Rgb.blue   <= synYcbcr.blue;
        d7Rgb.valid  <= iRgb_hsl1_range.valid;
    end if;
end process;
process (clk) begin  --frame_remake_ccr_h_s
    if rising_edge(clk) then 
        d8Rgb.red    <= iRgb.cgain.red;
        d8Rgb.green  <= iRgb_hsl1_range.red;
        d8Rgb.blue   <= iRgb.hsv.blue;
        d8Rgb.valid  <= iRgb_hsl1_range.valid;
    end if;
end process;
process (clk) begin  --fframe_remake_s_cb_cr
    if rising_edge(clk) then 
        d22Rgb.red    <= iRgb_hsll1range.green;
        d22Rgb.green  <= synYcbcr.green;
        d22Rgb.blue   <= synYcbcr.blue;
        d22Rgb.valid  <= iRgb_hsll1range.valid;
    end if;
end process;
process (clk) begin  --fframe_remake_l_cb_cr
    if rising_edge(clk) then 
        d23Rgb.red    <= iRgb_hsll1range.blue;
        d23Rgb.green  <= synYcbcr.green;
        d23Rgb.blue   <= synYcbcr.blue;
        d23Rgb.valid  <= iRgb_hsll1range.valid;
    end if;
end process;
process (clk) begin  --fframe_remake_s_l_cr
    if rising_edge(clk) then 
        d25Rgb.red    <= iRgb_hsll1range.green;
        d25Rgb.green  <= iRgb_hsll1range.blue;
        d25Rgb.blue   <= synYcbcr.blue;
        d25Rgb.valid  <= iRgb_hsll1range.valid;
    end if;
end process;
process (clk) begin --fframe_remake_ccr_s_cb
    if rising_edge(clk) then 
        d26Rgb.red    <= iRgb.cgain.red;
        d26Rgb.green  <= iRgb_hsll1range.green;
        d26Rgb.blue   <= synYcbcr.blue;
        d26Rgb.valid  <= iRgb_hsll1range.valid;
    end if;
end process;
process (clk) begin --fframe_remake_ccr_s_cr
    if rising_edge(clk) then 
        d27Rgb.red    <= iRgb.cgain.red;
        d27Rgb.green  <= iRgb_hsll1range.green;
        d27Rgb.blue   <= synYcbcr.blue;
        d27Rgb.valid  <= iRgb_hsll1range.valid;
    end if;
end process;
process (clk) begin  --fframe_remake_ccr_s_l
    if rising_edge(clk) then 
        d28Rgb.red    <= iRgb.cgain.red;
        d28Rgb.green  <= iRgb_hsll1range.green;
        d28Rgb.blue   <= iRgb_hsll1range.blue;
        d28Rgb.valid  <= iRgb_hsll1range.valid;
    end if;
end process;
fframe_remake_s_cb_cr_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => "testFolder",
    input_file            => readbmp,
    output_file           => "fframe_remake_s_cb_cr")
port map (                  
    pixclk                => clk,
    iRgb                  => d22Rgb);
fframe_remake_l_cb_cr_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => "testFolder",
    input_file            => readbmp,
    output_file           => "fframe_remake_l_cb_cr")
port map (                  
    pixclk                => clk,
    iRgb                  => d23Rgb);
fframe_remake_s_l_cr_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => "testFolder",
    input_file            => readbmp,
    output_file           => "fframe_remake_s_l_cr")
port map (                  
    pixclk                => clk,
    iRgb                  => d25Rgb);
fframe_remake_ccr_s_cb_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => "testFolder",
    input_file            => readbmp,
    output_file           => "fframe_remake_ccr_s_cb")
port map (                  
    pixclk                => clk,
    iRgb                  => d26Rgb);
fframe_remake_ccr_s_cr_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => "testFolder",
    input_file            => readbmp,
    output_file           => "fframe_remake_ccr_s_cr")
port map (                  
    pixclk                => clk,
    iRgb                  => d27Rgb);
fframe_remake_ccr_s_l_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => "testFolder",
    input_file            => readbmp,
    output_file           => "fframe_remake_ccr_s_l")
port map (                  
    pixclk                => clk,
    iRgb                  => d28Rgb);
frame_remake_h_cb_cr_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => "testFolder",
    input_file            => readbmp,
    output_file           => "frame_remake_h_cb_cr")
port map (                  
    pixclk                => clk,
    iRgb                  => d1Rgb);
frame_remake_s_cb_cr_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => "testFolder",
    input_file            => readbmp,
    output_file           => "frame_remake_s_cb_cr")
port map (                  
    pixclk                => clk,
    iRgb                  => d2Rgb);
frame_remake_l_cb_cr_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => "testFolder",
    input_file            => readbmp,
    output_file           => "frame_remake_l_cb_cr")
port map (                  
    pixclk                => clk,
    iRgb                  => d3Rgb);
frame_remake_h_cb_l_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => "testFolder",
    input_file            => readbmp,
    output_file           => "frame_remake_h_cb_l")
port map (                  
    pixclk                => clk,
    iRgb                  => d4Rgb);
frame_remake_h_s_cr_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => "testFolder",
    input_file            => readbmp,
    output_file           => "frame_remake_h_s_cr")
port map (                  
    pixclk                => clk,
    iRgb                  => d5Rgb);
frame_remake_ccr_h_cb_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => "testFolder",
    input_file            => readbmp,
    output_file           => "frame_remake_ccr_h_cb")
port map (                  
    pixclk                => clk,
    iRgb                  => d6Rgb);
frame_remake_ccr_h_cr_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => "testFolder",
    input_file            => readbmp,
    output_file           => "frame_remake_ccr_h_cr")
port map (                  
    pixclk                => clk,
    iRgb                  => d7Rgb);
frame_remake_ccr_h_s_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => "testFolder",
    input_file            => readbmp,
    output_file           => "frame_remake_ccr_h_s")
port map (                  
    pixclk                => clk,
    iRgb                  => d8Rgb);
end behavioral;
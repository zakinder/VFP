--------------------------------------------------------------------------------
--
-- Filename    : filters.vhd
-- Create Date : 05022019 [05-02-2019]
-- Author      : Zakinder
--
-- Description:
-- This file instantiation
--
--------------------------------------------------------------------------------
-- filter_dith_1_inst  : dither_filter
-- filter_blur_1_inst  : blur_filter
-- filter_dith_2_inst  : dither_filter
-- filter_blur_2_inst  : blur_filter
-- filter_dith_3_inst  : dither_filter
-- filter_blur_3_inst  : blur_filter
-- filter_kernel_inst  : kernel
-- filter_blur_4_inst  : blur_filter
-- filter_colcor_inst  : color_correction
-- filter_sharpe_inst  : sharp_filter
-- sharp_f_valid_inst  : d_valid
-- filter_blur_5_inst  : blur_filter
-- blurr_f_valid_inst  : d_valid
-- filter_y_cbcr_inst  : rgb_ycbcr
-- test_patterns_inst  : testpattern
-- frame_masking_inst  : frame_mask
-- frame_masking_inst  : frame_mask
-- sob_hsv_syncr_inst  : sync_frames
-- frame_masking_inst  : frame_mask
-- sob_hsv_syncr_inst  : sync_frames
-- frame_masking_inst  : frame_mask
-- frame_masking_inst  : frame_mask
-- frame_masking_inst  : frame_mask
-- tap_mk_sobcga_inst  : taps_controller
-- sob_rgb_syncr_inst  : sync_frames
-- frame_masking_inst  : frame_mask
-- frame_masking_inst  : frame_mask
-- frame_masking_inst  : frame_mask
-- ycbcr_rgb_sel_inst  : rgb_select
-- ycbcr_f_valid_inst  : d_valid
-- k_hsv_rgb_sel_inst  : rgb_select
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fixed_pkg.all;

use work.constants_package.all;
use work.vpf_records.all;
use work.ports_package.all;

entity filters is
generic (
    F_TES                    : boolean := false;
    F_LUM                    : boolean := false;
    F_TRM                    : boolean := false;
    F_RGB                    : boolean := false;
    F_SHP                    : boolean := false;
    F_BLU                    : boolean := false;
    F_EMB                    : boolean := false;
    F_YCC                    : boolean := false;
    F_SOB                    : boolean := false;
    F_CGA                    : boolean := false;
    F_HSV                    : boolean := false;
    F_HSL                    : boolean := false;
    L_BLU                    : boolean := false;
    M_SOB_LUM                : boolean := false;
    M_SOB_TRM                : boolean := false;
    M_SOB_RGB                : boolean := false;
    M_SOB_SHP                : boolean := false;
    M_SOB_BLU                : boolean := false;
    M_SOB_YCC                : boolean := false;
    M_SOB_CGA                : boolean := false;
    M_SOB_HSV                : boolean := false;
    M_SOB_HSL                : boolean := false;
    F_BLUR_CHANNELS          : boolean := false;
    F_DITH_CHANNELS          : boolean := false;
    img_width                : integer := 4096;
    img_height               : integer := 4096;
    adwrWidth                : integer := 16;
    addrWidth                : integer := 12;
    s_data_width             : integer := 16;
    i_data_width             : integer := 8);
port (
    clk                      : in std_logic;
    rst_l                    : in std_logic;
    txCord                   : in coord;
    iRgb                     : in channel;
    iLumTh                   : in integer;
    iSobelTh                 : in integer;
    iVideoChannel            : in integer;
    iFilterId                : in integer;
    iHsvPerCh                : in integer;
    iYccPerCh                : in integer;
    iAls                     : in coefficient;
    iKcoeff                  : in kernelCoeff;
    oKcoeff                  : out kernelCoeff;
    edgeValid                : out std_logic;
    blur_channels            : out blur_frames;
    oRgb                     : out frameColors);
end filters;

architecture Behavioral of filters is

    signal rgbImageKernel      : colors;
    constant init_channel      : channel := (valid => lo, red => black, green => black, blue => black);
    signal fRgb                : frameColors;
    signal sEdgeValid          : std_logic;
    signal ycbcrValid          : std_logic;
    signal fRgb1               : colors;
    signal fRgb2               : colors;
    signal fRgb3               : colors;
    signal cgainIoIn           : channel;
    signal sharpIoIn           : channel;
    signal blurIoIn            : channel;
    signal YcbcrIoIn           : channel;
    signal cgainIoOut          : channel;
    signal cgainValidRgb       : channel;
    signal sharpIoOut          : channel;
    signal blurIoOut           : channel;
    signal sharpIodValid       : channel;
    signal blurIodValid        : channel;
    signal YcbcrIoOut          : channel;
    signal YcbcrIoOutSelect    : channel;
    signal rgbImageKernel_blur : channel;

    signal blur1vx             : channel;
    signal blur2vx             : channel;
    signal blur3vx             : channel;
    
    signal ditRgb1vx           : channel;
    signal ditRgb2vx           : channel;
    signal ditRgb3vx           : channel;

    
    signal rgbSel              : channel;

    
begin

    edgeValid               <= sEdgeValid;
    oRgb                    <= fRgb;
    
    blur_channels.ditRgb1vx <= ditRgb1vx;
    blur_channels.ditRgb2vx <= ditRgb2vx;
    blur_channels.ditRgb3vx <= ditRgb3vx;
    
    blur_channels.blur1vx   <= blur1vx;
    blur_channels.blur2vx   <= blur2vx;
    blur_channels.blur3vx   <= blur3vx;
    
    fRgb.cgainToYcbcr       <= fRgb1.ycbcr;--CgainToYcbcr
    fRgb.cgainToShp         <= fRgb1.sharp;--CgainToSharp
    fRgb.cgainToBlu         <= fRgb1.blur; --CgainToBlur
    fRgb.cgainToCgain       <= fRgb1.cgain;--CgainToCgain
    fRgb.shpToYcbcr         <= fRgb2.ycbcr;--SharpToYcbcr
    fRgb.shpToShp           <= fRgb2.sharp;--SharpToSharp
    fRgb.shpToBlu           <= fRgb2.blur; --SharpToBlur
    fRgb.shpToCgain         <= fRgb2.cgain;--SharpToCgain
    fRgb.bluToYcc           <= fRgb3.ycbcr;--BlurToYcbcr
    fRgb.bluToShp           <= fRgb3.sharp;--BlurToSharp
    fRgb.bluToBlu           <= fRgb3.blur; --BlurToBlur
    fRgb.bluToCga           <= fRgb3.cgain;--BlurToCgain
    fRgb.cgainToHsl         <= fRgb1.hsl;  --CgainToHsl  ,HslToCgain
    fRgb.cgainToHsv         <= fRgb1.hsv;  --CgainToHsv  ,HsvToCgain
    fRgb.shpToHsl           <= fRgb2.hsl;  --SharpToHsl  ,HslToSharp
    fRgb.shpToHsv           <= fRgb2.hsv;  --SharpToHsv  ,HsvToSharp
    fRgb.bluToHsl           <= fRgb3.hsl;  --BlurToHsl   ,HslToBlur
    fRgb.bluToHsv           <= fRgb3.hsv;  --BlurToHsv   ,HsvToBlur

lThSelectP: process (clk) begin
    if rising_edge(clk) then
        if (iLumTh = 0)  then
            rgbSel     <= iRgb;
        else
            rgbSel     <= blur3vx;
        end if;
    end if;
end process lThSelectP;


CgainIoP: process (clk) begin
    if rising_edge(clk) then
        if (iVideoChannel = FILTER_SHP_TO_CGA) then
            cgainIoIn           <= rgbImageKernel.sharp;--SharpToCgain
            fRgb2.cgain         <= cgainIoOut;
        elsif(iVideoChannel = FILTER_CGA_TO_HSL)then
            cgainIoIn           <= rgbImageKernel.hsl;  --CgainToHsl  ,HslToCgain
            fRgb1.hsl           <= cgainIoOut;
        elsif(iVideoChannel = FILTER_CGA_TO_HSV)then
            cgainIoIn           <= rgbImageKernel.hsv;  --CgainToHsv  ,HsvToCgain
            fRgb1.hsv           <= cgainIoOut;
        elsif(iVideoChannel = FILTER_BLU_TO_CGA)then
            cgainIoIn           <= rgbImageKernel_blur; --BlurToCgain
            fRgb3.cgain         <= cgainIoOut;
        elsif(iVideoChannel = FILTER_K_CGA)then
            cgainIoIn           <= rgbImageKernel.hsl; --Kernal Cgain
            fRgb1.cgain         <= cgainIoOut;
            fRgb3.cgain         <= rgbImageKernel.cgain;
        else
            cgainIoIn           <= cgainValidRgb;--CgainToCgain
            fRgb1.cgain         <= cgainIoOut;
        end if;
    end if;
end process CgainIoP;


SharpIoP: process (clk) begin
    if rising_edge(clk) then
        if (iVideoChannel = FILTER_CGA_TO_SHP) then
            sharpIoIn           <= cgainValidRgb;--CgainToSharp
            fRgb1.sharp         <= sharpIoOut;
        elsif(iVideoChannel = FILTER_SHP_TO_HSL)then
            sharpIoIn           <= rgbImageKernel.hsl;  --SharpToHsl  ,HslToSharp
            fRgb2.hsl           <= sharpIoOut;
        elsif(iVideoChannel = FILTER_SHP_TO_HSV)then
            sharpIoIn           <= rgbImageKernel.hsv;  --SharpToHsv  ,HsvToSharp
            fRgb2.hsv           <= sharpIoOut;
        elsif(iVideoChannel = FILTER_BLU_TO_SHP)then
            sharpIoIn           <= rgbImageKernel_blur; --BlurToSharp
            fRgb3.sharp         <= sharpIoOut;
        else
            sharpIoIn           <= rgbImageKernel.sharp;--SharpToSharp
            fRgb2.sharp         <= sharpIoOut;
        end if;
    end if;
end process SharpIoP;


BlurIoP: process (clk) begin
    if rising_edge(clk) then
        if (iVideoChannel = FILTER_CGA_TO_BLU) then
            blurIoIn            <= cgainValidRgb; --CgainToBlur
            fRgb1.blur          <= blurIoOut;
        elsif(iVideoChannel = FILTER_SHP_TO_BLU)then
            blurIoIn            <= rgbImageKernel.sharp; --SharpToBlur
            fRgb2.blur          <= blurIoOut;
        elsif(iVideoChannel = FILTER_BLU_TO_BLU)then
            blurIoIn            <= rgbImageKernel_blur;   --BlurToHsl   ,HslToBlur
            fRgb3.blur          <= blurIoOut;
        elsif(iVideoChannel = FILTER_BLU_TO_HSV)then
            blurIoIn            <= rgbImageKernel.hsv;   --BlurToHsv   ,HsvToBlur
            fRgb3.hsv           <= blurIoOut;
        elsif(iVideoChannel = FILTER_BLU_TO_HSL)then
            blurIoIn            <= rgbImageKernel.hsl;   --BlurToHsl   ,HslToBlur
            fRgb3.hsl           <= blurIoOut;
        else
            blurIoIn            <= rgbImageKernel_blur;  --BlurToBlur
            fRgb3.blur          <= blurIoOut;
        end if;
    end if;
end process BlurIoP;


YcbcrIoP: process (clk) begin
    if rising_edge(clk) then
        if (iVideoChannel = FILTER_CGA_TO_YCC) then
            YcbcrIoIn           <= cgainValidRgb; --CgainToYcbcr
            YcbcrIoOut          <= YcbcrIoOutSelect;
            fRgb1.ycbcr         <= YcbcrIoOut;
        elsif(iVideoChannel = FILTER_BLU_TO_YCC)then
            YcbcrIoIn           <= rgbImageKernel_blur;  --BlurToYcbcr
            YcbcrIoOut          <= YcbcrIoOutSelect;
            fRgb3.ycbcr         <= YcbcrIoOut;
        elsif(iVideoChannel = FILTER_SHP_TO_YCC)then
            YcbcrIoIn           <= rgbImageKernel.sharp; --SharpToYcbcr
            YcbcrIoOut          <= YcbcrIoOutSelect;
            fRgb3.ycbcr         <= YcbcrIoOut;
        elsif(iVideoChannel = FILTER_YCC)then
            YcbcrIoIn           <= iRgb;
            fRgb2.ycbcr         <= rgbImageKernel.ycbcr; --
            YcbcrIoOut          <= rgbImageKernel.ycbcr; --
        else
            YcbcrIoIn           <= iRgb;
            YcbcrIoOut          <= YcbcrIoOutSelect;--SharpToYcbcr
            fRgb2.ycbcr         <= YcbcrIoOut;
        end if;
    end if;
end process YcbcrIoP;




F_BLUR_CHANNELS_ENABLE: if (F_BLUR_CHANNELS = true) generate
begin
filter_blur_1_inst  : blur_filter
generic map(
    iMSB                => blurMsb,
    iLSB                => blurLsb,
    i_data_width        => i_data_width,
    img_width           => img_width,
    adwrWidth           => adwrWidth,
    addrWidth           => addrWidth)
port map(
    clk                 => clk,
    rst_l               => rst_l,
    iRgb                => ditRgb1vx,
    oRgb                => blur1vx);

filter_blur_2_inst  : blur_filter
generic map(
    iMSB                => blurMsb - 1,
    iLSB                => blurLsb - 1,
    i_data_width        => i_data_width,
    img_width           => img_width,
    adwrWidth           => adwrWidth,
    addrWidth           => addrWidth)
port map(
    clk                 => clk,
    rst_l               => rst_l,
    iRgb                => blur1vx,
    oRgb                => blur2vx);

filter_blur_3_inst  : blur_filter
generic map(
    iMSB                => blurMsb - 1,
    iLSB                => blurLsb - 1,
    i_data_width        => i_data_width,
    img_width           => img_width,
    adwrWidth           => adwrWidth,
    addrWidth           => addrWidth)
port map(
    clk                 => clk,
    rst_l               => rst_l,
    iRgb                => blur2vx,
    oRgb                => blur3vx);
end generate F_BLUR_CHANNELS_ENABLE;


F_DITH_CHANNELS_ENABLE: if (F_DITH_CHANNELS = true) generate

begin

filter_dith_1_inst  : dither_filter
generic map (
    img_width         => img_width,
    img_height        => img_height,
    color_width       => 8,
    reduced_width     => 1)
port map (
    clk               => clk,
    iCord_x           => txCord.x,
    iRgb              => iRgb,
    oRgb              => ditRgb1vx);
    
filter_dith_2_inst  : dither_filter
generic map (
    img_width         => img_width,
    img_height        => img_height,
    color_width       => 8,
    reduced_width     => 2)
port map (
    clk               => clk,
    iCord_x           => txCord.x,
    iRgb              => iRgb,
    oRgb              => ditRgb2vx);
    
filter_dith_3_inst  : dither_filter
generic map (
    img_width         => img_width,
    img_height        => img_height,
    color_width       => 8,
    reduced_width     => 3)
port map (
    clk               => clk,
    iCord_x           => txCord.x,
    iRgb              => iRgb,
    oRgb              => ditRgb3vx);

end generate F_DITH_CHANNELS_ENABLE;


--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
filter_kernel_inst  : kernel
generic map(
    INRGB_FRAME         => F_RGB,
    RGBLP_FRAME         => F_LUM,
    RGBTR_FRAME         => F_TRM,
    SHARP_FRAME         => F_SHP,
    BLURE_FRAME         => F_BLU,
    EMBOS_FRAME         => F_EMB,
    YCBCR_FRAME         => F_YCC,
    SOBEL_FRAME         => F_SOB,
    CGAIN_FRAME         => F_CGA,
    CCGAIN_FRAME        => false,
    HSV_FRAME           => F_HSV,
    HSL_FRAME           => F_HSL,
    img_width           => img_width,
    img_height          => img_height,
    s_data_width        => s_data_width,
    i_data_width        => i_data_width)
port map(
    clk                 => clk,
    rst_l               => rst_l,
    txCord              => txCord,
    iLumTh              => iLumTh,
    iSobelTh            => iSobelTh,
    iRgb                => rgbSel,
    iKcoeff             => iKcoeff,
    iFilterId           => iFilterId,
    oKcoeff             => oKcoeff,
    oEdgeValid          => sEdgeValid,
    oRgb                => rgbImageKernel);
    
    
L_BLUR_CHANNELS_ENABLE: if (L_BLU = true) generate
begin
filter_blur_4_inst  : blur_filter
generic map(
    iMSB                => blurMsb,
    iLSB                => blurLsb,
    i_data_width        => i_data_width,
    img_width           => img_width,
    adwrWidth           => adwrWidth,
    addrWidth           => addrWidth)
port map(
    clk                 => clk,
    rst_l               => rst_l,
    iRgb                => iRgb,
    oRgb                => rgbImageKernel_blur);
end generate L_BLUR_CHANNELS_ENABLE;



    
    
filter_colcor_inst  : color_correction
generic map(
    i_data_width        => i_data_width)
port map(
    clk                 => clk,
    rst_l               => rst_l,
    iRgb                => cgainIoIn,
    als                 => iAls,
    oRgb                => cgainIoOut);
filter_sharpe_inst  : sharp_filter
generic map(
    i_data_width        => i_data_width,
    img_width           => img_width,
    adwrWidth           => adwrWidth,
    addrWidth           => addrWidth)
port map(
    clk                 => clk,
    rst_l               => rst_l,
    iRgb                => sharpIoIn,
    kls                 => iAls,
    oRgb                => sharpIodValid);
sharp_f_valid_inst  : d_valid
generic map (
    pixelDelay   => 25)
port map(
    clk      => clk,
    iRgb     => sharpIodValid,
    oRgb     => sharpIoOut);
filter_blur_5_inst  : blur_filter
generic map(
    iMSB                => blurMsb,
    iLSB                => blurLsb,
    i_data_width        => i_data_width,
    img_width           => img_width,
    adwrWidth           => adwrWidth,
    addrWidth           => addrWidth)
port map(
    clk                 => clk,
    rst_l               => rst_l,
    iRgb                => blurIoIn,
    oRgb                => blurIodValid);
blurr_f_valid_inst  : d_valid
generic map (
    pixelDelay   => 16)
port map(
    clk      => clk,
    iRgb     => blurIodValid,
    oRgb     => blurIoOut);
    
filter_y_cbcr_inst  : rgb_ycbcr
generic map(
    i_data_width         => i_data_width,
    i_precision          => 12,
    i_full_range         => TRUE)
port map(
    clk                  => clk,
    rst_l                => rst_l,
    iRgb                 => YcbcrIoIn,
    y                    => YcbcrIoOutSelect.red,
    cb                   => YcbcrIoOutSelect.green,
    cr                   => YcbcrIoOutSelect.blue,
    oValid               => YcbcrIoOutSelect.valid);
--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
TEST_FRAME_ENABLE: if (F_TES = true) generate
begin
test_patterns_inst  : testpattern
port map(
    clk           => clk,
    iValid        => iRgb.valid,
    iCord         => txCord,
    tpSelect      => iLumTh,
    oRgb          => fRgb.tPattern);
end generate TEST_FRAME_ENABLE;

MASK_SOB_CGA_FRAME_ENABLE : if (M_SOB_CGA = true) generate
    signal tp2cgain   : channel;
    signal tp2        : std_logic_vector(23 downto 0) := (others => '0');
    alias tp2Red      : std_logic_vector(7 downto 0) is tp2(23 downto 16);
    alias tp2Green    : std_logic_vector(7 downto 0) is tp2(15 downto 8);
    alias tp2Blue     : std_logic_vector(7 downto 0) is tp2(7 downto 0);
    signal tpValid    : std_logic  := lo;
begin
TapsControllerSobCgaInst: taps_controller
generic map(
    img_width    => img_width,
    tpDataWidth  => 24)
port map(
    clk          => clk,
    rst_l        => rst_l,
    iRgb         => rgbImageKernel.cgain,
    tpValid      => tpValid,
    tp0          => open,
    tp1          => open,
    tp2          => tp2);
process (clk,rst_l) begin
    if (rst_l = lo) then
        tp2cgain.red   <= black;
        tp2cgain.green <= black;
        tp2cgain.blue  <= black;
        tp2cgain.valid <= lo;
    elsif rising_edge(clk) then
        tp2cgain.red   <= tp2Red;
        tp2cgain.green <= tp2Green;
        tp2cgain.blue  <= tp2Blue;
        tp2cgain.valid <= tpValid;
    end if;
end process;
frame_masking_inst  : frame_mask
generic map (
    eBlack       => true)
port map(
    clk         => clk,
    reset       => rst_l,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => tp2cgain,
    oRgb        => fRgb.maskSobelCga);
end generate MASK_SOB_CGA_FRAME_ENABLE;
MASK_SOB_TRM_FRAME_ENABLE: if (M_SOB_TRM = true) generate
begin
frame_masking_inst  : frame_mask
generic map (
    eBlack       => true)
port map(
    clk         => clk,
    reset       => rst_l,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => rgbImageKernel.colorTrm,
    oRgb        => fRgb.maskSobelTrm);
end generate MASK_SOB_TRM_FRAME_ENABLE;
MASK_SOB_HSL_FRAME_ENABLE: if (M_SOB_HSL = true) generate
    signal dSobHsl           : channel;
    constant sobHslPiDelay   : integer := 18;
begin
sob_hsv_syncr_inst  : sync_frames
generic map(
    pixelDelay => sobHslPiDelay)
port map(
    clk        => clk,
    reset      => rst_l,
    iRgb       => rgbImageKernel.hsl,
    oRgb       => dSobHsl);
frame_masking_inst  : frame_mask
generic map (
    eBlack       => true)
port map(
    clk         => clk,
    reset       => rst_l,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => dSobHsl,
    oRgb        => fRgb.maskSobelHsl);
end generate MASK_SOB_HSL_FRAME_ENABLE;
MASK_SOB_HSV_FRAME_ENABLE: if (M_SOB_HSV = true) generate
    signal dSobHsv           : channel;
    constant sobHsvPiDelay   : integer := 18;
begin
sob_hsv_syncr_inst  : sync_frames
generic map(
    pixelDelay => sobHsvPiDelay)
port map(
    clk        => clk,
    reset      => rst_l,
    iRgb       => rgbImageKernel.hsv,
    oRgb       => dSobHsv);
frame_masking_inst  : frame_mask
generic map (
    eBlack       => true)
port map(
    clk         => clk,
    reset       => rst_l,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => dSobHsv,
    oRgb        => fRgb.maskSobelHsv);
end generate MASK_SOB_HSV_FRAME_ENABLE;
MASK_SOB_YCC_FRAME_ENABLE: if (M_SOB_YCC = true) generate
begin
frame_masking_inst  : frame_mask
generic map (
    eBlack       => true)
port map(
    clk         => clk,
    reset       => rst_l,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => YcbcrIoOutSelect,
    oRgb        => fRgb.maskSobelYcc);
end generate MASK_SOB_YCC_FRAME_ENABLE;
MASK_SOB_SHP_FRAME_ENABLE: if (M_SOB_SHP = true) generate
begin
frame_masking_inst  : frame_mask
generic map (
    eBlack       => true)
port map(
    clk         => clk,
    reset       => rst_l,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => rgbImageKernel.sharp,
    oRgb        => fRgb.maskSobelShp);
end generate MASK_SOB_SHP_FRAME_ENABLE;
MASK_SOB_RGB_FRAME_ENABLE: if (M_SOB_RGB = true) generate
    constant sobRgbPiDelay : integer := 14;
    signal tp2inrgb        : channel;
    signal tp2             : std_logic_vector(23 downto 0) := (others => '0');
    alias tp2Red           : std_logic_vector(7 downto 0) is tp2(23 downto 16);
    alias tp2Green         : std_logic_vector(7 downto 0) is tp2(15 downto 8);
    alias tp2Blue          : std_logic_vector(7 downto 0) is tp2(7 downto 0);
    signal tpValid         : std_logic  := lo;
    signal d1Rgb           : channel;
begin
tap_mk_sobcga_inst  : taps_controller
generic map(
    img_width    => img_width,
    tpDataWidth  => 24)
port map(
    clk          => clk,
    rst_l        => rst_l,
    iRgb         => rgbImageKernel.inrgb,
    tpValid      => tpValid,
    tp0          => open,
    tp1          => open,
    tp2          => tp2);
process (clk,rst_l) begin
    if (rst_l = lo) then
        tp2inrgb.red   <= black;
        tp2inrgb.green <= black;
        tp2inrgb.blue  <= black;
        tp2inrgb.valid <= lo;
    elsif rising_edge(clk) then
        tp2inrgb.red   <= tp2Red;
        tp2inrgb.green <= tp2Green;
        tp2inrgb.blue  <= tp2Blue;
        tp2inrgb.valid <= tpValid;
    end if;
end process;
sob_rgb_syncr_inst  : sync_frames
generic map(
    pixelDelay => sobRgbPiDelay)
port map(
    clk        => clk,
    reset      => rst_l,
    iRgb       => tp2inrgb,
    oRgb       => d1Rgb);
frame_masking_inst  : frame_mask
generic map (
    eBlack       => true)
port map(
    clk         => clk,
    reset       => rst_l,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => d1Rgb,
    oRgb        => fRgb.maskSobelRgb);
end generate MASK_SOB_RGB_FRAME_ENABLE;
MASK_SOB_LUM_FRAME_ENABLE: if (M_SOB_LUM = true) generate
begin
frame_masking_inst  : frame_mask
generic map (
    eBlack       => true)
port map(
    clk         => clk,
    reset       => rst_l,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => rgbImageKernel.colorLmp,
    oRgb        => fRgb.maskSobelLum);
end generate MASK_SOB_LUM_FRAME_ENABLE;
MASK_SOB_BLU_FRAME_ENABLE: if (M_SOB_BLU = true) generate
begin
frame_masking_inst  : frame_mask
generic map (
    eBlack       => true)
port map(
    clk         => clk,
    reset       => rst_l,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => rgbImageKernel.blur,
    oRgb        => fRgb.maskSobelBlu);
end generate MASK_SOB_BLU_FRAME_ENABLE;
INRGB_FRAME_ENABLE: if (F_RGB = true) generate
    fRgb.inrgb <= rgbImageKernel.inrgb;
end generate INRGB_FRAME_ENABLE;
YCBCR_FRAME_ENABLE: if (F_YCC = true) generate
    signal dlyYcbcr   : channel;
    signal rgbYcbcr   : channel;
begin
ycbcr_rgb_sel_inst  : rgb_select
    port map(
        clk      => clk,
        iPerCh   => iYccPerCh,
        iRgb     => rgbYcbcr,
        oRgb     => fRgb.ycbcr);
    process (clk) begin
        if rising_edge(clk) then
            if (iVideoChannel = FILTER_YCC) then
                rgbYcbcr    <= dlyYcbcr;
            else
                rgbYcbcr    <= YcbcrIoOut;
            end if;
        end if;
    end process;
ycbcr_f_valid_inst  : d_valid
    generic map (
        pixelDelay   => 18)
    port map(
        clk      => clk,
        iRgb     => YcbcrIoOut,
        oRgb     => dlyYcbcr);
end generate YCBCR_FRAME_ENABLE;
SHARP_FRAME_ENABLE: if (F_SHP = true) generate
begin
    fRgb.sharp <= rgbImageKernel.sharp;
end generate SHARP_FRAME_ENABLE;
BLURE_FRAME_ENABLE: if (F_BLU = true) generate
begin
    fRgb.blur <= rgbImageKernel.blur;
end generate BLURE_FRAME_ENABLE;
EMBOS_FRAME_ENABLE: if (F_EMB = true) generate
begin
    fRgb.embos <= rgbImageKernel.embos;
end generate EMBOS_FRAME_ENABLE;
SOBEL_FRAME_ENABLE: if (F_SOB = true) generate
signal sobel_delay : channel;
begin
    fRgb.sobel <= rgbImageKernel.sobel;
end generate SOBEL_FRAME_ENABLE;
CGAIN_FRAME_ENABLE: if (F_CGA = true) generate begin
    fRgb.cgain <= rgbImageKernel.cgain;
end generate CGAIN_FRAME_ENABLE;
HSL_FRAME_ENABLE: if (F_HSL = true) generate
    fRgb.hsl <= rgbImageKernel.hsl;
end generate HSL_FRAME_ENABLE;
HSV_FRAME_ENABLE: if (F_HSV = true) generate begin
k_hsv_rgb_sel_inst  : rgb_select
        port map(
            clk      => clk,
            iPerCh   => iHsvPerCh,
            iRgb     => rgbImageKernel.hsv,
            oRgb     => fRgb.hsv);
end generate HSV_FRAME_ENABLE;
LUM_FRAME_ENABLE: if (F_LUM = true) generate
    fRgb.colorLmp <= rgbImageKernel.colorLmp;
end generate LUM_FRAME_ENABLE;
TRM_FRAME_ENABLE: if (F_TRM = true) generate
    fRgb.colorTrm <= rgbImageKernel.colorTrm;
end generate TRM_FRAME_ENABLE;
MASK_SOB_CGA_FRAME_DISABLED: if (M_SOB_CGA = false) generate
    fRgb.maskSobelCga  <= init_channel;
end generate MASK_SOB_CGA_FRAME_DISABLED;
MASK_SOB_TRM_FRAME_DISABLED: if (M_SOB_TRM = false) generate
    fRgb.maskSobelTrm  <= init_channel;
end generate MASK_SOB_TRM_FRAME_DISABLED;
MASK_SOB_HSL_FRAME_DISABLED: if (M_SOB_HSL = false) generate
    fRgb.maskSobelHsl  <= init_channel;
end generate MASK_SOB_HSL_FRAME_DISABLED;
MASK_SOB_HSV_FRAME_DISABLED: if (M_SOB_HSV = false) generate
    fRgb.maskSobelHsv  <= init_channel;
end generate MASK_SOB_HSV_FRAME_DISABLED;
MASK_SOB_YCC_FRAME_DISABLED: if (M_SOB_YCC = false) generate
    fRgb.maskSobelYcc  <= init_channel;
end generate MASK_SOB_YCC_FRAME_DISABLED;
MASK_SOB_SHP_FRAME_DISABLED: if (M_SOB_SHP = false) generate
    fRgb.maskSobelShp  <= init_channel;
end generate MASK_SOB_SHP_FRAME_DISABLED;
MASK_SOB_RGB_FRAME_DISABLED: if (M_SOB_RGB = false) generate
    fRgb.maskSobelRgb  <= init_channel;
end generate MASK_SOB_RGB_FRAME_DISABLED;
MASK_SOB_LUM_FRAME_DISABLED: if (M_SOB_LUM = false) generate
    fRgb.maskSobelLum  <= init_channel;
end generate MASK_SOB_LUM_FRAME_DISABLED;
MASK_SOB_BLU_FRAME_DISABLED: if (M_SOB_BLU = false) generate
    fRgb.maskSobelBlu  <= init_channel;
end generate MASK_SOB_BLU_FRAME_DISABLED;
LUM_FRAME_DISABLED: if (F_LUM = false) generate
    fRgb.colorLmp  <= init_channel;
end generate LUM_FRAME_DISABLED;
TRM_FRAME_DISABLED: if (F_TRM = false) generate
    fRgb.colorTrm  <= init_channel;
end generate TRM_FRAME_DISABLED;
INRGB_FRAME_DISABLED: if (F_RGB = false) generate
    fRgb.inrgb     <= init_channel;
end generate INRGB_FRAME_DISABLED;
YCBCR_FRAME_DISABLED: if (F_YCC = false) generate
    fRgb.ycbcr     <= init_channel;
end generate YCBCR_FRAME_DISABLED;
SHARP_FRAME_DISABLED: if (F_SHP = false) generate
    fRgb.sharp     <= init_channel;
end generate SHARP_FRAME_DISABLED;
BLURE_FRAME_DISABLED: if (F_BLU = false) generate
    fRgb.blur     <= init_channel;
end generate BLURE_FRAME_DISABLED;
EMBOS_FRAME_DISABLED: if (F_EMB = false) generate
    fRgb.embos     <= init_channel;
end generate EMBOS_FRAME_DISABLED;
SOBEL_FRAME_DISABLED: if (F_SOB = false) generate
    fRgb.sobel     <= init_channel;
end generate SOBEL_FRAME_DISABLED;
CGAIN_FRAME_DISABLED: if (F_CGA = false) generate
    fRgb.cgain     <= init_channel;
end generate CGAIN_FRAME_DISABLED;
HSL_FRAME_DISABLED: if (F_HSL = false) generate
    fRgb.hsl     <= init_channel;
end generate HSL_FRAME_DISABLED;
HSV_FRAME_DISABLED: if (F_HSV = false) generate
    fRgb.hsv     <= init_channel;
end generate HSV_FRAME_DISABLED;
end Behavioral;
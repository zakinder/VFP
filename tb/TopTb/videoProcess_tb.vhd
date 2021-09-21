--01062019 [01-06-2019]
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.constants_package.all;
use work.vpf_records.all;
use work.ports_package.all;
use work.tbPackage.all;
use work.dutPortsPackage.all;
entity video_process_tb is
end video_process_tb;
architecture behavioral of video_process_tb is
    signal resetn                        : std_logic := lo;
    signal clk                           : std_logic;
    signal kCoeff                        : kernelCoeff;
    signal oKcoeff                       : kernelCoeff;
    signal iAls                          : coefficient;
    signal olm                           : rgbConstraint;
    signal edgeValid                     : std_logic;
    constant clk_freq                    : real    := 1000.00e6;
    signal txCord                        : coord;
    signal iVideoChannel                 : integer;
    signal iThreshold                    : std_logic_vector(s_data_width-1 downto 0); 
    --cgain  ycbcr sobel blur emboss sobelRgb hsv ycbcr_y ycbcr_r hsv_h hsv_s hsv_v
    constant testFolder                  : string  := "F_BLU_TO_HSL";
    -------------------------------------------------
    constant DUT_FILTERS_TESTENABLED     : boolean := true;
    constant DUT_VFP_ENABLED             : boolean := false;
    constant DUT_FRAMEPROCESS_ENABLED    : boolean := false;
    constant DUT_IMAGES_TESTENABLED      : boolean := false;
    constant DUT_SOBEL_TEST_ENABLED      : boolean := false;
    constant DUT_EMBOSS_TEST_ENABLED     : boolean := false;
    constant DUT_YCBCR_TEST_ENABLED      : boolean := false;
    constant DUT_HSV_TEST_ENABLED        : boolean := false;
    constant DUT_CC_TEST_ENABLED         : boolean := false;
    constant DUT_IMAGEKERNELS_ENABLED    : boolean := false;
    constant DUT_FILTERS_ENABLED         : boolean := false;
    constant DUT_FIFO_ENABLED            : boolean := false;
    constant DUT_RGBASSERTION_ENABLED    : boolean := false;
    -------------------------------------------------
    constant F_READ_COEFF_DATA           : boolean := true;
    -------------------------------------------------
    constant F_CGA_BRIGHT                : boolean := false;
    constant F_CGA_DARK                  : boolean := false;
    constant F_CGA_BALANCE               : boolean := false;
    constant F_CGA_GAIN_RED              : boolean := false;
    constant F_CGA_GAIN_GRE              : boolean := false;
    constant F_CGA_GAIN_BLU              : boolean := false;
    -------------------------------------------------
    constant F_TES                       : boolean := false;
    constant F_LUM                       : boolean := false;
    constant F_TRM                       : boolean := false;
    -------------------------------------------------
    constant F_RGB                       : boolean := true;
    constant F_SHP                       : boolean := false;
    constant F_BLU                       : boolean := false;
    constant F_EMB                       : boolean := false;
    constant F_YCC                       : boolean := false;
    constant F_SOB                       : boolean := false;
    constant F_CGA                       : boolean := false;
    constant F_HSV                       : boolean := false;
    constant F_HSL                       : boolean := false;
    constant L_BLU                       : boolean := false;
    -------------------------------------------------
    constant MASK_TRUE                   : boolean := true;
    constant MASK_FLSE                   : boolean := false;
    constant M_SOB_LUM                   : boolean := SelFrame(F_SOB,F_LUM,MASK_FLSE);
    constant M_SOB_TRM                   : boolean := SelFrame(F_SOB,F_TRM,MASK_FLSE);
    constant M_SOB_RGB                   : boolean := SelFrame(F_SOB,F_RGB,MASK_FLSE);
    constant M_SOB_SHP                   : boolean := SelFrame(F_SOB,F_SHP,MASK_FLSE);
    constant M_SOB_BLU                   : boolean := SelFrame(F_SOB,F_BLU,MASK_FLSE);
    constant M_SOB_YCC                   : boolean := SelFrame(F_SOB,F_YCC,MASK_FLSE);
    constant M_SOB_CGA                   : boolean := SelFrame(F_SOB,F_CGA,MASK_FLSE);
    constant M_SOB_HSV                   : boolean := SelFrame(F_SOB,F_HSV,MASK_FLSE);
    constant M_SOB_HSL                   : boolean := SelFrame(F_SOB,F_HSL,MASK_FLSE);
    -------------------------------------------------
    constant F_CGA_TO_CGA                : boolean := false;--IF:FILTER_K_CGA = F_KCGA_TO_LCGA
    constant F_CGA_TO_HSL                : boolean := false;
    constant F_CGA_TO_HSV                : boolean := false;
    constant F_CGA_TO_YCC                : boolean := false;
    constant F_CGA_TO_SHP                : boolean := false;
    constant F_CGA_TO_BLU                : boolean := false;
    -------------------------------------------------
    constant F_SHP_TO_SHP                : boolean := false;
    constant F_SHP_TO_HSL                : boolean := false;
    constant F_SHP_TO_HSV                : boolean := false;
    constant F_SHP_TO_YCC                : boolean := false;
    constant F_SHP_TO_CGA                : boolean := false;
    constant F_SHP_TO_BLU                : boolean := false;
    -------------------------------------------------
    constant F_BLU_TO_BLU                : boolean := false;
    constant F_BLU_TO_HSL                : boolean := false;
    constant F_BLU_TO_HSV                : boolean := false;
    constant F_BLU_TO_YCC                : boolean := false;
    constant F_BLU_TO_CGA                : boolean := false;--IF:FILTER_K_CGA = F_KCGA
    constant F_BLU_TO_SHP                : boolean := false;
    -------------------------------------------------
    constant F_BLUR_CHANNELS             : boolean := false;
    constant F_DITH_CHANNELS             : boolean := false;
    signal cHsvH                         : std_logic := lo;
    signal cHsvS                         : std_logic := lo;
    signal cHsvV                         : std_logic := hi;
    signal cHsv                          : std_logic_vector(2 downto 0);
    signal cYccY                         : std_logic := lo;
    signal cYccB                         : std_logic := lo;
    signal cYccR                         : std_logic := lo;
    signal cYcc                          : std_logic_vector(2 downto 0);
    signal iLumTh                        : integer := 0;
    signal iSobelTh                      : integer := 30;
    signal iHsvPerCh                     : integer := 0;--[0-cHsv,1-cHsvH,2-cHsvS,3-cHsvV]
    signal iYccPerCh                     : integer := 0;--[0-cYcc,1-cYccY,2-cYccB,3-cYccR]
    signal iFilterId                     : integer := 2;--[0-cYcc,1-cYccY,2-cYccB,3-cYccR]
    signal vChannelSelect                : integer := FILTER_K_CGA;
    signal blur_channels                 : blur_frames;
    -------------------------------------------------
begin
    -------------------------------------------------
    iAls.config  <= 0;
    cHsv                  <= std_logic_vector(to_unsigned(iHsvPerCh,3));
    cYcc                  <= std_logic_vector(to_unsigned(iYccPerCh,3));
    iVideoChannel         <= vChannelSelect;
    -------------------------------------------------
    --cHsv <= cHsvV & cHsvS & cHsvH;
    --cYcc <= cYccR & cYccB & cYccY;
    clk_gen(clk,clk_freq);
    process begin
        resetn  <= lo;
    wait for 2 ns;
        resetn  <= hi;
    wait;
    end process;
F_CGA_BRIGHT_FRAME_ENABLE: if (F_CGA_BRIGHT = true) generate
begin
kernel1ReadInst: read_kernel2_coefs
generic map (
    s_data_width    => s_data_width,
    input_file      => "ReadCoeffData")
port map (                  
    clk               => clk,
    reset             => resetn,
    iCord             => txCord,
    kSet1Out          => kCoeff);
end generate F_CGA_BRIGHT_FRAME_ENABLE;
READ_COEFF_DATA_ENABLE: if (F_READ_COEFF_DATA = true) generate
begin
kernel1ReadInst: read_kernel2_coefs
generic map (
    s_data_width    => s_data_width,
    input_file      => "ReadCoeffData")
port map (                  
    clk               => clk,
    reset             => resetn,
    iCord             => txCord,
    kSet1Out          => kCoeff);
end generate READ_COEFF_DATA_ENABLE;
FILTERS_TEST_ENABLED: if (DUT_FILTERS_TESTENABLED = true) generate
    constant init_type_Rgb   : type_Rgb := (valid => lo, red => (others => '0'), green => (others => '0'), blue => (others => '0'));
    signal enableWrite       : std_logic := lo;
    signal rgbRead           : channel;
    signal endOfFrame        : std_logic := lo;
    signal rgbImageFilters   : frameColors;
begin
ImageReadInst: image_read
generic map (
    i_data_width          => i_data_width,
    input_file            => readbmp)
port map (                  
    clk                   => clk,
    reset                 => resetn,
    oRgb                  => rgbRead,
    oCord                 => txCord,
    endOfFrame            => endOfFrame,
    olm                   => olm);
FiltersInst: filters
generic map(
    F_TES                 =>  F_TES,
    F_LUM                 =>  F_LUM,
    F_TRM                 =>  F_TRM,
    F_RGB                 =>  F_RGB,
    F_SHP                 =>  F_SHP,
    F_BLU                 =>  F_BLU,
    F_EMB                 =>  F_EMB,
    F_YCC                 =>  F_YCC,
    F_SOB                 =>  F_SOB,
    F_CGA                 =>  F_CGA,
    F_HSV                 =>  F_HSV,
    F_HSL                 =>  F_HSL,
    L_BLU                 =>  L_BLU,
    M_SOB_LUM             =>  M_SOB_LUM,
    M_SOB_TRM             =>  M_SOB_TRM,
    M_SOB_RGB             =>  M_SOB_RGB,
    M_SOB_SHP             =>  M_SOB_SHP,
    M_SOB_BLU             =>  M_SOB_BLU,
    M_SOB_YCC             =>  M_SOB_YCC,
    M_SOB_CGA             =>  M_SOB_CGA,
    M_SOB_HSV             =>  M_SOB_HSV,
    M_SOB_HSL             =>  M_SOB_HSL,
    F_BLUR_CHANNELS       =>  F_BLUR_CHANNELS,
    F_DITH_CHANNELS       =>  F_DITH_CHANNELS,
    img_width             =>  img_width,
    img_height            =>  img_width,
    adwrWidth             =>  adwrWidth,
    addrWidth             =>  addrWidth,
    s_data_width          =>  s_data_width,
    i_data_width          =>  i_data_width)
port map(
    clk                   => clk,
    rst_l                 => resetn,
    txCord                => txCord,
    iRgb                  => rgbRead,
    iLumTh                => iLumTh,
    iSobelTh              => iSobelTh,
    iVideoChannel         => iVideoChannel,
    iFilterId             => iFilterId,
    iHsvPerCh             => iHsvPerCh,
    iYccPerCh             => iYccPerCh,
    iAls                  => iAls,
    iKcoeff               => kCoeff,
    oKcoeff               => oKcoeff,
    edgeValid             => edgeValid,
    blur_channels         => blur_channels,
    oRgb                  => rgbImageFilters);

F_BLUR_CHANNELS_TEST_ENABLED : if (F_BLUR_CHANNELS = true) generate 

signal write_en_ditrgb1vx  : std_logic := lo;
signal write_en_ditRgb2vx  : std_logic := lo;
signal write_en_ditRgb3vx  : std_logic := lo;
signal write_en_blur1vx    : std_logic := lo;
signal write_en_blur2vx    : std_logic := lo;
signal write_en_blur3vx    : std_logic := lo;

begin 

write_en_ditrgb1vx <= hi when (blur_channels.ditRgb1vx.valid = hi);
write_en_ditRgb2vx <= hi when (blur_channels.ditRgb2vx.valid = hi);
write_en_ditRgb3vx <= hi when (blur_channels.ditRgb3vx.valid = hi);
write_en_blur1vx   <= hi when (blur_channels.blur1vx.valid = hi);
write_en_blur2vx   <= hi when (blur_channels.blur2vx.valid = hi);
write_en_blur3vx   <= hi when (blur_channels.blur3vx.valid = hi);

ditrgb1vx_Inst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "ditrgb1vx")
port map (                  
    pixclk                => clk,
    enableWrite           => write_en_ditrgb1vx,
    iRgb                  => blur_channels.ditRgb1vx);
ditrgb2vx_Inst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "ditrgb2vx")
port map (                  
    pixclk                => clk,
    enableWrite           => write_en_ditRgb2vx,
    iRgb                  => blur_channels.ditRgb2vx);
ditrgb3vx_Inst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "ditrgb3vx")
port map (                  
    pixclk                => clk,
    enableWrite           => write_en_ditRgb3vx,
    iRgb                  => blur_channels.ditRgb3vx);
blur1vx_Inst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "blur1vx")
port map (                  
    pixclk                => clk,
    enableWrite           => write_en_blur1vx,
    iRgb                  => blur_channels.blur1vx);
blur2vx_Inst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "blur2vx")
port map (                  
    pixclk                => clk,
    enableWrite           => write_en_blur2vx,
    iRgb                  => blur_channels.blur2vx);
blur3vx_Inst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "blur3vx")
port map (                  
    pixclk                => clk,
    enableWrite           => write_en_blur3vx,
    iRgb                  => blur_channels.blur3vx);
end generate F_BLUR_CHANNELS_TEST_ENABLED;
M_SOB_CGA_TEST_ENABLED : if (M_SOB_CGA = true) generate 
signal enableWrite                : std_logic;
begin
enableWrite <= hi when (rgbImageFilters.maskSobelCga.valid = hi);
ImageWriteCgainToshpSBInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "maskSobelCga")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.maskSobelCga);
end generate M_SOB_CGA_TEST_ENABLED;
M_SOB_TRM_TEST_ENABLED : if (M_SOB_TRM = true) generate 
signal enableWrite                : std_logic;
begin
enableWrite <= hi when (rgbImageFilters.maskSobelTrm.valid = hi);
ImageWriteMaskSobelTrmInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "maskSobelTrm")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.maskSobelTrm);
end generate M_SOB_TRM_TEST_ENABLED;  
M_SOB_HSL_TEST_ENABLED : if (M_SOB_HSL = true) generate 
signal enableWrite                : std_logic;
begin
enableWrite <= hi when (rgbImageFilters.maskSobelHsl.valid = hi);
ImageWriteMaskSobelHslInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "maskSobelHsl")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.maskSobelHsl);
end generate M_SOB_HSL_TEST_ENABLED;  
M_SOB_HSV_TEST_ENABLED : if (M_SOB_HSV = true) generate 
signal enableWrite                : std_logic;
begin
enableWrite <= hi when (rgbImageFilters.maskSobelHsv.valid = hi);
ImageWriteMaskSobelHsvInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "maskSobelHsv")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.maskSobelHsv);
end generate M_SOB_HSV_TEST_ENABLED;
M_SOB_YCC_TEST_ENABLED : if (M_SOB_YCC = true) generate 
signal enableWrite                : std_logic;
begin
enableWrite <= hi when (rgbImageFilters.maskSobelYcc.valid = hi);
ImageWriteMaskSobelYccInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "maskSobelYcc")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.maskSobelYcc);
end generate M_SOB_YCC_TEST_ENABLED;
M_SOB_SHP_TEST_ENABLED : if (M_SOB_SHP = true) generate 
signal enableWrite                : std_logic;
begin
enableWrite <= hi when (rgbImageFilters.maskSobelShp.valid = hi);
ImageWriteMaskSobelShpInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "maskSobelShp")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.maskSobelShp);
end generate M_SOB_SHP_TEST_ENABLED;
M_SOB_RGB_TEST_ENABLED : if (M_SOB_RGB = true) generate 
signal enableWrite                : std_logic;
begin
enableWrite <= hi when (rgbImageFilters.maskSobelRgb.valid = hi);
ImageWriteMaskSobelRgbInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "maskSobelRgb")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.maskSobelRgb);
end generate M_SOB_RGB_TEST_ENABLED;
M_SOB_LUM_TEST_ENABLED : if (M_SOB_LUM = true) generate 
signal enableWrite                : std_logic;
begin
enableWrite <= hi when (rgbImageFilters.maskSobelLum.valid = hi);
ImageWriteMaskSobelLumInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "maskSobelLum")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.maskSobelLum);
end generate M_SOB_LUM_TEST_ENABLED;
M_SOB_BLU_TEST_ENABLED : if (M_SOB_BLU = true) generate 
signal enableWrite                : std_logic;
begin
enableWrite <= hi when (rgbImageFilters.maskSobelBlu.valid = hi);
ImageWriteMaskSobelBluInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "maskSobelBlu")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.maskSobelBlu);
end generate M_SOB_BLU_TEST_ENABLED;
F_TRM_TEST_ENABLED : if (F_TRM = true) generate 
signal enableWrite                : std_logic;
begin
enableWrite <= hi when (rgbImageFilters.colorTrm.valid = hi);
ImageWriteCgainToshpInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "colorTrm")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.colorTrm);
end generate F_TRM_TEST_ENABLED;    
F_LUM_TEST_ENABLED : if (F_LUM = true) generate 
signal enableWrite                : std_logic;
begin
enableWrite <= hi when (rgbImageFilters.colorLmp.valid = hi);  
ImageWriteCgainToshpInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "colorLmp")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.colorLmp);
end generate F_LUM_TEST_ENABLED;
F_CGA_TO_SHP_TEST_ENABLED : if (F_CGA_TO_SHP = true) generate 
signal enableWrite                : std_logic;
begin
enableWrite <= hi when (rgbImageFilters.cgainToShp.valid = hi);
ImageWriteCgainToshpInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "cgainToShp")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.cgainToShp);
end generate F_CGA_TO_SHP_TEST_ENABLED;
F_CGA_TO_BLU_TEST_ENABLED : if (F_CGA_TO_BLU = true) generate 
signal enableWrite                : std_logic;
begin
enableWrite <= hi when (rgbImageFilters.cgainToBlu.valid = hi); 
ImageWritcgainTobluInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "cgainToBlu")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.cgainToBlu);
end generate F_CGA_TO_BLU_TEST_ENABLED;
F_CGA_TO_YCC_TEST_ENABLED : if (F_CGA_TO_YCC = true) generate 
signal enableWrite                : std_logic;
begin
enableWrite <= hi when (rgbImageFilters.cgainToYcbcr.valid = hi); 
ImageWritaetextRGBInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "cgainToYcbcr")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.cgainToYcbcr);
end generate F_CGA_TO_YCC_TEST_ENABLED;
F_CGA_TO_HSV_TEST_ENABLED : if (F_CGA_TO_HSV = true) generate 
signal enableWrite                : std_logic;
begin
enableWrite <= hi when (rgbImageFilters.cgainToHsv.valid = hi); 
ImageWriteCgainInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "cgainToHsv")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.cgainToHsv);
end generate F_CGA_TO_HSV_TEST_ENABLED;
F_CGA_TO_HSL_TEST_ENABLED : if (F_CGA_TO_HSL = true) generate 
signal enableWrite                : std_logic;
signal HslR                  : channel;
signal HslG                  : channel;
signal HslB                  : channel;
signal HslBB                 : channel;
begin
enableWrite <= hi when (rgbImageFilters.cgainToHsl.valid = hi);  
hsl_r_select_Inst: rgb_select
port map(
    clk      => clk,
    iPerCh   => 1,
    iRgb     => rgbImageFilters.cgainToHsl,
    oRgb     => HslR);
hsl_g_select_Inst: rgb_select
port map(
    clk      => clk,
    iPerCh   => 2,
    iRgb     => rgbImageFilters.cgainToHsl,
    oRgb     => HslG);
hsl_b_select_Inst: rgb_select
port map(
    clk      => clk,
    iPerCh   => 3,
    iRgb     => rgbImageFilters.cgainToHsl,
    oRgb     => HslB);
process(HslR,HslB) begin
    if (HslR.red = x"00" and HslR.valid = hi) then
            HslBB <= HslB;
    else
            HslBB.red       <= x"00";
            HslBB.green     <= x"00";
            HslBB.blue      <= x"00";
            HslBB.valid     <= HslB.valid;
    end if;
end process;
ImageWriteCgainToHslInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "CgainToHsl")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.cgainToHsl);
ImageWriteCgainTo_Hsl_H_Inst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "CgainToHsl_H")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => HslR);
ImageWriteCgainTo_Hsl_S_Inst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "CgainToHsl_S")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => HslG);
ImageWriteCgainTo_Hsl_L_Inst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "CgainToHsl_L")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => HslBB);
end generate F_CGA_TO_HSL_TEST_ENABLED;
F_CGA_TO_CGA_TEST_ENABLED : if (F_CGA_TO_CGA = true) generate 
signal enableWrite                : std_logic;
begin
enableWrite <= hi when (rgbImageFilters.cgainToCgain.valid = hi);
ImageWriteCgainToCgainInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "cgainToCgain")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.cgainToCgain);
end generate F_CGA_TO_CGA_TEST_ENABLED;
F_SOB_TEST_ENABLED : if (F_SOB = true) generate begin 
enableWrite <= hi when (rgbImageFilters.sobel.valid = hi); 
ImageWriteSobelInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "sobel")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.sobel);
end generate F_SOB_TEST_ENABLED;
F_TES_TEST_ENABLED : if (F_TES = true) generate begin 
enableWrite <= hi when (rgbImageFilters.tPattern.valid = hi);
ImageWritetPatternInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "tPattern")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.tPattern);
end generate F_TES_TEST_ENABLED;
F_RGB_TEST_ENABLED : if (F_RGB = true) generate 
signal rgb_enablewrite                : std_logic;
begin 
rgb_enablewrite <= hi when (rgbImageFilters.inrgb.valid = hi);
ImageWritesharptPatternInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "inrgb")
port map (                  
    pixclk                => clk,
    enableWrite           => rgb_enablewrite,
    iRgb                  => rgbImageFilters.inrgb);
end generate F_RGB_TEST_ENABLED;
F_SHP_TEST_ENABLED : if (F_SHP = true) generate 
signal shp_enablewrite                : std_logic;
begin 
shp_enablewrite <= hi when (rgbImageFilters.sharp.valid = hi);
ImageWritesharptPatternInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "sharp")
port map (                  
    pixclk                => clk,
    enableWrite           => shp_enablewrite,
    iRgb                  => rgbImageFilters.sharp);
end generate F_SHP_TEST_ENABLED;
F_HSV_TEST_ENABLED : if (F_HSV = true) generate 
signal enableWriteHsv       : std_logic := lo;

begin 
enableWriteHsv <= hi when (rgbImageFilters.hsv.valid = hi);

ImageWritehsvInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "hsv")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWriteHsv,
    iRgb                  => rgbImageFilters.hsv);
end generate F_HSV_TEST_ENABLED;
F_HSL_TEST_ENABLED : if (F_HSL = true) generate 
signal enableWriteHsl       : std_logic := lo;
begin 
enableWriteHsl <= hi when (rgbImageFilters.hsl.valid = hi);
ImageWritehsltPatternInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "hsl")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWriteHsl,
    iRgb                  => rgbImageFilters.hsl);
end generate F_HSL_TEST_ENABLED;
F_EMB_TEST_ENABLED : if (F_EMB = true) generate 
signal enablewriteemb       : std_logic := lo;
begin 
enablewriteemb <= hi when (rgbImageFilters.embos.valid = hi);
ImageWriteembostPatternInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "embos")
port map (                  
    pixclk                => clk,
    enableWrite           => enablewriteemb,
    iRgb                  => rgbImageFilters.embos);
end generate F_EMB_TEST_ENABLED;
F_BLU_TEST_ENABLED : if (F_BLU = true) generate 
signal enablewriteblu       : std_logic := lo;
begin 
enablewriteblu <= hi when (rgbImageFilters.blur.valid = hi);
ImageWriteblurtPatternInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "blur")
port map (                  
    pixclk                => clk,
    enableWrite           => enablewriteblu,
    iRgb                  => rgbImageFilters.blur);
end generate F_BLU_TEST_ENABLED;
F_CGA_TEST_ENABLED : if (F_CGA = true) generate 
signal enableWriteCga       : std_logic := lo;
begin 
enableWriteCga <= hi when (rgbImageFilters.cgain.valid = hi);
ImageWritecgaintPatternInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "cgain")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWriteCga,
    iRgb                  => rgbImageFilters.cgain);
end generate F_CGA_TEST_ENABLED;
F_YCC_TEST_ENABLED : if (F_YCC = true) generate 
signal enableWriteycbcr       : std_logic := lo;
begin 
enableWriteycbcr <= hi when (rgbImageFilters.ycbcr.valid = hi);
ImageWriteycbcrtPatternInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "ycbcr")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWriteycbcr,
    iRgb                  => rgbImageFilters.ycbcr);
end generate F_YCC_TEST_ENABLED;
F_SHP_TO_SHP_TEST_ENABLED : if (F_SHP_TO_SHP = true) generate 
signal enableWrite                : std_logic;
begin  
enableWrite <= hi when (rgbImageFilters.shpToShp.valid = hi);
ImageWriteCgainToCgainInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "shpToShp")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.shpToShp);
end generate F_SHP_TO_SHP_TEST_ENABLED;
F_SHP_TO_HSL_TEST_ENABLED : if (F_SHP_TO_HSL = true) generate 
signal enableWrite                : std_logic;
begin  
enableWrite <= hi when (rgbImageFilters.shpToHsl.valid = hi);
ImageWriteCgainToCgainInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "shpToHsl")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.shpToHsl);
end generate F_SHP_TO_HSL_TEST_ENABLED;
F_SHP_TO_HSV_TEST_ENABLED : if (F_SHP_TO_HSV = true) generate 
signal enableWrite                : std_logic;
begin  
enableWrite <= hi when (rgbImageFilters.shpToHsv.valid = hi);
ImageWriteCgainToCgainInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "shpToHsv")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.shpToHsv);
end generate F_SHP_TO_HSV_TEST_ENABLED;
F_SHP_TO_YCC_TEST_ENABLED : if (F_SHP_TO_YCC = true) generate 
signal enableWrite                : std_logic;
begin 
enableWrite <= hi when (rgbImageFilters.shpToYcbcr.valid = hi);
ImageWriteCgainToCgainInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "shpToYcbcr")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.shpToYcbcr);
end generate F_SHP_TO_YCC_TEST_ENABLED;
F_SHP_TO_CGA_TEST_ENABLED : if (F_SHP_TO_CGA = true) generate 
signal enableWrite                : std_logic;
begin  
enableWrite <= hi when (rgbImageFilters.shpToCgain.valid = hi);
ImageWriteCgainToCgainInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "shpToCgain")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.shpToCgain);
end generate F_SHP_TO_CGA_TEST_ENABLED;
F_SHP_TO_BLU_TEST_ENABLED : if (F_SHP_TO_BLU = true) generate 
signal enableWrite                : std_logic;
begin 
enableWrite <= hi when (rgbImageFilters.shpToBlu.valid = hi);
ImageWriteCgainToCgainInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "shpToBlu")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.shpToBlu);
end generate F_SHP_TO_BLU_TEST_ENABLED;
F_BLU_TO_BLU_TEST_ENABLED : if (F_BLU_TO_BLU = true) generate 
signal enableWrite                : std_logic;
begin  
enableWrite <= hi when (rgbImageFilters.bluToBlu.valid = hi);
ImageWriteCgainToCgainInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "bluToBlu")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.bluToBlu);
end generate F_BLU_TO_BLU_TEST_ENABLED;
F_BLU_TO_HSL_TEST_ENABLED : if (F_BLU_TO_HSL = true) generate 
signal enableWrite                : std_logic;
begin  
enableWrite <= hi when (rgbImageFilters.bluToHsl.valid = hi);
ImageWriteCgainToCgainInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "bluToHsl")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.bluToHsl);
end generate F_BLU_TO_HSL_TEST_ENABLED;
F_BLU_TO_HSV_TEST_ENABLED : if (F_BLU_TO_HSV = true) generate 
signal enableWrite                : std_logic;
begin  
enableWrite <= hi when (rgbImageFilters.bluToHsv.valid = hi);
ImageWriteCgainToCgainInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "bluToHsv")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.bluToHsv);
end generate F_BLU_TO_HSV_TEST_ENABLED;
F_BLU_TO_YCC_TEST_ENABLED : if (F_BLU_TO_YCC = true) generate 
signal enableWrite                : std_logic;
begin  
enableWrite <= hi when (rgbImageFilters.bluToYcc.valid = hi);
ImageWriteCgainToCgainInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "bluToYcc")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.bluToYcc);
end generate F_BLU_TO_YCC_TEST_ENABLED;
F_BLU_TO_CGA_TEST_ENABLED : if (F_BLU_TO_CGA = true) generate 
signal enableWrite                : std_logic;
begin  
enableWrite <= hi when (rgbImageFilters.bluToCga.valid = hi);
ImageWriteCgainToCgainInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "bluToCga")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.bluToCga);
end generate F_BLU_TO_CGA_TEST_ENABLED;
F_BLU_TO_SHP_TEST_ENABLED : if (F_BLU_TO_SHP = true) generate 
signal enableWrite                : std_logic;
begin  
enableWrite <= hi when (rgbImageFilters.bluToShp.valid = hi);
ImageWriteCgainToCgainInst: image_write
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "bluToShp")
port map (                  
    pixclk                => clk,
    enableWrite           => enableWrite,
    iRgb                  => rgbImageFilters.bluToShp);
end generate F_BLU_TO_SHP_TEST_ENABLED;
end generate FILTERS_TEST_ENABLED;
--FRAMEPROCESS_ENABLED : if (DUT_FRAMEPROCESS_ENABLED = true) generate
--frameProcess_test : dut_frame_process
--port map(
--    clk          => clk,
--    resetn       => resetn);
--end generate FRAMEPROCESS_ENABLED;
VFP_ENABLED : if (DUT_VFP_ENABLED = true) generate
    -- d5m input
    signal pixclk                : std_logic;
    signal ifval                 : std_logic;
    signal ilval                 : std_logic;
    signal idata                 : std_logic_vector(dataWidth - 1 downto 0);
    --tx channel
    signal rgb_m_axis_aclk       : std_logic;
    signal rgb_m_axis_aresetn    : std_logic :='0';
    signal rgb_m_axis_tvalid     : std_logic;
    signal rgb_m_axis_tlast      : std_logic;
    signal rgb_m_axis_tuser      : std_logic;
    signal rgb_m_axis_tready     : std_logic;
    signal rgb_m_axis_tdata      : std_logic_vector(s_data_width-1 downto 0);
    --rx channel
    signal rgb_s_axis_aclk       : std_logic;
    signal rgb_s_axis_aresetn    : std_logic :='0';
    signal rgb_s_axis_tready     : std_logic;
    signal rgb_s_axis_tvalid     : std_logic;
    signal rgb_s_axis_tuser      : std_logic;
    signal rgb_s_axis_tlast      : std_logic;
    signal rgb_s_axis_tdata      : std_logic_vector(s_data_width-1 downto 0);
    --destination channel
    signal m_axis_mm2s_aclk      : std_logic;
    signal m_axis_mm2s_aresetn   : std_logic :='0';
    signal m_axis_mm2s_tready    : std_logic;
    signal m_axis_mm2s_tvalid    : std_logic;
    signal m_axis_mm2s_tuser     : std_logic;
    signal m_axis_mm2s_tlast     : std_logic;
    signal m_axis_mm2s_tdata     : std_logic_vector(s_data_width-1 downto 0);
    signal m_axis_mm2s_tkeep     : std_logic_vector(2 downto 0);
    signal m_axis_mm2s_tstrb     : std_logic_vector(2 downto 0);
    signal m_axis_mm2s_tid       : std_logic_vector(0 downto 0);
    signal m_axis_mm2s_tdest     : std_logic_vector(0 downto 0);
    signal vfpconfig_aclk        : std_logic;
    signal vfpconfig_aresetn     : std_logic :='0';
    signal vfpconfig_awaddr      : std_logic_vector(C_vfpConfig_ADDR_WIDTH-1 downto 0);
    signal vfpconfig_awprot      : std_logic_vector(2 downto 0);
    signal vfpconfig_awvalid     : std_logic;
    signal vfpconfig_awready     : std_logic;
    signal vfpconfig_wdata       : std_logic_vector(conf_data_width-1 downto 0);
    signal vfpconfig_wstrb       : std_logic_vector((conf_data_width/8)-1 downto 0);
    signal vfpconfig_wvalid      : std_logic;
    signal vfpconfig_wready      : std_logic;
    signal vfpconfig_bresp       : std_logic_vector(1 downto 0);
    signal vfpconfig_bvalid      : std_logic;
    signal vfpconfig_bready      : std_logic;
    signal vfpconfig_araddr      : std_logic_vector(C_vfpConfig_ADDR_WIDTH-1 downto 0);
    signal vfpconfig_arprot      : std_logic_vector(2 downto 0);
    signal vfpconfig_arvalid     : std_logic;
    signal vfpconfig_arready     : std_logic;
    signal vfpconfig_rdata       : std_logic_vector(conf_data_width-1 downto 0);
    signal vfpconfig_rresp       : std_logic_vector(1 downto 0);
    signal vfpconfig_rvalid      : std_logic;
    signal vfpconfig_rready      : std_logic;
begin
    clk_gen(m_axis_mm2s_aclk, 150.00e6);
    clk_gen(rgb_s_axis_aclk, 150.00e6);
    clk_gen(rgb_m_axis_aclk, 150.00e6);
    -------------------------------------------------------------------------
    rgb_s_axis_tvalid    <= rgb_m_axis_tvalid;
    rgb_s_axis_tlast     <= rgb_m_axis_tlast;
    rgb_s_axis_tuser     <= rgb_m_axis_tuser;
    rgb_m_axis_tready    <= rgb_s_axis_tready;
    rgb_s_axis_tdata     <= rgb_m_axis_tdata;
    -------------------------------------------------------------------------
    process begin
        m_axis_mm2s_aresetn  <= '0';
        rgb_s_axis_aresetn   <= '0';
        rgb_m_axis_aresetn   <= '0';
    wait for 10 ns;
        m_axis_mm2s_aresetn  <= '1';
        rgb_s_axis_aresetn   <= '1';
        rgb_m_axis_aresetn   <= '1';   
    wait;
    end process;
dut_d5m_inst: dut_d5m
generic map(
    pixclk_freq                 => pixclk_freq,
    img_width                   => img_width,
    line_hight                  => line_hight,
    dataWidth                   => dataWidth)    
port map(
    pixclk                      => pixclk,
    ifval                       => ifval,
    ilval                       => ilval,
    idata                       => idata);
dut_configAxis_inst : dut_config_axis
generic map(
    aclk_freq                   => aclk_freq,
    C_vfpConfig_DATA_WIDTH      => C_vfpConfig_DATA_WIDTH,
    C_vfpConfig_ADDR_WIDTH      => C_vfpConfig_ADDR_WIDTH)    
port map(
    --video configuration       
    vfpconfig_aclk              => vfpconfig_aclk,
    vfpconfig_aresetn           => vfpconfig_aresetn,
    vfpconfig_awaddr            => vfpconfig_awaddr,
    vfpconfig_awprot            => vfpconfig_awprot,
    vfpconfig_awvalid           => vfpconfig_awvalid,
    vfpconfig_awready           => vfpconfig_awready,
    vfpconfig_wdata             => vfpconfig_wdata,
    vfpconfig_wstrb             => vfpconfig_wstrb,
    vfpconfig_wvalid            => vfpconfig_wvalid,
    vfpconfig_wready            => vfpconfig_wready,
    vfpconfig_bresp             => vfpconfig_bresp,
    vfpconfig_bvalid            => vfpconfig_bvalid,
    vfpconfig_bready            => vfpconfig_bready,
    vfpconfig_araddr            => vfpconfig_araddr,
    vfpconfig_arprot            => vfpconfig_arprot,
    vfpconfig_arvalid           => vfpconfig_arvalid,
    vfpconfig_arready           => vfpconfig_arready,
    vfpconfig_rdata             => vfpconfig_rdata,
    vfpconfig_rresp             => vfpconfig_rresp,
    vfpconfig_rvalid            => vfpconfig_rvalid,
    vfpconfig_rready            => vfpconfig_rready);
d5m_camera_inst: VFP_v1_0
generic map(
    revision_number             => revision_number,
    C_rgb_m_axis_TDATA_WIDTH    => C_rgb_m_axis_TDATA_WIDTH,
    C_rgb_m_axis_START_COUNT    => C_rgb_m_axis_START_COUNT,
    C_rgb_s_axis_TDATA_WIDTH    => C_rgb_s_axis_TDATA_WIDTH,
    C_m_axis_mm2s_TDATA_WIDTH   => C_m_axis_mm2s_TDATA_WIDTH,
    C_m_axis_mm2s_START_COUNT   => C_m_axis_mm2s_START_COUNT,
    C_vfpConfig_DATA_WIDTH      => C_vfpConfig_DATA_WIDTH,
    C_vfpConfig_ADDR_WIDTH      => C_vfpConfig_ADDR_WIDTH,
    i_data_width                => i_data_width,
    s_data_width                => s_data_width,
    b_data_width                => b_data_width,
    i_precision                 => i_precision,
    i_full_range                => i_full_range,
    conf_data_width             => conf_data_width,
    conf_addr_width             => conf_addr_width,
    img_width                   => img_width,
    dataWidth                   => dataWidth)
port map(
    -- d5m input
    pixclk                      => pixclk,
    ifval                       => ifval,
    ilval                       => ilval,
    idata                       => idata,
    --tx channel
    rgb_m_axis_aclk             => rgb_m_axis_aclk,
    rgb_m_axis_aresetn          => rgb_m_axis_aresetn,
    rgb_m_axis_tvalid           => rgb_m_axis_tvalid,
    rgb_m_axis_tlast            => rgb_m_axis_tlast,
    rgb_m_axis_tuser            => rgb_m_axis_tuser,
    rgb_m_axis_tready           => rgb_m_axis_tready,
    rgb_m_axis_tdata            => rgb_m_axis_tdata,
    --rx channel                
    rgb_s_axis_aclk             => rgb_s_axis_aclk,
    rgb_s_axis_aresetn          => rgb_s_axis_aresetn,
    rgb_s_axis_tready           => rgb_s_axis_tready,
    rgb_s_axis_tvalid           => rgb_s_axis_tvalid,
    rgb_s_axis_tuser            => rgb_s_axis_tuser,
    rgb_s_axis_tlast            => rgb_s_axis_tlast,
    rgb_s_axis_tdata            => rgb_s_axis_tdata,
    --destination channel       
    m_axis_mm2s_aclk            => m_axis_mm2s_aclk,
    m_axis_mm2s_aresetn         => m_axis_mm2s_aresetn,
    m_axis_mm2s_tready          => m_axis_mm2s_tready,
    m_axis_mm2s_tvalid          => m_axis_mm2s_tvalid,
    m_axis_mm2s_tuser           => m_axis_mm2s_tuser,
    m_axis_mm2s_tlast           => m_axis_mm2s_tlast,
    m_axis_mm2s_tdata           => m_axis_mm2s_tdata,
    m_axis_mm2s_tkeep           => m_axis_mm2s_tkeep,
    m_axis_mm2s_tstrb           => m_axis_mm2s_tstrb,
    m_axis_mm2s_tid             => m_axis_mm2s_tid,
    m_axis_mm2s_tdest           => m_axis_mm2s_tdest,
    --video configuration       
    vfpconfig_aclk              => vfpconfig_aclk,
    vfpconfig_aresetn           => vfpconfig_aresetn,
    vfpconfig_awaddr            => vfpconfig_awaddr,
    vfpconfig_awprot            => vfpconfig_awprot,
    vfpconfig_awvalid           => vfpconfig_awvalid,
    vfpconfig_awready           => vfpconfig_awready,
    vfpconfig_wdata             => vfpconfig_wdata,
    vfpconfig_wstrb             => vfpconfig_wstrb,
    vfpconfig_wvalid            => vfpconfig_wvalid,
    vfpconfig_wready            => vfpconfig_wready,
    vfpconfig_bresp             => vfpconfig_bresp,
    vfpconfig_bvalid            => vfpconfig_bvalid,
    vfpconfig_bready            => vfpconfig_bready,
    vfpconfig_araddr            => vfpconfig_araddr,
    vfpconfig_arprot            => vfpconfig_arprot,
    vfpconfig_arvalid           => vfpconfig_arvalid,
    vfpconfig_arready           => vfpconfig_arready,
    vfpconfig_rdata             => vfpconfig_rdata,
    vfpconfig_rresp             => vfpconfig_rresp,
    vfpconfig_rvalid            => vfpconfig_rvalid,
    vfpconfig_rready            => vfpconfig_rready);
end generate VFP_ENABLED;
------------------------------------------------------------------------------
-- END GENERATE
------------------------------------------------------------------------------
end behavioral;
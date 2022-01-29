--12302021 [12-30-2021]
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.constants_package.all;
use work.vpf_records.all;
use work.ports_package.all;
use work.vfp_pkg.all;
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
    signal edgeValid                     : std_logic;
    signal tx1Cord                       : coord;
    signal cordValues                    : cord;
    signal sCordValues                   : cord;
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
    constant vChannelSelect              : integer := FILTER_K_CGA;
    -------------------------------------------------
    constant F_HSV                       : boolean := false;
    constant F_HSL                       : boolean := false;
    constant HSV_L                       : boolean := false;
    constant HSV_1                       : boolean := false;
    constant HSV_2                       : boolean := false;
    constant HSV_3                       : boolean := false;
    constant HSV_4                       : boolean := false;
    constant HSVL1                       : boolean := false;
    constant HSVL2                       : boolean := false;
    constant HSVL3                       : boolean := false;
    constant HSVL4                       : boolean := false;
    constant RGB_FRAME_MIX               : boolean := false;
    -------------------------------------------------
    constant F_RE1                       : boolean := false;
    constant F_RE2                       : boolean := false;
    constant F_RE3                       : boolean := false;
    constant F_RE4                       : boolean := false;
    constant F_RE5                       : boolean := false;
    constant F_RE6                       : boolean := false;
    constant F_RE7                       : boolean := false;
    constant F_RE8                       : boolean := false;
    -------------------------------------------------
    constant F_TES                       : boolean := false;
    constant F_LUM                       : boolean := false;
    constant F_TRM                       : boolean := false;
    constant F_OHS                       : boolean := false; --colorhsl
    constant L_AVG                       : boolean := false;
    constant L_OBJ                       : boolean := false;
    constant L_SPC                       : boolean := false; --init_channel
    constant L_HIS                       : boolean := false;
    -------------------------------------------------
    constant F_SHP                       : boolean := false;
    constant F_BLU                       : boolean := false;
    constant F_EMB                       : boolean := false;
    constant F_SOB                       : boolean := false;
    constant L_BLU                       : boolean := false;-- synBlur
    constant L_D1T                       : boolean := false; 
    constant L_B1T                       : boolean := false;
    -------------------------------------------------
    constant F_RGB                       : boolean := false;
    constant F_YCC                       : boolean := false;
    constant F_CGA                       : boolean := false;
    constant L_SHP                       : boolean := false; -- synSharp
    constant L_CGA                       : boolean := false; -- synCgain
    constant L_YCC                       : boolean := true; 
    -------------------------------------------------
    constant MASK_TRUE                   : boolean := true;
    constant MASK_FLSE                   : boolean := false;
    constant M_SOB_LUM                   : boolean := selframe(F_SOB,F_TRM,MASK_FLSE);
    constant M_SOB_TRM                   : boolean := selframe(F_SOB,F_TRM,MASK_FLSE);
    constant M_SOB_RGB                   : boolean := selframe(F_SOB,F_RGB,MASK_FLSE);
    constant M_SOB_SHP                   : boolean := selframe(F_SOB,F_SHP,MASK_FLSE);
    constant M_SOB_BLU                   : boolean := selframe(F_SOB,F_TRM,MASK_FLSE);
    constant M_SOB_YCC                   : boolean := selframe(F_SOB,F_YCC,MASK_FLSE);
    constant M_SOB_CGA                   : boolean := selframe(F_SOB,F_CGA,MASK_FLSE);
    constant M_SOB_HSV                   : boolean := selframe(F_SOB,F_HSV,MASK_FLSE);
    constant M_SOB_HSL                   : boolean := selframe(F_SOB,F_HSL,MASK_FLSE);
    -------------------------------------------------
    constant PER_FRE_TRUE                : boolean := PerFrame(Per_Frame(vChannelSelect,FILTER_K_CGA),F_CGA,F_SHP);
    constant F_CGA_TO_CGA                : boolean := PER_FRE_TRUE;--IF:FILTER_K_CGA = F_KCGA_TO_LCGA
    constant F_CGA_TO_HSL                : boolean := false;
    constant F_CGA_TO_HSV                : boolean := false;
    constant F_CGA_TO_YCC                : boolean := false;
    constant F_CGA_TO_SHP                : boolean := false;
    constant F_CGA_TO_BLU                : boolean := false;
    -------------------------------------------------
    constant F_SHP_TO_SHP                : boolean := PER_FRE_TRUE;
    constant F_SHP_TO_HSL                : boolean := false;
    constant F_SHP_TO_HSV                : boolean := false;
    constant F_SHP_TO_YCC                : boolean := PER_FRE_TRUE;
    constant F_SHP_TO_CGA                : boolean := false;
    constant F_SHP_TO_BLU                : boolean := false;
    -------------------------------------------------
    constant F_BLU_TO_BLU                : boolean := false;
    constant F_BLU_TO_HSL                : boolean := false;
    constant F_BLU_TO_HSV                : boolean := false;
    constant F_BLU_TO_YCC                : boolean := false;
    constant F_BLU_TO_CGA                : boolean := PER_FRE_TRUE;--IF:FILTER_K_CGA = F_KCGA
    constant F_BLU_TO_SHP                : boolean := false;
    -------------------------------------------------
    constant F_BLUR_CHANNELS             : boolean := false;
    constant F_DITH_CHANNELS             : boolean := false;
    -------------------------------------------------
    -- FILTER_K_CGA = F_SHP_TO_YCC F_SHP_TO_SHP F_BLU_TO_CGA F_CGA_TO_CGA
    -------------------------------------------------
    signal cHsvH                         : std_logic := lo;
    signal cHsvS                         : std_logic := lo;
    signal cHsvV                         : std_logic := hi;
    signal cHsv                          : std_logic_vector(2 downto 0);
    signal cYccY                         : std_logic := lo;
    signal cYccB                         : std_logic := lo;
    signal cYccR                         : std_logic := lo;
    signal cYcc                          : std_logic_vector(2 downto 0);
    signal iLumTh                        : integer := 5;
    signal iSobelTh                      : integer := 100;
    signal iHsvPerCh                     : integer := 0;--[0-cHsv,1-cHsvH,2-cHsvS,3-cHsvV]
    signal iYccPerCh                     : integer := 0;--[0-cYcc,1-cYccY,2-cYccB,3-cYccR]
    signal iFilterId                     : integer := 2;--[0-cYcc,1-cYccY,2-cYccB,3-cYccR]
    signal blur_channels                 : blur_frames;
    signal wr_image_rgb_o                : channel;
    signal wr_image_rgb_i                : channel;
    signal enWrite                       : std_logic := lo;
    -------------------------------------------------
begin
    -------------------------------------------------
    iAls.config           <= 3;
    iAls.k1               <= std_logic_vector(to_unsigned(40,32));
    iAls.k2               <= std_logic_vector(to_unsigned(248,32));
    iAls.k3               <= std_logic_vector(to_unsigned(248,32));
    iAls.k4               <= std_logic_vector(to_unsigned(8,32));
    iAls.k5               <= std_logic_vector(to_unsigned(48,32));
    iAls.k6               <= std_logic_vector(to_unsigned(232,32));
    iAls.k7               <= std_logic_vector(to_unsigned(24,32));
    iAls.k8               <= std_logic_vector(to_unsigned(232,32));
    iAls.k9               <= std_logic_vector(to_unsigned(40,32));
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
    iCord             => tx1Cord,
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
    iCord             => tx1Cord,
    kSet1Out          => kCoeff);
end generate READ_COEFF_DATA_ENABLE;
FILTERS_TEST_ENABLED: if (DUT_FILTERS_TESTENABLED = true) generate
    signal enableWrite           : std_logic := lo;
    signal rgb1Read              : channel;
    signal rgb2Read              : channel;
    signal rgb_histo             : channel;
    signal rgbImageFilters       : frameColors;
    signal rgbColors             : type_RgbArray(0 to 7);
begin
image_read_inst: read_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "output_image")
port map (                  
    pixclk                => clk,
    oCord                 => tx1Cord,
    oRgb                  => rgb1Read);
cordValues.x      <= to_integer((unsigned(tx1Cord.x)));
cordValues.y      <= to_integer((unsigned(tx1Cord.y)));
sync_cord_inst: sync_cord
generic map (
    cordDelay            => 34)
port map (                  
    clk                  => clk,
    reset                => enWrite,
    iCord                => cordValues,
    oCord                => sCordValues);
FiltersInst: filters
generic map(
    HSV_L                 =>  HSV_L,
    HSV_1                 =>  HSV_1,
    HSV_2                 =>  HSV_2,
    HSV_3                 =>  HSV_3,
    HSV_4                 =>  HSV_4,
    HSVL1                 =>  HSVL1,
    HSVL2                 =>  HSVL2,
    HSVL3                 =>  HSVL3,
    HSVL4                 =>  HSVL4,
    F_RE1                 =>  F_RE1,
    F_RE2                 =>  F_RE2,
    F_RE3                 =>  F_RE3,
    F_RE4                 =>  F_RE4,
    F_RE5                 =>  F_RE5,
    F_RE6                 =>  F_RE6,
    F_RE7                 =>  F_RE7,
    F_RE8                 =>  F_RE8,
    F_TES                 =>  F_TES,
    F_LUM                 =>  F_LUM,
    F_TRM                 =>  F_TRM,
    F_RGB                 =>  F_RGB,
    F_OHS                 =>  F_OHS,
    F_SHP                 =>  F_SHP,
    F_BLU                 =>  F_BLU,
    F_EMB                 =>  F_EMB,
    F_YCC                 =>  F_YCC,
    F_SOB                 =>  F_SOB,
    F_CGA                 =>  F_CGA,
    F_HSV                 =>  F_HSV,
    F_HSL                 =>  F_HSL,
    L_BLU                 =>  L_BLU,
    L_SHP                 =>  L_SHP,
    L_AVG                 =>  L_AVG,
    L_OBJ                 =>  L_OBJ,
    L_D1T                 =>  L_D1T,
    L_B1T                 =>  L_B1T,
    L_CGA                 =>  L_CGA,
    L_YCC                 =>  L_YCC,
    L_HIS                 =>  L_HIS,
    L_SPC                 =>  L_SPC,
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
    txCord                => tx1Cord,
    iRgb                  => rgb1Read,
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
L_HIS_ENABLE: if (L_HIS = true) generate
begin
write_valid_rgb_histogram_inst: write_valid_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => Histrograms,
    input_file            => Histrograms,
    output_file           => "rgb_histogram")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.histogram);
end generate L_HIS_ENABLE;
L_SPC_ENABLE: if (L_SPC = true) generate begin
init_channel_0_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "init_channel_0")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.space.ch0);
init_channel_1_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "init_channel_1")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.space.ch1);
init_channel_2_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "init_channel_2")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.space.ch2);
init_channel_3_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "init_channel_3")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.space.ch3);
init_channel_4_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "init_channel_4")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.space.ch4);
init_channel_5_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "init_channel_5")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.space.ch5);
init_channel_6_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "init_channel_6")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.space.ch6);
init_channel_7_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "init_channel_7")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.space.ch7);
end generate L_SPC_ENABLE;
LOGS_INST: write_image_filter_logs
generic map (
    F_TES                 => F_TES,
    F_LUM                 => F_LUM,
    F_TRM                 => F_TRM,
    F_RGB                 => F_RGB,
    F_SHP                 => F_SHP,
    F_BLU                 => F_BLU,
    F_EMB                 => F_EMB,
    F_YCC                 => F_YCC,
    F_SOB                 => F_SOB,
    F_CGA                 => F_CGA,
    F_HSV                 => F_HSV,
    F_HSL                 => F_HSL,
    L_BLU                 => L_BLU,
    L_SHP                 => L_SHP,
    L_AVG                 => L_AVG,
    L_OBJ                 => L_OBJ,
    L_D1T                 => L_D1T,
    L_B1T                 => L_B1T,
    L_CGA                 => L_CGA,
    L_YCC                 => L_YCC,
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "logs")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters);
RGB_FRAME_MIX_ENABLED : if (RGB_FRAME_MIX = true) generate 
begin
rgbimageframes_inst: frame_remake
port map (
    clk                   => clk,
    reset                 => resetn,
    iEdgeValid            => edgeValid,
    iRgb                  => rgbImageFilters);
end generate RGB_FRAME_MIX_ENABLED;
L_CGA_ENABLED : if (L_CGA = true) generate 
begin
L_CGA_INST: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "syncgain")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.synCgain);
end generate L_CGA_ENABLED;
SYN_SHARP_ENABLED : if (L_SHP = true) generate 
begin
rgbimageframes_inst: frame_remake
port map (
    clk                   => clk,
    reset                 => resetn,
    iEdgeValid            => edgeValid,
    iRgb                  => rgbImageFilters);
L_SHP_INST: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "synSharp")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.synSharp);
end generate SYN_SHARP_ENABLED;
D1T_ENABLED : if (L_D1T = true) generate 
L_D1T_INST: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "l_d1t")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.d1t);
end generate D1T_ENABLED;
F_BLUR_CHANNELS_TEST_ENABLED : if (F_BLUR_CHANNELS = true) generate 
begin 
BLUR1VX_INST: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "blur1vx")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.blur1vx);
BLUR2VX_INST: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "blur2vx")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.blur2vx);
BLUR3VX_INST: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "blur3vx")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.blur3vx);
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
M_SOB_HSL_TEST_ENABLED : if (M_SOB_HSL = true) generate begin
ImageWriteMaskSobelHslInst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "maskSobelHsl")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.maskSobelHsl);
end generate M_SOB_HSL_TEST_ENABLED;  
M_SOB_HSV_TEST_ENABLED : if (M_SOB_HSV = true) generate begin
ImageWritemaskSobelHsvInst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "maskSobelHsv")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.maskSobelHsv);
end generate M_SOB_HSV_TEST_ENABLED;
M_SOB_YCC_TEST_ENABLED : if (M_SOB_YCC = true) generate begin
ImageWriteMaskSobelYccInst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "maskSobelYcc")
port map (                  
    pixclk                => clk,
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
M_SOB_LUM_TEST_ENABLED : if (M_SOB_LUM = true) generate begin
L_M1T_INST: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "maskSobelLum")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.maskSobelLum);
end generate M_SOB_LUM_TEST_ENABLED;
M_SOB_BLU_TEST_ENABLED : if (M_SOB_BLU = true) generate begin
L_M2T_INST: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "maskSobelBlu")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.maskSobelBlu);
end generate M_SOB_BLU_TEST_ENABLED;
F_TRM_TEST_ENABLED : if (F_TRM = true) generate  
begin
F_TRM_INST: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "colortrm")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.colorTrm);
end generate F_TRM_TEST_ENABLED;
COLORHSL_TEST_ENABLED : if (F_OHS = true) generate  
re1color_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "colorhsl")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.colorhsl);
end generate COLORHSL_TEST_ENABLED;
F_RE1_TEST_ENABLED : if (F_RE1 = true) generate  
re1color_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "re1color")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.re1color);
end generate F_RE1_TEST_ENABLED;
F_RE2_TEST_ENABLED : if (F_RE2 = true) generate
re2color_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "re2color")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.re2color);
re3color_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "re3color")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.re3color);
re4color_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "re4color")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.re4color);
re5color_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "re5color")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.re5color);
re6color_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "re6color")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.re6color);
re7color_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "re7color")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.re7color);
re8color_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "re8color")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.re8color);
end generate F_RE2_TEST_ENABLED;   
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
signal enableWrite        : std_logic;
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
begin
F_CGA_TO_CGA_INST: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "cgainToCgain")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.cgainToCgain);
end generate F_CGA_TO_CGA_TEST_ENABLED;
F_SOB_TEST_ENABLED : if (F_SOB = true) generate begin 
sobel_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "sobel")
port map (                  
    pixclk                => clk,
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
begin 
inrgb_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "inrgb")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.inrgb);
end generate F_RGB_TEST_ENABLED;
L_AVG_ENABLED : if (L_AVG = true) generate 
signal cAvgRgb             : channel;
begin 
coloravgInst: color_avg
generic map (
    i_data_width          => i_data_width)
port map (                  
    clk                   => clk,
    reset                 => resetn,
    iRgb                  => rgb1Read,
    oRgb                  => cAvgRgb);
L_AVG_INST: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "cavgrgb")
port map (                  
    pixclk                => clk,
    iRgb                  => cAvgRgb);
L_AVG2_INST: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "L_AVG")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.synRgbag);
end generate L_AVG_ENABLED;
C_OBJ_ENABLED : if (L_OBJ = true) generate 
begin
rgbremix_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "rgbremix")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.eObject);
synlcobj_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "a_syn_lcobj")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.synLcobj);
end generate C_OBJ_ENABLED;
F_SHP_TEST_ENABLED : if (F_SHP = true) generate 
begin 
sharp_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "sharp")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.sharp);
end generate F_SHP_TEST_ENABLED;
F_HSV_TEST_ENABLED : if (F_HSV = true) generate begin 
hsv_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "hsv")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.hsv);
end generate F_HSV_TEST_ENABLED;
HSV_L_TEST_ENABLED : if (HSV_L = true) generate begin 
hvl_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "hsvl")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.hsvl);
end generate HSV_L_TEST_ENABLED;
F_HSL_TEST_ENABLED : if (F_HSL = true) generate begin 
hsl_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "hsl")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.hsl);
end generate F_HSL_TEST_ENABLED;
HSV_1_TEST_ENABLED : if (HSV_1 = true) generate begin 
hsl1_range_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "hsl_1range")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.hsl1_range);
end generate HSV_1_TEST_ENABLED;
HSV_2_TEST_ENABLED : if (HSV_2 = true) generate begin 
hsl2_range_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "hsl_2range")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.hsl2_range);
end generate HSV_2_TEST_ENABLED;
HSV_3_TEST_ENABLED : if (HSV_3 = true) generate begin 
hsl3_range_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "hsl_3range")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.hsl3_range);
end generate HSV_3_TEST_ENABLED;
HSV_4_TEST_ENABLED : if (HSV_4 = true) generate begin 
hsl4_range_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "hsl_4range")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.hsl4_range);
end generate HSV_4_TEST_ENABLED;
HSVL1_TEST_ENABLED : if (HSVL1 = true) generate begin 
hsll1range_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "hsvl_1range")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.hsll1range);
end generate HSVL1_TEST_ENABLED;
HSVL2_TEST_ENABLED : if (HSVL2 = true) generate begin 
hsll2range_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "hsvl_2range")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.hsll2range);
end generate HSVL2_TEST_ENABLED;
HSVL3_TEST_ENABLED : if (HSVL3 = true) generate begin 
hsll3range_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "hsvl_3range")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.hsll3range);
end generate HSVL3_TEST_ENABLED;
HSVL4_TEST_ENABLED : if (HSVL4 = true) generate begin 
hsll4range_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "hsvl_4range")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.hsll4range);
end generate HSVL4_TEST_ENABLED;
F_EMB_TEST_ENABLED : if (F_EMB = true) generate 
begin 
embos_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "embos")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.embos);
end generate F_EMB_TEST_ENABLED;
F_BLU_TEST_ENABLED : if (F_BLU = true) generate 
begin 
blur_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "blur")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.blur);
end generate F_BLU_TEST_ENABLED;
F_CGA_TEST_ENABLED : if (F_CGA = true) generate 
begin 
cgain_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "cgain")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.cgain);
end generate F_CGA_TEST_ENABLED;
L_BLU_TEST_ENABLED : if (L_BLU = true) generate 
begin 
synblur_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "l_blure")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.synBlur);
end generate L_BLU_TEST_ENABLED;
L_YCC_TEST_ENABLED : if (L_YCC = true) generate 
begin 
ycbcr_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "fixed_ycbcr")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.synYcbcr);
end generate L_YCC_TEST_ENABLED;
F_YCC_TEST_ENABLED : if (F_YCC = true) generate 
begin 
ycbcr_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "ycbcr")
port map (                  
    pixclk                => clk,
    iRgb                  => rgbImageFilters.ycbcr);
end generate F_YCC_TEST_ENABLED;
F_SHP_TO_SHP_TEST_ENABLED : if (F_SHP_TO_SHP = true) generate begin  
F_SHP_TO_SHP_INST: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "shp_to_shp")
port map (                  
    pixclk                => clk,
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
begin 
shptoycbcr_image_inst: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "shp_to_ycbcr")
port map (                  
    pixclk                => clk,
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
begin  
F_BLU_TO_BLU_INST: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "blur_to_blur")
port map (                  
    pixclk                => clk,
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
begin  
F_BLU_TO_CGA_INST: write_image
generic map (
    enImageText           => true,
    enImageIndex          => true,
    i_data_width          => i_data_width,
    test                  => testFolder,
    input_file            => readbmp,
    output_file           => "blur_to_cga")
port map (                  
    pixclk                => clk,
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
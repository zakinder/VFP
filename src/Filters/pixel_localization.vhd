-------------------------------------------------------------------------------
--
-- Filename    : pixel_localization.vhd
-- Create Date : 05062019 [05-06-2019]
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
use work.vfp_pkg.all;
use work.ports_package.all;
entity pixel_localization is
generic (
    neighboring_pixel_threshold : integer := 255;
    img_width                   : integer := 1920;
    i_data_width                : integer := 8);
port (
    clk                         : in  std_logic;
    reset                       : in  std_logic;
    iRgb                        : in channel;
    txCord                      : in coord;
    oRgb                        : out channel);
end pixel_localization;
architecture behavioral of pixel_localization is
------------------------------------------------------------------------------

  signal pixel_threshold_2       : integer  := neighboring_pixel_threshold;   -- [60% with 20] [70% with 40] 
  signal tpd1                    : k_3by3;
  signal tpd2                    : k_3by3;
  signal tpd3                    : k_3by3;
  signal tpd4                    : k_3by3;
  signal row1                    : k_9by9;
  signal row2                    : k_9by9;
  signal row3                    : k_9by9;
  signal row4                    : k_9by9;
  signal row5                    : k_9by9;
  signal row6                    : k_9by9;
  signal row7                    : k_9by9;
  signal row8                    : k_9by9;
  signal row9                    : k_9by9;
  signal rgb_pixels_9x9          : k_9by9_rgb;
  signal rgb_9x9                 : k_9by9_rgb_integers;
  signal rgb_9x9_delta           : filters_size_rgb_integers;
  signal rgb_9x9_detect          : filters_size_rgb_detect;
  signal pix_9x9                 : k_9by9_rgb_integers;
  signal sum                     : rgb_pixel_sum_values;
  signal v1TapRGB0x              : std_logic_vector(23 downto 0) := (others => '0');
  signal v1TapRGB1x              : std_logic_vector(23 downto 0) := (others => '0');
  signal v1TapRGB2x              : std_logic_vector(23 downto 0) := (others => '0');
  signal v1TapRGB3x              : std_logic_vector(23 downto 0) := (others => '0'); 
  signal v1TapRGB4x              : std_logic_vector(23 downto 0) := (others => '0');
  signal v1TapRGB5x              : std_logic_vector(23 downto 0) := (others => '0');
  signal v1TapRGB6x              : std_logic_vector(23 downto 0) := (others => '0');
  signal v1TapRGB7x              : std_logic_vector(23 downto 0) := (others => '0');
  signal v_tap_0x                : std_logic_vector(23 downto 0) := (others => '0');
  signal v_tap_1x                : std_logic_vector(23 downto 0) := (others => '0');
  signal v_tap_2x                : std_logic_vector(23 downto 0) := (others => '0');
  signal v_tap_3x                : std_logic_vector(23 downto 0) := (others => '0'); 
  signal v_tap_4x                : std_logic_vector(23 downto 0) := (others => '0');
  signal v_tap_5x                : std_logic_vector(23 downto 0) := (others => '0');
  signal v_tap_6x                : std_logic_vector(23 downto 0) := (others => '0');
  signal v_tap_7x                : std_logic_vector(23 downto 0) := (others => '0');
  signal v_tap_8x                : std_logic_vector(23 downto 0) := (others => '0');
  signal tp1Valid                : std_logic;
  signal tp2Valid                : std_logic;
  signal tp3Valid                : std_logic;
  signal pixels_1_81_enabled     : std_logic:= '0';
  --==============================================================================================
  signal Rgb1                    : channel;
  signal Rgb2                    : channel;
  signal Rgb3                    : channel;
  signal tpd_rgb                 : channel;
  signal red_on                  : rgbSumProd;
  signal gre_on                  : rgbSumProd;
  signal blu_on                  : rgbSumProd;
  signal red_select              : rgb_sum_prod;
  signal gre_select              : rgb_sum_prod;
  signal blu_select              : rgb_sum_prod;
  signal red_add                 : rgb_add_range;
  signal gre_add                 : rgb_add_range;
  signal blu_add                 : rgb_add_range;
  signal red_detect              : rgb_detect_kernal;
  signal gre_detect              : rgb_detect_kernal;
  signal blu_detect              : rgb_detect_kernal;
  --==============================================================================================
  signal syn1KernalData_red      : kkkCoeff;
  signal syn2KernalData_red      : kkkCoeff;
  signal syn3KernalData_red      : kkkCoeff;
  signal syn4KernalData_red      : kkkCoeff;
  signal syn5KernalData_red      : kkkCoeff;
  signal synaKernalData_red      : kkkCoeff;
  signal synbKernalData_red      : kkkCoeff;
  signal syn6KernalData_red      : kkkCoeff;
  --==============================================================================================
  signal syn1KernalData_gre      : kkkCoeff;
  signal syn2KernalData_gre      : kkkCoeff;
  signal syn3KernalData_gre      : kkkCoeff;
  signal syn4KernalData_gre      : kkkCoeff;
  signal syn5KernalData_gre      : kkkCoeff;
  signal synaKernalData_gre      : kkkCoeff;
  signal synbKernalData_gre      : kkkCoeff;
  signal syn6KernalData_gre      : kkkCoeff;
  --==============================================================================================
  signal syn1KernalData_blu      : kkkCoeff;
  signal syn2KernalData_blu      : kkkCoeff;
  signal syn3KernalData_blu      : kkkCoeff;
  signal syn4KernalData_blu      : kkkCoeff;
  signal syn5KernalData_blu      : kkkCoeff;
  signal synaKernalData_blu      : kkkCoeff;
  signal synbKernalData_blu      : kkkCoeff;
  signal syn6KernalData_blu      : kkkCoeff;
  --==============================================================================================
  signal rgbSyncValid            : std_logic_vector(31 downto 0)  := x"00000000";
  signal crd_s1,crd_s2,crd_s3,crd_s4,crd_s5        : cord;
  signal crd_s6,crd_s7,crd_s8,crd_s9,crd_s10       : cord;
  signal crd_s11,crd_s12,crd_s13,crd_s14,crd_s15   : cord;
  signal crd_s16,crd_s17,crd_s18,crd_s19,crd_s20   : cord;
  signal crd_s21,crd_s22,crd_s23,crd_s24,crd_s25   : cord;
  signal crd_s26,crd_s27,crd_s28,crd_s29,crd_s30   : cord;
  signal crd_s31,crd_s32,crd_s33,crd_s34,crd_s35   : cord;
  signal crd_s36,crd_s37,crd_s38,crd_s39,crd_s40   : cord;
begin 
process (clk) begin
    if rising_edge(clk) then
        crd_s1.x      <= to_integer((unsigned(txCord.x)));
        crd_s1.y      <= to_integer((unsigned(txCord.y)));
        crd_s2        <= crd_s1;
        crd_s3        <= crd_s2;
        crd_s4        <= crd_s3;
        crd_s5        <= crd_s4;
        crd_s6        <= crd_s5;
        crd_s7        <= crd_s6;
        crd_s8        <= crd_s7;
        crd_s9        <= crd_s8;
        crd_s10       <= crd_s9;
        crd_s11       <= crd_s10;
        crd_s12       <= crd_s11;
        crd_s13       <= crd_s12;
        crd_s14       <= crd_s13;
        crd_s15       <= crd_s14;
        crd_s16       <= crd_s15;
        crd_s17       <= crd_s16;
        crd_s18       <= crd_s17;
        crd_s19       <= crd_s18;
        crd_s20       <= crd_s19;
        crd_s21       <= crd_s20;
        crd_s22       <= crd_s21;
        crd_s23       <= crd_s22;
        crd_s24       <= crd_s23;
        crd_s25       <= crd_s24;
        crd_s26       <= crd_s25;
        crd_s27       <= crd_s26;
        crd_s28       <= crd_s27;
        crd_s29       <= crd_s28;
        crd_s30       <= crd_s29;
        crd_s31       <= crd_s30;
        crd_s32       <= crd_s31;
        crd_s33       <= crd_s32;
        crd_s34       <= crd_s33;
        crd_s35       <= crd_s34;
        crd_s36       <= crd_s35;
        crd_s37       <= crd_s36;
        crd_s38       <= crd_s37;
        crd_s39       <= crd_s38;
        crd_s40       <= crd_s39;
    end if;
end process;
rgb_syncr_inst  : sync_frames
generic map(
    pixelDelay => 14)
port map(
    clk        => clk,
    reset      => reset,
    iRgb       => iRgb,
    oRgb       => Rgb3);
    
    
    
RGB_1_Inst: rgb_4taps
generic map(
    img_width       => img_width,
    tpDataWidth     => 24)
port map(
    clk             => clk,
    rst_l           => reset,
    iRgb            => iRgb,
    tpValid         => tp1Valid,
    tp0             => v1TapRGB0x,
    tp1             => v1TapRGB1x,
    tp2             => v1TapRGB2x,
    tp3             => v1TapRGB3x);
--RGB_2_Inst: rgb_8taps
--generic map(
--    img_width       => img_width,
--    tpDataWidth     => 24)
--port map(
--    clk             => clk,
--    rst_l           => reset,
--    iRgb            => iRgb,
--    tpValid         => tp2Valid,
--    tp0             => v_tap_0x,
--    tp1             => v_tap_1x,
--    tp2             => v_tap_2x,
--    tp3             => v_tap_3x,
--    tp4             => v_tap_4x,
--    tp5             => v_tap_5x,
--    tp6             => v_tap_6x,
--    tp7             => v_tap_7x,
--    tp8             => v_tap_8x);
    
    
--RGB_3_Inst: rgb_4_taps
--generic map(
--    img_width       => img_width,
--    tpDataWidth     => 24)
--port map(
--    clk             => clk,
--    rst_l           => reset,
--    iRgb            => iRgb,
--    tpValid         => tp3Valid,
--    tap_1           => v_tap_0x,
--    tap_2           => v_tap_1x,
--    tap_3           => v_tap_2x,
--    tap_4           => v_tap_3x);
    
    
RGB_4_Inst: rgb_3_taps
generic map(
    img_width       => img_width,
    tpDataWidth     => 24)
port map(
    clk             => clk,
    rst_l           => reset,
    iRgb            => iRgb,
    tpValid         => tp3Valid,
    tap_1           => v_tap_0x,
    tap_2           => v_tap_1x,
    tap_3           => v_tap_2x);
    
process (clk) begin
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
        rgbSyncValid(11) <= rgbSyncValid(10);
        rgbSyncValid(12) <= rgbSyncValid(11);
        rgbSyncValid(13) <= rgbSyncValid(12);
        rgbSyncValid(14) <= rgbSyncValid(13);
        rgbSyncValid(15) <= rgbSyncValid(14);
        rgbSyncValid(16) <= rgbSyncValid(15);
        rgbSyncValid(17) <= rgbSyncValid(16);
        rgbSyncValid(18) <= rgbSyncValid(17);
        rgbSyncValid(19) <= rgbSyncValid(18);
        rgbSyncValid(20) <= rgbSyncValid(19);
        rgbSyncValid(21) <= rgbSyncValid(20);
        rgbSyncValid(22) <= rgbSyncValid(21);
        rgbSyncValid(23) <= rgbSyncValid(22);
        rgbSyncValid(24) <= rgbSyncValid(23);
        rgbSyncValid(25) <= rgbSyncValid(24);
        rgbSyncValid(26) <= rgbSyncValid(25);
        rgbSyncValid(27) <= rgbSyncValid(26);
        rgbSyncValid(28) <= rgbSyncValid(27);
        rgbSyncValid(29) <= rgbSyncValid(28);
        rgbSyncValid(30) <= rgbSyncValid(29);
        rgbSyncValid(31) <= rgbSyncValid(30);
    end if;
end process;

    
process (clk) begin
    if rising_edge(clk) then
            row1.pixel_1    <= v_tap_0x;
            row1.pixel_2    <= row1.pixel_1;
            row1.pixel_3    <= row1.pixel_2;


            row2.pixel_1    <= v_tap_1x;
            row2.pixel_2    <= row2.pixel_1;
            row2.pixel_3    <= row2.pixel_2;


            row3.pixel_1    <= v_tap_2x;
            row3.pixel_2    <= row3.pixel_1;
            row3.pixel_3    <= row3.pixel_2;



    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
            rgb_pixels_9x9.red.k1  <= row1.pixel_1(23 downto 16);
            rgb_pixels_9x9.red.k2  <= row1.pixel_2(23 downto 16);
            rgb_pixels_9x9.red.k3  <= row1.pixel_3(23 downto 16);
            rgb_pixels_9x9.red.k4  <= row2.pixel_1(23 downto 16);
            rgb_pixels_9x9.red.k5  <= row2.pixel_2(23 downto 16);
            rgb_pixels_9x9.red.k6  <= row2.pixel_3(23 downto 16);
            rgb_pixels_9x9.red.k7  <= row3.pixel_1(23 downto 16);
            rgb_pixels_9x9.red.k8  <= row3.pixel_2(23 downto 16);
            rgb_pixels_9x9.red.k9  <= row3.pixel_3(23 downto 16);

    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
            rgb_pixels_9x9.green.k1  <= row1.pixel_1(15 downto 8);
            rgb_pixels_9x9.green.k2  <= row1.pixel_2(15 downto 8);
            rgb_pixels_9x9.green.k3  <= row1.pixel_3(15 downto 8);
            rgb_pixels_9x9.green.k4  <= row2.pixel_1(15 downto 8);
            rgb_pixels_9x9.green.k5  <= row2.pixel_2(15 downto 8);
            rgb_pixels_9x9.green.k6  <= row2.pixel_3(15 downto 8);
            rgb_pixels_9x9.green.k7  <= row3.pixel_1(15 downto 8);
            rgb_pixels_9x9.green.k8  <= row3.pixel_2(15 downto 8);
            rgb_pixels_9x9.green.k9  <= row3.pixel_3(15 downto 8);

    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
            rgb_pixels_9x9.blue.k1  <= row1.pixel_1(7 downto 0);
            rgb_pixels_9x9.blue.k2  <= row1.pixel_2(7 downto 0);
            rgb_pixels_9x9.blue.k3  <= row1.pixel_3(7 downto 0);
            rgb_pixels_9x9.blue.k4  <= row2.pixel_1(7 downto 0);
            rgb_pixels_9x9.blue.k5  <= row2.pixel_2(7 downto 0);
            rgb_pixels_9x9.blue.k6  <= row2.pixel_3(7 downto 0);
            rgb_pixels_9x9.blue.k7  <= row3.pixel_1(7 downto 0);
            rgb_pixels_9x9.blue.k8  <= row3.pixel_2(7 downto 0);
            rgb_pixels_9x9.blue.k9  <= row3.pixel_3(7 downto 0);

    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_9x9.red.k1    <= to_integer(unsigned(rgb_pixels_9x9.red.k1)); 
        rgb_9x9.red.k2    <= to_integer(unsigned(rgb_pixels_9x9.red.k2)); 
        rgb_9x9.red.k3    <= to_integer(unsigned(rgb_pixels_9x9.red.k3)); 
        rgb_9x9.red.k4    <= to_integer(unsigned(rgb_pixels_9x9.red.k4)); 
        rgb_9x9.red.k5    <= to_integer(unsigned(rgb_pixels_9x9.red.k5)); 
        rgb_9x9.red.k6    <= to_integer(unsigned(rgb_pixels_9x9.red.k6)); 
        rgb_9x9.red.k7    <= to_integer(unsigned(rgb_pixels_9x9.red.k7)); 
        rgb_9x9.red.k8    <= to_integer(unsigned(rgb_pixels_9x9.red.k8)); 
        rgb_9x9.red.k9    <= to_integer(unsigned(rgb_pixels_9x9.red.k9)); 


    end if;
end process;

process (clk) begin
    if rising_edge(clk) then
        rgb_9x9.green.k1    <= to_integer(unsigned(rgb_pixels_9x9.green.k1)); 
        rgb_9x9.green.k2    <= to_integer(unsigned(rgb_pixels_9x9.green.k2)); 
        rgb_9x9.green.k3    <= to_integer(unsigned(rgb_pixels_9x9.green.k3)); 
        rgb_9x9.green.k4    <= to_integer(unsigned(rgb_pixels_9x9.green.k4)); 
        rgb_9x9.green.k5    <= to_integer(unsigned(rgb_pixels_9x9.green.k5)); 
        rgb_9x9.green.k6    <= to_integer(unsigned(rgb_pixels_9x9.green.k6)); 
        rgb_9x9.green.k7    <= to_integer(unsigned(rgb_pixels_9x9.green.k7)); 
        rgb_9x9.green.k8    <= to_integer(unsigned(rgb_pixels_9x9.green.k8)); 
        rgb_9x9.green.k9    <= to_integer(unsigned(rgb_pixels_9x9.green.k9)); 


    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_9x9.blue.k1    <= to_integer(unsigned(rgb_pixels_9x9.blue.k1)); 
        rgb_9x9.blue.k2    <= to_integer(unsigned(rgb_pixels_9x9.blue.k2)); 
        rgb_9x9.blue.k3    <= to_integer(unsigned(rgb_pixels_9x9.blue.k3)); 
        rgb_9x9.blue.k4    <= to_integer(unsigned(rgb_pixels_9x9.blue.k4)); 
        rgb_9x9.blue.k5    <= to_integer(unsigned(rgb_pixels_9x9.blue.k5)); 
        rgb_9x9.blue.k6    <= to_integer(unsigned(rgb_pixels_9x9.blue.k6)); 
        rgb_9x9.blue.k7    <= to_integer(unsigned(rgb_pixels_9x9.blue.k7)); 
        rgb_9x9.blue.k8    <= to_integer(unsigned(rgb_pixels_9x9.blue.k8)); 
        rgb_9x9.blue.k9    <= to_integer(unsigned(rgb_pixels_9x9.blue.k9)); 


    end if;
end process;



    
process (clk) begin
    if rising_edge(clk) then
        rgb_9x9_delta.filter_size_9x9.red.k1      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k1); 
        rgb_9x9_delta.filter_size_9x9.red.k2      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k2); 
        rgb_9x9_delta.filter_size_9x9.red.k3      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k3); 
        rgb_9x9_delta.filter_size_9x9.red.k4      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k4); 
        rgb_9x9_delta.filter_size_9x9.red.k5      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k5); 
        rgb_9x9_delta.filter_size_9x9.red.k6      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k6); 
        rgb_9x9_delta.filter_size_9x9.red.k7      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k7); 
        rgb_9x9_delta.filter_size_9x9.red.k8      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k8); 
        rgb_9x9_delta.filter_size_9x9.red.k9      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k9); 


    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_9x9_delta.filter_size_9x9.green.k1      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k1); 
        rgb_9x9_delta.filter_size_9x9.green.k2      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k2); 
        rgb_9x9_delta.filter_size_9x9.green.k3      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k3); 
        rgb_9x9_delta.filter_size_9x9.green.k4      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k4); 
        rgb_9x9_delta.filter_size_9x9.green.k5      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k5); 
        rgb_9x9_delta.filter_size_9x9.green.k6      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k6); 
        rgb_9x9_delta.filter_size_9x9.green.k7      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k7); 
        rgb_9x9_delta.filter_size_9x9.green.k8      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k8); 
        rgb_9x9_delta.filter_size_9x9.green.k9      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k9); 


    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_9x9_delta.filter_size_9x9.blue.k1      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k1); 
        rgb_9x9_delta.filter_size_9x9.blue.k2      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k2); 
        rgb_9x9_delta.filter_size_9x9.blue.k3      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k3); 
        rgb_9x9_delta.filter_size_9x9.blue.k4      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k4); 
        rgb_9x9_delta.filter_size_9x9.blue.k5      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k5); 
        rgb_9x9_delta.filter_size_9x9.blue.k6      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k6); 
        rgb_9x9_delta.filter_size_9x9.blue.k7      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k7); 
        rgb_9x9_delta.filter_size_9x9.blue.k8      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k8); 
        rgb_9x9_delta.filter_size_9x9.blue.k9      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k9); 


    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_9x9_delta.filter_size_3x3.red.k1      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k1); 
        rgb_9x9_delta.filter_size_3x3.red.k2      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k2); 
        rgb_9x9_delta.filter_size_3x3.red.k3      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k3); 
        rgb_9x9_delta.filter_size_3x3.red.k4      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k4); 
        rgb_9x9_delta.filter_size_3x3.red.k5      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k5); 
        rgb_9x9_delta.filter_size_3x3.red.k6      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k6); 
        rgb_9x9_delta.filter_size_3x3.red.k7      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k7); 
        rgb_9x9_delta.filter_size_3x3.red.k8      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k8); 
        rgb_9x9_delta.filter_size_3x3.red.k9      <= abs(rgb_9x9.red.k5 - rgb_9x9.red.k9); 


    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_9x9_delta.filter_size_3x3.green.k1      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k1); 
        rgb_9x9_delta.filter_size_3x3.green.k2      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k2); 
        rgb_9x9_delta.filter_size_3x3.green.k3      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k3); 
        rgb_9x9_delta.filter_size_3x3.green.k4      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k4); 
        rgb_9x9_delta.filter_size_3x3.green.k5      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k5); 
        rgb_9x9_delta.filter_size_3x3.green.k6      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k6); 
        rgb_9x9_delta.filter_size_3x3.green.k7      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k7); 
        rgb_9x9_delta.filter_size_3x3.green.k8      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k8); 
        rgb_9x9_delta.filter_size_3x3.green.k9      <= abs(rgb_9x9.green.k5 - rgb_9x9.green.k9); 


    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_9x9_delta.filter_size_3x3.blue.k1      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k1); 
        rgb_9x9_delta.filter_size_3x3.blue.k2      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k2); 
        rgb_9x9_delta.filter_size_3x3.blue.k3      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k3); 
        rgb_9x9_delta.filter_size_3x3.blue.k4      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k4); 
        rgb_9x9_delta.filter_size_3x3.blue.k5      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k5); 
        rgb_9x9_delta.filter_size_3x3.blue.k6      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k6); 
        rgb_9x9_delta.filter_size_3x3.blue.k7      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k7); 
        rgb_9x9_delta.filter_size_3x3.blue.k8      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k8); 
        rgb_9x9_delta.filter_size_3x3.blue.k9      <= abs(rgb_9x9.blue.k5 - rgb_9x9.blue.k9); 


    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        pix_9x9.red   <= rgb_9x9.red;
        pix_9x9.green <= rgb_9x9.green;
        pix_9x9.blue  <= rgb_9x9.blue;
    end if;
end process;

process (clk) begin
    if rising_edge(clk) then
    
        sum.red.pixels_01_02_03_3x3                <= (pix_9x9.red.k1  + pix_9x9.red.k2*2  + pix_9x9.red.k3) / 4;
        sum.red.pixels_10_11_12_3x3                <= (pix_9x9.red.k4*2 + pix_9x9.red.k5*4 + pix_9x9.red.k6*2) / 8;
        sum.red.pixels_19_20_21_3x3                <= (pix_9x9.red.k7 + pix_9x9.red.k8*2 + pix_9x9.red.k9) / 4;

        sum.red.pixels_01                          <= (pix_9x9.red.k5);

        sum.red.pixels_01_02_03_04_05_06_07_08_09  <= (pix_9x9.red.k1 *0 + pix_9x9.red.k2 *0 + pix_9x9.red.k3 *0 + pix_9x9.red.k4 *0 + pix_9x9.red.k5 *1 + pix_9x9.red.k6 *0 + pix_9x9.red.k7 *0 + pix_9x9.red.k8 *0 + pix_9x9.red.k9*0);
        sum.red.pixels_10_11_12_13_14_15_16_17_18  <= (pix_9x9.red.k10*0 + pix_9x9.red.k11*0 + pix_9x9.red.k12*0 + pix_9x9.red.k13*0 + pix_9x9.red.k14*1 + pix_9x9.red.k15*0 + pix_9x9.red.k16*0 + pix_9x9.red.k17*0 + pix_9x9.red.k18*0);
        sum.red.pixels_19_20_21_22_23_24_25_26_27  <= (pix_9x9.red.k19*0 + pix_9x9.red.k20*0 + pix_9x9.red.k21*0 + pix_9x9.red.k22*0 + pix_9x9.red.k23*1 + pix_9x9.red.k24*0 + pix_9x9.red.k25*0 + pix_9x9.red.k26*0 + pix_9x9.red.k27*0);
        sum.red.pixels_28_29_30_31_32_33_34_35_36  <= (pix_9x9.red.k28*0 + pix_9x9.red.k29*0 + pix_9x9.red.k30*0 + pix_9x9.red.k31*0 + pix_9x9.red.k32*1 + pix_9x9.red.k33*0 + pix_9x9.red.k34*0 + pix_9x9.red.k35*0 + pix_9x9.red.k36*0);
        sum.red.pixels_37_38_39_40_41_42_43_44_45  <= (pix_9x9.red.k37*0 + pix_9x9.red.k38*0 + pix_9x9.red.k39*0 + pix_9x9.red.k40*0 + pix_9x9.red.k41*1 + pix_9x9.red.k42*0 + pix_9x9.red.k43*0 + pix_9x9.red.k44*0 + pix_9x9.red.k45*0);
        sum.red.pixels_46_47_48_49_50_51_52_53_54  <= (pix_9x9.red.k46*0 + pix_9x9.red.k47*0 + pix_9x9.red.k48*0 + pix_9x9.red.k49*0 + pix_9x9.red.k50*1 + pix_9x9.red.k51*0 + pix_9x9.red.k52*0 + pix_9x9.red.k53*0 + pix_9x9.red.k54*0);
        sum.red.pixels_55_56_57_58_59_60_61_62_63  <= (pix_9x9.red.k55*0 + pix_9x9.red.k56*0 + pix_9x9.red.k57*0 + pix_9x9.red.k58*0 + pix_9x9.red.k59*1 + pix_9x9.red.k60*0 + pix_9x9.red.k61*0 + pix_9x9.red.k62*0 + pix_9x9.red.k63*0);
        sum.red.pixels_64_65_66_67_68_69_70_71_72  <= (pix_9x9.red.k64*0 + pix_9x9.red.k65*0 + pix_9x9.red.k66*0 + pix_9x9.red.k67*0 + pix_9x9.red.k68*1 + pix_9x9.red.k69*0 + pix_9x9.red.k70*0 + pix_9x9.red.k71*0 + pix_9x9.red.k72*0);
        sum.red.pixels_73_74_75_76_77_78_79_80_81  <= (pix_9x9.red.k73*0 + pix_9x9.red.k74*0 + pix_9x9.red.k75*0 + pix_9x9.red.k76*0 + pix_9x9.red.k77*1 + pix_9x9.red.k78*0 + pix_9x9.red.k79*0 + pix_9x9.red.k80*0 + pix_9x9.red.k81*0);
        --sum.red.pixels_01_to_81                    <= (sum.red.pixels_01_02_03_04_05_06_07_08_09 + sum.red.pixels_10_11_12_13_14_15_16_17_18 + sum.red.pixels_19_20_21_22_23_24_25_26_27 + sum.red.pixels_28_29_30_31_32_33_34_35_36 + sum.red.pixels_37_38_39_40_41_42_43_44_45 + sum.red.pixels_46_47_48_49_50_51_52_53_54 + sum.red.pixels_55_56_57_58_59_60_61_62_63 + sum.red.pixels_64_65_66_67_68_69_70_71_72 + sum.red.pixels_73_74_75_76_77_78_79_80_81) /9;
        if(crd_s40.y=0)then
            sum.red.pixels_01_to_21_3x3                <= (sum.red.pixels_01_02_03_3x3);
        elsif(crd_s40.y=1)then
            sum.red.pixels_01_to_21_3x3                <= (sum.red.pixels_01_02_03_3x3 + sum.red.pixels_10_11_12_3x3) / 2;
        else
            sum.red.pixels_01_to_21_3x3                <= (sum.red.pixels_01_02_03_3x3 + sum.red.pixels_10_11_12_3x3 + sum.red.pixels_19_20_21_3x3) / 3;
        end if;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
    
    
        sum.green.pixels_01_02_03_3x3                <= (pix_9x9.green.k1  + pix_9x9.green.k2*2  + pix_9x9.green.k3) / 4;
        sum.green.pixels_10_11_12_3x3                <= (pix_9x9.green.k4*2 + pix_9x9.green.k5*4 + pix_9x9.green.k6*2) / 8;
        sum.green.pixels_19_20_21_3x3                <= (pix_9x9.green.k7 + pix_9x9.green.k8*2 + pix_9x9.green.k9) / 4;
        sum.green.pixels_01                          <= (pix_9x9.green.k5);
    
        if(crd_s40.y=0)then
            sum.green.pixels_01_to_21_3x3                <= (sum.green.pixels_01_02_03_3x3);
        elsif(crd_s40.y=1)then
            sum.green.pixels_01_to_21_3x3                <= (sum.green.pixels_01_02_03_3x3 + sum.green.pixels_10_11_12_3x3) / 2;
        else
            sum.green.pixels_01_to_21_3x3                <= (sum.green.pixels_01_02_03_3x3 + sum.green.pixels_10_11_12_3x3 + sum.green.pixels_19_20_21_3x3) / 3;
        end if;
    
        sum.green.pixels_01_02_03_04_05_06_07_08_09  <= (pix_9x9.green.k1  + pix_9x9.green.k2  + pix_9x9.green.k3  + pix_9x9.green.k4  + pix_9x9.green.k5  + pix_9x9.green.k6  + pix_9x9.green.k7  + pix_9x9.green.k8  + pix_9x9.green.k9) / 9;
        sum.green.pixels_10_11_12_13_14_15_16_17_18  <= (pix_9x9.green.k10 + pix_9x9.green.k11 + pix_9x9.green.k12 + pix_9x9.green.k13 + pix_9x9.green.k14 + pix_9x9.green.k15 + pix_9x9.green.k16 + pix_9x9.green.k17 + pix_9x9.green.k18) / 9;
        sum.green.pixels_19_20_21_22_23_24_25_26_27  <= (pix_9x9.green.k19 + pix_9x9.green.k20 + pix_9x9.green.k21 + pix_9x9.green.k22 + pix_9x9.green.k23 + pix_9x9.green.k24 + pix_9x9.green.k25 + pix_9x9.green.k26 + pix_9x9.green.k27) / 9;
        sum.green.pixels_28_29_30_31_32_33_34_35_36  <= (pix_9x9.green.k28 + pix_9x9.green.k29 + pix_9x9.green.k30 + pix_9x9.green.k31 + pix_9x9.green.k32 + pix_9x9.green.k33 + pix_9x9.green.k34 + pix_9x9.green.k35 + pix_9x9.green.k36) / 9;
        sum.green.pixels_37_38_39_40_41_42_43_44_45  <= (pix_9x9.green.k37 + pix_9x9.green.k38 + pix_9x9.green.k39 + pix_9x9.green.k40 + pix_9x9.green.k41 + pix_9x9.green.k42 + pix_9x9.green.k43 + pix_9x9.green.k44 + pix_9x9.green.k45) / 9;
        sum.green.pixels_46_47_48_49_50_51_52_53_54  <= (pix_9x9.green.k46 + pix_9x9.green.k47 + pix_9x9.green.k48 + pix_9x9.green.k49 + pix_9x9.green.k50 + pix_9x9.green.k51 + pix_9x9.green.k52 + pix_9x9.green.k53 + pix_9x9.green.k54) / 9;
        sum.green.pixels_55_56_57_58_59_60_61_62_63  <= (pix_9x9.green.k55 + pix_9x9.green.k56 + pix_9x9.green.k57 + pix_9x9.green.k58 + pix_9x9.green.k59 + pix_9x9.green.k60 + pix_9x9.green.k61 + pix_9x9.green.k62 + pix_9x9.green.k63) / 9;
        sum.green.pixels_64_65_66_67_68_69_70_71_72  <= (pix_9x9.green.k64 + pix_9x9.green.k65 + pix_9x9.green.k66 + pix_9x9.green.k67 + pix_9x9.green.k68 + pix_9x9.green.k69 + pix_9x9.green.k70 + pix_9x9.green.k71 + pix_9x9.green.k72) / 9;
        sum.green.pixels_73_74_75_76_77_78_79_80_81  <= (pix_9x9.green.k73 + pix_9x9.green.k74 + pix_9x9.green.k75 + pix_9x9.green.k76 + pix_9x9.green.k77 + pix_9x9.green.k78 + pix_9x9.green.k79 + pix_9x9.green.k80 + pix_9x9.green.k81) / 9;
        
        if(crd_s11.y=0)then
            sum.green.pixels_01_to_81                    <= (sum.green.pixels_01_02_03_04_05_06_07_08_09);
        elsif(crd_s11.y=1)then
            sum.green.pixels_01_to_81                    <= (sum.green.pixels_01_02_03_04_05_06_07_08_09 + sum.green.pixels_10_11_12_13_14_15_16_17_18) /2;
        elsif(crd_s11.y=2)then
            sum.green.pixels_01_to_81                    <= (sum.green.pixels_01_02_03_04_05_06_07_08_09 + sum.green.pixels_10_11_12_13_14_15_16_17_18 + sum.green.pixels_19_20_21_22_23_24_25_26_27) /3;
        elsif(crd_s11.y=3)then
            sum.green.pixels_01_to_81                    <= (sum.green.pixels_01_02_03_04_05_06_07_08_09 + sum.green.pixels_10_11_12_13_14_15_16_17_18 + sum.green.pixels_19_20_21_22_23_24_25_26_27 + sum.green.pixels_28_29_30_31_32_33_34_35_36) /4;
        elsif(crd_s11.y=4)then
            sum.green.pixels_01_to_81                    <= (sum.green.pixels_01_02_03_04_05_06_07_08_09 + sum.green.pixels_10_11_12_13_14_15_16_17_18 + sum.green.pixels_19_20_21_22_23_24_25_26_27 + sum.green.pixels_28_29_30_31_32_33_34_35_36 + sum.green.pixels_37_38_39_40_41_42_43_44_45) /5;
        elsif(crd_s11.y=5)then
            sum.green.pixels_01_to_81                    <= (sum.green.pixels_01_02_03_04_05_06_07_08_09 + sum.green.pixels_10_11_12_13_14_15_16_17_18 + sum.green.pixels_19_20_21_22_23_24_25_26_27 + sum.green.pixels_28_29_30_31_32_33_34_35_36 + sum.green.pixels_37_38_39_40_41_42_43_44_45 + sum.green.pixels_46_47_48_49_50_51_52_53_54) /6;
        elsif(crd_s11.y=6)then
            sum.green.pixels_01_to_81                    <= (sum.green.pixels_01_02_03_04_05_06_07_08_09 + sum.green.pixels_10_11_12_13_14_15_16_17_18 + sum.green.pixels_19_20_21_22_23_24_25_26_27 + sum.green.pixels_28_29_30_31_32_33_34_35_36 + sum.green.pixels_37_38_39_40_41_42_43_44_45 + sum.green.pixels_46_47_48_49_50_51_52_53_54 + sum.green.pixels_55_56_57_58_59_60_61_62_63) /7;
        elsif(crd_s11.y=7)then
            sum.green.pixels_01_to_81                    <= (sum.green.pixels_01_02_03_04_05_06_07_08_09 + sum.green.pixels_10_11_12_13_14_15_16_17_18 + sum.green.pixels_19_20_21_22_23_24_25_26_27 + sum.green.pixels_28_29_30_31_32_33_34_35_36 + sum.green.pixels_37_38_39_40_41_42_43_44_45 + sum.green.pixels_46_47_48_49_50_51_52_53_54 + sum.green.pixels_55_56_57_58_59_60_61_62_63 + sum.green.pixels_64_65_66_67_68_69_70_71_72) /8;
        else
            sum.green.pixels_01_to_81                    <= (sum.green.pixels_01_02_03_04_05_06_07_08_09 + sum.green.pixels_10_11_12_13_14_15_16_17_18 + sum.green.pixels_19_20_21_22_23_24_25_26_27 + sum.green.pixels_28_29_30_31_32_33_34_35_36 + sum.green.pixels_37_38_39_40_41_42_43_44_45 + sum.green.pixels_46_47_48_49_50_51_52_53_54 + sum.green.pixels_55_56_57_58_59_60_61_62_63 + sum.green.pixels_64_65_66_67_68_69_70_71_72 + sum.green.pixels_73_74_75_76_77_78_79_80_81) /9;
        end if;
        
        
        
        
        
    end if;
end process;

process (clk) begin
    if rising_edge(clk) then
    
        sum.blue.pixels_01_02_03_3x3                <= (pix_9x9.blue.k1  + pix_9x9.blue.k2*2  + pix_9x9.blue.k3) / 4;
        sum.blue.pixels_10_11_12_3x3                <= (pix_9x9.blue.k4*2 + pix_9x9.blue.k5*4 + pix_9x9.blue.k6*2) / 8;
        sum.blue.pixels_19_20_21_3x3                <= (pix_9x9.blue.k7 + pix_9x9.blue.k8*2 + pix_9x9.blue.k9) / 4;
        sum.blue.pixels_01                          <= (pix_9x9.blue.k5);
        if(crd_s40.y=0)then
            sum.blue.pixels_01_to_21_3x3                <= (sum.blue.pixels_01_02_03_3x3);
        elsif(crd_s40.y=1)then
            sum.blue.pixels_01_to_21_3x3                <= (sum.blue.pixels_01_02_03_3x3 + sum.blue.pixels_10_11_12_3x3) / 2;
        else
            sum.blue.pixels_01_to_21_3x3                <= (sum.blue.pixels_01_02_03_3x3 + sum.blue.pixels_10_11_12_3x3 + sum.blue.pixels_19_20_21_3x3) / 3;
        end if;
        
        
        
        sum.blue.pixels_01_02_03_04_05_06_07_08_09  <= (pix_9x9.blue.k1  + pix_9x9.blue.k2  + pix_9x9.blue.k3  + pix_9x9.blue.k4  + pix_9x9.blue.k5  + pix_9x9.blue.k6  + pix_9x9.blue.k7  + pix_9x9.blue.k8  + pix_9x9.blue.k9) / 9;
        sum.blue.pixels_10_11_12_13_14_15_16_17_18  <= (pix_9x9.blue.k10 + pix_9x9.blue.k11 + pix_9x9.blue.k12 + pix_9x9.blue.k13 + pix_9x9.blue.k14 + pix_9x9.blue.k15 + pix_9x9.blue.k16 + pix_9x9.blue.k17 + pix_9x9.blue.k18) / 9;
        sum.blue.pixels_19_20_21_22_23_24_25_26_27  <= (pix_9x9.blue.k19 + pix_9x9.blue.k20 + pix_9x9.blue.k21 + pix_9x9.blue.k22 + pix_9x9.blue.k23 + pix_9x9.blue.k24 + pix_9x9.blue.k25 + pix_9x9.blue.k26 + pix_9x9.blue.k27) / 9;
        sum.blue.pixels_28_29_30_31_32_33_34_35_36  <= (pix_9x9.blue.k28 + pix_9x9.blue.k29 + pix_9x9.blue.k30 + pix_9x9.blue.k31 + pix_9x9.blue.k32 + pix_9x9.blue.k33 + pix_9x9.blue.k34 + pix_9x9.blue.k35 + pix_9x9.blue.k36) / 9;
        sum.blue.pixels_37_38_39_40_41_42_43_44_45  <= (pix_9x9.blue.k37 + pix_9x9.blue.k38 + pix_9x9.blue.k39 + pix_9x9.blue.k40 + pix_9x9.blue.k41 + pix_9x9.blue.k42 + pix_9x9.blue.k43 + pix_9x9.blue.k44 + pix_9x9.blue.k45) / 9;
        sum.blue.pixels_46_47_48_49_50_51_52_53_54  <= (pix_9x9.blue.k46 + pix_9x9.blue.k47 + pix_9x9.blue.k48 + pix_9x9.blue.k49 + pix_9x9.blue.k50 + pix_9x9.blue.k51 + pix_9x9.blue.k52 + pix_9x9.blue.k53 + pix_9x9.blue.k54) / 9;
        sum.blue.pixels_55_56_57_58_59_60_61_62_63  <= (pix_9x9.blue.k55 + pix_9x9.blue.k56 + pix_9x9.blue.k57 + pix_9x9.blue.k58 + pix_9x9.blue.k59 + pix_9x9.blue.k60 + pix_9x9.blue.k61 + pix_9x9.blue.k62 + pix_9x9.blue.k63) / 9;
        sum.blue.pixels_64_65_66_67_68_69_70_71_72  <= (pix_9x9.blue.k64 + pix_9x9.blue.k65 + pix_9x9.blue.k66 + pix_9x9.blue.k67 + pix_9x9.blue.k68 + pix_9x9.blue.k69 + pix_9x9.blue.k70 + pix_9x9.blue.k71 + pix_9x9.blue.k72) / 9;
        sum.blue.pixels_73_74_75_76_77_78_79_80_81  <= (pix_9x9.blue.k73 + pix_9x9.blue.k74 + pix_9x9.blue.k75 + pix_9x9.blue.k76 + pix_9x9.blue.k77 + pix_9x9.blue.k78 + pix_9x9.blue.k79 + pix_9x9.blue.k80 + pix_9x9.blue.k81) / 9;
        
        if(crd_s11.y=0)then
            sum.blue.pixels_01_to_81                    <= (sum.blue.pixels_01_02_03_04_05_06_07_08_09);
        elsif(crd_s11.y=1)then
            sum.blue.pixels_01_to_81                    <= (sum.blue.pixels_01_02_03_04_05_06_07_08_09 + sum.blue.pixels_10_11_12_13_14_15_16_17_18) /2;
        elsif(crd_s11.y=2)then
            sum.blue.pixels_01_to_81                    <= (sum.blue.pixels_01_02_03_04_05_06_07_08_09 + sum.blue.pixels_10_11_12_13_14_15_16_17_18 + sum.blue.pixels_19_20_21_22_23_24_25_26_27) /3;
        elsif(crd_s11.y=3)then
            sum.blue.pixels_01_to_81                    <= (sum.blue.pixels_01_02_03_04_05_06_07_08_09 + sum.blue.pixels_10_11_12_13_14_15_16_17_18 + sum.blue.pixels_19_20_21_22_23_24_25_26_27 + sum.blue.pixels_28_29_30_31_32_33_34_35_36) /4;
        elsif(crd_s11.y=4)then
            sum.blue.pixels_01_to_81                    <= (sum.blue.pixels_01_02_03_04_05_06_07_08_09 + sum.blue.pixels_10_11_12_13_14_15_16_17_18 + sum.blue.pixels_19_20_21_22_23_24_25_26_27 + sum.blue.pixels_28_29_30_31_32_33_34_35_36 + sum.blue.pixels_37_38_39_40_41_42_43_44_45) /5;
        elsif(crd_s11.y=5)then
            sum.blue.pixels_01_to_81                    <= (sum.blue.pixels_01_02_03_04_05_06_07_08_09 + sum.blue.pixels_10_11_12_13_14_15_16_17_18 + sum.blue.pixels_19_20_21_22_23_24_25_26_27 + sum.blue.pixels_28_29_30_31_32_33_34_35_36 + sum.blue.pixels_37_38_39_40_41_42_43_44_45 + sum.blue.pixels_46_47_48_49_50_51_52_53_54) /6;
        elsif(crd_s11.y=6)then
            sum.blue.pixels_01_to_81                    <= (sum.blue.pixels_01_02_03_04_05_06_07_08_09 + sum.blue.pixels_10_11_12_13_14_15_16_17_18 + sum.blue.pixels_19_20_21_22_23_24_25_26_27 + sum.blue.pixels_28_29_30_31_32_33_34_35_36 + sum.blue.pixels_37_38_39_40_41_42_43_44_45 + sum.blue.pixels_46_47_48_49_50_51_52_53_54 + sum.blue.pixels_55_56_57_58_59_60_61_62_63) /7;
        elsif(crd_s11.y=7)then
            sum.blue.pixels_01_to_81                    <= (sum.blue.pixels_01_02_03_04_05_06_07_08_09 + sum.blue.pixels_10_11_12_13_14_15_16_17_18 + sum.blue.pixels_19_20_21_22_23_24_25_26_27 + sum.blue.pixels_28_29_30_31_32_33_34_35_36 + sum.blue.pixels_37_38_39_40_41_42_43_44_45 + sum.blue.pixels_46_47_48_49_50_51_52_53_54 + sum.blue.pixels_55_56_57_58_59_60_61_62_63 + sum.blue.pixels_64_65_66_67_68_69_70_71_72) /8;
        else
            sum.blue.pixels_01_to_81                    <= (sum.blue.pixels_01_02_03_04_05_06_07_08_09 + sum.blue.pixels_10_11_12_13_14_15_16_17_18 + sum.blue.pixels_19_20_21_22_23_24_25_26_27 + sum.blue.pixels_28_29_30_31_32_33_34_35_36 + sum.blue.pixels_37_38_39_40_41_42_43_44_45 + sum.blue.pixels_46_47_48_49_50_51_52_53_54 + sum.blue.pixels_55_56_57_58_59_60_61_62_63 + sum.blue.pixels_64_65_66_67_68_69_70_71_72 + sum.blue.pixels_73_74_75_76_77_78_79_80_81) /9;
        end if;
    end if;
end process;

process (clk) begin
    if rising_edge(clk) then
        if( rgb_9x9_detect.filter_size_9x9.red.k(1).n   =2  and
            rgb_9x9_detect.filter_size_9x9.red.k(2).n   =2  and
            rgb_9x9_detect.filter_size_9x9.red.k(3).n   =3  and
            rgb_9x9_detect.filter_size_9x9.red.k(4).n   =4  and
            rgb_9x9_detect.filter_size_9x9.red.k(5).n   =5  and
            rgb_9x9_detect.filter_size_9x9.red.k(6).n   =6  and
            rgb_9x9_detect.filter_size_9x9.red.k(7).n   =7  and
            rgb_9x9_detect.filter_size_9x9.red.k(8).n   =8  and
            rgb_9x9_detect.filter_size_9x9.red.k(9).n   =9) then  
                pixels_1_81_enabled <= hi;
                sum.red.result      <= std_logic_vector(to_unsigned(sum.red.pixels_01_to_21_3x3, 8));
            else
                pixels_1_81_enabled <= lo;
                sum.red.result      <= std_logic_vector(to_unsigned(sum.blue.pixels_01, 8));
                --sum.red.result   <= Rgb3.red;
            end if;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        if( rgb_9x9_detect.filter_size_9x9.green.k(1).n   =2  and
            rgb_9x9_detect.filter_size_9x9.green.k(2).n   =2  and
            rgb_9x9_detect.filter_size_9x9.green.k(3).n   =3  and
            rgb_9x9_detect.filter_size_9x9.green.k(4).n   =4  and
            rgb_9x9_detect.filter_size_9x9.green.k(5).n   =5  and
            rgb_9x9_detect.filter_size_9x9.green.k(6).n   =6  and
            rgb_9x9_detect.filter_size_9x9.green.k(7).n   =7  and
            rgb_9x9_detect.filter_size_9x9.green.k(8).n   =8  and
            rgb_9x9_detect.filter_size_9x9.green.k(9).n   =9) then  
                sum.green.result   <= std_logic_vector(to_unsigned(sum.green.pixels_01_to_21_3x3, 8));
            else
                sum.green.result   <= std_logic_vector(to_unsigned(sum.green.pixels_01, 8));
                --sum.green.result   <= Rgb3.green;
            end if;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        if( rgb_9x9_detect.filter_size_9x9.blue.k(1).n   =2  and
            rgb_9x9_detect.filter_size_9x9.blue.k(2).n   =2  and
            rgb_9x9_detect.filter_size_9x9.blue.k(3).n   =3  and
            rgb_9x9_detect.filter_size_9x9.blue.k(4).n   =4  and
            rgb_9x9_detect.filter_size_9x9.blue.k(5).n   =5  and
            rgb_9x9_detect.filter_size_9x9.blue.k(6).n   =6  and
            rgb_9x9_detect.filter_size_9x9.blue.k(7).n   =7  and
            rgb_9x9_detect.filter_size_9x9.blue.k(8).n   =8  and
            rgb_9x9_detect.filter_size_9x9.blue.k(9).n   =9) then  
                --sum.blue.result   <= std_logic_vector(to_unsigned(sum.blue.pixels_01_to_81, 8));
                sum.blue.result   <= std_logic_vector(to_unsigned(sum.blue.pixels_01_to_21_3x3, 8));
            else
                sum.blue.result   <= std_logic_vector(to_unsigned(sum.blue.pixels_01, 8));
                --sum.blue.result   <= Rgb3.blue;
            end if;
    end if;
end process;

process (clk) begin
    if rising_edge(clk) then
        Rgb1.red     <= red_select.result(7 downto 0);
        Rgb1.green   <= gre_select.result(7 downto 0);
        Rgb1.blue    <= blu_select.result(7 downto 0);
        Rgb1.valid   <= rgbSyncValid(27);
    end if;
end process;

--18,24
process (clk) begin
    if rising_edge(clk) then
        oRgb.red     <= Rgb1.red;
        oRgb.green   <= Rgb1.green;
        oRgb.blue    <= Rgb1.blue;
        oRgb.valid   <= Rgb1.valid;
    end if;
end process;
--process (clk) begin
--    if rising_edge(clk) then
--        oRgb.red     <= sum.red.result;
--        oRgb.green   <= sum.green.result;
--        oRgb.blue    <= sum.blue.result;
--        oRgb.valid   <= rgbSyncValid(16);
--    end if;
--end process;

process (clk) begin
    if rising_edge(clk) then
        if(rgb_9x9_delta.filter_size_9x9.red.k1 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(1).n  <= 1;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(1).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k2 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(2).n  <= 2;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(2).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k3 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(3).n  <= 3;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(3).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k4 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(4).n  <= 4;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(4).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k5 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(5).n  <= 5;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(5).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k6 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(6).n  <= 6;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(6).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k7 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(7).n  <= 7;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(7).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k8 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(8).n  <= 8;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(8).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k9 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(9).n  <= 9;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(9).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k10 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(10).n  <= 10;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(10).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k11 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(11).n  <= 11;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(11).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k12 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(12).n  <= 12;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(12).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k13 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(13).n  <= 13;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(13).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k14 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(14).n  <= 14;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(14).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k15 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(15).n  <= 15;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(15).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k16 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(16).n  <= 16;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(16).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k17 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(17).n  <= 17;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(17).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k18 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(18).n  <= 18;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(18).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k19 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(19).n  <= 19;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(19).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k20 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(20).n  <= 20;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(20).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k21 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(21).n  <= 21;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(21).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k22 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(22).n  <= 22;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(22).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k23 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(23).n  <= 23;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(23).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k24 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(24).n  <= 24;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(24).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k25 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(25).n  <= 25;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(25).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k26 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(26).n  <= 26;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(26).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k27 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(27).n  <= 27;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(27).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k28 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(28).n  <= 28;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(28).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k29 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(29).n  <= 29;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(29).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k30 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(30).n  <= 30;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(30).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k31 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(31).n  <= 31;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(31).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k32 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(32).n  <= 32;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(32).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k33 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(33).n  <= 33;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(33).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k34 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(34).n  <= 34;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(34).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k35 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(35).n  <= 35;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(35).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k36 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(36).n  <= 36;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(36).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k37 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(37).n  <= 37;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(37).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k38 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(38).n  <= 38;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(38).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k39 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(39).n  <= 39;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(39).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k40 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(40).n  <= 40;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(40).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k41 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(41).n  <= 41;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(41).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k42 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(42).n  <= 42;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(42).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k43 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(43).n  <= 43;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(43).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k44 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(44).n  <= 44;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(44).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k45 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(45).n  <= 45;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(45).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k46 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(46).n  <= 46;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(46).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k47 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(47).n  <= 47;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(47).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k48 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(48).n  <= 48;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(48).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k49 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(49).n  <= 49;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(49).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k50 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(50).n  <= 50;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(50).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k51 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(51).n  <= 51;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(51).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k52 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(52).n  <= 52;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(52).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k53 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(53).n  <= 53;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(53).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k54 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(54).n  <= 54;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(54).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k55 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(55).n  <= 55;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(55).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k56 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(56).n  <= 56;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(56).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k57 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(57).n  <= 57;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(57).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k58 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(58).n  <= 58;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(58).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k59 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(59).n  <= 59;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(59).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k60 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(60).n  <= 60;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(60).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k61 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(61).n  <= 61;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(61).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k62 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(62).n  <= 62;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(62).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k63 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(63).n  <= 63;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(63).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k64 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(64).n  <= 64;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(64).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k65 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(65).n  <= 65;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(65).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k66 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(66).n  <= 66;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(66).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k67 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(67).n  <= 67;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(67).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k68 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(68).n  <= 68;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(68).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k69 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(69).n  <= 69;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(69).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k70 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(70).n  <= 70;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(70).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k71 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(71).n  <= 71;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(71).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k72 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(72).n  <= 72;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(72).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k73 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(73).n  <= 73;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(73).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k74 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(74).n  <= 74;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(74).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k75 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(75).n  <= 75;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(75).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k76 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(76).n  <= 76;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(76).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k77 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(77).n  <= 77;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(77).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k78 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(78).n  <= 78;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(78).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k79 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(79).n  <= 79;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(79).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k80 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(80).n  <= 80;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(80).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.red.k81 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.red.k(81).n  <= 81;
        else
            rgb_9x9_detect.filter_size_9x9.red.k(81).n  <= 0;
        end if;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        if(rgb_9x9_delta.filter_size_9x9.green.k1 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(1).n  <= 1;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(1).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k2 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(2).n  <= 2;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(2).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k3 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(3).n  <= 3;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(3).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k4 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(4).n  <= 4;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(4).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k5 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(5).n  <= 5;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(5).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k6 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(6).n  <= 6;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(6).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k7 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(7).n  <= 7;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(7).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k8 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(8).n  <= 8;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(8).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k9 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(9).n  <= 9;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(9).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k10 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(10).n  <= 10;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(10).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k11 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(11).n  <= 11;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(11).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k12 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(12).n  <= 12;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(12).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k13 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(13).n  <= 13;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(13).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k14 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(14).n  <= 14;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(14).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k15 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(15).n  <= 15;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(15).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k16 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(16).n  <= 16;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(16).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k17 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(17).n  <= 17;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(17).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k18 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(18).n  <= 18;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(18).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k19 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(19).n  <= 19;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(19).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k20 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(20).n  <= 20;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(20).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k21 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(21).n  <= 21;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(21).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k22 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(22).n  <= 22;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(22).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k23 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(23).n  <= 23;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(23).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k24 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(24).n  <= 24;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(24).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k25 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(25).n  <= 25;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(25).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k26 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(26).n  <= 26;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(26).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k27 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(27).n  <= 27;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(27).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k28 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(28).n  <= 28;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(28).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k29 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(29).n  <= 29;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(29).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k30 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(30).n  <= 30;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(30).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k31 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(31).n  <= 31;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(31).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k32 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(32).n  <= 32;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(32).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k33 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(33).n  <= 33;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(33).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k34 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(34).n  <= 34;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(34).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k35 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(35).n  <= 35;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(35).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k36 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(36).n  <= 36;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(36).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k37 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(37).n  <= 37;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(37).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k38 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(38).n  <= 38;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(38).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k39 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(39).n  <= 39;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(39).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k40 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(40).n  <= 40;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(40).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k41 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(41).n  <= 41;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(41).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k42 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(42).n  <= 42;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(42).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k43 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(43).n  <= 43;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(43).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k44 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(44).n  <= 44;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(44).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k45 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(45).n  <= 45;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(45).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k46 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(46).n  <= 46;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(46).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k47 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(47).n  <= 47;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(47).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k48 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(48).n  <= 48;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(48).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k49 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(49).n  <= 49;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(49).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k50 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(50).n  <= 50;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(50).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k51 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(51).n  <= 51;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(51).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k52 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(52).n  <= 52;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(52).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k53 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(53).n  <= 53;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(53).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k54 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(54).n  <= 54;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(54).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k55 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(55).n  <= 55;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(55).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k56 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(56).n  <= 56;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(56).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k57 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(57).n  <= 57;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(57).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k58 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(58).n  <= 58;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(58).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k59 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(59).n  <= 59;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(59).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k60 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(60).n  <= 60;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(60).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k61 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(61).n  <= 61;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(61).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k62 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(62).n  <= 62;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(62).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k63 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(63).n  <= 63;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(63).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k64 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(64).n  <= 64;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(64).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k65 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(65).n  <= 65;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(65).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k66 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(66).n  <= 66;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(66).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k67 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(67).n  <= 67;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(67).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k68 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(68).n  <= 68;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(68).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k69 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(69).n  <= 69;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(69).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k70 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(70).n  <= 70;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(70).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k71 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(71).n  <= 71;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(71).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k72 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(72).n  <= 72;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(72).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k73 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(73).n  <= 73;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(73).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k74 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(74).n  <= 74;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(74).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k75 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(75).n  <= 75;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(75).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k76 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(76).n  <= 76;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(76).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k77 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(77).n  <= 77;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(77).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k78 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(78).n  <= 78;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(78).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k79 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(79).n  <= 79;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(79).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k80 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(80).n  <= 80;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(80).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.green.k81 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.green.k(81).n  <= 81;
        else
            rgb_9x9_detect.filter_size_9x9.green.k(81).n  <= 0;
        end if;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        if(rgb_9x9_delta.filter_size_9x9.blue.k1 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(1).n  <= 1;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(1).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k2 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(2).n  <= 2;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(2).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k3 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(3).n  <= 3;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(3).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k4 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(4).n  <= 4;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(4).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k5 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(5).n  <= 5;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(5).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k6 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(6).n  <= 6;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(6).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k7 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(7).n  <= 7;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(7).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k8 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(8).n  <= 8;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(8).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k9 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(9).n  <= 9;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(9).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k10 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(10).n  <= 10;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(10).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k11 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(11).n  <= 11;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(11).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k12 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(12).n  <= 12;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(12).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k13 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(13).n  <= 13;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(13).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k14 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(14).n  <= 14;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(14).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k15 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(15).n  <= 15;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(15).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k16 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(16).n  <= 16;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(16).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k17 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(17).n  <= 17;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(17).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k18 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(18).n  <= 18;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(18).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k19 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(19).n  <= 19;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(19).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k20 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(20).n  <= 20;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(20).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k21 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(21).n  <= 21;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(21).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k22 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(22).n  <= 22;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(22).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k23 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(23).n  <= 23;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(23).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k24 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(24).n  <= 24;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(24).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k25 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(25).n  <= 25;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(25).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k26 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(26).n  <= 26;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(26).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k27 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(27).n  <= 27;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(27).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k28 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(28).n  <= 28;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(28).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k29 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(29).n  <= 29;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(29).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k30 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(30).n  <= 30;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(30).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k31 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(31).n  <= 31;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(31).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k32 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(32).n  <= 32;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(32).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k33 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(33).n  <= 33;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(33).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k34 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(34).n  <= 34;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(34).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k35 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(35).n  <= 35;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(35).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k36 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(36).n  <= 36;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(36).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k37 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(37).n  <= 37;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(37).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k38 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(38).n  <= 38;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(38).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k39 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(39).n  <= 39;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(39).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k40 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(40).n  <= 40;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(40).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k41 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(41).n  <= 41;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(41).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k42 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(42).n  <= 42;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(42).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k43 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(43).n  <= 43;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(43).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k44 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(44).n  <= 44;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(44).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k45 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(45).n  <= 45;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(45).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k46 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(46).n  <= 46;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(46).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k47 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(47).n  <= 47;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(47).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k48 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(48).n  <= 48;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(48).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k49 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(49).n  <= 49;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(49).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k50 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(50).n  <= 50;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(50).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k51 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(51).n  <= 51;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(51).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k52 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(52).n  <= 52;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(52).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k53 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(53).n  <= 53;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(53).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k54 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(54).n  <= 54;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(54).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k55 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(55).n  <= 55;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(55).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k56 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(56).n  <= 56;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(56).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k57 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(57).n  <= 57;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(57).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k58 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(58).n  <= 58;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(58).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k59 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(59).n  <= 59;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(59).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k60 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(60).n  <= 60;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(60).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k61 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(61).n  <= 61;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(61).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k62 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(62).n  <= 62;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(62).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k63 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(63).n  <= 63;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(63).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k64 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(64).n  <= 64;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(64).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k65 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(65).n  <= 65;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(65).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k66 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(66).n  <= 66;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(66).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k67 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(67).n  <= 67;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(67).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k68 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(68).n  <= 68;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(68).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k69 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(69).n  <= 69;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(69).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k70 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(70).n  <= 70;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(70).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k71 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(71).n  <= 71;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(71).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k72 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(72).n  <= 72;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(72).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k73 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(73).n  <= 73;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(73).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k74 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(74).n  <= 74;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(74).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k75 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(75).n  <= 75;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(75).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k76 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(76).n  <= 76;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(76).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k77 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(77).n  <= 77;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(77).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k78 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(78).n  <= 78;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(78).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k79 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(79).n  <= 79;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(79).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k80 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(80).n  <= 80;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(80).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_9x9.blue.k81 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_9x9.blue.k(81).n  <= 81;
        else
            rgb_9x9_detect.filter_size_9x9.blue.k(81).n  <= 0;
        end if;
    end if;
end process;

process (clk) begin
    if rising_edge(clk) then
        if(rgb_9x9_delta.filter_size_3x3.red.k1 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(1).n  <= 1;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(1).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k2 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(2).n  <= 2;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(2).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k3 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(3).n  <= 3;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(3).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k4 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(4).n  <= 4;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(4).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k5 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(5).n  <= 5;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(5).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k6 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(6).n  <= 6;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(6).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k7 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(7).n  <= 7;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(7).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k8 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(8).n  <= 8;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(8).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k9 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(9).n  <= 9;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(9).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k10 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(10).n  <= 10;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(10).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k11 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(11).n  <= 11;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(11).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k12 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(12).n  <= 12;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(12).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k13 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(13).n  <= 13;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(13).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k14 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(14).n  <= 14;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(14).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k15 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(15).n  <= 15;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(15).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k16 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(16).n  <= 16;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(16).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k17 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(17).n  <= 17;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(17).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k18 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(18).n  <= 18;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(18).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k19 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(19).n  <= 19;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(19).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k20 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(20).n  <= 20;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(20).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k21 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(21).n  <= 21;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(21).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k22 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(22).n  <= 22;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(22).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k23 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(23).n  <= 23;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(23).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k24 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(24).n  <= 24;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(24).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k25 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(25).n  <= 25;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(25).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k26 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(26).n  <= 26;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(26).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k27 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(27).n  <= 27;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(27).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k28 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(28).n  <= 28;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(28).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k29 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(29).n  <= 29;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(29).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k30 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(30).n  <= 30;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(30).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k31 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(31).n  <= 31;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(31).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k32 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(32).n  <= 32;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(32).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k33 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(33).n  <= 33;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(33).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k34 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(34).n  <= 34;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(34).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k35 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(35).n  <= 35;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(35).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k36 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(36).n  <= 36;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(36).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k37 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(37).n  <= 37;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(37).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k38 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(38).n  <= 38;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(38).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k39 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(39).n  <= 39;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(39).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k40 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(40).n  <= 40;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(40).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k41 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(41).n  <= 41;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(41).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k42 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(42).n  <= 42;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(42).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k43 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(43).n  <= 43;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(43).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k44 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(44).n  <= 44;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(44).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k45 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(45).n  <= 45;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(45).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k46 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(46).n  <= 46;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(46).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k47 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(47).n  <= 47;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(47).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k48 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(48).n  <= 48;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(48).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k49 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(49).n  <= 49;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(49).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k50 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(50).n  <= 50;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(50).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k51 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(51).n  <= 51;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(51).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k52 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(52).n  <= 52;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(52).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k53 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(53).n  <= 53;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(53).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k54 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(54).n  <= 54;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(54).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k55 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(55).n  <= 55;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(55).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k56 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(56).n  <= 56;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(56).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k57 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(57).n  <= 57;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(57).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k58 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(58).n  <= 58;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(58).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k59 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(59).n  <= 59;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(59).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k60 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(60).n  <= 60;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(60).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k61 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(61).n  <= 61;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(61).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k62 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(62).n  <= 62;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(62).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k63 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(63).n  <= 63;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(63).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k64 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(64).n  <= 64;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(64).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k65 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(65).n  <= 65;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(65).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k66 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(66).n  <= 66;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(66).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k67 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(67).n  <= 67;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(67).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k68 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(68).n  <= 68;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(68).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k69 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(69).n  <= 69;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(69).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k70 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(70).n  <= 70;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(70).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k71 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(71).n  <= 71;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(71).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k72 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(72).n  <= 72;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(72).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k73 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(73).n  <= 73;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(73).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k74 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(74).n  <= 74;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(74).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k75 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(75).n  <= 75;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(75).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k76 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(76).n  <= 76;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(76).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k77 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(77).n  <= 77;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(77).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k78 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(78).n  <= 78;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(78).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k79 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(79).n  <= 79;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(79).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k80 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(80).n  <= 80;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(80).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.red.k81 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.red.k(81).n  <= 81;
        else
            rgb_9x9_detect.filter_size_3x3.red.k(81).n  <= 0;
        end if;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        if(rgb_9x9_delta.filter_size_3x3.green.k1 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(1).n  <= 1;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(1).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k2 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(2).n  <= 2;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(2).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k3 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(3).n  <= 3;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(3).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k4 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(4).n  <= 4;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(4).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k5 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(5).n  <= 5;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(5).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k6 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(6).n  <= 6;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(6).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k7 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(7).n  <= 7;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(7).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k8 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(8).n  <= 8;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(8).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k9 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(9).n  <= 9;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(9).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k10 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(10).n  <= 10;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(10).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k11 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(11).n  <= 11;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(11).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k12 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(12).n  <= 12;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(12).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k13 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(13).n  <= 13;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(13).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k14 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(14).n  <= 14;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(14).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k15 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(15).n  <= 15;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(15).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k16 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(16).n  <= 16;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(16).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k17 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(17).n  <= 17;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(17).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k18 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(18).n  <= 18;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(18).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k19 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(19).n  <= 19;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(19).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k20 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(20).n  <= 20;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(20).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k21 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(21).n  <= 21;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(21).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k22 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(22).n  <= 22;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(22).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k23 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(23).n  <= 23;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(23).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k24 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(24).n  <= 24;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(24).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k25 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(25).n  <= 25;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(25).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k26 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(26).n  <= 26;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(26).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k27 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(27).n  <= 27;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(27).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k28 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(28).n  <= 28;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(28).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k29 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(29).n  <= 29;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(29).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k30 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(30).n  <= 30;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(30).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k31 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(31).n  <= 31;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(31).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k32 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(32).n  <= 32;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(32).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k33 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(33).n  <= 33;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(33).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k34 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(34).n  <= 34;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(34).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k35 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(35).n  <= 35;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(35).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k36 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(36).n  <= 36;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(36).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k37 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(37).n  <= 37;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(37).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k38 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(38).n  <= 38;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(38).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k39 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(39).n  <= 39;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(39).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k40 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(40).n  <= 40;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(40).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k41 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(41).n  <= 41;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(41).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k42 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(42).n  <= 42;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(42).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k43 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(43).n  <= 43;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(43).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k44 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(44).n  <= 44;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(44).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k45 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(45).n  <= 45;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(45).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k46 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(46).n  <= 46;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(46).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k47 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(47).n  <= 47;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(47).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k48 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(48).n  <= 48;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(48).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k49 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(49).n  <= 49;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(49).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k50 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(50).n  <= 50;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(50).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k51 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(51).n  <= 51;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(51).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k52 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(52).n  <= 52;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(52).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k53 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(53).n  <= 53;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(53).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k54 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(54).n  <= 54;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(54).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k55 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(55).n  <= 55;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(55).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k56 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(56).n  <= 56;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(56).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k57 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(57).n  <= 57;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(57).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k58 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(58).n  <= 58;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(58).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k59 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(59).n  <= 59;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(59).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k60 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(60).n  <= 60;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(60).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k61 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(61).n  <= 61;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(61).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k62 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(62).n  <= 62;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(62).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k63 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(63).n  <= 63;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(63).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k64 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(64).n  <= 64;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(64).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k65 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(65).n  <= 65;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(65).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k66 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(66).n  <= 66;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(66).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k67 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(67).n  <= 67;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(67).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k68 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(68).n  <= 68;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(68).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k69 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(69).n  <= 69;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(69).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k70 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(70).n  <= 70;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(70).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k71 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(71).n  <= 71;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(71).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k72 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(72).n  <= 72;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(72).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k73 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(73).n  <= 73;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(73).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k74 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(74).n  <= 74;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(74).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k75 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(75).n  <= 75;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(75).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k76 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(76).n  <= 76;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(76).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k77 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(77).n  <= 77;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(77).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k78 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(78).n  <= 78;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(78).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k79 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(79).n  <= 79;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(79).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k80 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(80).n  <= 80;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(80).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.green.k81 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.green.k(81).n  <= 81;
        else
            rgb_9x9_detect.filter_size_3x3.green.k(81).n  <= 0;
        end if;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        if(rgb_9x9_delta.filter_size_3x3.blue.k1 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(1).n  <= 1;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(1).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k2 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(2).n  <= 2;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(2).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k3 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(3).n  <= 3;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(3).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k4 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(4).n  <= 4;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(4).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k5 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(5).n  <= 5;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(5).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k6 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(6).n  <= 6;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(6).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k7 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(7).n  <= 7;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(7).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k8 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(8).n  <= 8;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(8).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k9 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(9).n  <= 9;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(9).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k10 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(10).n  <= 10;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(10).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k11 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(11).n  <= 11;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(11).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k12 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(12).n  <= 12;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(12).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k13 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(13).n  <= 13;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(13).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k14 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(14).n  <= 14;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(14).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k15 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(15).n  <= 15;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(15).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k16 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(16).n  <= 16;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(16).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k17 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(17).n  <= 17;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(17).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k18 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(18).n  <= 18;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(18).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k19 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(19).n  <= 19;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(19).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k20 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(20).n  <= 20;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(20).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k21 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(21).n  <= 21;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(21).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k22 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(22).n  <= 22;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(22).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k23 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(23).n  <= 23;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(23).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k24 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(24).n  <= 24;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(24).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k25 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(25).n  <= 25;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(25).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k26 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(26).n  <= 26;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(26).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k27 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(27).n  <= 27;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(27).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k28 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(28).n  <= 28;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(28).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k29 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(29).n  <= 29;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(29).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k30 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(30).n  <= 30;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(30).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k31 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(31).n  <= 31;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(31).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k32 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(32).n  <= 32;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(32).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k33 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(33).n  <= 33;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(33).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k34 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(34).n  <= 34;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(34).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k35 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(35).n  <= 35;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(35).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k36 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(36).n  <= 36;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(36).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k37 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(37).n  <= 37;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(37).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k38 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(38).n  <= 38;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(38).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k39 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(39).n  <= 39;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(39).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k40 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(40).n  <= 40;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(40).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k41 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(41).n  <= 41;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(41).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k42 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(42).n  <= 42;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(42).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k43 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(43).n  <= 43;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(43).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k44 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(44).n  <= 44;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(44).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k45 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(45).n  <= 45;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(45).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k46 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(46).n  <= 46;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(46).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k47 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(47).n  <= 47;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(47).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k48 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(48).n  <= 48;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(48).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k49 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(49).n  <= 49;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(49).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k50 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(50).n  <= 50;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(50).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k51 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(51).n  <= 51;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(51).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k52 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(52).n  <= 52;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(52).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k53 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(53).n  <= 53;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(53).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k54 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(54).n  <= 54;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(54).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k55 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(55).n  <= 55;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(55).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k56 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(56).n  <= 56;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(56).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k57 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(57).n  <= 57;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(57).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k58 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(58).n  <= 58;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(58).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k59 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(59).n  <= 59;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(59).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k60 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(60).n  <= 60;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(60).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k61 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(61).n  <= 61;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(61).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k62 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(62).n  <= 62;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(62).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k63 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(63).n  <= 63;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(63).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k64 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(64).n  <= 64;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(64).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k65 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(65).n  <= 65;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(65).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k66 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(66).n  <= 66;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(66).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k67 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(67).n  <= 67;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(67).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k68 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(68).n  <= 68;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(68).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k69 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(69).n  <= 69;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(69).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k70 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(70).n  <= 70;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(70).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k71 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(71).n  <= 71;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(71).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k72 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(72).n  <= 72;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(72).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k73 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(73).n  <= 73;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(73).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k74 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(74).n  <= 74;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(74).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k75 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(75).n  <= 75;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(75).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k76 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(76).n  <= 76;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(76).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k77 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(77).n  <= 77;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(77).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k78 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(78).n  <= 78;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(78).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k79 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(79).n  <= 79;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(79).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k80 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(80).n  <= 80;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(80).n  <= 0;
        end if;
        if(rgb_9x9_delta.filter_size_3x3.blue.k81 <= pixel_threshold_2) then
            rgb_9x9_detect.filter_size_3x3.blue.k(81).n  <= 81;
        else
            rgb_9x9_detect.filter_size_3x3.blue.k(81).n  <= 0;
        end if;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        if reset = '0' then
            tpd1.row_1    <= (others => '0');
            tpd1.row_2    <= (others => '0');
            tpd1.row_3    <= (others => '0');
            tpd1.row_4    <= (others => '0');
            tpd2.row_1    <= (others => '0');
            tpd2.row_2    <= (others => '0');
            tpd2.row_3    <= (others => '0');
            tpd2.row_4    <= (others => '0');
            tpd3.row_1    <= (others => '0');
            tpd3.row_2    <= (others => '0');
            tpd3.row_3    <= (others => '0');
            tpd3.row_4    <= (others => '0');
            tpd4.row_1    <= (others => '0');
            tpd4.row_2    <= (others => '0');
            tpd4.row_3    <= (others => '0');
            tpd4.row_4    <= (others => '0');
        else
            tpd1.row_1    <= v1TapRGB0x;
            tpd2.row_1    <= tpd1.row_1;
            tpd3.row_1    <= tpd2.row_1;
            tpd4.row_1    <= tpd3.row_1;
            tpd1.row_2    <= v1TapRGB1x;
            tpd2.row_2    <= tpd1.row_2;
            tpd3.row_2    <= tpd2.row_2;
            tpd4.row_2    <= tpd3.row_2;
            tpd1.row_3    <= v1TapRGB2x;
            tpd2.row_3    <= tpd1.row_3;
            tpd3.row_3    <= tpd2.row_3;
            tpd4.row_3    <= tpd3.row_3;
            tpd1.row_4    <= v1TapRGB3x;
            tpd2.row_4    <= tpd1.row_4;
            tpd3.row_4    <= tpd2.row_4;
            tpd4.row_4    <= tpd3.row_4;
            syn1KernalData_red.k1  <= tpd4.row_1(23 downto 16);
            syn1KernalData_red.k2  <= tpd3.row_1(23 downto 16);
            syn1KernalData_red.k3  <= tpd2.row_1(23 downto 16);
            syn1KernalData_red.k4  <= tpd1.row_1(23 downto 16);
            syn1KernalData_red.k5  <= tpd4.row_2(23 downto 16);
            syn1KernalData_red.k6  <= tpd3.row_2(23 downto 16);
            syn1KernalData_red.k7  <= tpd2.row_2(23 downto 16);
            syn1KernalData_red.k8  <= tpd1.row_2(23 downto 16);
            syn1KernalData_red.k9  <= tpd4.row_3(23 downto 16);
            syn1KernalData_red.k10 <= tpd3.row_3(23 downto 16);
            syn1KernalData_red.k11 <= tpd2.row_3(23 downto 16);
            syn1KernalData_red.k12 <= tpd1.row_3(23 downto 16);
            syn1KernalData_red.k13 <= tpd4.row_4(23 downto 16);
            syn1KernalData_red.k14 <= tpd3.row_4(23 downto 16);
            syn1KernalData_red.k15 <= tpd2.row_4(23 downto 16);
            syn1KernalData_red.k16 <= tpd1.row_4(23 downto 16);
            syn2KernalData_red     <= syn1KernalData_red;
            syn3KernalData_red     <= syn2KernalData_red;
            syn4KernalData_red     <= syn3KernalData_red;
            syn5KernalData_red     <= syn4KernalData_red;
            synaKernalData_red     <= syn5KernalData_red;
            synbKernalData_red     <= synaKernalData_red;
        --========================================================================================
            syn1KernalData_gre.k1  <= tpd4.row_1(15 downto 8);
            syn1KernalData_gre.k2  <= tpd3.row_1(15 downto 8);
            syn1KernalData_gre.k3  <= tpd2.row_1(15 downto 8);
            syn1KernalData_gre.k4  <= tpd1.row_1(15 downto 8);
            syn1KernalData_gre.k5  <= tpd4.row_2(15 downto 8);
            syn1KernalData_gre.k6  <= tpd3.row_2(15 downto 8);
            syn1KernalData_gre.k7  <= tpd2.row_2(15 downto 8);
            syn1KernalData_gre.k8  <= tpd1.row_2(15 downto 8);
            syn1KernalData_gre.k9  <= tpd4.row_3(15 downto 8);
            syn1KernalData_gre.k10 <= tpd3.row_3(15 downto 8);
            syn1KernalData_gre.k11 <= tpd2.row_3(15 downto 8);
            syn1KernalData_gre.k12 <= tpd1.row_3(15 downto 8);
            syn1KernalData_gre.k13 <= tpd4.row_4(15 downto 8);
            syn1KernalData_gre.k14 <= tpd3.row_4(15 downto 8);
            syn1KernalData_gre.k15 <= tpd2.row_4(15 downto 8);
            syn1KernalData_gre.k16 <= tpd1.row_4(15 downto 8);
            syn2KernalData_gre     <= syn1KernalData_gre;
            syn3KernalData_gre     <= syn2KernalData_gre;
            syn4KernalData_gre     <= syn3KernalData_gre;
            syn5KernalData_gre     <= syn4KernalData_gre;
            synaKernalData_gre     <= syn5KernalData_gre;
            synbKernalData_gre     <= synaKernalData_gre;
        --========================================================================================
            syn1KernalData_blu.k1  <= tpd4.row_1(7 downto 0);
            syn1KernalData_blu.k2  <= tpd3.row_1(7 downto 0);
            syn1KernalData_blu.k3  <= tpd2.row_1(7 downto 0);
            syn1KernalData_blu.k4  <= tpd1.row_1(7 downto 0);
            syn1KernalData_blu.k5  <= tpd4.row_2(7 downto 0);
            syn1KernalData_blu.k6  <= tpd3.row_2(7 downto 0);
            syn1KernalData_blu.k7  <= tpd2.row_2(7 downto 0);
            syn1KernalData_blu.k8  <= tpd1.row_2(7 downto 0);
            syn1KernalData_blu.k9  <= tpd4.row_3(7 downto 0);
            syn1KernalData_blu.k10 <= tpd3.row_3(7 downto 0);
            syn1KernalData_blu.k11 <= tpd2.row_3(7 downto 0);
            syn1KernalData_blu.k12 <= tpd1.row_3(7 downto 0);
            syn1KernalData_blu.k13 <= tpd4.row_4(7 downto 0);
            syn1KernalData_blu.k14 <= tpd3.row_4(7 downto 0);
            syn1KernalData_blu.k15 <= tpd2.row_4(7 downto 0);
            syn1KernalData_blu.k16 <= tpd1.row_4(7 downto 0);
            syn2KernalData_blu     <= syn1KernalData_blu;
            syn3KernalData_blu     <= syn2KernalData_blu;
            syn4KernalData_blu     <= syn3KernalData_blu;
            syn5KernalData_blu     <= syn4KernalData_blu;
            synaKernalData_blu     <= syn5KernalData_blu;
            synbKernalData_blu     <= synaKernalData_blu;
        --========================================================================================
        end if;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
            syn6KernalData_red.k1  <= synbKernalData_red.k1;
            syn6KernalData_red.k2  <= synbKernalData_red.k2;
            syn6KernalData_red.k3  <= synbKernalData_red.k3;
            syn6KernalData_red.k4  <= synbKernalData_red.k4;
            syn6KernalData_red.k5  <= syn4KernalData_red.k5;
            syn6KernalData_red.k6  <= syn4KernalData_red.k6;
            syn6KernalData_red.k7  <= syn4KernalData_red.k7;
            syn6KernalData_red.k8  <= syn4KernalData_red.k8;
            syn6KernalData_red.k9  <= syn3KernalData_red.k9;
            syn6KernalData_red.k10 <= syn3KernalData_red.k10;
            syn6KernalData_red.k11 <= syn3KernalData_red.k11;
            syn6KernalData_red.k12 <= syn3KernalData_red.k12;
            syn6KernalData_red.k13 <= syn2KernalData_red.k13;
            syn6KernalData_red.k14 <= syn2KernalData_red.k14;
            syn6KernalData_red.k15 <= syn2KernalData_red.k15;
            syn6KernalData_red.k16 <= syn2KernalData_red.k16;
        --========================================================================================
            syn6KernalData_gre.k1  <= synbKernalData_gre.k1;
            syn6KernalData_gre.k2  <= synbKernalData_gre.k2;
            syn6KernalData_gre.k3  <= synbKernalData_gre.k3;
            syn6KernalData_gre.k4  <= synbKernalData_gre.k4;
            syn6KernalData_gre.k5  <= syn4KernalData_gre.k5;
            syn6KernalData_gre.k6  <= syn4KernalData_gre.k6;
            syn6KernalData_gre.k7  <= syn4KernalData_gre.k7;
            syn6KernalData_gre.k8  <= syn4KernalData_gre.k8;
            syn6KernalData_gre.k9  <= syn3KernalData_gre.k9;
            syn6KernalData_gre.k10 <= syn3KernalData_gre.k10;
            syn6KernalData_gre.k11 <= syn3KernalData_gre.k11;
            syn6KernalData_gre.k12 <= syn3KernalData_gre.k12;
            syn6KernalData_gre.k13 <= syn2KernalData_gre.k13;
            syn6KernalData_gre.k14 <= syn2KernalData_gre.k14;
            syn6KernalData_gre.k15 <= syn2KernalData_gre.k15;
            syn6KernalData_gre.k16 <= syn2KernalData_gre.k16;
        --========================================================================================
            syn6KernalData_blu.k1  <= synbKernalData_blu.k1;
            syn6KernalData_blu.k2  <= synbKernalData_blu.k2;
            syn6KernalData_blu.k3  <= synbKernalData_blu.k3;
            syn6KernalData_blu.k4  <= synbKernalData_blu.k4;
            syn6KernalData_blu.k5  <= syn4KernalData_blu.k5;
            syn6KernalData_blu.k6  <= syn4KernalData_blu.k6;
            syn6KernalData_blu.k7  <= syn4KernalData_blu.k7;
            syn6KernalData_blu.k8  <= syn4KernalData_blu.k8;
            syn6KernalData_blu.k9  <= syn3KernalData_blu.k9;
            syn6KernalData_blu.k10 <= syn3KernalData_blu.k10;
            syn6KernalData_blu.k11 <= syn3KernalData_blu.k11;
            syn6KernalData_blu.k12 <= syn3KernalData_blu.k12;
            syn6KernalData_blu.k13 <= syn2KernalData_blu.k13;
            syn6KernalData_blu.k14 <= syn2KernalData_blu.k14;
            syn6KernalData_blu.k15 <= syn2KernalData_blu.k15;
            syn6KernalData_blu.k16 <= syn2KernalData_blu.k16;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        --========================================================================================
        red_on.k1    <= to_integer(unsigned(syn6KernalData_red.k1));
        red_on.k2    <= to_integer(unsigned(syn6KernalData_red.k2)); 
        red_on.k3    <= to_integer(unsigned(syn6KernalData_red.k3)); 
        red_on.k4    <= to_integer(unsigned(syn6KernalData_red.k4)); 
        red_on.k5    <= to_integer(unsigned(syn6KernalData_red.k5)); 
        red_on.k6    <= to_integer(unsigned(syn6KernalData_red.k6)); 
        red_on.k7    <= to_integer(unsigned(syn6KernalData_red.k7)); 
        red_on.k8    <= to_integer(unsigned(syn6KernalData_red.k8)); 
        red_on.k9    <= to_integer(unsigned(syn6KernalData_red.k9)); 
        red_on.k10   <= to_integer(unsigned(syn6KernalData_red.k10));
        red_on.k11   <= to_integer(unsigned(syn6KernalData_red.k11));
        red_on.k12   <= to_integer(unsigned(syn6KernalData_red.k12));
        red_on.k13   <= to_integer(unsigned(syn6KernalData_red.k13));
        red_on.k14   <= to_integer(unsigned(syn6KernalData_red.k14));
        red_on.k15   <= to_integer(unsigned(syn6KernalData_red.k15));
        red_on.k16   <= to_integer(unsigned(syn6KernalData_red.k16));
        gre_on.k1    <= to_integer(unsigned(syn6KernalData_gre.k1));
        gre_on.k2    <= to_integer(unsigned(syn6KernalData_gre.k2)); 
        gre_on.k3    <= to_integer(unsigned(syn6KernalData_gre.k3)); 
        gre_on.k4    <= to_integer(unsigned(syn6KernalData_gre.k4)); 
        gre_on.k5    <= to_integer(unsigned(syn6KernalData_gre.k5)); 
        gre_on.k6    <= to_integer(unsigned(syn6KernalData_gre.k6)); 
        gre_on.k7    <= to_integer(unsigned(syn6KernalData_gre.k7)); 
        gre_on.k8    <= to_integer(unsigned(syn6KernalData_gre.k8)); 
        gre_on.k9    <= to_integer(unsigned(syn6KernalData_gre.k9)); 
        gre_on.k10   <= to_integer(unsigned(syn6KernalData_gre.k10));
        gre_on.k11   <= to_integer(unsigned(syn6KernalData_gre.k11));
        gre_on.k12   <= to_integer(unsigned(syn6KernalData_gre.k12));
        gre_on.k13   <= to_integer(unsigned(syn6KernalData_gre.k13));
        gre_on.k14   <= to_integer(unsigned(syn6KernalData_gre.k14));
        gre_on.k15   <= to_integer(unsigned(syn6KernalData_gre.k15));
        gre_on.k16   <= to_integer(unsigned(syn6KernalData_gre.k16));
        blu_on.k1    <= to_integer(unsigned(syn6KernalData_blu.k1));
        blu_on.k2    <= to_integer(unsigned(syn6KernalData_blu.k2)); 
        blu_on.k3    <= to_integer(unsigned(syn6KernalData_blu.k3)); 
        blu_on.k4    <= to_integer(unsigned(syn6KernalData_blu.k4)); 
        blu_on.k5    <= to_integer(unsigned(syn6KernalData_blu.k5)); 
        blu_on.k6    <= to_integer(unsigned(syn6KernalData_blu.k6)); 
        blu_on.k7    <= to_integer(unsigned(syn6KernalData_blu.k7)); 
        blu_on.k8    <= to_integer(unsigned(syn6KernalData_blu.k8)); 
        blu_on.k9    <= to_integer(unsigned(syn6KernalData_blu.k9)); 
        blu_on.k10   <= to_integer(unsigned(syn6KernalData_blu.k10));
        blu_on.k11   <= to_integer(unsigned(syn6KernalData_blu.k11));
        blu_on.k12   <= to_integer(unsigned(syn6KernalData_blu.k12));
        blu_on.k13   <= to_integer(unsigned(syn6KernalData_blu.k13));
        blu_on.k14   <= to_integer(unsigned(syn6KernalData_blu.k14));
        blu_on.k15   <= to_integer(unsigned(syn6KernalData_blu.k15));
        blu_on.k16   <= to_integer(unsigned(syn6KernalData_blu.k16));
    end if;
end process;
        --========================================================================================
        -- STAGE 1
        --========================================================================================
process (clk) begin
    if rising_edge(clk) then
        red_on.delta.k1      <= abs(red_on.k6 - red_on.k1);
        red_on.delta.k2      <= abs(red_on.k6 - red_on.k2);
        red_on.delta.k3      <= abs(red_on.k6 - red_on.k3);
        red_on.delta.k4      <= abs(red_on.k6 - red_on.k4);
        red_on.delta.k5      <= abs(red_on.k6 - red_on.k5);
        red_on.delta.k6      <= abs(red_on.k6 - red_on.k6);
        red_on.delta.k7      <= abs(red_on.k6 - red_on.k7);
        red_on.delta.k8      <= abs(red_on.k6 - red_on.k8);
        red_on.delta.k9      <= abs(red_on.k6 - red_on.k9);
        red_on.delta.k10     <= abs(red_on.k6 - red_on.k10);
        red_on.delta.k11     <= abs(red_on.k6 - red_on.k11);
        red_on.delta.k12     <= abs(red_on.k6 - red_on.k12);
        red_on.delta.k13     <= abs(red_on.k6 - red_on.k13);
        red_on.delta.k14     <= abs(red_on.k6 - red_on.k14);
        red_on.delta.k15     <= abs(red_on.k6 - red_on.k15);
        red_on.delta.k16     <= abs(red_on.k6 - red_on.k16);
        gre_on.delta.k1      <= abs(gre_on.k6 - gre_on.k1);
        gre_on.delta.k2      <= abs(gre_on.k6 - gre_on.k2);
        gre_on.delta.k3      <= abs(gre_on.k6 - gre_on.k3);
        gre_on.delta.k4      <= abs(gre_on.k6 - gre_on.k4);
        gre_on.delta.k5      <= abs(gre_on.k6 - gre_on.k5);
        gre_on.delta.k6      <= abs(gre_on.k6 - gre_on.k6);
        gre_on.delta.k7      <= abs(gre_on.k6 - gre_on.k7);
        gre_on.delta.k8      <= abs(gre_on.k6 - gre_on.k8);
        gre_on.delta.k9      <= abs(gre_on.k6 - gre_on.k9);
        gre_on.delta.k10     <= abs(gre_on.k6 - gre_on.k10);
        gre_on.delta.k11     <= abs(gre_on.k6 - gre_on.k11);
        gre_on.delta.k12     <= abs(gre_on.k6 - gre_on.k12);
        gre_on.delta.k13     <= abs(gre_on.k6 - gre_on.k13);
        gre_on.delta.k14     <= abs(gre_on.k6 - gre_on.k14);
        gre_on.delta.k15     <= abs(gre_on.k6 - gre_on.k15);
        gre_on.delta.k16     <= abs(gre_on.k6 - gre_on.k16);
        blu_on.delta.k1      <= abs(blu_on.k6 - blu_on.k1);
        blu_on.delta.k2      <= abs(blu_on.k6 - blu_on.k2);
        blu_on.delta.k3      <= abs(blu_on.k6 - blu_on.k3);
        blu_on.delta.k4      <= abs(blu_on.k6 - blu_on.k4);
        blu_on.delta.k5      <= abs(blu_on.k6 - blu_on.k5);
        blu_on.delta.k6      <= abs(blu_on.k6 - blu_on.k6);
        blu_on.delta.k7      <= abs(blu_on.k6 - blu_on.k7);
        blu_on.delta.k8      <= abs(blu_on.k6 - blu_on.k8);
        blu_on.delta.k9      <= abs(blu_on.k6 - blu_on.k9);
        blu_on.delta.k10     <= abs(blu_on.k6 - blu_on.k10);
        blu_on.delta.k11     <= abs(blu_on.k6 - blu_on.k11);
        blu_on.delta.k12     <= abs(blu_on.k6 - blu_on.k12);
        blu_on.delta.k13     <= abs(blu_on.k6 - blu_on.k13);
        blu_on.delta.k14     <= abs(blu_on.k6 - blu_on.k14);
        blu_on.delta.k15     <= abs(blu_on.k6 - blu_on.k15);
        blu_on.delta.k16     <= abs(blu_on.k6 - blu_on.k16);
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        red_select.sumprod_2.k1             <= red_on.k1; 
        red_select.sumprod_2.k2             <= red_on.k2; 
        red_select.sumprod_2.k3             <= red_on.k3; 
        red_select.sumprod_2.k4             <= red_on.k4; 
        red_select.sumprod_2.k5             <= red_on.k5; 
        red_select.sumprod_2.k6             <= red_on.k6; 
        red_select.sumprod_2.k7             <= red_on.k7; 
        red_select.sumprod_2.k8             <= red_on.k8; 
        red_select.sumprod_2.k9             <= red_on.k9; 
        red_select.sumprod_2.k10            <= red_on.k10;
        red_select.sumprod_2.k11            <= red_on.k11;
        red_select.sumprod_2.k12            <= red_on.k12;
        red_select.sumprod_2.k13            <= red_on.k13;
        red_select.sumprod_2.k14            <= red_on.k14;
        red_select.sumprod_2.k15            <= red_on.k15;
        red_select.sumprod_2.k16            <= red_on.k16;
        gre_select.sumprod_2.k1             <= gre_on.k1; 
        gre_select.sumprod_2.k2             <= gre_on.k2; 
        gre_select.sumprod_2.k3             <= gre_on.k3; 
        gre_select.sumprod_2.k4             <= gre_on.k4; 
        gre_select.sumprod_2.k5             <= gre_on.k5; 
        gre_select.sumprod_2.k6             <= gre_on.k6; 
        gre_select.sumprod_2.k7             <= gre_on.k7; 
        gre_select.sumprod_2.k8             <= gre_on.k8; 
        gre_select.sumprod_2.k9             <= gre_on.k9; 
        gre_select.sumprod_2.k10            <= gre_on.k10;
        gre_select.sumprod_2.k11            <= gre_on.k11;
        gre_select.sumprod_2.k12            <= gre_on.k12;
        gre_select.sumprod_2.k13            <= gre_on.k13;
        gre_select.sumprod_2.k14            <= gre_on.k14;
        gre_select.sumprod_2.k15            <= gre_on.k15;
        gre_select.sumprod_2.k16            <= gre_on.k16;
        blu_select.sumprod_2.k1             <= blu_on.k1; 
        blu_select.sumprod_2.k2             <= blu_on.k2; 
        blu_select.sumprod_2.k3             <= blu_on.k3; 
        blu_select.sumprod_2.k4             <= blu_on.k4; 
        blu_select.sumprod_2.k5             <= blu_on.k5; 
        blu_select.sumprod_2.k6             <= blu_on.k6; 
        blu_select.sumprod_2.k7             <= blu_on.k7; 
        blu_select.sumprod_2.k8             <= blu_on.k8; 
        blu_select.sumprod_2.k9             <= blu_on.k9; 
        blu_select.sumprod_2.k10            <= blu_on.k10;
        blu_select.sumprod_2.k11            <= blu_on.k11;
        blu_select.sumprod_2.k12            <= blu_on.k12;
        blu_select.sumprod_2.k13            <= blu_on.k13;
        blu_select.sumprod_2.k14            <= blu_on.k14;
        blu_select.sumprod_2.k15            <= blu_on.k15;
        blu_select.sumprod_2.k16            <= blu_on.k16;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        red_detect.k_syn_1  <= red_detect.k;
        red_detect.k_syn_2  <= red_detect.k_syn_1;
        red_detect.k_syn_3  <= red_detect.k_syn_2;
        red_detect.k_syn_4  <= red_detect.k_syn_3;
        red_detect.k_syn_5  <= red_detect.k_syn_4;
        red_detect.k_syn_6  <= red_detect.k_syn_5;
        red_detect.k_syn_7  <= red_detect.k_syn_6;
        red_detect.k_syn_8  <= red_detect.k_syn_7;
        red_detect.k_syn_9  <= red_detect.k_syn_8;
        red_detect.k_syn_10 <= red_detect.k_syn_9;
        red_detect.k_syn_11 <= red_detect.k_syn_10;
        red_detect.k_syn_12 <= red_detect.k_syn_11;
        gre_detect.k_syn_1  <= gre_detect.k;
        gre_detect.k_syn_2  <= gre_detect.k_syn_1;
        gre_detect.k_syn_3  <= gre_detect.k_syn_2;
        gre_detect.k_syn_4  <= gre_detect.k_syn_3;
        gre_detect.k_syn_5  <= gre_detect.k_syn_4;
        gre_detect.k_syn_6  <= gre_detect.k_syn_5;
        gre_detect.k_syn_7  <= gre_detect.k_syn_6;
        gre_detect.k_syn_8  <= gre_detect.k_syn_7;
        gre_detect.k_syn_9  <= gre_detect.k_syn_8;
        gre_detect.k_syn_10 <= gre_detect.k_syn_9;
        gre_detect.k_syn_11 <= gre_detect.k_syn_10;
        gre_detect.k_syn_12 <= gre_detect.k_syn_11;
        blu_detect.k_syn_1  <= blu_detect.k;
        blu_detect.k_syn_2  <= blu_detect.k_syn_1;
        blu_detect.k_syn_3  <= blu_detect.k_syn_2;
        blu_detect.k_syn_4  <= blu_detect.k_syn_3;
        blu_detect.k_syn_5  <= blu_detect.k_syn_4;
        blu_detect.k_syn_6  <= blu_detect.k_syn_5;
        blu_detect.k_syn_7  <= blu_detect.k_syn_6;
        blu_detect.k_syn_8  <= blu_detect.k_syn_7;
        blu_detect.k_syn_9  <= blu_detect.k_syn_8;
        blu_detect.k_syn_10 <= blu_detect.k_syn_9;
        blu_detect.k_syn_11 <= blu_detect.k_syn_10;
        blu_detect.k_syn_12 <= blu_detect.k_syn_11;
    end if;
end process;
--=================================================================================================
process (clk) begin
    if rising_edge(clk) then
       -- ∆P|xy| <- TH {set [Pn(xy)+Pn+1(xy)]}
        if(red_on.delta.k1 <= pixel_threshold_2) then
            red_detect.k(1).n  <= 1;
        else
            red_detect.k(1).n  <= 0;
        end if;
        if(red_on.delta.k2 <= pixel_threshold_2) then
            red_detect.k(2).n  <= 2;
        else
            red_detect.k(2).n  <= 0;
        end if;
        if(red_on.delta.k3 <= pixel_threshold_2) then
            red_detect.k(3).n  <= 3;
        else
            red_detect.k(3).n  <= 0;
        end if;
        if(red_on.delta.k4 <= pixel_threshold_2) then
            red_detect.k(4).n  <= 4;
        else
            red_detect.k(4).n  <= 0;
        end if;
        if(red_on.delta.k5 <= pixel_threshold_2) then
            red_detect.k(5).n  <= 5;
        else
            red_detect.k(5).n  <= 0;
        end if;
        if(red_on.delta.k6 <= pixel_threshold_2) then
            red_detect.k(6).n  <= 6;
        else
            red_detect.k(6).n  <= 0;
        end if;
        if(red_on.delta.k7 <= pixel_threshold_2) then
            red_detect.k(7).n  <= 7;
        else
            red_detect.k(7).n  <= 0;
        end if;
        if(red_on.delta.k8 <= pixel_threshold_2) then
            red_detect.k(8).n  <= 8;
        else
            red_detect.k(8).n  <= 0;
        end if;
        if(red_on.delta.k9 <= pixel_threshold_2) then
            red_detect.k(9).n  <= 9;
        else
            red_detect.k(9).n  <= 0;
        end if;
        if(red_on.delta.k10 <= pixel_threshold_2) then
            red_detect.k(10).n  <= 10;
        else
            red_detect.k(10).n  <= 0;
        end if;
        if(red_on.delta.k11 <= pixel_threshold_2) then
            red_detect.k(11).n  <= 11;
        else
            red_detect.k(11).n  <= 0;
        end if;
        if(red_on.delta.k12 <= pixel_threshold_2) then
            red_detect.k(12).n  <= 12;
        else
            red_detect.k(12).n  <= 0;
        end if;
        if(red_on.delta.k13 <= pixel_threshold_2) then
            red_detect.k(13).n  <= 13;
        else
            red_detect.k(13).n  <= 0;
        end if;
        if(red_on.delta.k14 <= pixel_threshold_2) then
            red_detect.k(14).n  <= 14;
        else
            red_detect.k(14).n  <= 0;
        end if;
        if(red_on.delta.k15 <= pixel_threshold_2) then
            red_detect.k(15).n  <= 15;
        else
            red_detect.k(15).n  <= 0;
        end if;
        if(red_on.delta.k16 <= pixel_threshold_2) then
            red_detect.k(16).n  <= 16;
        else
            red_detect.k(16).n  <= 0;
        end if;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
       -- ∆P|xy| <- TH {set [Pn(xy)+Pn+1(xy)]}
        if(gre_on.delta.k1 <= pixel_threshold_2) then
            gre_detect.k(1).n  <= 1;
        else
            gre_detect.k(1).n  <= 0;
        end if;
        if(gre_on.delta.k2 <= pixel_threshold_2) then
            gre_detect.k(2).n  <= 2;
        else
            gre_detect.k(2).n  <= 0;
        end if;
        if(gre_on.delta.k3 <= pixel_threshold_2) then
            gre_detect.k(3).n  <= 3;
        else
            gre_detect.k(3).n  <= 0;
        end if;
        if(gre_on.delta.k4 <= pixel_threshold_2) then
            gre_detect.k(4).n  <= 4;
        else
            gre_detect.k(4).n  <= 0;
        end if;
        if(gre_on.delta.k5 <= pixel_threshold_2) then
            gre_detect.k(5).n  <= 5;
        else
            gre_detect.k(5).n  <= 0;
        end if;
        if(gre_on.delta.k6 <= pixel_threshold_2) then
            gre_detect.k(6).n  <= 6;
        else
            gre_detect.k(6).n  <= 0;
        end if;
        if(gre_on.delta.k7 <= pixel_threshold_2) then
            gre_detect.k(7).n  <= 7;
        else
            gre_detect.k(7).n  <= 0;
        end if;
        if(gre_on.delta.k8 <= pixel_threshold_2) then
            gre_detect.k(8).n  <= 8;
        else
            gre_detect.k(8).n  <= 0;
        end if;
        if(gre_on.delta.k9 <= pixel_threshold_2) then
            gre_detect.k(9).n  <= 9;
        else
            gre_detect.k(9).n  <= 0;
        end if;
        if(gre_on.delta.k10 <= pixel_threshold_2) then
            gre_detect.k(10).n  <= 10;
        else
            gre_detect.k(10).n  <= 0;
        end if;
        if(gre_on.delta.k11 <= pixel_threshold_2) then
            gre_detect.k(11).n  <= 11;
        else
            gre_detect.k(11).n  <= 0;
        end if;
        if(gre_on.delta.k12 <= pixel_threshold_2) then
            gre_detect.k(12).n  <= 12;
        else
            gre_detect.k(12).n  <= 0;
        end if;
        if(gre_on.delta.k13 <= pixel_threshold_2) then
            gre_detect.k(13).n  <= 13;
        else
            gre_detect.k(13).n  <= 0;
        end if;
        if(gre_on.delta.k14 <= pixel_threshold_2) then
            gre_detect.k(14).n  <= 14;
        else
            gre_detect.k(14).n  <= 0;
        end if;
        if(gre_on.delta.k15 <= pixel_threshold_2) then
            gre_detect.k(15).n  <= 15;
        else
            gre_detect.k(15).n  <= 0;
        end if;
        if(gre_on.delta.k16 <= pixel_threshold_2) then
            gre_detect.k(16).n  <= 16;
        else
            gre_detect.k(16).n  <= 0;
        end if;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
       -- ∆P|xy| <- TH {set [Pn(xy)+Pn+1(xy)]}
        if(blu_on.delta.k1 <= pixel_threshold_2) then
            blu_detect.k(1).n  <= 1;
        else
            blu_detect.k(1).n  <= 0;
        end if;
        if(blu_on.delta.k2 <= pixel_threshold_2) then
            blu_detect.k(2).n  <= 2;
        else
            blu_detect.k(2).n  <= 0;
        end if;
        if(blu_on.delta.k3 <= pixel_threshold_2) then
            blu_detect.k(3).n  <= 3;
        else
            blu_detect.k(3).n  <= 0;
        end if;
        if(blu_on.delta.k4 <= pixel_threshold_2) then
            blu_detect.k(4).n  <= 4;
        else
            blu_detect.k(4).n  <= 0;
        end if;
        if(blu_on.delta.k5 <= pixel_threshold_2) then
            blu_detect.k(5).n  <= 5;
        else
            blu_detect.k(5).n  <= 0;
        end if;
        if(blu_on.delta.k6 <= pixel_threshold_2) then
            blu_detect.k(6).n  <= 6;
        else
            blu_detect.k(6).n  <= 0;
        end if;
        if(blu_on.delta.k7 <= pixel_threshold_2) then
            blu_detect.k(7).n  <= 7;
        else
            blu_detect.k(7).n  <= 0;
        end if;
        if(blu_on.delta.k8 <= pixel_threshold_2) then
            blu_detect.k(8).n  <= 8;
        else
            blu_detect.k(8).n  <= 0;
        end if;
        if(blu_on.delta.k9 <= pixel_threshold_2) then
            blu_detect.k(9).n  <= 9;
        else
            blu_detect.k(9).n  <= 0;
        end if;
        if(blu_on.delta.k10 <= pixel_threshold_2) then
            blu_detect.k(10).n  <= 10;
        else
            blu_detect.k(10).n  <= 0;
        end if;
        if(blu_on.delta.k11 <= pixel_threshold_2) then
            blu_detect.k(11).n  <= 11;
        else
            blu_detect.k(11).n  <= 0;
        end if;
        if(blu_on.delta.k12 <= pixel_threshold_2) then
            blu_detect.k(12).n  <= 12;
        else
            blu_detect.k(12).n  <= 0;
        end if;
        if(blu_on.delta.k13 <= pixel_threshold_2) then
            blu_detect.k(13).n  <= 13;
        else
            blu_detect.k(13).n  <= 0;
        end if;
        if(blu_on.delta.k14 <= pixel_threshold_2) then
            blu_detect.k(14).n  <= 14;
        else
            blu_detect.k(14).n  <= 0;
        end if;
        if(blu_on.delta.k15 <= pixel_threshold_2) then
            blu_detect.k(15).n  <= 15;
        else
            blu_detect.k(15).n  <= 0;
        end if;
        if(blu_on.delta.k16 <= pixel_threshold_2) then
            blu_detect.k(16).n  <= 16;
        else
            blu_detect.k(16).n  <= 0;
        end if;
    end if;
end process;
--=================================================================================================
process (clk) begin
    if rising_edge(clk) then
            red_select.sumprod_2n         <= red_select.sumprod_2;
            red_select.sumprod_3n         <= red_select.sumprod_2n;
            red_select.sumprod_4n         <= red_select.sumprod_3n;
            red_select.sumprod_5n         <= red_select.sumprod_4n;
            red_select.sumprod_6n         <= red_select.sumprod_5n;
            red_select.sumprod_7n         <= red_select.sumprod_6n;
            red_select.sumprod_8n         <= red_select.sumprod_7n;
            red_select.sumprod_9n         <= red_select.sumprod_8n;
            red_select.sumprod_An         <= red_select.sumprod_9n;
            red_select.sumprod_Bn         <= red_select.sumprod_An;
            red_select.sumprod_Cn         <= red_select.sumprod_Bn;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
            gre_select.sumprod_2n       <= gre_select.sumprod_2;
            gre_select.sumprod_3n       <= gre_select.sumprod_2n;
            gre_select.sumprod_4n       <= gre_select.sumprod_3n;
            gre_select.sumprod_5n       <= gre_select.sumprod_4n;
            gre_select.sumprod_6n       <= gre_select.sumprod_5n;
            gre_select.sumprod_7n       <= gre_select.sumprod_6n;
            gre_select.sumprod_8n       <= gre_select.sumprod_7n;
            gre_select.sumprod_9n       <= gre_select.sumprod_8n;
            gre_select.sumprod_An       <= gre_select.sumprod_9n;
            gre_select.sumprod_Bn       <= gre_select.sumprod_An;
            gre_select.sumprod_Cn       <= gre_select.sumprod_Bn;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
            blu_select.sumprod_2n        <= blu_select.sumprod_2;
            blu_select.sumprod_3n        <= blu_select.sumprod_2n;
            blu_select.sumprod_4n        <= blu_select.sumprod_3n;
            blu_select.sumprod_5n        <= blu_select.sumprod_4n;
            blu_select.sumprod_6n        <= blu_select.sumprod_5n;
            blu_select.sumprod_7n        <= blu_select.sumprod_6n;
            blu_select.sumprod_8n        <= blu_select.sumprod_7n;
            blu_select.sumprod_9n        <= blu_select.sumprod_8n;
            blu_select.sumprod_An        <= blu_select.sumprod_9n;
            blu_select.sumprod_Bn        <= blu_select.sumprod_An;
            blu_select.sumprod_Cn        <= blu_select.sumprod_Bn;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
            red_add.add_125               <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k5) / 3;
            red_add.add_639               <= (red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k3 + red_select.sumprod_Bn.k9) / 3;
            red_add.add_657               <= (red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k5 + red_select.sumprod_Bn.k7) / 3;
            red_add.add_62_10             <= (red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k10) / 3;
            red_add.add_625               <= (red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k5) / 3;
            red_add.add_6251              <= (red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k2*2 + red_select.sumprod_Bn.k5*2 + red_select.sumprod_Bn.k1*4) / 9;
            if ((red_select.sumprod_Bn.k6 - red_select.sumprod_Bn.k1) <=  (neighboring_pixel_threshold / 4) ) and ((red_select.sumprod_Bn.k6 - red_select.sumprod_Bn.k11) <=  (neighboring_pixel_threshold / 4) )then
                red_add.add_61_11             <= (red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k11) / 3;
            else
                red_add.add_61_11             <= red_select.sumprod_Bn.k1;
            end if;
            red_add.add_62               <= (red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k2) / 2;
            red_add.add_65               <= red_select.sumprod_Bn.k6;
            red_add.add_6527_10           <= (red_select.sumprod_Bn.k6*4 + red_select.sumprod_Bn.k5*2 + red_select.sumprod_Bn.k2*2 + red_select.sumprod_Bn.k7*2 + red_select.sumprod_Bn.k10*2) / 12;
            if(abs(red_select.sumprod_Bn.k1 - red_select.sumprod_Bn.k2) <=  (neighboring_pixel_threshold + 60) )then
                red_add.add_12                <= (red_select.sumprod_Bn.k1*2 + red_select.sumprod_Bn.k2) / 3; 
            else
                red_add.add_12               <= red_select.sumprod_Bn.k1;
            end if;
            
             red_add.add_1 <= red_select.sumprod_Bn.k1;
            
            
            if((red_select.sumprod_Bn.k1 - red_select.sumprod_Bn.k5) <=  (neighboring_pixel_threshold + 60) )then
                red_add.add_15                <= (red_select.sumprod_Bn.k1*2 + red_select.sumprod_Bn.k5) / 3;
            else
                red_add.add_15               <= red_select.sumprod_Bn.k1;
            end if;
            if((red_select.sumprod_Bn.k1 - red_select.sumprod_Bn.k2) <=  neighboring_pixel_threshold and (red_select.sumprod_Bn.k1 - red_select.sumprod_Bn.k5) <=  neighboring_pixel_threshold )then
                red_add.add_125               <= red_select.sumprod_Bn.k5;
            elsif((red_select.sumprod_Bn.k1 - red_select.sumprod_Bn.k2) <=  neighboring_pixel_threshold)then
                red_add.add_125               <= red_select.sumprod_Bn.k2;
            elsif((red_select.sumprod_Bn.k1 - red_select.sumprod_Bn.k5) <=  neighboring_pixel_threshold)then
                red_add.add_125               <= red_select.sumprod_Bn.k5;
            else
                red_add.add_125               <= red_select.sumprod_Bn.k1;
            end if;
            red_add.add_1256              <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k5 + red_select.sumprod_Bn.k6) / 4;
            red_add.add_125639            <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k5 + red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k3 + red_select.sumprod_Bn.k9) / 6;          
            red_add.add_1256394           <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k5 + red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k3 + red_select.sumprod_Bn.k9 + red_select.sumprod_Bn.k4) / 7;          
            red_add.add_125639_13         <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k5 + red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k3 + red_select.sumprod_Bn.k9 + red_select.sumprod_Bn.k13) / 7;         
            red_add.add_1256394_13        <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k5 + red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k3 + red_select.sumprod_Bn.k9 + red_select.sumprod_Bn.k4 + red_select.sumprod_Bn.k13) / 8;
            red_add.add_12563947_13_10    <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k5 + red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k3 + red_select.sumprod_Bn.k9 + red_select.sumprod_Bn.k4 + red_select.sumprod_Bn.k13 + red_select.sumprod_Bn.k7 + red_select.sumprod_Bn.k10) / 10;
            red_add.add_16                <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k6) / 2;                      
            red_add.add_34                <= (red_select.sumprod_Bn.k3 + red_select.sumprod_Bn.k4) / 2;                   
            red_add.add_56                <= (red_select.sumprod_Bn.k5 + red_select.sumprod_Bn.k6) / 2;                       
            red_add.add_78                <= (red_select.sumprod_Bn.k7 + red_select.sumprod_Bn.k8) / 2;  
            red_add.add_1245              <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k4 + red_select.sumprod_Bn.k5) / 4;
            red_add.add_1379              <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k3 + red_select.sumprod_Bn.k7 + red_select.sumprod_Bn.k9) / 4;
            red_add.add_123               <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k3) / 3;
            red_add.add_124               <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k4) / 3;
            red_add.add_147               <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k4 + red_select.sumprod_Bn.k7) / 3;
            red_add.add_145               <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k4 + red_select.sumprod_Bn.k5) / 3;
            red_add.add_45                <= (red_select.sumprod_Bn.k4 + red_select.sumprod_Bn.k5) / 2;
            red_add.add_14                <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k4) / 2;
            red_add.add_17                <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k7) / 2;
            red_add.add_13                <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k3) / 2;
            red_add.add_79                <= (red_select.sumprod_Bn.k7 + red_select.sumprod_Bn.k9) / 2;
            red_add.add_113               <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k13) / 2;
            red_add.add_116               <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k16) / 2;
            red_add.add_1316              <= (red_select.sumprod_Bn.k13 + red_select.sumprod_Bn.k16) / 2;
            ---------------------------------------------------------------------------------------------------------
            red_add.add_1234_max          <= int_max_val(red_select.sumprod_Bn.k1,red_select.sumprod_Bn.k2,red_select.sumprod_Bn.k5,red_select.sumprod_Bn.k6);
            red_add.add_1234_min          <= int_max_val(red_select.sumprod_Bn.k1,red_select.sumprod_Bn.k2,red_select.sumprod_Bn.k5,red_select.sumprod_Bn.k6);
            red_add.add_1234_sat          <= (red_add.add_1234_max + red_add.add_1234_min) / 2;
            ---------------------------------------------------------------------------------------------------------
            red_add.add_1234              <= ((red_select.sumprod_Bn.k1+red_select.sumprod_Bn.k2+red_select.sumprod_Bn.k3+red_select.sumprod_Bn.k4)/4);                  
            red_add.add_5678              <= ((red_select.sumprod_Bn.k5+red_select.sumprod_Bn.k6+red_select.sumprod_Bn.k7+red_select.sumprod_Bn.k8)/4);
            red_add.add_1_to_8            <= (red_add.add_1234 + red_add.add_5678) / 2;
            ---------------------------------------------------------------------------------------------------------
            red_add.add_12345678          <= (red_select.sumprod_Bn.k1*2 + red_select.sumprod_Bn.k2*2 + red_select.sumprod_Bn.k3*2 + red_select.sumprod_Bn.k4*2 + red_select.sumprod_Bn.k5*2 + red_select.sumprod_Bn.k6*5 + red_select.sumprod_Bn.k7*5 + red_select.sumprod_Bn.k8*2) / 22;
            red_add.add_9ABCDEFF          <= (red_select.sumprod_Bn.k9*2 + red_select.sumprod_Bn.k10*5 + red_select.sumprod_Bn.k11*5 + red_select.sumprod_Bn.k12*2 + red_select.sumprod_Bn.k13*2 + red_select.sumprod_Bn.k14*2 + red_select.sumprod_Bn.k15*2 + red_select.sumprod_Bn.k16*2) / 22;
            red_add.add_123456789ABCDEFF  <= (red_add.add_12345678 + red_add.add_9ABCDEFF) / 2;
            red_add.add_141316            <= (red_add.add_s14 + red_add.add_s1316);
            ---------------------------------------------------------------------------------------------------------
            red_add.add_123               <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k2*2 + red_select.sumprod_Bn.k3) / 4;
            red_add.add_567               <= (red_select.sumprod_Bn.k5*2 + red_select.sumprod_Bn.k6*4 + red_select.sumprod_Bn.k7*2) / 8;
            red_add.add_9_10_11           <= (red_select.sumprod_Bn.k9 + red_select.sumprod_Bn.k10*2 + red_select.sumprod_Bn.k11) / 4;
            red_add.add_123_567_9_10_11   <= (red_add.add_123 + red_add.add_567 + red_add.add_9_10_11) / 3;
            ---------------------------------------------------------------------------------------------------------
            red_add.add_678               <= (red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k7*2 + red_select.sumprod_Bn.k8) / 4;
            red_add.add_10_11_12          <= (red_select.sumprod_Bn.k10*2 + red_select.sumprod_Bn.k11*4 + red_select.sumprod_Bn.k12*2) / 8;
            red_add.add_14_15_16          <= (red_select.sumprod_Bn.k14 + red_select.sumprod_Bn.k15*2 + red_select.sumprod_Bn.k16) / 4;
            red_add.add_678_10_11_12_14_15_16   <= (red_add.add_678 + red_add.add_10_11_12 + red_add.add_14_15_16) / 3;
--  
--  |-----|-----|-----|
--  | k6  | k7  | k8  |
--  |-----|-----|-----|
--  | k10 | k11 | k12 |
--  |-----|-----|-----| 
--  | k14 | k15 | k16 |
--  +-----+-----+-----+
            if((red_detect.k_syn_12(1).n=1) and (red_detect.k_syn_12(2).n=2) and (red_detect.k_syn_12(3).n=3) and (red_detect.k_syn_12(4).n=4)) then
                red_add.row1                  <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k3 + red_select.sumprod_Bn.k4) / 4;
            elsif((red_detect.k_syn_12(1).n=1) and (red_detect.k_syn_12(2).n=2) and (red_detect.k_syn_12(3).n=3) )  then
                red_add.row1               <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k3) / 3;
            elsif((red_detect.k_syn_12(1).n=1) and (red_detect.k_syn_12(2).n=2) and (red_detect.k_syn_12(4).n=4) )then
                red_add.row1               <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k4) / 3;
            elsif((red_detect.k_syn_12(1).n=1) and (red_detect.k_syn_12(3).n=3) and (red_detect.k_syn_12(4).n=4) )then
                red_add.row1               <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k3 + red_select.sumprod_Bn.k4) / 3;
            elsif((red_detect.k_syn_12(2).n=2) and (red_detect.k_syn_12(3).n=3) and (red_detect.k_syn_12(4).n=4) )then
                red_add.row1               <= (red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k3 + red_select.sumprod_Bn.k4) / 3;
            elsif((red_detect.k_syn_12(1).n=1) and (red_detect.k_syn_12(2).n=2)  )  then
                red_add.row1               <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k2) / 2;
            elsif((red_detect.k_syn_12(1).n=1) and (red_detect.k_syn_12(3).n=3)  )  then
                red_add.row1               <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k3) / 2;
            elsif((red_detect.k_syn_12(1).n=1) and (red_detect.k_syn_12(4).n=4)  )  then
                red_add.row1               <= (red_select.sumprod_Bn.k1 + red_select.sumprod_Bn.k4) / 2;
            elsif((red_detect.k_syn_12(3).n=3) and (red_detect.k_syn_12(4).n=4)  )  then
                red_add.row1               <= (red_select.sumprod_Bn.k3 + red_select.sumprod_Bn.k4) / 2;
            elsif((red_detect.k_syn_12(2).n=2) and (red_detect.k_syn_12(4).n=4)  )  then
                red_add.row1               <= (red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k4) / 2;
            elsif((red_detect.k_syn_12(2).n=2) and (red_detect.k_syn_12(3).n=3)  )  then
                red_add.row1               <= (red_select.sumprod_Bn.k2 + red_select.sumprod_Bn.k3) / 2;
            else
                red_add.row1               <= red_select.sumprod_Bn.k1;
            end if;
            if((red_detect.k_syn_12(5).n=5) and (red_detect.k_syn_12(6).n=6) and (red_detect.k_syn_12(7).n=7) and (red_detect.k_syn_12(8).n=8)) then
                red_add.row2                  <= (red_select.sumprod_Bn.k5 + red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k7 + red_select.sumprod_Bn.k8) / 4;
            elsif((red_detect.k_syn_12(5).n=5) and (red_detect.k_syn_12(6).n=6) and (red_detect.k_syn_12(7).n=7) )  then
                red_add.row2               <= (red_select.sumprod_Bn.k5 + red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k7) / 3;
            elsif((red_detect.k_syn_12(5).n=5) and (red_detect.k_syn_12(6).n=6) and (red_detect.k_syn_12(8).n=8) )then
                red_add.row2               <= (red_select.sumprod_Bn.k5 + red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k8) / 3;
            elsif((red_detect.k_syn_12(5).n=5) and (red_detect.k_syn_12(7).n=7) and (red_detect.k_syn_12(8).n=8) )then
                red_add.row2               <= (red_select.sumprod_Bn.k5 + red_select.sumprod_Bn.k7 + red_select.sumprod_Bn.k8) / 3;
            elsif((red_detect.k_syn_12(6).n=6) and (red_detect.k_syn_12(7).n=7) and (red_detect.k_syn_12(8).n=8) )then
                red_add.row2               <= (red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k7 + red_select.sumprod_Bn.k8) / 3;
            elsif((red_detect.k_syn_12(5).n=5) and (red_detect.k_syn_12(6).n=6)  )  then
                red_add.row2               <= (red_select.sumprod_Bn.k5 + red_select.sumprod_Bn.k6) / 2;
            elsif((red_detect.k_syn_12(5).n=5) and (red_detect.k_syn_12(7).n=7)  )  then
                red_add.row2               <= (red_select.sumprod_Bn.k5 + red_select.sumprod_Bn.k7) / 2;
            elsif((red_detect.k_syn_12(5).n=5) and (red_detect.k_syn_12(8).n=8)  )  then
                red_add.row2               <= (red_select.sumprod_Bn.k5 + red_select.sumprod_Bn.k8) / 2;
            elsif((red_detect.k_syn_12(7).n=7) and (red_detect.k_syn_12(8).n=8)  )  then
                red_add.row2               <= (red_select.sumprod_Bn.k7 + red_select.sumprod_Bn.k8) / 2;
            elsif((red_detect.k_syn_12(6).n=6) and (red_detect.k_syn_12(8).n=8)  )  then
                red_add.row2               <= (red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k8) / 2;
            elsif((red_detect.k_syn_12(6).n=6) and (red_detect.k_syn_12(7).n=7)  )  then
                red_add.row2               <= (red_select.sumprod_Bn.k6 + red_select.sumprod_Bn.k7) / 2;
            else
                red_add.row2               <= red_select.sumprod_Bn.k1;
            end if;
            if((red_detect.k_syn_12(9).n=9) and (red_detect.k_syn_12(10).n=10) and (red_detect.k_syn_12(11).n=11) and (red_detect.k_syn_12(12).n=12)) then
                red_add.row3                  <= (red_select.sumprod_Bn.k9 + red_select.sumprod_Bn.k10 + red_select.sumprod_Bn.k11 + red_select.sumprod_Bn.k12) / 4;
            elsif((red_detect.k_syn_12(9).n=9) and (red_detect.k_syn_12(10).n=10) and (red_detect.k_syn_12(11).n=11) )  then
                red_add.row3               <= (red_select.sumprod_Bn.k9 + red_select.sumprod_Bn.k10 + red_select.sumprod_Bn.k11) / 3;
            elsif((red_detect.k_syn_12(9).n=9) and (red_detect.k_syn_12(10).n=10) and (red_detect.k_syn_12(12).n=12) )then
                red_add.row3               <= (red_select.sumprod_Bn.k9 + red_select.sumprod_Bn.k10 + red_select.sumprod_Bn.k12) / 3;
            elsif((red_detect.k_syn_12(9).n=9) and (red_detect.k_syn_12(11).n=11) and (red_detect.k_syn_12(12).n=12) )then
                red_add.row3               <= (red_select.sumprod_Bn.k9 + red_select.sumprod_Bn.k11 + red_select.sumprod_Bn.k12) / 3;
            elsif((red_detect.k_syn_12(10).n=10) and (red_detect.k_syn_12(11).n=11) and (red_detect.k_syn_12(12).n=12) )then
                red_add.row3               <= (red_select.sumprod_Bn.k10 + red_select.sumprod_Bn.k11 + red_select.sumprod_Bn.k12) / 3;
            elsif((red_detect.k_syn_12(9).n=9) and (red_detect.k_syn_12(10).n=10)  )  then
                red_add.row3               <= (red_select.sumprod_Bn.k9 + red_select.sumprod_Bn.k10) / 2;
            elsif((red_detect.k_syn_12(9).n=9) and (red_detect.k_syn_12(11).n=11)  )  then
                red_add.row3               <= (red_select.sumprod_Bn.k9 + red_select.sumprod_Bn.k11) / 2;
            elsif((red_detect.k_syn_12(9).n=9) and (red_detect.k_syn_12(12).n=12)  )  then
                red_add.row3               <= (red_select.sumprod_Bn.k9 + red_select.sumprod_Bn.k12) / 2;
            elsif((red_detect.k_syn_12(11).n=11) and (red_detect.k_syn_12(12).n=12)  )  then
                red_add.row3               <= (red_select.sumprod_Bn.k11 + red_select.sumprod_Bn.k12) / 2;
            elsif((red_detect.k_syn_12(10).n=10) and (red_detect.k_syn_12(12).n=12)  )  then
                red_add.row3               <= (red_select.sumprod_Bn.k10 + red_select.sumprod_Bn.k12) / 2;
            elsif((red_detect.k_syn_12(10).n=10) and (red_detect.k_syn_12(11).n=11)  )  then
                red_add.row3               <= (red_select.sumprod_Bn.k10 + red_select.sumprod_Bn.k11) / 2;
            else
                red_add.row3               <= red_select.sumprod_Bn.k1;
            end if;
            if((red_detect.k_syn_12(13).n=13) and (red_detect.k_syn_12(14).n=14) and (red_detect.k_syn_12(15).n=15) and (red_detect.k_syn_12(16).n=16)) then
                red_add.row4                  <= (red_select.sumprod_Bn.k13 + red_select.sumprod_Bn.k14 + red_select.sumprod_Bn.k15 + red_select.sumprod_Bn.k16) / 4;
            elsif((red_detect.k_syn_12(13).n=13) and (red_detect.k_syn_12(14).n=14) and (red_detect.k_syn_12(15).n=15) )  then
                red_add.row4               <= (red_select.sumprod_Bn.k13 + red_select.sumprod_Bn.k14 + red_select.sumprod_Bn.k15) / 3;
            elsif((red_detect.k_syn_12(13).n=13) and (red_detect.k_syn_12(14).n=14) and (red_detect.k_syn_12(16).n=16) )then
                red_add.row4               <= (red_select.sumprod_Bn.k13 + red_select.sumprod_Bn.k14 + red_select.sumprod_Bn.k16) / 3;
            elsif((red_detect.k_syn_12(13).n=13) and (red_detect.k_syn_12(15).n=15) and (red_detect.k_syn_12(16).n=16) )then
                red_add.row4               <= (red_select.sumprod_Bn.k13 + red_select.sumprod_Bn.k15 + red_select.sumprod_Bn.k16) / 3;
            elsif((red_detect.k_syn_12(14).n=14) and (red_detect.k_syn_12(15).n=15) and (red_detect.k_syn_12(16).n=16) )then
                red_add.row4               <= (red_select.sumprod_Bn.k14 + red_select.sumprod_Bn.k15 + red_select.sumprod_Bn.k16) / 3;
            elsif((red_detect.k_syn_12(13).n=13) and (red_detect.k_syn_12(14).n=14)  )  then
                red_add.row4               <= (red_select.sumprod_Bn.k13 + red_select.sumprod_Bn.k14) / 2;
            elsif((red_detect.k_syn_12(13).n=13) and (red_detect.k_syn_12(15).n=15)  )  then
                red_add.row4               <= (red_select.sumprod_Bn.k13 + red_select.sumprod_Bn.k15) / 2;
            elsif((red_detect.k_syn_12(13).n=13) and (red_detect.k_syn_12(16).n=16)  )  then
                red_add.row4               <= (red_select.sumprod_Bn.k13 + red_select.sumprod_Bn.k16) / 2;
            elsif((red_detect.k_syn_12(15).n=15) and (red_detect.k_syn_12(16).n=16)  )  then
                red_add.row4               <= (red_select.sumprod_Bn.k15 + red_select.sumprod_Bn.k16) / 2;
            elsif((red_detect.k_syn_12(14).n=14) and (red_detect.k_syn_12(16).n=16)  )  then
                red_add.row4               <= (red_select.sumprod_Bn.k14 + red_select.sumprod_Bn.k16) / 2;
            elsif((red_detect.k_syn_12(14).n=14) and (red_detect.k_syn_12(15).n=15)  )  then
                red_add.row4               <= (red_select.sumprod_Bn.k14 + red_select.sumprod_Bn.k15) / 2;
            else
                red_add.row4               <= red_select.sumprod_Bn.k1;
            end if;
                        red_add.row4x4 <= (red_add.row1 + red_add.row2 + red_add.row3 + red_add.row4) /4;
    end if;
end process;
--=================================================================================================
process (clk) begin
    if rising_edge(clk) then
        if (red_detect.k_syn_12(1).n=1 and red_detect.k_syn_12(2).n=2 and red_detect.k_syn_12(3).n=3 and red_detect.k_syn_12(4).n=4 
           and red_detect.k_syn_12(5).n=5 and red_detect.k_syn_12(6).n=6 and red_detect.k_syn_12(7).n=7  
           and red_detect.k_syn_12(8).n=8 and red_detect.k_syn_12(9).n=9 and red_detect.k_syn_12(10).n=10 
           and red_detect.k_syn_12(11).n=11 and red_detect.k_syn_12(12).n=12 and red_detect.k_syn_12(13).n=13  
           and red_detect.k_syn_12(14).n=14 and red_detect.k_syn_12(15).n=15 and red_detect.k_syn_12(16).n=16) then
--  +-----+-----+-----+-----+
--  | k1  | k2  | k3  | k4  |
--  |-----|-----|-----|-----|
--  | k5  | k6  | k7  | k8  |
--  |-----|-----|-----|-----|
--  | k9  | k10 | k11 | k12 |
--  |-----|-----|-----|-----| 
--  | k13 | k14 | k15 | k16 |
--  +-----+-----+-----+-----+
            red_select.result   <= std_logic_vector(to_unsigned((red_add.add_123456789ABCDEFF), 14));
        elsif (red_detect.k_syn_12(1).n=1 and  red_detect.k_syn_12(2).n=2 and red_detect.k_syn_12(3).n=3
           and red_detect.k_syn_12(5).n=5 and red_detect.k_syn_12(6).n=6 and red_detect.k_syn_12(7).n=7  
           and red_detect.k_syn_12(9).n=9 and red_detect.k_syn_12(10).n=10  and red_detect.k_syn_12(11).n=11) then
--  +-----+-----+-----+
--  | k1  | k2  | k3  |
--  |-----|-----|-----|
--  | k5  | k6  | k7  |
--  |-----|-----|-----|
--  | k9  | k10 | k11 |
--  |-----|-----|-----|
            red_select.result   <= std_logic_vector(to_unsigned((red_add.add_123_567_9_10_11), 14));
        elsif (red_detect.k_syn_12(1).n=2 and  red_detect.k_syn_12(2).n=2 and red_detect.k_syn_12(3).n=3 and red_detect.k_syn_12(4).n=4) then
--  +-----+-----+-----+-----+
--  | k1  | k2  | k3  | k4  |
--  |-----|-----|-----|-----|
            red_select.result   <= std_logic_vector(to_unsigned((red_add.add_1234), 14));
        elsif (red_detect.k_syn_12(1).n=2 and red_detect.k_syn_12(6).n=6 and  red_detect.k_syn_12(7).n=7 and red_detect.k_syn_12(8).n=8
           and red_detect.k_syn_12(10).n=10 and red_detect.k_syn_12(11).n=11 and red_detect.k_syn_12(12).n=12  
           and red_detect.k_syn_12(14).n=14 and red_detect.k_syn_12(15).n=15  and red_detect.k_syn_12(16).n=16) then
--  +-----+
--  | k1  |
--  |-----|-----|-----|-----|
--        | k6  | k7  | k8  |
--        |-----|-----|-----|
--        | k10 | k11 | k12 |
--        |-----|-----|-----| 
--        | k14 | k15 | k16 |
--        +-----+-----+-----+
            red_select.result   <= std_logic_vector(to_unsigned((red_add.add_678_10_11_12_14_15_16), 14));
--  +-----+
--  | k1  |
--  |-----|-----|-----|-----|
--  | k5  | k6  | k7  | k8  |
--  |-----|-----|-----|-----|
--  | k9  | k10 | k11 | k12 |
--  |-----|-----|-----|-----| 
--  | k13 | k14 | k15 | k16 |
--  +-----+-----+-----+-----+
--  +-----+
--  | k1  |
--  |-----|-----+-----+
--  | k5  | k6  | k7  |
--  |-----|-----|-----|
--  | k9  | k10 | k11 |
--  |-----|-----|-----|
--  | k13 | k14 | k15 |
--  +-----+-----+-----+
--  +-----+
--  | k1  |
--  |-----|-----+
--  | k5  | k6  |
--  |-----|-----|-----+
--  | k9  | k10 | k11 |
--  |-----|-----|-----|
--  | k13 | k14 | k15 |
--  +-----+-----+-----+
--  +-----+
--  | k1  |
--  |-----|-----+
--  | k5  | k6  |
--  |-----|-----|
--  | k9  | k10 |
--  |-----|-----|-----+
--  | k13 | k14 | k15 |
--  +-----+-----+-----+
--  +-----+
--  | k1  |
--  |-----|
--  | k5  |
--  |-----|-----+
--  | k9  | k10 |
--  |-----|-----|-----+
--  | k13 | k14 | k15 |
--  +-----+-----+-----+
--  +-----+
--  | k1  |
--  |-----|-----+
--  | k5  | k6  |
--  |-----|-----|
--  | k9  | k10 |
--  |-----|-----|
--  | k13 | k14 |
--  +-----+-----+
--  +-----+
--  | k1  |
--  |-----|
--  | k5  |
--  |-----|
--  | k9  |
--  |-----|-----|-----+
--  | k13 | k14 | k15 |
--  +-----+-----+-----+
--  +-----+
--  | k1  |
--  |-----|
--  | k5  |
--  |-----|
--  | k9  |
--  |-----|
--  | k13 |
--  +-----+
        --elsif (red_detect.k_syn_12(2).n=2 and red_detect.k_syn_12(3).n=3 and red_detect.k_syn_12(4).n=4 
        --   and red_detect.k_syn_12(5).n=5 and red_detect.k_syn_12(6).n=6 and red_detect.k_syn_12(7).n=7  
        --   and red_detect.k_syn_12(9).n=9 and red_detect.k_syn_12(10).n=10   
        --   and red_detect.k_syn_12(13).n=13) then
        --    red_select.result   <= std_logic_vector(to_unsigned((red_add.add_12563947_13_10), 14));
        --elsif (red_detect.k_syn_12(2).n=2 and red_detect.k_syn_12(3).n=3 and red_detect.k_syn_12(4).n=4 
        --   and red_detect.k_syn_12(5).n=5 and red_detect.k_syn_12(6).n=6
        --   and red_detect.k_syn_12(9).n=9
        --   and red_detect.k_syn_12(13).n=13) then
        --    red_select.result   <= std_logic_vector(to_unsigned((red_add.add_1256394_13), 14));
        --elsif (red_detect.k_syn_12(2).n=2 and red_detect.k_syn_12(3).n=3
        --    and red_detect.k_syn_12(5).n=5 and red_detect.k_syn_12(6).n=6
        --    and red_detect.k_syn_12(9).n=9 
        --    and red_detect.k_syn_12(13).n=13) then
        --     red_select.result   <= std_logic_vector(to_unsigned((red_add.add_125639_13), 14));
        --if (red_detect.k_syn_12(2).n=2 and red_detect.k_syn_12(3).n=3 and red_detect.k_syn_12(4).n=4 
        --    and red_detect.k_syn_12(5).n=5 and red_detect.k_syn_12(6).n=6
        --    and red_detect.k_syn_12(9).n=9) then
        --     red_select.result   <= std_logic_vector(to_unsigned((red_add.add_1256394), 14));
        --elsif (red_detect.k_syn_12(2).n=2 and red_detect.k_syn_12(5).n=5 and red_detect.k_syn_12(6).n=6) then
        --    red_select.result   <= std_logic_vector(to_unsigned((red_add.add_1256), 14));
        elsif (red_detect.k_syn_12(1).n=2 and red_detect.k_syn_12(2).n=2 and red_detect.k_syn_12(3).n=3 and red_detect.k_syn_12(4).n=4 
           and red_detect.k_syn_12(5).n=5 and red_detect.k_syn_12(6).n=6 and red_detect.k_syn_12(7).n=7  
           and red_detect.k_syn_12(8).n=8) then
            red_select.result   <= std_logic_vector(to_unsigned((red_add.add_1_to_8), 14));
        elsif (red_detect.k_syn_12(1).n=2 and red_detect.k_syn_12(2).n=2 and red_detect.k_syn_12(3).n=3
            and red_detect.k_syn_12(5).n=5 and red_detect.k_syn_12(6).n=6
            and red_detect.k_syn_12(9).n=9) then
             red_select.result   <= std_logic_vector(to_unsigned((red_add.add_125639), 14));
        elsif (red_detect.k_syn_12(6).n=6 and red_detect.k_syn_12(1).n=2 and red_detect.k_syn_12(11).n=11) then
            red_select.result   <= std_logic_vector(to_unsigned((red_add.add_61_11), 14));
        elsif (red_detect.k_syn_12(6).n=6 and red_detect.k_syn_12(2).n=1 and red_detect.k_syn_12(10).n=10) then
            red_select.result   <= std_logic_vector(to_unsigned((red_add.add_62_10), 14));
        elsif (red_detect.k_syn_12(6).n=6 and red_detect.k_syn_12(5).n=1 and red_detect.k_syn_12(2).n=2 and red_detect.k_syn_12(7).n=7 and red_detect.k_syn_12(10).n=10) then
            red_select.result   <= std_logic_vector(to_unsigned((red_add.add_6527_10), 14));
        elsif (red_detect.k_syn_12(6).n=6 and red_detect.k_syn_12(2).n=1 and red_detect.k_syn_12(5).n=5 and red_detect.k_syn_12(1).n=1) and ((abs(red_select.sumprod_Bn.k6 - red_select.sumprod_Bn.k1) <=  (neighboring_pixel_threshold / 2) ) and (abs(red_select.sumprod_Bn.k6 - red_select.sumprod_Bn.k2) <=  (neighboring_pixel_threshold / 2) ) and (abs(red_select.sumprod_Bn.k6 - red_select.sumprod_Bn.k5) <=  (neighboring_pixel_threshold / 2) ))then
            red_select.result   <= std_logic_vector(to_unsigned((red_add.add_6251), 14));
        elsif (red_detect.k_syn_12(1).n=1 and red_detect.k_syn_12(2).n=1 and red_detect.k_syn_12(5).n=5) then
            red_select.result   <= std_logic_vector(to_unsigned((red_add.add_125), 14));
        elsif (red_detect.k_syn_12(1).n=2 and red_detect.k_syn_12(5).n=5) then
            red_select.result   <= std_logic_vector(to_unsigned((red_add.add_15), 14));
        elsif (red_detect.k_syn_12(1).n=2 and red_detect.k_syn_12(2).n=2) then
            red_select.result   <= std_logic_vector(to_unsigned((red_add.add_12), 14));
        else
            red_select.result   <= std_logic_vector(to_unsigned(red_add.add_1, 14));
        end if;
    end if;
end process;
--=================================================================================================
process (clk) begin
    if rising_edge(clk) then
            gre_add.add_61_11             <= (gre_select.sumprod_Bn.k6 + gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k11) / 3;
            gre_add.add_639               <= (gre_select.sumprod_Bn.k6 + gre_select.sumprod_Bn.k3 + gre_select.sumprod_Bn.k9) / 3;
            gre_add.add_657               <= (gre_select.sumprod_Bn.k6 + gre_select.sumprod_Bn.k5 + gre_select.sumprod_Bn.k7) / 3;
            gre_add.add_62_10             <= (gre_select.sumprod_Bn.k6 + gre_select.sumprod_Bn.k2 + gre_select.sumprod_Bn.k10) / 3;
          if((gre_select.sumprod_Bn.k6 - gre_select.sumprod_Bn.k2) <=  (neighboring_pixel_threshold / 6) )then
            gre_add.add_62               <= (gre_select.sumprod_Bn.k6 + gre_select.sumprod_Bn.k2) / 2;
          else
              gre_add.add_62               <= gre_select.sumprod_Bn.k6;
          end if;
          if((gre_select.sumprod_Bn.k6 - gre_select.sumprod_Bn.k5) <=  (neighboring_pixel_threshold) )then
            gre_add.add_65               <= (gre_select.sumprod_Bn.k6 + gre_select.sumprod_Bn.k5) / 2;
          else
              gre_add.add_65               <= gre_select.sumprod_Bn.k1;
          end if;
          if(abs(gre_select.sumprod_Bn.k1 - gre_select.sumprod_Bn.k2) <=  (neighboring_pixel_threshold + 60) )then
                gre_add.add_12              <= (gre_select.sumprod_Bn.k1*2 + gre_select.sumprod_Bn.k2) / 3;
          else
              gre_add.add_12               <= gre_select.sumprod_Bn.k1;
          end if;
          if((gre_select.sumprod_Bn.k1 - gre_select.sumprod_Bn.k5) <=  (neighboring_pixel_threshold + 60) )then
                gre_add.add_15              <= (gre_select.sumprod_Bn.k1*2 + gre_select.sumprod_Bn.k5) / 3;
          else
                gre_add.add_15               <= gre_select.sumprod_Bn.k1;
          end if;
            gre_add.add_625               <= (gre_select.sumprod_Bn.k6 + gre_select.sumprod_Bn.k2 + gre_select.sumprod_Bn.k5) / 3;
            gre_add.add_6251              <= (gre_select.sumprod_Bn.k6 + gre_select.sumprod_Bn.k2 + gre_select.sumprod_Bn.k5 + gre_select.sumprod_Bn.k1) / 4;
            gre_add.add_6527_10           <= (gre_select.sumprod_Bn.k6*4 + gre_select.sumprod_Bn.k5*2 + gre_select.sumprod_Bn.k2*2 + gre_select.sumprod_Bn.k7*2 + gre_select.sumprod_Bn.k10*2) / 12;
            if((gre_select.sumprod_Bn.k1 - gre_select.sumprod_Bn.k2) <=  neighboring_pixel_threshold and (gre_select.sumprod_Bn.k1 - gre_select.sumprod_Bn.k5) <=  neighboring_pixel_threshold )then
                gre_add.add_125               <= gre_select.sumprod_Bn.k5;
            elsif((gre_select.sumprod_Bn.k1 - gre_select.sumprod_Bn.k2) <=  neighboring_pixel_threshold)then
                gre_add.add_125               <= gre_select.sumprod_Bn.k2;
            elsif((gre_select.sumprod_Bn.k1 - gre_select.sumprod_Bn.k5) <=  neighboring_pixel_threshold)then
                gre_add.add_125               <= gre_select.sumprod_Bn.k5;
            else
                gre_add.add_125               <= gre_select.sumprod_Bn.k1;
            end if;
            gre_add.add_1                 <= gre_select.sumprod_Bn.k1;
            gre_add.add_1256              <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k2 + gre_select.sumprod_Bn.k5 + gre_select.sumprod_Bn.k6) / 4;
            gre_add.add_125639            <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k2 + gre_select.sumprod_Bn.k5 + gre_select.sumprod_Bn.k6 + gre_select.sumprod_Bn.k3 + gre_select.sumprod_Bn.k9) / 6;          
            gre_add.add_1256394           <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k2 + gre_select.sumprod_Bn.k5 + gre_select.sumprod_Bn.k6 + gre_select.sumprod_Bn.k3 + gre_select.sumprod_Bn.k9 + gre_select.sumprod_Bn.k4) / 7;          
            gre_add.add_125639_13         <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k2 + gre_select.sumprod_Bn.k5 + gre_select.sumprod_Bn.k6 + gre_select.sumprod_Bn.k3 + gre_select.sumprod_Bn.k9 + gre_select.sumprod_Bn.k13) / 7;         
            gre_add.add_1256394_13        <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k2 + gre_select.sumprod_Bn.k5 + gre_select.sumprod_Bn.k6 + gre_select.sumprod_Bn.k3 + gre_select.sumprod_Bn.k9 + gre_select.sumprod_Bn.k4 + gre_select.sumprod_Bn.k13) / 8;
            gre_add.add_12563947_13_10    <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k2 + gre_select.sumprod_Bn.k5 + gre_select.sumprod_Bn.k6 + gre_select.sumprod_Bn.k3 + gre_select.sumprod_Bn.k9 + gre_select.sumprod_Bn.k4 + gre_select.sumprod_Bn.k13 + gre_select.sumprod_Bn.k7 + gre_select.sumprod_Bn.k10) / 10;
            gre_add.add_16                <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k6) / 2;                      
            gre_add.add_34                <= (gre_select.sumprod_Bn.k3 + gre_select.sumprod_Bn.k4) / 2;                   
            gre_add.add_56                <= (gre_select.sumprod_Bn.k5 + gre_select.sumprod_Bn.k6) / 2;                       
            gre_add.add_78                <= (gre_select.sumprod_Bn.k7 + gre_select.sumprod_Bn.k8) / 2;  
            gre_add.add_1245              <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k2 + gre_select.sumprod_Bn.k4 + gre_select.sumprod_Bn.k5) / 4;
            gre_add.add_1379              <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k3 + gre_select.sumprod_Bn.k7 + gre_select.sumprod_Bn.k9) / 4;
            gre_add.add_123               <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k2 + gre_select.sumprod_Bn.k3) / 3;
            gre_add.add_124               <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k2 + gre_select.sumprod_Bn.k4) / 3;
            gre_add.add_147               <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k4 + gre_select.sumprod_Bn.k7) / 3;
            gre_add.add_145               <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k4 + gre_select.sumprod_Bn.k5) / 3;
            gre_add.add_45                <= (gre_select.sumprod_Bn.k4 + gre_select.sumprod_Bn.k5) / 2;
            gre_add.add_14                <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k4) / 2;
            gre_add.add_17                <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k7) / 2;
            gre_add.add_13                <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k3) / 2;
            gre_add.add_79                <= (gre_select.sumprod_Bn.k7 + gre_select.sumprod_Bn.k9) / 2;
            gre_add.add_113               <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k13) / 2;
            gre_add.add_116               <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k16) / 2;
            gre_add.add_1316              <= (gre_select.sumprod_Bn.k13 + gre_select.sumprod_Bn.k16) / 2;
            ---------------------------------------------------------------------------------------------------------
            gre_add.add_1234_max          <= int_max_val(gre_select.sumprod_Bn.k1,gre_select.sumprod_Bn.k2,gre_select.sumprod_Bn.k5,gre_select.sumprod_Bn.k6);
            gre_add.add_1234_min          <= int_max_val(gre_select.sumprod_Bn.k1,gre_select.sumprod_Bn.k2,gre_select.sumprod_Bn.k5,gre_select.sumprod_Bn.k6);
            gre_add.add_1234_sat          <= (gre_add.add_1234_max + red_add.add_1234_min) / 2;
            ---------------------------------------------------------------------------------------------------------
            gre_add.add_1234              <= (gre_select.sumprod_Bn.k1+gre_select.sumprod_Bn.k2+gre_select.sumprod_Bn.k3+gre_select.sumprod_Bn.k4) / 4;
            gre_add.add_5678              <= (int_max_val(gre_select.sumprod_Bn.k9,gre_select.sumprod_Bn.k10,gre_select.sumprod_Bn.k11,gre_select.sumprod_Bn.k12) + int_max_val(gre_select.sumprod_Bn.k13,gre_select.sumprod_Bn.k14,gre_select.sumprod_Bn.k15,gre_select.sumprod_Bn.k16)) / 2;
            gre_add.add_1_to_8            <= (gre_add.add_1234 + gre_add.add_5678) / 2;
            ---------------------------------------------------------------------------------------------------------
            gre_add.add_12345678          <= (gre_select.sumprod_Bn.k1*2 + gre_select.sumprod_Bn.k2*2 + gre_select.sumprod_Bn.k3*2 + gre_select.sumprod_Bn.k4*2 + gre_select.sumprod_Bn.k5*2 + gre_select.sumprod_Bn.k6*5 + gre_select.sumprod_Bn.k7*5 + gre_select.sumprod_Bn.k8*2) / 22;
            gre_add.add_9ABCDEFF          <= (gre_select.sumprod_Bn.k9*2 + gre_select.sumprod_Bn.k10*5 + gre_select.sumprod_Bn.k11*5 + gre_select.sumprod_Bn.k12*2 + gre_select.sumprod_Bn.k13*2 + gre_select.sumprod_Bn.k14*2 + gre_select.sumprod_Bn.k15*2 + gre_select.sumprod_Bn.k16*2) / 22;
            gre_add.add_123456789ABCDEFF  <= (gre_add.add_12345678 + gre_add.add_9ABCDEFF) / 2;
            gre_add.add_141316            <= (gre_add.add_s14 + gre_add.add_s1316) / 2;
            ---------------------------------------------------------------------------------------------------------
            gre_add.add_123               <= (gre_select.sumprod_Bn.k1 + gre_select.sumprod_Bn.k2*2 + gre_select.sumprod_Bn.k3) / 4;
            gre_add.add_567               <= (gre_select.sumprod_Bn.k5*2 + gre_select.sumprod_Bn.k6*4 + gre_select.sumprod_Bn.k7*2) / 8;
            gre_add.add_9_10_11           <= (gre_select.sumprod_Bn.k9 + gre_select.sumprod_Bn.k10*2 + gre_select.sumprod_Bn.k11) / 4;
            gre_add.add_123_567_9_10_11   <= (gre_add.add_123 + gre_add.add_567 + gre_add.add_9_10_11) / 3;
            ---------------------------------------------------------------------------------------------------------
            gre_add.add_678               <= (gre_select.sumprod_Bn.k6 + gre_select.sumprod_Bn.k7*2 + gre_select.sumprod_Bn.k8) / 4;
            gre_add.add_10_11_12          <= (gre_select.sumprod_Bn.k10*2 + gre_select.sumprod_Bn.k11*4 + gre_select.sumprod_Bn.k12*2) / 8;
            gre_add.add_14_15_16          <= (gre_select.sumprod_Bn.k14 + gre_select.sumprod_Bn.k15*2 + gre_select.sumprod_Bn.k16) / 4;
            gre_add.add_678_10_11_12_14_15_16   <= (gre_add.add_678 + gre_add.add_10_11_12 + gre_add.add_14_15_16) / 3;
    end if;
end process;
--=================================================================================================
process (clk) begin
    if rising_edge(clk) then
        if (gre_detect.k_syn_12(1).n=1 and gre_detect.k_syn_12(2).n=2 and gre_detect.k_syn_12(3).n=3 and gre_detect.k_syn_12(4).n=4 
           and gre_detect.k_syn_12(5).n=5 and gre_detect.k_syn_12(6).n=6 and gre_detect.k_syn_12(7).n=7  
           and gre_detect.k_syn_12(8).n=8 and gre_detect.k_syn_12(9).n=9 and gre_detect.k_syn_12(10).n=10 
           and gre_detect.k_syn_12(11).n=11 and gre_detect.k_syn_12(12).n=12 and gre_detect.k_syn_12(13).n=13  
           and gre_detect.k_syn_12(14).n=14 and gre_detect.k_syn_12(15).n=15 and gre_detect.k_syn_12(16).n=16) then
            gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_123456789ABCDEFF), 14));
        elsif (gre_detect.k_syn_12(1).n=1 and gre_detect.k_syn_12(2).n=2 and gre_detect.k_syn_12(3).n=3
           and gre_detect.k_syn_12(5).n=5 and gre_detect.k_syn_12(6).n=6 and gre_detect.k_syn_12(7).n=7  
           and gre_detect.k_syn_12(9).n=9 and gre_detect.k_syn_12(10).n=10  and gre_detect.k_syn_12(11).n=11) then
            gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_123_567_9_10_11), 14));
        elsif (gre_detect.k_syn_12(1).n=2 and gre_detect.k_syn_12(2).n=2 and gre_detect.k_syn_12(3).n=3 and gre_detect.k_syn_12(4).n=4) then
            gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_1234), 14));
        elsif (gre_detect.k_syn_12(1).n=2 and gre_detect.k_syn_12(6).n=6 and  gre_detect.k_syn_12(7).n=7 and gre_detect.k_syn_12(8).n=8
           and gre_detect.k_syn_12(10).n=10 and gre_detect.k_syn_12(11).n=11 and gre_detect.k_syn_12(12).n=12  
           and gre_detect.k_syn_12(14).n=14 and gre_detect.k_syn_12(15).n=15  and gre_detect.k_syn_12(16).n=16) then
--  +-----+
--  | k1  |
--  |-----|-----|-----|-----|
--        | k6  | k7  | k8  |
--        |-----|-----|-----|
--        | k10 | k11 | k12 |
--        |-----|-----|-----| 
--        | k14 | k15 | k16 |
--        +-----+-----+-----+
            gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_678_10_11_12_14_15_16), 14));
        --elsif (gre_detect.k_syn_12(2).n=2 and gre_detect.k_syn_12(3).n=3 and gre_detect.k_syn_12(4).n=4 
        --   and gre_detect.k_syn_12(5).n=5 and gre_detect.k_syn_12(6).n=6 and gre_detect.k_syn_12(7).n=7  
        --   and gre_detect.k_syn_12(9).n=9 and gre_detect.k_syn_12(10).n=10   
        --   and gre_detect.k_syn_12(13).n=13) then
        --    gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_12563947_13_10), 14));
        --elsif (gre_detect.k_syn_12(2).n=2 and gre_detect.k_syn_12(3).n=3 and gre_detect.k_syn_12(4).n=4 
        --   and gre_detect.k_syn_12(5).n=5 and gre_detect.k_syn_12(6).n=6
        --   and gre_detect.k_syn_12(9).n=9 
        --   and gre_detect.k_syn_12(13).n=13) then
        --    gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_1256394_13), 14));
        --elsif (gre_detect.k_syn_12(2).n=2 and gre_detect.k_syn_12(3).n=3
        --   and gre_detect.k_syn_12(5).n=5 and gre_detect.k_syn_12(6).n=6
        --   and gre_detect.k_syn_12(9).n=9
        --   and gre_detect.k_syn_12(13).n=13) then
        --    gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_125639_13), 14));
        --if (gre_detect.k_syn_12(2).n=2 and gre_detect.k_syn_12(3).n=3 and gre_detect.k_syn_12(4).n=4 
        --   and gre_detect.k_syn_12(5).n=5 and gre_detect.k_syn_12(6).n=6
        --   and gre_detect.k_syn_12(9).n=9) then
        --    gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_1256394), 14));
        --elsif (gre_detect.k_syn_12(2).n=2 and gre_detect.k_syn_12(3).n=3
        --   and gre_detect.k_syn_12(5).n=5 and gre_detect.k_syn_12(6).n=6
        --   and gre_detect.k_syn_12(9).n=9) then
        --    gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_125639), 14));
        --elsif (gre_detect.k_syn_12(2).n=2 and gre_detect.k_syn_12(5).n=5 and gre_detect.k_syn_12(6).n=6) then
        --    gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_1256), 14));
        --elsif (gre_detect.k_syn_12(2).n=2 and gre_detect.k_syn_12(5).n=5) then
        --    gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_125), 14));
        --elsif (gre_detect.k_syn_12(5).n=5) then
        --    gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_15), 14));
        --if (gre_detect.k_syn_12(2).n=1 and gre_detect.k_syn_12(3).n=3 and gre_detect.k_syn_12(4).n=4 
        --   and gre_detect.k_syn_12(5).n=5 and gre_detect.k_syn_12(6).n=6 and gre_detect.k_syn_12(7).n=7  
        --   and gre_detect.k_syn_12(8).n=8) then
        --    gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_1_to_8), 14));
        --if (gre_detect.k_syn_12(2).n=1 and gre_detect.k_syn_12(5).n=5) then
        --    gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_125), 14));
       --elsif (gre_detect.k_syn_12(5).n=5) then
       --    gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_15), 14));
       --elsif (gre_detect.k_syn_12(2).n=2) then
       --    gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_12), 14));
        --if (gre_detect.k_syn_12(2).n=2 and gre_detect.k_syn_12(3).n=3 and gre_detect.k_syn_12(4).n=4) then
        --    gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_1234_sat), 14));
        elsif (gre_detect.k_syn_12(1).n=1 and gre_detect.k_syn_12(2).n=1 and gre_detect.k_syn_12(5).n=5) then
            gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_125), 14));
        elsif (gre_detect.k_syn_12(1).n=2 and gre_detect.k_syn_12(5).n=5) then
            gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_15), 14));
        elsif (gre_detect.k_syn_12(1).n=2 and gre_detect.k_syn_12(2).n=2) then
            gre_select.result   <= std_logic_vector(to_unsigned((gre_add.add_12), 14));
        else
            gre_select.result   <= std_logic_vector(to_unsigned(gre_add.add_1, 14));
        end if;
    end if;
end process;
--=================================================================================================
process (clk) begin
    if rising_edge(clk) then
            blu_add.add_61_11             <= (blu_select.sumprod_Bn.k6 + blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k11) / 3;
            blu_add.add_639               <= (blu_select.sumprod_Bn.k6 + blu_select.sumprod_Bn.k3 + blu_select.sumprod_Bn.k9) / 3;
            blu_add.add_657               <= (blu_select.sumprod_Bn.k6 + blu_select.sumprod_Bn.k5 + blu_select.sumprod_Bn.k7) / 3;
            blu_add.add_62_10             <= (blu_select.sumprod_Bn.k6 + blu_select.sumprod_Bn.k2 + blu_select.sumprod_Bn.k10) / 3;
            if((blu_select.sumprod_Bn.k6 - blu_select.sumprod_Bn.k2) <=  (neighboring_pixel_threshold / 8) )then
                blu_add.add_62               <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k2) / 2;
            else
                blu_add.add_62               <= blu_select.sumprod_Bn.k1;
            end if;
            if((blu_select.sumprod_Bn.k6 - blu_select.sumprod_Bn.k5) <=  (neighboring_pixel_threshold) )then
                blu_add.add_65               <= (blu_select.sumprod_Bn.k6 + blu_select.sumprod_Bn.k5) / 2;
            else
                blu_add.add_65               <= blu_select.sumprod_Bn.k1;
            end if;
            if(abs(blu_select.sumprod_Bn.k1 - blu_select.sumprod_Bn.k2) <=  (neighboring_pixel_threshold + 60) )then
                blu_add.add_12                <= (blu_select.sumprod_Bn.k1*2 + blu_select.sumprod_Bn.k2) / 3;
            else
                blu_add.add_12               <= blu_select.sumprod_Bn.k1;
            end if;
            if((blu_select.sumprod_Bn.k1 - blu_select.sumprod_Bn.k5) <=  (neighboring_pixel_threshold + 60) )then
                blu_add.add_15                <= (blu_select.sumprod_Bn.k1*2 + blu_select.sumprod_Bn.k5) / 3;
            else
                blu_add.add_15               <= blu_select.sumprod_Bn.k1;
            end if;
            blu_add.add_1                 <= blu_select.sumprod_Bn.k1;
            blu_add.add_625               <= (blu_select.sumprod_Bn.k6 + blu_select.sumprod_Bn.k2 + blu_select.sumprod_Bn.k5) / 3;
            blu_add.add_6251              <= (blu_select.sumprod_Bn.k6 + blu_select.sumprod_Bn.k2 + blu_select.sumprod_Bn.k5 + blu_select.sumprod_Bn.k1) / 4;
            blu_add.add_6527_10           <= (blu_select.sumprod_Bn.k6*4 + blu_select.sumprod_Bn.k5*2 + blu_select.sumprod_Bn.k2*2 + blu_select.sumprod_Bn.k7*2 + blu_select.sumprod_Bn.k10*2) / 12;
            if((blu_select.sumprod_Bn.k1 - blu_select.sumprod_Bn.k2) <=  neighboring_pixel_threshold and (blu_select.sumprod_Bn.k1 - blu_select.sumprod_Bn.k5) <=  neighboring_pixel_threshold )then
                blu_add.add_125               <= blu_select.sumprod_Bn.k5;
            elsif((blu_select.sumprod_Bn.k1 - blu_select.sumprod_Bn.k2) <=  neighboring_pixel_threshold)then
                blu_add.add_125               <= blu_select.sumprod_Bn.k2;
            elsif((blu_select.sumprod_Bn.k1 - blu_select.sumprod_Bn.k5) <=  neighboring_pixel_threshold)then
                blu_add.add_125               <= blu_select.sumprod_Bn.k5;
            else
                blu_add.add_125               <= blu_select.sumprod_Bn.k1;
            end if;
            blu_add.add_1256              <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k2 + blu_select.sumprod_Bn.k5 + blu_select.sumprod_Bn.k6) / 4;
            blu_add.add_125639            <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k2 + blu_select.sumprod_Bn.k5 + blu_select.sumprod_Bn.k6 + blu_select.sumprod_Bn.k3 + blu_select.sumprod_Bn.k9) / 6;          
            blu_add.add_1256394           <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k2 + blu_select.sumprod_Bn.k5 + blu_select.sumprod_Bn.k6 + blu_select.sumprod_Bn.k3 + blu_select.sumprod_Bn.k9 + blu_select.sumprod_Bn.k4) / 7;          
            blu_add.add_125639_13         <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k2 + blu_select.sumprod_Bn.k5 + blu_select.sumprod_Bn.k6 + blu_select.sumprod_Bn.k3 + blu_select.sumprod_Bn.k9 + blu_select.sumprod_Bn.k13) / 7;         
            blu_add.add_1256394_13        <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k2 + blu_select.sumprod_Bn.k5 + blu_select.sumprod_Bn.k6 + blu_select.sumprod_Bn.k3 + blu_select.sumprod_Bn.k9 + blu_select.sumprod_Bn.k4 + blu_select.sumprod_Bn.k13) / 8;
            blu_add.add_12563947_13_10    <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k2 + blu_select.sumprod_Bn.k5 + blu_select.sumprod_Bn.k6 + blu_select.sumprod_Bn.k3 + blu_select.sumprod_Bn.k9 + blu_select.sumprod_Bn.k4 + blu_select.sumprod_Bn.k13 + blu_select.sumprod_Bn.k7 + blu_select.sumprod_Bn.k10) / 10;
            blu_add.add_16                <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k6) / 2;                      
            blu_add.add_34                <= (blu_select.sumprod_Bn.k3 + blu_select.sumprod_Bn.k4) / 2;                   
            blu_add.add_56                <= (blu_select.sumprod_Bn.k5 + blu_select.sumprod_Bn.k6) / 2;                       
            blu_add.add_78                <= (blu_select.sumprod_Bn.k7 + blu_select.sumprod_Bn.k8) / 2;  
            blu_add.add_1245              <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k2 + blu_select.sumprod_Bn.k4 + blu_select.sumprod_Bn.k5) / 4;
            blu_add.add_1379              <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k3 + blu_select.sumprod_Bn.k7 + blu_select.sumprod_Bn.k9) / 4;
            blu_add.add_123               <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k2 + blu_select.sumprod_Bn.k3) / 3;
            blu_add.add_124               <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k2 + blu_select.sumprod_Bn.k4) / 3;
            blu_add.add_147               <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k4 + blu_select.sumprod_Bn.k7) / 3;
            blu_add.add_145               <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k4 + blu_select.sumprod_Bn.k5) / 3;
            blu_add.add_45                <= (blu_select.sumprod_Bn.k4 + blu_select.sumprod_Bn.k5) / 2;
            blu_add.add_14                <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k4) / 2;
            blu_add.add_17                <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k7) / 2;
            blu_add.add_13                <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k3) / 2;
            blu_add.add_79                <= (blu_select.sumprod_Bn.k7 + blu_select.sumprod_Bn.k9) / 2;
            blu_add.add_113               <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k13) / 2;
            blu_add.add_116               <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k16) / 2;
            blu_add.add_1316              <= (blu_select.sumprod_Bn.k13 + blu_select.sumprod_Bn.k16) / 2;
            blu_add.add_141316            <= (blu_add.add_s14 + blu_add.add_s1316) / 2;
            ---------------------------------------------------------------------------------------------------------
            blu_add.add_1234_max          <= int_max_val(blu_select.sumprod_Bn.k1,blu_select.sumprod_Bn.k2,blu_select.sumprod_Bn.k5,blu_select.sumprod_Bn.k6);
            blu_add.add_1234_min          <= int_max_val(blu_select.sumprod_Bn.k1,blu_select.sumprod_Bn.k2,blu_select.sumprod_Bn.k5,blu_select.sumprod_Bn.k6);
            blu_add.add_1234_sat          <= (blu_add.add_1234_max + blu_add.add_1234_min) / 2;
            ---------------------------------------------------------------------------------------------------------
            blu_add.add_1234              <= (blu_select.sumprod_Bn.k1+blu_select.sumprod_Bn.k2+blu_select.sumprod_Bn.k3+blu_select.sumprod_Bn.k4) / 4;                     
            blu_add.add_5678              <= (int_max_val(blu_select.sumprod_Bn.k9,blu_select.sumprod_Bn.k10,blu_select.sumprod_Bn.k11,blu_select.sumprod_Bn.k12) + int_max_val(blu_select.sumprod_Bn.k13,blu_select.sumprod_Bn.k14,blu_select.sumprod_Bn.k15,blu_select.sumprod_Bn.k16)) / 2;
            blu_add.add_1_to_8            <= (blu_add.add_1234 + blu_add.add_5678) / 2;
            ---------------------------------------------------------------------------------------------------------
            blu_add.add_12345678_max      <= int_max_val(int_max_val(blu_select.sumprod_An.k1,blu_select.sumprod_An.k2,blu_select.sumprod_An.k3,blu_select.sumprod_An.k4),
            int_max_val(blu_select.sumprod_An.k5,blu_select.sumprod_An.k6,blu_select.sumprod_An.k7,blu_select.sumprod_An.k8));
            blu_add.add_9ABCDEFF_max      <= int_max_val(int_max_val(blu_select.sumprod_An.k9,blu_select.sumprod_An.k10,blu_select.sumprod_An.k11,blu_select.sumprod_An.k12),
            int_max_val(blu_select.sumprod_An.k13,blu_select.sumprod_An.k14,blu_select.sumprod_An.k15,blu_select.sumprod_An.k16));
            if(blu_add.add_12345678_max=blu_select.sumprod_Bn.k6)then
                blu_add.add_12345678_max_new          <= (blu_select.sumprod_Bn.k1*2 + blu_select.sumprod_Bn.k2*2 + blu_select.sumprod_Bn.k3*2 + blu_select.sumprod_Bn.k4*2 + blu_select.sumprod_Bn.k5*2 + blu_select.sumprod_Bn.k7*5 + blu_select.sumprod_Bn.k8*2) / 17;
            elsif(blu_add.add_12345678_max=blu_select.sumprod_Bn.k7)then
                blu_add.add_12345678_max_new          <= (blu_select.sumprod_Bn.k1*2 + blu_select.sumprod_Bn.k2*2 + blu_select.sumprod_Bn.k3*2 + blu_select.sumprod_Bn.k4*2 + blu_select.sumprod_Bn.k5*2 + blu_select.sumprod_Bn.k6*5 + blu_select.sumprod_Bn.k8*2) / 17;
            else
                blu_add.add_12345678_max_new          <= (blu_select.sumprod_Bn.k1*2 + blu_select.sumprod_Bn.k2*2 + blu_select.sumprod_Bn.k3*2 + blu_select.sumprod_Bn.k4*2 + blu_select.sumprod_Bn.k5*2 + blu_select.sumprod_Bn.k6*5 + blu_select.sumprod_Bn.k7*5 + blu_select.sumprod_Bn.k8*2) / 22;
            end if;
            if(blu_add.add_9ABCDEFF_max=blu_select.sumprod_Bn.k10)then
                blu_add.add_9ABCDEFF_max_new          <= (blu_select.sumprod_Bn.k9*2 + blu_select.sumprod_Bn.k11*5 + blu_select.sumprod_Bn.k12*2 + blu_select.sumprod_Bn.k13*2 + blu_select.sumprod_Bn.k14*2 + blu_select.sumprod_Bn.k15*2 + blu_select.sumprod_Bn.k16*2) / 17;
            elsif(blu_add.add_12345678_max=blu_select.sumprod_Bn.k11)then
                blu_add.add_9ABCDEFF_max_new          <= (blu_select.sumprod_Bn.k9*2 + blu_select.sumprod_Bn.k10*5 + blu_select.sumprod_Bn.k12*2 + blu_select.sumprod_Bn.k13*2 + blu_select.sumprod_Bn.k14*2 + blu_select.sumprod_Bn.k15*2 + blu_select.sumprod_Bn.k16*2) / 17;
            else
                blu_add.add_9ABCDEFF_max_new          <= (blu_select.sumprod_Bn.k9*2 + blu_select.sumprod_Bn.k10*5 + blu_select.sumprod_Bn.k11*5 + blu_select.sumprod_Bn.k12*2 + blu_select.sumprod_Bn.k13*2 + blu_select.sumprod_Bn.k14*2 + blu_select.sumprod_Bn.k15*2 + blu_select.sumprod_Bn.k16*2) / 22;
            end if;
            blu_add.add_123456789ABCDEFF_new <= (blu_add.add_12345678_max_new + blu_add.add_9ABCDEFF_max_new) / 2;
            blu_add.add_12345678          <= (blu_select.sumprod_Bn.k1*2 + blu_select.sumprod_Bn.k2*2 + blu_select.sumprod_Bn.k3*2 + blu_select.sumprod_Bn.k4*2 + blu_select.sumprod_Bn.k5*2 + blu_select.sumprod_Bn.k6*5 + blu_select.sumprod_Bn.k7*5 + blu_select.sumprod_Bn.k8*2) / 22;
            blu_add.add_9ABCDEFF          <= (blu_select.sumprod_Bn.k9*2 + blu_select.sumprod_Bn.k10*5 + blu_select.sumprod_Bn.k11*5 + blu_select.sumprod_Bn.k12*2 + blu_select.sumprod_Bn.k13*2 + blu_select.sumprod_Bn.k14*2 + blu_select.sumprod_Bn.k15*2 + blu_select.sumprod_Bn.k16*2) / 22;
            blu_add.add_123456789ABCDEFF  <= (blu_add.add_12345678 + blu_add.add_9ABCDEFF) / 2;
            ---------------------------------------------------------------------------------------------------------
            blu_add.add_123               <= (blu_select.sumprod_Bn.k1 + blu_select.sumprod_Bn.k2*2 + blu_select.sumprod_Bn.k3) / 4;
            blu_add.add_567               <= (blu_select.sumprod_Bn.k5*2 + blu_select.sumprod_Bn.k6*4 + blu_select.sumprod_Bn.k7*2) / 8;
            blu_add.add_9_10_11           <= (blu_select.sumprod_Bn.k9 + blu_select.sumprod_Bn.k10*2 + blu_select.sumprod_Bn.k11) / 4;
            blu_add.add_123_567_9_10_11   <= (blu_add.add_123 + blu_add.add_567 + blu_add.add_9_10_11) / 3;
            ---------------------------------------------------------------------------------------------------------
            blu_add.add_678               <= (blu_select.sumprod_Bn.k6 + blu_select.sumprod_Bn.k7*2 + blu_select.sumprod_Bn.k8) / 4;
            blu_add.add_10_11_12          <= (blu_select.sumprod_Bn.k10*2 + blu_select.sumprod_Bn.k11*4 + blu_select.sumprod_Bn.k12*2) / 8;
            blu_add.add_14_15_16          <= (blu_select.sumprod_Bn.k14 + blu_select.sumprod_Bn.k15*2 + blu_select.sumprod_Bn.k16) / 4;
            blu_add.add_678_10_11_12_14_15_16   <= (blu_add.add_678 + blu_add.add_10_11_12 + blu_add.add_14_15_16) / 3;
    end if;
end process;
--=================================================================================================
process (clk) begin
    if rising_edge(clk) then
        if (blu_detect.k_syn_12(1).n=1 and blu_detect.k_syn_12(2).n=2 and blu_detect.k_syn_12(3).n=3 and blu_detect.k_syn_12(4).n=4 
           and blu_detect.k_syn_12(5).n=5 and blu_detect.k_syn_12(6).n=6 and blu_detect.k_syn_12(7).n=7  
           and blu_detect.k_syn_12(8).n=8 and blu_detect.k_syn_12(9).n=9 and blu_detect.k_syn_12(10).n=10 
           and blu_detect.k_syn_12(11).n=11 and blu_detect.k_syn_12(12).n=12 and blu_detect.k_syn_12(13).n=13  
           and blu_detect.k_syn_12(14).n=14 and blu_detect.k_syn_12(15).n=15 and blu_detect.k_syn_12(16).n=16) then
            blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_123456789ABCDEFF), 14));
        elsif (blu_detect.k_syn_12(1).n=1 and blu_detect.k_syn_12(2).n=2 and blu_detect.k_syn_12(3).n=3
           and blu_detect.k_syn_12(5).n=5 and blu_detect.k_syn_12(6).n=6 and blu_detect.k_syn_12(7).n=7  
           and blu_detect.k_syn_12(9).n=9 and blu_detect.k_syn_12(10).n=10  and blu_detect.k_syn_12(11).n=11) then
            blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_123_567_9_10_11), 14));
        elsif (blu_detect.k_syn_12(1).n=2 and blu_detect.k_syn_12(2).n=2 and blu_detect.k_syn_12(3).n=3 and blu_detect.k_syn_12(4).n=4) then
            blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_1234), 14));
        elsif (blu_detect.k_syn_12(1).n=2 and blu_detect.k_syn_12(6).n=6 and  blu_detect.k_syn_12(7).n=7 and blu_detect.k_syn_12(8).n=8
           and blu_detect.k_syn_12(10).n=10 and blu_detect.k_syn_12(11).n=11 and blu_detect.k_syn_12(12).n=12  
           and blu_detect.k_syn_12(14).n=14 and blu_detect.k_syn_12(15).n=15  and blu_detect.k_syn_12(16).n=16) then
--  +-----+
--  | k1  |
--  |-----|-----|-----|-----|
--        | k6  | k7  | k8  |
--        |-----|-----|-----|
--        | k10 | k11 | k12 |
--        |-----|-----|-----| 
--        | k14 | k15 | k16 |
--        +-----+-----+-----+
            blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_678_10_11_12_14_15_16), 14));
        --elsif (blu_detect.k_syn_12(2).n=2 and blu_detect.k_syn_12(3).n=3 and blu_detect.k_syn_12(4).n=4 
        --   and blu_detect.k_syn_12(5).n=5 and blu_detect.k_syn_12(6).n=6 and blu_detect.k_syn_12(7).n=7  
        --   and blu_detect.k_syn_12(9).n=9 and blu_detect.k_syn_12(10).n=10   
        --   and blu_detect.k_syn_12(13).n=13) then
        --    blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_12563947_13_10), 14));
        --elsif (blu_detect.k_syn_12(2).n=2 and blu_detect.k_syn_12(3).n=3 and blu_detect.k_syn_12(4).n=4 
        --   and blu_detect.k_syn_12(5).n=5 and blu_detect.k_syn_12(6).n=6
        --   and blu_detect.k_syn_12(9).n=9
        --   and blu_detect.k_syn_12(13).n=13) then
        --    blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_1256394_13), 14));
        --elsif (blu_detect.k_syn_12(2).n=2 and blu_detect.k_syn_12(3).n=3 and blu_detect.k_syn_12(5).n=5 
        --and blu_detect.k_syn_12(6).n=6 and blu_detect.k_syn_12(9).n=9 and blu_detect.k_syn_12(13).n=13) then
        --    blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_125639_13), 14));
        --if (blu_detect.k_syn_12(2).n=2 and blu_detect.k_syn_12(3).n=3 and blu_detect.k_syn_12(4).n=4 
        --   and blu_detect.k_syn_12(5).n=5 and blu_detect.k_syn_12(6).n=6
        --   and blu_detect.k_syn_12(9).n=9) then
        --    blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_1256394), 14));
        --elsif (blu_detect.k_syn_12(2).n=2 and blu_detect.k_syn_12(3).n=3
        --   and blu_detect.k_syn_12(5).n=5 and blu_detect.k_syn_12(6).n=6 
        --   and blu_detect.k_syn_12(9).n=9) then
        --    blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_125639), 14));
        --elsif (blu_detect.k_syn_12(2).n=2 and blu_detect.k_syn_12(5).n=5 and blu_detect.k_syn_12(6).n=6) then
        --    blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_1256), 14));
        --if (blu_detect.k_syn_12(2).n=1 and blu_detect.k_syn_12(3).n=3 and blu_detect.k_syn_12(4).n=4 
        --   and blu_detect.k_syn_12(5).n=5 and blu_detect.k_syn_12(6).n=6 and blu_detect.k_syn_12(7).n=7  
        --   and blu_detect.k_syn_12(8).n=8) then
        --    blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_1_to_8), 14));
        --if (blu_detect.k_syn_12(2).n=1 and blu_detect.k_syn_12(5).n=5) then
        --    blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_125), 14));
        --elsif (blu_detect.k_syn_12(5).n=5) then
        --    blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_15), 14));
        --elsif (blu_detect.k_syn_12(2).n=2) then
        --    blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_12), 14));
        --if (blu_detect.k_syn_12(2).n=2 and blu_detect.k_syn_12(3).n=3 and blu_detect.k_syn_12(4).n=4) then
        --    blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_1234_sat), 14));
        elsif (blu_detect.k_syn_12(1).n=1 and blu_detect.k_syn_12(2).n=1 and blu_detect.k_syn_12(5).n=5) then
            blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_125), 14));
        elsif (blu_detect.k_syn_12(1).n=2 and blu_detect.k_syn_12(5).n=5) then
            blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_15), 14));
        elsif (blu_detect.k_syn_12(1).n=2 and blu_detect.k_syn_12(2).n=2) then
            blu_select.result   <= std_logic_vector(to_unsigned((blu_add.add_12), 14));
        else
            blu_select.result   <= std_logic_vector(to_unsigned(blu_add.add_1, 14));
        end if;
    end if;
end process;
--=================================================================================================

--rc_f_valid_inst : d_valid
--generic map (
--    pixelDelay   => 1)
--port map(
--    clk      => clk,
--    iRgb     => Rgb1,
--    oRgb     => Rgb2);

end behavioral;
--02092019 [02-17-2019]
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constantspackage.all;
use work.vpfRecords.all;
use work.portspackage.all;
entity videoSelect is
generic (
    img_width         : integer := 4096;
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
end videoSelect;
architecture Behavioral of videoSelect is
    signal vChannelSelect     : integer;
    signal eChannelSelect     : integer;
    signal ycbcr              : channel;
    signal selFilter          : channel;
    signal location           : cord := (x => 512, y => 512);
    signal rgbText            : channel;
    signal channels         : channel;
    
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
        if (vChannelSelect = 0) then
            selFilter           <= iFrameData.cgain;
        elsif(vChannelSelect = 1)then
            selFilter           <= iFrameData.sharp;
        elsif(vChannelSelect = 2)then
            selFilter           <= iFrameData.blur;
        elsif(vChannelSelect = 3)then
            selFilter           <= iFrameData.hsl;
        elsif(vChannelSelect = 4)then
            selFilter           <= iFrameData.hsv;
        elsif(vChannelSelect = 5)then
            selFilter           <= iFrameData.inrgb;
        elsif(vChannelSelect = 6)then
            selFilter           <= iFrameData.sobel;
        elsif(vChannelSelect = 7)then
            selFilter           <= iFrameData.embos;
        elsif(vChannelSelect = 8)then
            selFilter           <= iFrameData.maskSobelLum;
        elsif(vChannelSelect = 9)then
            selFilter           <= iFrameData.maskSobelTrm;
        elsif(vChannelSelect = 10)then
            selFilter           <= iFrameData.maskSobelRgb;
        elsif(vChannelSelect = 11)then
            selFilter           <= iFrameData.maskSobelShp;
        elsif(vChannelSelect = 12)then
            selFilter           <= iFrameData.maskSobelShp;
        elsif(vChannelSelect = 13)then
            selFilter           <= iFrameData.maskSobelBlu;
        elsif(vChannelSelect = 14)then
            selFilter           <= iFrameData.maskSobelYcc;
        elsif(vChannelSelect = 15)then
            selFilter           <= iFrameData.maskSobelHsv;
        elsif(vChannelSelect = 16)then
            selFilter           <= iFrameData.maskSobelHsl;
        elsif(vChannelSelect = 17)then
            selFilter           <= iFrameData.maskSobelCga;
        elsif(vChannelSelect = 18)then
            selFilter           <= iFrameData.colorTrm;
        elsif(vChannelSelect = 19)then
            selFilter           <= iFrameData.colorLmp;
        elsif(vChannelSelect = 20)then
            selFilter           <= iFrameData.tPattern;
        elsif(vChannelSelect = 21)then
            selFilter           <= iFrameData.cgainToCgain;
        elsif(vChannelSelect = 22)then
            selFilter           <= iFrameData.cgainToHsl;
        elsif(vChannelSelect = 23)then
            selFilter           <= iFrameData.cgainToHsv;
        elsif(vChannelSelect = 24)then
            selFilter           <= iFrameData.cgainToYcbcr;
        elsif(vChannelSelect = 25)then
            selFilter           <= iFrameData.cgainToShp;
        elsif(vChannelSelect = 26)then
            selFilter           <= iFrameData.cgainToBlu;
        elsif(vChannelSelect = 27)then
            selFilter           <= iFrameData.shpToCgain;
        elsif(vChannelSelect = 28)then
            selFilter           <= iFrameData.shpToHsl;
        elsif(vChannelSelect = 29)then
            selFilter           <= iFrameData.shpToHsv;
        elsif(vChannelSelect = 30)then
            selFilter           <= iFrameData.shpToYcbcr;
        elsif(vChannelSelect = 31)then
            selFilter           <= iFrameData.shpToShp;
        elsif(vChannelSelect = 32)then
            selFilter           <= iFrameData.shpToBlu;
        elsif(vChannelSelect = 33)then
            selFilter           <= iFrameData.bluToBlu;
        elsif(vChannelSelect = 34)then
            selFilter           <= iFrameData.bluToCga;
        elsif(vChannelSelect = 35)then
            selFilter           <= iFrameData.bluToShp;
        elsif(vChannelSelect = 36)then
            selFilter           <= iFrameData.bluToYcc;
        elsif(vChannelSelect = 37)then
            selFilter           <= iFrameData.bluToHsv;
        elsif(vChannelSelect = 38)then
            selFilter           <= iFrameData.bluToHsl;
        elsif(vChannelSelect = 39)then
            selFilter           <= iFrameData.bluToCgaShp;
        elsif(vChannelSelect = 40)then
            selFilter           <= iFrameData.bluToCgaShpYcc;
        elsif(vChannelSelect = 41)then
            selFilter           <= iFrameData.bluToCgaShpHsv;
        elsif(vChannelSelect = 42)then
            selFilter           <= iFrameData.bluToShpCga;
        elsif(vChannelSelect = 43)then
            selFilter           <= iFrameData.bluToShpCgaYcc;
        elsif(vChannelSelect = 44)then
            selFilter           <= iFrameData.bluToShpCgaHsv;
        elsif(vChannelSelect = 45)then
            selFilter           <= iFrameData.rgbCorrect;
        elsif(vChannelSelect = 46)then
            selFilter           <= iFrameData.rgbRemix;
        elsif(vChannelSelect = 47)then
            selFilter           <= iFrameData.rgbDetect;
        elsif(vChannelSelect = 48)then
            selFilter           <= iFrameData.rgbPoi;
        elsif(vChannelSelect = 49)then
            selFilter           <= iFrameData.ycbcr;
        else
            selFilter           <= iFrameData.rgbCorrect;
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
    iRgb                 => selFilter,
    y                    => ycbcr.red,
    cb                   => ycbcr.green,
    cr                   => ycbcr.blue,
    oValid               => ycbcr.valid);
    
    
process (clk) begin
    if rising_edge(clk) then
        oCord <= iFrameData.cod;
    end if;
end process;

channelOutP: process (clk) begin
    if rising_edge(clk) then
        if (eChannelSelect = 0) then
            channels   <= ycbcr;
        elsif(vChannelSelect = 1)then
            channels   <= selFilter;
        elsif(vChannelSelect = 2)then
            channels   <= ycbcr;
        else
            channels   <= selFilter; 
        end if;
    end if;
end process channelOutP;


TextGenYcbcrInst: TextGen
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
    iRgb            => channels,
    oRgb            => rgbText);
    
ChaTextP: process (clk) begin
    if rising_edge(clk) then
        if (eChannelSelect = 0) or (eChannelSelect = 1) then
            oRgb   <= channels;
        else
            oRgb   <= rgbText;
        end if;
    end if;
end process ChaTextP;


end Behavioral;
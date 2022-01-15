-------------------------------------------------------------------------------
--
-- Filename    : hsv_c.vhd
-- Create Date : 05062019 [05-06-2019]
-- Author      : Zakinder
--
-- Description:
-- This file instantiation
-- p ← RGB2HSV(p)
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fixed_pkg.all;
use work.float_pkg.all;

use work.constants_package.all;
use work.vpf_records.all;
use work.ports_package.all;

entity hsv_c is
generic (
    i_data_width   : integer := 8);
port (
    clk            : in  std_logic;
    reset          : in  std_logic;
    iRgb           : in channel;
    oHsv           : out channel);
end hsv_c;
architecture behavioral of hsv_c is
    signal uFs1Rgb       : intChannel;
    signal uFs2Rgb       : intChannel;
    signal uFs3Rgb       : intChannel;
    
    signal uFs11Rgb      : intChannel;
    signal uFs22Rgb      : intChannel;
    signal rgbMax        : natural;
    signal rgb2Max       : natural;
    signal rgbMin        : natural;
    signal maxValue      : natural;
    signal rgbDelta      : natural;
    --H
    signal hue_quot      : ufixed(17 downto 0) :=(others => '0');
    signal uuFiXhueQuot  : ufixed(17 downto -9) :=(others => '0');
    signal uuFiXhueTop   : ufixed(17 downto 0)  :=(others => '0');
    signal uuFiXhueBot   : ufixed(8 downto 0)   :=(others => '0');
    signal uFiXhueTop    : integer := zero;
    signal uFiXhueBot    : integer := zero;
    signal uFiXhueQuot   : integer := zero;
    signal hueQuot1x     : integer := zero;
    signal hueDeg        : integer := zero;
    signal hueDeg1x      : integer := zero;
    signal h_value       : integer := zero;
    --S
    signal s1value       : unsigned(7 downto 0);
    --V
    signal v1value       : unsigned(7 downto 0);
    --Valid
    signal valid1_rgb    : std_logic := '0';
    signal valid2_rgb    : std_logic := '0';
    signal valid3_rgb    : std_logic := '0';
    signal sHsl          : channel;
    signal lHsl          : channel;
begin
rgbToUfP: process (clk,reset)begin
    if (reset = lo) then
        uFs1Rgb.red    <= zero;
        uFs1Rgb.green  <= zero;
        uFs1Rgb.blue   <= zero;
    elsif rising_edge(clk) then
        uFs1Rgb.red    <= to_integer(unsigned(iRgb.red));
        uFs1Rgb.green  <= to_integer(unsigned(iRgb.green));
        uFs1Rgb.blue   <= to_integer(unsigned(iRgb.blue));
        uFs1Rgb.valid  <= iRgb.valid;
    end if;
end process rgbToUfP;
-- RGB.max = max(R, G, B)
rgbMaxP: process (clk) begin
    if rising_edge(clk) then
        if ((uFs1Rgb.red >= uFs1Rgb.green) and (uFs1Rgb.red >= uFs1Rgb.blue)) then
            rgbMax <= uFs1Rgb.red;
        elsif((uFs1Rgb.green >= uFs1Rgb.red) and (uFs1Rgb.green >= uFs1Rgb.blue))then
            rgbMax <= uFs1Rgb.green;
        else
            rgbMax <= uFs1Rgb.blue;
        end if;
    end if;
end process rgbMaxP;
--RGB.min = min(R, G, B)
rgbMinP: process (clk) begin
    if rising_edge(clk) then
        if ((uFs1Rgb.red <= uFs1Rgb.green) and (uFs1Rgb.red <= uFs1Rgb.blue)) then
            rgbMin <= uFs1Rgb.red;
        elsif((uFs1Rgb.green <= uFs1Rgb.red) and (uFs1Rgb.green <= uFs1Rgb.blue)) then
            rgbMin <= uFs1Rgb.green;
        else
            rgbMin <= uFs1Rgb.blue;
        end if;
    end if;
end process rgbMinP;
-- RGB.∆ = RGB.max − RGB.min
pipRgbMaxUfD1P: process (clk) begin
    if rising_edge(clk) then
        maxValue          <= rgbMax;
    end if;
end process pipRgbMaxUfD1P;
-- RGB.∆ = RGB.max − RGB.min
rgbDeltaP: process (clk) begin
    if rising_edge(clk) then
        rgbDelta      <= rgbMax - rgbMin;
    end if;
end process rgbDeltaP;
pipRgbD2P: process (clk) begin
    if rising_edge(clk) then
        uFs2Rgb <= uFs1Rgb;
        uFs3Rgb <= uFs2Rgb;
    end if;
end process pipRgbD2P;
-------------------------------------------------
-- HUE
-- RGB.∆ = RGB.MAX − RGB.MIN
-- IF (RED== RGB.MAX) *H = 0 + ( GRE - BLU ) / RGB.∆; BETWEEN ← YELLOW & MAGENTA
-- IF (GRE== RGB.MAX) *H = 2 + ( BLU - RED ) / RGB.∆; BETWEEN ← CYAN & YELLOW
-- IF (BLU== RGB.MAX) *H = 4 + ( RED - GRE ) / RGB.∆; BETWEEN ← MAGENTA & CYAN
-------------------------------------------------
hueP: process (clk) begin
  if rising_edge(clk) then
    if (uFs3Rgb.red  = maxValue) then
            hueDeg <= 0;
        if (uFs3Rgb.green >= uFs3Rgb.blue) then
            uFiXhueTop        <= (uFs3Rgb.green - uFs3Rgb.blue) * 60;
        else
            uFiXhueTop        <= (uFs3Rgb.blue - uFs3Rgb.green) * 60;
        end if;
    elsif(uFs3Rgb.green = maxValue)  then
            hueDeg <= 60;
        if (uFs3Rgb.blue >= uFs3Rgb.red ) then
            uFiXhueTop       <= (uFs3Rgb.blue - uFs3Rgb.red ) * 60;
        else
            uFiXhueTop       <= (uFs3Rgb.red  - uFs3Rgb.blue) * 60;
        end if;
    elsif(uFs3Rgb.blue = maxValue)  then
            hueDeg <= 120;
        if (uFs3Rgb.red  >= uFs3Rgb.green) then
            uFiXhueTop       <= (uFs3Rgb.red  - uFs3Rgb.green) * 60;
        else
            uFiXhueTop       <= (uFs3Rgb.green - uFs3Rgb.red ) * 60;
        end if;
    end if;
  end if;
end process hueP;
-------------------------------------------------
-- HUE
-- RGB.∆ = RGB.max − RGB.min
-------------------------------------------------
hueBottomP: process (clk) begin
    if rising_edge(clk) then
        if (rgbDelta > 0) then
            uFiXhueBot <= rgbDelta;
        else
            uFiXhueBot <= 6;
        end if;
    end if;
end process hueBottomP;

uuFiXhueTop   <= to_ufixed(uFiXhueTop,uuFiXhueTop);
uuFiXhueBot   <= to_ufixed(uFiXhueBot,uuFiXhueBot);
uuFiXhueQuot  <= (uuFiXhueTop / uuFiXhueBot);
hue_quot      <= resize(uuFiXhueQuot,hue_quot);
uFiXhueQuot   <= to_integer(unsigned(hue_quot));

hueDegreeP: process (clk) begin
    if rising_edge(clk) then
        hueDeg1x       <= hueDeg;
    end if;
end process hueDegreeP;
hueDividerResizeP: process (clk) begin
    if rising_edge(clk) then
        if (uFs3Rgb.red  = maxValue) then
            hueQuot1x <= uFiXhueQuot;
        else
            hueQuot1x <= uFiXhueQuot;
        end if;
        --hueQuot1x <= (uFiXhueQuot mod 45900) /255;
    end if;
end process hueDividerResizeP;
hueValueP: process (clk) begin
    if rising_edge(clk) then
        h_value <= hueQuot1x + hueDeg1x;
    end if;
end process hueValueP;    
-------------------------------------------------
-- SATURATE
-------------------------------------------------     
satValueP: process (clk) begin
    if rising_edge(clk) then
        if(rgbMax /= 0)then
            s1value <= to_unsigned((255*rgbDelta)/rgbMax,8);
        else
            s1value <= to_unsigned(0, 8);
        end if;
    end if;
end process satValueP; 
-------------------------------------------------
-- VALUE
-------------------------------------------------
valValueP: process (clk) begin
    if rising_edge(clk) then
        v1value <= to_unsigned(rgbMax, 8);
    end if;
end process valValueP;
pipValidP: process (clk) begin
    if rising_edge(clk) then
        valid1_rgb    <= uFs3Rgb.valid;
        valid2_rgb    <= valid1_rgb;
        valid3_rgb    <= valid2_rgb;
    end if;
end process pipValidP;


-------------------------------------------------
lHsl.red   <= std_logic_vector(to_unsigned(h_value, 8));
lHsl.green <= std_logic_vector(s1value);
lHsl.blue  <= std_logic_vector(v1value);
lHsl.valid <= valid3_rgb;


process (clk,reset)begin
    if (reset = lo) then
        uFs11Rgb.red    <= zero;
        uFs11Rgb.green  <= zero;
        uFs11Rgb.blue   <= zero;
    elsif rising_edge(clk) then
        uFs11Rgb.red    <= to_integer(unsigned(lHsl.red));
        uFs11Rgb.green  <= to_integer(unsigned(lHsl.green));
        uFs11Rgb.blue   <= to_integer(unsigned(lHsl.blue));
        uFs11Rgb.valid  <= lHsl.valid;
    end if;
end process;

-- RGB.max = max(R, G, B)
process (clk) begin
    if rising_edge(clk) then
    
    sHsl.valid <= uFs11Rgb.valid;
    sHsl.green <= std_logic_vector(to_unsigned(uFs11Rgb.green, 8));
    sHsl.blue  <= std_logic_vector(to_unsigned(uFs11Rgb.blue,  8));
    
        if ((uFs11Rgb.red >= uFs11Rgb.green) and (uFs11Rgb.red >= uFs11Rgb.blue)) then
            --if (uFs11Rgb.green >= uFs11Rgb.blue) then
            --    sHsl.red   <= std_logic_vector(to_unsigned(2, 2)) & std_logic_vector(to_unsigned(uFs11Rgb.red,   6));
            --    sHsl.green <= std_logic_vector(to_unsigned(2, 3)) & std_logic_vector(to_unsigned(uFs11Rgb.green, 5));
            --    sHsl.blue  <= std_logic_vector(to_unsigned(2, 3)) & std_logic_vector(to_unsigned(uFs11Rgb.blue,  5));
            --else
                --if (uFs11Rgb.red >= 150) then
                    sHsl.red   <= std_logic_vector(to_unsigned(uFs11Rgb.red,   8));
                    --sHsl.green <= std_logic_vector(to_unsigned(uFs11Rgb.green, 8));
                    --sHsl.blue  <= std_logic_vector(to_unsigned(uFs11Rgb.blue,  8));
                --elsif (uFs11Rgb.red >= 130  and uFs11Rgb.red <= 149) then
                --    sHsl.red   <= std_logic_vector(to_unsigned(130, 8));
                --    sHsl.green <= std_logic_vector(to_unsigned(130, 8));
                --    sHsl.blue  <= std_logic_vector(to_unsigned(130, 8));
                --elsif (uFs11Rgb.red >= 100  and uFs11Rgb.red <= 129) then
                --    sHsl.red   <= std_logic_vector(to_unsigned(110, 8));
                --    sHsl.green <= std_logic_vector(to_unsigned(110, 8));
                --    sHsl.blue  <= std_logic_vector(to_unsigned(110, 8));
                --elsif (uFs11Rgb.red >= 80  and uFs11Rgb.red <= 99) then
                --    sHsl.red   <= std_logic_vector(to_unsigned(80, 8));
                --    sHsl.green <= std_logic_vector(to_unsigned(80, 8));
                --    sHsl.blue  <= std_logic_vector(to_unsigned(80, 8));
                --elsif (uFs11Rgb.red >= 40  and uFs11Rgb.red <= 79) then
                --    sHsl.red   <= std_logic_vector(to_unsigned(40, 8));
                --    sHsl.green <= std_logic_vector(to_unsigned(40, 8));
                --    sHsl.blue  <= std_logic_vector(to_unsigned(40, 8));
                --elsif (uFs11Rgb.red >= 21  and uFs11Rgb.red <= 39) then
                --    sHsl.red   <= std_logic_vector(to_unsigned(30, 8));
                --    sHsl.green <= std_logic_vector(to_unsigned(30, 8));
                --    sHsl.blue  <= std_logic_vector(to_unsigned(30, 8));
                --elsif (uFs11Rgb.red >= 20 and uFs11Rgb.red <= 0) then
                --    sHsl.red   <= std_logic_vector(to_unsigned(20, 8));
                --    sHsl.green <= std_logic_vector(to_unsigned(20, 8));
                --    sHsl.blue  <= std_logic_vector(to_unsigned(20, 8));
                --end if;
            --end if;
        elsif((uFs11Rgb.green >= uFs11Rgb.red) and (uFs11Rgb.green >= uFs11Rgb.blue))then
        
               if (uFs11Rgb.green >= 150) then
                    sHsl.red   <= std_logic_vector(to_unsigned(uFs11Rgb.red,   8));
                    --sHsl.green <= std_logic_vector(to_unsigned(uFs11Rgb.green, 8));
                    --sHsl.blue  <= std_logic_vector(to_unsigned(uFs11Rgb.blue,  8));
                elsif (uFs11Rgb.green >= 130  and uFs11Rgb.green <= 149) then
                    sHsl.red   <= std_logic_vector(to_unsigned(130, 8));
                    --sHsl.green <= std_logic_vector(to_unsigned(130, 8));
                    --sHsl.blue  <= std_logic_vector(to_unsigned(130, 8));
                elsif (uFs11Rgb.green >= 100  and uFs11Rgb.green <= 129) then
                    sHsl.red   <= std_logic_vector(to_unsigned(110, 8));
                    --sHsl.green <= std_logic_vector(to_unsigned(110, 8));
                    --sHsl.blue  <= std_logic_vector(to_unsigned(110, 8));
                elsif (uFs11Rgb.green >= 80  and uFs11Rgb.green <= 99) then
                    sHsl.red   <= std_logic_vector(to_unsigned(80, 8));
                    --sHsl.green <= std_logic_vector(to_unsigned(80, 8));
                    --sHsl.blue  <= std_logic_vector(to_unsigned(80, 8));
                elsif (uFs11Rgb.green >= 40  and uFs11Rgb.green <= 79) then
                    sHsl.red   <= std_logic_vector(to_unsigned(40, 8));
                    --sHsl.green <= std_logic_vector(to_unsigned(40, 8));
                    --sHsl.blue  <= std_logic_vector(to_unsigned(40, 8));
                elsif (uFs11Rgb.green >= 21  and uFs11Rgb.green <= 39) then
                    sHsl.red   <= std_logic_vector(to_unsigned(30, 8));
                    --sHsl.green <= std_logic_vector(to_unsigned(30, 8));
                    --sHsl.blue  <= std_logic_vector(to_unsigned(30, 8));
                elsif (uFs11Rgb.green >= 20 and uFs11Rgb.green <= 0) then
                    sHsl.red   <= std_logic_vector(to_unsigned(20, 8));
                    --sHsl.green <= std_logic_vector(to_unsigned(20, 8));
                    --sHsl.blue  <= std_logic_vector(to_unsigned(20, 8));
                end if;
        
            --if (uFs11Rgb.blue >= uFs11Rgb.red ) then
            --    sHsl.red   <= std_logic_vector(to_unsigned(0, 2)) & std_logic_vector(to_unsigned(uFs11Rgb.red,   6));
            --    sHsl.green <= std_logic_vector(to_unsigned(0, 1)) & std_logic_vector(to_unsigned(uFs11Rgb.green, 7));
            --    sHsl.blue  <= std_logic_vector(to_unsigned(0, 3)) & std_logic_vector(to_unsigned(uFs11Rgb.blue,  5));
            --else
            --    if (uFs11Rgb.green >= 50) then
            --        sHsl.red   <= std_logic_vector(to_unsigned(0, 2)) & std_logic_vector(to_unsigned(uFs11Rgb.red,   6));
            --        sHsl.green <= std_logic_vector(to_unsigned(0, 3)) & std_logic_vector(to_unsigned(uFs11Rgb.green, 5));
            --        sHsl.blue  <= std_logic_vector(to_unsigned(0, 3)) & std_logic_vector(to_unsigned(uFs11Rgb.blue,  5));
            --    elsif (uFs11Rgb.green >= 40) then
            --        sHsl.red   <= std_logic_vector(to_unsigned(40, 8));
            --        sHsl.green <= std_logic_vector(to_unsigned(40, 8));
            --        sHsl.blue  <= std_logic_vector(to_unsigned(40, 8));
            --    elsif (uFs11Rgb.green >= 30) then
            --        sHsl.red   <= std_logic_vector(to_unsigned(30, 8));
            --        sHsl.green <= std_logic_vector(to_unsigned(30, 8));
            --        sHsl.blue  <= std_logic_vector(to_unsigned(30, 8));
            --    elsif (uFs11Rgb.green >= 20) then
            --        sHsl.red   <= std_logic_vector(to_unsigned(20, 8));
            --        sHsl.green <= std_logic_vector(to_unsigned(20, 8));
            --        sHsl.blue  <= std_logic_vector(to_unsigned(20, 8));
            --    else
            --        sHsl.red   <= std_logic_vector(to_unsigned(10, 8));
            --        sHsl.green <= std_logic_vector(to_unsigned(10, 8));
            --        sHsl.blue  <= std_logic_vector(to_unsigned(10, 8));
            --    end if;
            --end if;
        else
               if (uFs11Rgb.blue >= 150) then
                    sHsl.red   <= std_logic_vector(to_unsigned(uFs11Rgb.red,   8));
                    --sHsl.green <= std_logic_vector(to_unsigned(uFs11Rgb.green, 8));
                    --sHsl.blue  <= std_logic_vector(to_unsigned(uFs11Rgb.blue,  8));
                elsif (uFs11Rgb.blue >= 130  and uFs11Rgb.blue <= 149) then
                    sHsl.red   <= std_logic_vector(to_unsigned(130, 8));
                    --sHsl.green <= std_logic_vector(to_unsigned(130, 8));
                    --sHsl.blue  <= std_logic_vector(to_unsigned(130, 8));
                elsif (uFs11Rgb.blue >= 100  and uFs11Rgb.blue <= 129) then
                    sHsl.red   <= std_logic_vector(to_unsigned(110, 8));
                    --sHsl.green <= std_logic_vector(to_unsigned(110, 8));
                    --sHsl.blue  <= std_logic_vector(to_unsigned(110, 8));
                elsif (uFs11Rgb.blue >= 80  and uFs11Rgb.blue <= 99) then
                    sHsl.red   <= std_logic_vector(to_unsigned(80, 8));
                    --sHsl.green <= std_logic_vector(to_unsigned(80, 8));
                    --sHsl.blue  <= std_logic_vector(to_unsigned(80, 8));
                elsif (uFs11Rgb.blue >= 40  and uFs11Rgb.blue <= 79) then
                    sHsl.red   <= std_logic_vector(to_unsigned(40, 8));
                    --sHsl.green <= std_logic_vector(to_unsigned(40, 8));
                    --sHsl.blue  <= std_logic_vector(to_unsigned(40, 8));
                elsif (uFs11Rgb.blue >= 21  and uFs11Rgb.blue <= 39) then
                    sHsl.red   <= std_logic_vector(to_unsigned(30, 8));
                    --sHsl.green <= std_logic_vector(to_unsigned(30, 8));
                    --sHsl.blue  <= std_logic_vector(to_unsigned(30, 8));
                elsif (uFs11Rgb.blue >= 20 and uFs11Rgb.blue <= 0) then
                    sHsl.red   <= std_logic_vector(to_unsigned(20, 8));
                    --sHsl.green <= std_logic_vector(to_unsigned(20, 8));
                    --sHsl.blue  <= std_logic_vector(to_unsigned(20, 8));
                end if;
        
         --if (uFs11Rgb.red  >= uFs11Rgb.green) then
         --    sHsl.red   <= std_logic_vector(to_unsigned(0, 2)) & std_logic_vector(to_unsigned(uFs11Rgb.red,   6));
         --    sHsl.green <= std_logic_vector(to_unsigned(0, 3)) & std_logic_vector(to_unsigned(uFs11Rgb.green, 5));
         --    sHsl.blue  <= std_logic_vector(to_unsigned(0, 3)) & std_logic_vector(to_unsigned(uFs11Rgb.blue,  5));
         --else
         --   if (uFs11Rgb.blue >= 50) then
         --        sHsl.red   <= std_logic_vector(to_unsigned(0, 2)) & std_logic_vector(to_unsigned(uFs11Rgb.red,   6));
         --        sHsl.green <= std_logic_vector(to_unsigned(0, 3)) & std_logic_vector(to_unsigned(uFs11Rgb.green, 5));
         --        sHsl.blue  <= std_logic_vector(to_unsigned(0, 3)) & std_logic_vector(to_unsigned(uFs11Rgb.blue,  5));
         --    elsif (uFs11Rgb.blue >= 40) then
         --        sHsl.red   <= std_logic_vector(to_unsigned(40, 8));
         --        sHsl.green <= std_logic_vector(to_unsigned(40, 8));
         --        sHsl.blue  <= std_logic_vector(to_unsigned(40, 8));
         --    elsif (uFs11Rgb.blue >= 30) then
         --        sHsl.red   <= std_logic_vector(to_unsigned(30, 8));
         --        sHsl.green <= std_logic_vector(to_unsigned(30, 8));
         --        sHsl.blue  <= std_logic_vector(to_unsigned(30, 8));
         --    elsif (uFs11Rgb.blue >= 20) then
         --        sHsl.red   <= std_logic_vector(to_unsigned(20, 8));
         --        sHsl.green <= std_logic_vector(to_unsigned(20, 8));
         --        sHsl.blue  <= std_logic_vector(to_unsigned(20, 8));
         --    else
         --        sHsl.red   <= std_logic_vector(to_unsigned(10, 8));
         --        sHsl.green <= std_logic_vector(to_unsigned(10, 8));
         --        sHsl.blue  <= std_logic_vector(to_unsigned(10, 8));
         --    end if;
         --end if;
        end if;
    end if;
end process;

-------------------------------------------------
-- Hsv
-------------------------------------------------
pipRgbwD2P: process (clk) begin
    if rising_edge(clk) then
        oHsv.red   <= sHsl.red;
        oHsv.green <= sHsl.green;
        oHsv.blue  <= sHsl.blue;
        oHsv.valid <= sHsl.valid;
    end if;
end process pipRgbwD2P;
end behavioral;
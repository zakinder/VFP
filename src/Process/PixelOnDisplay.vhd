library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constantspackage.all;
use work.vpfrecords.all;
use work.portspackage.all;
entity PixelOnDisplay is
generic(
    img_width_bmp    : integer := 1920;
    img_height_bmp   : integer := 1080;
    b_data_width     : integer := 32);
port (
    clk          : in std_logic;
    rst_l        : in std_logic;
    location     : in cord;
    grid         : in cord;
    videoChannel : in std_logic_vector(b_data_width-1 downto 0);
    pixel        : out std_logic);
end PixelOnDisplay;

architecture Behavioral of PixelOnDisplay is
    constant NU_MRGB_TYPES       : natural := 40;
    signal displayText           : string(1 to 5):= "INRGB";
    signal vChannelSelect        : integer;
    signal fontAddress           : integer := 0;
    signal charBitInRow          : std_logic_vector(FONT_WIDTH-1 downto 0) := (others => '0');
    signal charCode              : natural := 0;
    signal charCodeLen           : natural := 16;
    signal charPosition          : integer := 1;
    signal bit_position_enable   : std_logic := lo;
    signal bit_position_sync     : std_logic := lo;
    signal bit_position          : natural range 0 to (FONT_WIDTH-1) := 0;
    
begin

vChannelSelect    <= to_integer(unsigned(videoChannel));

videoOutP: process (clk) begin
    if rising_edge(clk) then
        if (vChannelSelect = 0) then
            displayText      <= "CGAIN";
        elsif(vChannelSelect = 1)then
            displayText      <= "SHARP";
        elsif(vChannelSelect = 2)then
            displayText      <= "BLURE";
        elsif(vChannelSelect = 3)then
            displayText      <= "INHSL";
        elsif(vChannelSelect = 4)then
            displayText      <= "INHSV";
        elsif(vChannelSelect = 5)then
            displayText      <= "INRGB";
        elsif(vChannelSelect = 6)then
            displayText      <= "SOBEL";
        elsif(vChannelSelect = 7)then
            displayText      <= "EMBOS";
        elsif(vChannelSelect = 22)then
            displayText      <= "CGHSL";
        elsif(vChannelSelect = 25)then
            displayText      <= "CGSHP";
        elsif(vChannelSelect = 27)then
            displayText      <= "SHPCG";
        else
            displayText      <= "YCBCR";
        end if;
    end if;
end process videoOutP;


charPosition <= (iCrdDelta(grid.x,location.x)/FONT_WIDTH + 1) when (grid.x >= location.x);
charCode     <= (character'pos(displayText(charPosition))) when (charPosition > zero and charPosition < displayText'LENGTH);
fontAddress  <= (charCode*charCodeLen) + iCrdDelta(grid.y,location.y);
bit_position_enable  <= hi when (grid.x >= location.x - 1) else lo;

dSyncP: process(clk) begin
    if rising_edge(clk) then
        bit_position_sync <= bit_position_enable;
        if (bit_position_sync = hi and bit_position < FONT_WIDTH-1) then
            bit_position  <= bit_position + one;
        else
            bit_position <= zero;
        end if;
    end if;
end process dSyncP;

FontRomInst: FontRom
port map(
    clk     => clk,
    addr    => fontAddress,
    fontRow => charBitInRow);
    
pixelOn: process(clk)
    variable inXRange: boolean := false;
    variable inYRange: boolean := false;
begin
    if rising_edge(clk) then
        inXRange := false;
        inYRange := false;
        pixel   <= lo;
        if grid.x >= location.x and grid.x < location.x + (FONT_WIDTH * displayText'length) then
            inXRange := true;
        end if;
        if grid.y >= location.y and grid.y < location.y + FONT_HEIGHT then
            inYRange := true;
        end if;
        if inXRange and inYRange then
            if charBitInRow((FONT_WIDTH-1)- bit_position) = hi then
                pixel <= hi;
            end if;                    
        end if;
    end if;
end process;
end Behavioral;
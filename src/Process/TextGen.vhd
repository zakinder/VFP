library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constantspackage.all;
use work.vpfrecords.all;
use work.portspackage.all;
entity TextGen is
generic(
    img_width_bmp    : integer := 1920;
    img_height_bmp   : integer := 1080;
    b_data_width     : integer := 32);
port (
    clk              : in std_logic;
    rst_l            : in std_logic;
    videoChannel     : in std_logic_vector(b_data_width-1 downto 0);
    txCord           : in coord;
    location         : in cord;
    iRgb             : in channel;
    oRgb             : out channel);
end TextGen;
architecture Behavioral of TextGen is
    signal grid  :  cord;
    signal pixOn : std_logic := '0';
begin
grid.x <= to_integer(unsigned(txCord.x(11 downto 0)));
grid.y <= (img_height_bmp-1) - (to_integer(unsigned(txCord.y(11 downto 0))));
textElement2: PixelOnDisplay
generic map (
    img_width_bmp  => img_width_bmp,
    img_height_bmp => img_height_bmp,
    b_data_width   => b_data_width)
port map(
    clk          => clk,
    rst_l        => rst_l,
    videoChannel => videoChannel,
    location     => location,
    grid         => grid,
    pixel        => pixOn);
process (clk) begin
    if rising_edge(clk) then
    if (rst_l = lo) then
        oRgb.red   <= black;
        oRgb.green <= black;
        oRgb.blue  <= black;
    else
     oRgb.valid  <= iRgb.valid;
        if (iRgb.valid = hi) then
            if (pixOn = hi) then
                oRgb.red   <= black;
                oRgb.green <= black;
                oRgb.blue  <= black;
            else
                oRgb.red   <= iRgb.red;
                oRgb.green <= iRgb.green;
                oRgb.blue  <= iRgb.blue;
            end if;
        end if;    
    end if;
    end if;
end process;
end Behavioral;
--12302021 [12-30-2021]
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package tbPackage is
    ----------------------------------------------------------------------------------------------------
    --procdures
    procedure clk_gen(signal clk : out std_logic; constant FREQ : real);
    ----------------------------------------------------------------------------------------------------
    --functions
    function conv_std_logic_vector(arg : integer; size : integer)   return std_logic_vector;
    function maxchar(L: integer)                                    return string;
    function maxthr(L, M, R: integer)                               return integer;
    function max(L, R: integer)                                     return integer;
    function min(L, R: integer)                                     return integer;
    function image_size_width(bmp: string)                          return integer;
    function image_size_height(bmp: string)                         return integer;
    ----------------------------------------------------------------------------------------------------
    --       [64_64   = 5   us]
    --       [128_128 = 18  us]
    --       [255_255 = 18  us]
    --       [300_300 = 110 us]
    --       [400_300 = 123 us] 1/2 HR
    --       [500_500 = 250 us] 1   HR
    --       [770_580 = 452 us]
    constant readbmp             : string  := "128_128";
    constant Histrograms         : string  := "Histrograms";
    constant img_width           : integer := image_size_width(readbmp);
    constant img_height          : integer := image_size_height(readbmp);
    ----------------------------------------------------------------------------------------------------
    constant clk_freq            : real    := 1000.00e6;
    constant revision_number     : std_logic_vector(31 downto 0) := x"02212019";
    constant pixclk_freq         : real    := 150.00e6;
    constant aclk_freq           : real    := 150.00e6;
    constant mm2s_aclk           : real    := 150.00e6;
    constant maxis_aclk          : real    := 150.00e6;
    constant saxis_aclk          : real    := 150.00e6;
    constant dataWidth           : integer := 12; 
    constant line_hight          : integer := 5;  
    constant adwrWidth           : integer := 16;
    constant addrWidth           : integer := 12;
    constant SLOT_NUM            : integer := 53;
    constant wImgFolder          : string := "K:/ZEDBOARD/simulations/images/write";
    constant rImgFolder          : string := "K:/ZEDBOARD/simulations/images/read";
    constant bSlash              : string := "\";
    constant fSlash              : string := "/";
    constant LogsFolder          : string := "Logs";
end package;


--------------------------------------------------------------------------------------------------------
--TB PACKAGE
--------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package body tbPackage is
    ----------------------------------------------------------------------------------------------------
    function image_size_width(bmp: string) return integer is
    begin
       if bmp = "64_64"  then
           return 64;
       elsif bmp = "128_128" then
           return 128;
       elsif bmp = "255_255" then
           return 255;
       elsif bmp = "255_127" then
           return 255;
       elsif bmp = "300_300" then
           return 300;
       elsif bmp = "500_500" then
           return 500;
       elsif bmp = "600_600" then
           return 600;
       elsif bmp = "770_580" then
           return 770;
       elsif bmp = "950_950" then
           return 950;
       end if;
    end;
    ----------------------------------------------------------------------------------------------------
    function image_size_height(bmp: string) return integer is
    begin
       if bmp = "64_64"  then
           return 64;
       elsif bmp = "128_128" then
           return 128;
       elsif bmp = "255_255" then
           return 255;
       elsif bmp = "255_127" then
           return 127;
       elsif bmp = "300_300" then
           return 300;
       elsif bmp = "500_500" then
           return 500;
       elsif bmp = "600_600" then
           return 600;
       elsif bmp = "770_580" then
           return 580;
       elsif bmp = "950_950" then
           return 950;
       end if;
    end;
    ----------------------------------------------------------------------------------------------------
    function maxchar(L: integer) return string is
    begin
       if L >= 100  then
           return " ";
       elsif L >= 10 then
           return "  ";
       elsif L <= 10 then
           return "   ";
       end if;
    end;
    ----------------------------------------------------------------------------------------------------
    function maxthr(L, M, R: integer) return integer is
    begin
       if L > R and L > M then
           return L;
       elsif M > L and M > R then
           return L;
       else
           return R;
       end if;
    end;
    ----------------------------------------------------------------------------------------------------
    function max(L, R: integer) return integer is
    begin
       if L > R then
           return L;
       else
           return R;
       end if;
    end;
    ----------------------------------------------------------------------------------------------------
    function min(L, R: integer) return integer is
    begin
       if L < R then
           return L;
       else
           return R;
       end if;
    end;
    ----------------------------------------------------------------------------------------------------
    procedure clk_gen(signal clk : out std_logic; constant FREQ : real) is
        constant PERIOD    : time := 1 sec / FREQ;
        constant HIGH_TIME : time := PERIOD / 2;
        constant LOW_TIME  : time := PERIOD - HIGH_TIME;
        begin
            loop
            clk <= '1';
            wait for HIGH_TIME;
            clk <= '0';
            wait for LOW_TIME;
        end loop;
    end procedure;
    ----------------------------------------------------------------------------------------------------
    function conv_std_logic_vector(arg : integer; size : integer) return std_logic_vector is
        variable result         : std_logic_vector (size - 1 downto 0);
        variable temp           : integer;
        begin
        temp := arg;
        for i in 0 to size - 1 loop
            if (temp mod 2) = 1 then
                result(i) := '1';
            else
                result(i) := '0';
            end if;
            if temp > 0 then
                temp := temp / 2;
            elsif (temp > integer'low) then
                temp := (temp - 1) / 2;
            else
                temp := temp / 2;
            end if;
        end loop; 
        return result;
    end function;
    ----------------------------------------------------------------------------------------------------
end package body;
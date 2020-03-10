-------------------------------------------------------------------------------
--
-- Filename    : image_write.vhd
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
use std.textio.all;
use ieee.std_logic_textio.all;

use work.constants_package.all;
use work.vpf_records.all;
use work.ports_package.all;
use work.tbpackage.all;

entity image_write is
generic (
    enImageText   : boolean := false;
    enImageIndex  : boolean := false;
    i_data_width  : integer := 8;
    test          : string  := "folder";
    input_file    : string  := "input_image";
    output_file   : string  := "output_image");
port (
    pixclk        : in  std_logic;
    enableWrite   : in  std_logic;
    iRgb          : in channel);
end image_write; 
architecture Behavioral of image_write is
    constant outPutPath1a  : string := "K:\ZEDBOARD/uvm_tb/VFP_TEST/dut/tb/uvm_images/vhdl_images/w_images";
    constant outPutPath1b  : string := "K:\ZEDBOARD/uvm_tb/VFP_TEST/dut/tb/uvm_images/vhdl_images/imagesLogs";
    constant backSlash     : string := "\";
    constant wrBmp         : string := outPutPath1a&backSlash&output_file&".bmp";
    constant wrBmpLog      : string := outPutPath1a&backSlash&output_file&".txt";
    constant readbmp       : string := input_file&".bmp";
    type bitFile is file of bit_vector;
    file readFile       : bitFile open read_mode  is readbmp;
    type stdFile is file of character;
    file wrBmpfile      : stdFile open write_mode is wrBmp;
    file wrBmpLogfile   : text open write_mode is wrBmpLog;
    type imageHeaderTable is array(0 to 60) of integer range 0 to 255;
    constant imageHeader    : imageHeaderTable := (0,66,77,54,192,0,0,0,0,0,0,54,0,0,0,40,0,0,0,128,0,0,0,128,0,0,0,1,0,24,0,0,0,0,0,0,192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    type rgbPixel is array(1 to 3) of std_logic_vector(i_data_width-1 downto 0);
    type rgbFrame is array(0 to img_width -1, 0 to img_height -1) of rgbPixel;
    signal rgbData         : rgbFrame  := (others => (others => (others => (others => '0'))));
    signal Xcont           : integer   := 0;
    signal Ycont           : integer   := 0;
    signal wrImageFile     : std_logic := lo;
    signal frameEnable     : std_logic := lo;
    signal rgb,rgb1,rgb2             :  channel  := (valid => lo, red => black, green => black, blue => black);
    
    
    signal imageCompleted  : std_logic := lo;
    
begin


process (pixclk) begin
    if rising_edge(pixclk) then
        rgb   <= iRgb;
        rgb1   <= rgb;
        rgb2   <= rgb1;
    end if;
end process;

frameEnable <= hi when (enableWrite = hi and imageCompleted = lo);



readRgbDataP: process(pixclk)begin
    if rising_edge(pixclk) then
        if(frameEnable = hi) then
        
            if (rgb.valid = hi and wrImageFile = lo) then
                Xcont  <= Xcont + 1;
            end if;
            
            rgbData(Xcont, Ycont)(3) <= rgb2.red;
            rgbData(Xcont, Ycont)(2) <= rgb2.green;
            rgbData(Xcont, Ycont)(1) <= rgb2.blue;
            
            if(Xcont = img_width - 1)then
                Ycont  <= Ycont + 1;
                Xcont  <= 0;
            end if;
            
            
            if(Xcont = img_width - 1 and Ycont = img_height - 1)then
                Ycont  <= 0;
            end if;
            
            
        end if;        
    end if;
end process readRgbDataP;


ImageFrameLoadDoneP: process(Ycont,Xcont)begin
    if (Xcont = img_width - 1 and Ycont = img_height - 1) then
        wrImageFile <= hi;
    end if;
end process ImageFrameLoadDoneP;

ImageFrameP: process
    variable stdBuffer      : character;
    variable outLine        : line;
    variable cnt            : integer := 0;
    variable pixelIndex     : integer := 0;
    variable rowIndex       : integer := 0;
    variable pixelLocation  : integer := 0;
    variable charSpace      : character := ' ';
    variable nBitVale       : bit_vector (0 downto 0);
    variable actual_len     : natural;
    begin
    wait until wrImageFile = hi;
    -- for i in 1 to 54 loop
        -- cnt := cnt + 1;
        -- stdBuffer := character'val(imageHeader(cnt));
        -- write(wrBmpfile, stdBuffer);
    -- end loop;
    
    for i in 0 to 53 loop
        read(readFile, nBitVale, actual_len);
        stdBuffer := character'val(to_integer(unsigned(conv_std_logic_vector(bit'pos(nBitVale(0)), 8))));
        write(wrBmpfile, stdBuffer);
    end loop;
    
    for y in 0 to img_height - 1 loop
        rowIndex := rowIndex + 1;
        pixelLocation := 0;
        
        for x in 0 to img_width - 1 loop
        
            for c in 1 to 3 loop
            
                if (pixelIndex > 18) and (y < img_height) then
                    stdBuffer := character'val(to_integer(unsigned(rgbData(x, y)(c))));
                    write(wrBmpfile, stdBuffer);
                end if;
                

                
            end loop;
            
            pixelLocation := pixelLocation + 1;
            pixelIndex    := pixelIndex + 1;
            if(enImageText = True) then
                if(enImageIndex = True) then
                    write(outLine,pixelIndex);
                    write(outLine,charSpace);
                    write(outLine,rowIndex);
                    write(outLine,charSpace);
                    write(outLine,pixelLocation);
                    write(outLine,charSpace);
                end if;
                write(outLine,(to_integer(unsigned(rgbData(x, y)(3)))));
                write(outLine,charSpace);
                write(outLine,(to_integer(unsigned(rgbData(x, y)(2)))));
                write(outLine,charSpace);
                write(outLine,(to_integer(unsigned(rgbData(x, y)(1)))));
                writeline(wrBmpLogfile, outLine);
            end if;
        end loop;
    end loop;
    wait for 10 ns;
    imageCompleted <= hi;
	assert false
	report "simulation ended"
	severity failure;
end process ImageFrameP;
end Behavioral;